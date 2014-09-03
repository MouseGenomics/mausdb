####################################################################
# Checkup-Script for MausDB                                        #
#                                                                  #
# intented to run daily as cron job for quality control            #
####################################################################

use strict;
use Mail::Sendmail;
use CGI qw(:standard);
use DBI;

#--------------------------------
# configuration
my $hostname = "<mausdb_hostname>";           # if mausdb.uni-abc.de is your MausDB server, enter "mausdb" here

my %checkup_data;
$checkup_data{0}{'admin_mail'}                = 'admin@your.institution.com';
$checkup_data{0}{'admins_mail'}               = 'admin1@your.institution.com; admin2@your.institution.com';
$checkup_data{0}{'host'}                      = '<mausdb_hostname>';            # if mausdb.uni-abc.de is your MausDB server, enter "mausdb" here

$checkup_data{1}{'database'}                  = 'mausdb_1';
$checkup_data{1}{'db_username'}               = '<db-username>';
$checkup_data{1}{'db_password'}               = '<password>';

$checkup_data{2}{'database'}                  = 'mausdb_2';
$checkup_data{2}{'db_username'}               = '<db-username>';
$checkup_data{2}{'db_password'}               = '<password>';


#--------------------------------
# process input

# check MausDB_1
if (defined(param('do_checkup')) && param('do_checkup') eq 'yes') {
   do_checkup(1);
}

# check MausDB_2
if (defined(param('do_checkup')) && param('do_checkup') eq 'yes') {
   do_checkup(2);
}


# no parameters given: short help on usage
if (!defined(param('do_checkup'))) {
   print "Usage: #> (sudo) perl checkup.pl do_checkup=yes \n";
}


#-------------------------------------------------------------------------------
#  do_checkup():                    do the checkup
sub do_checkup {
  my $backup = shift;
  my $mailbody = '';
  my $datetime = current_datetime();
  my $error_counter = 0;
  my ($errors, $mice_alive_1, $mice_alive_2, $occupied_cages_1, $occupied_cages_2);
  my ($query_column, $table_string, $table_errors);
  my @check_tables;
  my @error_cages;
  my %mail_to_admin = ();
  my %cage_count;
  my $current_datetime = current_datetime();
  my ($result, $rows, $row, $i);
  my $sql;
  my @sql_parameters;

  # connect to database
  my ($dbh, $db_server, $db_name) = my_connect($checkup_data{0}{'host'},
                                               $checkup_data{$backup}{'database'},
                                               $checkup_data{$backup}{'db_username'},
                                               $checkup_data{$backup}{'db_password'}
                                    );

  ###########################################################################################
  $current_datetime = current_datetime();

  $mailbody .= "Checking database $checkup_data{$backup}{'database'} on $hostname at $current_datetime\n\n"
               . "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  # 1) check number of alive animals
  $mailbody .= "1) Checking number of alive animals\n\n";

  ###################
  # method 1
  $sql = qq(select count(*) as mice_alive1
            from   mice
            where  mouse_deathorexport_datetime is null
         );

  @sql_parameters = ();

  ($mice_alive_1) = @{do_single_result_sql_query($dbh, $sql, \@sql_parameters, __LINE__)};

  $mailbody .= "Number of alive animals (method 1):\n$mice_alive_1\n";

  ###################
  # method 2
  $sql = qq(select count(*) as mice_alive2
            from   mice2cages
            where  m2c_datetime_to is null
                   and m2c_cage_id > ?
         );

  @sql_parameters = (0);

  ($mice_alive_2) = @{do_single_result_sql_query($dbh, $sql, \@sql_parameters, __LINE__)};

  $mailbody .= "Number of alive animals (method 2):\n$mice_alive_2\n";

  ###################
  # compare results
  if ($mice_alive_1 eq $mice_alive_2) {
     $mailbody .= "\nNO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "\nTHERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";


  ###########################################################################################
  $mailbody .= "2) Checking number of occupied cages with 2 independent methods\n\n";

  ###################
  # method 1
  $sql = qq(select count(*)
            from   cages
            where  cage_id > ?
                   and cage_occupied = ?
         );

  @sql_parameters = (0, 'y');

  ($occupied_cages_1) = @{do_single_result_sql_query($dbh, $sql, \@sql_parameters, __LINE__)};

  $mailbody .= "Number of occupied cages (method 1):\n$occupied_cages_1\n";

  ###################
  # method 2
  $sql = qq(select count(*)
            from   cages2locations
            where  c2l_datetime_to is null
                   and c2l_cage_id > ?
         );

  @sql_parameters = (0);

  ($occupied_cages_2) = @{do_single_result_sql_query($dbh, $sql, \@sql_parameters, __LINE__)};

  $mailbody .= "Number of occupied cages (method 2):\n$occupied_cages_2\n";

  if ($occupied_cages_1 eq $occupied_cages_2) {
     $mailbody .= "\nNO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "\nTHERE WHERE ERRORS!\n\n";
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "3) Checking for errors in mouse cage/location tables\n\n";

  $sql = qq(select m2c_mouse_id as mouse_id, count(m2c_cage_id) as number_of_cages
            from   mice2cages
            where  m2c_datetime_to IS NULL
            group  by mouse_id
            having number_of_cages <> ?
           );

  @sql_parameters = (1);

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... multiple cage/location entries for the following mouse/mice\n\n"
                  . "mouse ID\tnumber of cages\n";

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $mailbody .= "$row->{'mouse_id'}\t$row->{'number_of_cages'}\n";
      }
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "4) Checking for living mice with wrong status\n\n";

  $sql = qq(select mouse_id, dr1.death_reason_name as how, dr2.death_reason_name as why
            from   mice
                   join death_reasons dr1 on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2 on  mouse_deathorexport_why = dr2.death_reason_id
            where  mouse_deathorexport_datetime IS NULL
                   and (mouse_deathorexport_how <> ?
                        OR
                        mouse_deathorexport_why <> ?
                       )
           );

  @sql_parameters = (1, 2);

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... found the following living mice with wrong status\n"
                  . "mouse ID\tdate of death\thow\twhy\n";

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $mailbody .= "$row->{'mouse_id'}\t-\t$row->{'how'}\t$row->{'why'}\n";
      }
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "5) Checking for living mice in wrong cage\n\n";

  $sql = qq(select mouse_id, dr1.death_reason_name as how, dr2.death_reason_name as why, m2c_cage_id
            from   mice
                   join death_reasons dr1 on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2 on  mouse_deathorexport_why = dr2.death_reason_id
                   join mice2cages        on             m2c_mouse_id = mouse_id
            where  mouse_deathorexport_datetime IS NULL
                   and m2c_datetime_to IS NULL
                   and m2c_cage_id < ?
           );

  @sql_parameters = (0);

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... found the following living mice with wrong status\n"
                  . "mouse ID\tdate of death\thow\twhy\tcage\n";

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $mailbody .= "$row->{'mouse_id'}\t-\t$row->{'how'}\t$row->{'why'}\t$row->{'m2c_cage_id'}\n";
      }
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "6) Checking for dead mice with wrong status\n\n";

  $sql = qq(select mouse_id, mouse_deathorexport_datetime, dr1.death_reason_name as how, dr2.death_reason_name as why
            from   mice
                   join death_reasons dr1 on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2 on  mouse_deathorexport_why = dr2.death_reason_id
            where  not (mouse_deathorexport_datetime IS NULL)
                   and (mouse_deathorexport_how = ?
                        OR
                        mouse_deathorexport_why = ?
                       )
           );

  @sql_parameters = (1, 2);

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... found the following dead mice with wrong status\n"
              . "mouse ID\tdate of death\thow\twhy\n";

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $mailbody .= "$row->{'mouse_id'}\t$row->{'mouse_deathorexport_datetime'}\t$row->{'how'}\t$row->{'why'}\n";
      }
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "7) Checking for dead mice in wrong cage\n\n";

  $sql = qq(select mouse_id, mouse_deathorexport_datetime, dr1.death_reason_name as how, dr2.death_reason_name as why, m2c_cage_id
            from   mice
                   join death_reasons dr1 on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2 on  mouse_deathorexport_why = dr2.death_reason_id
                   join mice2cages        on             m2c_mouse_id = mouse_id
            where  not (mouse_deathorexport_datetime IS NULL)
                   and m2c_datetime_to IS NULL
                   and m2c_cage_id > ?
           );

  @sql_parameters = (0);

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... found the following dead mice with wrong status\n"
                  . "mouse ID\tdate of death\thow\twhy\tcage\n";

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $mailbody .= "$row->{'mouse_id'}\t$row->{'mouse_deathorexport_datetime'}\t$row->{'how'}\t$row->{'why'}\t$row->{'m2c_cage_id'}\n";
      }
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "8) Checking for errors in cage status\n\n";

  # get all cages which have the 'occupied' flag
  $sql = qq(select cage_id
            from   cages
            where  cage_occupied = ?
                   and   cage_id > ?
           );

  @sql_parameters = ('y', 0);

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      $cage_count{$row->{'cage_id'}}++;
  }

  # get all cages which have no end datetime in table 'mice2cages'
  $sql = qq(select distinct m2c_cage_id
            from   mice2cages
            where  m2c_datetime_to IS NULL
                   and   m2c_cage_id > ?
           );

  @sql_parameters = (0);

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      $cage_count{$row->{'m2c_cage_id'}}++;
  }

  # no check for cages that did not occur in both result lists
  foreach (keys %cage_count) {
     if ($cage_count{$_} != 2) {
        push(@error_cages, $_);
     }
  }

  if (scalar(@error_cages) == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... please check status of the following cages: \n"
                  . 'cage list: ' . join(',', @error_cages) . "\n";
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "9) Checking for errors in cage moves\n\n";

  # find all cages with more than one current rack location
  $sql = qq(select c2l_cage_id as cage, count(c2l_location_id) as current_locations
            from   cages2locations
            where  c2l_datetime_to is null
            group  by c2l_cage_id
            having current_locations > ?
           );

  @sql_parameters = (1);

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... multiple current rack entries for the following cage(s) found:\n"
                  . "cage ID\tnumber of current racks\n";

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $mailbody .= "$row->{'cage_id'}\t$row->{'current_locations'}\n";
      }
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "10) Checking for mice where alive/dead status does not match experiment_end status\n\n";

  $sql = qq(select mouse_id, mouse_deathorexport_datetime, m2e_datetime_to
            from   mice
                   join mice2experiments on mouse_id = m2e_mouse_id
            where  ( (mouse_deathorexport_datetime is null and m2e_datetime_to is not null)
                     or
                     (mouse_deathorexport_datetime is not null and m2e_datetime_to is null)
                   )
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... mice with mismatch in date of death and experiment end:\n"
                 . "mouse ID\tdate/time of death\tdate/time of experiment end\n";

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $mailbody .= "$row->{'mouse_id'}\t$row->{'mouse_deathorexport_datetime'}\t$row->{'m2e_datetime_to'}\n";
      }
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "11) Checking for mice where GVO differs from line GVO status\n\n";

  $sql = qq(select mouse_id, mouse_is_gvo, line_name
            from   mice
                   join mouse_lines    on mouse_line = line_id
                   join GTAS_line_info on mouse_line = gli_mouse_line_id
            where  gli_mouse_line_is_gvo != mouse_is_gvo
                   and mouse_id > ?
           );

  @sql_parameters = (30067000);

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... $rows mice with mismatch of GVO status between mouse and line:\n"
                 . "mouse ID\tis GVO\tline name\n";

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $mailbody .= "$row->{'mouse_id'}\t$row->{'mouse_is_gvo'}\t$row->{'line_name'}\n";
      }
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "12) Checking for mice where experiment start date is after date of death\n\n";

  $sql = qq(select mouse_id, line_name, strain_name,
                   date(mouse_deathorexport_datetime) as died,
                   date(m2e_datetime_from)            as experiment_start,
                   date(m2e_datetime_to)              as experiment_end
            from   mice
                   join mouse_lines           on      line_id = mouse_line
                   join mouse_strains         on    strain_id = mouse_strain
                   left join mice2experiments on m2e_mouse_id = mouse_id
            where  (mouse_deathorexport_datetime < m2e_datetime_from
                    or
                    mouse_deathorexport_datetime < m2e_datetime_to
                   )
                   and mouse_id > ?
           );

  @sql_parameters = (30028500);

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... $rows mice with experiment start date after date of death:\n"
                 . "mouse ID\tline\tstrain\tdied\texperiment start\texperiment end\n";

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $mailbody .= "$row->{'mouse_id'}\t$row->{'line_name'}\t$row->{'strain_name'}\t$row->{'died'}\t$row->{'experiment_start'}\t$row->{'experiment_end'}\n";
      }
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "13) Checking for mice with more than one experiment\n\n";

  $sql = qq(select m2e_mouse_id, count(m2e_experiment_id) as number
            from   mice2experiments
            group  by m2e_mouse_id
            having number > ?
                   and m2e_mouse_id > ?
            order by m2e_mouse_id asc
           );

  @sql_parameters = (1, 30111700);

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... $rows mice with more than one experiment:\n"
                 . "mouse ID\texperiments\n";

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $mailbody .= "$row->{'m2e_mouse_id'}\t$row->{'number'}\n";
      }
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "14) Checking for orderlists with wrong datetime '0000-00-00 00:00:00' on medical_records\n\n";

  $sql = qq(select distinct mr_orderlist_id, mr_parameterset_id, parameterset_name, line_name
            from   medical_records
                   join parametersets on mr_parameterset_id = parameterset_id
                   left join mice2orderlists on    mr_orderlist_id = m2o_orderlist_id
                   left join mice            on           mouse_id = m2o_mouse_id
                   left join mouse_lines     on         mouse_line = line_id
            where  mr_measure_datetime = ?
            group  by mr_orderlist_id
           );

  @sql_parameters = ('0000-00-00 00:00:00');

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... $rows orderlists with wrong datetime format medical records\n"
                 . "orderlist\tparameterset_id\tparameterset\tline\n";

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $mailbody .= "$row->{'mr_orderlist_id'}\t$row->{'mr_parameterset_id'}\t$row->{'parameterset_name'}\t$row->{'line_name'}\n";
      }
  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "15) Checking for orphan entries in mice2medical_records\n\n";

  $sql = qq(select m2mr_mr_id, m2mr_mouse_id, mr_id
            from   mice2medical_records
                   left join medical_records on m2mr_mr_id = mr_id
            where  mr_id is NULL
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... $rows orphan entries in mice2medical_records found\n"
                  . "\nplease run the following SQL query: \n"
                  . $sql . "\n";

  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "16) Checking for orphan medical_records\n\n";

  $sql = qq(select mr_id, m2mr_mr_id, m2mr_mouse_id
            from   medical_records
                   left join mice2medical_records on m2mr_mr_id = mr_id
            where  m2mr_mr_id is NULL
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... $rows orphan medical_records found\n"
                  . "\nplease run the following SQL query: \n"
                  . $sql . "\n";

  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  $mailbody .= "17) Checking for medical records with mr_measure_datetime > mouse_deathorexport_datetime\n\n";

  $sql = qq(select mouse_id, date(mouse_deathorexport_datetime), date(mr_measure_datetime)
            from   mice2medical_records
                   join medical_records on    mr_id = m2mr_mr_id
                   join mice            on mouse_id = m2mr_mouse_id
            where  date(mr_measure_datetime) > date(mouse_deathorexport_datetime)
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  if ($rows == 0) {
     $mailbody .= "NO ERRORS\n\n";
  }
  else {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
     $mailbody .= "... $rows medical records with mr_measure_datetime > mouse_deathorexport_datetime\n"
                  . "\nplease run the following SQL query: \n"
                  . $sql . "\n";

  }

  $mailbody .= "-------------------------------------------------------------------\n\n\n";

  ###########################################################################################
  # check tables
  $current_datetime = current_datetime();
  $table_errors = 0; 

  $mailbody .= "18) Checking tables of database $checkup_data{$backup}{'database'} on $checkup_data{$backup}{'host'} at $current_datetime\n\n";

  # collect all tables to check
  $query_column = 'Tables_in_' . $checkup_data{$backup}{'database'};

  $sql = qq(show tables);

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@check_tables, $row->{$query_column});
  }

  $table_string = join(', ', @check_tables);

  $sql = qq(CHECK TABLE $table_string);

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($dbh, $sql, \@sql_parameters, __LINE__ );

  # loop over tables to see if any errors
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      if ($row->{'Msg_text'} ne "OK") {
         $table_errors++;
      }
  }

  $mailbody .= "$rows tables\n\n";

  if ($table_errors != 0) {
     $error_counter++;
     $mailbody .= "THERE WHERE ERRORS!\n\n";
  }
  else {
     $mailbody .= "NO ERRORS\n\n";
  }

  # now loop again, this time just display results
  $mailbody .= "Msg_text\tTable\n";

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $mailbody .= "$row->{'Msg_text'}\t$row->{'Table'}\n";
  }

  $current_datetime = current_datetime();
  $mailbody .= "\ntable check finished at $current_datetime\n";

  $mailbody .= "-------------------------------------------------------------------\n\n\n";


  ###########################################################################################
  # send mail to admin
  if ($error_counter == 0) {
     $errors = 'no errors';
  }
  else {
     $errors = "$error_counter ERRORS! ";
  }

  # don't mail password: replace it by 'xxxxxx'
  $mailbody =~ s/$checkup_data{$backup}{'db_password'}/xxxxxx/g;

  %mail_to_admin = ( From    => $checkup_data{0}{'admin_mail'},
                     To      => $checkup_data{0}{'admins_mail'},
                     Subject => "$errors - QC check of $checkup_data{$backup}{'database'} at $checkup_data{0}{'host'}",
                     Message => $mailbody
                   );

  print $mailbody;

  if (sendmail(%mail_to_admin)) {
     print STDOUT "mail to $checkup_data{0}{'admins_mail'} sent successfully!\n\n";
  }
  else {
     print STDOUT "ERROR: could not send mail to $checkup_data{0}{'admins_mail'}!\n\n";
  }
  #-------------------------------------------------------

   # ClOSE CONNECTION TO DATABASE
   $dbh->disconnect();            # disconnect from database
}
# end of do_checkup()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
sub my_connect {
  # DATABASE CONNECTION PARAMETERS [@ localhost = (database runs on same machine as webserver) ]
  my $host_name   = $_[0];
  my $db_name     = $_[1];
  my $username    = $_[2];
  my $password    = $_[3];

  # OTHER VARIABLES
  my $dbh;                                                       # database handle (this is the return object)
  my $dsn  = "DBI:mysql:host=$host_name;database=$db_name";      # database connection string. Second parameter defines the DBMS: "mysql", "Pg", ...

  # ... now try to connect to the database
  $dbh = DBI->connect($dsn, $username, $password);

  # if above connect() fails -> display error message page and stop
  if (DBI->err()) {
     print "Could not connect to database " . $dbh-err() . "\n";
  }

  # else return db handler and continue
  else {
     return ($dbh, $host_name, $db_name);
  }
}
# my_connect()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#  current_datetime():                    returns current time as: "2005_04_26-1214"
sub current_datetime {
  my ($sec, $min, $hour, $day, $month, $yyyyear) = (localtime)[0,1,2,3,4,5];
  my $datetime;

  # create sql datetime format: 2005-04-26 00:00:00
  $month++;                                      # start with january = 1, not 0
  if ($month < 10) { $month = '0' . $month; }
  if ($day   < 10) { $day   = '0' . $day;   }
  if ($hour  < 10) { $hour  = '0' . $hour;  }
  if ($min   < 10) { $min   = '0' . $min;   }
  if ($sec   < 10) { $sec   = '0' . $sec;   }

  $datetime = ($yyyyear + 1900) . '_' . $month . '_' . $day . '-' . $hour . '' . $min . '' . $sec;

  return ($datetime);
}
# end of current_datetime()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_DB_001 do_multi_result_sql_query():                 generalized SQL query handler for queries with more than one result
sub do_multi_result_sql_query2 {

  my $dbh               = $_[0];           # get reference to global vars hash
  my $sql_statement     = $_[1];           # actual SQL statement
  my $sql_arguments_ref = $_[2];           # reference to SQL argument list
  my $error_code        = $_[3];           # error code
  my $sth;                                 # DBI statement handle
  my $result;                              # reference on the results (explained some lines below)
  my $rows;                                # number of results (lines)

  # prepare the SQL statement (or generate error page if that fails)
  $sth = $dbh->prepare($sql_statement) or die("Error");

  # execute the SQL query (or generate error page if that fails)
  $sth->execute(@{$sql_arguments_ref}) or die("Error");

  # read query results using the fetchall_arrayref() method
  $result = $sth->fetchall_arrayref({}) or die("Error");

  # finish the query (or generate error page if that fails)
  $sth->finish() or &die("Error");

  # how many result sets are returned?
  $rows = scalar @{$result};       # scalar is an operator that returns the number of elements of an array

  # return the reference on the results and the number of results
  return ($result, $rows);
}
# end of do_multi_result_sql_query()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_DB_002 do_single_result_sql_query():                generalized SQL query handler for simple queries with only one result (count only, limit 1, ...)
sub do_single_result_sql_query {
  my $dbh               = $_[0];               # get reference to global vars hash
  my $sql_statement     = $_[1];               # actual SQL statement
  my $sql_arguments_ref = $_[2];               # reference to SQL argument list
  my $error_code        = $_[3];               # error code
  my $sth;                                     # DBI statement handle
  my @results;                                 # result array

  # prepare the SQL statement (or generate error page if that fails)
  $sth = $dbh->prepare($sql_statement) or die("Error");

  # execute the SQL query (or generate error page if that fails)
  $sth->execute(@{$sql_arguments_ref}) or die("Error");

  # just get one line of results (hopefully it is the only one) and read it to an array
  @results = $sth->fetchrow_array();

  # finish the query (or generate error page if that fails)
  $sth->finish() or die("Error");

  # return array reference
  return (\@results);
}
# end of do_single_result_sql_query()
#------------------------------------------------------------------------------

