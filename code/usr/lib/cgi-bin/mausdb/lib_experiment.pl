# lib_experiment.pl - a MausDB subroutine library file                                                                                #
# $Id:: lib_experiment.pl 114 2010-02-24 07:44:00Z berger                                                                          $  #
# Subroutines in this file provide functions related to experimental status                                                           #
#                                                                                                                                     #
#-------------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                                 #
#-------------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                     #
# SR_EXP001 experiment_1                                  experiment (step 1: form)                                                   #
# SR_EXP002 experiment_2                                  confirm experiment information                                              #
# SR_EXP003 experiment_3                                  do adding to experiment and display results                                 #
# SR_EXP004 add_mouse_to_experiment                       do database transaction for this mouse and get result                       #
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
# SR_EXP001 experiment_1                                  experiment (step 1: form)
sub experiment_1 {                                        my $sr_name = 'SR_EXP001';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $sql, $result, $rows, $row, $i);
  my $url                 = url();
  my @mice_for_experiment = ();
  my ($popup, $mouse, $warning, $is_in_experiment);

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_for_experiment, $mouse);
     }
     # else ignore ...
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_for_experiment == 0) {
     $page .= h2("Add mice to experiment or change experiment")
              . hr()
              . h3("No mice for experiment chosen")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # display experiment form
  $page .= h2("Add mice to experiment or change experiment: 1. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("Please choose the experiment you wish chosen mice to be added or changed to")
           . table( {-border=>1},
                Tr( td({-align=>'center'}, b("Experiment ")),
                    td(get_experiments_popup_menu($global_var_href))
                ) .
                Tr( td({-align=>'center'}, b("Date") . br() . small('(at which mice entered (new) experiment)')),
                    td(textfield(-name => "experiment_start_datetime", -id=>"experiment_start_datetime", -size=>"20", -maxlength=>"21", -value=>get_current_datetime_for_display())
               . "&nbsp;&nbsp;"
               . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=experiment_start_datetime', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
               )
                )
             )
           . p()
           . hidden(-name=>'mouse_select') . "\n"
           . start_table({-border=>1, -summary=>"table"})
           . Tr(
               th("mouse id"),
               th("ear"),
               th("sex"),
               th("experiment status")
             );

  # one table row for each mouse
  foreach $mouse (@mice_for_experiment) {

     $warning = 'breeding animal';

     # check if mouse is in an experiment
     $is_in_experiment = is_in_experiment($global_var_href, $mouse);

     if ($is_in_experiment > 0) {
        $warning = span({-class=>"red"}, "Mouse is already in an experiment. If you continue, the experiment will change.");
     }

     $page .= Tr({-align=>"center"},
                td($mouse),
                td(get_earmark($global_var_href, $mouse)),
                td(get_sex($global_var_href, $mouse)),
                td({-align=>'left'}, $warning)
              );
  }

  $page .= end_table()
           . p()
           . submit(-name => "choice", -value=>"confirm experiment")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel adding to or change of experiment (go to previous page)"))
           . end_form();

  return $page;
}
# end of experiment_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_EXP002 experiment_2                                  confirm experiment information
sub experiment_2 {                                        my $sr_name = 'SR_EXP002';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};      # DBI database handle
  my ($page, $mouse);
  my $url                  = url();
  my @mice_for_experiment  = ();
  my $experiment           = param('experiment');
  my $errors               = 0;
  my $experiment_name;
  my $experiment_start_datetime = param('experiment_start_datetime');
  my ($is_in_experiment, $is_date_younger, $is_dead_atdate);
  #convert datetime into SQL datetime
  my $date = format_display_datetime2sql_datetime(param('experiment_start_datetime'));
     	
  my $warning;
  my $submit_enable;										#submit will be disabled in case of faulse input
  
  # check input: is experiment id given? is it a number?
  if (!param('experiment') || param('experiment') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please select a valid experiment"));
     return $page;
  }

  # get experiment name from experiment id
  ($experiment_name) = $dbh->selectrow_array("select experiment_name
                                              from   experiments
                                              where  experiment_id = $experiment
                                             ");

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs (but skip those who already are in an experiment)
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) { # && is_in_experiment($global_var_href, $mouse) < 0) {
        push(@mice_for_experiment, $mouse);
     }
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_for_experiment == 0) {
     $page .= h2("Add mice to experiment or change experiment: 2. step")
              . hr()
              . h3("No mice for experiment chosen (or have been removed from list)")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # date of entering experiment not given or invalid
  if (!param('experiment_start_datetime') || check_datetime_ddmmyyyy_hhmmss(param('experiment_start_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date/time of entering (new) experiment not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is date of entering experiment in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('experiment_start_datetime')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: date/time of entering (new) experiment is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # display confirmation page
  $page .= h2("Add mice to experiment or change experiment: 2. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3(qq(Please confirm adding the mice listed below to experiment "$experiment_name" at "$experiment_start_datetime"))
           . hidden(-name=>'experiment')
           . hidden(-name=>'experiment_start_datetime')
           . hidden(-name=>'mouse_select')
           . start_table({-border=>1, -summary=>"table"})
           . Tr(
               th("mouse id"),
               th("ear"),
               th("sex"),
               th("remark")
             );

 $submit_enable = 1;
 
   # one table row for each mouse
 foreach $mouse (@mice_for_experiment) {

	 $warning = 'ok';

     # check if mouse is in an experiment
     $is_in_experiment = is_in_experiment($global_var_href, $mouse);

     if ($is_in_experiment > 0) {
     	
     	#check start and end data of experiments
     	
     	#is date of entering experiment younger than an existing experiment
     	$is_date_younger = is_date_younger($global_var_href, $mouse, $date);
     	
     	if ($is_date_younger > 0) {
        	$warning = span({-class=>"red"}, "Mouse ".$mouse." is already in an experiment with start datetime younger than your given data! Saving of experiment data is not possible! Please contact your admin!");
        	$submit_enable = 0;
     	}
     }
     
     #is mouse already dead and experiment start date is younger than mouse death date
     $is_dead_atdate = is_mouse_dead_atdate($global_var_href, $mouse, $date);
     	
     if ($is_dead_atdate > 0) {
     	$warning = span({-class=>"red"}, "Mouse ".$mouse." is already dead at experiment start datetime! Saving of experiment data is not possible! Please contact your admin!");
        $submit_enable = 0;
     }

     $page .= Tr({-align=>"center"},
                td(a({-href=>"$url?choice=mouse_details&mouse_id=". $mouse}, &reformat_number($mouse, 8))),
                td(get_earmark($global_var_href, $mouse)),
                td(get_sex($global_var_href, $mouse)),
                td($warning)
              );
  }

  #do not show submit button in case of any error
  $page .= end_table()
           . p()
           . (($submit_enable)
           		?
           		submit(-name => "choice", -value=>"add/change experiment!")
           		:
           		''
           		)
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel adding to experiment (go to previous page)"))
           . end_form();

  return $page;
}
# end of experiment_2
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_EXP003 experiment_3                                  do adding to experiment and display results
sub experiment_3 {                                        my $sr_name = 'SR_EXP003';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};      # DBI database handle
  my ($page, $mouse);
  my $url                  = url();
  my @mice_for_experiment  = ();
  my $experiment           = param('experiment');
  my $errors               = 0;
  my ($experiment_remark, $experiment_name, $error_code);
  my $experiment_start_datetime = param('experiment_start_datetime');

  # check input: is experiment id given? is it a number?
  if (!param('experiment') || param('experiment') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please select a valid experiment"));
     return $page;
  }

  # get experiment name from experiment id
  ($experiment_name) = $dbh->selectrow_array("select experiment_name
                                              from   experiments
                                              where  experiment_id = $experiment
                                             ");

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs (but skip those who already are in an experiment)
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) { # && is_in_experiment($global_var_href, $mouse) < 0) {
        push(@mice_for_experiment, $mouse);
     }
     # else ignore ...
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_for_experiment == 0) {
     $page .= h2("Add mice to experiment or change experiment: 3. step")
              . hr()
              . h3("No mice for experiment chosen (or have been removed from list)")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # date of entering experiment not given or invalid
  if (!param('experiment_start_datetime') || check_datetime_ddmmyyyy_hhmmss(param('experiment_start_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date/time of entering (new) experiment not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is date of entering experiment in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('experiment_start_datetime')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: date/time of entering (new) experiment is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # display results
  $page .= h2("Add mice to experiment or change experiment: 3. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("Trying to add experiment information")
           . hidden(-name=>'experiment')
           . hidden(-name=>'experiment_start_datetime')
           . hidden(-name=>'mouse_select')
           . start_table({-border=>1, -summary=>"table"})
           . Tr(
               th("mouse id"),
               th("ear"),
               th("sex"),
               th("experiment"),
               th("remark")
             );

  # one table row for each mouse
  foreach $mouse (@mice_for_experiment) {

     # do database transaction for this mouse and get result
     ($error_code, $experiment_remark) = add_mouse_to_experiment($global_var_href, $mouse, $experiment, format_display_datetime2sql_datetime(param('experiment_start_datetime')));

     $page .= Tr({-align=>"center"},
                td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse}, $mouse)),
                td(get_earmark($global_var_href, $mouse)),
                td(get_sex($global_var_href, $mouse)),
                td($experiment_name),
                td({-align=>"left"}, $experiment_remark)
              );
  }

  $page .= end_table()
           . end_form()

           . p("All done (please check remarks for error messages).");

  return $page;
}
# end of experiment_3
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_EXP004 add_mouse_to_experiment                  do database transaction for this mouse and get result
sub add_mouse_to_experiment {                        my $sr_name = 'SR_EXP004';
  my $global_var_href               = $_[0];              # get reference to global vars hash
  my $mouse_id                      = $_[1];              # mouse_id              (-> m2e_mouse_id        )
  my $experiment_id                 = $_[2];              # experiment_id         (-> m2e_experiment_id   )
  my $experiment_start_datetime_sql = $_[3];              # experiment_start_date (-> m2e_experiment_from )
  my $dbh     = $global_var_href->{'dbh'};                # DBI database handle
  my $session = $global_var_href->{'session'};            # session handle
  my $datetime_now     = get_current_datetime_for_sql();
  my $user_id = $session->param('user_id');
  my ($previous_experiment, $in_this_experiment, $status);
  my ($rc, $sql);
  my $birth_datetime_sql;

  # 1. check mouse_id for formally being a MausDB ID
  if (!defined($mouse_id) || $mouse_id !~ /^[0-9]{8}$/) {
     return (1, span({-class=>'red'}, "ignored (invalid mouse id)"));
  }

#   # 2. check mouse for already being in an experiment
#   if (is_in_experiment($global_var_href, $mouse_id) > 0) {
#      return (1, span({-class=>'red'}, "ignored (already is in experiment)"));
#   }

  # 3. get date of birth to prevent experiment_date < birth_date
  ($birth_datetime_sql) = $dbh->selectrow_array("select mouse_birth_datetime
                                                 from   mice
                                                 where  mouse_id = $mouse_id
                                                ");

  # check if experiment_date < birth_date: if so, return with error
  if (Delta_ddmmyyyhhmmss(format_sql_datetime2display_datetime($experiment_start_datetime_sql), format_sql_datetime2display_datetime($birth_datetime_sql)) eq 'future') {
     return (1, span({-class=>'red'}, "ignored (date of experiment start cannot be before date of birth)"));
  }

  # try to get a lock
  &get_semaphore_lock($global_var_href, $user_id);

  ############################################################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start experiment transaction)", $sr_name . "-" . __LINE__);

  # is mouse currently in an experiment?
  ($previous_experiment) = $dbh->selectrow_array("select  m2e_experiment_id
                                                  from    mice2experiments
                                                  where   m2e_mouse_id = $mouse_id
                                                          and m2e_datetime_to IS NULL
                                                 ");

  # mouse cannot be in the same experiment twice without interruption
  if (defined($previous_experiment) && $previous_experiment == $experiment_id) {
       $status = span({-class=>'red'}, "skipped (new experiment is same to current experiment)");
  }
  # mouse is currently in an experiment (previous experiment defined) and changes into new experiment
  elsif (defined($previous_experiment) && $previous_experiment != $experiment_id) {
    # stop previous experiment
    $dbh->do("update mice2experiments
              set    m2e_datetime_to = ?, m2e_inserted_by = ?
              where  m2e_mouse_id = ?
                     and m2e_experiment_id = ?
             ", undef, "$experiment_start_datetime_sql", $user_id, $mouse_id, $previous_experiment
            ) or &error_message_and_exit($global_var_href, "SQL error (could not update experiment)", $sr_name . "-" . __LINE__);

    # start new experiment
     $dbh->do("insert
               into   mice2experiments (m2e_experiment_id, m2e_mouse_id, m2e_datetime_from, m2e_datetime_to, m2e_inserted_by, m2e_inserted_at)
               values (?, ?, ?, NULL, ?, NULL)
              ", undef, $experiment_id, $mouse_id,  "$experiment_start_datetime_sql", $user_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert experiment)", $sr_name . "-" . __LINE__);

     $status = "changed experiment";
  }
  # mouse is currently not in an experiment (no previous experiment defined)
  elsif (!defined($previous_experiment)) {
     $dbh->do("insert
               into   mice2experiments (m2e_experiment_id, m2e_mouse_id, m2e_datetime_from, m2e_datetime_to, m2e_inserted_by, m2e_inserted_at)
               values (?, ?, ?, NULL, ?, NULL)
              ", undef, $experiment_id, $mouse_id,  "$experiment_start_datetime_sql", $user_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert experiment)", $sr_name . "-" . __LINE__);

     $status = "added mouse to experiment";
  }

  $rc = $dbh->commit or &error_message_and_exit($global_var_href, "SQL error (could not commit experiment transaction)", $sr_name . "-" . __LINE__);

  # end of transaction
  ############################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $user_id);

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tadd_mouse_to_experiment\t$mouse_id\t$experiment_id\t$experiment_start_datetime_sql");

  return (0, $status);
}
# end of add_mouse_to_experiment
#--------------------------------------------------------------------------------------



# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;