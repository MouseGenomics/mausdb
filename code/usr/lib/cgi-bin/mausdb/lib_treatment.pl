# lib_treatment.pl - a MausDB subroutine library file                                                                                 #
#                                                                                                                                     #
# Subroutines in this file provide functions related to treatments on mice                                                            #
#                                                                                                                                     #
#-------------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                                 #
#-------------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                     #
# SR_TRE001 add_treatment_1                               add treatment to mice (step 1: initial form)                                #
# SR_TRE002 add_treatment_2                               confirm adding treatment (step 2: confirmation form)                        #
# SR_TRE003 add_treatment_3                               assign treatments to mice and display results (step 3: do it, show result)  #
# SR_TRE004 add_treatment_4                               do database transaction for this mouse and get result                       #
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
# SR_TRE001 add_treatment_1                               add treatment to mice (step 1: initial form)
sub add_treatment_1 {                                     my $sr_name = 'SR_TRE001';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $session           = $global_var_href->{'session'};   # session handle
  my $user_id           = $session->param('user_id');
  my ($page, $sql, $result, $rows, $row, $i);
  my $url           = url();
  my @mice_to_treat = ();
  my @values        = ();
  my ($popup, $mouse);
  my @sql_parameters;

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_treat, $mouse);
     }
     # else ignore ...
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_to_treat == 0) {
     $page .= h2("Add treatment to mice")
              . hr()
              . h3("No mice to treat")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # display form
  $page .= h2("Add treatment to mice: 1. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("Specify treatment for mice ... ")
           . table( {-border=>1, -summary=>"treatment_table"},
               Tr(
                 th({-bgcolor=>'lightblue'}, "Treatment protocol "),
                 td(get_treatments_popup_menu($global_var_href))
               ) .
               Tr(
                 th({-bgcolor=>'lightblue'}, "Treatment by "),
                 td(get_users_popup_menu($global_var_href, $user_id, 'treatment_user'))
               )
             )

           . p()

           . hidden(-name=>'mouse_select') . "\n"
           . start_table({-border=>1, -summary=>"mouse_table"})
           . Tr({-bgcolor=>'lightblue'},
               th({-rowspan=>2}, "mouse id"),
               th({-rowspan=>2}, "ear"),
               th({-rowspan=>2}, "sex"),
               th({-rowspan=>2}, "cage"),
               th({-rowspan=>2}, "date and time " . br() . "(single treatment)"),
               th({-colspan=>2}, "time period (for multiple treatments)"),
               th({-colspan=>2}, "[applied substance]"),
               th({-rowspan=>2}, "success? "),
               th({-rowspan=>2}, "failure reason"),
               th({-rowspan=>2}, "comment")
             ) .
             Tr({-bgcolor=>'lightblue'},
               th("from"),
               th("to"),
               th("amount"),
               th("unit")
             );

  # one table row for each mouse
  foreach $mouse (@mice_to_treat) {
     $page .= Tr({-align=>"center"},
                td({-bgcolor=>'#DCDCDC'}, $mouse),
                td({-bgcolor=>'#DCDCDC'}, get_earmark($global_var_href, $mouse)),
                td({-bgcolor=>'#DCDCDC'}, get_sex($global_var_href, $mouse)),
                td({-bgcolor=>'#DCDCDC'}, ((get_cage($global_var_href, $mouse)>0)?reformat_number(get_cage($global_var_href, $mouse), 4):'-')),
                td(textfield(-name=>"treatment_datetime_$mouse", -id=>"treatment_datetime_$mouse", -size=>"20", -maxlength=>"21",
                             -value=>''
                   )
                   . "&nbsp;&nbsp;"
                   . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=treatment_datetime_$mouse', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                ),
                td(textfield(-name=>"treatment_start_$mouse", -id=>"treatment_start_$mouse", -size=>"20", -maxlength=>"21",
                             -value=>''
                   )
                   . "&nbsp;&nbsp;"
                   . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=treatment_start_$mouse', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                ),
                td(textfield(-name=>"treatment_end_$mouse", -id=>"treatment_end_$mouse", -size=>"20", -maxlength=>"21",
                             -value=>''
                   )
                   . "&nbsp;&nbsp;"
                   . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=treatment_end_$mouse', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                ),
                td(textfield(-name=>"amount_$mouse",         -size=>"6", -maxlength=>"10", -value=>'')),
                td(textfield(-name=>"amount_unit_$mouse",    -size=>"6", -maxlength=>"10", -value=>'')),
                td(radio_group(-name=>"success_$mouse", -values=>['y', 'n'], -default=>'y')),
                td(textfield(-name=>"failure_reason_$mouse", -size=>"20", -maxlength=>"254", -value=>'')),
                td(textfield(-name=>"comment_$mouse",        -size=>"20", -maxlength=>"254", -value=>''))
              );
  }

  $page .= end_table()
           . p()
           . submit(-name => "choice", -value=>"confirm adding treatment")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel adding treatment (go to previous page)"))
           . end_form();

  return $page;
}
# end of add_treatment_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_TRE002 add_treatment_2                               confirm adding treatment (step 2: confirmation form)
sub add_treatment_2 {                                     my $sr_name = 'SR_TRE002';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $mouse);
  my $url           = url();
  my @mice_to_treat = ();
  my @values        = ();
  my $errors        = 0;

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_treat, $mouse);
     }
     # else ignore ...
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_to_treat == 0) {
     $page .= h2("Add treatment to mice")
              . hr()
              . h3("No mice to treat")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # display form
  $page .= h2("Add treatment to mice: 2. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("Please confirm")
           . hidden(-name=>'mouse_select')
           . hidden(-name=>'treatment_user')
           . hidden(-name=>'treatment_protocol')

           . start_table({-border=>1, -summary=>"mouse_table"})
           . Tr({-bgcolor=>'lightblue'},
               th({-rowspan=>2}, "mouse id"),
               th({-rowspan=>2}, "ear"),
               th({-rowspan=>2}, "sex"),
               th({-rowspan=>2}, "cage"),
               th({-rowspan=>2}, "date and time " . br() . "(single treatment)"),
               th({-colspan=>2}, "time period (for multiple treatments)"),
               th({-colspan=>2}, "[applied substance]"),
               th({-rowspan=>2}, "success? "),
               th({-rowspan=>2}, "failure reason"),
               th({-rowspan=>2}, "comment")
             ) .
             Tr({-bgcolor=>'lightblue'},
               th("from"),
               th("to"),
               th("amount"),
               th("unit")
             );

  # one table row for each mouse
  foreach $mouse (@mice_to_treat) {
     $page .= Tr({-align=>"center"},
                td({-bgcolor=>'#DCDCDC'}, $mouse),
                td({-bgcolor=>'#DCDCDC'}, get_earmark($global_var_href, $mouse)),
                td({-bgcolor=>'#DCDCDC'}, get_sex($global_var_href, $mouse)),
                td({-bgcolor=>'#DCDCDC'}, ((get_cage($global_var_href, $mouse)>0)?reformat_number(get_cage($global_var_href, $mouse), 4):'-')),
                td(param("treatment_datetime_$mouse")
                   . hidden(-name=>"treatment_datetime_$mouse", -value=>param("treatment_datetime_$mouse"), -override=>1)
                ),
                td(param("treatment_start_$mouse")
                   . hidden(-name=>"treatment_start_$mouse",    -value=>param("treatment_start_$mouse"),    -override=>1)
                ),
                td(param("treatment_end_$mouse")
                   . hidden(-name=>"treatment_end_$mouse",      -value=>param("treatment_end_$mouse"),      -override=>1)
                ),
                td(param("amount_$mouse")
                   . hidden(-name=>"amount_$mouse",             -value=>param("amount_$mouse"),             -override=>1)
                ),
                td(param("amount_unit_$mouse")
                   . hidden(-name=>"amount_unit_$mouse",        -value=>param("amount_unit_$mouse"),        -override=>1)
                ),
                td(param("success_$mouse")
                   . hidden(-name=>"success_$mouse",            -value=>param("success_$mouse"),            -override=>1)
                ),
                td(param("failure_reason_$mouse")
                   . hidden(-name=>"failure_reason_$mouse",     -value=>param("failure_reason_$mouse"),     -override=>1)
                ),
                td(param("comment_$mouse")
                   . hidden(-name=>"comment_$mouse",            -value=>param("comment_$mouse"),            -override=>1)
                )
              );
  }

  $page .= end_table()

           . p()

           . submit(-name => "choice", -value=>"add treatment!")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel adding treatment (go to previous page)"))

           . end_form();

  return $page;
}
# end of add_treatment_2
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_TRE003 add_treatment_3                               assign treatments to mice and display results (step 3: do it and show result)
sub add_treatment_3 {                                     my $sr_name = 'SR_TRE003';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $mouse);
  my $url           = url();
  my @mice_to_treat = ();
  my @values        = ();
  my $errors        = 0;
  my ($error_code, $treatment_remark);

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_treat, $mouse);
     }
     # else ignore ...
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_to_treat == 0) {
     $page .= h2("Add treatment to mice")
              . hr()
              . h3("No mice to treat")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # display form
  $page .= h2("Add treatment to mice: 3. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("Please confirm")
           . hidden(-name=>'mouse_select')

           . start_table({-border=>1, -summary=>"mouse_table"})
           . Tr({-bgcolor=>'lightblue'},
               th({-rowspan=>2}, "mouse id"),
               th({-rowspan=>2}, "ear"),
               th({-rowspan=>2}, "sex"),
               th({-rowspan=>2}, "cage"),
               th({-rowspan=>2}, "date and time " . br() . "(single treatment)"),
               th({-colspan=>2}, "time period (for multiple treatments)"),
               th({-colspan=>2}, "[applied substance]"),
               th({-rowspan=>2}, "success? "),
               th({-rowspan=>2}, "failure reason"),
               th({-rowspan=>2}, "comment"),
               th({-rowspan=>2}, "remark")
             ) .
             Tr({-bgcolor=>'lightblue'},
               th("from"),
               th("to"),
               th("amount"),
               th("unit")
             );

  # one table row for each mouse
  foreach $mouse (@mice_to_treat) {

     # do database transaction for this mouse and get result
     ($error_code, $treatment_remark) = add_treatment_4($global_var_href, $mouse, param('treatment_user'), param('treatment_protocol'),
                                                        param("treatment_datetime_$mouse"), param("treatment_start_$mouse"),
                                                        param("treatment_end_$mouse"), param("amount_$mouse"), param("amount_unit_$mouse"),
                                                        param("success_$mouse"), param("failure_reason_$mouse"), param("comment_$mouse")
                                        );

     $page .= Tr({-align=>"center"},
                td({-bgcolor=>'#DCDCDC'}, $mouse),
                td({-bgcolor=>'#DCDCDC'}, get_earmark($global_var_href, $mouse)),
                td({-bgcolor=>'#DCDCDC'}, get_sex($global_var_href, $mouse)),
                td({-bgcolor=>'#DCDCDC'}, ((get_cage($global_var_href, $mouse)>0)?reformat_number(get_cage($global_var_href, $mouse), 4):'-')),
                td(param("treatment_datetime_$mouse")),
                td(param("treatment_start_$mouse")),
                td(param("treatment_end_$mouse")),
                td(param("amount_$mouse")),
                td(param("amount_unit_$mouse")),
                td(param("success_$mouse")),
                td(param("failure_reason_$mouse")),
                td(param("comment_$mouse")),
                td($treatment_remark)
              );
  }

  $page .= end_table()
           . end_form()

           . p("Treatment added to mice. You may view mice with added treatment " . a({-href=>"$url?choice=Search%20by%20mouse%20IDs&mouse_ids=" . join(',', @mice_to_treat)}, "here"));

  return $page;
}
# end of add_treatment_3
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_TRE004 add_treatment_4                               do database transaction for this mouse and get result
sub add_treatment_4 {                                     my $sr_name = 'SR_TRE004';
  my $global_var_href    = $_[0];                         # get reference to global vars hash
  my $mouse_id           = $_[1];
  my $treatment_user     = $_[2];
  my $treatment_protocol = $_[3];
  my $treatment_datetime = $_[4];
  my $treatment_start    = $_[5];
  my $treatment_end      = $_[6];
  my $amount             = $_[7];
  my $amount_unit        = $_[8];
  my $success            = $_[9];
  my $failure_reason     = $_[10];
  my $comment            = $_[11];
  my $dbh             = $global_var_href->{'dbh'};        # DBI database handle
  my $session         = $global_var_href->{'session'};    # session handle
  my $user_id         = $session->param('user_id');
  my ($status);
  my ($rc, $sql);
  my $datetime_sql = get_current_datetime_for_sql();      # get current system time

  # check mouse_id for formally being a MausDB ID
  if (!defined($mouse_id) || $mouse_id !~ /^[0-9]{8}$/) {
     return (1, "ignored (invalid mouse id)");
  }

  ############################################################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start add treatment transaction)", $sr_name . "-" . __LINE__);

  $dbh->do("insert
            into mice2treatment_procedures (m2tp_id, m2tp_mouse_id, m2tp_treatment_procedure_id, m2tp_treatment_datetime, m2tp_applied_amount,
                                            m2tp_applied_amount_unit, m2tp_application_start_datetime, m2tp_application_end_datetime,
                                            m2tp_treatment_success, m2tp_application_terminated_why, m2tp_treatment_user_id, m2tp_application_comment)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
           ", undef, undef, $mouse_id, $treatment_protocol, format_display_datetime2sql_datetime($treatment_datetime), $amount,
                     $amount_unit, format_display_datetime2sql_datetime($treatment_start), format_display_datetime2sql_datetime($treatment_end),
                     $success, $failure_reason, $treatment_user, $comment
        ) or &error_message_and_exit($global_var_href, "SQL error (could not add treatment)", $sr_name . "-" . __LINE__);

  $status = "treatment added";

  $rc = $dbh->commit or &error_message_and_exit($global_var_href, "SQL error (could not commit add treatment transaction)", $sr_name . "-" . __LINE__);

  # end of transaction
  ############################################################################################

  &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tadd_treatment\t$mouse_id\t$treatment_protocol\t");

  return (0, $status);
}
# end of add_treatment_4
#--------------------------------------------------------------------------------------



# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;