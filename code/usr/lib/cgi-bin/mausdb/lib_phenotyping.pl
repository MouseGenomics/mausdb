# lib_phenotyping.pl - a MausDB subroutine library file                                                                          #
#                                                                                                                                #
# Subroutines in this file provide functions related to phenotyping                                                              #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_PHE001 parameterset_view():                         parameterset view (show parameters that belong to a parameterset)       #
# SR_PHE002 orderlist_view():                            orderlist view                                                          #
# SR_PHE003 mouse_orderlists_view():                     orderlist view for a mouse                                              #
# SR_PHE004 show_mouse_phenotyping_record_overview():    show phenotyping records overview                                       #
# SR_PHE005 phenotyping_order_1                          order phenotyping (step 1: form)                                        #
# SR_PHE006 phenotyping_order_2                          order phenotyping (step 2: form)                                        #
# SR_PHE007 phenotyping_order_3                          order phenotyping (step 3: form)                                        #
# SR_PHE008 phenotyping_order_4                          order phenotyping (step 4: do the database transaction)                 #
# SR_PHE009 show_mouse_phenotyping_records               show phenotyping records from a specific parameterset for a mouse       #
# SR_PHE010 print_orderlist():                           print orderlist                                                         #
# SR_PHE011 view_phenotyping_data_1                      show phenotyping records for a selection of mice (1. step)              #
# SR_PHE012 view_phenotyping_data_2                      show phenotyping records for a selection of mice (2. step)              #
# SR_PHE013 show_phenotype_record_details                show phenotype record details                                           #
# SR_PHE014 enter_or_edit__mouse_phenotyping_records     enter or edit mouse phenotyping records                                 #
# SR_PHE015 parametersets_overview():                    parametersets overview                                                  #
# SR_PHE016 insert_global_metadata_1():                  insert_global_metadata (step 1: form)                                   #
# SR_PHE017 insert_global_metadata_2():                  insert_global_metadata (step 2: specific input form)                    #
# SR_PHE018 insert_global_metadata_3():                  insert_global_metadata (step 3: database transaction)                   #
# SR_PHE019 parameters_overview():                       parameters overview                                                     #
# SR_PHE020 parameter_view():                            parameter view                                                          #
# SR_PHE021 create_new_metadata_definition_1():          create new metadaata definition, step 1: input dialog                   #
# SR_PHE022 create_new_metadata_definition_2():          create new metadata definition,  step 2: database transaction           #
# SR_PHE023 parameterset_stats_view():                   parameterset stats view                                                 #
#                                                                                                                                #
##################################################################################################################################
#                                                                                                                                #
# Copyright (C), 2008 Helmholtz Zentrum Muenchen, German Research Center for Environmental Health (GmbH)                         #
#                                                                                                                                #
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as   #
# published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.             #
#                                                                                                                                #
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.                      #
#                                                                                                                                #
# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software  #
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA                                                           #
#                                                                                                                                #
# Holger Maier, January 2008 (email: holger.maier at helmholtz-muenchen.de)                                                      #
#                                                                                                                                #
##################################################################################################################################

use strict;

#--------------------------------------------------------------------------------------
# SR_PHE001 parameterset_view():                         parameterset view (show parameters that belong to a parameterset)
sub parameterset_view {                                  my $sr_name = 'SR_PHE001';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $session           = $global_var_href->{'session'}; # get session handle
  my $user_id           = $session->param('user_id');
  my $parameterset_id   = param('parameterset_id');
  my $parameterset_name = get_parameterset_name_by_id($global_var_href, $parameterset_id);
  my ($parameter_to_add, $parameter_name, $increment_value, $already_exists);
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my %parameter_type = ('b' => 'boolean', 'f' => 'float', 'i' => 'integer', 'l' => 'list', 'p' => 'picture', 'c' => 'text', 'd' => 'date', 't' => 'datetime');
  my @sql_parameters;
  my ($mouse_id_column, $measure_date_column);
  my $message             = '';
  my $datetime_sql        = get_current_datetime_for_sql();
  my @parameters_to_add = param('parameter_select');
  my @parameters        = param('parameters');
  my @increment_values;
  my %column_counter;
  my @multiple_columns;
  my ($update_column, $update_column_name, $parameter_id, $parameter, $current_column, $possible_values, $number_metadata);
  my %Excel_column_number2column_letter = ( '1' =>  'A',  '2' =>  'B',  '3' =>  'C',  '4' =>  'D',  '5' =>  'E',  '6' =>  'F',  '7' =>  'G',  '8' =>  'H',  '9' =>  'I', '10' =>  'J',
                                           '11' =>  'K', '12' =>  'L', '13' =>  'M', '14' =>  'N', '15' =>  'O', '16' =>  'P', '17' =>  'Q', '18' =>  'R', '19' =>  'S', '20' =>  'T',
                                           '21' =>  'U', '22' =>  'V', '23' =>  'W', '24' =>  'X', '25' =>  'Y', '26' =>  'Z', '27' => 'AA', '28' => 'AB', '29' => 'AC', '30' => 'AD',
                                           '31' => 'AE', '32' => 'AF', '33' => 'AG', '34' => 'AH', '35' => 'AI', '36' => 'AJ', '37' => 'AK', '38' => 'AL', '39' => 'AM', '40' => 'AN',
                                           '41' => 'AO', '42' => 'AP', '43' => 'AQ', '44' => 'AR', '45' => 'AS', '46' => 'AT', '47' => 'AU', '48' => 'AV', '49' => 'AW', '50' => 'AX',
                                           '51' => 'AY', '52' => 'AZ', '53' => 'BA', '54' => 'BB', '55' => 'BC', '56' => 'BD', '57' => 'BE', '58' => 'BF', '59' => 'BG', '60' => 'BH',
                                           '61' => 'BI', '62' => 'BK', '63' => 'BK', '64' => 'BL', '65' => 'BM', '66' => 'BN', '67' => 'BO', '68' => 'BP', '69' => 'BQ', '70' => 'BR',
                                           '71' => 'BS', '72' => 'BT', '73' => 'BU', '74' => 'BV', '75' => 'BW', '76' => 'BX', '77' => 'BY', '78' => 'BZ', '79' => 'CA', '80' => 'CB',
                                           '81' => 'CC', '82' => 'CD', '83' => 'CE', '84' => 'CF', '85' => 'CG', '86' => 'CH', '87' => 'CI', '88' => 'CJ', '89' => 'CK', '90' => 'CL',
                                           '91' => 'CM', '92' => 'CN', '93' => 'CO', '94' => 'CP', '95' => 'CQ', '96' => 'CR', '97' => 'CS', '98' => 'CT', '99' => 'CT','100' => 'CV',
                                          '101' => 'CW','102' => 'CX','103' => 'CY','104' => 'CZ','105' => 'DA','106' => 'DB','107' => 'DC','108' => 'DD','109' => 'DE','110' => 'DF',
                                          '111' => 'DG','112' => 'DH','113' => 'DI','114' => 'DJ','115' => 'DK','116' => 'DL','117' => 'DM','118' => 'DN','119' => 'DO','110' => 'DP',
                                          '121' => 'DQ','122' => 'DR','123' => 'DS','124' => 'DT','125' => 'DU','126' => 'DV','127' => 'DW','128' => 'DX','129' => 'DY','130' => 'DZ',
                                          '131' => 'EA','132' => 'EB','133' => 'EC','134' => 'ED','135' => 'EE','136' => 'EF','137' => 'EG','138' => 'EH','139' => 'EI','140' => 'EJ',
                                          '141' => 'EK','142' => 'EL','143' => 'EM','144' => 'EN','145' => 'EO','146' => 'EP','147' => 'EQ','148' => 'ER','149' => 'ES','150' => 'ET',
                                          '151' => 'EU','152' => 'EV','153' => 'EW','154' => 'EX','155' => 'EY','156' => 'EZ','157' => 'FA','158' => 'FB','159' => 'FC','160' => 'FD',
                                          '161' => 'FE','162' => 'FF','163' => 'FG','164' => 'FH','165' => 'FI','166' => 'FJ','167' => 'FK','168' => 'FL','169' => 'FM','170' => 'FN',
                                          '171' => 'FO','172' => 'FP','173' => 'FQ','174' => 'FR','175' => 'FS','176' => 'FT','177' => 'FU','178' => 'FV','179' => 'FW','180' => 'FX',
                                          '181' => 'FY','182' => 'FZ','183' => 'GA','184' => 'GB','185' => 'GC','186' => 'GD','187' => 'GE','188' => 'GF','189' => 'GG','190' => 'GH',
                                          '191' => 'GI','192' => 'GJ','193' => 'GK','194' => 'GL','195' => 'GM','196' => 'GN','197' => 'GO','198' => 'GP','199' => 'GQ','200' => 'GR');

  # check input: is parameterset_id given? is it a number?
  if (!param('parameterset_id') || param('parameterset_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid parameterset id"));
     return $page;
  }


  #####################################################################
  # update parameterset settings if requested
  if (param('choice') eq "update parameterset settings") {

     ########################################
     # 1. check input
     # if user does not have an admin role, reject
     if (current_user_is_admin($global_var_href) eq 'n') {
        $page = h2("Update settings for parameterset \"$parameterset_name\"")
                . hr()
                . h3("Sorry, you don't have admin rights. Please contact the administrator.");

        return ($page);
     }

     # check if parameterset given
     if (!defined(param('parameterset_id')) || param('parameterset_id') !~ /^[0-9]+$/) {
        $page = h2("Update settings for parameterset \"$parameterset_name\"")
                . hr()
                . p({-class=>"red"}, b("Error: parameterset not given or invalid! "))
                . p(a({-href=>"javascript:back()"}, "go back and try again"));

        return ($page);
     }

     # check if mouse_id_column given and valid
     if (!defined(param('mouse_id_column')) || param('mouse_id_column') !~ /^[0-9]+$/) {
        $page = h2("Update settings for parameterset \"$parameterset_name\"")
                . hr()
                . p({-class=>"red"}, b("Error: mouse ID column not given or invalid! "))
                . p(a({-href=>"javascript:back()"}, "go back and try again"));

        return ($page);
     }

     # check if measure_date_column given and valid
     if (!defined(param('measure_date_column')) || param('measure_date_column') !~ /^[0-9]+$/) {
        $page = h2("Update settings for parameterset \"$parameterset_name\"")
                . hr()
                . p({-class=>"red"}, b("Error: measure date/time column not given or invalid! "))
                . p(a({-href=>"javascript:back()"}, "go back and try again"));

        return ($page);
     }
     ########################################

     ########################################
     # 2. insert/update special columns (mouse id and measure date/time)
     # 2a) mouse id column
     #     check if there is an entry (-> update) or not (-> insert)

     &get_semaphore_lock($global_var_href, $user_id);       # try to get a lock

     ###################
     # begin transaction
     $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start adding parameter to set)", $sr_name . "-" . __LINE__);

     $sql = qq(select setting_value_int
               from   settings
               where  setting_category = ?
                      and setting_item = ?
                      and setting_key  = ?
            );

     @sql_parameters = ('upload_column', 'mouse_id', $parameterset_id);

     ($current_column) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

     # if not defined: insert
     if (!defined($current_column)) {
        $dbh->do("insert
                  into   settings (setting_id,        setting_category,   setting_item,       setting_key,         setting_value_type,
                                   setting_value_int, setting_value_text, setting_value_bool, setting_value_float, setting_description)
                  values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
              ", undef,
              undef, 'upload_column', 'mouse_id', $parameterset_id, 'integer', param('mouse_id_column'), undef, undef, undef, undef
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert mouse_id colum in settings)", $sr_name . "-" . __LINE__);
     }
     # else: update
     else {
        $dbh->do("update settings
                  set    setting_value_int = ?
                  where   setting_category = ?
                          and setting_item = ?
                          and setting_key  = ?
              ", undef,
              param('mouse_id_column'), 'upload_column', 'mouse_id', $parameterset_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update mouse_id colum in settings)", $sr_name . "-" . __LINE__);
     }

     $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);
     # end transaction
     #################

     &release_semaphore_lock($global_var_href, $user_id);     # release lock

     #####################
     #
     # 2b) measure date/time column
     #     check if there is an entry (-> update) or not (-> insert)

     &get_semaphore_lock($global_var_href, $user_id);       # try to get a lock

     ###################
     # begin transaction
     $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start adding parameter to set)", $sr_name . "-" . __LINE__);

     $sql = qq(select setting_value_int
               from   settings
               where  setting_category = ?
                      and setting_item = ?
                      and setting_key  = ?
            );

     @sql_parameters = ('upload_column', 'measure_date', $parameterset_id);

     ($current_column) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

     # if not defined: insert
     if (!defined($current_column)) {
        $dbh->do("insert
                  into   settings (setting_id,        setting_category,   setting_item,       setting_key,         setting_value_type,
                                   setting_value_int, setting_value_text, setting_value_bool, setting_value_float, setting_description)
                  values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
              ", undef,
              undef, 'upload_column', 'measure_date', $parameterset_id, 'integer', param('measure_date_column'), undef, undef, undef, undef
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert measure date/time colum in settings)", $sr_name . "-" . __LINE__);
     }
     # else: update
     else {
        $dbh->do("update settings
                  set    setting_value_int = ?
                  where   setting_category = ?
                          and setting_item = ?
                          and setting_key  = ?
              ", undef,
              param('measure_date_column'), 'upload_column', 'measure_date', $parameterset_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update measure date/time colum in settings)", $sr_name . "-" . __LINE__);
     }

     $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);
     # end transaction
     #################

     &release_semaphore_lock($global_var_href, $user_id);     # release lock

     ########################################
     # 3. update parameters

     # loop over all parameters to be updated
     foreach $parameter (@parameters) {
        # process input
        ($parameter_id, $increment_value) = split(/_/, $parameter);
        $update_column      = param('column_' . $parameter);
        $update_column_name = param('columnname_' . $parameter);

        # update is different for simple and series parameter (series: additional increment value)
        # series first ...
        if (defined($increment_value) && $increment_value ne 'simple') {
           $dbh->do("update  parametersets2parameters
                     set           p2p_upload_column = ?,
                              p2p_upload_column_name = ?
                     where       p2p_parameterset_id = ?
                             and    p2p_parameter_id = ?
                             and p2p_increment_value = ?
              ", undef, $update_column, $update_column_name, $parameterset_id, $parameter_id, $increment_value
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update parameter setting)", $sr_name . "-" . __LINE__);

           &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tupdate_parameter_setting\tparameterset_$parameterset_id\tparameter_id_$parameter_id\tincrement_$increment_value\tupload_colum_$update_column\tupload_colum_name_$update_column_name");
        }
        # simple ...
        else {
           $dbh->do("update  parametersets2parameters
                     set           p2p_upload_column = ?,
                              p2p_upload_column_name = ?
                     where       p2p_parameterset_id = ?
                             and    p2p_parameter_id = ?
              ", undef, $update_column, $update_column_name, $parameterset_id, $parameter_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update parameter setting)", $sr_name . "-" . __LINE__);

           &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tupdate_parameter_setting\tparameterset_$parameterset_id\tparameter_id_$parameter_id\tupload_colum_$update_column\tupload_colum_name_$update_column_name");
        }
     }

     # show transaction message
     $message .= p({-class=>'red'}, 'parameterset settings updated!')
                 . hr();
  }
  # end of update parameterset settings
  #####################################################################

  #####################################################################
  # remove parameters from parameterset if requested
  if (param('choice') eq "remove_parameter_from_set") {

     # if user does not have an admin role, reject
     if (current_user_is_admin($global_var_href) eq 'n') {
        $page = h2("Removing parameters from parameterset \"$parameterset_name\"")
                . hr()
                . h3("Sorry, you don't have admin rights. Please contact the administrator.");

        return ($page);
     }

     # check if parameterset given
     if (!defined(param('parameterset_id')) || param('parameterset_id') !~ /^[0-9]+$/) {
        $page = h2("Removing parameters from parameterset \"$parameterset_name\"")
                . hr()
                . p({-class=>"red"}, b("Error: parameterset not given or invalid! "))
                . p(a({-href=>"javascript:back()"}, "go back and try again"));

        return ($page);
     }

     # check if parameter given
     if (!defined(param('parameter_id')) || param('parameter_id') !~ /^[0-9]+$/) {
        $page = h2("Removing parameters from parameterset \"$parameterset_name\"")
                . hr()
                . p({-class=>"red"}, b("Error: parameter not given or invalid! "))
                . p(a({-href=>"javascript:back()"}, "go back and try again"));

        return ($page);
     }

     # everything checked, now delete ...
     $dbh->do("delete
               from   parametersets2parameters
               where   p2p_parameterset_id = ?
                      and p2p_parameter_id = ?
              ", undef, $parameterset_id, param('parameter_id')) or &error_message_and_exit($global_var_href, "SQL error (could not remove parameter from set)", $sr_name . "-" . __LINE__);

     # show transaction message
     $message .= p({-class=>'red'}, 'parameters deleted from parameterset!')
                 . hr();
  }
  # end of remove parameters from parameterset
  #####################################################################

  #####################################################################
  # remove metadata definition from parameterset if requested
  if (param('choice') eq "remove_mdd_from_set") {

     # if user does not have an admin role, reject
     if (current_user_is_admin($global_var_href) eq 'n') {
        $page = h2("Removing metadata definition from parameterset \"$parameterset_name\"")
                . hr()
                . h3("Sorry, you don't have admin rights. Please contact the administrator.");

        return ($page);
     }

     # check if parameterset given
     if (!defined(param('parameterset_id')) || param('parameterset_id') !~ /^[0-9]+$/) {
        $page = h2("Removing metadata definition from parameterset \"$parameterset_name\"")
                . hr()
                . p({-class=>"red"}, b("Error: parameterset not given or invalid! "))
                . p(a({-href=>"javascript:back()"}, "go back and try again"));

        return ($page);
     }

     # check if mdd id given
     if (!defined(param('mdd_id')) || param('mdd_id') !~ /^[0-9]+$/) {
        $page = h2("Removing metadata definition from parameterset \"$parameterset_name\"")
                . hr()
                . p({-class=>"red"}, b("Error: metadata definition id not given or invalid! "))
                . p(a({-href=>"javascript:back()"}, "go back and try again"));

        return ($page);
     }

     ########################################
     # delete metadata definition if there are no linked entries in table metadata

     &get_semaphore_lock($global_var_href, $user_id);       # try to get a lock

     ###################
     # begin transaction
     $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start delete metadata definition transaction)", $sr_name . "-" . __LINE__);

     # get number of metadata for this metadata definition
     $sql = qq(select count(metadata_id) as number_metadata
               from   metadata
               where  metadata_mdd_id  = ?
            );

     @sql_parameters = (param('mdd_id'));

     ($number_metadata) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

     # rollback there are linked entries in table metadata
     if ($number_metadata > 0) {

        $rc = $dbh->rollback() or &error_message_and_exit($global_var_href,"SQL error (could not roll back delete metadata definition transaction)", $sr_name . "-" . __LINE__);
        &release_semaphore_lock($global_var_href, $user_id);
        $page .= h2("Delete metadata definition ")
                 . hr()
                 . p({-class=>"red"}, b("Error: metadata definition not deleted (metadata entries for this metadata definition exists)! "));

        return $page;
     }

     # delete ...
     $dbh->do("delete
               from   metadata_definitions
               where   mdd_parameterset_id = ?
                      and           mdd_id = ?
              ", undef, $parameterset_id, param('mdd_id')) or &error_message_and_exit($global_var_href, "SQL error (could not remove metadata definition from set)", $sr_name . "-" . __LINE__);

     $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);
     # end transaction
     #################

     &release_semaphore_lock($global_var_href, $user_id);     # release lock

     # show transaction message
     $message .= p({-class=>'red'}, 'metadata definiton deleted from parameterset!')
                 . hr();
  }
  # remove metadata definition from parameterset
  #####################################################################

  #####################################################################
  # add parameters to parameterset if requested
  if (param('choice') eq "add parameters to parameterset!") {


     # if user does not have an admin role, reject
     if (current_user_is_admin($global_var_href) eq 'n') {
        $page = h2("Add parameters to parameterset \"$parameterset_name\"")
                . hr()
                . h3("Sorry, you don't have admin rights. Please contact the administrator.");

        return ($page);
     }

     # check if at least one parameter to add
     if (scalar @parameters_to_add == 0) {
        $page = h2("Add parameters to parameterset \"$parameterset_name\"")
                . hr()
                . p({-class=>"red"}, b("Please select at least one parameter to add to parameterset! "))
                . p(a({-href=>"javascript:back()"}, "go back and try again"));

        return ($page);
     }

     # loop over all parameters to be added to the parameterset
     foreach $parameter_to_add (@parameters_to_add) {

        $parameter_name = get_parameter_name_by_id($global_var_href, $parameter_to_add);

        # check if Excel column for current parameter is given and valid
        if (!defined(param('Excel_column_' . $parameter_to_add)) || param('Excel_column_' . $parameter_to_add) !~ /^[0-9]+$/) {
           $page = h2("Add parameters to parameterset \"$parameterset_name\"")
                   . hr()
                   . p({-class=>"red"}, b("Error: Excel upload column for parameter \"$parameter_name\" not given or not valid!"))
                   . p(a({-href=>"javascript:back()"}, "go back and try again"));

           return ($page);
        }

        # check if Excel column name for current parameter is given
        if (!defined(param('Excel_column_name_' . $parameter_to_add)) || param('Excel_column_name_' . $parameter_to_add) eq '') {
           $page = h2("Add parameters to parameterset \"$parameterset_name\"")
                   . hr()
                   . p({-class=>"red"}, b("Error: Excel upload column name for parameter \"$parameter_name\" not given or not valid!"))
                   . p(a({-href=>"javascript:back()"}, "go back and try again"));

           return ($page);
        }

        # check if parameter_type for current parameter is given
        if (!defined(param('parameter_type_' . $parameter_to_add)) || param('parameter_type_' . $parameter_to_add) !~ /[simple|series]/) {
           $page = h2("Add parameters to parameterset \"$parameterset_name\"")
                   . hr()
                   . p({-class=>"red"}, b("Error: parameter type for parameter \"$parameter_name\" not given or not valid! Must be either \"simple\" or \"series\""))
                   . p(a({-href=>"javascript:back()"}, "go back and try again"));

           return ($page);
        }

        # in case of "series" parameter: check if increment value and increment unit are given
        if (param('parameter_type_' . $parameter_to_add) eq "series") {

           # increment values: we expect a list of increment values separated by semicolon
           if (!defined(param('increment_value_' . $parameter_to_add)) || param('increment_value_' . $parameter_to_add) eq '' || param('increment_value_' . $parameter_to_add) !~ /;/) {
              $page = h2("Add parameters to parameterset \"$parameterset_name\"")
                      . hr()
                      . p({-class=>"red"}, b("Error: increment values for parameter \"$parameter_name\" not given or not valid (at least two increment values separated by semicolon)!"))
                      . p(a({-href=>"javascript:back()"}, "go back and try again"));

              return ($page);
           }

           # increment unit
           if (!defined(param('increment_unit_' . $parameter_to_add)) || param('increment_unit_' . $parameter_to_add) eq '') {
              $page = h2("Add parameters to parameterset \"$parameterset_name\"")
                      . hr()
                      . p({-class=>"red"}, b("Error: increment unit for parameter \"$parameter_name\" not given!"))
                      . p(a({-href=>"javascript:back()"}, "go back and try again"));

              return ($page);
           }
        }

		#check,if required is given
		if (!defined(param('parameter_required_' . $parameter_to_add)) || param('parameter_required_' . $parameter_to_add) eq '') {
			$page = h2("Add parameters to parameterset \"$parameterset_name\"")
                      . hr()
                      . p({-class=>"red"}, b("Error: required field for parameter \"$parameter_name\" not given!"))
                      . p(a({-href=>"javascript:back()"}, "go back and try again"));

              return ($page);
		}

        # all checks passed for this parameter...
     }

     # checks for every parameter passed, so now start insert transaction
     # ##################################################################

     # try to get a lock
     &get_semaphore_lock($global_var_href, $user_id);

     ############################################################################################
     # begin transaction
     $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start adding parameter to set)", $sr_name . "-" . __LINE__);

     # loop again over all parameters to be added to the parameterset
     foreach $parameter_to_add (@parameters_to_add) {

       # first check if parameter already is part of this parameterset
       $sql = qq(select count(p2p_parameterset_id) as existing
                 from   parametersets2parameters
                 where   p2p_parameterset_id = ?
                        and p2p_parameter_id = ?
              );

       @sql_parameters = ($parameterset_id, $parameter_to_add);

       ($already_exists) =  @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

       if ($already_exists > 0) {
          $rc = $dbh->rollback() or &error_message_and_exit($global_var_href,"SQL error (could not roll back add parameter to set transaction)", $sr_name . "-" . __LINE__);
          &release_semaphore_lock($global_var_href, $user_id);
          $page .= h2("Add parameters to parameterset \"$parameterset_name\"")
                   . hr()
                   . p({-class=>"red"}, b("Error: parameter \"$parameter_name\" already is part of parameterset \"$parameterset_name\"!"))
                   . p(a({-href=>"javascript:back()"}, "go back and try again"));
          return $page;
       }

       # first do simple parameters
       if (param('parameter_type_' . $parameter_to_add) eq 'simple') {

           $dbh->do("insert
                     into   parametersets2parameters (p2p_parameterset_id,    p2p_parameter_id,       p2p_display_row,     p2p_display_column, p2p_upload_column,
                                                      p2p_upload_column_name, p2p_parameter_category, p2p_increment_value, p2p_increment_unit,
                                                      p2p_parameter_required)
                     values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                     , undef, $parameterset_id, $parameter_to_add, undef, undef, param('Excel_column_' . $parameter_to_add),
                              param('Excel_column_name_' . $parameter_to_add), param('parameter_type_' . $parameter_to_add),
                              param('increment_value_'   . $parameter_to_add), param('increment_unit_' . $parameter_to_add),
                              param('parameter_required_' . $parameter_to_add)
                 ) or &error_message_and_exit($global_var_href, "SQL error (could not add parameter to set)", $sr_name . "-" . __LINE__);
       }
       elsif (param('parameter_type_' . $parameter_to_add) eq 'series') {

           # first split increment value field into individual increment values
           @increment_values = split(/;/, param('increment_value_'   . $parameter_to_add));

           # loop over increment values
           foreach $increment_value (@increment_values) {
              $dbh->do("insert
                        into   parametersets2parameters (p2p_parameterset_id,    p2p_parameter_id,       p2p_display_row,     p2p_display_column, p2p_upload_column,
                                                         p2p_upload_column_name, p2p_parameter_category, p2p_increment_value, p2p_increment_unit,
                                                         p2p_parameter_required)
                        values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                        , undef, $parameterset_id, $parameter_to_add, undef, undef, param('Excel_column_' . $parameter_to_add),
                                 param('Excel_column_name_' . $parameter_to_add), param('parameter_type_' . $parameter_to_add),
                                 $increment_value, param('increment_unit_' . $parameter_to_add),
                                 param('parameter_required_' . $parameter_to_add)
                    ) or &error_message_and_exit($global_var_href, "SQL error (could not add parameter to set)", $sr_name . "-" . __LINE__);
           }
       }

        #&write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\t$datetime_sql");
     }

     $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

     # end transaction
     ############################################################################################

     # release lock
     &release_semaphore_lock($global_var_href, $user_id);

     # show transaction message
     $message .=   p({-class=>'red'}, 'parameters added to parameterset! Please check if everything is correct!')
                 . p({-class=>'red'}, 'FOR SERIES PARAMETERS: PLEASE ENTER/UPDATE COLUM AND COLUMN NAME FOR EVERY INCREMENT NOW!')
                 . hr();
  }
  # end of add parameters to parameterset
  #####################################################################

  # read configuration for upload columns
  $mouse_id_column     = get_column_in_upload_file($global_var_href, 'mouse_id',     $parameterset_id);
  $measure_date_column = get_column_in_upload_file($global_var_href, 'measure_date', $parameterset_id);

  # register columns
  $column_counter{$mouse_id_column}++;
  $column_counter{$measure_date_column}++;

  $page = h2(qq(Parameterset overview: "$parameterset_name"   )
             . a({-href=>"$url?choice=parameterset_view&parameterset_id=$parameterset_id", -title=>'reload page'},
                    img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
               )
             . "&nbsp; ["
             . a({-href=>"$url?choice=parameterset_stats&parameterset_id=$parameterset_id"}, "overall min, mean, max")
             . "]"
          )
          . hr()

          . start_form(-action => url());

  #################################
  # 1) display upload configuration
  $page .= h3("1) Excel upload configuration")

          . table( {-border=>1},
               Tr( th('mouse ID column'),
                   td((defined($mouse_id_column)
                       ?"(you may update this column)"
                       :span({-class=>"red"}, "Warning: mouse ID column not defined!")
                      )
                   ),
                   td({-align=>"right"},
                      popup_menu(-name   => "mouse_id_column",
                               -values => [ '1',  '2',  '3',  '4',  '5',  '6',  '7',  '8',  '9', '10',
                                           '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',
                                           '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',
                                           '31', '32', '33', '34', '35', '36', '37', '38', '39', '40',
                                           '41', '42', '43', '44', '45', '46', '47', '48', '49', '50',
                                           '51', '52', '53', '54', '55', '56', '57', '58', '59', '60',
                                           '61', '62', '63', '64', '65', '66', '67', '68', '69', '70',
                                           '71', '72', '73', '74', '75', '76', '77', '78', '79', '80',
                                           '81', '82', '83', '84', '85', '86', '87', '88', '89', '90',
                                           '91', '92', '93', '94', '95', '96', '97', '98', '99','100',
                                          '101','102','103','104','105','106','107','108','109','110',
                                          '111','112','113','114','115','116','117','118','119','120',
                                          '121','122','123','124','125','126','127','128','129','130',
                                          '131','132','133','134','135','136','137','138','139','140',
                                          '141','142','143','144','145','146','147','148','149','150',
                                          '151','152','153','154','155','156','157','158','159','160',
                                          '161','162','163','164','165','166','167','168','169','170',
                                          '171','172','173','174','175','176','177','178','179','180',
                                          '181','182','183','184','185','186','187','188','189','190',
                                          '191','192','193','194','195','196','197','198','199','200'],
                               -default=> (defined($mouse_id_column)?$mouse_id_column:'-'),
                               -labels => \%Excel_column_number2column_letter
                      )
                   )
               ) .
               Tr( th('date(time) column'),
                   td((defined($mouse_id_column)
                       ?"(you may update this column)"
                       :span({-class=>"red"}, "Warning: measure date/time column not defined!")
                      )
                   ),
                   td({-align=>"right"},
                      popup_menu(-name   => "measure_date_column",
                               -values => [ '1',  '2',  '3',  '4',  '5',  '6',  '7',  '8',  '9', '10',
                                           '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',
                                           '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',
                                           '31', '32', '33', '34', '35', '36', '37', '38', '39', '40',
                                           '41', '42', '43', '44', '45', '46', '47', '48', '49', '50',
                                           '51', '52', '53', '54', '55', '56', '57', '58', '59', '60',
                                           '61', '62', '63', '64', '65', '66', '67', '68', '69', '70',
                                           '71', '72', '73', '74', '75', '76', '77', '78', '79', '80',
                                           '81', '82', '83', '84', '85', '86', '87', '88', '89', '90',
                                           '91', '92', '93', '94', '95', '96', '97', '98', '99','100',
                                          '101','102','103','104','105','106','107','108','109','110',
                                          '111','112','113','114','115','116','117','118','119','120',
                                          '121','122','123','124','125','126','127','128','129','130',
                                          '131','132','133','134','135','136','137','138','139','140',
                                          '141','142','143','144','145','146','147','148','149','150',
                                          '151','152','153','154','155','156','157','158','159','160',
                                          '161','162','163','164','165','166','167','168','169','170',
                                          '171','172','173','174','175','176','177','178','179','180',
                                          '181','182','183','184','185','186','187','188','189','190',
                                          '191','192','193','194','195','196','197','198','199','200'],
                               -default=> (defined($measure_date_column)?$measure_date_column:'-'),
                               -labels => \%Excel_column_number2column_letter
                      )
                   )
               )
            );

  $page .= hr({-width=>"50%", -align=>"left"});

  ######################################################
  # 2) display metadata definitions for this parameterset
  $sql = qq(select mdd_id, mdd_name, mdd_shortname, mdd_type, mdd_decimals, mdd_unit, mdd_default, mdd_possible_values,
                   mdd_global_yn, mdd_active_yn, mdd_required, mdd_parameterset_id, mdd_parameter_id, mdd_description
            from   metadata_definitions
            where  mdd_parameterset_id = ?
           );

  @sql_parameters = ($parameterset_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no metadata definitions found at all: tell and quit
  if ($rows == 0) {
     $page .= h3("2) Metadata definitions parameter set " . qq("$parameterset_name"))
              . p("No metadata definitions found for this parameter set");
  }
  else {
     # else continue: display metadata definitions table
     $page .= h3("2) Metadata definitions for parameter set " . qq("$parameterset_name"))
              . start_table( {-border=>"1", -summary=>"metadata_definitions"})
              . Tr({-align=>'center', -bgcolor=>"lightblue"},
                  th("remove"),
                  th("name"),
                  th("shortname"),
                  th("type"),
                  th("unit"),
                  th("required"),
                  th("default"),
                  th("possible values"),
                  th("description")

                );

     # ... loop over all metadata definitions
     for ($i=0; $i<$rows; $i++) {               # $rows is the number of racks returned from the above query
         $row = $result->[$i];                  # get a reference on the current result row

         # split possible values list, enter line breaks
         $possible_values = $row->{'mdd_possible_values'};
         $possible_values =~ s/;/<br>/g;

         $page .= Tr({-align=>'center'},
                    #td(a({-href=>"$url?choice=remove_mdd_from_set&parameterset_id=$parameterset_id&mdd_id=$row->{'mdd_id'}", -title=>"click to remove metadata definition from this parameterset"}, "remove")),
                    td({-title=>"inactivated"}, "remove"),
                    td($row->{'mdd_name'}),
                    td($row->{'mdd_shortname'}),
                    td($parameter_type{$row->{'mdd_type'}}),
                    td($row->{'mdd_unit'}),
                    td($row->{'mdd_required'}),
                    td($row->{'mdd_default'}),
                    td($possible_values),
                    td($row->{'mdd_description'})
                  );
     }

     $page .= end_table();
  }

  $page .= p()
           . submit(-name => 'choice', -value => 'add metadata definition')
           . hr({-width=>"50%", -align=>"left"});

  ############################
  # 3) display parameter settings
  $sql = qq(select parameter_id, parameter_name, parameter_shortname, parameter_description, parameter_unit, parameter_is_metadata,
                   parameter_type, parameter_default, parameter_normal_range, p2p_upload_column, p2p_upload_column_name,
                   p2p_parameter_category, p2p_increment_value, p2p_increment_unit, p2p_parameter_required
            from   parametersets2parameters
                   join parameters on p2p_parameter_id = parameter_id
            where  p2p_parameterset_id = ?
            order  by p2p_upload_column asc, parameter_name asc
           );

  @sql_parameters = ($parameterset_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no imports found at all: tell and quit
  if ($rows == 0) {
     $page .= h3("3) Parameters belonging to parameter set " . qq("$parameterset_name"))
              . p("No parameters in this parameter set")

              . hr({-width=>"50%", -align=>"left"});
  }
  else {
     # else continue: display parameters table
     $page .= h3("3) Parameters belonging to parameter set " . qq("$parameterset_name"))
              . $message
              . start_table( {-border=>"1", -summary=>"experiment_overview"})
              . Tr( {-align=>'center', -bgcolor=>"lightblue"},
                  th({-rowspan=>"2"}, "remove"),
                  th({-rowspan=>"2"}, "name"),
                  th({-rowspan=>"2"}, "short name"),
                  th({-rowspan=>"2"}, "description"),
                  th({-rowspan=>"2"}, "unit"),
                  th({-rowspan=>"2"}, "metadata?"),
                  th({-rowspan=>"2"}, "type"),
                  th({-rowspan=>"2"}, "category"),
                  th({-rowspan=>"2"}, "default value"),
                  th({-rowspan=>"2"}, "normal range"),
                  th({-rowspan=>"2"}, "increment"),
                  th({-rowspan=>"2"}, "increment unit"),
                  th({-rowspan=>"2"}, "required"),
                  th({-colspan=>"2"}, "Excel upload")
                )
              . Tr({-align=>'center', -bgcolor=>"lightblue"},
                  th("Excel column"),
                  th("Excel column name")
                );

     # ... loop over all parameters
     for ($i=0; $i<$rows; $i++) {               # $rows is the number of racks returned from the above query
         $row = $result->[$i];                  # get a reference on the current result row

         $page .= Tr({-align=>'center'},
                    #td(a({-href=>"$url?choice=remove_parameter_from_set&parameterset_id=$parameterset_id&parameter_id=$row->{'parameter_id'}", -title=>"click to remove parameter from this parameterset"}, "remove")),
                    td({-title=>"inactivated"}, "remove"),
                    td(defined($row->{'parameter_name'})?b(a({-href=>"$url?choice=parameter_view&parameter_id=$row->{'parameter_id'}"}, $row->{'parameter_name'})):'-'),
                    td(defined($row->{'parameter_shortname'})?$row->{'parameter_shortname'}:'-'),
                    td(defined($row->{'parameter_description'})?$row->{'parameter_description'}:'-'),
                    td(defined($row->{'parameter_unit'})?$row->{'parameter_unit'}:'-'),
                    td(defined($row->{'parameter_is_metadata'})?$row->{'parameter_is_metadata'}:'-'),
                    td(defined($row->{'parameter_type'})?$parameter_type{$row->{'parameter_type'}}:'-'),
                    td($row->{'p2p_parameter_category'}),
                    td(defined($row->{'parameter_default'})?$row->{'parameter_default'}:'-'),
                    td(defined($row->{'parameter_normal_range'})?$row->{'parameter_normal_range'}:'-'),
                    td(defined($row->{'p2p_increment_value'})?$row->{'p2p_increment_value'}:'-'),
                    td(defined($row->{'p2p_increment_unit'})?$row->{'p2p_increment_unit'}:'-'),
                    td($row->{'p2p_parameter_required'}),
                    td(popup_menu(-name   => "column_$row->{'parameter_id'}_$row->{'p2p_increment_value'}",
                                  -values => [ '1',  '2',  '3',  '4',  '5',  '6',  '7',  '8',  '9', '10',
                                              '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',
                                              '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',
                                              '31', '32', '33', '34', '35', '36', '37', '38', '39', '40',
                                              '41', '42', '43', '44', '45', '46', '47', '48', '49', '50',
                                              '51', '52', '53', '54', '55', '56', '57', '58', '59', '60',
                                              '61', '62', '63', '64', '65', '66', '67', '68', '69', '70',
                                              '71', '72', '73', '74', '75', '76', '77', '78', '79', '80',
                                              '81', '82', '83', '84', '85', '86', '87', '88', '89', '90',
                                              '91', '92', '93', '94', '95', '96', '97', '98', '99','100',
                                             '101','102','103','104','105','106','107','108','109','110',
                                             '111','112','113','114','115','116','117','118','119','120',
                                             '121','122','123','124','125','126','127','128','129','130',
                                             '131','132','133','134','135','136','137','138','139','140',
                                             '141','142','143','144','145','146','147','148','149','150',
                                             '151','152','153','154','155','156','157','158','159','160',
                                             '161','162','163','164','165','166','167','168','169','170',
                                             '171','172','173','174','175','176','177','178','179','180',
                                             '181','182','183','184','185','186','187','188','189','190',
                                             '191','192','193','194','195','196','197','198','199','200'],
                                  -default=> (defined($row->{'p2p_upload_column'})?$row->{'p2p_upload_column'}:'-'),
                                  -labels => \%Excel_column_number2column_letter
                       )
                    ),
                    td(textfield(-name=>"columnname_$row->{'parameter_id'}_$row->{'p2p_increment_value'}", -size=>"15", -maxlength => '100',
                                 -value=>(defined($row->{'p2p_upload_column_name'}))?$row->{'p2p_upload_column_name'}:'-'
                       )
                       . hidden(-name=>'parameters', -value=>"$row->{'parameter_id'}_$row->{'p2p_increment_value'}", -override=>1)
                    )
                  );

         # add column to hash to detect multiple use of that column
         $column_counter{$row->{'p2p_upload_column'}}++;
     }

     $page .= end_table();

     # loop over column hash and find out if columns are used more than once
     foreach (keys %column_counter) {
        if ($column_counter{$_} > 1) {
           push(@multiple_columns, $Excel_column_number2column_letter{$_});
        }
     }

     # if multiple used columns found, display warning
     if (scalar @multiple_columns > 0) {
        $page .= p({-class=>"red"}, " Warning: the following columns are used more than once: " . join(', ', sort @multiple_columns));
     }
  }

  $page .= hidden('parameterset_id')
           . p()
           . submit(-name => 'choice', -value => 'update parameterset settings') . '&nbsp;&nbsp;' . CGI->reset(-name=>'reset form')
           . end_form();

  return $page;
}
# end of parameterset_view()
#------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE002 orderlist_view():                         orderlist view
sub orderlist_view {                                  my $sr_name = 'SR_PHE002';
  my ($global_var_href)  = @_;                            # get reference to global vars hash
  my $url                = url();
  my $orderlist_id       = param('orderlist_id');
  my $orderlist_comment  = param('orderlist_comment');
  my $orderlist_new_name = param('orderlist_new_name');
  my $sort_column        = param('sort_by');
  my $sort_order         = param('sort_order');
  my $mouse_ids          = param('mouse_ids');
  my $dbh                = $global_var_href->{'dbh'};                # DBI database handle
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my ($current_mating, $short_comment, $orderlist_position, $check_mouse_to_add, $potential_id, $is_dead, $is_on_list, $m2o_mouse_id, $mouse_to_add);
  my $sex_color   = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my $datetime_sql = get_current_datetime_for_sql();
  my @selected_mice;
  my ($mouse_id, $parameter, $orderlist_comment_sql, $parameterset, $metadata_value, $print_value, $metadata_parameter, $metadata_name);
  my ($new_metadata_id, $mdd_id, $metadata_is_stored, $the_metadata_value, $orderlist_new_name_sql);
  my @parameters  = param();                                # read all CGI parameter keys
  my $top_message = '';
  my $message = '';
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;
  my $session           = $global_var_href->{'session'};            # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $username          = $session->param('username');
  my $epoch_week        = get_current_epoch_week($global_var_href);
  my $rev_order         = {'asc' => 'desc', 'desc' => 'asc'};     # toggle table
  # hide real database column names from user (security issue): use translation hash table
  # left (key): identifier used in HTML form; right (value): database column name
  my $columns  = {'id' => 'mouse_id', 'cage' => 'cage_id', 'rack' => 'concat(location_room,location_rack)'};
  my @possible_values;
  my @metadata_parameters;
  my @id_list;
  my @mice_to_add;


  # check input: is orderlist id given? is it a number?
  if (!param('orderlist_id') || param('orderlist_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid orderlist id"));
     return $page;
  }

  # make sure a sort column is defined
  if (!param('sort_by')) {
     $sort_column = 'cage';
  }
  # raise error if invalid sort column given
  elsif (!defined($columns->{$sort_column})) {
     $page = p({-class=>"red"}, b("Error: invalid sort column $sort_column"));
     return $page;
  }

  # if sort order is given and 'desc': set it to 'desc'
  if (param('sort_order') && param('sort_order') eq 'desc') {
     $sort_order = 'desc';
  }
  # else default to 'asc'
  else {
     $sort_order = 'asc';
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href);
  }

  ####################################################################################################################################
  # update comment if requested
  if (defined(param('job')) && param('job') eq "update comment") {

     $orderlist_comment_sql = $orderlist_comment;
     $orderlist_comment_sql =~ s/'|;|-{2}//g;                  # remove dangerous content

     # update orderlist comment
     $dbh->do("update  orderlists
               set     orderlist_comment = ?
               where   orderlist_id = ?
              ", undef, $orderlist_comment_sql, $orderlist_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update orderlist comment)", $sr_name . "-" . __LINE__);

     &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tupdate_orderlist_comment\t$orderlist_id\tnew:$orderlist_comment_sql");

     $top_message = p({-class=>"red"}, "Orderlist comment updated!");
  }
  ####################################################################################################################################

  ####################################################################################################################################
  # update orderlist_name if requested
  if (defined(param('job')) && param('job') eq "update orderlist name") {

     $orderlist_new_name_sql = $orderlist_new_name;
     $orderlist_new_name_sql =~ s/'|;|-{2}//g;                  # remove dangerous content

     # update orderlist name
     $dbh->do("update  orderlists
               set     orderlist_name = ?
               where   orderlist_id   = ?
              ", undef, $orderlist_new_name_sql, $orderlist_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update orderlist name)", $sr_name . "-" . __LINE__);

     &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tupdate_orderlist_name\t$orderlist_id\tnew:$orderlist_new_name_sql");

     $top_message = p({-class=>"red"}, "Orderlist name updated!");
  }
  ####################################################################################################################################

  ####################################################################################################################################
  # set orderlist on 'done' if requested
  if (defined(param('job')) && param('job') eq "set on done") {

	 #check if metadata is valid
	 
	 my $set_done =  check_orderlist_data($global_var_href, $orderlist_id, param('parameterset'));                   
     
     if ($set_done eq '1') {
     	 # update orderlist status
	     $dbh->do("update  orderlists
	               set     orderlist_status = ?
	               where   orderlist_id = ?
	              ", undef, 'done', $orderlist_id
	             ) or &error_message_and_exit($global_var_href, "SQL error (could not update orderlist status)", $sr_name . "-" . __LINE__);
	
	     &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tupdate_orderlist_status\t$orderlist_id\tset_on:done");
	
	     $top_message = p({-class=>"red"}, "Orderlist set on done!");
     }
     else {
     	$top_message = p({-class=>"red"}, $set_done);
     }
     
  }
  ####################################################################################################################################

  ####################################################################################################################################
  # set orderlist on 'ordered' if requested
  if (defined(param('job')) && param('job') eq "set on ordered") {

     # update orderlist status
     $dbh->do("update  orderlists
               set     orderlist_status = ?
               where   orderlist_id = ?
              ", undef, 'ordered', $orderlist_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update orderlist status)", $sr_name . "-" . __LINE__);

     &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tupdate_orderlist_status\t$orderlist_id\tset_on:ordered");

     $top_message = p({-class=>"red"}, "Orderlist set on ordered!");
  }
  ####################################################################################################################################

  ####################################################################################################################################
  # set orderlist on 'cancelled' if requested
  if (defined(param('job')) && param('job') eq "set on cancelled") {

     # update orderlist status
     $dbh->do("update  orderlists
               set     orderlist_status = ?
               where   orderlist_id = ?
              ", undef, 'cancelled', $orderlist_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update orderlist status)", $sr_name . "-" . __LINE__);

     &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tupdate_orderlist_status\t$orderlist_id\tset_on:cancelled");

     $top_message = p({-class=>"red"}, "Orderlist set on cancelled!");
  }
  ####################################################################################################################################

  ####################################################################################################################################
  # update mice2orderlist if requested
  if (defined(param('job')) && param('job') eq "update status") {

     # read update info from CGI parameters
     foreach $parameter (@parameters) {
        if ($parameter =~ /status_code__/) {
           (undef, $m2o_mouse_id) = split(/__/, $parameter);

           # update orderlist status
           $dbh->do("update  mice2orderlists
                     set     m2o_status = ?
                     where   m2o_orderlist_id = ?
                             and m2o_mouse_id = ?
                    ", undef, param($parameter), $orderlist_id, $m2o_mouse_id
                 ) or &error_message_and_exit($global_var_href, "SQL error (could not update mice2orderlist status)", $sr_name . "-" . __LINE__);

           &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tupdated_mice2orderlist_status\torderlist:\t$orderlist_id\tmouse_id:\t$m2o_mouse_id\tset_on:" . param($parameter));
        }
     }

     $top_message = p({-class=>"red"}, "updated orderlist status of mice");
  }
  ####################################################################################################################################

  ####################################################################################################################################
  # remove mice from orderlist
  if (defined(param('job')) && param('job') eq 'remove selected from orderlist' && defined(param('mouse_select'))) {
     # read list of selected mice from CGI form
     my @selected_mice = param('mouse_select');

     # check list of mouse ids for formally being MausDB IDs
     foreach $mouse_id (@selected_mice) {
        if ($mouse_id =~ /^[0-9]{8}$/) {
           ############################################################################################
           # delete entry from mice2orderlists
           $dbh->do("delete
                     from   mice2orderlists
                     where  m2o_mouse_id = ?
                     and    m2o_orderlist_id = ?
                    ", undef, $mouse_id, $orderlist_id
                   );

           &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tremove_mouse_from_orderlist\t$orderlist_id\t$mouse_id");
           ##########################################################################################
        }
     }

     $top_message = p({-class=>"red"}, "Mice deleted from orderlist!");
     $message     = p({-class=>"red"}, (scalar @selected_mice) . " mice deleted from orderlist.");
  }
  ####################################################################################################################################

  ####################################################################################################################################
  # delete all medical records uploaded for this orderlist
  if (defined(param('job')) && param('job') eq 'delete uploaded data from this orderlist') {
     if (defined(param('confirm_data_delete')) && param('confirm_data_delete') eq 'yes') {

        # try to get a lock
        &get_semaphore_lock($global_var_href, $user_id);

        ############################################################################################
        # begin transaction
        $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start delete medical records from orderlist transaction)", $sr_name . "-" . __LINE__);

        $dbh->do("delete
                  from   mice2medical_records
                  where  m2mr_mr_id in (select mr_id
                                        from   medical_records
                                        where  mr_orderlist_id = ?
                                       )
                 ", undef, $orderlist_id
               ) or &error_message_and_exit($global_var_href, "SQL error (could not delete entries from mice2medical_records)", $sr_name . "-" . __LINE__);

           $dbh->do("delete
                     from   medical_records
                     where  mr_orderlist_id = ?
                    ", undef, $orderlist_id
                   ) or &error_message_and_exit($global_var_href, "SQL error (could not delete medical_records)", $sr_name . "-" . __LINE__);


        $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

        # end transaction
        ############################################################################################

        # release lock
        &release_semaphore_lock($global_var_href, $user_id);

        &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tdelete_all_mrs_from_orderlist\t$orderlist_id\t$datetime_sql");

        $top_message = p({-class=>"red"}, "Deleted all medical records previously uploaded for this orderlist!");
     }
     else {
        $top_message = p({-class=>"red"}, "Medical records NOT deleted! Please go back and check the \"confirm\" box!");
     }

  }
  ####################################################################################################################################

  ####################################################################################################################################
  # change schedule date
  if (defined(param('job')) && param('job') eq 'change schedule date') {
     my $new_schedule_date = param('new_schedule_date');

     if ($new_schedule_date =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
        ############################################################################################
        # delete entry from mice2orderlists
        $dbh->do("update orderlists
                  set    orderlist_date_scheduled = ?
                  where  orderlist_id = ?
                ", undef, $new_schedule_date, $orderlist_id
                );

        &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tchanged_orderlist_schedule_date\t$orderlist_id\t$new_schedule_date");
        ##########################################################################################

        $top_message = p({-class=>"red"}, "changed schedule date for orderlist!");
     }
     else {
        $top_message = p({-class=>"red"}, "Did not change schedule date for orderlist (wrong date format)!");
     }
  }
  ####################################################################################################################################

  ####################################################################################################################################
  # add/update metadata
  if (defined(param('job')) && param('job') eq 'store or update metadata') {
     # read all parameters
     @metadata_parameters = param();

     # begin transaction
     $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start insert/update metadata transaction)", $sr_name . "-" . __LINE__);

     # collect all metadata_definition-ids from 'metadata_i' CGI-parameters
     foreach $metadata_parameter (unique_list(@metadata_parameters)) {

        # if parameter is named "metadata_1", "metadata_2", ... and is not undefined (has a value): store it
        if ($metadata_parameter =~ /metadata_([0-9]+)/ && defined(param('metadata_' . $1))) {

           # store the index
           $mdd_id = $1;

           # store the value
           $the_metadata_value = param('metadata_' . $mdd_id);

            # get name of metadata
           ($metadata_name) = $dbh->selectrow_array("select mdd_shortname
                                                     from   metadata_definitions
                                                     where  mdd_id = $mdd_id
                                                    ");
				
	            # get an insert metadata_id
	           ($new_metadata_id) = $dbh->selectrow_array("select (max(metadata_id)+1) as new_metadata_id
	                                                       from   metadata
	                                                      ");

	           # ok, this is only neccessary for the very first metadata_id when (max(metadata_id)+1) is undefined
	           if (!defined($new_metadata_id)) { $new_metadata_id = 1; }
	
	           # check if a specific metadata point has been stored
	           $sql = qq(select count(*)
	                     from   metadata
	                     where  metadata_orderlist_id = ?
	                            and metadata_mdd_id   = ?
	                );
	
	           @sql_parameters = ($orderlist_id, $mdd_id);

           		($metadata_is_stored) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

	           # if not stored: insert
	           if ($metadata_is_stored == 0) {
	              $dbh->do("insert
	                        into   metadata (metadata_id, metadata_mdd_id, metadata_value, metadata_orderlist_id,
	                                         metadata_medical_record_id, metadata_parameterset_id,
	                                         metadata_valid_datetime_from, metadata_valid_datetime_to)
	                        values (?, ?, ?, ?, NULL, NULL, NULL, NULL)
	                       ", undef, $new_metadata_id, $mdd_id, $the_metadata_value, $orderlist_id
	                    );
	
	              &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $username . "\tinserted_orderlist_metadata\t$orderlist_id\t$metadata_name\t$the_metadata_value\tok");
	           }
	           # otherwise: update
	           else {
	              $dbh->do("update metadata
	                        set    metadata_value = ?
	                        where  metadata_orderlist_id = ?
	                               and metadata_mdd_id   = ?
	                       ", undef, $the_metadata_value, $orderlist_id, $mdd_id
	                    );
	
	              &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $username . "\tupdated_orderlist_metadata\t$orderlist_id\t$metadata_name\t$the_metadata_value\tok");
	           }
        }
		# otherwise ignore
     }

     $rc = $dbh->commit or &error_message_and_exit($global_var_href, "SQL error (could not commit insert/update metadata transaction)", $sr_name . "-" . __LINE__);

     $top_message = p({-class=>"red"}, "Metadata updated!");
  }
  ####################################################################################################################################

  ####################################################################################################################################
  # add mice to the orderlist
  if (defined(param('job')) && param('job') eq 'add to orderlist') {

     if (param('mouse_ids') && param('mouse_ids') ne '') {

        # split the string that contains the mouse ids. Use any non-digit character as separator
        @id_list = split(/[^0-9]/, $mouse_ids);

        # check every element of the resulting list of potential mouse ids
        foreach $potential_id (@id_list) {
           # ... if it is an 8 digit number:
           if ($potential_id =~ /^[0-9]{8}$/) {
               # check if mouse with this id exists at all
               if (!defined(mouse_exists($global_var_href, $mouse_id)) || mouse_exists($global_var_href, $mouse_id) != $mouse_id) {
                  # if so, add it to the list
                  push(@mice_to_add, $potential_id);
               }
           }
        }
     }

     # loop over valid and existing mouse_ids, add them to cohort
     foreach $mouse_to_add (@mice_to_add) {
        # determine list position
        ($orderlist_position) = $dbh->selectrow_array("select (max(m2o_listposition)+1) as next_position
                                                       from   mice2orderlists
                                                       where  m2o_orderlist_id = $orderlist_id
                                                      ");
        # in case of empty list: init
        if (!defined($orderlist_position)) { $orderlist_position = 1; }

        # now check if mouse exists and is still alive
        ($check_mouse_to_add, $is_dead) = $dbh->selectrow_array("select mouse_id, mouse_deathorexport_datetime
                                                                 from   mice
                                                                 where  mouse_id = $mouse_to_add
                                                                ");
        if (defined($check_mouse_to_add)) {
           # now check if mouse already on orderlist
           ($is_on_list) = $dbh->selectrow_array("select m2o_mouse_id
                                                  from   mice2orderlists
                                                  where  m2o_orderlist_id = $orderlist_id
                                                         and m2o_mouse_id = $mouse_to_add
                                                 ");
           if (!defined($is_on_list)) {
              ###########################################################################################
              # insert into mice2orderlists
              $dbh->do("insert
                        into   mice2orderlists (m2o_mouse_id, m2o_orderlist_id, m2o_listposition, m2o_status, m2o_added_datetime)
                        values (?, ?, ?, ?, ?)
                       ", undef, $mouse_to_add, $orderlist_id, $orderlist_position, '', "$datetime_sql"
                      );

              &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tadd_mouse_to_orderlist\t$orderlist_id\t$mouse_to_add");
              ##########################################################################################

              $message .= p({-class=>"red"}, "Added mouse $mouse_to_add to orderlist.");
           }
        }
     }
  }
  ####################################################################################################################################

  ####################################################################################################################
  # 1. get orderlist info and mice on orderlist
  $sql = qq(select orderlist_id, orderlist_name, orderlist_created_by, orderlist_date_created, orderlist_job, orderlist_sampletype,
                   orderlist_sample_amount, orderlist_date_scheduled, orderlist_assigned_user, orderlist_parameterset, orderlist_status,
                   orderlist_comment, user_name, day_week_in_year, day_year, parameterset_name
            from   orderlists
                   join users         on         user_id = orderlist_created_by
                   left join days     on        day_date = orderlist_date_scheduled
                   join parametersets on parameterset_id = orderlist_parameterset
            where  orderlist_id = ?
           );

  @sql_parameters = ($orderlist_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  $page = h2("Orderlist view " .
            a({-href=>"$url?choice=orderlist_view&orderlist_id=$orderlist_id", -title=>"reload page"},
              img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
             )
          )
          . hr();

  # if no imports found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No such orderlist found");
     return $page;
  }

  $row = $result->[0];

  $parameterset = $row->{'orderlist_parameterset'};

  # else continue: display orderlist info table
  $page .= h2('Orderlist information ' . a({-href=>"$url?choice=print_orderlist&orderlist_id=$orderlist_id&sort_by=$sort_column&sort_order=$sort_order", -target=>'_blank'}, '[print orderlist]'))
           . $top_message
           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>"1", -summary=>"experiment_overview"})
           . Tr( {-align=>'center'},
               th("orderlist ID"),
               td(b($row->{'orderlist_id'})),
             )
           . Tr( {-align=>'center'},
               th("name"),
               td(textfield(-name => 'orderlist_new_name', -size=>"50", -maxlength=>'250', -default=>$row->{'orderlist_name'})
                  . submit(-name => "job", -value=>"update orderlist name")
               ),
             )
           . Tr( {-align=>'center'},
               th("created by"),
               td($row->{'user_name'}),
             )
           . Tr( {-align=>'center'},
               th("created at"),
               td(format_sql_datetime2display_datetime($row->{'orderlist_date_created'})),
             )
           . Tr( {-align=>'center'},
               th("job"),
               td($row->{'orderlist_job'}),
             )
           . Tr( {-align=>'center'},
               th("scheduled for"),
               td( table(
                         Tr(th("scheduled: "),
                            td(format_sql_date2display_date($row->{'orderlist_date_scheduled'}) . ' (week ' . $row->{'day_week_in_year'} . '/' . $row->{'day_year'} . ')')
                         ) .
                         Tr(th("change to: "),
                            td(get_calendar_week_popup_menu_2($global_var_href, $epoch_week, 'new_schedule_date', undef)),
                            td(submit(-name => "job", -value=>"change schedule date"))
                         )
                   )
               ),
             )
           . Tr( {-align=>'center'},
               th("assigned to"),
               td($row->{'user_name'}),
             )
           . Tr( {-align=>'center'},
               th("parameter set"),
               td(a({-href=>"$url?choice=parameterset_view&parameterset_id=" . $row->{'orderlist_parameterset'},-target=>'_blank'}, $row->{'parameterset_name'}
                  )
               ),
             )
           . Tr( {-align=>'center'},
               th("status"),
               td($row->{'orderlist_status'} . '&nbsp;&nbsp;'
                  . (($row->{'orderlist_status'} eq 'ordered' || $row->{'orderlist_status'} eq '')
                      ?submit(-name => "job", -value=>"set on done") . '&nbsp;' . submit(-name => "job", -value=>"set on cancelled")
                      :(($row->{'orderlist_status'} eq 'done')
                         ?submit(-name => "job", -value=>"set on ordered")
                         :(($row->{'orderlist_status'} eq 'cancelled')
                            ?submit(-name => "job", -value=>"set on ordered") . '&nbsp;' . submit(-name => "job", -value=>"set on done")
                            :''
                          )
                       )
                    )
               ),
             )
           . Tr(th("comment"),
                td(textarea(-name=>"orderlist_comment", -columns=>"50", -rows=>"2",
                            -value=>($row->{'orderlist_comment'} ne '')?$row->{'orderlist_comment'}:'no comments for this orderlist'
                   )
                   . br()
                   . submit(-name => "job", -value=>"update comment")
                )
             )
           . ((current_user_is_admin($global_var_href) eq 'y')
              ?Tr(th("delete orderlist data"),
                  td(b("Do you really want to delete all medical records uploaded for this orderlist?")
                     . br() . br()
                     . checkbox(-name=>'confirm_data_delete', -value=>'yes', -label=>'', -override=>1, -checked=>0)
                     . "&nbsp; yes, I want to delete all medical records from this orderlist "
                     . br()
                     . submit(-name => "job", -value=>"delete uploaded data from this orderlist")
                  )
               )
              :''
             )
           . end_table()
           . hr({-width=>'50%', -align=>'left'});

  ####################################################################################################################
  # 2. display metadata
  $sql = qq(select mdd_id, mdd_name, mdd_shortname, mdd_type, mdd_decimals, mdd_unit, mdd_default
  			, mdd_possible_values, mdd_active_yn, mdd_required
            from   orderlists
                   join metadata_definitions  on orderlist_parameterset = mdd_parameterset_id
            where  orderlist_id = ?
           );

  @sql_parameters = ($orderlist_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  $page .= h2('Parameterset-specific metadata');

  if ($rows == 0) {
     $page .= p("No parameterset-specific metadata stored or even defined! ");
  }
  else {
     $page .= start_table( {-border=>1, -summary=>"table"})
              . Tr(
                  th('Metadata'),
                  th('Value'),
                  th('Status')
                );
my $message_p;

     # loop over metadata
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

		 my $bgcolor = 'green';
		 $message_p = 'confirmed value';

         # check if a specific metadata point has been stored
         $sql = qq(select metadata_value
                   from   metadata
                   where  metadata_orderlist_id = ?
                          and   metadata_mdd_id = ?
                );

         @sql_parameters = ($orderlist_id, $row->{'mdd_id'});

         ($metadata_value) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

         # if distinct value stored in database, print it (no matter if active or not)
         if (defined($metadata_value)) {
            $print_value = textfield(-name => "metadata_" . $row->{'mdd_id'}, -size=>"50", -maxlength=>'255', -default=>$metadata_value);

			#check date
			if ($row->{'mdd_type'} eq 'd') {
				unless(check_date_ddmmyyyy($metadata_value)) {
					$message_p = "Error: Check format (dd.mm.yyyy)!";
					$bgcolor = 'yellow';
				}
			}
			
			#check datetime
			if ($row->{'mdd_type'} eq 't') {
				unless (check_datetime_ddmmyyyy_hhmmss($metadata_value)) {
					$message_p = "Error: Check format (dd.mm.yyyy hh:mm:ss)!";
					$bgcolor = 'yellow';
				}
			}
			
			#check required values; value is empty string
			if (($row->{'mdd_required'} eq 'y') && ($metadata_value eq '')) {
				$message_p = "Error: Required value!";
				$bgcolor = 'yellow';
			}
         }
         # else print the default value or let choose from stored possibilites (but only if definition is still active)
         elsif ($row->{'mdd_active_yn'} eq 'y') {
            if (defined($row->{'mdd_possible_values'})) {
               @possible_values = split(/;/, $row->{'mdd_possible_values'});

               $print_value = popup_menu( -name    => "metadata_" . $row->{'mdd_id'},
                                          -values  => [@possible_values],
                                          -default => $row->{'mdd_default'}
                              );
            }
            else {
               $print_value = textfield(-name => "metadata_" . $row->{'mdd_id'}, -size=>"50", -maxlength=>'255', -default=>$row->{'mdd_default'});
            }
            $bgcolor = 'red';
            $message_p = 'default value, please confirm or change';
            
         }
         # this metadata definition is not active any more, so skip
         else {
            next;
         }

         $page .= Tr(
                    td("$row->{'mdd_shortname'} ($row->{'mdd_name'})"),
                    td($print_value),
                    td({-bgcolor=>$bgcolor}, $message_p)
                  );
     }

     $page .= end_table()
              . br()
              . submit(-name=>"job", -value=>"store or update metadata");
  }

  ####################################################################################################################
  # 3. collect some details about mice on orderlist  (order by m2o_listposition asc, mouse_id asc)
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment, m2o_status,
                   mouse_birth_datetime, location_room, location_rack, cage_id, mouse_deathorexport_datetime,
                   dr1.death_reason_name as how, dr2.death_reason_name as why
            from   mice2orderlists
                   join mice               on             m2o_mouse_id = mouse_id
                   join mouse_strains      on             mouse_strain = strain_id
                   join mouse_lines        on               mouse_line = line_id
                   join mice2cages         on                 mouse_id = m2c_mouse_id
                   join cages2locations    on              m2c_cage_id = c2l_cage_id
                   join locations          on              location_id = c2l_location_id
                   join cages              on                  cage_id = c2l_cage_id
                   join death_reasons dr1  on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2  on  mouse_deathorexport_why = dr2.death_reason_id
            where  m2o_orderlist_id = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
            order  by $columns->{$sort_column} $sort_order
           );

  @sql_parameters = ($orderlist_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  $page .= ''
           #. end_form()
           . hr({-width=>'50%', -align=>'left'})
           . h2('Mice on orderlist');

  # if mice from orderlist cannot be found in database (should not happen): tell user and exit
  unless ($rows > 0) {
     $page .= p(b("No mice found having matching ids from your orderlist (probably all mice on that orderlist have been deleted)"))
              . $message
              . p()
              . textarea(-name => "mouse_ids", -columns=>"20", -rows=>"2", -override=>"1", -title=>"example: 30000001,30000033, 30010043")
              . hidden('orderlist_id')
              . '&nbsp;&nbsp;&nbsp;'
              . submit(-name=>"job", -value=>"add to orderlist");

     # store CGI parameters in hidden fields. Yes, I know, there are better ways to do this, but input from hidden fields will be checked
     foreach $parameter (@parameters) {
        unless ($parameter eq 'mouse_select' || $parameter eq 'job' || $parameter eq 'cart_name') {
           $page .= hidden(-name=>$parameter, -value=>param("$parameter")) . "\n";
        }
     }

     $page .=  hidden(-name=>"parameterset",   -value=>"$parameterset")
               . end_form();

     return ($page);
  }

  # proceed with displaying details about mice in cart
  $page .= p(b("There " . (($rows == 1)?'is':'are' ) . " $rows " . (($rows == 1)?'mouse':'mice' ) . qq( on this orderlist)))
           . $message
           . hidden('orderlist_id')
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th(a({-href=>"$url?choice=orderlist_view&orderlist_id=$orderlist_id&sort_order=$rev_order->{$sort_order}&sort_by=id", -title=>"click to sort by mouse id"}, "mouse ID")),
               th("ear"),
               th("sex"),
               th("born"),
               th("age"),
               th("death"),
               th("genotype"),
               th("strain"),
               th("line"),
               th(a({-href=>"$url?choice=orderlist_view&orderlist_id=$orderlist_id&sort_order=$rev_order->{$sort_order}&sort_by=rack", -title=>"click to sort by rack"}, "room/rack")
                . ' / '
                . a({-href=>"$url?choice=orderlist_view&orderlist_id=$orderlist_id&sort_order=$rev_order->{$sort_order}&sort_by=cage", -title=>"click to sort by cage"}, "cage")
               ),
               th("comment (shortened)"),
               th("pathoID"),
               th("view" . br() . "records" . br()
                  . "[" . a({-href=>"$url?choice=parameterset_stats&parameterset_id=$parameterset&orderlist_id=$orderlist_id"}, "stats") . "]"
               ),
               th("status"),
               th("edit status [" . a({-href=>"$url?choice=status_codes_overview", -target=>"_blank"}, "status codes") . "]"
                  . br()
                  . submit(-name=>"job", -value=>"update status")
               )
             );

  # loop over all mice
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     # shorten comment to fit on page
     if (defined($row->{'mouse_comment'}) && $row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
     }
     elsif (!defined($row->{'mouse_comment'})) {
        $short_comment = '';
     }
     else {
        $short_comment = $row->{'mouse_comment'};
     }

     $short_comment =~ s/^'(.*)'$/$1/g;

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current line
     $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                td($i+1),
                td(checkbox('mouse_select', '0', $row->{'mouse_id'}, '')),
                td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                td($row->{'mouse_earmark'}),
                td($row->{'mouse_sex'}),
                td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                td({-title=>"$row->{'how'}, $row->{'why'}"}, format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
                td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
                td($row->{'strain_name'}),
                td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                td((!defined($row->{'mouse_deathorexport_datetime'}))                                                             # check if mouse is alive
                    ?a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"},     # yes: print cage link
                       $row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'})
                    :'-'                                                                                                          # no: don't print cage link
                  ),
                td({-align=>'left'},
                   ((defined($current_mating))
                    ?"(in mating $current_mating) "
                    :''
                   )
                   . $short_comment
                ),
                td(get_pathoID($global_var_href, $row->{'mouse_id'})),
                td(records_for_this_mouse($global_var_href, $row->{'mouse_id'}, $parameterset, $orderlist_id)),
                td((defined($row->{'m2o_status'})?$row->{'m2o_status'}:"-")),
                td(get_procedure_status_codes_popup_menu($global_var_href, $row->{'mouse_id'}, $row->{'m2o_status'}))
              );
  }

  $page .= end_table()
           . p()
           . submit(-name=>"job", -value=>"remove selected from orderlist")
           . p()
           . p("You may add mice to the orderlist by entering their IDs: ")
           . textarea(-name => "mouse_ids", -columns=>"20", -rows=>"2", -override=>"1", -title=>"example: 30000001,30000033, 30010043")
           . '&nbsp;&nbsp;&nbsp;'
           . submit(-name=>"job", -value=>"add to orderlist");


  # store 'choice' parameter
  foreach $parameter (@parameters) {
     if ($parameter eq 'choice' ) {
        $page .= hidden(-name=>$parameter, -value=>param("$parameter")) . "\n";
     }
  }

  $page .= hr()
           . hidden(-name=>"parameterset",   -value=>"$parameterset")
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"Add selected mice to cart")           . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"kill")                                . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"print selected orderlist")            . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"upload data for mice from this list") . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"assign media files")                  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"apply R script")
           . end_form();

  return $page;
}
# end of orderlist_view()
#------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE003 mouse_orderlists_view():                  orderlist view for a mouse
sub mouse_orderlists_view {                           my $sr_name = 'SR_PHE003';
  my ($global_var_href) = @_;                         # get reference to global vars hash
  my $url               = url();
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $mouse_id          = param('mouse_id');
  my $orderlist_id      = param('delete_orderlist');
  my ($page, $sql, $sql1, $result1, $rows1, $row1, $i1);
  my  ($sql2, $result2, $rows2, $row2, $i2);
  my %calendar_week;
  my $head_columns  = '';
  my %parameterset_class = (1 => "I", 2 => "II", 3 => "III", 99 => "Blood");
  my $date_sql;
  my ($epoch_week, $epoch_week_last, $first_task_at, $last_task_at, $columns, $i);
  my @sql_parameters;

  # check input: is orderlist id given? is it a number?
  if (!param('mouse_id') || param('mouse_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid mouse id"));
     return $page;
  }

  if (defined(param('job')) && param('job') eq 'delete' && defined(param('delete_orderlist')) && param('delete_orderlist') =~ /^[0-9]+$/) {
     ############################################################################################
     # delete entry from mice2orderlists
     $dbh->do("delete
               from   mice2orderlists
               where  m2o_mouse_id = ?
               and    m2o_orderlist_id = ?
              ", undef, $mouse_id, $orderlist_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not add gene link)", $sr_name . "-" . __LINE__);
     ##########################################################################################

  }

  # query starting date of phenotyping
  $sql = qq(select min(orderlist_date_scheduled) as start_date, max(orderlist_date_scheduled) as end_date
            from   orderlists
                   join mice2orderlists on m2o_orderlist_id = orderlist_id
            where m2o_mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($first_task_at, $last_task_at) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (!defined($first_task_at) || !defined($last_task_at)) {
     $page .= h2("Orderlist view for mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id", -title=>"click for mouse details"}, $mouse_id))
              . hr()
              . p("No orderlists found for this mouse. ");

     return ($page);
  }

  # query epoch week of 'first_task_at'
  $sql = qq(select day_epoch_week
            from   days
            where  day_date = ?
           );

  @sql_parameters = ($first_task_at);

  ($epoch_week) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # query epoch week of 'first_task_at'
  $sql = qq(select day_epoch_week
            from   days
            where  day_date = ?
           );

  @sql_parameters = ($last_task_at);

  ($epoch_week_last) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # query all calendar weeks between week of first task and week of last task (both inclusive)
  $sql1 = qq(select day_number, day_week_and_year, day_date as monday_of_week, day_week_in_year, day_year
             from   days
             where      day_epoch_week >= ?
                    and day_epoch_week <= ?
                    and day_week_day_number = ?
             order  by day_date asc
           );

  @sql_parameters = ($epoch_week, $epoch_week_last, 1);

  ($result1, $rows1) = &do_multi_result_sql_query2($global_var_href, $sql1, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # build column header with calendar weeks
  for ($i1=0; $i1<$rows1; $i1++) {
      $row1 = $result1->[$i1];

      # write look-up table: column->date_of_monday
      $calendar_week{$i1} = $row1->{'monday_of_week'};

      $head_columns .= td({-align=>'center', valign=>'top', -style=>'font-size: 10px; font-weight : bold;'}, $row1->{'day_week_in_year'} . br() . $row1->{'day_year'} . br() . format_sql_datetime2display_day_and_month($row1->{'monday_of_week'}));
  }

  # now query all involved parametersets
  $sql2 = qq(select parameterset_id, parameterset_name, parameterset_class, parameterset_display_order, orderlist_date_scheduled, orderlist_id
             from   parametersets
                    join orderlists      on orderlist_parameterset = parameterset_id
                    join mice2orderlists on       m2o_orderlist_id = orderlist_id
             where  m2o_mouse_id = ?
             order  by orderlist_date_scheduled asc
            );

  @sql_parameters = ($mouse_id);

  ($result2, $rows2) = &do_multi_result_sql_query2($global_var_href, $sql2, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if mice from cart cannot be found in database (should not happen): tell user and exit
  unless ($rows2 > 0) {
     $page .= h2("Orderlist view for mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id", -title=>"click for mouse details"}, $mouse_id))
              . hr()
              . p("No orderlists found for this mouse. ");

     return ($page);
  }


  # display form
  $page .= h2("Orderlist view for mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id", -title=>"click for mouse details"}, $mouse_id))
           . hr()
           . h3("Mouse $mouse_id is on the following orderlist(s)")
           . ((current_user_is_admin($global_var_href) eq 'y')
              ?p("You may delete (d) this mouse from an orderlist or view (v) and edit the orderlist")
               . p({-class=>'red'}, "warning: (d)elete will remove mouse from orderlist immediately")
              :''
             )
           . start_form(-action=>url(), -name=>"myform")

           . start_table( {-border=>1, -summary=>"table"})
           . Tr(
               th({-colspan=>3}, ''),
               th({-colspan=>20}, b("week" . br() . "year" . br() . "monday of week"))
             )
           . Tr(
               th({-align=>'center', valign=>'bottom', -colspan=>2}, 'Parameterset'),
               th({-align=>'center', valign=>'bottom'}, 'class'),
               $head_columns
             );

  # loop over parametersets (just to to build sorting hashes)
  for ($i2=0; $i2<$rows2; $i2++) {
      $row2 = $result2->[$i2];

      $columns = '';

      # loop over calendar weeks ...
      for ($i=0; $i<$rows1; $i++) {
          # ... and set mice from @mice_for_phenotyping to orderlist in the calendar week chosen for the current parameterset
          if (get_epoch_week($global_var_href, $row2->{'orderlist_date_scheduled'}) == get_epoch_week($global_var_href, $calendar_week{$i}) ) {
             $columns .= td({-bgcolor=>"red"}, ((current_user_is_admin($global_var_href) eq 'y')
                                                ?a({-href=>"$url?choice=show_mouse_orderlists&mouse_id=$mouse_id&job=delete&delete_orderlist=$row2->{'orderlist_id'}",
                                                    -title=>'delete'}, 'delete'
                                                 ) . '&nbsp;&nbsp;&nbsp;&nbsp;'
                                                :''
                                               )
                                               . a({-href=>"$url?choice=orderlist_view&orderlist_id=" . $row2->{'orderlist_id'},
                                                    -title=>'view'}, 'view')
                         );
          }
          else {
             $columns .= td('');
          }
      }

      $page .= Tr( {-align=>'center'},
                 th(($i2+1)),
                 th(a({-href=>"$url?choice=parameterset_view&parameterset_id=" . $row2->{'parameterset_id'},-target=>'_blank'}, $row2->{'parameterset_name'})),
                 th($parameterset_class{$row2->{'parameterset_class'}}),
                 $columns
               );
  }

  $page .= end_table()
           . p()
           . end_form();

  return $page;
}
# end of mouse_orderlists_view()
#------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_PHE004 show_mouse_phenotyping_record_overview():    show phenotyping records overview for a mouse
sub show_mouse_phenotyping_record_overview {             my $sr_name = 'SR_PHE004';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $mouse_id          = param('mouse_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($parameterset_id, $parameterset_name, $parameter_unit, $parameterset_class, $parameterset_description, $project_name, $project_shortname);
  my ($value_int, $value_float, $value_text, $value_bool);
  my @sql_parameters;

  # check input: is mouse id given? is it a number?
  if (!param('mouse_id') || param('mouse_id') !~ /^[0-9]{8}$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid mouse id"));
     return $page;
  }

  $page = h2("Phenotyping results for mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id"}, $mouse_id) . " [" . a({-href=>"$url?choice=show_mouse_phenotyping_records_overview&mouse_id=$mouse_id"}, "overview") . "]")
          . hr();

  # get list of all parametersets that have medical records
  # first query all involved parametersets from phenotyping records for this mouse
  # (in order to sort medical records)
  $sql = qq(select count(m2mr_mr_id) as number_of_mrs, mr_parameterset_id
            from   mice2medical_records
                   join medical_records on m2mr_mr_id = mr_id
            where  m2mr_mouse_id = ?
            group  by mr_parameterset_id
           );

  @sql_parameters = ($mouse_id);

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  unless ($rows > 0) {
    $page .= p("No phenotyping results found for this mouse");
    return $page;
  }

  # else: first generate table header ...
  $page .= h3("There are phenotyping records for mouse $mouse_id from the following parametersets")
           . start_table( {-border=>"1", -summary=>"table"})
           . Tr( {-align=>'center'},
               th("parameterset"),
               th("record #"),
               th("description"),
               th("class"),
               th("project")
             );

  # ... then loop over all parametersets
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      # if we have a parameter set
      if (defined($row->{'mr_parameterset_id'})) {
         # get parameterset name
         $sql = qq(select parameterset_id, parameterset_name, parameterset_class, parameterset_description, project_name, project_shortname
                   from   parametersets
                          left join projects on parameterset_project_id = project_id
                   where  parameterset_id = ?
                );

         @sql_parameters = ($row->{'mr_parameterset_id'});

         ($parameterset_id, $parameterset_name, $parameterset_class, $parameterset_description, $project_name, $project_shortname) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

         # generate the current row
         $page .= Tr({-align=>'center'},
                    td(a({-href=>"$url?choice=show_mouse_phenotyping_records&mouse_id=$mouse_id&parameterset_id=$parameterset_id"}, $parameterset_name)),
                    td($row->{'number_of_mrs'}),
                    td($parameterset_description),
                    td($parameterset_class),
                    td({-title=>"$project_name"}, $project_shortname)
                   );
      }
      # otherwise: medical record does not belong to a parameterset
      else {
         # generate the current row
         $page .= Tr({-align=>'center'},
                    td(a({-href=>"$url?choice=show_mouse_phenotyping_records&mouse_id=$mouse_id&parameterset_id=none"}, 'NO_SET')),
                    td($row->{'number_of_mrs'}),
                    td('medical records not assigned to a parameterset'),
                    td('n/a'),
                    td('n/a')
                   );
      }
  }

  $page .= end_table();

  return $page;
}
# end of show_mouse_phenotyping_record_overview()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_PHE005 phenotyping_order_1                           order phenotyping (step 1: form)
sub phenotyping_order_1 {                                 my $sr_name = 'SR_PHE005';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $sql, $result, $rows, $row, $i);
  my $url                  = url();
  my @mice_for_phenotyping = ();
  my ($mouse);

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_for_phenotyping, $mouse);
     }
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_for_phenotyping == 0) {
     $page .= h2("Order phenotyping")
              . hr()
              . h3("No mice for chosen for phenotyping")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # display form
  $page .= h2("Order phenotyping: 1. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("Please specify phenotyping workflow ")
           . table( {-border=>1},
                Tr( td({-align=>'center'}, b("Workflow ")),
                    td(get_workflows_popup_menu($global_var_href))
                ) .
                Tr( td({-align=>'center'}, b("Calendar week") . br() . small('(of first phenotyping task)')),
                    td(get_calendar_week_popup_menu($global_var_href))
                )
             )
           . p()
           . hidden(-name=>'mouse_select') . "\n"
           . start_table({-border=>1, -summary=>"table"})
           . Tr(
               th("mouse id"),
               th("ear"),
               th("sex")
             );

  # one table row for each mouse
  foreach $mouse (@mice_for_phenotyping) {

     $page .= Tr({-align=>"center"},
                td($mouse),
                td(get_earmark($global_var_href, $mouse)),
                td(get_sex($global_var_href, $mouse))
              );
  }

  $page .= end_table()
           . p()
           . submit(-name => "choice", -value=>"phenotyping: next step")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel phenotyping order (go to previous page)"))
           . end_form();

  return $page;
}
# end of phenotyping_order_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE006 phenotyping_order_2                           order phenotyping (step 2: form)
sub phenotyping_order_2 {                                 my $sr_name = 'SR_PHE006';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};               # DBI database handle
  my ($page, $sql1, $result1, $rows1, $row1, $i1);
  my  ($sql, $sql2, $result2, $rows2, $row2, $i2);
  my $first_task_at = param('first_task_at');
  my $workflow_id   = param('workflow_id');
  my $url = url();
  my ($ref_date_number, $epoch_week, $columns, $i, $day_number_of_parameterset, $the_day, $popup_default);
  my %startdate_of_parameterset;
  my %parameterset_class = (1 => "I", 2 => "II", 3 => "III", 4 => "IV", 5 => "V");
  my ($mouse, $birth_datetime_sql, $death_datetime_sql);
  my $warning = '';
  my @sql_parameters;

  # 1. check if workflow given
  if (!defined(param('workflow_id')) || param('workflow_id') !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid workflow id (must be a number)", $sr_name . "-" . __LINE__);
  }

  # 2. check if date of first task given
  if (!defined(param('first_task_at')) || param('first_task_at') !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
     &error_message_and_exit($global_var_href, "date of first task not given or invalid", $sr_name . "-" . __LINE__);
  }

  # 3. read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # 4. check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {

        # 4a. get date of birth to prevent phenotyping_date < birth_date
        ($birth_datetime_sql) = $dbh->selectrow_array("select mouse_birth_datetime
                                                       from   mice
                                                       where  mouse_id = $mouse
                                                      ");

        # check if litter_born_date < mating_start_date: if so, warn
        if (Delta_ddmmyyyhhmmss(format_sql_datetime2display_datetime(param('first_task_at') . ' 00:00:00'), format_sql_datetime2display_datetime($birth_datetime_sql)) eq 'future') {
           $warning .= p({-class=>"red"}, b("Warning: mouse $mouse not born before first phenotyping task (Born: " . format_sql_datetime2display_datetime($birth_datetime_sql) . ")! "));
        }

        # 4b. check if mouse is still alive
        ($death_datetime_sql) = $dbh->selectrow_array("select mouse_deathorexport_datetime
                                                       from   mice
                                                       where  mouse_id = $mouse
                                                      ");

        # if mouse is dead, warn
        if (defined($death_datetime_sql)) {
           $warning .= p({-class=>"red"}, b("Warning: mouse $mouse is dead (Death: " . format_sql_datetime2display_datetime($death_datetime_sql) . ")! "));
        }
     }
  }

  # PREPARE STEP 1
  # query day_number and epoch week of 'first_task_at' (which is a date)
  $sql = qq(select day_number, day_epoch_week
            from   days
            where  day_date = ?
           );

  @sql_parameters = ($first_task_at);

  ($ref_date_number, $epoch_week) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};


  # PREPARE STEP 2
  # for the given workflow, query defined task_start_days for every parameterset
  $sql1 = qq(select parameterset_id, w2p_days_from_ref_date
             from   parametersets
                    left join workflows2parametersets on w2p_parameterset_id = parameterset_id
             where  w2p_workflow_id = ?
          );

  @sql_parameters = ($workflow_id);

  ($result1, $rows1) = &do_multi_result_sql_query2($global_var_href, $sql1, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results
  for ($i1=0; $i1<$rows1; $i1++) {
      $row1 = $result1->[$i1];

      # add to given ref_date of workflow the relative number of days for the current parameterset to get the absolute day for the current parameterset
      $day_number_of_parameterset = $ref_date_number + $row1->{'w2p_days_from_ref_date'};

      # now get the date which has the day_number calculated above
      $sql = qq(select day_date
                from   days
                where  day_number = ?
             );

      @sql_parameters = ($day_number_of_parameterset);

      ($the_day) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      # write to look-up table: parameterset->start_date
      $startdate_of_parameterset{$row1->{'parameterset_id'}} = $the_day;
  }

  # ACTUAL TABLE
  # query all active parametersets
  $sql2 = qq(select parameterset_id, parameterset_name, parameterset_class, parameterset_display_order
             from   parametersets
             where  parameterset_is_active = ?
             order  by parameterset_class asc, parameterset_name asc
          );

  @sql_parameters = ('y');

  ($result2, $rows2) = &do_multi_result_sql_query2($global_var_href, $sql2, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($warning ne '') {
     $warning = hr()
                . $warning
                . p("Go " . a({-href=>"javascript:back()"}, "back") . ' or proceed');
  }

  # display form
  $page .= h2("Order phenotyping: 2. step")
           . $warning
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . hidden(-name=>'first_task_at') . "\n"                 # re-write date of first task
           . hidden(-name=>'mouse_select')  . "\n"                 # re-write selected mice
           . hidden(-name=>'workflow_id')   . "\n"                 # re-write workflow_id

           . start_table( {-border=>1, -summary=>"table"})
           . Tr(
               th({-colspan=>2}, 'Parameterset'),
               th('Class'),
               th({-colspan=>20}, b("calendar week (monday)"))
             );

  # loop over all parametersets
  for ($i2=0; $i2<$rows2; $i2++) {
      $row2 = $result2->[$i2];

      # if there is a startdate defined for the current parameterset, this is the default in the popup_menu
      if (defined($startdate_of_parameterset{$row2->{'parameterset_id'}})) {
         $popup_default = $startdate_of_parameterset{$row2->{'parameterset_id'}};
      }
      # else set default to 'never' (which displays as '-')
      else {
         $popup_default = 'never';
         # next;
      }

      $page .= Tr( {-align=>'center'},
                 th(($i2+1)),
                 th(a({-href=>"$url?choice=parameterset_view&parameterset_id=" . $row2->{'parameterset_id'},-target=>'_blank'}, $row2->{'parameterset_name'})),
                 th($parameterset_class{$row2->{'parameterset_class'}}),
                 td(get_calendar_week_popup_menu_2($global_var_href, $epoch_week, 'date_for_parameterset_' . $row2->{'parameterset_id'}, $popup_default))
               );
  }

  $page .= end_table()
           . p()
           . submit(-name => "choice", -value=>"phenotyping: confirm")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel phenotyping confirmation (go to previous page)"))
           . end_form();

  return $page;
}
# end of phenotyping_order_2()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE007 phenotyping_order_3                           order phenotyping (step 3: form)
sub phenotyping_order_3 {                                 my $sr_name = 'SR_PHE007';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $dbh     = $global_var_href->{'dbh'};                # DBI database handle
  my ($page, $sql1, $result1, $rows1, $row1, $i1);
  my ($sql, $sql2, $result2, $rows2, $row2, $i2);
  my $first_task_at = param('first_task_at');
  my $workflow_id   = param('workflow_id');
  my $url = url();
  my %calendar_week;
  my $head_columns  = '';
  my $hidden_fields = '';
  my ($epoch_week, $columns, $i, $j, $sql_parameter_list, $parameter);
  my @parameters = param();
  my @parameterlist;
  my %sort_parametersets_by_date;
  my %sort_parametersets_by_name;
  my %parameterset_class = (1 => "I", 2 => "II");
  my ($mouse, $birth_datetime_sql, $death_datetime_sql);
  my $warning = '';
  my @sql_parameters;

  # check if workflow given
  if (!defined(param('workflow_id')) || param('workflow_id') !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid workflow id (must be a number)", $sr_name . "-" . __LINE__);
  }

  # check if date of first task given
  if (!defined(param('first_task_at')) || param('first_task_at') !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
     &error_message_and_exit($global_var_href, "date of first task not given or invalid", $sr_name . "-" . __LINE__);
  }

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {

        # 4a. get date of birth to prevent phenotyping_date < birth_date
        ($birth_datetime_sql) = $dbh->selectrow_array("select mouse_birth_datetime
                                                       from   mice
                                                       where  mouse_id = $mouse
                                                      ");

        # check if litter_born_date < mating_start_date: if so, warn
        if (Delta_ddmmyyyhhmmss(format_sql_datetime2display_datetime(param('first_task_at') . ' 00:00:00'), format_sql_datetime2display_datetime($birth_datetime_sql)) eq 'future') {
           $warning .= p({-class=>"red"}, b("Warning: mouse $mouse not born before first phenotyping task (Born: " . format_sql_datetime2display_datetime($birth_datetime_sql) . ")! "));
        }

        # 4b. check if mouse is still alive
        ($death_datetime_sql) = $dbh->selectrow_array("select mouse_deathorexport_datetime
                                                       from   mice
                                                       where  mouse_id = $mouse
                                                      ");

        # if mouse is dead, warn
        if (defined($death_datetime_sql)) {
           $warning .= p({-class=>"red"}, b("Warning: mouse $mouse is dead (Death: " . format_sql_datetime2display_datetime($death_datetime_sql) . ")! "));
        }
     }
  }

  # query epoch week of 'first_task_at'
  $sql = qq(select day_epoch_week
            from   days
            where  day_date = ?
           );

  @sql_parameters = ($first_task_at);

  ($epoch_week) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # query next 20 calendar weeks
  $sql1 = qq(select day_number, day_week_and_year, day_date as monday_of_week, day_week_in_year, day_year
             from   days
             where      day_epoch_week > ($epoch_week - 1)
                    and day_epoch_week < ($epoch_week + 20)
                    and day_week_day_number = ?
             order  by day_date asc
           );

  @sql_parameters = (1);

  ($result1, $rows1) = &do_multi_result_sql_query2($global_var_href, $sql1, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # build column header with calendar weeks
  for ($i1=0; $i1<$rows1; $i1++) {
      $row1 = $result1->[$i1];

      # write look-up table: column->date_of_monday
      $calendar_week{$i1} = $row1->{'monday_of_week'};

      $head_columns .= td({-align=>'center', valign=>'top', -style=>'font-size: 10px; font-weight : bold;'}, $row1->{'day_week_in_year'} . br() . $row1->{'day_year'} . br() . format_sql_datetime2display_day_and_month($row1->{'monday_of_week'}));
  }

  # collect all parameterset-ids from CGI-parameters (use this to only generate table rows for scheduled parametersets)
  foreach $parameter (unique_list(@parameters)) {
     # select for those which are named "date_for_parameterset_1", "date_for_parameterset_2", ... and which are not set to 'never'
     # in other words: those who have an assigned date
     if ($parameter =~ /date_for_parameterset_([0-9]+)/ && defined(param('date_for_parameterset_' . $1)) && param('date_for_parameterset_' . $1) ne 'never') {
        push(@parameterlist, $1);
     }
  }

  # make the list SQL compatible
  $sql_parameter_list = join(',', unique_list(@parameterlist));

  # now query all those parametersets
  $sql2 = qq(select parameterset_id, parameterset_name, parameterset_class, parameterset_display_order
             from   parametersets
             where  parameterset_id in ($sql_parameter_list)
             order  by parameterset_display_order
          );

  @sql_parameters = ();

  ($result2, $rows2) = &do_multi_result_sql_query2($global_var_href, $sql2, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($warning ne '') {
     $warning = hr()
                . $warning
                . p("Mice with warnings will be put on the orderlists. It is upon you if this makes sense.");
  }

  # display form
  $page .= h2("Order phenotyping: 3. step")
           . $warning
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . hidden(-name=>'first_task_at') . "\n"                 # re-write date of first task
           . hidden(-name=>'mouse_select')  . "\n"                 # re-write selected mice
           . hidden(-name=>'workflow_id')   . "\n"                 # re-write workflow_id

           . h3("Please check your phenotyping order and confirm")

           . start_table( {-border=>1, -summary=>"table"})
           . Tr(
               th({-colspan=>3}, ''),
               th({-colspan=>20}, b("week" . br() . "year" . br() . "monday of week"))
             )
           . Tr(
               th({-align=>'center', valign=>'bottom', -colspan=>2}, 'Parameterset'),
               th({-align=>'center', valign=>'bottom'}, 'class'),
               $head_columns
             );

  # loop over results (just to build sorting hashes)
  for ($i2=0; $i2<$rows2; $i2++) {
      $row2 = $result2->[$i2];

      for ($i=0; $i<20; $i++) {

          if (defined(param('date_for_parameterset_' . $row2->{'parameterset_id'})) && param('date_for_parameterset_' . $row2->{'parameterset_id'}) eq $calendar_week{$i}) {
             $sort_parametersets_by_date{$i2} = param('date_for_parameterset_' . $row2->{'parameterset_id'});
             $sort_parametersets_by_name{$i2} = $row2->{'parameterset_name'};
          }
      }
  }

  # loop over parametersets
  foreach $i2 (sort {$sort_parametersets_by_date{$a} cmp $sort_parametersets_by_date{$b} ||                                      # first sort by date
                     $sort_parametersets_by_name{$a} cmp $sort_parametersets_by_name{$b} } keys %sort_parametersets_by_date) {   # then alphabetically
      $row2 = $result2->[$i2];

      $columns = '';
      $j++;

      for ($i=0; $i<20; $i++) {

          if (defined(param('date_for_parameterset_' . $row2->{'parameterset_id'})) && param('date_for_parameterset_' . $row2->{'parameterset_id'}) eq $calendar_week{$i}) {
             $columns .= td({-bgcolor=>"red"}, '');
             $hidden_fields .= hidden(-name=>'date_for_parameterset_' . $row2->{'parameterset_id'});
          }
          else {
             $columns .= td('');
          }
      }

      $page .= Tr( {-align=>'center'},
                 th(($j)),
                 th(a({-href=>"$url?choice=parameterset_view&parameterset_id=" . $row2->{'parameterset_id'},-target=>'_blank'}, $row2->{'parameterset_name'})),
                 th($parameterset_class{$row2->{'parameterset_class'}}),
                 $columns
               );
  }

  $page .= end_table()
           . p()
           . $hidden_fields
           . p("[optional: prefix to orderlist name] "
               . textfield(-name => 'orderlist_name_prefix', -size => '20', -value=>'', -maxlength => '20', -title => 'orderlist name prefix')
             )
           . p()
           . submit(-name => "choice", -value=>"order phenotyping!")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel phenotyping confirmation (go to previous page)"))
           . end_form();

  return $page;
}
# end of phenotyping_order_3()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE008 phenotyping_order_4                           order phenotyping (step 4: do the database transaction)
sub phenotyping_order_4 {                                 my $sr_name = 'SR_PHE008';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $dbh      = $global_var_href->{'dbh'};               # DBI database handle
  my $session  = $global_var_href->{'session'};           # session handle
  my $user_id  = $session->param('user_id');
  my $username = $session->param('username');
  my ($page, $sql1, $result1, $rows1, $row1, $i1);
  my  ($sql, $sql2, $result2, $rows2, $row2, $i2);
  my $first_task_at         = param('first_task_at');
  my $workflow_id           = param('workflow_id');
  my $orderlist_name_prefix = param('orderlist_name_prefix');
  my $url = url();
  my %calendar_week;
  my $head_columns  = '';
  my ($epoch_week, $columns, $i, $sql_parameter_list, $parameter, $mouse, $orderlist_id, $orderlist_name, $rc);
  my @parameters = param();
  my @parameterlist;
  my @mice_for_phenotyping;
  my $datetime_sql = get_current_datetime_for_sql();
  my ($current_mouse, $is_mouse_on_orderlist, $insert_message, $line);
  my %sort_parametersets_by_date;
  my %sort_parametersets_by_name;
  my %parameterset_class = (1 => "I", 2 => "II");
  my $date_sql;
  my ($birth_datetime_sql, $death_datetime_sql);
  my $warning = '';
  my @sql_parameters;
  my $create_orderlist = 0;
  my $summary = '';
  my $add_orderlist_name_prefix = '';
  my $existing_orderlist;

  # check if workflow given
  if (!defined(param('workflow_id')) || param('workflow_id') !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid workflow id (must be a number)", $sr_name . "-" . __LINE__);
  }

  # process prefix to orderlist_name
  if (defined(param('orderlist_name_prefix')) && $orderlist_name_prefix ne "") {
     $add_orderlist_name_prefix = $orderlist_name_prefix;
     $add_orderlist_name_prefix =~ s/'|;|-{2}//g;                  # remove dangerous content
  }

  # check if date of first task given
  if (!defined(param('first_task_at')) || param('first_task_at') !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
     &error_message_and_exit($global_var_href, "date of first task not given or invalid", $sr_name . "-" . __LINE__);
  }

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_for_phenotyping, $mouse);

        # get date of birth to prevent phenotyping_date < birth_date
        ($birth_datetime_sql) = $dbh->selectrow_array("select mouse_birth_datetime
                                                       from   mice
                                                       where  mouse_id = $mouse
                                                      ");

        # check if litter_born_date < mating_start_date: if so, warn
        if (Delta_ddmmyyyhhmmss(format_sql_datetime2display_datetime(param('first_task_at') . ' 00:00:00'), format_sql_datetime2display_datetime($birth_datetime_sql)) eq 'future') {
           $warning .= p({-class=>"red"}, b("Warning: mouse $mouse not born before first phenotyping task (Born: " . format_sql_datetime2display_datetime($birth_datetime_sql) . ")! "));
        }

        # check if mouse is still alive
        ($death_datetime_sql) = $dbh->selectrow_array("select mouse_deathorexport_datetime
                                                       from   mice
                                                       where  mouse_id = $mouse
                                                      ");

        # if mouse is dead, warn
        if (defined($death_datetime_sql)) {
           $warning .= p({-class=>"red"}, b("Warning: mouse $mouse is dead (Death: " . format_sql_datetime2display_datetime($death_datetime_sql) . ")! "));
        }
     }
  }

  $line = get_line_name_by_id($global_var_href, get_line($global_var_href, $mice_for_phenotyping[0]));

  # query epoch week of 'first_task_at'
  $sql = qq(select day_epoch_week
            from   days
            where  day_date = ?
         );

  @sql_parameters = ($first_task_at);

  ($epoch_week) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # query next 20 calendar weeks
  $sql1 = qq(select day_number, day_week_and_year, day_date as monday_of_week, day_week_in_year, day_year
             from   days
             where      day_epoch_week > ($epoch_week - 1)
                    and day_epoch_week < ($epoch_week + 20)
                    and day_week_day_number = ?
             order  by day_date asc
          );

  @sql_parameters = (1);

  ($result1, $rows1) = &do_multi_result_sql_query2($global_var_href, $sql1, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # build column header with calendar weeks
  for ($i1=0; $i1<$rows1; $i1++) {
      $row1 = $result1->[$i1];

      # write look-up table: column->date_of_monday
      $calendar_week{$i1} = $row1->{'monday_of_week'};

      $head_columns .= td({-align=>'center', valign=>'top', -style=>'font-size: 10px; font-weight : bold;'}, $row1->{'day_week_in_year'} . br() . $row1->{'day_year'} . br() . format_sql_datetime2display_day_and_month($row1->{'monday_of_week'}));
  }

  # collect all parameterset-ids from CGI-parameters (use this to only generate table rows for scheduled parametersets)
  foreach $parameter (unique_list(@parameters)) {
     # select for those which are named "date_for_parameterset_1", "date_for_parameterset_2", ... and which are not set to 'never'
     # in other words: those who have an assigned date
     if ($parameter =~ /date_for_parameterset_([0-9]+)/ && defined(param('date_for_parameterset_' . $1)) && param('date_for_parameterset_' . $1) ne 'never') {
        push(@parameterlist, $1);
     }
  }

  # make the list SQL compatible
  $sql_parameter_list = join(',', unique_list(@parameterlist));

  # now query all those parametersets
  $sql2 = qq(select parameterset_id, parameterset_name, parameterset_class, parameterset_display_order
             from   parametersets
             where  parameterset_id in ($sql_parameter_list)
             order  by parameterset_display_order
          );

  @sql_parameters = ();

  ($result2, $rows2) = &do_multi_result_sql_query2($global_var_href, $sql2, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($warning ne '') {
     $warning = hr()
                . $warning
                . p("Mice with warnings have been put on the orderlists. It is upon you to check if this makes sense.");
  }

  # display form
  $page .= h2("Order phenotyping: 4. step ")
           . $warning
           . start_form(-action=>url(), -name=>"myform")
           . hr()

           . start_table( {-border=>1, -summary=>"table"})
           . Tr(
               th({-colspan=>2}, ''),
               th({-colspan=>20}, b("week" . br() . "year" . br() . "monday of week"))
             )
           . Tr(
               th({-align=>'center', valign=>'bottom'}, 'Parameterset'),
               th({-align=>'center', valign=>'bottom'}, 'class'),
               $head_columns
             );

  # loop over parametersets (just to to build sorting hashes)
  for ($i2=0; $i2<$rows2; $i2++) {
      $row2 = $result2->[$i2];

      for ($i=0; $i<20; $i++) {

          if (defined(param('date_for_parameterset_' . $row2->{'parameterset_id'})) && param('date_for_parameterset_' . $row2->{'parameterset_id'}) eq $calendar_week{$i}) {
             $sort_parametersets_by_date{$i2} = param('date_for_parameterset_' . $row2->{'parameterset_id'});
             $sort_parametersets_by_name{$i2} = $row2->{'parameterset_name'};
          }
      }
  }

  # try to get a lock
  &get_semaphore_lock($global_var_href, $user_id);

  ############################################################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start phenotyping transaction)", $sr_name . "-" . __LINE__);

  # loop over parametersets
  foreach $i2 (sort {$sort_parametersets_by_date{$a} cmp $sort_parametersets_by_date{$b} ||                                      # first sort by date
                     $sort_parametersets_by_name{$a} cmp $sort_parametersets_by_name{$b} } keys %sort_parametersets_by_date) {   # then alphabetically
      $row2 = $result2->[$i2];

      $columns = '';
      $create_orderlist = 0;

      ##########################
      # get an orderlist_id: for each parameterset, we need to open a new orderlist (list of all mice to be done at the same time for the same parameterset)
      ($orderlist_id) = $dbh->selectrow_array("select (max(orderlist_id)+1) as new_orderlist_id
                                               from   orderlists
                                              ");

      # ok, this is only neccessary for the very first orderlist when (max(orderlist_id)+1) is undefined
      if (!defined($orderlist_id)) { $orderlist_id = 1; }

      $orderlist_name = $add_orderlist_name_prefix . $line . '__' . $row2->{'parameterset_name'} . '__' . param('date_for_parameterset_' . $row2->{'parameterset_id'}) . '__' . $username;
      $date_sql = param('date_for_parameterset_' . $row2->{'parameterset_id'});
      ##########################

      ##########################
      # check if orderlist with this name already exists. If so, we use it instead creating a new orderlist
      $sql = qq(select orderlist_id
                from   orderlists
                where  orderlist_name = ?
             );

      @sql_parameters = ($orderlist_name);

      ($existing_orderlist) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      # if there is already an orderlist with this name, use it (except parameterset_class > 3)
      if (defined($existing_orderlist) && $row2->{'parameterset_class'} < 4) {
         $orderlist_id = $existing_orderlist;
      }
      ##########################


      # loop over next calendar weeks ...
      for ($i=0; $i<20; $i++) {
          # ... and set mice from @mice_for_phenotyping to orderlist in the calendar week chosen for the current parameterset
          if (defined(param('date_for_parameterset_' . $row2->{'parameterset_id'})) && param('date_for_parameterset_' . $row2->{'parameterset_id'}) eq $calendar_week{$i}) {
             $current_mouse = 0;

             # loop over mice from list
             foreach $mouse (@mice_for_phenotyping) {
                 $current_mouse++;

                 # check if current mouse already is on orderlist for current parameter for chosen week
                 # (this allows to have a mouse on an orderlist for the same parameters in different weeks)
                 (undef, $is_mouse_on_orderlist) = $dbh->selectrow_array("select orderlist_parameterset, count(m2o_mouse_id) as is_mouse_on_orderlist
                                                                          from   mice2orderlists
                                                                                 join orderlists on m2o_orderlist_id = orderlist_id
                                                                          where  m2o_mouse_id = $mouse
                                                                                 and   orderlist_parameterset = $row2->{'parameterset_id'}
                                                                                 and orderlist_date_scheduled = '$date_sql'
                                                                          group  by orderlist_parameterset
                                                                         ");
                 # no entry yet, so insert new one
                 if (!defined($is_mouse_on_orderlist)) {
                    $dbh->do("insert
                              into   mice2orderlists (m2o_mouse_id, m2o_orderlist_id, m2o_listposition, m2o_status, m2o_added_datetime)
                              values (?, ?, ?, ?, ?)
                             ", undef, $mouse, $orderlist_id, $current_mouse, '', "$datetime_sql"
                            ) or &error_message_and_exit($global_var_href, "SQL error (could not insert phenotype order)", $sr_name . "-" . __LINE__);

                    # at least one mouse on orderlist, so create this orderlist
                    $create_orderlist++;

                    $insert_message = a({-href=>"$url?choice=orderlist_view&orderlist_id=" . $orderlist_id, -title=>'view orderlist'}, 'ok');

                    &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $username . "\tadd_mouse_to_orderlist\t$orderlist_id\t$row2->{'parameterset_name'}\t$mouse\tok");
                 }
                 # mouse already is on orderlist for this parameter in this week
                 else {
                    $summary .= "Ignored: $mouse / $row2->{'parameterset_name'} " . br();

                    $insert_message = span({-title=>'all mice ignored'}, 'ign.');

                    &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $username . "\tadd_mouse_to_orderlist\t$orderlist_id\t$row2->{'parameterset_name'}\t$mouse\tignored");
                 }
             }

             $columns .= td({-bgcolor=>"red"}, $insert_message);
          }
          else {
             $columns .= td('');
          }
      }

      # at least one mouse on orderlist, so create orderlist
      if ($create_orderlist > 0) {
         # only create new orderlist if we can't use an existing one (except for parameterset_class > 3)
         if (!defined($existing_orderlist) || $existing_orderlist != $orderlist_id) {
            # create new orderlist
            $dbh->do("insert
                      into   orderlists (orderlist_id, orderlist_name, orderlist_created_by, orderlist_date_created, orderlist_job, orderlist_sampletype,
                                         orderlist_sample_amount, orderlist_date_scheduled, orderlist_assigned_user, orderlist_parameterset, orderlist_status,
                                         orderlist_comment)
                      values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                     ", undef, $orderlist_id, $orderlist_name, $user_id, "$datetime_sql", 'measure', 'mouse', 'one',
                        "$date_sql", $user_id, $row2->{'parameterset_id'}, 'ordered',
                        ''
                    ) or &error_message_and_exit($global_var_href, "SQL error (could not insert orderlist)", $sr_name . "-" . __LINE__);

            $insert_message = a({-href=>"$url?choice=orderlist_view&orderlist_id=" . $orderlist_id, -title=>'view orderlist'}, 'ok');

            &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $username . "\tcreate_orderlist\t$orderlist_id\t$row2->{'parameterset_name'}\t$date_sql");
         }
         else {
            &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $username . "\tusing_existing_orderlist\t$orderlist_id\t$row2->{'parameterset_name'}\t$date_sql");
         }
      }
      # all mice ignored, skip creating orderlist
      else {
         $insert_message = span({-title=>'all mice ignored'}, 'ign.');
      }


      $page .= Tr( {-align=>'center'},
                 th(a({-href=>"$url?choice=parameterset_view&parameterset_id=" . $row2->{'parameterset_id'},-target=>'_blank'}, $row2->{'parameterset_name'})),
                 th($parameterset_class{$row2->{'parameterset_class'}}),
                 $columns
               );
  }

  $rc = $dbh->commit or &error_message_and_exit($global_var_href, "SQL error (could not commit genotyping transaction)", $sr_name . "-" . __LINE__);

  # end of transaction
  ############################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $user_id);

  if ($summary ne '') {
     $summary = p($summary);
  }

  $page .= end_table()
           . p()
           . end_form()
           . p()
           . $summary
           . p()
           . p("All done!");

  return $page;
}
# end of phenotyping_order_4()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE009 show_mouse_phenotyping_records               show phenotyping records from a specific parameterset for a mouse
sub show_mouse_phenotyping_records {                     my $sr_name = 'SR_PHE009';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};   # session handle
  my $user_id           = $session->param('user_id');
  my $mouse_id          = param('mouse_id');
  my $parameterset_id   = param('parameterset_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($parameterset_name, $parameter_unit, $parameterset_class, $parameterset_description, $project_name, $project_shortname);
  my ($value_int, $value_float, $value_text, $value_bool, $value, $value_align);
  my %type_hash         = ('f' => 'float', 'i' => 'integer', 'c' => 'text', 'b' => 'boolean', 'd' => 'date', 't' => 'datetime');
  my @user_projects     = get_user_projects($global_var_href, $user_id);
  my $project_string    = '';
  my $error_novalue_bgcolor = '#FFFFC0';
  my @sql_parameters;

  # check input: is mouse id given? is it a number?
  if (!param('mouse_id') || param('mouse_id') !~ /^[0-9]{8}$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid mouse id"));
     return $page;
  }

  $page = h2("Phenotyping results for mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id"}, $mouse_id) . " [" . a({-href=>"$url?choice=show_mouse_phenotyping_records_overview&mouse_id=$mouse_id"}, "overview") . "]")
          . hr();

  # if function is called with valid parameterset_id, medical records belonging to this parameterset
  if (defined($parameterset_id) && (param('parameterset_id') =~ /^[0-9]+$/)) {
     # get all medical records for this mouse from chosen parameterset
     $sql = qq(select mr_id, mr_project_id, m2mr_mouse_id, mr_orderlist_id, mr_is_public, mr_parameter,
                      mr_responsible_user, mr_measure_user, mr_integer, mr_bool, mr_increment_value, mr_increment_unit,
                      mr_float, mr_text, mr_probetaken_datetime, mr_measure_datetime,
                      mr_is_outside_normal_range, mr_comment,
                      project_shortname,
                      parameterset_name,
                      parameter_id, parameter_name, parameter_shortname, parameter_type, parameter_description,
                      parameter_unit, parameter_decimals
               from   mice2medical_records
                      join medical_records    on         m2mr_mr_id = mr_id
                      join projects           on      mr_project_id = project_id
                      left join parametersets on mr_parameterset_id = parameterset_id
                      left join parameters    on       mr_parameter = parameter_id
               where           m2mr_mouse_id = ?
                      and mr_parameterset_id = ?
               order  by mr_parent_mr_group asc, parameter_id asc;
              );

     @sql_parameters = ($mouse_id, $parameterset_id);

     # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
     ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

     unless ($rows > 0) {
       $page .= p("No phenotyping results found for this mouse from chosen parameterset");
       return $page;
     }

     # else: first generate table header ...
     $page .= h3("Phenotyping records for mouse $mouse_id from parameterset \"" . $result->[0]->{'parameterset_name'} . "\"")
              . start_table( {-border=>"1", -summary=>"table"})
              . Tr( {-align=>'center'},
                  th("name"),
                  th("description"),
                  th("type"),
                  th("increment"),
                  th("value"),
                  th("unit"),
                  th("status"),
                  th({-title=>'of measurement'}, "date"),
                  th("project")
                );

     # ... then loop over all users
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         # choose the right field from 'medical_records' according to parameter definition in 'parameters'
         if ($row->{'parameter_type'} eq 'i') {
            $value_align = "right";

            if (defined($row->{'mr_integer'})) {
               $value = $row->{'mr_integer'};
            }
            else {
               $value = '[n/d]';
            }
         }
         elsif ($row->{'parameter_type'} eq 'f') {
            $value_align = "right";

            if (defined($row->{'mr_float'})) {
               $value = round_number($row->{'mr_float'}, $row->{'parameter_decimals'});
            }
            else {
               $value = '[n/d]';
            }
         }
         elsif ($row->{'parameter_type'} eq 'b') {
            $value_align = "center";

            if (defined($row->{'mr_bool'})) {
               $value = $row->{'mr_bool'};
            }
            else {
               $value = '[n/d]';
            }
         }
         elsif ($row->{'parameter_type'} eq 'c') {
            $value_align = "left";

            if (defined($row->{'mr_text'})) {
               $value = $row->{'mr_text'};
            }
            else {
               $value = '[n/d]';
            }
         }
         elsif ($row->{'parameter_type'} eq 'd') {
            $value_align = "left";

            if (defined($row->{'mr_text'})) {
               $value = $row->{'mr_text'};
            }
            else {
               $value = '[n/d]';
            }
         }
         elsif ($row->{'parameter_type'} eq 't') {
            $value_align = "left";

            if (defined($row->{'mr_text'})) {
               $value = $row->{'mr_text'};
            }
            else {
               $value = '[n/d]';
            }
         }

         # only display medical record if:
         # 1) medical record is public
         if ($row->{'mr_is_public'} eq 'y') {
             $project_string = $row->{'project_shortname'} . ' (public)';
         }

         # or
         # 2) medical record project belongs to a user's project
         elsif (is_in_list($row->{'mr_project_id'}, \@user_projects) == 1) {
             $project_string = $row->{'project_shortname'} . ' (not public)';
         }

         # otherwise do not display
         else {
            $value   = span({-class=>'red'}, '[hidden]');
            $project_string = span({-class=>'red'},  $row->{'project_shortname'} . ' (not public)');
         }

         # generate the current row
         $page .= Tr({-align=>'center', -bgcolor=>(($row->{'mr_comment'} ne 'ok')?'#FFFFC0':'white')},
                    td(b($row->{'parameter_shortname'})),
                    td($row->{'parameter_name'}),
                    td($type_hash{lc($row->{'parameter_type'})}),
                    td((defined($row->{'mr_increment_value'})?$row->{'mr_increment_value'}:'-')),
                    td({-align=>"$value_align"}, a({-href=>"$url?choice=phenotype_record_details&phenotype_record_id=" . $row->{'mr_id'}}, $value)),
                    td((defined($row->{'parameter_unit'}))?$row->{'parameter_unit'}:'n/d'),
                    td($row->{'mr_comment'}),
                    td(format_datetime2simpledate($row->{'mr_measure_datetime'})),
                    td($project_string)
                   );
     }

     $page .= end_table();
  }

  # if function is called with parameterset_id = 'none', show all medical records belonging to no orderlist/parameterset
  elsif (defined($parameterset_id) && param('parameterset_id') eq 'none') {
     # get all medical records for this mouse from chosen parameterset
     $sql = qq(select mr_id, mr_project_id, m2mr_mouse_id, mr_orderlist_id, mr_is_public, mr_parameter,
                      mr_responsible_user, mr_measure_user, mr_integer, mr_bool,
                      mr_float, mr_text, mr_probetaken_datetime, mr_measure_datetime,
                      mr_is_outside_normal_range,
                      project_shortname,
                      parameterset_name,
                      parameter_id, parameter_name, parameter_shortname, parameter_type, parameter_description,
                      parameter_unit
               from   mice2medical_records
                      join medical_records    on         m2mr_mr_id = mr_id
                      join projects           on      mr_project_id = project_id
                      left join parametersets on mr_parameterset_id = parameterset_id
                      left join parameters    on       mr_parameter = parameter_id
               where  m2mr_mouse_id = ?
                      and mr_parameterset_id IS NULL
              );

     @sql_parameters = ($mouse_id);

     # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
     ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

     unless ($rows > 0) {
       $page .= p("No phenotyping results found for this mouse from chosen parameterset");
       return $page;
     }

     # else: first generate table header ...
     $page .= h3("Phenotyping records for mouse $mouse_id from parameterset \"NO_SET\"")
              . start_table( {-border=>"1", -summary=>"table"})
              . Tr( {-align=>'center'},
                  th("name"),
                  th("description"),
                  th("type"),
                  th("value"),
                  th("unit"),
                  th("project")
                );

     # ... then loop over all records
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         # choose the right field from 'medical_records' according to parameter definition in 'parameters'
            if ($row->{'parameter_type'} eq 'i') { $value = $row->{'mr_integer'}; }
         elsif ($row->{'parameter_type'} eq 'f') { $value = $row->{'mr_float'};   }
         elsif ($row->{'parameter_type'} eq 'b') { $value = $row->{'mr_bool'};    }
         elsif ($row->{'parameter_type'} eq 'c') { $value = $row->{'mr_text'};    }
         elsif ($row->{'parameter_type'} eq 'd') { $value = $row->{'mr_text'};    }
         elsif ($row->{'parameter_type'} eq 't') { $value = $row->{'mr_text'};    }

         if (!defined($value)) { $value = '[n/d]';}

         # only display medical record if:
         # 1) medical record is public
         if ($row->{'mr_is_public'} eq 'y') {
             $project_string = $row->{'project_shortname'} . ' (public)';
         }

         # or
         # 2) medical record project belongs to a user's project
         elsif (is_in_list($row->{'mr_project_id'}, \@user_projects) == 1) {
             $project_string = $row->{'project_shortname'} . ' (not public)';
         }

         # otherwise do not display
         else {
            $value   = span({-class=>'red'}, '[hidden]');
            $project_string = span({-class=>'red'},  $row->{'project_shortname'} . ' (not public)');
         }

         # generate the current row
         $page .= Tr({-align=>'center'},
                    td(b($row->{'parameter_shortname'})),
                    td($row->{'parameter_name'}),
                    td($type_hash{lc($row->{'parameter_type'})}),
                    td(a({-href=>"$url?choice=phenotype_record_details&phenotype_record_id=" . $row->{'mr_id'}}, $value)),
                    td((defined($row->{'parameter_unit'}))?$row->{'parameter_unit'}:'n/d'),
                    td($project_string)
                   );
     }

     $page .= end_table();
  }

  return $page;

}
# end of show_mouse_phenotyping_records()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_PHE010 print_orderlist():                        print orderlist
sub print_orderlist {                                 my $sr_name = 'SR_PHE010';
  my ($global_var_href) = @_;                         # get reference to global vars hash
  my $url               = url();
  my $orderlist_id      = param('orderlist_id');
  my $orderlist_comment = param('orderlist_comment');
  my $sort_column       = param('sort_by');
  my $sort_order        = param('sort_order');
  my $dbh               = $global_var_href->{'dbh'};                # DBI database handle
  my ($page, $sql, $result, $rows, $row, $i);
  my ($current_mating, $short_comment, $orderlist_position, $check_mouse_to_add, $is_dead, $is_on_list);
  my $sex_color   = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my $datetime_sql = get_current_datetime_for_sql();
  my ($mouse_id, $parameter, $orderlist_comment_sql);
  my @parameters  = param();                                # read all CGI parameter keys
  my $message = '';
  my $j = 0;
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;
  my @selected_mice = param('mouse_select');
  my %selected_mouse;
  # hide real database column names from user (security issue): use translation hash table
  # left (key): identifier used in HTML form; right (value): database column name
  my $columns  = {'id' => 'mouse_id', 'cage' => 'cage_id', 'rack' => 'concat(location_room,location_rack)'};

  # check input: is orderlist id given? is it a number?
  if (!param('orderlist_id') || param('orderlist_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid orderlist id"));
     return $page;
  }

  # make sure a sort column is defined
  if (!param('sort_by')) {
     $sort_column = 'cage';
  }
  # raise error if invalid sort column given
  elsif (!defined($columns->{$sort_column})) {
     $page = p({-class=>"red"}, b("Error: invalid sort column $sort_column"));
     return $page;
  }

  # if sort order is given and 'desc': set it to 'desc'
  if (param('sort_order') && param('sort_order') eq 'desc') {
     $sort_order = 'desc';
  }
  # else default to 'asc'
  else {
     $sort_order = 'asc';
  }

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse_id (@selected_mice) {
     if ($mouse_id =~ /^[0-9]{8}$/) {
        $selected_mouse{$mouse_id}++;
     }
  }

  # get all mice on orderlist
  $sql = qq(select orderlist_id, orderlist_name, orderlist_created_by, orderlist_date_created, orderlist_job, orderlist_sampletype,
                   orderlist_sample_amount, orderlist_date_scheduled, orderlist_assigned_user, orderlist_parameterset, orderlist_status,
                   orderlist_comment, user_name, day_week_in_year, day_year, parameterset_name
            from   orderlists
                   join users         on         user_id = orderlist_created_by
                   left join days     on        day_date = orderlist_date_scheduled
                   join parametersets on parameterset_id = orderlist_parameterset
            where  orderlist_id = ?
           );

  @sql_parameters = ($orderlist_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sql . $sr_name . "-" . __LINE__ );

  ###############################################################
  # we dont want the usual page header with logo, but a pure printable table
  $page = header()
          . start_html(-title=>"(MausDB)", -style=>{-src=>$global_var_href->{'URL_htdoc_basedir'} . '/css/print.css', -media=>"screen, print"})
          . style({-type=>"text/css"},
                   '@page' .    ' { size: landscape; margin: 1in; }'  . "\n"
                   . '@media print{ a { display: none; } }'           . "\n"
                   . '@media print{ .noprint { display: none; } }'    . "\n"
                   . '@media print{ td { font-family:  Verdana, Helvetica, Arial, sans-serif;
                                          font-size  :  10px;
                                          font-weight : normal; } }'  . "\n"
                   . '@media print{ th { font-family:  Verdana, Helvetica, Arial, sans-serif;
                                          font-size  :  10px;
                                          font-weight : bold; } }'    . "\n"
                   . '@media print{ p  { font-family:  Verdana, Helvetica, Arial, sans-serif;
                                          font-size  :  11px;
                                          font-weight : normal; } }'  . "\n"
                   . '@media print{ b  { font-family:  Verdana, Helvetica, Arial, sans-serif;
                                          font-size  :  11px;
                                          font-weight : bold; } }'    . "\n"
                   . '@media print{ .np  { font-family:  Verdana, Helvetica, Arial, sans-serif;
                                           font-size  :  10px;
                                           font-weight : normal; } }'    . "\n"
            )
          . "\n\n";

  # if no imports found at all: tell and quit
  unless ($rows > 0) {
     $page = p("No such orderlist found");
     return $page;
  }

  $row = $result->[0];

  $page .= p()
           . table({-border=>0},
               Tr( th("Worklist: "),
                   td($row->{'orderlist_name'}),
                   th(" created by: "),
                   td($row->{'user_name'}),
                   th(" created at: "),
                   td(format_sql_datetime2display_datetime($row->{'orderlist_date_created'}))
               )
             )
           . p("Date:" . ' '  . '  ..............................................  '   . "Signature:" . ' '  . '  ..............................................................  ')
           . hr({-width=>"30%", -align=>'left'});

  # collect some details about mice on orderlist
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, location_room, location_rack, cage_id, mouse_deathorexport_datetime,
                   dr1.death_reason_name as how, dr2.death_reason_name as why
            from   mice2orderlists
                   join mice               on             m2o_mouse_id = mouse_id
                   join mouse_strains      on             mouse_strain = strain_id
                   join mouse_lines        on               mouse_line = line_id
                   join mice2cages         on                 mouse_id = m2c_mouse_id
                   join cages2locations    on              m2c_cage_id = c2l_cage_id
                   join locations          on              location_id = c2l_location_id
                   join cages              on                  cage_id = c2l_cage_id
                   join death_reasons dr1  on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2  on  mouse_deathorexport_why = dr2.death_reason_id
            where  m2o_orderlist_id = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
            order  by $columns->{$sort_column} $sort_order
           );

  @sql_parameters = ($orderlist_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if mice from orderlist cannot be found in database (should not happen): tell user and exit
  unless ($rows > 0) {
     $page .= p(b("No mice found having matching ids from your orderlist (probably all mice on that orderlist have been deleted)"))
              . end_html();

     print $page;

     exit(0);
  }

  # proceed with displaying details about mice in cart
  $page .= p(b("There " . (($rows == 1)?'is':'are' ) . " $rows " . (($rows == 1)?'mouse':'mice' ) . qq( on this orderlist)))
           . start_table( {-border=>1, -cellpadding=>2, -summary=>"table"})
           . Tr(
               th("#"),
               th("mouse ID"),
               th("sex"),
               th("born"),
               th({-class=>'noprint'}, "age"),
               th("death"),
               th("genotype"),
               th("strain"),
               th("line"),
               th("room/rack"),
               th("cage"),
               th("ear"),
               th("pathoID"),
               th("this is for notes ")
             );

  # loop over all mice in cart
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # just the line counter
     $j++;

     if (defined(param('job')) && param('job') eq 'print selected orderlist') {
        unless (defined($selected_mouse{$row->{'mouse_id'}})) {
           $j--;             # skip mouse => do not count a line
           next;
        }
     }

     # shorten comment to fit on page
     if (defined($row->{'mouse_comment'}) && $row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
     }
     elsif (!defined($row->{'mouse_comment'})) {
        $short_comment = '';
     }
     else {
        $short_comment = $row->{'mouse_comment'};
     }

     $short_comment =~ s/^'(.*)'$/$1/g;

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current line
     $page .= Tr({  -align=>'center'},
                td($j),
                td(&reformat_number($row->{'mouse_id'}, 8)),
                td($row->{'mouse_sex'}),
                td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                td({-class=>'noprint'}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                td({-title=>"$row->{'how'}, $row->{'why'}"}, format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
                td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
                td($row->{'strain_name'}),
                td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                td((!defined($row->{'mouse_deathorexport_datetime'}))                                                             # check if mouse is alive
                    ?$row->{'location_room'} . '/' . $row->{'location_rack'}
                    :'-'                                                                                                          # no: don't print cage link
                  ),
                td((!defined($row->{'mouse_deathorexport_datetime'}))                                                             # check if mouse is alive
                    ?$row->{'cage_id'}
                    :'-'                                                                                                          # no: don't print cage link
                  ),
                td($row->{'mouse_earmark'}),
                td(get_pathoID($global_var_href, $row->{'mouse_id'})),
                td('')
              );
  }

  $page .= end_table()
           . hr({-width=>"30%", -align=>'left'})
           . span( {-style=>"font-size: 8px;"}, "Printed on " . localtime())
           . p('&nbsp;') . p('&nbsp;') . p('&nbsp;') . p('&nbsp;')
           . a({-href=>"javascript:window.print()"}, "Print this orderlist")
           . p()
           . a({-href=>"javascript:window.close()"}, "close this window");

  $page .= end_html();

  # rather than returning the page to MAIN, we print $page directly to STDOUT, because
  # don't need the usual page header and tail, but a pure cage card
  print $page;

  # exit without error
  exit(0);
}
# end of print_orderlist()
#------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE011 view_phenotyping_data_1                       show phenotyping records for a selection of mice (2. step)
sub view_phenotyping_data_1 {                             my $sr_name = 'SR_PHE011';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $sql, $result, $rows, $row, $i);
  my $url                  = url();
  my @mice_to_view_phenotyping_data = ();
  my ($mouse, $sql_mouse_list);
  my $old_parameterset = "";
  my ($div_id, $time, $mouse_counter, $current_parameterset_id, $current_parameterset_name);
  my %labels;
  my @parameters = param();
  my $parameter;
  my @sql_parameters;

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_view_phenotyping_data, $mouse);
     }
  }
  # make the list SQL compatible
  $sql_mouse_list = join(',', unique_list(@mice_to_view_phenotyping_data));

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_to_view_phenotyping_data == 0) {
     $page .= h2("View phenotyping data")
              . hr()
              . h3("No mice for chosen for phenotyping")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # display form
  $page .= h2("View phenotyping data for a selection of " . (scalar @mice_to_view_phenotyping_data) . " mice")
           . hr()
           . h3("Please specify the parametersets and/or single parameters you want to see");


  #########################################################
  $sql = qq(select distinct(mr_parameter) as parameter_id, mr_parameterset_id, parameterset_name, parameter_name
            from   mice2medical_records
                   join medical_records    on         m2mr_mr_id = mr_id
                   left join parameters    on       mr_parameter = parameter_id
                   left join parametersets on mr_parameterset_id = parameterset_id
            where  m2mr_mouse_id in ($sql_mouse_list)
            order  by parameterset_display_order asc
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no cage found in this rack: tell user and exit
  unless ($rows > 0) {
    $page .= p(b("no phenotyping data records found for chosen mice"));
    return $page;
  }

  # show table if there is any phenotyping data found for selected mice
  $page .= p("for your selection of mice, the phenotyping date from the following parametersets is available:")
           . span( {-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 12px; font-weight: normal;"},
                     a({-href=>"javascript:hide_all('cage')", -style=>"text-decoration: none; display: none;",   -name=>"toggle", -id=>"hide_all", -title=>'click to collapse all'}, "(-) collapse all")
                   . a({-href=>"javascript:show_all('cage')", -style=>"text-decoration: none; display: inline;", -name=>"toggle", -id=>"show_all", -title=>'click to expand   all'}, "(+) expand all"  )
             )
           . start_form(-action=>url(), -name=>"myform")
           . hidden(-name=>'mouse_select') . "\n"

           . start_table( {-border=>"1", -summary=>"table", -cellspacing=>"1", -cellpadding=>"1", -style=>"background: #EEFFEE;"})
           . Tr( {-align=>'left', -bgcolor=>"#DDFFDD"},
               th(checkbox(-name=>"checkall3", -label=>"", -onClick=>"checkAll3(document.myform.checkall3, document.myform.parameter_select)",
                           -title=>"select/unselect all parameters from all parametersets")),
               th({-colspan=>2}, "parameterset/parameter")
             );

  # loop over all parameters found for selected mice
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                       # get reference on current result row

      if (!defined($row->{'mr_parameterset_id'})) {
         $current_parameterset_id   = 'none';
         $current_parameterset_name = 'NO_SET';
      }
      else {
         $current_parameterset_id   = $row->{'mr_parameterset_id'};
         $current_parameterset_name = $row->{'parameterset_name'};
      }

      if ($old_parameterset ne $current_parameterset_id) {   # if it is a new parameterset, generate cage summary header row in table
          $mouse_counter = 0;                     # reset cage mouse counter if cage changes

          # generate parameterset id tag for <div> elements (needed to collapse/expand cages in table view)
          $div_id = "cage_" . $current_parameterset_id;

          # generate the actual header row
          $page .= Tr(
                     td({-align=>'center', -colspan=>'3', -style=>"visibility: hidden; height: 0.2em;"}, "")
                   )
                   . Tr(
                      td(checkbox(-name=>$current_parameterset_name, -id=>$current_parameterset_name, -checked=>'0', -value=>$current_parameterset_id, -label=>'',
                                  -onClick=>"checkAll4(document.myform.$current_parameterset_name, document.myform.parameter_select, '$current_parameterset_name')",
                                  -title=>"click to select all parameters from this parameterset"
                         )
                      ),
                      td({-align=>'left', -colspan=>2},
                         a({-href=>"javascript:show('$div_id','100')", -style=>"text-decoration: none; display: inline; ", -name=>"toggle", -id=>"$div_id" . "-show", -title=>'click to expand parameterset'},   "(+) ") .
                         a({-href=>"javascript:hide('$div_id','100')", -style=>"text-decoration: none; display: none;",    -name=>"toggle", -id=>"$div_id" . "-hide", -title=>'click to collapse parameterset'}, "(-) ") .
                         b($current_parameterset_name)
                        )
                     );
      }

      # count mice in current cage
      $mouse_counter++;

      $labels{$row->{'parameter_id'}} = "";

      # generate actual row
      $page .= Tr({-align=>'left', -name=>"cage_row", -id=>"$div_id" . "-" . $mouse_counter, -style=>"display: none;"},
                 td(),
                 td(checkbox(-name=>'parameter_select', -id=>$current_parameterset_name . '_' . $mouse_counter, -checked=>'0',
                             -value=>$row->{'parameter_id'} . '_' . $current_parameterset_id,
                             -label=>''
                    )
                 ),
                 td($row->{'parameter_name'})
               );

      $old_parameterset = $current_parameterset_id;
  }

$page .= end_table()
           . p()
           . submit(-name => "choice", -value=>"view phenotyping data: next step")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel (go to previous page)"))
           . end_form();

  return $page;
}
# end of view_phenotyping_data_1()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_PHE012 view_phenotyping_data_2                      show phenotyping records for a selection of mice (2. step)
sub view_phenotyping_data_2 {                            my $sr_name = 'SR_PHE012';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};   # session handle
  my $user_id           = $session->param('user_id');
  my $username          = $session->param('username');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($mouse_id, $sql_mouse_list, $composed_parameter_id, $parameter_id, $sql_parameter_list, $sql_parameterset_list);
  my ($parameterset_name, $parameterset_id, $parameter_unit, $parameterset_class, $parameterset_description, $project_name, $project_shortname);
  my ($value_int, $value_float, $value_text, $value_bool, $value);
  my %type_hash = ('f' => 'float', 'i' => 'integer', 'c' => 'text', 'b' => 'boolean', 'd' => 'date', 't' => 'datetime');
  my @user_projects     = get_user_projects($global_var_href, $user_id);
  my $project_string = '';
  my @sql_parameters;
  my @selected_mice;
  my @mice_to_view_phenotyping_data;
  my @selected_parameters;
  my @parameter_to_view_phenotyping_data;
  my @parameterset_to_view_phenotyping_data;
  my %value_of_mouse_and_parameter;
  my %comment_of_mouse_and_parameter;
  my %all_parameters;
  my %parameter_unit;
  my ($table_mouse, $table_parameter, $table_value, $table_comment);
  my @table_parameters;
  my %sex;
  my %birth;
  my %earmark;
  my ($excel_sheet, $local_filename, $data);
  my $mouse_counter = 1;
  my @xls_row;
  my %phenotype_record_id;
  my %value_of_mouse_and_record;

  #-------------------------------------------------
  # read and check list of selected mice from CGI form
  @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse_id (@selected_mice) {
     if ($mouse_id =~ /^[0-9]{8}$/) {
        push(@mice_to_view_phenotyping_data, $mouse_id);
     }
  }
  # make the list SQL compatible
  $sql_mouse_list = join(',', unique_list(@mice_to_view_phenotyping_data));

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_to_view_phenotyping_data == 0) {
     $page .= h2("View phenotyping data")
              . hr()
              . h3("No mice for chosen for phenotyping")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }
  #-------------------------------------------------

  #-------------------------------------------------
  # read list of selected parameters from CGI form
  @selected_parameters = param('parameter_select');

  # check list of parameter ids
  foreach $composed_parameter_id (@selected_parameters) {
    ($parameter_id, $parameterset_id) = split(/_/, $composed_parameter_id);

    if ($parameter_id =~ /^[0-9]+$/) {
       push(@parameter_to_view_phenotyping_data, $parameter_id);
    }

    if ($parameterset_id =~ /^[0-9]+$/) {
       push(@parameterset_to_view_phenotyping_data, $parameterset_id);
    }
  }

  # make the lists SQL compatible
  $sql_parameter_list    = join(',', unique_list(@parameter_to_view_phenotyping_data));
  $sql_parameterset_list = join(',', unique_list(@parameterset_to_view_phenotyping_data));

  # stop if parameter list is empty (no mice selected)
  if (scalar @parameter_to_view_phenotyping_data == 0) {
     $page .= h2("View phenotyping data")
              . hr()
              . h3("No parameters chosen")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }
  #-------------------------------------------------


  $page = h2("View phenotyping data for a selection of " . (scalar @mice_to_view_phenotyping_data) . " mice")
          . start_form(-action=>url(), -name=>"myform")
          . hr();

  # get all medical records for this mouse from chosen parameterset
  $sql = qq(select m2mr_mouse_id,
                   mr_id, mr_project_id, mr_is_public, mr_parameter, mr_integer, mr_bool,mr_float, mr_text, mr_comment, mr_increment_value,
                   mouse_sex, mouse_birth_datetime, mouse_earmark,
                   project_shortname,
                   parameterset_name,
                   parameter_id, parameter_name, parameter_shortname, parameter_type, parameter_unit
            from   mice2medical_records
                   join medical_records    on         m2mr_mr_id = mr_id
                   join projects           on      mr_project_id = project_id
                   join mice               on      m2mr_mouse_id = mouse_id
                   left join parametersets on mr_parameterset_id = parameterset_id
                   left join parameters    on       mr_parameter = parameter_id
            where            m2mr_mouse_id in ($sql_mouse_list)
                   and        mr_parameter in ($sql_parameter_list)
                   and (mr_parameterset_id in ($sql_parameterset_list)
                        or
                        mr_parameterset_id IS NULL
                       )
            order by m2mr_mouse_id asc, parameterset_id, parameter_id
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__);

  unless ($rows > 0) {
    $page .= p("No phenotyping results found for this mouse from chosen parameterset");
    return $page;
  }

  # loop over all results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      # choose the right field from 'medical_records' according to parameter definition in 'parameters'
         if ($row->{'parameter_type'} eq 'i') { $value = $row->{'mr_integer'}; }
      elsif ($row->{'parameter_type'} eq 'f') { $value = $row->{'mr_float'};   }
      elsif ($row->{'parameter_type'} eq 'b') { $value = $row->{'mr_bool'};    }
      elsif ($row->{'parameter_type'} eq 'c') { $value = $row->{'mr_text'};    }
      elsif ($row->{'parameter_type'} eq 'd') { $value = $row->{'mr_text'};    }
      elsif ($row->{'parameter_type'} eq 't') { $value = $row->{'mr_text'};    }

      # no value defined? say so!
      if (!defined($value)) { $value = '[n/d]';}
      if (defined($row->{'mr_increment_value'})) { $value = '[series]';}

      # check ownership: only display medical record if:
      # 1) medical record is public
      if ($row->{'mr_is_public'} eq 'y') {
         $project_string = $row->{'project_shortname'} . ' (public)';
      }

      # or 2) medical record project belongs to a user's project
      elsif (is_in_list($row->{'mr_project_id'}, \@user_projects) == 1) {
         $project_string = $row->{'project_shortname'} . ' (not public)';
     }

     # otherwise do not display
     else {
        $value          = span({-class=>'red'}, '[hidden]');
        $project_string = '[hidden] ' . $row->{'project_shortname'} . ' (not public)';
     }

     # write value and project string to a 2-dimensional hash (build table from these hashes down below)
     $value_of_mouse_and_parameter{$row->{'m2mr_mouse_id'}}->{$row->{'parameter_shortname'}}   = $value;
     $value_of_mouse_and_record{$row->{'m2mr_mouse_id'}}->{$row->{'mr_id'}}                    = $value;
     $comment_of_mouse_and_parameter{$row->{'m2mr_mouse_id'}}->{$row->{'parameter_shortname'}} = $project_string;
     $phenotype_record_id{$row->{'m2mr_mouse_id'}}->{$row->{'parameter_shortname'}}            = $row->{'mr_id'};

     # build hashes for parameter names, parameter units, sex, birth
     $all_parameters{$row->{'parameter_shortname'}}++;
     $parameter_unit{$row->{'parameter_shortname'}} = $row->{'parameter_unit'};
     $sex{$row->{'m2mr_mouse_id'}}     = $row->{'mouse_sex'};
     $birth{$row->{'m2mr_mouse_id'}}   = $row->{'mouse_birth_datetime'};
     $earmark{$row->{'m2mr_mouse_id'}} = $row->{'mouse_earmark'};
  }

  # the list of all parameters (sorted alphabetically)
  @table_parameters = sort keys %all_parameters;

  #-------------------------------------------------
  # write HTML table
  # first row: header
  $page .= start_table( {-border=>"1", -summary=>"table"})
           . qq(<Tr>)
           . th({-bgcolor=>'#DDFFDD'}, 'mouse ID')
           . th({-bgcolor=>'#DDFFDD'}, 'sex')
           . th({-bgcolor=>'#DDFFDD'}, 'strain')
           . th({-bgcolor=>'#DDFFDD'}, 'line')
           . th({-bgcolor=>'#DDFFDD'}, 'birth')
           . th({-bgcolor=>'#DDFFDD'}, 'ear')
           . th({-bgcolor=>'#DDFFDD'}, 'genotype')
           . th({-bgcolor=>'#DDFFDD'}, 'origin');

  # write table names and units into header row
  foreach $table_parameter (@table_parameters) {
     $page .= th($table_parameter . br() . '[' . ((defined($parameter_unit{$table_parameter}))?$parameter_unit{$table_parameter}:'-') . ']');
  }

  $page .= qq(</Tr>);
  # end of header row
  #-------------------------------------------------

  #-------------------------------------------------
  # write Excel header row
  # check if data has to be exported to Excel
  if (defined(param('job')) && param('job') eq 'Export phenotyping data to Excel') {
     # include a module to write tables as Excel file in a simple way
     use Spreadsheet::WriteExcel::Simple;

     # create a new excel sheet object
     $excel_sheet = Spreadsheet::WriteExcel::Simple->new;

     # create a unique filename (using combination of user name and time) for server-side storage of temporary Excel file
     $local_filename = $username . '_' . time() . '.xls';

     #-----------------------------------
     # generate parameter name header row
     @xls_row = ('number', 'mouse id', 'sex', 'strain', 'line', 'birth', 'ear', 'origin');

     foreach $table_parameter (@table_parameters) {
        push(@xls_row, $table_parameter);
     }

     push(@xls_row, 'genotype');

     # write header line to Excel file
     $excel_sheet->write_row(\@xls_row);
     #-----------------------------------

     #-----------------------------------
     @xls_row = ('', '', '', '', '', '', '', '');

     # generate parameter name header row
     foreach $table_parameter (@table_parameters) {
        push(@xls_row, ((defined($parameter_unit{$table_parameter}))?$parameter_unit{$table_parameter}:'-'));
     }

     # write header line to Excel file
     $excel_sheet->write_row(\@xls_row);
     #-----------------------------------
  }
  #-------------------------------------------------


  foreach $table_mouse (keys %value_of_mouse_and_parameter) {
     #------------------------------------------
     # write data line for current mouse in HTML
     $page .= qq(<Tr>)
              . th({-bgcolor=>'#DDFFDD'}, a({-href=>"$url?choice=mouse_details&mouse_id=$table_mouse"}, $table_mouse))
              . th({-bgcolor=>'#DDFFDD'}, $sex{$table_mouse})
              . th({-bgcolor=>'#DDFFDD'}, get_strain_name_by_id($global_var_href, get_strain($global_var_href, $table_mouse)))
              . th({-bgcolor=>'#DDFFDD'}, get_line_name_by_id($global_var_href, get_line($global_var_href, $table_mouse)))
              . th({-bgcolor=>'#DDFFDD'}, format_datetime2simpledate($birth{$table_mouse}))
              . th({-bgcolor=>'#DDFFDD'}, $earmark{$table_mouse})
              . th({-bgcolor=>'#DDFFDD'}, get_all_genotypes_in_one_line($global_var_href, $table_mouse))
              . th({-bgcolor=>'#DDFFDD'}, get_origin_type($global_var_href, $table_mouse));

     foreach $table_parameter (@table_parameters) {
        if (defined($value_of_mouse_and_parameter{$table_mouse}->{$table_parameter})) {
           $table_value = a({-href=>"$url?choice=phenotype_record_details&phenotype_record_id=" . $phenotype_record_id{$table_mouse}->{$table_parameter}},
                            $value_of_mouse_and_parameter{$table_mouse}->{$table_parameter}
                          );
        }
        else {
           $table_value = '[n/a]';
        }

        if (defined($comment_of_mouse_and_parameter{$table_mouse}->{$table_parameter})) {
           $table_comment = $comment_of_mouse_and_parameter{$table_mouse}->{$table_parameter};
        }
        else {
           $table_comment = '[n/a]';
        }

        $page .= td({-title=>$table_comment}, $table_value);
     }

     $page .= qq(</Tr>);
     #------------------------------------------

     #------------------------------------------
     # if export to excel was requested, in addition to generate table row for display in HTML also generate row for Excel
     if (defined(param('job')) && param('job') eq 'Export phenotyping data to Excel') {
        @xls_row = (($mouse_counter++),
                    $table_mouse,
                    $sex{$table_mouse},
                    get_strain_name_by_id($global_var_href, get_strain($global_var_href, $table_mouse)),
                    get_line_name_by_id($global_var_href, get_line($global_var_href, $table_mouse)),
                    format_datetime2simpledate($birth{$table_mouse}),
                    $earmark{$table_mouse},
                    get_origin_type($global_var_href, $table_mouse)
                   );

        foreach $table_parameter (@table_parameters) {
           if (defined($value_of_mouse_and_parameter{$table_mouse}->{$table_parameter})) {
              $table_value = $value_of_mouse_and_parameter{$table_mouse}->{$table_parameter};

              if ($table_value =~ /\[hidden\]/) {
                 $table_value = '[hidden]';
              }
           }
           else {
              $table_value = '[n/a]';
           }

           push(@xls_row, $table_value);
        }

        push(@xls_row, get_all_genotypes_in_one_line($global_var_href, $table_mouse));

        # write current row to Excel object
        $excel_sheet->write_row(\@xls_row);
     }
     #------------------------------------------
  }

  #------------------------------------------
  # if export to excel was requested, write the Excel file to the temp folder and send it to the client  ...
  if (defined(param('job')) && param('job') eq 'Export phenotyping data to Excel') {
     # ... save Excel object to local Excel file
     $excel_sheet->save("./files/$local_filename");

     # now send the just-saved Excel file to browser
     # print the html header with correct MIME-type, so that client browser knows what to do with this content (and hopefully offers to open with Excel)
     print header(-Content_disposition => "attachment; filename=$local_filename",
                  -type => 'application/vnd.ms-excel');

     # open local Excel file for read
     open (XLS, "< ./files/$local_filename") or &error_message_and_exit($global_var_href, "Could not generate Excel file", "");

     # write Excel file in binary mode to STDOUT
     binmode XLS;
     binmode STDOUT;

     while(read(XLS, $data, 1024)) {
        print $data;
     }

     close(XLS);
  }
  #------------------------------------------

  $page .= end_table()
           . p()
           . hidden('mouse_select')
           . hidden('parameter_select')
           . hidden('choice')
           . submit(-name=>"job", -value=>"Export phenotyping data to Excel")
           . end_form();

  return ($page);
}
# end of view_phenotyping_data_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_PHE013 show_phenotype_record_details                show phenotype record details
sub show_phenotype_record_details {                      my $sr_name = 'SR_PHE013';
  my ($global_var_href)    = @_;                         # get reference to global vars hash
  my $session              = $global_var_href->{'session'};           # get session handle
  my $user_id              = $session->param('user_id');
  my @user_projects        = get_user_projects($global_var_href, $user_id);
  my ($value, $project_string);
  my $phenotype_record_id  = param('phenotype_record_id');
  my $url                  = url();
  my $sex_color            = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my $parameter_types      = {'m' => 'media', 'f' => 'float', 'i' => 'integer', 'b' => 'bool', 'c' => 'text', 'd' => 'date', 't' => 'datetime'};
  my ($page, $sql, $result, $rows, $row, $i);
  my $offer_blob_link      = '';
  my $blob_id;
  my @sql_parameters;

  $page .= h2('Phenotype record details')
           . hr();

  # check input: is phenotype_record_id given? is it a number?
  if (!param('phenotype_record_id') || param('phenotype_record_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid phenotype record id"));
     return $page;
  }

  # get all about this phenotype record
  $sql = qq(select m2mr_mouse_id,
                   mr_probetaken_datetime, mr_measure_datetime, mr_is_public, mr_comment, mr_orderlist_id,
                   mr_id, mr_integer, mr_float, mr_bool, mr_text, mr_increment_value, mr_increment_unit,
                   project_id, project_shortname,
                   parameter_id, parameter_shortname, parameter_type,
                   parameterset_id, parameterset_name,
                   orderlist_id, orderlist_name,
                   u1.user_name as responsible_user_name, u1.user_id as responsible_user_id,
                   u2.user_name as measure_user_name,     u1.user_id as measure_user_id
            from   medical_records
                   join mice2medical_records on          m2mr_mr_id = mr_id
                   left join projects        on       mr_project_id = project_id
                   left join parameters      on        mr_parameter = parameter_id
                   left join parametersets   on  mr_parameterset_id = parameterset_id
                   left join orderlists      on     mr_orderlist_id = orderlist_id
                   left join users u1        on mr_responsible_user = u1.user_id
                   left join users u2        on     mr_measure_user = u2.user_id
            where  mr_id = ?
           );

  @sql_parameters = ($phenotype_record_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("No details on phenotype record $phenotype_record_id");
     return $page;
  }

  # else continue: get result handle and display table
  $row = $result->[0];

  #--------------------------------------
  # check ownership of phenotyping record

  # choose the right field from 'medical_records' according to parameter definition in 'parameters'
     if ($row->{'parameter_type'} eq 'i') { $value = $row->{'mr_integer'}; }
  elsif ($row->{'parameter_type'} eq 'f') { $value = $row->{'mr_float'};   }
  elsif ($row->{'parameter_type'} eq 'b') { $value = $row->{'mr_bool'};    }
  elsif ($row->{'parameter_type'} eq 'c') { $value = $row->{'mr_text'};    }
  elsif ($row->{'parameter_type'} eq 'd') { $value = $row->{'mr_text'};    }
  elsif ($row->{'parameter_type'} eq 't') { $value = $row->{'mr_text'};    }

  if (!defined($value)) {
     $value = '[n/d]';
  }

  if ($row->{'parameter_type'} eq 'b' && $row->{'mr_bool'} == 1) {
     $blob_id = get_blob_by_mr_id($global_var_href, $row->{'mr_id'});

     if (defined($blob_id)) {
        $offer_blob_link = br() . '(Download file by clicking ' . a({-href=>"$url?choice=download_file&file=$blob_id"}, "here") . ')';
     }
     else {
        $offer_blob_link = br() . '(no file found)'
     }
  }
  else {
     $offer_blob_link = '';
  }

  # only display medical record if:
  # 1) medical record is public
  if ($row->{'mr_is_public'} eq 'y') {
      $project_string = $row->{'project_shortname'} . ' (public)';
  }

  # or
  # 2) medical record project belongs to a user's project
  elsif (is_in_list($row->{'project_id'}, \@user_projects) == 1) {
      $project_string = $row->{'project_shortname'} . ' (not public)';
  }

  # otherwise do not display
  else {
     $value   = span({-class=>'red'}, '[hidden]');
     $project_string = $row->{'project_shortname'} . ' (not public)';
     $offer_blob_link = '';
  }
  #--------------------------------------


  $page .= h3('Details for phenotype record ' . $phenotype_record_id)
           . table( {-border=>1, -summary=>"table", -bgcolor=>'#DDFFFF'},
               Tr(
                 th("Phenotype record id"),
                 td({-align=>'center'}, $phenotype_record_id)
               ),
               Tr(
                 th("Mouse"),
                 td({-align=>'center'}, b($row->{'m2mr_mouse_id'})
                                        . br()
                                        . a({-href=>"$url?choice=mouse_details&mouse_id=" . $row->{'m2mr_mouse_id'}}, 'mouse details')
                                        . br()
                                        . a({-href=>"$url?choice=show_mouse_phenotyping_records_overview&mouse_id=" . $row->{'m2mr_mouse_id'}}, 'all phenotype records')
                 )
               ),
               Tr(
                 th("Project"),
                 td({-align=>'center'}, $row->{'project_shortname'})
               ),
               Tr(
                 th("is public"),
                 td({-align=>'center'}, $row->{'mr_is_public'})
               ),
               Tr(
                 th("Parameter"),
                 td({-align=>'center'}, $row->{'parameter_shortname'} . ' (ID:' . $row->{'parameter_id'} . ')')
               ),
               Tr(
                 th("Parameterset"),
                 td({-align=>'center'}, defined($row->{'parameterset_name'})?$row->{'parameterset_name'} . ' (ID:' . $row->{'parameterset_id'} . ')':'NO SET')
               ),
               Tr(
                 th("Parameter type "),
                 td({-align=>'center'}, $parameter_types->{$row->{'parameter_type'}})
               ),
               Tr(
                 th("Serial/Simple"),
                 td({-align=>'center'}, defined($row->{'mr_increment_value'})?"Serial [increment: $row->{'mr_increment_value'} $row->{'mr_increment_unit'}]":'Simple')
               ),
               Tr(
                 th("Value "),
                 td({-align=>'center', -title=>$project_string, -bgcolor=>(($value eq '[n/d]')?'#FFFFC0':'#DDFFFF')}, $value . $offer_blob_link)
               ),
               ((get_mice_of_medical_record($global_var_href, $phenotype_record_id) > 1)
                ?Tr(
                   th("Extras "),
                   td({-align=>'center'}, "This is a " . a({-href=>"$url?choice=view_mice_of_mr&mr_id=" . $phenotype_record_id}, "multi-mouse") . " medical record. ")
                 )
                :''
               ),
               Tr(
                 th("orderlist"),
                 td({-align=>'center'}, (defined($row->{'mr_orderlist_id'})?a({-href=>"$url?choice=orderlist_view&orderlist_id=" . $row->{'mr_orderlist_id'}}, $row->{'orderlist_name'}):'no orderlist') )
               ),
               Tr(
                 th("Probe taken"),
                 td({-align=>'center'}, format_sql_datetime2display_datetime($row->{'mr_probetaken_datetime'}))
               ),
               Tr(
                 th("Measured"),
                 td({-align=>'center'}, format_sql_datetime2display_datetime($row->{'mr_measure_datetime'}))
               ),
               Tr(
                 th("Measure user"),
                 td({-align=>'center'}, (defined($row->{'measure_user_name'})?a({-href=>"$url?choice=user_details&user_id=" . $row->{'measure_user_id'}}, $row->{'measure_user_name'}):'[n/a]'))
               ),
               Tr(
                 th("Responsible user"),
                 td({-align=>'center'}, (defined($row->{'responsible_user_name'})?a({-href=>"$url?choice=user_details&user_id=" . $row->{'responsible_user_id'}}, $row->{'responsible_user_name'}):'[n/a]'))
               ),
               Tr(
                 th("Status"),
                 td({-align=>'center', -bgcolor=>(($value eq '[n/d]')?'#FFFFC0':'#DDFFFF')}, (defined($row->{'mr_comment'})?$row->{'mr_comment'}:''))
               )
             )
           . end_table();

  return $page;
}
# end of show_phenotype_record_details
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_PHE014 enter_or_edit_mouse_phenotyping_records     enter or edit mouse phenotyping records
sub enter_or_edit_mouse_phenotyping_records {           my $sr_name = 'SR_PHE014';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};   # session handle
  my $user_id           = $session->param('user_id');
  my $mouse_id          = param('mouse_id');
  my $parameterset      = param('parameterset_id');
  my $orderlist_id      = param('orderlist_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($sql2, $result2, $rows2, $row2, $i2);
  my ($parameterset_name, $parameter_unit, $parameterset_class, $parameterset_description, $project_name, $project_shortname);
  my ($value_int, $value_float, $value_text, $value_bool, $value, $default, $comment, $multiple_entries, $mr_id);
  my %parameter_type    = ('b' => 'boolean', 'f' => 'float', 'i' => 'integer', 'l' => 'list', 'p' => 'picture', 'c' => 'text', 'd' => 'date', 't' => 'datetime');
  my %radio_labels      = ('y' => 'yes', 'n' => 'no');
  my @user_projects     = get_user_projects($global_var_href, $user_id);
  my $project_string    = '';
  my @sql_parameters;
  my $input_field;

  # check input: is mouse id given? is it a number?
  if (!param('mouse_id') || param('mouse_id') !~ /^[0-9]{8}$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid mouse id"));
     return $page;
  }

  # get total number of mice in database
  $sql = qq(select parameterset_name
            from   parametersets
            where  parameterset_id = ?
           );

  @sql_parameters = ($parameterset);

  ($parameterset_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $page = h2("Enter or edit phenotyping results for mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id"}, $mouse_id))
          . start_form(-action => url())
          . hidden('mouse_id')
          . hidden('parameterset_id')
          . hidden('orderlist_id')
          . hr();

  $sql = qq(select parameter_id, parameter_name, parameter_shortname, parameter_description, parameter_unit,
                   parameter_type, parameter_default, parameter_normal_range,
                   parameterset_name
            from   parametersets2parameters
                   join parameters    on p2p_parameter_id = parameter_id
                   join parametersets on p2p_parameterset_id = parameterset_id
            where  p2p_parameterset_id = ?
            order  by p2p_display_row asc, p2p_display_column asc
           );

  @sql_parameters = ($parameterset);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no imports found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No parameters in this parameter set");
     return $page;
  }

  # else continue: display imports table
  $page .= h3("Parameters belonging to parameter set " . qq("$parameterset_name"))
           . start_table( {-border=>"1", -summary=>"experiment_overview"})
           . Tr( {-align=>'center'},
               th("name"),
               th("description"),
               th("value"),
               th("unit"),
               th("comment")
             );

  # ... loop over all
  for ($i=0; $i<$rows; $i++) {               # $rows is the number of racks returned from the above query
      $row = $result->[$i];                  # get a reference on the current result row

      $default = '';
      $comment = '';
      $multiple_entries = '';

      # read existing values as default
      $sql2 = qq(select mr_id, mr_parameter, mr_integer, mr_bool, mr_float, mr_text, parameter_type
                 from   mice2medical_records
                        join medical_records on m2mr_mr_id = mr_id
                        join parameters      on mr_parameter = parameter_id
                 where     m2mr_mouse_id = ?
                        and mr_parameter = ?
              );

      @sql_parameters = ($mouse_id, $row->{'parameter_id'});

      ($result2, $rows2) = &do_multi_result_sql_query2($global_var_href, $sql2, \@sql_parameters, $sr_name . "-" . __LINE__ );

      if ($rows2 == 0) {
         $comment = span({-class=>'red'}, "no entry in database");

         $mr_id = 'none';
      }
      elsif ($rows2 == 1) {
         $row2 = $result2->[0];

            if ($row2->{'parameter_type'} eq 'i') { $default = $row2->{'mr_integer'}; }
         elsif ($row2->{'parameter_type'} eq 'f') { $default = $row2->{'mr_float'};   }
         elsif ($row2->{'parameter_type'} eq 'b') { $default = $row2->{'mr_bool'};    }
         elsif ($row2->{'parameter_type'} eq 'c') { $default = $row2->{'mr_text'};    }
         elsif ($row2->{'parameter_type'} eq 'd') { $default = $row2->{'mr_text'};    }
         elsif ($row2->{'parameter_type'} eq 't') { $default = $row2->{'mr_text'};    }

         $mr_id = $row2->{'mr_id'};
      }
      elsif ($rows2 > 1) {
         for ($i2=0; $i2<$rows2; $i2++) {
             $row2 = $result2->[$i2];

                if ($row2->{'parameter_type'} eq 'i') { $value = $row2->{'mr_integer'}; }
             elsif ($row2->{'parameter_type'} eq 'f') { $value = $row2->{'mr_float'};   }
             elsif ($row2->{'parameter_type'} eq 'b') { $value = $row2->{'mr_bool'};    }
             elsif ($row2->{'parameter_type'} eq 'c') { $value = $row2->{'mr_text'};    }
             elsif ($row2->{'parameter_type'} eq 'd') { $value = $row2->{'mr_text'};    }
             elsif ($row2->{'parameter_type'} eq 't') { $value = $row2->{'mr_text'};    }

             $multiple_entries .= a({-href=>"$url?choice=phenotype_record_details&phenotype_record_id=" . $row2->{'mr_id'}}, $value) . br();
         }

         $mr_id = 'none';

         $comment = span({-class=>'red'}, "multiple entries, click to edit on detail view");
      }

      # depending on parameter type, choose input format
      if ($row->{'parameter_type'} eq 'c') {
         $input_field = textarea(-name => "parameter_" . $row->{'parameter_id'}, -columns=>"40", -rows=>"2", -override=>"1", -default=>$default, -title=>"");
      }
      elsif ($row->{'parameter_type'} eq 'f' || $row->{'parameter_type'} eq 'i') {
         $input_field = textfield(-name => "parameter_" . $row->{'parameter_id'}, -size=>"40", -maxlength=>"40", -default=>$default, -title=>"");
      }
      elsif ($row->{'parameter_type'} eq 'b') {
         $input_field = radio_group(-name => "parameter_" . $row->{'parameter_id'}, -values=>['y', 'n'], -default=>$default, -labels=>\%radio_labels);
      }

      if ($multiple_entries ne '') {
         $input_field = $multiple_entries;
      }

      $page .= Tr({-align=>'center'},
                 td(defined($row->{'parameter_shortname'})?b($row->{'parameter_shortname'}):'-'),
                 td(defined($row->{'parameter_name'})?b($row->{'parameter_name'}):'-'),
                 td({-align=>'left', -bgcolor=>'lightblue'}, $input_field),
                 td(defined($row->{'parameter_unit'})?$row->{'parameter_unit'}:'-'),
                 td($comment)
               )
               . hidden(-name=>"mr_of_parameter_" . $row->{'parameter_id'}, -value=>$mr_id);
  }

  $page .= end_table()
           . p()
           . submit(-name => "choice", -value=>"update records")
           . end_form();

  return $page;

}
# end of enter_or_edit_mouse_phenotyping_records()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE015 parametersets_overview():                    parametersets overview
sub parametersets_overview {                             my $sr_name = 'SR_PHE015';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  $page = h2("Parametersets overview "
             . ((current_user_is_admin($global_var_href) eq 'y')                                       # check user for being admin
                ?"&nbsp;&nbsp; [" . a({-href=>"$url?choice=new_parameterset"}, "create new parameterset") . "]"
                :''                                                                                    # display non-admin content
               )
          )
          . hr();

  $sql = qq(select parameterset_id, parameterset_name, parameterset_project_id, parameterset_description, parameterset_class, parameterset_is_active,
                   project_id, project_shortname, count(mr_id) as number_mrs
            from   parametersets
                   left join projects        on         project_id = parameterset_project_id
                   left join medical_records on mr_parameterset_id = parameterset_id
            group  by parameterset_id
            order  by parameterset_class asc, parameterset_name asc
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no cost accounts found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No parametersets defined");
     return $page;
  }

  # else continue: display imports table
  $page .= start_table( {-border=>"1", -summary=>"parametersets_overview"})
          . Tr( {-align=>'center'},
              th('#'),
              th("parameterset"),
              th("description"),
              th("screen/project"),
              th("class"),
              th("is active"),
              th("# records")
            );

  # ... loop over all imports
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td(a({-href=>"$url?choice=parameterset_view&parameterset_id=" . $row->{'parameterset_id'}}, $row->{'parameterset_name'})),
                 td($row->{'parameterset_description'}),
                 td($row->{'project_shortname'}),
                 td($row->{'parameterset_class'}),
                 td($row->{'parameterset_is_active'}),
                 td({-align=>'right'}, $row->{'number_mrs'})
               );
  }

  $page .= end_table();

  return $page;
}
# end of parametersets_overview()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_PHE016 insert_global_metadata_1():                  insert_global_metadata (step 1: form)
sub insert_global_metadata_1 {                           my $sr_name = 'SR_PHE016';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  $page = h2("Global metadata ")
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select mdd_id, mdd_name, mdd_shortname
            from   metadata_definitions
            where  mdd_global_yn = ?
            order  by mdd_shortname asc
           );

  @sql_parameters = ('y');

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no global metadata found, tell and quit
  unless ($rows > 0) {
    $page .= p("No global metadata definitions found.");
    return $page;
  }

  # else: first generate table header ...
  $page .= h3("$rows global metadata definitions found")
           . p("Click one of the entries in the table below if you want to enter global metadata")
           . start_table( {-border=>"1", -summary=>"blob_overview"})
           . Tr( {-align=>'left'},
               td(b('#')),
               td(b('name')),
               td(b('short name'))
             );

  # ... then loop over all result sets
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      # generate the current row
      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td({-align=>'left'}, a({-href=>"$url?choice=insert_global_metadata_2&mdd_id=" . $row->{'mdd_id'}}, "$row->{'mdd_name'}")),
                 td($row->{'mdd_shortname'} )
               );
  }

  $page .= end_table();

  return $page;
}
# end of insert_global_metadata_1()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_PHE017 insert_global_metadata_2():                  insert_global_metadata (step 2: specific input form)
sub insert_global_metadata_2 {                           my $sr_name = 'SR_PHE017';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $mdd_id            = param('mdd_id');
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;
  my @possible_values;
  my $input_field;

  # check input: is mdd id given? is it a number?
  if (!param('mdd_id') || param('mdd_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid metadata definition id"));
     return $page;
  }

  $page = h2("Global metadata ")
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select mdd_id, mdd_name, mdd_shortname, mdd_possible_values, mdd_default
            from   metadata_definitions
            where  mdd_global_yn = ?
                   and    mdd_id = ?
           );

  @sql_parameters = ('y', $mdd_id);

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no global metadata found, tell and quit
  unless ($rows > 0) {
    $page .= p("No such global metadata definition found.");
    return $page;
  }

  # else: first generate table header ...
  $row = $result->[0];

  # print the default value or let choose from stored possibilites
  if (defined($row->{'mdd_possible_values'})) {
     @possible_values = split(/;/, $row->{'mdd_possible_values'});

     $input_field = popup_menu( -name    => 'metadata_value',
                                -values  => [@possible_values],
                                -default => $row->{'mdd_default'}
                              );
  }
  else {
     $input_field = textfield(-name => 'metadata_value', -size=>"50", -maxlength=>'255', -default=>$row->{'mdd_default'});
  }

  $page .= h3("$row->{'mdd_name'}")
           . p("Please enter metadata for $row->{'mdd_name'}")
           . start_form(-action => url())

           . hidden('mdd_id')
           . hidden(-name=>'mdd_name', -value=>$row->{'mdd_name'})

           . start_table( {-border=>"1", -summary=>"blob_overview"})
           . Tr(
               td(b('name')),
               td($row->{'mdd_name'})
             )
           . Tr(
               td(b('short name')),
               td($row->{'mdd_shortname'})
             )
           . Tr(
               td(b('metadata value')),
               td($input_field)
             )
           . Tr(
               td(b('metadata valid from')),
               td(textfield(-name => "metadata_valid_from", -id=>"metadata_valid_from", -size=>"20", -maxlength=>"21", -value=>get_current_datetime_for_display())
                  . "&nbsp;&nbsp;"
                  . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=metadata_valid_from', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
               )
             )
           . Tr(
               td(b('metadata valid to')),
               td(textfield(-name => "metadata_valid_to",   -id=>"metadata_valid_to",   -size=>"20", -maxlength=>"21", -value=>get_current_datetime_for_display())
                  . "&nbsp;&nbsp;"
                  . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=metadata_valid_to',   480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
               )
             )
           . end_table()

           . br()

           . submit(-name=>"choice", -value=>"store metadata!")

           . end_form();

  return $page;
}
# end of insert_global_metadata_2()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE018 insert_global_metadata_3():                  insert_global_metadata (step 3: database transaction)
sub insert_global_metadata_3 {                           my $sr_name = 'SR_PHE018';
  my ($global_var_href)   = @_;                          # get reference to global vars hash
  my $session             = $global_var_href->{'session'};            # get session handle
  my $user_id             = $session->param(-name=>'user_id');
  my $username            = $session->param('username');
  my $dbh                 = $global_var_href->{'dbh'};   # DBI database handle
  my $url                 = url();
  my $mdd_id              = param('mdd_id');
  my $mdd_name            = param('mdd_name');
  my $the_value           = param('metadata_value');
  my $metadata_valid_from = param('metadata_valid_from');
  my $metadata_valid_to   = param('metadata_valid_to');
  my $datetime_sql        = get_current_datetime_for_sql();
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my @sql_parameters;
  my ($new_metadata_id);

  # check input: is mdd id given? is it a number?
  if (!param('mdd_id') || param('mdd_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid metadata definition id"));
     return $page;
  }

  # valid from date not given or invalid
  if (!param('metadata_valid_from') || check_datetime_ddmmyyyy_hhmmss(param('metadata_valid_from')) != 1) {
     $page .= p({-class=>"red"}, b("Error: valid-from date/time not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # valid to date not given or invalid
  if (!param('metadata_valid_to') || check_datetime_ddmmyyyy_hhmmss(param('metadata_valid_to')) != 1) {
     $page .= p({-class=>"red"}, b("Error: valid-to date/time not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  $page = h2("Global metadata ")
          . hr();

  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start insert/update metadata transaction)", $sr_name . "-" . __LINE__);

  # get an insert metadata_id
  ($new_metadata_id) = $dbh->selectrow_array("select (max(metadata_id)+1) as new_metadata_id
                                              from   metadata
                                             ");

  # ok, this is only neccessary for the very first metadata_id when (max(metadata_id)+1) is undefined
  if (!defined($new_metadata_id)) { $new_metadata_id = 1; }

  $dbh->do("insert
            into   metadata (metadata_id, metadata_mdd_id, metadata_value, metadata_orderlist_id,
                             metadata_medical_record_id, metadata_mouse_id, metadata_parameterset_id,
                             metadata_valid_datetime_from, metadata_valid_datetime_to)
            values (?, ?, ?, NULL, NULL, NULL, NULL, ?, ?)
           ", undef, $new_metadata_id, $mdd_id, $the_value, format_display_datetime2sql_datetime($metadata_valid_from), format_display_datetime2sql_datetime($metadata_valid_to)
        ) or &error_message_and_exit($global_var_href, "SQL error (could not write metadata to database)", $sr_name . "-" . __LINE__);

  &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $username . "\tinserted_global_metadata\t$mdd_name\t$the_value\tfrom\t$metadata_valid_from\tto\t$metadata_valid_to");

  $page .= p('Metadata stored!');

  $rc = $dbh->commit or &error_message_and_exit($global_var_href, "SQL error (could not commit insert/update metadata transaction)", $sr_name . "-" . __LINE__);

  return $page;
}
# end of insert_global_metadata_3()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_PHE019 parameters_overview():                       parameters overview
sub parameters_overview {                                my $sr_name = 'SR_PHE019';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $session           = $global_var_href->{'session'};           # get session handle
  my $dbh               = $global_var_href->{'dbh'};               # DBI database handle
  my $user_id           = $session->param('user_id');
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my @sql_parameters;
  my $sort_column  = param('sort_by');
  my $columns  = {'parameter'  => 'parameter_name',
                  'id'         => 'parameter_id',
                  'shortname'  => 'parameter_shortname',
                  'mrs'        => 'number_mrs'
                 };
  my $message = '';
  my ($number_mrs, $number_sets, $parameter_name);

  # make sure a sort column is defined
  if (!param('sort_by')) {
     $sort_column = 'parameter';
  }
  # raise error if invalid sort column given
  elsif (!defined($columns->{$sort_column})) {
     $page = p({-class=>"red"}, b("Error: invalid sort column: \"$sort_column\""));
     return $page;
  }


  #####################################################################
  # delete parameter if requested
  if (param('choice') eq "delete_parameter") {

     $parameter_name = get_parameter_name_by_id($global_var_href, param('parameter_id'));

     ########################################
     # if user does not have an admin role, reject
     if (current_user_is_admin($global_var_href) eq 'n') {
        $page = h2("Delete parameter \"$parameter_name\"")
                . hr()
                . h3("Sorry, you don't have admin rights. Please contact the administrator.");

        return ($page);
     }

     # check if parameter id given
     if (!defined(param('parameter_id')) || param('parameter_id') !~ /^[0-9]+$/) {
        $page = h2("Delete parameter \"$parameter_name\"")
                . hr()
                . p({-class=>"red"}, b("Error: parameter not given or invalid! "))
                . p(a({-href=>"javascript:back()"}, "go back and try again"));

        return ($page);
     }
     ########################################

     ########################################
     # delete parameter if 1) there are no medical records for this parameter and 2) parameter is not part of a parameterset

     &get_semaphore_lock($global_var_href, $user_id);       # try to get a lock

     ###################
     # begin transaction
     $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start delete parameter transaction)", $sr_name . "-" . __LINE__);

     # get number of medical records for this parameter
     $sql = qq(select count(mr_id) as number_mrs
               from   medical_records
               where  mr_parameter  = ?
            );

     @sql_parameters = (param('parameter_id'));

     ($number_mrs) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

     # get number of parametersets with this parameter
     $sql = qq(select count(p2p_parameterset_id) as number_sets
               from   parametersets2parameters
               where  p2p_parameter_id  = ?
            );

     @sql_parameters = (param('parameter_id'));

     ($number_sets) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

     # rollback if 1) there are medical records for this parameter or 2) parameter is part of a parameterset
     if ($number_mrs > 0 || $number_sets > 0) {

        $rc = $dbh->rollback() or &error_message_and_exit($global_var_href,"SQL error (could not roll back delete parameter transaction)", $sr_name . "-" . __LINE__);
        &release_semaphore_lock($global_var_href, $user_id);
        $page .= h2("Delete parameter \"$parameter_name\"")
                 . hr()
                 . p({-class=>"red"}, b("Error: parameter not deleted (there are medical records for this parameter and/or parameter is part of a parameterset)! "));

        return $page;
     }

     # delete ...
     $dbh->do("delete
               from   parameters
               where  parameter_id = ?
              ", undef, param('parameter_id')
           ) or &error_message_and_exit($global_var_href, "SQL error (could not delete parameter)", $sr_name . "-" . __LINE__);

     $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);
     # end transaction
     #################

     &release_semaphore_lock($global_var_href, $user_id);     # release lock

     # show transaction message
     $message .= p({-class=>'red'}, "parameter \"$parameter_name\" (ID: " . param('parameter_id') . ") deleted!")
                 . hr();
  }
  # end of delete parameter
  #####################################################################


  $page = h2("Parameters overview "
             . a({-href=>"$url?choice=parameters_overview", -title=>'reload page'},
                    img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
               )
             . ((current_user_is_admin($global_var_href) eq 'y')                                       # check user for being admin
                ?"&nbsp;&nbsp; [" . a({-href=>"$url?choice=new_parameter"}, "create new parameter") . "]"
                :''                                                                                    # display non-admin content
               )
          )
          . hr()
          . $message;

  $sql = qq(select parameter_id, parameter_name, parameter_shortname, parameter_is_metadata, count(mr_id) as number_mrs
            from   parameters
                   left join medical_records on parameter_id = mr_parameter
            group  by parameter_id
            order  by $columns->{$sort_column} asc
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no parameters found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No parameters defined");
     return $page;
  }

  # else continue: display parameters table
  $page .= start_form(-action => url())
          . p("Re-sort table by clicking on headers")
          . start_table( {-border=>"1", -summary=>"parameters_overview"})
          . Tr( {-align=>'left'},
              th("#"),
              th("select"),
              th("delete"),
              th(a({-href=>"$url?choice=parameters_overview&sort_by=parameter", -title=>"click to sort by parameter name"},            "parameter name")),
              th(a({-href=>"$url?choice=parameters_overview&sort_by=shortname", -title=>"click to sort by parameter short name"},      "parameter short name")),
              th(a({-href=>"$url?choice=parameters_overview&sort_by=id",        -title=>"click to sort by parameter id"},              "ID")),
              th("metadata?"),
              th(a({-href=>"$url?choice=parameters_overview&sort_by=mrs",       -title=>"click to sort by number of medical records"}, "# medical records"))
            );

  # ... loop over all parameters
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= Tr(
                 td({-align=>'right'},  $i),
                 td({-align=>'center'}, checkbox(-name=>'parameter_select', -checked=>'0', -value=>$row->{'parameter_id'}, -label=>'') ),
                 td({-align=>'center'},
                    (($row->{'number_mrs'} == 0)
                     ?a({-href=>"$url?choice=delete_parameter&parameter_id=" . $row->{'parameter_id'}}, "delete")
                     :''
                    )
                 ),
                 td({-align=>'left'},   a({-href=>"$url?choice=parameter_view&parameter_id=" . $row->{'parameter_id'}}, $row->{'parameter_name'})),
                 td({-align=>'left'},   $row->{'parameter_shortname'}),
                 td({-align=>'right'},  $row->{'parameter_id'} ),
                 td({-align=>'right'},  $row->{'parameter_is_metadata'} ),
                 td({-align=>'right'},  $row->{'number_mrs'} )
               );
  }

  $page .= end_table()
           . p()
           . h3("In order to add parameters to a parameterset: ")
           . p(  "1) choose parameter(s) from above by clicking the checkbox(es)" . br()
               . "2) choose parameterset from the pulldown menu"                  . br()
               . "3) press button and follow the instructions"
             )
           . get_parametersets_popup_menu($global_var_href) . "&nbsp;&nbsp" . submit(-name => 'choice', -value => 'add parameters to parameterset')
           . end_form()
           . p();

  return $page;
}
# end of parameters_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE020 parameter_view():                            parameter view
sub parameter_view {                                     my $sr_name = 'SR_PHE020';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my $parameter_id      = param('parameter_id');
  my @sql_parameters;
  my %Excel_column_number2column_letter = ( '1' =>  'A',  '2' =>  'B',  '3' =>  'C',  '4' =>  'D',  '5' =>  'E',  '6' =>  'F',  '7' =>  'G',  '8' =>  'H',  '9' =>  'I', '10' =>  'J',
                                           '11' =>  'K', '12' =>  'L', '13' =>  'M', '14' =>  'N', '15' =>  'O', '16' =>  'P', '17' =>  'Q', '18' =>  'R', '19' =>  'S', '20' =>  'T',
                                           '21' =>  'U', '22' =>  'V', '23' =>  'W', '24' =>  'X', '25' =>  'Y', '26' =>  'Z', '27' => 'AA', '28' => 'AB', '29' => 'AC', '30' => 'AD',
                                           '31' => 'AE', '32' => 'AF', '33' => 'AG', '34' => 'AH', '35' => 'AI', '36' => 'AJ', '37' => 'AK', '38' => 'AL', '39' => 'AM', '40' => 'AN',
                                           '41' => 'AO', '42' => 'AP', '43' => 'AQ', '44' => 'AR', '45' => 'AS', '46' => 'AT', '47' => 'AU', '48' => 'AV', '49' => 'AW', '50' => 'AX',
                                           '51' => 'AY', '52' => 'AZ', '53' => 'BA', '54' => 'BB', '55' => 'BC', '56' => 'BD', '57' => 'BE', '58' => 'BF', '59' => 'BG', '60' => 'BH',
                                           '61' => 'BI', '62' => 'BK', '63' => 'BK', '64' => 'BL', '65' => 'BM', '66' => 'BN', '67' => 'BO', '68' => 'BP', '69' => 'BQ', '70' => 'BR',
                                           '71' => 'BS', '72' => 'BT', '73' => 'BU', '74' => 'BV', '75' => 'BW', '76' => 'BX', '77' => 'BY', '78' => 'BZ', '79' => 'CA', '80' => 'CB',
                                           '81' => 'CC', '82' => 'CD', '83' => 'CE', '84' => 'CF', '85' => 'CG', '86' => 'CH', '87' => 'CI', '88' => 'CJ', '89' => 'CK', '90' => 'CL',
                                           '91' => 'CM', '92' => 'CN', '93' => 'CO', '94' => 'CP', '95' => 'CQ', '96' => 'CR', '97' => 'CS', '98' => 'CT', '99' => 'CT','100' => 'CV',
                                          '101' => 'CW','102' => 'CX','103' => 'CY','104' => 'CZ','105' => 'DA','106' => 'DB','107' => 'DC','108' => 'DD','109' => 'DE','110' => 'DF',
                                          '111' => 'DG','112' => 'DH','113' => 'DI','114' => 'DJ','115' => 'DK','116' => 'DL','117' => 'DM','118' => 'DN','119' => 'DO','110' => 'DP',
                                          '121' => 'DQ','122' => 'DR','123' => 'DS','124' => 'DT','125' => 'DU','126' => 'DV','127' => 'DW','128' => 'DX','129' => 'DY','130' => 'DZ',
                                          '131' => 'EA','132' => 'EB','133' => 'EC','134' => 'ED','135' => 'EE','136' => 'EF','137' => 'EG','138' => 'EH','139' => 'EI','140' => 'EJ',
                                          '141' => 'EK','142' => 'EL','143' => 'EM','144' => 'EN','145' => 'EO','146' => 'EP','147' => 'EQ','148' => 'ER','149' => 'ES','150' => 'ET',
                                          '151' => 'EU','152' => 'EV','153' => 'EW','154' => 'EX','155' => 'EY','156' => 'EZ','157' => 'FA','158' => 'FB','159' => 'FC','160' => 'FD',
                                          '161' => 'FE','162' => 'FF','163' => 'FG','164' => 'FH','165' => 'FI','166' => 'FJ','167' => 'FK','168' => 'FL','169' => 'FM','170' => 'FN',
                                          '171' => 'FO','172' => 'FP','173' => 'FQ','174' => 'FR','175' => 'FS','176' => 'FT','177' => 'FU','178' => 'FV','179' => 'FW','180' => 'FX',
                                          '181' => 'FY','182' => 'FZ','183' => 'GA','184' => 'GB','185' => 'GC','186' => 'GD','187' => 'GE','188' => 'GF','189' => 'GG','190' => 'GH',
                                          '191' => 'GI','192' => 'GJ','193' => 'GK','194' => 'GL','195' => 'GM','196' => 'GN','197' => 'GO','198' => 'GP','199' => 'GQ','200' => 'GR');

  my %parameter_type2human = ('i' => 'int', 'f' => 'float',  'c' =>  'text',  'b' =>  'bool', 'd' => 'date', 't' => 'datetime');
  my %yn2yesno             = ('y' => 'yes', 'n' => 'no');

  # check input: is parameter id given? is it a number?
  if (!param('parameter_id') || param('parameter_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid parameter id"));
     return $page;
  }

  # first table
  $page .= h2("Parameter details "
             . a({-href=>"$url?choice=parameter_view&parameter_id=$parameter_id", -title=>"reload page"},
                 img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
               ) . ' (' . a({-href=>"$url?choice=parameters_overview"}, 'parameters overview')
           . ')')
           . hr({-width=>"50%", align=>"left"});

  $sql = qq(select parameter_id, parameter_name, parameter_shortname, parameter_type, parameter_decimals, parameter_unit,
                   parameter_description, parameter_default, parameter_choose_list, parameter_normal_range, parameter_is_metadata
            from   parameters
            where  parameter_id = ?
           );

  @sql_parameters = ($parameter_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("No details on this parameter");
     return $page;
  }

  # else continue: get result handle to generate details table
  $row = $result->[0];

  $page .= h3("1) Parameter " . qq("$row->{'parameter_name'}" [$row->{'parameter_shortname'}]))
           . table( {-border=>1, -summary=>"table"},
               Tr(
                 th("Name (short)"),
                 td($row->{'parameter_name'})
               ) .
               Tr(
                 th("Name (long)"),
                 td($row->{'parameter_shortname'})
               ) .
               Tr(
                 th("Description"),
                 td($row->{'parameter_description'})
               ) .
               Tr(
                 th("Type"),
                 td($parameter_type2human{$row->{'parameter_type'}})
               ) .
               (($row->{'parameter_type'} eq 'f')
                ?Tr(
                   th("Decimals"),
                   td({-align=>"right"}, $row->{'parameter_decimals'})
                 )
                :''
               ) .
               Tr(
                 th("Unit"),
                 td($row->{'parameter_unit'})
               ) .
               Tr(
                 th("Default"),
                 td($row->{'parameter_default'})
               ) .
               Tr(
                 th("Valid value list"),
                 td($row->{'parameter_choose_list'})
               ) .
               Tr(
                 th("Normal range"),
                 td($row->{'parameter_normal_range'})
               ) .
               Tr(
                 th("is metadata"),
                 td($yn2yesno{$row->{'parameter_is_metadata'}})
               ) .
               Tr(
                 th("number of medical records"),
                 td({-align=>"right"}, get_number_medical_records_of_parameter($global_var_href, $parameter_id))
               )
             );

  ################################################################

  # list assigned parametersets in which current parameter is used
  $page .= hr()
           . h3("2) Parametersets assigned to this parameter")
           . hr({-width=>"50%", align=>"left"});

  $sql = qq(select parameter_name, parameterset_id, parameterset_name,
                   p2p_upload_column, p2p_upload_column_name, p2p_parameter_category, p2p_increment_value, p2p_increment_unit
            from   parametersets
                   left join parametersets2parameters on p2p_parameterset_id = parameterset_id
                   left join parameters               on    p2p_parameter_id = parameter_id
            where  parameter_id = ?
            order  by parameterset_name asc, p2p_increment_value asc
         );

  @sql_parameters = ($parameter_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows == 0) {
     $page .= p("No parametersets assigned to this parameter");
  }
  else {
     $page .= start_table({-border=>1})
              . Tr(
                  th("parameterset"),
                  th("simple/serial"),
                  th("increment value"),
                  th("increment unit"),
                  th("Excel header name"),
                  th({-colspan=>"2"}, "Excel column"),
                  th("number of medical records")
                );

     # loop over parametersets
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $page .= Tr(
                    td(a({-href=>"$url?choice=parameterset_view&parameterset_id=" . $row->{'parameterset_id'}}, $row->{'parameterset_name'})),
                    td($row->{'p2p_parameter_category'}),
                    td($row->{'p2p_increment_value'}),
                    td($row->{'p2p_increment_unit'}),
                    td($row->{'p2p_upload_column_name'}),
                    td({-align=>"right"},  $row->{'p2p_upload_column'}),
                    td({-align=>"center"}, $Excel_column_number2column_letter{$row->{'p2p_upload_column'}}),
                    td({-align=>"right"},  get_number_medical_records_of_parameter_and_parameterset($global_var_href, $parameter_id, $row->{'parameterset_id'}))
                  );
     }

     $page .= end_table();
  }

  return $page;
}
# end of parameter_view()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE021 create_new_metadata_definition_1():          create new metadata definition, step 1: input dialog
sub create_new_metadata_definition_1 {                   my $sr_name = 'SR_PHE021';
  my ($global_var_href) = @_;                                     # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $parameterset_id   = param('parameterset_id');
  my $parameterset_name = get_parameterset_name_by_id($global_var_href, $parameterset_id);
  my $url = url();
  my ($page, $sql);
  my @sql_parameters;
  my %labels = ("y" => 'yes', "n" => 'no');

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Define a new metadata definition for parameterset \"$parameterset_name\"")
             . hr()
             . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Define a new metadata definition for parameterset \"$parameterset_name\"")

          . hr()

          . start_form({-action => url()})

          . h3("Please specify details for your new metadata definition")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("name"),
                  td(textfield(-name => "mdd_name", -size=>"30", -maxlength=>"100", -default=>'')
                     . br()
                     . small("example: \"equipment name\"")
                  ),
                  td("Please enter the name of the new metadata definition")
              ) .
              Tr( th("shortname"),
                  td(textfield(-name => "mdd_shortname", -size=>"20", -maxlength=>"20", -default=>'')
                     . br()
                     . small("example: \"en\"")
                  ),
                  td("Please enter a shortname for the new metadata definition")
              ) .
              Tr( th("description"),
                  td(textarea(-name=>"mdd_description", -columns=>"60", -rows=>"2", -value=>"")),
                  td("Please describe the new metadata definition.")
              ) .
              Tr( th("metadata type"),
                  td(popup_menu(-name => "mdd_type",
                                -values => ["c", "f", "i", "b", "d", "t"],
                                -labels => {"c"  => "text",
                                            "f"  => "float",
                                            "i"  => "integer",
                                            "b"  => "boolean",
                                            "d"  => "date",
                                            "t"  => "datetime"},
                                -default => "1"
                     )
                  ),
                  td("Please specify metadata type")
              ) .
              Tr( th("decimals"),
                  td(popup_menu(-name => "mdd_decimals",
                                -values => [0..8],
                                -default => "0"
                     )
                  ),
                  td("Please specify decimals (only for float)")
              ) .
              Tr( th("unit"),
                  td(textfield(-name => "mdd_unit", -size=>"30", -maxlength=>"60", -default=>'-')
                     . br()
                     . small("example: \"g\"")
                  ),
                  td("Please specify the unit of your new metadata")
              ) .
              Tr(th("required"),
              	  td(radio_group(-name=>'mdd_required', -values=>['y', 'n'], -default=>'1', -labels=>\%labels) 
              	  	. br()
              	  	. small("example: \"yes\" if metadata is required")
              	  ),
              	  td("Please specify if metadata is required.")
              ).
              Tr( th("default"),
                  td(textfield(-name => "mdd_default", -size=>"30", -maxlength=>"60", -default=>'')
                     . br()
                     . small("example: \"2\" for parameter \"number of eyes\"")
                  ),
                  td("Please specify a default value for your metadata")
              ) .
              Tr( th("possible values"),
                  td(textfield(-name => "mdd_choose_list", -size=>"50", -maxlength=>"255", -default=>'')
                     . br()
                     . small("example: \"1;2;3;4\" or \"small;medium;large\"")
                  ),
                  td("Please enter a semicolon-separated list of possible values")
              )
            )

          . p()

          . hidden('parameterset_id')
          . submit(-name => "choice", -value => "add new metadata definition!") . "&nbsp; &nbsp;"
          . CGI->reset( -name => "reset form"                                      ) . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel"                      )

          . end_form();

  return $page;
}
# end of create_new_metadata_definition_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE022 create_new_metadata_definition_2():          create new metadata definition,  step 2: database transaction
sub create_new_metadata_definition_2 {                   my $sr_name = 'SR_PHE022';
  my ($global_var_href)   = @_;                                        # get reference to global vars hash
  my $session             = $global_var_href->{'session'};             # get session handle
  my $user_id             = $session->param(-name=>'user_id');
  my $user_name           = $session->param(-name=>'username');
  my $dbh                 = $global_var_href->{'dbh'};                 # DBI database handle
  my $parameterset_id     = param('parameterset_id');
  my $mdd_name            = param('mdd_name');
  my $mdd_shortname       = param('mdd_shortname');
  my $parameterset_name   = get_parameterset_name_by_id($global_var_href, $parameterset_id);
  my $url = url();
  my ($page, $sql, $i, $row, $rows, $result, $rc);
  my ($mdd_name_exists_for_parameterset, $new_mdd_id);
  my @sql_parameters;
  my $datetime_now        = get_current_datetime_for_sql();

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Define a new metadata definition for parameterset \"$parameterset_name\"")
             . hr()
             . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Define a new metadata definition for parameterset \"$parameterset_name\"")
          . hr();

  # check input: is mdd name given?
  if (!param('mdd_name') || param('mdd_name') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter a name for the new metadata definition (at least 1 character)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is mdd shortname given?
  if (!param('mdd_shortname') || param('mdd_shortname') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter a shortname for the new metadata definition (at least 1 character)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is mdd description given?
  if (!param('mdd_description') || param('mdd_description') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter a description for the new metadata definition (at least 1 character)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is mdd type given?
  if (!param('mdd_type') || param('mdd_type') !~ /^[cfibdt]$/) {
     $page .= p({-class=>"red"}, b("Error: please choose the data type of your new metadata definition [text, integer, float, boolean, date, datetime] "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is mdd decimals given? is it a number? (check only for float parameters)
  if (param('mdd_type') eq 'f') {
     if (!param('mdd_decimals') || param('mdd_decimals') !~ /^[0-8]+$/) {
        $page .= p({-class=>"red"}, b("Error: please choose number of decimals of your new float metadata definition"))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }
  }

  # check input: is mdd unit given?
  if (!param('mdd_unit') || param('mdd_unit') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter the unit of your metadata definition"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is mdd default given?
  if (!param('mdd_default') || param('mdd_default') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter the default for your metadata definition"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  #check input: is mdd_required given?
  my $mdd_required = param('mdd_required');
  if (!param('mdd_required') || param('mdd_required') eq '') {
  	 $page .= p({-class=>"red"}, b("Error: please enter if your metadata is required"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  ####################################################
  # check if mdd name or shortname exists (for this parameterset)
  $sql = qq(select mdd_parameterset_id
            from   metadata_definitions
            where  mdd_parameterset_id = ?
                   and
                   (          mdd_name = ?
                      or mdd_shortname = ?
                      or      mdd_name = ?
                      or mdd_shortname = ?
                   )
         );

  @sql_parameters = ($parameterset_id, $mdd_name, $mdd_name, $mdd_shortname, $mdd_shortname);

  ($mdd_name_exists_for_parameterset) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . __LINE__)};

  if (defined($mdd_name_exists_for_parameterset)) {
     $page .= p({-class=>"red"}, "Metadata definition name \"$mdd_name\" or shortname \"$mdd_shortname\" already exists for parameterset \"$parameterset_name\"! Please choose another one.")
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  ########################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during new metadata definition insert (begin transaction failed)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new mdd id
  ($new_mdd_id) = $dbh->selectrow_array("select (max(mdd_id)+1) as new_mdd_id
                                         from   metadata_definitions
                                        ");

  # ok, this is only neccessary for the very first mdd when (max(mdd_id)+1) = (NULL + 1) is undefined
  if (!defined($new_mdd_id)) { $new_mdd_id = 1; }

  # insert new metadata definition
  $dbh->do("insert
            into   metadata_definitions (mdd_id, mdd_name, mdd_shortname, mdd_type, mdd_decimals, mdd_unit, mdd_required, mdd_default, mdd_possible_values,
                                         mdd_global_yn, mdd_active_yn, mdd_parameterset_id, mdd_parameter_id, mdd_description)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
           ", undef,
           $new_mdd_id, $mdd_name, $mdd_shortname, param('mdd_type'), param('mdd_decimals'), param('mdd_unit'), param('mdd_required'),
           param('mdd_default'),   param('mdd_choose_list'), 'n', 'y', $parameterset_id, undef, param('mdd_description')
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new metadata definition)", $sr_name . "-" . __LINE__);

  # everything ok, so commit
  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during new metadata definition insert (commit failed)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_metadata_definition\t". $new_mdd_id . "\t" . $mdd_name);

  $page .= h3("New metadata definition \"$mdd_name\" for parameterset \"" . a({-href=>"$url?choice=parameterset_view&parameterset_id=" . param('parameterset_id')}, "$parameterset_name") . "\" successfully created!")
           . p();

  return $page;
}
# end of create_new_metadata_definition_2()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE023 parameterset_stats_view():                   parameterset stats view
sub parameterset_stats_view {                            my $sr_name = 'SR_PHE023';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $parameterset_id   = param('parameterset_id');
  my $orderlist_id      = param('orderlist_id');
  my $parameterset_name = get_parameterset_name_by_id($global_var_href, $parameterset_id);
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my ($min, $mean, $max);
  my $add_orderlist_to_title = '';
  my @sql_parameters;

  # check input: is parameterset_id given? is it a number?
  if (!param('parameterset_id') || param('parameterset_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid parameterset id"));
     return $page;
  }

  # check input: if orderlist_id given: is it a number?
  if (param('orderlist_id'))  {
     if (param('orderlist_id') !~ /^[0-9]+$/) {
        $page = p({-class=>"red"}, b("Error: please provide a valid orderlist id"));
        return $page;
     }

     $add_orderlist_to_title = " (from orderlist "
                               . a({-href=>"$url?choice=orderlist_view&orderlist_id=$orderlist_id"}, $orderlist_id)
                               . ", "
                               . a({-href=>"$url?choice=parameterset_stats&parameterset_id=$parameterset_id"}, "overall")
                               . ")";
  }

  $page = h2(qq(Parameterset statistics: "$parameterset_name"   )
             . a({-href=>"$url?choice=parameterset_stats&parameterset_id=$parameterset_id", -title=>'reload page'},
                    img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
               )
             . $add_orderlist_to_title
          )
          . hr()

          . start_form(-action => url());

  ############################
  # display parameter
  $sql = qq(select parameter_id, parameter_name, parameter_shortname, parameter_description, parameter_unit, parameter_is_metadata,
                   parameter_type
            from   parametersets2parameters
                   join parameters on p2p_parameter_id = parameter_id
            where  p2p_parameterset_id = ?
            order  by p2p_upload_column asc, parameter_name asc
           );

  @sql_parameters = ($parameterset_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no imports found at all: tell and quit
  if ($rows == 0) {
     $page .= h3("3) Parameters belonging to parameter set " . qq("$parameterset_name"))
              . p("No parameters in this parameter set")

              . hr({-width=>"50%", -align=>"left"});
  }
  else {
     # else continue: display parameters table
     $page .= h3("Parameters belonging to parameter set " . qq("$parameterset_name"))
              . p("[" . a({-href=>"$url?choice=search%20by%20value&parameterset_id=$parameterset_id"}, "start value-based search") . "]")
              . start_table( {-border=>"1", -summary=>"experiment_overview"})
              . Tr( {-align=>'center', -bgcolor=>"lightblue"},
                  th("name"),
                  th("short name"),
                  th("description"),
                  th("min"),
                  th("mean"),
                  th("max"),
                  th("unit")
                );

     # ... loop over all parameters
     for ($i=0; $i<$rows; $i++) {               # $rows is the number of racks returned from the above query
         $row = $result->[$i];                  # get a reference on the current result row

         ($min, $mean, $max) = get_parameter_3_numbers($global_var_href, $parameterset_id, $row->{'parameter_id'}, $row->{'parameter_type'}, $orderlist_id);

         $page .= Tr({-align=>'center'},
                    td(defined($row->{'parameter_name'})?b(a({-href=>"$url?choice=parameter_view&parameter_id=$row->{'parameter_id'}"}, $row->{'parameter_name'})):'-'),
                    td(defined($row->{'parameter_shortname'})?$row->{'parameter_shortname'}:'-'),
                    td(defined($row->{'parameter_description'})?$row->{'parameter_description'}:'-'),
                    td($min),
                    td($mean),
                    td($max),
                    td(defined($row->{'parameter_unit'})?$row->{'parameter_unit'}:'-')
                  );
     }

     $page .= end_table();

  }

  return $page;
}
# end of parameterset_stats_view()
#------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE024 parameterset_search_by_value_form():         parameterset search by value, step 1: form
sub parameterset_search_by_value_form {                  my $sr_name = 'SR_PHE024';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $parameterset_id   = param('parameterset_id');
  my $orderlist_id      = param('orderlist_id');
  my $parameterset_name = get_parameterset_name_by_id($global_var_href, $parameterset_id);
  my %parameter_type = ('b' => 'boolean', 'f' => 'float', 'i' => 'integer', 'l' => 'list', 'p' => 'picture', 'c' => 'text', 'd' => 'date', 't' => 'datetime');
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my ($min, $mean, $max);
  my $add_orderlist_to_title = '';
  my @sql_parameters;
  my ($lower_input, $upper_input, $row_color, $checkbox);

  # check input: is parameterset_id given? is it a number?
  if (!param('parameterset_id') || param('parameterset_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid parameterset id"));
     return $page;
  }

  # check input: if orderlist_id given: is it a number?
  if (param('orderlist_id'))  {
     if (param('orderlist_id') !~ /^[0-9]+$/) {
        $page = p({-class=>"red"}, b("Error: please provide a valid orderlist id"));
        return $page;
     }

     $add_orderlist_to_title = " (from orderlist "
                               . a({-href=>"$url?choice=orderlist_view&orderlist_id=$orderlist_id"}, $orderlist_id)
                               . ", "
                               . a({-href=>"$url?choice=parameterset_stats&parameterset_id=$parameterset_id"}, "overall")
                               . ")";
  }

  $page = h2(qq(Parameterset value search: "$parameterset_name"   )
             . a({-href=>"$url?choice=search%20by%20value&parameterset_id=$parameterset_id", -title=>'reload page'},
                    img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
               )
             . $add_orderlist_to_title
          )
          . hr()

          . start_form(-action => url())
          . hidden('parameterset_id');

  ############################
  # display parameters
  $sql = qq(select parameter_id, parameter_name, parameter_shortname, parameter_description, parameter_unit, parameter_is_metadata,
                   parameter_type
            from   parametersets2parameters
                   join parameters on p2p_parameter_id = parameter_id
            where  p2p_parameterset_id = ?
            order  by p2p_upload_column asc, parameter_name asc
           );

  @sql_parameters = ($parameterset_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no imports found at all: tell and quit
  if ($rows == 0) {
     $page .= h3("3) Parameters belonging to parameter set " . qq("$parameterset_name"))
              . p("No parameters in this parameter set")

              . hr({-width=>"50%", -align=>"left"});
  }
  else {
     # else continue: display parameters table
     $page .= h3(qq("$parameterset_name" parameters))
              . start_table( {-border=>"1", -summary=>"experiment_overview"})
              . Tr( {-align=>'center', -bgcolor=>"lightblue"},
                  th({-rowspan=>2}, "name"),
                  th({-rowspan=>2}, "short name"),
                  th({-rowspan=>2}, "type"),
                  th({-rowspan=>2}, "unit"),
                  th({-colspan=>3}, "overall"),
                  th({-colspan=>3}, "search for" . br() . "value between")
                )
              . Tr( {-align=>'center', -bgcolor=>"lightblue"},
                  th("min"),
                  th("mean"),
                  th("max"),
                  th("use?"),
                  th("lower"),
                  th("upper")
                );

     # ... loop over all parameters
     for ($i=0; $i<$rows; $i++) {               # $rows is the number of racks returned from the above query
         $row = $result->[$i];                  # get a reference on the current result row

         ($min, $mean, $max) = get_parameter_3_numbers($global_var_href, $parameterset_id, $row->{'parameter_id'}, $row->{'parameter_type'}, $orderlist_id);

         if ($row->{'parameter_type'} eq "f" || $row->{'parameter_type'} eq "i") {
            $row_color   = "white";
            $checkbox    = checkbox(-name=>'use_parameter', -checked=>'0', -value=>$row->{'parameter_id'}, -label=>'');
            $lower_input = textfield(-name => "parameter_lower_" . $row->{'parameter_id'}, -size=>"6", -maxlength=>"6", -value=>$min, -title=>"enter lower limit");
            $upper_input = textfield(-name => "parameter_upper_" . $row->{'parameter_id'}, -size=>"6", -maxlength=>"6", -value=>$max, -title=>"enter upper limit");
         }
         else {
            $row_color   = "lightgrey";
            $checkbox    = "";
            $lower_input = "";
            $upper_input = "";
         }

         $page .= Tr({-align=>'center', -bgcolor=>$row_color},
                    td(defined($row->{'parameter_name'})?b(a({-href=>"$url?choice=parameter_view&parameter_id=$row->{'parameter_id'}"}, $row->{'parameter_name'})):'-'),
                    td(defined($row->{'parameter_shortname'})?$row->{'parameter_shortname'}:'-'),
                    td(defined($row->{'parameter_type'})?$parameter_type{$row->{'parameter_type'}}:'-'),
                    td(defined($row->{'parameter_unit'})?$row->{'parameter_unit'}:'-'),
                    td($min),
                    td($mean),
                    td($max),
                    td($checkbox),
                    td($lower_input),
                    td($upper_input)
                  );
     }

     $page .= end_table()

              . p()
              . p("restrict to mice in cart " . checkbox('restrict_to_cart', '0', 1, ''))
              . p()
              . submit(-name => "choice", -value=>"Search mice by value")

              . end_form();
  }

  return $page;
}
# end of parameterset_search_by_value_form()
#------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_PHE025 search_mice_by_value                         find mice by phenotyping values
sub search_mice_by_value {                               my $sr_name = 'SR_PHE025';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my $url               = url();
  my $sex_color         = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my @parameters        = param();                       # read all CGI parameter keys
  my ($page, $sql, $result, $rows, $row, $i);
  my $parameterset_id   = param('parameterset_id');
  my @use_parameters    = param('use_parameter');
  my $use_parameter;
  my $parameter;
  my @sql_parameters;
  my @id_list;
  my @sql_id_list;
  my ($cart_mice, $cart_mouse, $first_gene_name, $first_genotype);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';
  my ($current_lower, $current_upper, $current_type, $current_parameter_sql, $restrict_to_previous);
  my @current_match_list      = ();
  my @previous_match_list;
  my $table;

  # check if parameters chosen
  if (!param('use_parameter') || (scalar @use_parameters) == 0) {
     $page = p({-class=>"red"}, b("Error: Please choose at least one parameter"));
     return $page;
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href)
              . hr();
  }

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  # result table
  $table = start_table( {-border=>1, -summary=>"table"})
           . Tr(
               th({-rowspan=>2}, "parameter"),
               th({-colspan=>2}, "filter"),
               th({-rowspan=>2}, "# cumulated matches")
             )
           . Tr(
               th("lower"),
               th("upper")
             );

  # loop over all chosen parameters
  foreach $use_parameter (@use_parameters) {
     # in every loop, build an SQL statement to filter for lower and upper bounds of current parameter
     # if statement forms a valid query, get all matching mice

     # reset
     $current_parameter_sql = '';
     @current_match_list    = ();
     $sql_mouse_list        = '';

     # check if parameter id is a number
     if ($use_parameter =~ /^[0-9]+$/) {
        # if so: get lower and upper bounds
        $current_lower = param('parameter_lower_' . $use_parameter);
        $current_upper = param('parameter_upper_' . $use_parameter);
        $current_type  = get_parameter_type($global_var_href, $use_parameter);         # returns "f" for float, "i" for integer

        # now process bounds
        # lower is float
        if ($current_type eq 'f'    && $current_lower =~ /^[0-9\.]+$/)  {
            $current_parameter_sql .= qq(and mr_float >= $current_lower )   . "\n";
        }
        # lower is integer
        elsif ($current_type eq 'i' && $current_lower =~ /^[0-9]+$/)  {
            $current_parameter_sql .= qq(and mr_integer >= $current_lower ) . "\n";
        }

        # upper is float
        if ($current_type eq 'f'    && $current_upper =~ /^[0-9\.]+$/)  {
            $current_parameter_sql .= qq(and mr_float <= $current_upper )   . "\n";
        }
        # upper is integer
        elsif ($current_type eq 'i' && $current_upper =~ /^[0-9]+$/)  {
            $current_parameter_sql .= qq(and mr_integer <= $current_upper ) . "\n";
        }

        $current_parameter_sql = qq(and mr_parameter = $use_parameter) . "\n" . $current_parameter_sql;

        $sql = qq(select mouse_id
                  from   mice
                         join mice2medical_records on m2mr_mouse_id = mouse_id
                         join medical_records      on    m2mr_mr_id = mr_id
                  where  1
                         $restrict_to_cart_sql
                         and mr_parameterset_id = ?
                         $current_parameter_sql
               );

        @sql_parameters = ($parameterset_id);

        ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

        # loop over matching mice
        for ($i=0; $i<$rows; $i++) {
            $row = $result->[$i];

            push(@current_match_list, $row->{'mouse_id'});
        }

        # now we have a list of mice matching the current filter in @current_match_list

        # if there is a previous match list, use intersection of current list with previous list
        if (defined(@previous_match_list)) {
           @current_match_list = in_both_lists(\@previous_match_list, \@current_match_list);
        }

        @previous_match_list = @current_match_list;

        # write table
        $table .= Tr(
                    td(get_parameter_name_by_id($global_var_href, $use_parameter)),
                    td($current_lower),
                    td($current_upper),
                    td(scalar @current_match_list)
                  );

     }
     # no valid parameter_id ignore ...
  }

  # after looping over all parameters, @current_match_list contains the list of mice that pass all filters


  $page .= h1(qq(Parameterset value search: Results))
           . hr();

  $page .= h3("Search filters and intermediate results")
           . $table
           . end_table()
           . hr();

  $page .= h3("List of mice matching above filters");

  # empty list
  if ((scalar @current_match_list) == 0) {
     $page .= p(qq(Sorry, no mice found for these filter settings));
     return $page;
  }

  $sql_mouse_list = join(',', @current_match_list);

  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime,
                   dr1.death_reason_name as how, dr2.death_reason_name as why
            from   mice
                   join mouse_strains      on             mouse_strain = strain_id
                   join mouse_lines        on               mouse_line = line_id
                   join death_reasons dr1  on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2  on  mouse_deathorexport_why = dr2.death_reason_id
            where  mouse_id in ($sql_mouse_list)
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__);

  # no mouse found for these filter settings
  unless ($rows > 0) {
     $page .= p(qq(Sorry, no mice found for these filter settings));
     return $page;
  }

  $page .= p(b("Found $rows " . (($rows == 1)?'mouse':'mice' ). " matching all filters"))

           . start_form(-action=>url())
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th("select"        ),
               th("mouse ID"      ),
               th("ear"           ),
               th("sex"           ),
               th("born"          ),
               th("age"           ),
               th("death"         ),
               th("genotype"      ),
               th("strain"        ),
               th("line"          )
             );

  # loop over all mice with matching patho id (should normally only be one)
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current line
     $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                td($i+1),
                td(checkbox('mouse_select', '0', $row->{'mouse_id'}, '')),
                td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                td($row->{'mouse_earmark'}),
                td($row->{'mouse_sex'}),
                td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                td({-title=>"$row->{'how'}, $row->{'why'}"}, format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
                td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
                td($row->{'strain_name'}),
                td('&nbsp;' . $row->{'line_name'} . '&nbsp;')
              );
  }

  $page .= end_table()
           . p();

  # store CGI parameters in hidden fields. Yes, I know, there are better ways to do this, but input from hidden fields will be checked
  foreach $parameter (@parameters) {
     unless ($parameter eq 'mouse_select' || $parameter eq 'job') {
        $page .= hidden(-name=>$parameter, -value=>param("$parameter")) . "\n";
     }
  }

  $page .= submit(-name => "job", -value=>"Add selected mice to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")               . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre") . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")      . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of search_mice_by_value
#--------------------------------------------------------------------------------------


# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;