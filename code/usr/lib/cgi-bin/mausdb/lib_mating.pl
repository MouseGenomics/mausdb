# lib_mating.pl - a MausDB subroutine library file                                                                               #
#                                                                                                                                #
# Subroutines in this file provide functions related to setup, manage and stop matings                                           #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_MAT001 new_mating():                                set up a new mating (1. step)                                           #
# SR_MAT002 db_set_up_mating():                          set up a new mating (2. step)                                           #
# SR_MAT003 report_litter():                             report new litter (1. step)                                             #
# SR_MAT004 remove_parent_from_mating_1():               remove parent from a mating                                             #
# SR_MAT005 report_litter_loss():                        report litter loss (1. step)                                            #
# SR_MAT006 new_embryotransfer():                        set up a new embryotransfer (1. step)                                   #
# SR_MAT007 db_set_up_transfer():                        set up a new transfer (2. step)                                         #
# SR_MAT008 update_litter_details():                     update litter details (1. step)                                         #
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
# SR_MAT001 new_mating():                                set up a new mating (1. step)
sub new_mating {                                         my $sr_name = 'SR_MAT001';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $move_mode         = param('move_mode');
  my ($current_mating, $warning, $sex, $strain_default, $line_default, $location, $is_in_experiment);
  my ($page, $mouse);
  my %sex_counter         = ('m' => 0, 'f' => 0);
  my %radio_labels        = ("screen" => "", "all" => "");
  my %radio_labels_screen = ("user_only" => "", "all" => "");
  my $url                 = url();
  my @mice_to_be_mated    = ();
  my $errors              = 0;
  my %strain_counter;
  my @strains;
  my %line_counter;
  my @lines;

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB ids
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_mated, $mouse);
     }
     # else ignore ...
  }

  # delete the list of selected mice (this is a CGI.pm method)
  Delete('mouse_select');

  # exit if no mice selected for mating
  if (scalar @mice_to_be_mated == 0) {
     $page .= h2("New mating")
              . hr()
              . h3("No mice to mate")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # else continue
  $page .= h2("New mating")
           . hr()
           . h3("Checking mating partners")
           . start_form(-action=>url(), -name=>"myform")
           . "<ul>";

  # get move_mode (automatically move mating partners into mating cage or not)
  if (defined(param('move_mode')) && param('move_mode') eq 'no_move') {
      $page .= hidden('move_mode');
  }
  else {
     $move_mode = 'move';
  }

  # display all selected mice and check if they can be mated at all
  foreach $mouse (@mice_to_be_mated) {
     # rewrite mouse to hidden field
     $page .= hidden(-name=>'mouse_select', -value=>"$mouse");

     $warning = '';

     # check (and count) sex (to avoid more than one male...)
     $sex = get_sex($global_var_href, $mouse);
     $sex_counter{$sex}++;

     # get current rack for this mouse (as default for location selection
     $location = get_location($global_var_href, $mouse);

     # check strain (and count)
     $strain_counter{get_strain($global_var_href, $mouse)}++;

     # check line (and count)
     $line_counter{get_line($global_var_href, $mouse)}++;

     # check if mouse is currently in another mating
     $current_mating = db_is_in_mating($global_var_href, $mouse);

     # females are not allowed to be part of more than one mating
     if (defined($current_mating) && ($sex eq 'f')) {
        $errors++;
        $warning .= span({-class=>"red"}, "Cannot mate: female mouse $mouse is currently in active "
                                          . a({-href=>"$url?choice=mating_view&mating_id=$current_mating", -style=>"color:red;", title=>"click to open mating details in separate window", -target=>"_blank"}, "mating $current_mating")
                                          . "Please remove mouse $mouse from mating $current_mating first."
                        );
     }

     # males can take part in more than one mating. In such cases, display a warning
     elsif (defined($current_mating) && ($sex eq 'm')) {
        $warning .= span({-class=>"red"}, "Warning: male mouse $mouse is currently in active "
                                          . a({-href=>"$url?choice=mating_view&mating_id=$current_mating", -style=>"color:red;", title=>"click to open mating details in separate window", -target=>"_blank"}, "mating $current_mating")
                                          . ". If you continue, a new mating will be set up."
                        );
     }

     # check if mouse is alive at all
     if (defined(get_date_of_death($global_var_href, $mouse))) {
        #$errors++;
        $warning .= span({-class=>"red"}, "Warning: mouse is dead");
     }

     # check if mouse is in an experiment
     $is_in_experiment = is_in_experiment($global_var_href, $mouse);
     if ($is_in_experiment > 0) {
        $warning .= span({-class=>"red"}, "Warning: mouse $mouse is currently in an "
                                          . a({-href=>"$url?choice=experiment_view&experiment_id=$is_in_experiment", -style=>"color:red;", -title=>"click to open experiment details in separate window", -target=>"_blank"}, "experiment")
                                          . ". Are you sure you want to mate this mouse?"
                        );
     }

     # OPTIONAL TO DO: check min-max age

     $page .= li("checking " . (($sex eq 'm')?'&nbsp;&nbsp;male':'female') .  " mouse " . a( {-href=>"$url?choice=mouse_details&mouse_id=" . $mouse}, $mouse) . " for mating ... "
                 . (($warning eq '')?'ok':$warning)
                );
  }

  $page .= "</ul>";

  # check if at least one of the mating partner cannot be mated, regardless of its sex
  if ($errors > 0) {
     $page .= h3({-class=>"red"}, "Mating not possible")
              . p("At least one of the mating partners in your selection cannot be mated. ")
              . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection");
     return $page;
  }

  $warning = '';

  # now make sure, that exactly one male and > 1 females are selected
  if ($sex_counter{'m'} > 1) {
     $errors++;
     $warning .= p("mating with more than one male is not possible");
  }

  # no male...
  if ($sex_counter{'m'} == 0) {
     $errors++;
     $warning .= p("you need a male to set up a new mating");
  }

  # no female
  if ($sex_counter{'f'} == 0) {
     $errors++;
     $warning .= p("you need at least one female to set up a new mating");
  }

  # do not allow more than four females
  if ($sex_counter{'f'} > 4) {
     $errors++;
     $warning .= p({-class=>"red"}, "Cannot set up mating with more than five mice (exceeds cage capacity)");
  }

  # warn if more than two females
  if ($sex_counter{'f'} > 2) {
     $warning .= p({-class=>"red"}, "Warning: Are you sure you want to select $sex_counter{'f'} females for the new mating?");
  }

  # exit if any errors
  if ($errors > 0) {
     $page .= h3({-class=>"red"}, "Mating not possible")
              . $warning
              . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection. ");
     return $page;
  }

  # check if there is more than one strain involved. if not, take the only strain as default for the mating
  @strains = keys %strain_counter;
  if (scalar @strains == 1) {               # only one strain? fine, take that one as default
     $strain_default = $strains[0];
  }
  else {
     $strain_default = get_mating_strain_default($global_var_href, \@mice_to_be_mated);       # more than one strain? get default
     $warning .= p({-class=>"red"}, "Mating partners are from different strains. Please check selected strain. ");
  }

  # check if there is more than one line involved. if not, take the only line as default for the mating
  @lines = keys %line_counter;
  if (scalar @lines == 1) {                 # only one line? fine, take that one as default
     $line_default = $lines[0];
  }
  elsif (scalar @lines == 2) {              # two lines? if one is 'wt', take the other one
     if ($lines[0] == 0) {
        $warning .= p({-class=>"red"}, "Tried to automatically assign line. Please check line. ");
        $line_default = $lines[1];
     }
     elsif ($lines[1] == 0) {
        $warning .= p({-class=>"red"}, "Tried to automatically assign line. Please check line. ");
        $line_default = $lines[0];
     }
     else {
        $line_default = 'please choose';
        $warning .= p({-class=>"red"}, "Mating partners are from different lines. You need to specify the line for the mating (litter) manually. ");
     }
  }
  else {
     $line_default = 'please choose';
     $warning .= p({-class=>"red"}, "Mating partners are from different lines. You need to specify the line for the mating (litter) manually. ");
  }

  $page .= $warning
           . h3("Now specify some mating details")
           . p("Grey fields are mandatory, please check them carefully. White fields are optional and may be left empty.")

           . start_table({-border=>1, -summary=>"table"});

  # display target cage/rack dialog only if mouse is to be moved
  if ($move_mode eq 'move') {
     $page .= Tr({-bgcolor=>"#DDDDDD"},
                td({-align=>"center"}, b("please choose rack for mating cage") . br() . u("or") . br() . checkbox('move_mode', '0', 'no_move', '') . b(" don't move")),
                td({-colspan=>"3"},
                   table({-border=>0, -summary=>"table"},
                        Tr(
                          td(),
                          th("racks from your screen"),
                          th({-colspan=>2}, "or"),
                          th("all racks")
                        ) .
                        Tr(
                          td(radio_group(-name=>'which_racks', -values=>['screen'], -default=>'screen', -labels=>\%radio_labels)),
                          td(span({-onclick=>"document.myform.which_racks[0].checked=true"}, get_locations_popup_menu($global_var_href, $location, 'cage_count', 'screen_racks_only'))),
                          td("&nbsp;&nbsp;&nbsp;&nbsp;"),
                          td(radio_group(-name=>'which_racks', -values=>['all'], -default=>'screen', -labels=>\%radio_labels)),
                          td(span({-onclick=>"document.myform.which_racks[1].checked=true"}, get_locations_popup_menu($global_var_href, $location, 'cage_count')))
                        )
                   )
                )
             );
  }
  else {
     $page .=   hidden(-name=>'which_racks',  -value=>'all')
              . hidden(-name=>'all_racks',    -value=>1)
              . hidden(-name=>'screen_racks', -value=>1);
  }

  $page .=  Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("strain") . br() . small("strain that litter from this mating will be assigned to")),
               td(get_strains_popup_menu($global_var_href, $strain_default)),
               td({-colspan=>"2"}, "if you need a new strain entry, please contact a MausDB administrator")
#                td({-align=>"right", -title=>qq(if you chose "new strain", please propose a name for the new strain)}, qq(&nbsp;&nbsp;&nbsp;[optional: for "new strain" only: name of the new strain] )),
#                td({-title=>qq(if you chose "new strain", please propose a name for the new strain)}, textfield(-name => "new_strain_name", -size=>"20"))
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("line") . br() . small("line that litter from this mating will be assigned to")),
               td(get_lines_popup_menu($global_var_href, $line_default)),
               td({-colspan=>"2"}, "if you need a new line entry, please contact a MausDB administrator")
#                td({-align=>"right", -title=>qq(if you chose "new line", please propose a name for the new line)}, qq(&nbsp;&nbsp;&nbsp;[optional: for "new line" only: name of the new line] )),
#                td({-title=>qq(if you chose "new line", please propose a name for the new line)}, textfield(-name => "new_line_name", -size=>"20"))
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("mating date") . br() . small("date of mating")),
               td({-colspan=>"3"}, textfield(-name => "mating_start_datetime", -id=>"mating_start_datetime", -size=>"20", -maxlength=>"21", -value=>(defined(param('move_datetime')))?param('move_datetime'):get_current_datetime_for_display())
                                   . "&nbsp;&nbsp;"
                                   . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=mating_start_datetime', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
               )
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("mating project") . br() . small("assign a screen/project")),
               td({-colspan=>"3"},
                  table({-border=>0, -summary=>"table"},
                        Tr(
                          td(),
                          th("your screens/projects only"),
                          th({-colspan=>2}, "or"),
                          th("all screens/projects")
                        ) .
                        Tr(
                          td(radio_group(-name=>'which_projects', -values=>['user_only'], -default=>'user_only', -labels=>\%radio_labels_screen)),
                          td(span({-onclick=>"document.myform.which_projects[0].checked=true"}, get_projects_popup_menu($global_var_href, 1, 'user_projects_only'))),
                          td("&nbsp;&nbsp;&nbsp;&nbsp;"),
                          td(radio_group(-name=>'which_projects', -values=>['all'],       -default=>'user_only', -labels=>\%radio_labels_screen)),
                          td(span({-onclick=>"document.myform.which_projects[1].checked=true"}, get_projects_popup_menu($global_var_href, 1, 'all')))
                        )
                  )
               )
             )
           . Tr(
               td({-align=>"center"}, b("[optional: mating name]") . br() . small("give your mating a unique name")),
               td({-colspan=>"3"}, textfield(-name => "mating_name", -size=>"80"))
             )
           . Tr(
               td({-align=>"center"}, b("[optional: mating scheme]") . br() . small("inbred, outcross, ...")),
               td({-colspan=>"3"}, textfield(-name => "mating_scheme", -size=>"80"))
             )
           . Tr(
               td({-align=>"center"}, b("[optional: mating purpose]") . br() . small("your own description")),
               td({-colspan=>"3"}, textfield(-name => "mating_purpose", -size=>"80"))
             )
           . Tr(
               td({-align=>"center"}, b("[optional: generation]") . br() . small("something like F1,F2,...")),
               td({-colspan=>"3"}, textfield(-name => "mating_generation", -size=>"20"))
             )
           . Tr(
               td({-align=>"center"}, b("[optional: comment]") . br() . small("any comment")),
               td({-colspan=>"3"}, textarea(-name=>"mating_comment", -columns=>"80", -rows=>"5"))
             )
           . end_table()

           . p()
           . submit(-name => "choice", -value=>"mate!")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel mating (go to previous page)"))
           . end_form();

  return $page;

}
# end of new_mating()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MAT002 db_set_up_mating():                            set up a new mating (2. step)
sub db_set_up_mating {                                     my $sr_name = 'SR_MAT002';
  my ($global_var_href)  = @_;                              # get reference to global vars hash
  my $dbh                = $global_var_href->{'dbh'};       # DBI database handle
  my $session            = $global_var_href->{'session'};   # session handle
  my $database           = $global_var_href->{'db_name'};   # which database are we working on?
  my $server             = $global_var_href->{'db_server'}; # on which server is the database currently running?
  my $datetime_now       = get_current_datetime_for_sql();
  my $url                = url();
  my $move_mode          = param('move_mode');
  my @selected_mice      = param('mouse_select');           # read list of selected mice from CGI form
  my $which_racks        = param('which_racks');            # switch to decide if target rack selection from 'all_racks' or from 'screen_racks'
  my $all_racks          = param('all_racks');
  my $screen_racks       = param('screen_racks');
  my $which_project      = param('which_projects');         # switch to decide if project selection from 'all_projects' or from 'user_only'
  my $all_projects       = param('all_projects');
  my $user_projects_only = param('user_projects');
  my $mating_strain      = param('strain');
  my $new_strain_name    = param('new_strain_name');
  my $mating_line        = param('line');
  my $new_line_name      = param('new_line_name');
  my $mating_start_datetime     = param('mating_start_datetime');
  my $mating_start_datetime_sql = format_display_datetime2sql_datetime($mating_start_datetime);
  my $mating_start_datetime_url = $mating_start_datetime; $mating_start_datetime_url =~ s/ /%20/g;
  my $mating_name        = param('mating_name');
  my $mating_scheme      = param('mating_scheme');
  my $mating_purpose     = param('mating_purpose');
  my $mating_generation  = param('mating_generation');
  my $mating_comment     = param('mating_comment');
  my %sex_counter        = ('m' => 0, 'f' => 0);
  my $errors             = 0;
  my @mice_to_be_mated   = ();
  my $moved_mouse        = '';
  my $mating_notification= '';
  my $user_id            = $session->param(-name=>'user_id');
  my @user_screens       = get_user_projects($global_var_href, $user_id);
  my ($page, $sql, $mouse, $rc, $warning);
  my ($current_mating, $mating_done, $mating_rack, $mating_project, $mating_cage, $sex, $new_mating_id, $mm, $dd, $yyyy);
  my ($current_cage, $current_rack, $mice_in_mating_cage, $mating_cage_capacity, $mice_in_origin_cage, $is_in_experiment);
  my ($error_code, $error_message, $assigned_mating_cage, $assigned_mating_rack, $number_of_cages, $rack_capacity, $birth_datetime_sql);
  my ($new_strain_id, $new_line_id, $strain_name, $line_name, $new_strain_order, $new_line_order, $cage_of_this_mouse, $last_cage_of_this_mouse, $the_male_cage);
  my ($admin_mail, $mailbody);
  my %mail_to_admin;

  # get move_mode
  if (defined(param('move_mode')) && param('move_mode') eq 'no_move') {
     $page .= hidden('move_mode');
  }
  else {
     $move_mode = 'move';
  }

  # since mating includes moving of mice, include moving library
  require 'lib_move.pl';

#   # if user wants to generate a new strain and/or new line on the fly, we need the mailing module in order to send a mail to the administrators
#   if (get_strain_name_by_id($global_var_href, $mating_strain) eq "new strain" || get_line_name_by_id($global_var_href, $mating_line) eq "new line" ) {
#      use Mail::Sendmail;                                # include mailing module
#
#      ($admin_mail) = $dbh->selectrow_array("select setting_value_text as admin_mail
#                                             from   settings
#                                             where  setting_category='admin'
#                                                    and setting_item='admin_mail'
#                                            ");
#   }

  $page .= h2("New mating: trying to set up new mating in the database")
           . hr();

  # check mating strain
  if (!defined($mating_strain) || get_strain_name_by_id($global_var_href, $mating_strain) eq "choose strain") {
     $page .= p({-class=>"red"}, "please choose a strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # check mating strain
  if ($mating_strain eq 'please choose') {
     $page .= p({-class=>"red"}, "please choose a strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # check mating line
  if (!defined($mating_line) || get_line_name_by_id($global_var_href, $mating_line) eq "choose line") {
     $page .= p({-class=>"red"}, "please choose a line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # check mating line
  if ($mating_line eq 'please choose') {
     $page .= p({-class=>"red"}, "please choose a line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # check target rack info
  if (!defined($which_racks) || !( ($which_racks eq 'screen') || ($which_racks eq 'all') ) ) {
     &error_message_and_exit($global_var_href, "invalid target rack selector", $sr_name . "-" . __LINE__);
  }
  if ($which_racks eq 'screen') {
     if (!defined($screen_racks) || $screen_racks !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid target rack (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $mating_rack = $screen_racks;
     }
  }
  if ($which_racks eq 'all') {
     if (!defined($all_racks) || $all_racks !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid target rack (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $mating_rack = $all_racks;
     }
  }

  # check project info
  if (!defined($which_project) || !( ($which_project eq 'user_only') || ($which_project eq 'all') ) ) {
     &error_message_and_exit($global_var_href, "invalid project selector", $sr_name . "-" . __LINE__);
  }
  if ($which_project eq 'user_only') {
     if (!defined($user_projects_only) || $user_projects_only !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid project id (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $mating_project = $user_projects_only;
     }
  }
  if ($which_project eq 'all') {
     if (!defined($all_projects) || $all_projects !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid project id (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $mating_project = $all_projects;
     }
  }

  # check list of mice to be mated
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_mated, $mouse);
     }
  }

  if (scalar @mice_to_be_mated == 0) {
     $page .= h3("No mice to mate")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_strain_name_by_id($global_var_href, $mating_strain) eq "new strain" && (!defined($new_strain_name) || $new_strain_name eq '')) {
     $page .= p({-class=>"red"}, "You chose \"new strain\", but you did not specify the name of the new strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_line_name_by_id($global_var_href, $mating_line) eq "new line" && (!defined($new_line_name) || $new_line_name eq '')) {
     $page .= p({-class=>"red"}, "You chose \"new line\", but you did not specify the name of the new line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  $page .= h3("Checking mating partners")
           . start_form(-action=>url())   . "\n"
           . "<ul>";

  # again check all mice from selected (they should be ok, since they have been checked before.
  # But 1) a lot can happen before pressing the "mate!" button and 2) we are prepared for users that simply press the browser reload button after setting up a mating
  foreach $mouse (@mice_to_be_mated) {
     $warning = '';

     # 1. check sex
     $sex = get_sex($global_var_href, $mouse);
     $sex_counter{$sex}++;

     # 2. check if mouse is currently in another mating
     $current_mating = db_is_in_mating($global_var_href, $mouse);
     if (defined($current_mating) && ($sex eq 'f')) {
        $errors++;
        $warning .= span({-class=>"red"}, "Cannot mate: female mouse $mouse is currently in active "
                                          . a({-href=>"$url?choice=mating_view&mating_id=$current_mating", -style=>"color:red;", -title=>"click to open mating details in separate window", -target=>"_blank"}, "mating $current_mating")
                                          . "Please remove mouse $mouse from mating $current_mating first."
                        );
     }
     elsif (defined($current_mating) && ($sex eq 'm')) {
        $warning .= span({-class=>"red"}, "Warning: male mouse $mouse is currently in active "
                                          . a({-href=>"$url?choice=mating_view&mating_id=$current_mating", -style=>"color:red;", -title=>"click to open mating details in separate window", -target=>"_blank"}, "mating $current_mating")
                                          . " ."
                        );
     }

     # 3. check if mouse is alive at all
     if (defined(get_date_of_death($global_var_href, $mouse))) {
        #$errors++;                                                             # re-activate to strictly disallow mating of dead mice)
        $warning .= span({-class=>"red"}, "Warning: mouse is dead");
     }

     # 4. check if mouse is in an experiment
     $is_in_experiment = is_in_experiment($global_var_href, $mouse);
     if ($is_in_experiment > 0) {
        $warning .= span({-class=>"red"}, "Warning: mouse $mouse is currently in an "
                                          . a({-href=>"$url?choice=experiment_view&experiment_id=$is_in_experiment", -style=>"color:red;", -title=>"click to open experiment details in separate window", -target=>"_blank"}, "experiment")
                                          . " ."
                        );
     }

     # 5. get date of birth to prevent mating_date < birth_date
     ($birth_datetime_sql) = $dbh->selectrow_array("select mouse_birth_datetime
                                                    from   mice
                                                    where  mouse_id = $mouse
                                                   ");

     # check if mating_date < birth_date: if so, return with error
     if (Delta_ddmmyyyhhmmss($mating_start_datetime, format_sql_datetime2display_datetime($birth_datetime_sql)) eq 'future') {
        $errors++;
        $warning .= span({-class=>"red"}, "Error: mating date cannot be before birth of this mouse");
     }

     $page .= li("checking " . (($sex eq 'm')?'&nbsp;&nbsp;male':'female') .  " mouse " . reformat_number($mouse, 8) . " for mating ... "
                 . (($warning eq '')?'ok':$warning)
                );
  }

  $page .= "</ul>";

  # so far, we checked if at least one of the mating partners cannot be mated, regardless of its sex
  if ($errors > 0) {
     $page .= h3({-class=>"red"}, "Mating not possible")
              . p("At least one of the mating partners in your selection cannot be mated. ")
              . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection");
     return $page;
  }

  $warning = '';

  # now make sure that exactly one male and > 1 females are selected
  if ($sex_counter{'m'} > 1) {
     $errors++;
     $warning .= p("mating with more than one male is not possible");
  }

  # we need a male
  if ($sex_counter{'m'} == 0) {
     $errors++;
     $warning .= p("you need a male to set up a new mating");
  }

  # we need at least one female
  if ($sex_counter{'f'} == 0) {
     $errors++;
     $warning .= p("you need at least one female to set up a new mating");
  }

  # don't allow more than four females
  if ($sex_counter{'f'} > 4) {
     $errors++;
     $warning .= p("Cannot set up mating with more than five mice (exceeds cage capacity)");
  }

  # date of mating not given or invalid
  if (!param('mating_start_datetime') || check_datetime_ddmmyyyy_hhmmss(param('mating_start_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date/time of mating not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is mating start datetime in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('mating_start_datetime')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: date/time of mating start is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if ($errors > 0) {
     $page .= h3({-class=>"red"}, "Mating not possible")
              . $warning
              . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and retry");
     return $page;
  }

  # try to get a lock
  &get_semaphore_lock($global_var_href, $user_id);

  ############################################################################################
  # begin transaction
  $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start mating transaction)", $sr_name . "-" . __LINE__);

  if ($move_mode eq 'move') {
     # get the next free cage for the mating
     $assigned_mating_cage = give_me_a_cage($global_var_href, $mating_start_datetime_sql);

     # if no free cages left (at given datetime of move): rollback and exit
     if (!defined($assigned_mating_cage)) {
        $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back cage move transaction)", $sr_name . "-" . __LINE__);

        &release_semaphore_lock($global_var_href, $user_id);
        return (1, span({-class=>'red'}, "mating cancelled: no free cage found at given date/time of mating (more recent or current move date/time will work more likely)"), undef, undef);
     }

     # mark new cage as occupied
     $dbh->do("update  cages
               set     cage_occupied = ?, cage_cardcolor = ?
               where   cage_id = ?
              ", undef, "y", 1, $assigned_mating_cage
             ) or &error_message_and_exit($global_var_href, "SQL error (could not set new cage to occupied)", $sr_name . "-" . __LINE__);

     # insert the new cage into the chosen rack
     $dbh->do("insert
               into    cages2locations (c2l_cage_id, c2l_location_id, c2l_datetime_from, c2l_datetime_to, c2l_move_user_id, c2l_move_datetime)
               values  (?, ?, ?, NULL, ?, ?)
              ", undef, $assigned_mating_cage, $mating_rack, $mating_start_datetime_sql, $user_id, $datetime_now
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new cage into target rack)", $sr_name . "-" . __LINE__);

     # does the number of cages in the chosen rack exceed the rack capacity when inserting the mating cage?
     ($number_of_cages) = $dbh->selectrow_array("select count(*)
                                                 from   cages2locations
                                                 where  c2l_location_id = $mating_rack
                                                        and c2l_datetime_to IS NULL
                                                ");

     ($rack_capacity) = $dbh->selectrow_array("select location_capacity
                                               from   locations
                                               where  location_id = $mating_rack
                                              ");

     # yes: -> rollback and exit
     if ($number_of_cages > $rack_capacity) {
        $rc = $dbh->rollback() or &error_message_and_exit($global_var_href,"SQL error (could not roll back cage move transaction)", $sr_name . "-" . __LINE__);

        &release_semaphore_lock($global_var_href, $user_id);
        $page .= p({-class=>"red"}, "mouse move cancelled (not enough space for new cage in target rack)");
        return $page;
     }
  }

  # ok, now check if this mating requires a new strain
  ($strain_name) = $dbh->selectrow_array("select strain_name
                                          from   mouse_strains
                                          where  strain_id = '$mating_strain'
                                         ");

#   # in case user wants to mate for a new strain ...
#   if ($strain_name eq 'new strain') {
#      # get new strain id for insert
#      ($new_strain_id, $new_strain_order) = $dbh->selectrow_array("select (max(strain_id) + 1) as new_strain_id, (max(strain_order) + 1) as new_strain_order
#                                                                   from   mouse_strains
#                                                                  ");
#      # insert a new strain
#      $sql = qq(insert
#                into   mouse_strains (strain_id, strain_name, strain_order, strain_show, strain_description)
#                values (?, ?, ?, ?, ?)
#               );
#
#      $dbh->do($sql, undef,
#               $new_strain_id, $new_strain_name, $new_strain_order, 'y', 'New strain inserted at mating by ' . $session->param('username') . ' at ' . $mating_start_datetime_sql
#              ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new strain)", $sr_name . "-" . __LINE__);
#
#      # use new strain id for mating insert down below
#      $mating_strain = $new_strain_id;
#
#      # tell user to inform administrators about new strain
#      $mating_notification .= p()
#                              . p({-class=>"red"}, b("Important: new strain \"$new_strain_name\" (id: $new_strain_id) has been generated. "
#                                                     . "Please inform MausDB administrators about this as soon as possible!")
#                                 );
#
#      &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tnew_imported_strain\t$new_strain_name\tnew_strain_id\t$new_strain_id");
#
#      #-------------------------------------------------------
#      # send mail to admin that new strain has been inserted
#      $mailbody =  "MausDB notification: a new strain has been inserted by user \"" . $session->param(-name=>'username') . "\"\n\n"
#                  . "name of new strain: \"$new_strain_name\"\n"
#                  . "id of new strain  : \"$new_strain_id\"\n\n"
#                  . "Please check this new strain!" . "\n";
#
#      %mail_to_admin = (From    => $admin_mail,
#                        To      => $admin_mail,
#                        Subject => "Message from MausDB ($database on $server): new strain inserted at mating",
#                        Message => $mailbody
#                      );
#
#      if (sendmail(%mail_to_admin)) {
#        # do nothing
#      }
#      else {
#        &error_message_and_exit($global_var_href, "Could not send mail for new strain to $admin_mail ($Mail::Sendmail::error)", $sr_name . "-" . __LINE__);
#      }
#      #-------------------------------------------------------
#   }

  # ok, now check if this mating requires a new line
  ($line_name) = $dbh->selectrow_array("select line_name
                                        from   mouse_lines
                                        where  line_id = '$mating_line'
                                       ");

#   # in case user wants to mate for a new line ...
#   if ($line_name eq 'new line') {
#      # get new line id for insert
#      ($new_line_id, $new_line_order) = $dbh->selectrow_array("select (max(line_id) + 1) as new_line_id, (max(line_order) + 1) as new_line_order
#                                                               from   mouse_lines
#                                                              ");
#      # insert a new line
#      $sql = qq(insert
#                into   mouse_lines (line_id, line_name, line_long_name, line_order, line_show, line_info_URL, line_comment)
#                values (?, ?, ?, ?, ?, ?, ?)
#               );
#
#      $dbh->do($sql, undef,
#               $new_line_id, $new_line_name, $new_line_name, $new_line_order, 'y', '', 'New line inserted at mating by ' . $session->param('username') . ' at ' . $mating_start_datetime_sql
#              ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new line)", $sr_name . "-" . __LINE__);
#
#      # use new line id for mating insert down below
#      $mating_line = $new_line_id;
#
#      # tell user to inform administrators about new strain
#      $mating_notification .= p()
#                              . p({-class=>"red"}, b("Important: a new line \"$new_line_name\" (id: $new_line_id) has been generated. "
#                                                     . "Please inform MausDB administrators about this as soon as possible!")
#                                 );
#
#      &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tnew_imported_line\t$new_line_name\tnew_line_id\t$new_line_id");
#
#      #-------------------------------------------------------
#      # send mail to admin that new strain has been inserted
#      $mailbody =  "MausDB notification: a new line has been inserted by user \"" . $session->param(-name=>'username') . "\"\n\n"
#                  . "name of new line: \"$new_line_name\"\n"
#                  . "id of new line  : \"$new_line_id\"\n\n"
#                  . "Please check this new line!" . "\n";
#
#      %mail_to_admin = (From    => $admin_mail,
#                        To      => $admin_mail,
#                        Subject => "Message from MausDB ($database on $server): new line inserted at mating",
#                        Message => $mailbody
#                      );
#
#      if (sendmail(%mail_to_admin)) {
#        # do nothing
#      }
#      else {
#        &error_message_and_exit($global_var_href, "Could not send mail for new line to $admin_mail", $sr_name . "-" . __LINE__);
#      }
#      #-------------------------------------------------------
#   }

  # get a new mating id
  ($new_mating_id) = $dbh->selectrow_array("select (max(mating_id)+1) as new_mating_id
                                            from   matings
                                           ");

  # only for first mating
  if (!defined($new_mating_id)) { $new_mating_id = 1; }

  # insert mating
  $sql = qq(insert
            into   matings (mating_id, mating_name, mating_matingstart_datetime, mating_matingend_datetime, mating_strain,
                            mating_line, mating_scheme, mating_purpose, mating_project, mating_generation, mating_comment)
            values ($new_mating_id, ?, ?, NULL, $mating_strain, $mating_line, ?, ?, $mating_project, ?, ?)
          );

  $dbh->do($sql, undef,
                 $mating_name,    $mating_start_datetime_sql, $mating_scheme,
                 $mating_purpose, $mating_generation,         $mating_comment
          ) or &error_message_and_exit($global_var_href, "SQL error (could not insert mating)", $sr_name . "-" . __LINE__);


  # check if mating has been generated
  ($mating_done) = $dbh->selectrow_array("select count(mating_id)
                                          from   matings
                                          where  mating_id = $new_mating_id
                                         ");

  # no: -> rollback and exit
  if ($mating_done != 1) {
     $rc    = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (something went wrong, but rollback failed)", $sr_name . "-" . __LINE__);

     &release_semaphore_lock($global_var_href, $user_id);
     $page .= p({-class=>"red"}, "Something went wrong when trying to set up mating.");
     return $page;
  }

  %sex_counter = ();

  # now add all parents to this mating
  foreach $mouse (@mice_to_be_mated) {
     # check sex
     $sex = get_sex($global_var_href, $mouse);
     $sex_counter{$sex}++;

     # roll back if female mouse is in another mating in the meanwhile
     $current_mating = db_is_in_mating($global_var_href, $mouse);
     if (defined($current_mating) && ($sex eq 'f')) {
        $rc    = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (female in another mating, but rollback failed)", $sr_name . "-" . __LINE__);

        &release_semaphore_lock($global_var_href, $user_id);
        $page .= p({-class=>"red"}, "Female mouse $mouse is in already in another mating. Can't set up mating.");
        return $page;
     }

     # add this mouse to the mating
     $sql = qq(insert
               into   parents2matings (p2m_mating_id, p2m_parent_id, p2m_parent_type, p2m_parent_start_date, p2m_parent_end_date)
               values ($new_mating_id, $mouse, ?, ?, NULL)
              );

     $dbh->do($sql, undef,
                    (($sex eq 'm')?'father':'mother'), $mating_start_datetime_sql
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert parent $mouse)", $sr_name . "-" . __LINE__);

     # get current cage for this mouse
     $current_cage = get_cage($global_var_href, $mouse);

     # do we need to move mouse to mating cage?
     if ($move_mode eq 'move') {
        # move mouse to mating cage (without nested transactions)

        # first check if movement is in the time period between now (system time) and the very last movement of this mouse
        # we cannot insert a movement before the last movement
        if (Delta_ddmmyyyhhmmss(datetime_of_last_move($global_var_href, $mouse), param('mating_start_datetime')) ne 'future') {
           $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back mating transaction)", $sr_name . "-" . __LINE__);

           &release_semaphore_lock($global_var_href, $user_id);

           $page .= p({-class=>"red"}, "mating cancelled: mating involves cage change of mouse "
                      . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse"}, &reformat_number($mouse, 8))
                      . "to mating cage that occurs before last reported cage change"
                     )
                    . p({-class=>"red"}, "Please check mating date or " . a({-href=>"javascript:back()"}, "go back") . " one page and use the \"don't move\" button to avoid the problem.");

           return $page;
        }

        ##############################################################################
        # first check if mouse is dead (=> is placed in cage -1). If so, skip movement.
        # determine highest movement number so far (counter for number of cages of this particular mouse)
        ($cage_of_this_mouse) = $dbh->selectrow_array("select max(m2c_cage_of_this_mouse) as cage_of_this_mouse
                                                       from   mice2cages
                                                       where  m2c_mouse_id = '$mouse'
                                                      ");

        # first check if mouse is dead (=> is placed in cage -1). If so, skip movement.
        ($last_cage_of_this_mouse) = $dbh->selectrow_array("select m2c_cage_id
                                                            from   mice2cages
                                                            where  m2c_mouse_id = '$mouse'
                                                                   and m2c_cage_of_this_mouse = '$cage_of_this_mouse'
                                                           ");
        # skip movement, if mouse is dead
        if ($last_cage_of_this_mouse == -1) {
           $moved_mouse .= li(span({-class=>"red"}, "mouse " . reformat_number($mouse, 8) . " not moved to mating cage (reason: dead)"));
           next;
        }
        ##############################################################################

        # get current rack of this mouse
        $current_rack = get_cage_location($global_var_href, $current_cage);

        # update cage in mice2cages: add m2c_datetime_to for cage_id
        $dbh->do("update  mice2cages
                  set     m2c_datetime_to = ?
                  where   m2c_mouse_id    = ?
                          and m2c_cage_id = ?
                          and m2c_datetime_to IS NULL
                 ", undef, $mating_start_datetime_sql, $mouse, $current_cage
                ) or &error_message_and_exit($global_var_href, "SQL error (could not update old cage)", $sr_name . "-" . __LINE__);

        # 0,5. determine next movement number (counter for number of cages of this particular mouse)
        ($cage_of_this_mouse) = $dbh->selectrow_array("select (max(m2c_cage_of_this_mouse)+1) as cage_of_this_mouse
                                                       from   mice2cages
                                                       where  m2c_mouse_id = '$mouse'
                                                      ");

        # insert target cage into mice2cages: add mouse_id, target_cage, datetime_from
        $dbh->do("insert
                  into    mice2cages (m2c_mouse_id, m2c_cage_id, m2c_cage_of_this_mouse, m2c_datetime_from, m2c_datetime_to, m2c_move_user_id, m2c_move_datetime)
                  values  (?, ?, ?, ?, NULL, ?, ?)
                 ", undef, $mouse, $assigned_mating_cage, $cage_of_this_mouse, $mating_start_datetime_sql, $user_id, $datetime_now
                ) or &error_message_and_exit($global_var_href, "SQL error (could not insert mouse into new cage)", $sr_name . "-" . __LINE__);

        # this was the mouse movement only, now check for the consequences

        # 4. does the number of mice in the mating cage exceed the cage capacity?
        ($mice_in_mating_cage) = $dbh->selectrow_array("select count(m2c_mouse_id) as mouse_number
                                                        from   mice2cages
                                                        where  m2c_cage_id = $assigned_mating_cage
                                                               and m2c_datetime_to IS NULL
                                                       ");

        ($mating_cage_capacity) = $dbh->selectrow_array("select cage_capacity
                                                         from   cages
                                                         where  cage_id = $assigned_mating_cage
                                                        ");

        # yes: -> rollback and exit
        if ($mice_in_mating_cage > $mating_cage_capacity) {
           $rc = $dbh->rollback() or &error_message_and_exit($global_var_href,"SQL error (could not roll back cage move transaction)", $sr_name . "-" . __LINE__);

           &release_semaphore_lock($global_var_href, $user_id);
           $page .= p({-class=>"red"}, "mating move cancelled (not enough space in mating cage)");
           return $page;
        }


        # 5. check if the source cage is empty now?
        ($mice_in_origin_cage) = $dbh->selectrow_array("select count(m2c_mouse_id) as mouse_number
                                                        from   mice2cages
                                                        where  m2c_cage_id = $current_cage
                                                               and m2c_datetime_to IS NULL
                                                       ");

        # yes: make empty source cage free
        if ($mice_in_origin_cage == 0) {
           #  update cages: set cage_occupied='n', cage_project=null, cage_contact=null, cage_purpose=null for source_cage
           $dbh->do("update  cages
                     set     cage_occupied = 'n', cage_cardcolor = 7, cage_project = 1, cage_user = 1, cage_purpose = '-'
                     where   cage_id = '$current_cage'
                    "
                   ) or &error_message_and_exit($global_var_href, "SQL error (could not update empty origin cage)", $sr_name . "-" . __LINE__);

           # update cages2locations: add c2l_datetime_to for source_cage and source_location
           $dbh->do("update  cages2locations
                     set     c2l_datetime_to      = ?
                     where   c2l_cage_id          = ?
                             and c2l_location_id  = ?
                             and c2l_datetime_to  IS NULL
                    ", undef, $mating_start_datetime_sql, $current_cage, $current_rack
                   ) or &error_message_and_exit($global_var_href, "SQL error (could not update empty origin cage rack)", $sr_name . "-" . __LINE__);
        }

        $moved_mouse .= li("moved mouse " . reformat_number($mouse, 8) . " from cage " . $current_cage
                                                                    . " to cage "   . $assigned_mating_cage);
     }

     # no move required
     else {
        if ($current_cage > 0) {
           $moved_mouse .= li("mouse " . reformat_number($mouse, 8) . " stays in cage " . $current_cage);
        }
        else {
           $moved_mouse .= li("mouse " . reformat_number($mouse, 8) . " is dead (therefore not moved)");
        }

        # assign a mating cage (rule: female cage)
        if (get_sex($global_var_href, $mouse) eq 'f') {
           $assigned_mating_cage = $current_cage;
        }
        else {
           # store the male cage
           $the_male_cage = $current_cage;
        }
     }
  }

  # roll back if more than one male
  if ($sex_counter{'m'} > 1) {
     $rc    = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (more than one male, but rollback failed)", $sr_name . "-" . __LINE__);

     &release_semaphore_lock($global_var_href, $user_id);
     $page .= p({-class=>"red"}, "Can't set up mating with more than one male.");
     return $page;
  }

  # mating generated, so commit
  $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

  # end transaction
  ############################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $user_id);

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tnew_mating\t$new_mating_id\t$mating_start_datetime_sql\t" . join(',', @mice_to_be_mated));

  $page .= h3("Moving mice")
           . ul($moved_mouse)
           . p()
           . h3("Setting up new mating")
           . p("Mating successfully set up in " . a({-href=>"$url?choice=cage_view&cage_id=" . $assigned_mating_cage}, " cage " . $assigned_mating_cage)
               . " (" . a({-href => "$url?choice=print_card&cage_id=$assigned_mating_cage", -target=>"_blank"}, "print cage card") . ").")
           . p(" See " . a({-href=>"$url?choice=mating_view&mating_id=$new_mating_id"},"mating $new_mating_id") . " for details. ")
           . $mating_notification;

  if ($move_mode ne 'move' && defined($the_male_cage) && $the_male_cage > 0) {
     $page .= hr()
              . h3("[Optional: move females into male cage]")
              . p("You may optionally use the links below to move the females into the male cage");

     foreach $mouse (@mice_to_be_mated) {
        if (get_sex($global_var_href, $mouse) eq 'f') {
           $page .= p(" optional move: " . a({-href=>"$url?choice=move_mouse&mouse_id=$mouse&which_cage=existing&existing_cage=$the_male_cage&datetime_of_move=$mating_start_datetime_url", -target=>"_blank"}, "move female $mouse into male cage $the_male_cage"));
        }
     }
  }

  return $page;
}
# end of db_set_up_mating()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MAT003 report_litter():                             report new litter (1. step)
sub report_litter {                                      my $sr_name = 'SR_MAT003';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};           # get session handle
  my $dbh               = $global_var_href->{'dbh'};               # DBI database handle
  my $mating_id         = param('mating_id');
  my $url               = url();
  my @parameters        = param();                            # read all CGI parameter keys
  my $sex_color         = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my ($page, $sql, $result, $rows, $row, $i);
  my $parameter;
  my ($dd, $mm, $yyyy, $rc, $updated);
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;

  $page .= h2(qq(Report new litter for ) . a({-href=>"$url?choice=mating_view&mating_id=" . $mating_id}, 'mating ' . $mating_id))
           . hr();

  # check input: is mating id given? is it a number?
  if (!param('mating_id') || param('mating_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid mating id"));
     return $page;
  }

  # first table (assign real parents)
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
                   dr1.death_reason_name as how, dr2.death_reason_name as why,
                   p2m_parent_type, p2m_parent_start_date, p2m_parent_end_date
            from   parents2matings
                   join mice               on            p2m_parent_id = mouse_id
                   join mouse_strains      on             mouse_strain = strain_id
                   join mouse_lines        on               mouse_line = line_id
                   join mice2cages         on                 mouse_id = m2c_mouse_id
                   join cages2locations    on              m2c_cage_id = c2l_cage_id
                   join locations          on              location_id = c2l_location_id
                   join cages              on                  cage_id = c2l_cage_id
                   join death_reasons dr1  on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2  on  mouse_deathorexport_why = dr2.death_reason_id
            where  p2m_mating_id = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
            order  by p2m_parent_type asc
           );

  @sql_parameters = ($mating_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  $page .= h3("1. Step: Please specify parents for this litter")
           . p("Using all parents of this mating as default, please uncheck mothers that can be excluded");

  if ($rows == 0) {
     $page .= p("No parents found for mating $mating_id")
              . hr({-align=>'left', -width=>'50%'});
  }

  else {
     $page .= start_form(-action=>url())
              . hidden(-name=>"mating_id")
              . start_table( {-border=>1, -summary=>"table"})

              . Tr(
                  th(span({-title=>"this is just the table row number"}, "#")),
                  th(" is parent "),
                  th("role"),
                  th("entered" . br() . "mating"),
                  th("left" . br() . "mating"),
                  th("mouse ID"),
                  th("ear"),
                  th("sex"),
                  th("born"),
                  th(span({-title=>"living mice: current age; dead mice: age at day of death"}, "age")),
                  th(span({-title=>"day of death"}, "death")),
                  th("genotype"),
                  th("strain"),
                  th("line"),
                  th("room/rack-cage")
                );

     # loop over all results from previous select
     for ($i=0; $i<$rows; $i++) {

        $row = $result->[$i];                # fetch next row

        # get first genotype
        ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

        # add table row for current mouse
        $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                   td($i+1),
                   td(qq(<input type="checkbox" name="litter_parents" value="$row->{'mouse_id'}" checked="1"/>)),
                   td($row->{'p2m_parent_type'}),
                   td(format_datetime2simpledate($row->{'p2m_parent_start_date'})),
                   td(format_datetime2simpledate($row->{'p2m_parent_end_date'})),
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
                       ?a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"},              # yes: print cage link
                          $row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'})
                       :'-'                                                                                                          # no: don't print cage link
                     )
                 );
     }

     $page .= end_table()
              . p()
              . hr({-align=>'left', -width=>'50%'});
  }

  # second table (litter details)
  $page .= h3("2. Step: Please enter litter details")
           . table( {-border=>1, -summary=>"table"},
                Tr(
                  th(" date of birth "),
                  td({-colspan=>3}, textfield(-name=>'litter_born_datetime', -id=>"litter_born_datetime", -size=>"20", -maxlength=>"21", -title=>"litter born (default: today)", -value=>'')
                                    . "&nbsp;&nbsp;"
                                    . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=litter_born_datetime', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                                    . br() . small("please enter date of birth (dd:mm:yyyy hh:mm:ss)")
                  )
                ) .
                Tr(
                  th(" living pups "),
                  td(b("total")  . br() . popup_menu(-name=>'litter_alive_total',   -values=>["0" .. "25"], -default=>"0", -title=>"number of all living pups"    )),
                  td(b("male")   . br() . popup_menu(-name=>'litter_alive_male',    -values=>["0" .. "25"], -default=>"0", -title=>"number of living male pups"   )),
                  td(b("female") . br() . popup_menu(-name=>'litter_alive_female',  -values=>["0" .. "25"], -default=>"0", -title=>"number of living female pups" ))
                ) .
                Tr(
                  th("dead"),
                  td(b("total")  . br() . popup_menu(-name=>'litter_dead_total',    -values=>["0" .. "25"], -default=>"0", -title=>"number of all dead pups"  )),
                  td(b("male")   . br() . popup_menu(-name=>'litter_dead_male',     -values=>["0" .. "25"], -default=>"0", -title=>"number of dead male pups" )),
                  td(b("female") . br() . popup_menu(-name=>'litter_dead_female',   -values=>["0" .. "25"], -default=>"0", -title=>"number of dead female pups" ))
                ) .
                Tr(
                  th("reduced"),
                  td({-colspan=>3}, popup_menu(-name=>'litter_reduced_total', -values=>["0" .. "25"], -default=>"0", -title=>"number of reduced (killed) pups" ) . br()
                                    . "if any reduced, why?" . br()
                                    . textarea( -name=>'litter_reduced_reason',  -columns=>"30", -rows=>"3", -title=>"give a reason why litter has been reduced", -value=>"")
                  )
                ) .
                Tr(
                  th("litter comment"),
                  td({-colspan=>3}, textarea(-name=>"litter_comment", -columns=>"40", -rows=>"5", -title=>"enter any comment on this litter" ))
                )
             )
           . p()
           . submit(-name => "job", -value=>"Report litter",          -title=>"only report litter, wean later") #. "&nbsp;&nbsp;or&nbsp;&nbsp;"
           . end_form();

  return $page;
}
# end of report_litter()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MAT004 remove_parent_from_mating_1():               remove parent from a mating
sub remove_parent_from_mating_1 {                        my $sr_name = 'SR_MAT004';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};           # get session handle
  my $dbh               = $global_var_href->{'dbh'};               # DBI database handle
  my $user_id           = $global_var_href->{'user_id'};
  my $mating_id         = param('mating_id');
  my $parent_id         = param('parent_id');
  my $confirmed         = param('confirmed');
  my $removal_datetime  = param('remove_from_mating_datetime');
  my $datetime_sql      = get_current_datetime_for_sql();
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my ($sex, $mating_start_datetime_sql, $removal_datetime_sql, $active_partners_remaining);

  $page .= h2("Remove parent from mating")
           . hr();

  # check input: is mating id given? is it a number?
  if (!param('mating_id') || param('mating_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid mating id"));
     return $page;
  }

  # check input: is parent id given? is it a number?
  if (!param('parent_id') || param('parent_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid parent id"));
     return $page;
  }

  # check input: is removal confirmed?
  # Yes: check removal date/time and do it
  if (param('confirmed') && param('confirmed') eq "yes_I_really_want_to_remove_parent_from_mating") {

     $sex = get_sex($global_var_href, $parent_id);

     # 1. check if removal datetime is given and valid
     if (!param('remove_from_mating_datetime') || check_datetime_ddmmyyyy_hhmmss(param('remove_from_mating_datetime')) != 1) {
        $page .= p({-class=>"red"}, b("Error: date/time of parent removal not given or has invalid format "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     # 2. is removal datetime in the future? if so, reject
     if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('remove_from_mating_datetime')) eq 'future') {
        $page .= p({-class=>"red"}, b("Error: date/time of parent removal is in the future "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     # 3. get date of mating start to prevent mating_end_date < mating_start_date
     ($mating_start_datetime_sql) = $dbh->selectrow_array("select mating_matingstart_datetime
                                                           from   matings
                                                           where  mating_id = $mating_id
                                                          ");

     # check if removal datetime < mating_start_date: if so, return with error
     if (Delta_ddmmyyyhhmmss(param('remove_from_mating_datetime'), format_sql_datetime2display_datetime($mating_start_datetime_sql)) eq 'future') {
        $page .= p({-class=>"red"}, b("Error: date/time of parent removal cannot be before mating was started. "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     $removal_datetime_sql = format_display_datetime2sql_datetime($removal_datetime);

     # everything checked: do it

     # try to get a lock
     &get_semaphore_lock($global_var_href, $user_id);

     ############################################################################################
     # begin transaction
     $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start transaction)", $sr_name . "-" . __LINE__);

     # remove parent from mating by setting an end date in parents2matings
     $dbh->do("update  parents2matings
               set     p2m_parent_end_date = ?
               where   p2m_mating_id = ?
                       and p2m_parent_id = ?
              ", undef, $removal_datetime_sql, $mating_id, $parent_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update parent status)", $sr_name . "-" . __LINE__);

      # stop mating if last female left mating
     ($active_partners_remaining) = $dbh->selectrow_array("select count(p2m_parent_id) as no_partners
                                                           from   parents2matings
                                                           where  p2m_mating_id = $mating_id
                                                                  and p2m_parent_type like '%mothe%'
                                                                  and p2m_parent_end_date IS NULL
                                                          ");
     # no mothers left!
     if ($active_partners_remaining == 0) {
        # 1) if no female left in mating => update matings, set mating_matingend_datetime
        $dbh->do("update matings
                  set    mating_matingend_datetime = ?
                  where  mating_id = ?
                 ", undef, $removal_datetime_sql, $mating_id
              ) or &error_message_and_exit($global_var_href, "SQL error (could not set mating end datetime)", $sr_name . "-" . __LINE__);

        # 2) if no female left in mating => set mating_matingend_datetime for all remaining partners that have not been previously removed
         $dbh->do("update  parents2matings
                   set     p2m_parent_end_date = ?
                   where   p2m_mating_id = ?
                           and p2m_parent_end_date IS NULL
                  ", undef, $removal_datetime_sql, $mating_id
               ) or &error_message_and_exit($global_var_href, "SQL error (could not update parentships of mating)", $sr_name . "-" . __LINE__);
     }

     $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

     # end transaction
     ############################################################################################

     # release lock
     &release_semaphore_lock($global_var_href, $user_id);

     &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tremove_parent_from_mating\t$mating_id\t$parent_id\t$removal_datetime_sql");

     $page .= h3("Remove mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$parent_id"}, $parent_id) . " " . (($sex eq 'm')?'(father)':'(mother)')
                 . " from mating " . a({-href=>"$url?choice=mating_view&mating_id=$mating_id"}, $mating_id)
                )
              . p("Successfully removed mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$parent_id"}, $parent_id) . " " . (($sex eq 'm')?'(father)':'(mother)')
                 . " from mating " . a({-href=>"$url?choice=mating_view&mating_id=$mating_id"}, $mating_id))


  }
  # show the confirmation page and get removal datetime
  else {
     $sex = get_sex($global_var_href, $parent_id);

     $page .= h3("Remove mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$parent_id"}, $parent_id) . " " . (($sex eq 'm')?'(father)':'(mother)')
                 . " from mating " . a({-href=>"$url?choice=mating_view&mating_id=$mating_id"}, $mating_id)
                )
              . p("Please enter date when mouse was removed from mating")

              . start_form(-action => url())
              . p(b("removal date/time: ")
                  . textfield(-name=>"remove_from_mating_datetime", -id=>'remove_from_mating_datetime', -size=>"20", -maxlength=>"21", -title=>"date/time of removal from mating", -value=>get_current_datetime_for_display()) . "&nbsp;&nbsp;"
                  . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=remove_from_mating_datetime', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                )
              . p()
              . hidden('mating_id')
              . hidden('parent_id')
              . hidden('user_id')
              . hidden(-name=>'confirmed', -value=>"yes_I_really_want_to_remove_parent_from_mating")
              . submit(-name => "choice", -value=>"remove parent from mating")
              . end_form();
     return $page;
  }

  return $page;
}
# end of remove_parent_from_mating_1()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_MAT005 report_litter_loss():                        report litter loss (1. step)
sub report_litter_loss {                                 my $sr_name = 'SR_MAT005';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $litter_id         = param('litter_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;
  my $parameter;
  my ($litter_born);

  $page .= h2("Report litter loss (" . a({-href=>"$url?choice=litter_view&litter_id=" . $litter_id}, "litter $litter_id")  . ")" )
           . hr()
           . start_form(-action=>url())
           . hidden(-name=>"litter_id");

  # check input: is litter id given? is it a number?
  if (!param('litter_id') || param('litter_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid litter id"));
     return $page;
  }

  # get basic litter data
  $sql = qq(select litter_id,         litter_mating_id,      litter_in_mating,        litter_born_datetime, litter_alive_total,
                   litter_alive_male, litter_alive_female,   litter_dead_total,       litter_dead_male,     litter_dead_female,
                   litter_reduced,    litter_reduced_reason, litter_weaning_datetime, litter_comment
            from   litters
            where  litter_id = ?
           );

  @sql_parameters = ($litter_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no such litter found: tell and quit
  unless ($rows > 0) {
     $page .= p("No such litter found");
     return $page;
  }

  # else continue: get the first (and hopefully only) result
  $row = $result->[0];
  $litter_born    = $row->{'litter_born_datetime'};

  # litter table
  $page .= h3("Please update litter details")
           . table( {-border=>1, -summary=>"table"},
                Tr(
                  th(" date of birth "),
                  td({-colspan=>3}, format_sql_datetime2display_datetime($litter_born))
                ) .
                Tr(
                  th(" date of litter loss "),
                  td({-colspan=>3}, textfield(-name=>'litter_loss_datetime', -id=>"litter_loss_datetime", -size=>"20", -maxlength=>"21", -title=>"litter loss (default: today)", -value=>get_current_datetime_for_display())
                                    . "&nbsp;&nbsp;"
                                    . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=litter_loss_datetime', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                  )
                ) .
                Tr(
                  th(" living pups "),
                  td(b("total")  . br() . popup_menu(-name=>'litter_alive_total',   -values=>["0"],          -default=>"0",                             -title=>"number of all living pups"    )),
                  td(b("male")   . br() . popup_menu(-name=>'litter_alive_male',    -values=>["0"],          -default=>"0",                             -title=>"number of living male pups"   )),
                  td(b("female") . br() . popup_menu(-name=>'litter_alive_female',  -values=>["0"],          -default=>"0",                             -title=>"number of living female pups" ))
                ) .
                Tr(
                  th("dead"),
                  td(b("total")  . br() . popup_menu(-name=>'litter_dead_total',    -values=>["0" .. "25"],  -default=>$row->{'litter_dead_total'},     -title=>"number of all dead pups"      )),
                  td(b("male")   . br() . popup_menu(-name=>'litter_dead_male',     -values=>["0" .. "25"],  -default=>$row->{'litter_dead_male'},      -title=>"number of dead male pups"     )),
                  td(b("female") . br() . popup_menu(-name=>'litter_dead_female',   -values=>["0" .. "25"],  -default=>$row->{'litter_dead_female'},    -title=>"number of dead female pups"   ))
                ) .
                Tr(
                  th("reduced"),
                  td({-colspan=>3}, popup_menu(-name=>'litter_reduced_total',       -values=>["0" .. "25"],  -default=>$row->{'litter_reduced'},        -title=>"number of reduced (killed) pups" ) . br()
                                    . "if any reduced, why?" . br()
                                    . textarea( -name=>'litter_reduced_reason',  -columns=>"30", -rows=>"3", -default=>$row->{'litter_reduced_reason'}, -title=>"give a reason why litter has been reduced")
                  )
                ) .
                Tr(
                  th("litter comment"),
                  td({-colspan=>3}, textarea(-name=>"litter_comment",            -columns=>"40", -rows=>"5", -default=>$row->{'litter_comment'},        -title=>"enter any comment on this litter" ))
                )
             )
           . p()
           . submit(-name => "job", -value=>"Report litter loss", -title=>"Report litter loss")
           . end_form();

  return $page;
}
# end of report_litter_loss()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SSR_MAT006 new_embryotransfer():                       set up a new embryotransfer (1. step)
sub new_embryotransfer {                                 my $sr_name = 'SR_MAT006';
  my ($global_var_href)                = @_;             # get reference to global vars hash
  my %radio_labels_manipulation_method = ("no_manipulation" => "",  "blastocyst_injection" => "", "pronucleus_injection" => "");
  my %radio_labels                     = ("screen" => "", "all" => "");
  my %radio_labels_screen              = ("user_only" => "", "all" => "");
  my %radio_labels_embryo              = ("in_vitro" => "in vitro",  "in_vivo" => "in vivo");
  my %radio_labels_frozen              = ("fresh" => "",  "frozen" => "");
  my %radio_labels_procedure           = ("embryo_production" => "",  "embryo_preservation" => "", "transgenic_manipulation" => "");
  my %sex_counter                      = ('m' => 0, 'f' => 0);
  my $url                              = url();
  my $errors                           = 0;
  my @genetic_fathers                  = ();
  my @recipient_mothers                = ();
  my @mice_to_be_mated                 = ();
  my ($current_mating, $warning, $sex, $strain_default, $line_default, $location, $is_in_experiment);
  my ($page, $sql, $mouse);
  my @sql_parameters;

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB ids
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_mated, $mouse);
     }
     # else ignore ...
  }

  # delete the list of selected mice (this is a CGI.pm method)
  Delete('mouse_select');

  # exit if no mice selected for mating
  if (scalar @mice_to_be_mated == 0) {
     $page .= h2("New embryo transfer")
              . hr()
              . h3("No mice for embryo transfer")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # else continue
  $page .= h2("New embryo transfer")
           . hr()
           . h3("Checking selected mice")
           . start_form(-action=>url(), -name=>"myform")
           . "<ul>";

  # display all selected mice and check if they can be used at all for an embryo transfer
  foreach $mouse (@mice_to_be_mated) {
     # rewrite mouse to hidden field
     $page .= hidden(-name=>'mouse_select', -value=>"$mouse");

     $warning = '';

     # check (and count) sex (to avoid more than one male...)
     $sex = get_sex($global_var_href, $mouse);
     $sex_counter{$sex}++;

     # get current rack for this mouse (as default for location selection
     $location = get_location($global_var_href, $mouse);

     # check if mouse is currently in another mating
     $current_mating = db_is_in_mating($global_var_href, $mouse);

     # females are not allowed to be part of more than one mating
     if (defined($current_mating) && ($sex eq 'f')) {
        $errors++;
        $warning .= span({-class=>"red"}, "Cannot use for embryo transfer: female mouse $mouse is currently in active "
                                          . a({-href=>"$url?choice=mating_view&mating_id=$current_mating", -style=>"color:red;", title=>"click to open mating details in separate window", -target=>"_blank"}, "mating $current_mating")
                                          . "Please remove mouse $mouse from mating $current_mating first."
                        );
     }
     elsif ($sex eq 'f') {
        push(@recipient_mothers, $mouse);
     }

     if ($sex eq 'm') {
        push(@genetic_fathers, $mouse);
     }

     # males can take part in more than one mating. In such cases, display a warning.
     if (defined($current_mating) && ($sex eq 'm')) {
        $warning .= span({-class=>"red"}, "Warning: male mouse $mouse is currently in active "
                                          . a({-href=>"$url?choice=mating_view&mating_id=$current_mating", -style=>"color:red;", title=>"click to open mating details in separate window", -target=>"_blank"}, "mating $current_mating")
                                          . ". If you continue, a new mating will be set up."
                        );
     }

     # check if mouse is alive at all
     if (defined(get_date_of_death($global_var_href, $mouse))) {
        #$errors++;
        $warning .= span({-class=>"red"}, "Warning: mouse is dead");
     }

     # check if mouse is in an experiment
     $is_in_experiment = is_in_experiment($global_var_href, $mouse);
     if ($is_in_experiment > 0) {
        $warning .= span({-class=>"red"}, "Warning: mouse $mouse is currently in an "
                                          . a({-href=>"$url?choice=experiment_view&experiment_id=$is_in_experiment", -style=>"color:red;", -title=>"click to open experiment details in separate window", -target=>"_blank"}, "experiment")
                                          . ". Are you sure you want to use this mouse for embryo transfer?"
                        );
     }

     $page .= li("checking " . (($sex eq 'm')?'&nbsp;&nbsp;genetic father':'recipient mother') .  " " . a( {-href=>"$url?choice=mouse_details&mouse_id=" . $mouse}, $mouse) . " for use in embryo transfer ... "
                 . (($warning eq '')?'ok':$warning)
                );
  }

  $page .= "</ul>";

  # so far, check if at least one of the mating partner cannot be mated, regardless of its sex
  if ($errors > 0) {
     $page .= h3({-class=>"red"}, "Setup of new embryo transfer is not possible")
              . p("At least one of the mice involved cannot be used for embryo transfer. ")
              . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection");
     return $page;
  }

  $warning = '';

  # warn if more than one male
  if ($sex_counter{'m'} > 1) {
     #$errors++;
     $warning .= p("Warning: more than one male!");
  }

  # no female
  if ($sex_counter{'f'} == 0) {
     $errors++;
     $warning .= p("Error: you need at least one recipient female to set up an embryo transfer!");
  }

  # exit if any errors
  if ($errors > 0) {
     $page .= h3({-class=>"red"}, "Setup of new embryo transfer is not possible")
              . $warning
              . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection. ");
     return $page;
  }

  ######################################
  # defaults for stain/line popup menus
  $sql = qq(select strain_id
            from   mouse_strains
            where  strain_name = ?
           );

  # default strain = "new strain"
  @sql_parameters = ('new strain');

  ($strain_default) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $sql = qq(select line_id
            from   mouse_lines
            where  line_name = ?
           );

  # default line   = "new line"
  @sql_parameters = ('new line');

  ($line_default) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};
  ######################################


  $page .= $warning
           . h3("Now specify some embryo transfer details")
           . p("Grey fields are mandatory, please check them carefully. White fields are optional and may be left empty.")

           . start_table({-border=>1, -summary=>"table"})

           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("date of embryo transfer") . br() . small("date of embryo transfer")),
               td({-colspan=>"3"}, textfield(-name => "mating_start_datetime", -id=>"mating_start_datetime", -size=>"20", -maxlength=>"21", -value=>(defined(param('move_datetime')))?param('move_datetime'):get_current_datetime_for_display())
                                   . "&nbsp;&nbsp;"
                                   . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=mating_start_datetime', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
               )
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("strain") . br() . small("strain that litter from this embryo transfer will be assigned to")),
               td(get_strains_popup_menu($global_var_href, undef)),
               td({-colspan=>"2"}, "if you need a new strain entry, please contact a MausDB administrator")
#                td({-align=>"right", -title=>qq(if you chose "new strain", please propose a name for the new strain)}, qq(&nbsp;&nbsp;&nbsp;[optional: for "new strain" only: name of the new strain] )),
#                td({-title=>qq(if you chose "new strain", please propose a name for the new strain)}, textfield(-name => "new_strain_name", -size=>"20"))
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("line") . br() . small("line that litter from this embryo transfer will be assigned to")),
               td(get_lines_popup_menu($global_var_href, undef)),
               td({-colspan=>"2"}, "if you need a new line entry, please contact a MausDB administrator")
#                td({-align=>"right", -title=>qq(if you chose "new line", please propose a name for the new line)}, qq(&nbsp;&nbsp;&nbsp;[optional: for "new line" only: name of the new line] )),
#                td({-title=>qq(if you chose "new line", please propose a name for the new line)}, textfield(-name => "new_line_name", -size=>"20"))
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("embryo")),
               td({-colspan=>"3"}, "embryo ID : " . textfield(-name => "embryo_id",     -size => "20") . "&nbsp;&nbsp;"
                                 . "origin "      . textfield(-name => "embryo_origin", -size => "30")
               )
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("embryo production") . br() . small("How has the embryo been produced?")),
               td({-colspan=>"3"},  table({-border=>0},
                                      Tr(td({-align=>'right'}, b("method: ")),
                                         td(radio_group(-name=>'embryo_production', -values=>['in_vivo', 'in_vitro'], -default=>"in_vitro", -labels=>\%radio_labels_embryo, -linebreak=>'true')),
                                         td()
                                      ) .
                                      Tr(td(),
                                         td({-align=>'right'}, b("sperm: ") . br() . b("assisted IVF: ")),
                                         td(radio_group(-name=>'sperm_frozen',  -values=>['fresh', 'frozen']) . br() .
                                            radio_group(-name=>'IVF_assistance', -values=>['none', 'Laser IVF', 'ICSI'], -default=>'none')
                                         )
                                      )
                                    )
               )
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("embryo preservation") . br() . small("How has the embryo been preserved?")),
               td({-colspan=>"3"},  table({-border=>0},
                                      Tr(
                                         td(radio_group(-name=>'embryo_preservation', -values=>['fresh', 'revitalized'])),
                                         td(),
                                         td()
                                      )
                                    )
               )
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("transgenic manipulation") . br() . small("How has the embryo been manipulated?")),
               td({-colspan=>"3"},  table({-border=>0},
                                      Tr(
                                         td(radio_group(-name=>'manipulation_method', -values=>['no_manipulation'], -default=>"no_manipulation", -labels=>\%radio_labels_manipulation_method)),
                                         td(b("no manipulation in-house")),
                                         td()
                                      ) .
                                      Tr(
                                         td({-valign=>'top'},
                                            radio_group(-name=>'manipulation_method', -values=>['blastocyst_injection'], -default=>"no_manipulation", -labels=>\%radio_labels_manipulation_method)),
                                         td(b("knockout (blastocyst injection)")
                                            . br()
                                            . table({-border=>0},
                                              Tr( td("background of donor cells: "),
                                                  td(textfield(-name => "background_of_donor_cells", -size=>"20"))
                                              ) .
                                              Tr( td("background of ES cell line: "),
                                                  td(textfield(-name => "background_of_ES_cell_line", -size=>"20"))
                                              ) .
                                              Tr( td("name of construct / line: "),
                                                  td(textfield(-name => "name_of_construct", -size=>"20"))
                                              )
                                            )
                                         ),
                                         td(
                                         )
                                      ) .
                                      Tr(
                                         td({-valign=>'top'},
                                            radio_group(-name=>'manipulation_method', -values=>['pronucleus_injection'], -default=>"no_manipulation", -labels=>\%radio_labels_manipulation_method)),
                                         td(b("transgenic animal (pronucleus injection)")
                                            . table({-border=>0},
                                              Tr( td("background of donor cells: "),
                                                  td(textfield(-name => "background_of_donor_cells_2", -size=>"20"))
                                              ) .
                                              Tr( td("name of construct / line: "),
                                                  td(textfield(-name => "name_of_construct_2", -size=>"20"))
                                              )
                                            )
                                         ),
                                         td()
                                      )
                                    )
               )
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("recipient mother(s)")),
               td({-colspan=>"3"}, mouse_list2link_list(\@recipient_mothers)
               )
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("genetic father - internal")),
               td({-colspan=>"3"}, mouse_list2link_list(\@genetic_fathers)
               )
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("genetic father - external")),
               td({-colspan=>"3"}, "external mouse ID : " . textfield(-name => "genetic_father_id", -size=>"10") . "&nbsp;&nbsp;"
                                 . "origin " . textfield(-name => "genetic_father_origin", -size=>"20")
               )
             )
           . Tr({-bgcolor=>"#DDDDDD"},
               td({-align=>"center"}, b("embryo transfer project") . br() . small("assign a screen/project")),
               td({-colspan=>"3"},
                  table({-border=>0, -summary=>"table"},
                        Tr(
                          td(),
                          th("your screens/projects only"),
                          th({-colspan=>2}, "or"),
                          th("all screens/projects")
                        ) .
                        Tr(
                          td(radio_group(-name=>'which_projects', -values=>['user_only'], -default=>'user_only', -labels=>\%radio_labels_screen)),
                          td(span({-onclick=>"document.myform.which_projects[0].checked=true"}, get_projects_popup_menu($global_var_href, 1, 'user_projects_only'))),
                          td("&nbsp;&nbsp;&nbsp;&nbsp;"),
                          td(radio_group(-name=>'which_projects', -values=>['all'],       -default=>'user_only', -labels=>\%radio_labels_screen)),
                          td(span({-onclick=>"document.myform.which_projects[1].checked=true"}, get_projects_popup_menu($global_var_href, 1, 'all')))
                        )
                  )
               )
             )
           . Tr(
               td({-align=>"center"}, b("[optional: embryo transfer name]") . br() . small("give your embryo transfer a unique name")),
               td({-colspan=>"3"}, textfield(-name => "mating_name", -size=>"80"))
             )
           . Tr(
               td({-align=>"center"}, b("[optional: embryo transfer purpose]") . br() . small("your own description")),
               td({-colspan=>"3"}, textfield(-name => "mating_purpose", -size=>"80"))
             )
           . Tr(
               td({-align=>"center"}, b("[optional: comment]") . br() . small("any comment")),
               td({-colspan=>"3"}, textarea(-name=>"mating_comment", -columns=>"80", -rows=>"5"))
             )
           . end_table()
           . p()
           . submit(-name => "choice", -value=>"setup transfer!")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel embryo transfer (go to previous page)"))
           . end_form();

  return $page;
}
# end of new_embryotransfer()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MAT007 db_set_up_transfer():                        set up a new transfer (2. step)
sub db_set_up_transfer {                                 my $sr_name = 'SR_MAT007';
  my ($global_var_href)           = @_;                              # get reference to global vars hash
  my $dbh                         = $global_var_href->{'dbh'};       # DBI database handle
  my $session                     = $global_var_href->{'session'};   # session handle
  my $database                    = $global_var_href->{'db_name'};   # which database are we working on?
  my $server                      = $global_var_href->{'db_server'}; # on which server is the database currently running?
  my $user_id                     = $session->param(-name=>'user_id');
  my $datetime_now                = get_current_datetime_for_sql();
  my $url                         = url();
  my @selected_mice               = param('mouse_select');           # read list of selected mice from CGI form
  my $which_project               = param('which_projects');         # switch to decide if project selection from 'all_projects' or from 'user_only'
  my $all_projects                = param('all_projects');
  my $user_projects_only          = param('user_projects');
  my $mating_strain               = param('strain');
  my $new_strain_name             = param('new_strain_name');
  my $mating_line                 = param('line');
  my $new_line_name               = param('new_line_name');
  my $mating_start_datetime       = param('mating_start_datetime');
  my $mating_start_datetime_sql   = format_display_datetime2sql_datetime($mating_start_datetime);
  my $mating_name                 = param('mating_name');
  my $mating_purpose              = param('mating_purpose');
  my $mating_comment              = param('mating_comment');
  my $embryo_id                   = param('embryo_id');
  my $embryo_origin               = param('embryo_origin');
  my $embryo_production           = param('embryo_production');
  my $sperm_frozen                = param('sperm_frozen');
  my $IVF_assistance              = param('IVF_assistance');
  my $embryo_preservation         = param('embryo_preservation');
  my $manipulation_method         = param('manipulation_method');
  my $background_of_donor_cells   = param('background_of_donor_cells');
  my $background_of_ES_cell_line  = param('background_of_ES_cell_line');
  my $name_of_construct           = param('name_of_construct');
  my $background_of_donor_cells_2 = param('background_of_donor_cells_2');
  my $name_of_construct_2         = param('name_of_construct_2');
  my $genetic_father_id           = param('genetic_father_id');
  my $genetic_father_origin       = param('genetic_father_origin');
  my %sex_counter                 = ('m' => 0, 'f' => 0);
  my $errors                      = 0;
  my @mice_to_be_mated            = ();
  my $moved_mouse                 = '';
  my $mating_notification         = '';
  my @user_screens                = get_user_projects($global_var_href, $user_id);
  my ($page, $sql, $mouse, $rc, $warning);
  my ($current_mating, $mating_done, $mating_rack, $mating_project, $mating_cage, $sex, $new_mating_id, $mm, $dd, $yyyy);
  my ($current_cage, $current_rack, $mice_in_mating_cage, $mating_cage_capacity, $mice_in_origin_cage, $is_in_experiment);
  my ($error_code, $error_message, $assigned_mating_cage, $number_of_cages, $birth_datetime_sql, $new_embryo_transfer_id);
  my ($new_strain_id, $new_line_id, $strain_name, $line_name, $new_strain_order, $new_line_order);
  my ($admin_mail, $mailbody);
  my %mail_to_admin;

#   # if user wants to generate a new strain and/or new line on the fly, we need the mailing module in order to send a mail to the administrators
#   if (get_strain_name_by_id($global_var_href, $mating_strain) eq "new strain" || get_line_name_by_id($global_var_href, $mating_line) eq "new line" ) {
#      use Mail::Sendmail;                                # include the mailing module
#
#      ($admin_mail) = $dbh->selectrow_array("select setting_value_text as admin_mail
#                                             from   settings
#                                             where  setting_category='admin'
#                                                    and setting_item='admin_mail'
#                                            ");
#   }

  $page .= h2("New mating: trying to set up new mating (type: embryo transfer) in the database")
           . hr();

  # check mating strain
  if (!defined($mating_strain) || get_strain_name_by_id($global_var_href, $mating_strain) eq "choose strain") {
     $page .= p({-class=>"red"}, "please choose a strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # check mating line
  if (!defined($mating_line) || get_line_name_by_id($global_var_href, $mating_line) eq "choose line") {
     $page .= p({-class=>"red"}, "please choose a line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # check if embryo id provided
  if (!defined($embryo_id)) {
     $page .= p({-class=>"red"}, "please provide an embryo id.")
              . p(a({-href=>"javascript:back()"}, "please go back and provide embryo id"));
     return $page;
  }

  # check if embryo_production (in_vivo or in_vitro) selected
  if (!defined($embryo_production) || !( ($embryo_production eq 'in_vivo') || ($embryo_production eq 'in_vitro') )) {
     $page .= p({-class=>"red"}, "please select type of embryo production (in vitro or in vivo).")
              . p(a({-href=>"javascript:back()"}, "please go back and select embryo production type"));
     return $page;
  }

  # some additional checks in case of in vitro production
  if (defined($embryo_production) && ($embryo_production eq 'in_vitro') ) {
     # check if sperm preservation method (fresh or frozen) selected
     if (!defined($sperm_frozen) || !( ($sperm_frozen eq 'fresh') || ($sperm_frozen eq 'frozen') )) {
        $page .= p({-class=>"red"}, "please select type of sperm preservation (fresh or frozen).")
                 . p(a({-href=>"javascript:back()"}, "please go back and select sperm preservation method"));
        return $page;
     }

     # check if IVF assistance method (none, Laser, ICSI) selected
     if (!defined($IVF_assistance) || !( ($IVF_assistance eq 'none') || ($IVF_assistance eq 'Laser IVF') || ($IVF_assistance eq 'ICSI'))) {
        $page .= p({-class=>"red"}, "please select type of IVF assistance method (none, Laser, ICSI).")
                 . p(a({-href=>"javascript:back()"}, "please go back and select IVF assistance method"));
        return $page;
     }
  }

  # check if embryo preservation method (fresh or revitalized) selected
  if (!defined($embryo_preservation) || !( ($embryo_preservation eq 'fresh') || ($embryo_preservation eq 'revitalized') )) {
     $page .= p({-class=>"red"}, "please select type of embryo preservation (fresh or revitalized).")
              . p(a({-href=>"javascript:back()"}, "please go back and select embryo preservation method"));
     return $page;
  }

  # check if manipulation method (no_manipulation, blastocyst_injection, pronucleus_injection) selected
  if (!defined($manipulation_method)
      ||
      !( ($manipulation_method eq 'no_manipulation') || ($manipulation_method eq 'blastocyst_injection') || ($manipulation_method eq 'pronucleus_injection') )) {
     $page .= p({-class=>"red"}, "please select manipulation method (none, blastocyst injection, pronucleus injection).")
              . p(a({-href=>"javascript:back()"}, "please go back and select manipulation method"));
     return $page;
  }

  # in case of blastocyst injection, do some more checks
  if (defined($manipulation_method) && ($manipulation_method eq 'blastocyst_injection')) {
     # check if background of donor cells given
     if (!defined($background_of_donor_cells) || ($background_of_donor_cells eq '')) {
        $page .= p({-class=>"red"}, "please provide the background of the donor cells.")
                 . p(a({-href=>"javascript:back()"}, "please go back and provide the background of the donor cells"));
        return $page;
     }

     # check if background of ES cells given
     if (!defined($background_of_ES_cell_line) || ($background_of_ES_cell_line eq '')) {
        $page .= p({-class=>"red"}, "please provide the background of the ES cells.")
                 . p(a({-href=>"javascript:back()"}, "please go back and provide the background of the ES cells"));
        return $page;
     }

     # check if name of the construct given
     if (!defined($name_of_construct) || ($name_of_construct eq '')) {
        $page .= p({-class=>"red"}, "please provide the name of construct")
                 . p(a({-href=>"javascript:back()"}, "please go back and provide the name of construct"));
        return $page;
     }
  }

  # in case of pronucleus injection, do some more checks
  if (defined($manipulation_method) && ($manipulation_method eq 'pronucleus_injection')) {
     # check if background of donor cells given
     if (!defined($background_of_donor_cells_2) || ($background_of_donor_cells_2 eq '')) {
        $page .= p({-class=>"red"}, "please provide the background of the donor cells.")
                 . p(a({-href=>"javascript:back()"}, "please go back and provide the background of the donor cells"));
        return $page;
     }

     # check if name of the construct given
     if (!defined($name_of_construct_2) || ($name_of_construct_2 eq '')) {
        $page .= p({-class=>"red"}, "please provide the name of construct")
                 . p(a({-href=>"javascript:back()"}, "please go back and provide the name of construct"));
        return $page;
     }

     $background_of_donor_cells = $background_of_donor_cells_2;
     $name_of_construct         = $name_of_construct_2;
  }

  # check project info
  if (!defined($which_project) || !( ($which_project eq 'user_only') || ($which_project eq 'all') ) ) {
     &error_message_and_exit($global_var_href, "invalid project selector", $sr_name . "-" . __LINE__);
  }
  if ($which_project eq 'user_only') {
     if (!defined($user_projects_only) || $user_projects_only !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid project id (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $mating_project = $user_projects_only;
     }
  }
  if ($which_project eq 'all') {
     if (!defined($all_projects) || $all_projects !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid project id (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $mating_project = $all_projects;
     }
  }

  # check list of mice to be mated
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_mated, $mouse);
     }
  }

  if (scalar @mice_to_be_mated == 0) {
     $page .= h3("No mice to mate")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_strain_name_by_id($global_var_href, $mating_strain) eq "new strain" && (!defined($new_strain_name) || $new_strain_name eq '')) {
     $page .= p({-class=>"red"}, "You chose \"new strain\", but you did not specify the name of the new strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_line_name_by_id($global_var_href, $mating_line) eq "new line" && (!defined($new_line_name) || $new_line_name eq '')) {
     $page .= p({-class=>"red"}, "You chose \"new line\", but you did not specify the name of the new line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  $page .= h3("Checking mating partners")
           . start_form(-action=>url())   . "\n"
           . "<ul>";

  # again check all mice from selected (they should be ok, since they have been checked before.
  # But 1) a lot can happen before pressing the "setup transfer!" button and 2) we are prepared for users that simply press the browser reload button after setting up a mating
  foreach $mouse (@mice_to_be_mated) {
     $warning = '';

     # 1. check sex
     $sex = get_sex($global_var_href, $mouse);
     $sex_counter{$sex}++;

     # 2. check if mouse is currently in another mating
     $current_mating = db_is_in_mating($global_var_href, $mouse);
     if (defined($current_mating) && ($sex eq 'f')) {
        $errors++;
        $warning .= span({-class=>"red"}, "Cannot mate: female mouse $mouse is currently in active "
                                          . a({-href=>"$url?choice=mating_view&mating_id=$current_mating", -style=>"color:red;", -title=>"click to open mating details in separate window", -target=>"_blank"}, "mating $current_mating")
                                          . "Please remove mouse $mouse from mating $current_mating first."
                        );
     }
     elsif (defined($current_mating) && ($sex eq 'm')) {
        $warning .= span({-class=>"red"}, "Warning: male mouse $mouse is currently in active "
                                          . a({-href=>"$url?choice=mating_view&mating_id=$current_mating", -style=>"color:red;", -title=>"click to open mating details in separate window", -target=>"_blank"}, "mating $current_mating")
                                          . " ."
                        );
     }

     # 3. check if mouse is alive at all
     if (defined(get_date_of_death($global_var_href, $mouse))) {
        #$errors++;
        $warning .= span({-class=>"red"}, "Warning: mouse is dead");
     }

     # 4. check if mouse is in an experiment
     $is_in_experiment = is_in_experiment($global_var_href, $mouse);
     if ($is_in_experiment > 0) {
        $warning .= span({-class=>"red"}, "Warning: mouse $mouse is currently in an "
                                          . a({-href=>"$url?choice=experiment_view&experiment_id=$is_in_experiment", -style=>"color:red;", -title=>"click to open experiment details in separate window", -target=>"_blank"}, "experiment")
                                          . " ."
                        );
     }

     # 5. get date of birth to prevent mating_date < birth_date
     ($birth_datetime_sql) = $dbh->selectrow_array("select mouse_birth_datetime
                                                    from   mice
                                                    where  mouse_id = $mouse
                                                   ");

     # check if mating_date < birth_date: if so, return with error
     if (Delta_ddmmyyyhhmmss($mating_start_datetime, format_sql_datetime2display_datetime($birth_datetime_sql)) eq 'future') {
        $errors++;
        $warning .= span({-class=>"red"}, "Error: mating date cannot be before birth of this mouse");
     }

     $page .= li("checking " . (($sex eq 'm')?'&nbsp;&nbsp;male':'female') .  " mouse " . reformat_number($mouse, 8) . " for mating ... "
                 . (($warning eq '')?'ok':$warning)
                );
  }

  $page .= "</ul>";

  # so far, we checked if at least one of the mating partners cannot be mated, regardless of its sex
  if ($errors > 0) {
     $page .= h3({-class=>"red"}, "Mating not possible")
              . p("At least one of the mating partners in your selection cannot be mated. ")
              . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection");
     return $page;
  }

  $warning = '';

  # now make sure that exactly one male and > 1 females are selected
  if ($sex_counter{'m'} > 1) {
     $errors++;
     $warning .= p("mating with more than one male is not possible");
  }

  # we need at least one female
  if ($sex_counter{'f'} == 0) {
     $errors++;
     $warning .= p("you need at least one female to set up a new mating");
  }

  # don't allow more than four females
  if ($sex_counter{'f'} > 4) {
     $errors++;
     $warning .= p("Cannot set up mating with more than five mice (exceeds cage capacity)");
  }

  # date of mating not given or invalid
  if (!param('mating_start_datetime') || check_datetime_ddmmyyyy_hhmmss(param('mating_start_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date/time of mating not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is mating start datetime in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('mating_start_datetime')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: date/time of mating start is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if ($errors > 0) {
     $page .= h3({-class=>"red"}, "Mating not possible")
              . $warning
              . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and retry");
     return $page;
  }

  # try to get a lock
  &get_semaphore_lock($global_var_href, $user_id);

  ############################################################################################
  # begin transaction
  $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start mating (embryo transfer) transaction)", $sr_name . "-" . __LINE__);

  # ok, now check if this mating requires a new strain
  ($strain_name) = $dbh->selectrow_array("select strain_name
                                          from   mouse_strains
                                          where  strain_id = '$mating_strain'
                                         ");

#   # in case user wants to mate for a new strain ...
#   if ($strain_name eq 'new strain') {
#      # get new strain id for insert
#      ($new_strain_id, $new_strain_order) = $dbh->selectrow_array("select (max(strain_id) + 1) as new_strain_id, (max(strain_order) + 1) as new_strain_order
#                                                                   from   mouse_strains
#                                                                  ");
#      # insert a new strain
#      $sql = qq(insert
#                into   mouse_strains (strain_id, strain_name, strain_order, strain_show, strain_description)
#                values (?, ?, ?, ?, ?)
#               );
#
#      $dbh->do($sql, undef,
#               $new_strain_id, $new_strain_name, $new_strain_order, 'y', 'New strain inserted at mating (embryo transfer) by ' . $session->param('username') . ' at ' . $mating_start_datetime_sql
#              ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new strain)", $sr_name . "-" . __LINE__);
#
#      # use new strain id for mating insert down below
#      $mating_strain = $new_strain_id;
#
#      # tell user to inform administrators about new strain
#      $mating_notification .= p()
#                              . p({-class=>"red"}, b("Important: new strain \"$new_strain_name\" (id: $new_strain_id) has been generated at mating (embryo transfer) "
#                                                     . "Please inform MausDB administrators about this as soon as possible!")
#                                 );
#
#      &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tnew_imported_strain\t$new_strain_name\tnew_strain_id\t$new_strain_id");
#
#      #-------------------------------------------------------
#      # send mail to admin that new strain has been inserted
#      $mailbody =  "MausDB notification: a new strain has been inserted by user \"" . $session->param(-name=>'username') . "\"\n\n"
#                  . "name of new strain: \"$new_strain_name\"\n"
#                  . "id of new strain  : \"$new_strain_id\"\n\n"
#                  . "Please check this new strain!" . "\n";
#
#      %mail_to_admin = (From    => $admin_mail,
#                        To      => $admin_mail,
#                        Subject => "Message from MausDB ($database on $server): new strain inserted at mating (embryo transfer)",
#                        Message => $mailbody
#                      );
#
#      if (sendmail(%mail_to_admin)) {
#        # do nothing
#      }
#      else {
#        &error_message_and_exit($global_var_href, "Could not send mail for new strain to $admin_mail ($Mail::Sendmail::error)", $sr_name . "-" . __LINE__);
#      }
#      #-------------------------------------------------------
#   }

  # ok, now check if this mating requires a new line
  ($line_name) = $dbh->selectrow_array("select line_name
                                        from   mouse_lines
                                        where  line_id = '$mating_line'
                                       ");

#   # in case user wants to mate for a new line ...
#   if ($line_name eq 'new line') {
#      # get new line id for insert
#      ($new_line_id, $new_line_order) = $dbh->selectrow_array("select (max(line_id) + 1) as new_line_id, (max(line_order) + 1) as new_line_order
#                                                               from   mouse_lines
#                                                              ");
#      # insert a new line
#      $sql = qq(insert
#                into   mouse_lines (line_id, line_name, line_long_name, line_order, line_show, line_info_URL, line_comment)
#                values (?, ?, ?, ?, ?, ?, ?)
#               );
#
#      $dbh->do($sql, undef,
#               $new_line_id, $new_line_name, $new_line_name, $new_line_order, 'y', '', 'New line inserted at mating (embryo transfer) by ' . $session->param('username') . ' at ' . $mating_start_datetime_sql
#              ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new line)", $sr_name . "-" . __LINE__);
#
#      # use new line id for mating insert down below
#      $mating_line = $new_line_id;
#
#      # tell user to inform administrators about new strain
#      $mating_notification .= p()
#                              . p({-class=>"red"}, b("Important: a new line \"$new_line_name\" (id: $new_line_id) has been generatedat mating (embryo transfer). "
#                                                     . "Please inform MausDB administrators about this as soon as possible!")
#                                 );
#
#      &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tnew_imported_line\t$new_line_name\tnew_line_id\t$new_line_id");
#
#      #-------------------------------------------------------
#      # send mail to admin that new strain has been inserted
#      $mailbody =  "MausDB notification: a new line has been inserted by user \"" . $session->param(-name=>'username') . "\"\n\n"
#                  . "name of new line: \"$new_line_name\"\n"
#                  . "id of new line  : \"$new_line_id\"\n\n"
#                  . "Please check this new line!" . "\n";
#
#      %mail_to_admin = (From    => $admin_mail,
#                        To      => $admin_mail,
#                        Subject => "Message from MausDB ($database on $server): new line inserted at mating (embryo transfer)",
#                        Message => $mailbody
#                      );
#
#      if (sendmail(%mail_to_admin)) {
#         # do nothing
#      }
#      else {
#         &error_message_and_exit($global_var_href, "Could not send mail for new line to $admin_mail", $sr_name . "-" . __LINE__);
#      }
#      #-------------------------------------------------------
#   }

  ################################################
  # insert new mating
  # get a new mating id
  ($new_mating_id) = $dbh->selectrow_array("select (max(mating_id)+1) as new_mating_id
                                            from   matings
                                           ");

  # only for first mating
  if (!defined($new_mating_id)) { $new_mating_id = 1; }

  # insert mating
  $sql = qq(insert
            into   matings (mating_id, mating_name, mating_matingstart_datetime, mating_matingend_datetime, mating_strain,
                            mating_line, mating_scheme, mating_purpose, mating_project, mating_generation, mating_comment)
            values (?, ?, ?, NULL, ?, ?, ?, ?, ?, ?, ?)
          );

  $dbh->do($sql, undef,
                 $new_mating_id, $mating_name, $mating_start_datetime_sql, $mating_strain, $mating_line, 'embryo transfer',
                 $mating_purpose, $mating_project, '', $mating_comment
          ) or &error_message_and_exit($global_var_href, "SQL error (could not insert mating)", $sr_name . "-" . __LINE__);

  # check if mating has been generated
  ($mating_done) = $dbh->selectrow_array("select count(mating_id)
                                          from   matings
                                          where  mating_id = $new_mating_id
                                         ");

  # no: -> rollback and exit
  if ($mating_done != 1) {
     $rc    = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (something went wrong, but rollback failed)", $sr_name . "-" . __LINE__);

     &release_semaphore_lock($global_var_href, $user_id);
     $page .= p({-class=>"red"}, "Something went wrong when trying to set up mating.");
     return $page;
  }

  ################################################
  # insert new embryo transfer

  # get a new embryo transfer id
  ($new_embryo_transfer_id) = $dbh->selectrow_array("select (max(transfer_id)+1) as new_transfer_id
                                                     from   embryo_transfers
                                                    ");

  # only for first embryo transfer
  if (!defined($new_embryo_transfer_id)) { $new_embryo_transfer_id = 1; }

  # insert embryo transfer
  $sql = qq(insert
            into   embryo_transfers (transfer_id, transfer_mating_id, transfer_embryo_id, transfer_embryo_id_context, transfer_embryo_production,
                                     transfer_sperm_preservation, transfer_IVF_assistance, transfer_embryo_preservation, transfer_transgenic_manipulation,
                                     transfer_background_donor_cells, transfer_background_ES_cells, transfer_name_of_construct, transfer_comment)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          );

  $dbh->do($sql, undef,
                 $new_embryo_transfer_id, $new_mating_id, $embryo_id, $embryo_origin, $embryo_production,
                 $sperm_frozen, $IVF_assistance, $embryo_preservation, $manipulation_method,
                 $background_of_donor_cells, $background_of_ES_cell_line, $name_of_construct, qq(External genetic father: $genetic_father_id ($genetic_father_origin))
          ) or &error_message_and_exit($global_var_href, "SQL error (could not insert embryo transfer)", $sr_name . "-" . __LINE__);


  # check if transfer has been generated
  ($mating_done) = $dbh->selectrow_array("select count(transfer_id)
                                          from   embryo_transfers
                                          where  transfer_id = $new_embryo_transfer_id
                                         ");

  # no: -> rollback and exit
  if ($mating_done != 1) {
     $rc    = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (something went wrong, but rollback failed)", $sr_name . "-" . __LINE__);

     &release_semaphore_lock($global_var_href, $user_id);
     $page .= p({-class=>"red"}, "Something went wrong when trying to set up transfer.");
     return $page;
  }

  ################################################

  %sex_counter = ();

  # now add all parents to this mating
  foreach $mouse (@mice_to_be_mated) {
     # check sex
     $sex = get_sex($global_var_href, $mouse);
     $sex_counter{$sex}++;

     # roll back if female mouse is in another mating in the meanwhile
     $current_mating = db_is_in_mating($global_var_href, $mouse);
     if (defined($current_mating) && ($sex eq 'f')) {
        $rc    = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (female in another mating, but rollback failed)", $sr_name . "-" . __LINE__);

        &release_semaphore_lock($global_var_href, $user_id);
        $page .= p({-class=>"red"}, "Female mouse $mouse is already in another mating. Can't set up mating.");
        return $page;
     }

     # add this mouse to the mating
     $sql = qq(insert
               into   parents2matings (p2m_mating_id, p2m_parent_id, p2m_parent_type, p2m_parent_start_date, p2m_parent_end_date)
               values ($new_mating_id, $mouse, ?, ?, NULL)
              );

     $dbh->do($sql, undef,
                    (($sex eq 'm')?'father':'recipient mother'), $mating_start_datetime_sql
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert parent $mouse)", $sr_name . "-" . __LINE__);

     # get current cage for this mouse
     $current_cage = get_cage($global_var_href, $mouse);

     # no move involved
     $moved_mouse .= li("mouse " . reformat_number($mouse, 8) . " stays in cage " . $current_cage);

     # mice will not be moved for embryo transfer, so the mating cage will be the cage with the female in it
     # if more than one female is involved, the last female cage will be assigned mating cage
     # which of course is a problem when females sit in different cages. We simply ignore this strange scenario :-))
     if ($sex eq 'f') {
        $assigned_mating_cage = $current_cage;
     }
  }

  # roll back if more than one male
  if ($sex_counter{'m'} > 1) {
     $rc    = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (more than one male, but rollback failed)", $sr_name . "-" . __LINE__);

     &release_semaphore_lock($global_var_href, $user_id);
     $page .= p({-class=>"red"}, "Can't set up mating with more than one male.");
     return $page;
  }

  # mating generated, so commit
  $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

  # end transaction
  ############################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $user_id);

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tnew_mating_(embryo_transfer)\t$new_mating_id\ttransfer_id\t$new_embryo_transfer_id\t$mating_start_datetime_sql\t" . join(',', @mice_to_be_mated));

  $page .= h3("Moving mice")
           . ul($moved_mouse)
           . p()
           . h3("Setting up new mating")
           . p("Mating (type: embryo transfer) successfully set up in "
                . a({-href=>"$url?choice=cage_view&cage_id=" . $assigned_mating_cage}, " cage " . $assigned_mating_cage)
                . " ("
                . a({-href => "$url?choice=print_card&cage_id=$assigned_mating_cage", -target=>"_blank"}, "print cage card")
                . ")."
             )
           . p(" See " . a({-href=>"$url?choice=mating_view&mating_id=$new_mating_id"},"mating $new_mating_id") . " for details. ")
           . $mating_notification;

  return $page;
}
# end of db_set_up_transfer()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_MAT008 update_litter_details():                     update litter details (1. step)
sub update_litter_details {                              my $sr_name = 'SR_MAT008';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};           # get session handle
  my $dbh               = $global_var_href->{'dbh'};               # DBI database handle
  my $litter_id         = param('litter_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;
  my $parameter;
  my ($litter_born);

  $page .= h2("Update litter details (" . a({-href=>"$url?choice=litter_view&litter_id=" . $litter_id}, "litter $litter_id")  . ")" )
           . hr()
           . start_form(-action=>url())
           . hidden(-name=>"litter_id");

  # check input: is litter id given? is it a number?
  if (!param('litter_id') || param('litter_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid litter id"));
     return $page;
  }

  # get basic litter data
  $sql = qq(select litter_id, litter_mating_id, litter_in_mating, litter_born_datetime, litter_alive_total,
                   litter_alive_male, litter_alive_female, litter_dead_total, litter_dead_male, litter_dead_female,
                   litter_reduced, litter_reduced_reason, litter_weaning_datetime, litter_comment
            from   litters
            where  litter_id = ?
           );

  @sql_parameters = ($litter_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no such litter found: tell and quit
  unless ($rows > 0) {
     $page .= p("No such litter found");
     return $page;
  }

  # else continue: get the first (and hopefully only) result
  $row = $result->[0];
  $litter_born    = $row->{'litter_born_datetime'};

  # litter table
  $page .= h3("Please update litter details")
           . table( {-border=>1, -summary=>"table"},
                Tr(
                  th(" date of birth "),
                  td({-colspan=>3}, format_sql_datetime2display_datetime($litter_born))
                ) .
                Tr(
                  th(" living pups "),
                  td(b("total")  . br() . popup_menu(-name=>'litter_alive_total',   -values=>["0" .. "25"], -default=>$row->{'litter_alive_total'},  -title=>"number of all living pups"    )),
                  td(b("male")   . br() . popup_menu(-name=>'litter_alive_male',    -values=>["0" .. "25"], -default=>$row->{'litter_alive_male'},   -title=>"number of living male pups"   )),
                  td(b("female") . br() . popup_menu(-name=>'litter_alive_female',  -values=>["0" .. "25"], -default=>$row->{'litter_alive_female'}, -title=>"number of living female pups" ))
                ) .
                Tr(
                  th("dead"),
                  td(b("total")  . br() . popup_menu(-name=>'litter_dead_total',    -values=>["0" .. "25"], -default=>$row->{'litter_dead_total'},   -title=>"number of all dead pups"  )),
                  td(b("male")   . br() . popup_menu(-name=>'litter_dead_male',     -values=>["0" .. "25"], -default=>$row->{'litter_dead_male'},    -title=>"number of dead male pups" )),
                  td(b("female") . br() . popup_menu(-name=>'litter_dead_female',   -values=>["0" .. "25"], -default=>$row->{'litter_dead_female'},  -title=>"number of dead female pups" ))
                ) .
                Tr(
                  th("reduced"),
                  td({-colspan=>3}, popup_menu(-name=>'litter_reduced_total',       -values=>["0" .. "25"], -default=>$row->{'litter_reduced'},      -title=>"number of reduced (killed) pups" ) . br()
                                    . "if any reduced, why?" . br()
                                    . textarea( -name=>'litter_reduced_reason',  -columns=>"30", -rows=>"3", -title=>"give a reason why litter has been reduced", -value=>$row->{'litter_reduced_reason'})
                  )
                ) .
                Tr(
                  th("litter comment"),
                  td({-colspan=>3}, textarea(-name=>"litter_comment", -columns=>"40", -rows=>"5", -value=>$row->{'litter_comment'}, -title=>"enter any comment on this litter" ))
                )
             )
           . p()
           . submit(-name => "job", -value=>"Update litter details", -title=>"Update litter details")
           . end_form();

  return $page;
}
# end of update_litter_details()
#--------------------------------------------------------------------------------------




# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;