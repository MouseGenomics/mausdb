# lib_health.pl - a MausDB subroutine library file                                                                                    #
#                                                                                                                                     #
# Subroutines in this file provide functions associated with health or sanitary data                                                  #
#                                                                                                                                     #
#-------------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                                 #
#-------------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                     #
# SR_HEA001 store_rack_sanitary_data_1                      store rack sanitary data (step 1: form)                                   #
# SR_HEA002 store_rack_sanitary_data_2                      store rack sanitary data (step 2: store in database)                      #
# SR_HEA003 duplicate_report                                duplicate existing report to another rack                                 #
#                                                                                                                                     #
#######################################################################################################################################
#                                                                                                                                     #
# Copyright (C), 2008 Helmholtz Zentrum Muenchen, German Research Center for Environmental Health (GmbH)                              #
#                                                                                                                                     #
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as        #
# published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.                  #
#                                                                                                                                     #
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of      #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.                           #
#                                                                                                                                     #
# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software       #
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA                                                                #
#                                                                                                                                     #
# Holger Maier, January 2008 (email: holger.maier at helmholtz-muenchen.de)                                                           #
#                                                                                                                                     #
#######################################################################################################################################

use strict;

#--------------------------------------------------------------------------------------
# SR_HEA001 store_rack_sanitary_data_1                    store rack sanitary data (step 1: form)
sub store_rack_sanitary_data_1 {                          my $sr_name = 'SR_HEA001';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $location_id       = param('rack_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # check input: is rack id given? is it a number?
  if (!param('rack_id') || param('rack_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid rack id"));
     return $page;
  }

  # fetch some rack details
  $sql = qq(select location_id, location_rack, location_building, location_subbuilding, location_room, location_subrack
            from   locations
                   where  location_id = ?
           );

  @sql_parameters = ($location_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no rack info found: tell and quit
  unless ($rows > 0) {
     $page .= p("Rack not defined");
     return $page;
  }

  # else continue
  $row = $result->[0];

  $page = h2("Enter sanitary examination data for rack $row->{'location_rack'} in room " . $row->{'location_building'} . "-" . $row->{'location_subbuilding'}
               . "-" .  $row->{'location_room'}
               . (defined($row->{'location_subrack'})?' (' . $row->{'location_subrack'} . ')':'')
          )

          . hr()

          . start_form(-action => url())

          . hidden('rack_id')

          . table( {-border=>1, -summary=>"table"},
               Tr(
                 td(b("Date of health report")),
                 td(textfield(-name=>"health_report_datetime", -id=>"health_report_datetime", -size=>"20", -maxlength=>"21", -title=>"date of health report")
                    . "&nbsp;&nbsp;"
                    . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=health_report_datetime', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                 )
               ) .
               Tr(
                 td(b("Start of screening period") . br() . small('(examined mice entered the rack)')),
                 td(textfield(-name=>"screening_start", -id=>"screening_start", -size=>"20", -maxlength=>"21", -title=>"examined mice entered the rack")
                    . "&nbsp;&nbsp;"
                    . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=screening_start', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                 )
               ) .
               Tr(
                 td(b("End of screening period") . br() . small('(examined mice left the rack)')),
                 td(textfield(-name=>"screening_end", -id=>"screening_end", -size=>"20", -maxlength=>"21", -title=>"examined mice left the rack")
                    . "&nbsp;&nbsp;"
                    . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=screening_end', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                 )
               ) .
               Tr(
                 td(b("Number of mice examined") . br() . small('(number of examined mice)')),
                 td(radio_group(-name=>'mice_examined', -label=>'', -values=>['0'..'3'], -default=>'2'))
               ) .
               Tr(
                 th("Examination results"),
                 td(get_health_agents_checkbox_list($global_var_href))
               ) .
               Tr(
                 th("Examination results (other)"),
                 td(textarea(-name=>"examination_comment", -columns=>"80", -rows=>"5"))
               ) .
               Tr(
                 td(b("[Optional: examined mice]") . br() . small('(IDs of examined mice)')),
                 td(textfield(-name=>"healthreport_mice", -size=>"20", -maxlength=>"200", -title=>"IDs of examined mice"))
               )
             )

          . p()

          . submit(-name => "choice", -value=>"store sanitary data!")

          . end_form();

  return $page;
}
# end of store_rack_sanitary_data_1()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_HEA002 store_rack_sanitary_data_2                    store rack sanitary data (step 1: store in database)
sub store_rack_sanitary_data_2 {                          my $sr_name = 'SR_HEA002';
  my ($global_var_href)       = @_;                                      # get reference to global vars hash
  my $dbh                     = $global_var_href->{'dbh'};               # DBI database handle
  my $session                 = $global_var_href->{'session'};           # session handle
  my $user_id                 = $session->param('user_id');
  my $location_id             = param('rack_id');
  my $health_report           = param('health_report_datetime');
  my $screening_start         = param('screening_start');
  my $screening_end           = param('screening_end');
  my $mice_examined           = param('mice_examined');
  my $examination_comment     = param('examination_comment');
  my $healthreport_mice       = param('healthreport_mice');
  my $url                     = url();
  my $datetime_sql            = get_current_datetime_for_sql();
  my $health_report_sql       = format_display_datetime2sql_datetime($health_report);
  my $screening_start_sql     = format_display_datetime2sql_datetime($screening_start);
  my $screening_end_sql       = format_display_datetime2sql_datetime($screening_end);
  my ($page, $sql, $result, $rows, $row, $i, $j, $rc);
  my ($max_agent_id, $new_healthreport_id);
  my @sql_parameters;
  my %agent_positives;

  # check input: is rack id given? is it a number?
  if (!param('rack_id') || param('rack_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid rack id"));
     return $page;
  }

  if (!param('mice_examined') || param('mice_examined') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide number of examined mice"));
     return $page;
  }

  if (!param('health_report_datetime') || check_datetime_ddmmyyyy_hhmmss(param('health_report_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of health report not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('screening_start') || check_datetime_ddmmyyyy_hhmmss(param('screening_start')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of screening start not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('screening_end') || check_datetime_ddmmyyyy_hhmmss(param('screening_end')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of screening start not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # fetch some rack details
  $sql = qq(select location_id, location_rack, location_building, location_subbuilding, location_room, location_subrack
            from   locations
                   where  location_id = ?
           );

  @sql_parameters = ($location_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no rack info found: tell and quit
  unless ($rows > 0) {
     $page .= p("Rack not defined");
     return $page;
  }

  # else continue
  $row = $result->[0];

  $page = h2("Storing sanitary examination data for rack $row->{'location_rack'} in room " . $row->{'location_building'} . "-" . $row->{'location_subbuilding'}
               . "-" .  $row->{'location_room'}
               . (defined($row->{'location_subrack'})?' (' . $row->{'location_subrack'} . ')':'')
          );

  # get max number of agents
  $sql = qq(select max(agent_id)
            from   healthreport_agents
           );

  @sql_parameters = ();

  ($max_agent_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};


  # try to get a lock
  &get_semaphore_lock($global_var_href, $user_id);

  ############################################################################################
  # begin transaction
  $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start transaction)", $sr_name . "-" . __LINE__);

  # get a new health_report_id
  $sql = qq(select (max(healthreport_id)+1) as new_healthreport_id
            from   healthreports
         );

  @sql_parameters = ();

  ($new_healthreport_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (!defined($new_healthreport_id)) { $new_healthreport_id = 1; }

  # insert into healthreports
  $sql = qq(insert
            into   healthreports (healthreport_id, healthreport_document_URL, healthreport_date, healthreport_valid_from_date,
                                  healthreport_valid_to_date, healthreport_status, healthreport_comment, healthreport_number_of_mice,
                                  healthreport_mice)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?)
         );

         $dbh->do($sql, undef,
                  $new_healthreport_id,  '', $health_report_sql, $screening_start_sql, $screening_end_sql, '', $examination_comment,
                  $mice_examined, $healthreport_mice
               ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new health_report)", $sr_name . "-" . __LINE__);

  # insert into locations2healthreports
  $sql = qq(insert
            into   locations2healthreports (l2h_location_id, l2h_healthreport_id)
            values (?, ?)
         );

         $dbh->do($sql, undef,
                  $location_id, $new_healthreport_id
               ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new locations to health_report link)", $sr_name . "-" . __LINE__);

  # insert into healthreports2healthreport_agents
  $sql = qq(insert
            into   healthreports2healthreport_agents (hr2ha_health_report_id, hr2ha_healthreport_agent_id, hr2ha_number_of_positive_animals)
            values (?, ?, ?)
         );

  # now loop over all agent parameters ('agent_1' .. 'agent_max_agent_id') to identify those which are > 0
  for ($i=1; $i<=$max_agent_id; $i++) {
      if (defined(param('agent_' . $i)) && param('agent_' . $i) > 0) {

         # insert positives for current agent
         $dbh->do($sql, undef,
                  $new_healthreport_id, $i, param('agent_' . $i)
               ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new sanitary info)", $sr_name . "-" . __LINE__);
      }
  }

  # finally commit
  $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

  # end transaction
  ############################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $user_id);

  &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tadd_rack_sanitary_data\t$location_id\t" . $screening_start_sql . "\t" . $screening_end_sql);

  $page .= hr()
           . p('Sanitary examination data successfully stored!')
           . p("See " . a({-href=>"$url?choice=show_sanitary_status&rack_id=$location_id"}, 'updated data'));

  return $page;
}
# end of store_rack_sanitary_data_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_HEA003 duplicate_report                              duplicate existing report to another rack
sub duplicate_report {                                    my $sr_name = 'SR_HEA003';
  my ($global_var_href)       = @_;                                      # get reference to global vars hash
  my $dbh                     = $global_var_href->{'dbh'};               # DBI database handle
  my $session                 = $global_var_href->{'session'};           # session handle
  my $user_id                 = $session->param('user_id');
  my $location_id             = param('rack_id');
  my $health_report           = param('report_id');
  my $target_rack             = param('all_racks');
  my $url                     = url();
  my ($page, $sql, $result, $rows, $row, $i, $j, $rc);
  my @sql_parameters;
  my ($existing_rack_nr, $existing_room, $existing_building, $existing_subbuilding, $existing_subrack);
  my ($target_rack_nr, $target_room, $target_building, $target_subbuilding, $target_subrack);
  my $is_there;
  my $datetime_sql = get_current_datetime_for_sql();

  # check input: is rack id given? is it a number?
  if (!param('rack_id') || param('rack_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid rack id"));
     return $page;
  }

  # check input: is target rack id given? is it a number?
  if (!param('all_racks') || param('all_racks') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid rack id for the target rack"));
     return $page;
  }

  # check input: is report id given? is it a number?
  if (!param('report_id') || param('report_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid report id"));
     return $page;
  }

  #------------------------------------------
  # fetch some rack details for existing rack
  $sql = qq(select location_id, location_rack, location_building, location_subbuilding, location_room, location_subrack
            from   locations
                   where  location_id = ?
           );

  @sql_parameters = ($location_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no rack info found: tell and quit
  unless ($rows > 0) {
     $page .= p("Rack not defined");
     return $page;
  }

  # else continue
  $row = $result->[0];

  $existing_rack_nr     = $row->{'location_rack'};
  $existing_room        = $row->{'location_room'};
  $existing_building    = $row->{'location_building'};
  $existing_subbuilding = $row->{'location_subbuilding'};
  $existing_subrack     = (defined($row->{'location_subrack'})?' (' . $row->{'location_subrack'} . ')':'');

  #------------------------------------------
  # fetch some rack details for existing rack
  $sql = qq(select location_id, location_rack, location_building, location_subbuilding, location_room, location_subrack
            from   locations
                   where  location_id = ?
           );

  @sql_parameters = ($target_rack);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no rack info found: tell and quit
  unless ($rows > 0) {
     $page .= p("Target rack not defined $sql $target_rack");
     return $page;
  }

  # else continue
  $row = $result->[0];

  $target_rack_nr     = $row->{'location_rack'};
  $target_room        = $row->{'location_room'};
  $target_building    = $row->{'location_building'};
  $target_subbuilding = $row->{'location_subbuilding'};
  $target_subrack     = (defined($row->{'location_subrack'})?' (' . $row->{'location_subrack'} . ')':'');
  #------------------------------------------

  $page = h2("Duplicating sanitary examination report from rack $existing_rack_nr in room $existing_building-$existing_subbuilding-$existing_room $existing_subrack
              to rack $target_rack_nr in room $target_building-$target_subbuilding-$target_room $target_subrack"
          );

  # try to get a lock
  &get_semaphore_lock($global_var_href, $user_id);

  ############################################################################################
  # begin transaction
  $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start transaction)", $sr_name . "-" . __LINE__);

  # get a new health_report_id
  $sql = qq(select count(*) as is_there
            from   locations2healthreports
            where  l2h_location_id = ?
                   and l2h_healthreport_id = ?
         );

  @sql_parameters = ($target_rack, $health_report);

  ($is_there) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if ($is_there == 0) {

     # insert into locations2healthreports
     $sql = qq(insert
               into   locations2healthreports (l2h_location_id, l2h_healthreport_id)
               values (?, ?)
            );

     $dbh->do($sql, undef,
              $target_rack, $health_report
           ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new locations to health_report link)", $sr_name . "-" . __LINE__);
  }

  # finally commit
  $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

  # end transaction
  ############################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $user_id);

  &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tduplicate_health_report\t$health_report\t$location_id\t$target_rack");

  $page .= hr()
           . p('Duplication of health report successful!')
           . p("See " . a({-href=>"$url?choice=show_sanitary_status&rack_id=$target_rack"}, 'updated data for target rack'));

  return $page;
}
# end of duplicate_report()
#--------------------------------------------------------------------------------------



# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;