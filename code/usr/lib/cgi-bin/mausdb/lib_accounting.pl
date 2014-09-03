# lib_accounting.pl - a MausDB subroutine library file                                                                                #
#                                                                                                                                     #
# Subroutines in this file provide functions related to cost accounting                                                               #
#                                                                                                                                     #
#-------------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                                 #
#-------------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                     #
# SR_ACC001 cost_centre_1                                 add/change cost centre (step 1: form)                                       #
# SR_ACC002 cost_centre_2                                 confirm add/change cost centre                                              #
# SR_ACC003 cost_centre_3                                 do adding to cost centre and display results                                #
# SR_ACC004 add_mouse_to_cost_centre                      do database transaction for this mouse and get result                       #
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
# SR_ACC001 cost_centre_1                                 add/change cost centre (step 1: form)
sub cost_centre_1 {                                       my $sr_name = 'SR_ACC001';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $sql, $result, $rows, $row, $i);             # standard variables for prepared HTML, prepared SQL and SQL query result handling
  my $url = url();                                        # get URL from which script was called
  my @mice_for_cost_centre = ();
  my ($popup, $mouse, $warning, $is_assigned_to_cost_centre);

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs (-> 8 digit numbers)
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_for_cost_centre, $mouse);
     }
     # else ignore...
  }

  # stop if mouse list is empty (-> no mice selected)
  if (scalar @mice_for_cost_centre == 0) {
     $page .= h2("Add mice to cost centre or change cost centre")
              . hr()
              . h3("No mice for cost centre chosen")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));

     return $page;
  }

  # display form
  $page .= h2("Add mice to cost centre or change cost centre: 1. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("Please choose the cost entre you wish chosen mice to be added or changed to ("
                . a({-href=>"$url?choice=cost_centre_overview", -title=>'click to see all cost centres in new window', -target=>'_blank'}, 'see cost centres overview')
                . ')'
             )
           . table( {-border=>1},
                Tr( td({-align=>'center'}, b("Cost centre ")),
                    td(get_cost_centre_popup_menu($global_var_href))
                ) .
                Tr( td({-align=>'center'}, b("Date") . br() . small('(at which mice entered (new) cost centre)')),
                    td(textfield(-name => "cost_centre_start_datetime", -id=>"cost_centre_start_datetime", -size=>"20", -maxlength=>"21", -value=>get_current_datetime_for_display())
                       . "&nbsp;&nbsp;"
                       . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=cost_centre_start_datetime', 480, 480, 400, 200, 'no')", -title=>"click for calender"},
                           img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'})
                         )
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
               th("cost centre")
             );

  # loop over mice
  foreach $mouse (@mice_for_cost_centre) {

     $warning = '';                   # reset warning

     # check if current mouse is already assigned to a cost centre
     $is_assigned_to_cost_centre = is_assigned_to_cost_centre($global_var_href, $mouse);

     # display warning if mouse already is assigned to cost centre
     if ($is_assigned_to_cost_centre > 0) {
        $warning = span({-class=>"red"}, "mouse already is assigned to a cost centre. If you continue, the cost centre will be updated.");
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
           . submit(-name => "choice", -value=>"confirm cost centre")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel adding to or change of cost centre (go to previous page)"))
           . end_form();

  return $page;
}
# end of cost_centre_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ACC002 cost_centre_2                                 confirm add/change cost centre
sub cost_centre_2 {                                       my $sr_name = 'SR_ACC002';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};      # DBI database handle
  my $cost_centre_start_datetime = param('cost_centre_start_datetime');
  my $cost_centre                = param('cost_centre');
  my $url                        = url();                 # get URL from which script was called
  my @mice_for_cost_centre       = ();
  my $errors                     = 0;
  my $page;                                               # standard variable for prepared HTML
  my ($mouse, $cost_centre_name);
  my ($warning, $submit_enable);

  # check input: is cost centre id given? is it a number?
  if (!param('cost_centre') || param('cost_centre') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please select a valid cost centre"));
     return $page;
  }

  # get cost centre name from cost centre id
  ($cost_centre_name) = $dbh->selectrow_array("select cost_account_name
                                               from   cost_accounts
                                               where  cost_account_id = $cost_centre
                                              ");

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  $submit_enable = 1;

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_for_cost_centre, $mouse);
     }
     # else ignore ...
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_for_cost_centre == 0) {
     $page .= h2("Add mice to cost centre or change cost centre: 2. step")
              . hr()
              . h3("No mice for cost centre chosen (or have been removed from list)")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }


  # date of entering cost centre not given or invalid
  if (!param('cost_centre_start_datetime') || check_datetime_ddmmyyyy_hhmmss(param('cost_centre_start_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date/time of entering (new) cost centre not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is date of entering cost centre in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('cost_centre_start_datetime')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: date/time of entering (new) cost centre is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # display confirmation page
  $page .= h2("Add mice to cost centre or change centre: 2. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3(qq(Please confirm adding the mice listed below to cost centre "$cost_centre_name" at "$cost_centre_start_datetime"))
           . hidden(-name=>'cost_centre')
           . hidden(-name=>'cost_centre_start_datetime')
           . hidden(-name=>'mouse_select')
           . start_table({-border=>1, -summary=>"table"})
           . Tr(
               th("mouse id"),
               th("ear"),
               th("sex"),
               th("remark")
             );

  # loop over mice
  foreach $mouse (@mice_for_cost_centre) {

	$warning = 'ok';

	#is mouse already dead and start date is younger than mouse death date
    my $date = format_display_datetime2sql_datetime(param('cost_centre_start_datetime'));
    my $is_dead_atdate = is_mouse_dead_atdate($global_var_href, $mouse, $date);
     	
    if ($is_dead_atdate > 0) {
    	$warning = span({-class=>"red"}, "Mouse ".$mouse." is already dead at start datetime! Saving of data is not possible! Please contact your admin!");
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
           		submit(-name => "choice", -value=>"add/change cost centre!")
           		:
           		''
           		)
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel adding to cost centre (go to previous page)"))
           . end_form();


  return $page;
}
# end of cost_centre_2
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ACC003 cost_centre_3                                 do adding to cost centre and display results
sub cost_centre_3 {                                       my $sr_name = 'SR_ACC003';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};      # DBI database handle
  my $cost_centre                = param('cost_centre');
  my $cost_centre_start_datetime = param('cost_centre_start_datetime');
  my $page;                                               # standard variable for prepared HTML
  my $url                  = url();                       # get URL from which script was called
  my @mice_for_cost_centre = ();
  my $errors               = 0;
  my ($cost_centre_remark, $cost_centre_name, $error_code, $mouse);

  # check input: is cost centre id given? is it a number?
  if (!param('cost_centre') || param('cost_centre') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please select a valid cost centre"));
     return $page;
  }

  # get cost centre name from cost centre id
  ($cost_centre_name) = $dbh->selectrow_array("select cost_account_name
                                               from   cost_accounts
                                               where  cost_account_id = $cost_centre
                                              ");

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_for_cost_centre, $mouse);
     }
     # else ignore ...
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_for_cost_centre == 0) {
     $page .= h2("Add mice to cost centre or change cost centre: 3. step")
              . hr()
              . h3("No mice for cost centre chosen (or have been removed from list)")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # date of entering cost centre not given or invalid
  if (!param('cost_centre_start_datetime') || check_datetime_ddmmyyyy_hhmmss(param('cost_centre_start_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date/time of entering (new) cost centre not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is date of entering cost centre in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('cost_centre_start_datetime')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: date/time of entering (new) cost centre is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # display results
  $page .= h2("Add mice to cost centre or change cost centre: 3. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("Trying to add cost centre information")
           . hidden(-name=>'cost_centre')
           . hidden(-name=>'cost_centre_start_datetime')
           . hidden(-name=>'mouse_select')
           . start_table({-border=>1, -summary=>"table"})
           . Tr(
               th("mouse id"),
               th("ear"),
               th("sex"),
               th("cost centre"),
               th("remark")
             );

  # loop over mice
  foreach $mouse (@mice_for_cost_centre) {

     # do database transaction for this mouse and get result
     ($error_code, $cost_centre_remark) = add_mouse_to_cost_centre($global_var_href, $mouse, $cost_centre, format_display_datetime2sql_datetime(param('cost_centre_start_datetime')));

     $page .= Tr({-align=>"center"},
                td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse}, $mouse)),
                td(get_earmark($global_var_href, $mouse)),
                td(get_sex($global_var_href, $mouse)),
                td($cost_centre_name),
                td({-align=>"left"}, $cost_centre_remark)
              );
  }

  $page .= end_table()
           . end_form()

           . p("All done (please check remarks for error messages).");

  return $page;
}
# end of cost_centre_3
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ACC004 add_mouse_to_cost_centre                      do database transaction for this mouse and get result
sub add_mouse_to_cost_centre {                            my $sr_name = 'SR_ACC004';
  my $global_var_href                = $_[0];             # get reference to global vars hash
  my $mouse_id                       = $_[1];             # mouse_id               (-> m2ca_mouse_id          )
  my $cost_centre                    = $_[2];             # cost_centre            (-> m2ca_cost_account_id   )
  my $cost_centre_start_datetime_sql = $_[3];             # cost_centre_start_date (-> m2ea_cost_centre_from  )
  my $dbh          = $global_var_href->{'dbh'};           # DBI database handle
  my $session      = $global_var_href->{'session'};       # session handle
  my $user_id      = $session->param('user_id');          # user id of current user
  my $datetime_now = get_current_datetime_for_sql();
  my ($previous_cost_centre, $in_this_cost_centre, $status);
  my ($sql, $rc);                                         # prepared SQL and return code
  my $birth_datetime_sql;

  # check mouse_id for formally being a MausDB ID
  if (!defined($mouse_id) || $mouse_id !~ /^[0-9]{8}$/) {
     return (1, span({-class=>'red'}, "ignored (invalid mouse id)"));
  }

  # get date of birth to prevent cost_centre_date < birth_date
  ($birth_datetime_sql) = $dbh->selectrow_array("select mouse_birth_datetime
                                                 from   mice
                                                 where  mouse_id = $mouse_id
                                                ");

  # check if cost_centre_date < birth_date: if so, return with error
  if (Delta_ddmmyyyhhmmss(format_sql_datetime2display_datetime($cost_centre_start_datetime_sql), format_sql_datetime2display_datetime($birth_datetime_sql)) eq 'future') {
     return (1, span({-class=>'red'}, "ignored (date of cost centre start cannot be before date of birth)"));
  }

  # try to get a lock
  &get_semaphore_lock($global_var_href, $user_id);

  ############################################################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start cost centre transaction)", $sr_name . "-" . __LINE__);

  # is mouse currently assigned to a cost centre?
  ($previous_cost_centre) = $dbh->selectrow_array("select  m2ca_cost_account_id
                                                   from    mice2cost_accounts
                                                   where   m2ca_mouse_id = $mouse_id
                                                           and m2ca_datetime_to IS NULL
                                                  ");

  # mouse cannot be in the same cost centre twice without interruption
  if (defined($previous_cost_centre) && $previous_cost_centre == $cost_centre) {
       $status = span({-class=>'red'}, "skipped (new cost centre is same to current cost centre)");
  }
  # mouse is currently assigned to a cost centre (previous cost centre defined) and changes into new cost centre
  elsif (defined($previous_cost_centre) && $previous_cost_centre != $cost_centre) {
    # stop previous cost centre
    $dbh->do("update mice2cost_accounts
              set    m2ca_datetime_to = ?
              where  m2ca_mouse_id = ?
                     and m2ca_cost_account_id = ?
             ", undef, "$cost_centre_start_datetime_sql", $mouse_id, $previous_cost_centre
            ) or &error_message_and_exit($global_var_href, "SQL error (could not update cost centre)", $sr_name . "-" . __LINE__);

    # start new cost centre
     $dbh->do("insert
               into   mice2cost_accounts (m2ca_cost_account_id, m2ca_mouse_id, m2ca_datetime_from, m2ca_datetime_to)
               values (?, ?, ?, NULL)
              ", undef, $cost_centre, $mouse_id,  "$cost_centre_start_datetime_sql"
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert cost centre)", $sr_name . "-" . __LINE__);

     $status = "changed cost centre";
  }
  # mouse is currently not assigned to a cost centre (no previous cost centre defined)
  elsif (!defined($previous_cost_centre)) {
     $dbh->do("insert
               into   mice2cost_accounts (m2ca_cost_account_id, m2ca_mouse_id, m2ca_datetime_from, m2ca_datetime_to)
               values (?, ?, ?, NULL)
              ", undef, $cost_centre, $mouse_id,  "$cost_centre_start_datetime_sql"
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert cost centre)", $sr_name . "-" . __LINE__);

     $status = "added mouse to cost centre";
  }

  $rc = $dbh->commit or &error_message_and_exit($global_var_href, "SQL error (could not commit cost centre transaction)", $sr_name . "-" . __LINE__);

  # end of transaction
  ############################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $user_id);

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tadd_mouse_to_cost_centre\t$mouse_id\t$cost_centre\t$cost_centre_start_datetime_sql");

  return (0, $status);
}
# end of add_mouse_to_cost_centre
#--------------------------------------------------------------------------------------



# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;