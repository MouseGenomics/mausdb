# lib_kill.pl - a MausDB subroutine library file                                                                                      #
#                                                                                                                                     #
# Subroutines in this file provide killing functions                                                                                  #
#                                                                                                                                     #
#-------------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                                 #
#-------------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                     #
# SR_KIL001 kill_mouse                                    kill selected mice                                                          #
# SR_KIL002 confirmed_kill_mouse                          confirmed kill selected mice (do the real killing)                          #
# SR_KIL003 db_kill_mouse                                 kill a mouse in the database                                                #
# SR_KIL004 reanimate_mouse                               reanimate a given mouse                                                     #
# SR_KIL005 db_reanimate_mouse                            reanimate a given mouse (database transaction)                              #
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


#--------------------------------------------------------------------------------------
# SR_KIL001 kill_mouse                                    kill selected mice
sub kill_mouse {                                          my $sr_name = 'SR_KIL001';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $mouse);
  my $url               = url();
  my @mice_to_be_killed = ();
  my $is_in_mating;

  # create popup menus for death reasons
  my ($how_popup_menu, $why_popup_menu) = get_death_reasons_popup_menus($global_var_href, 3, 6);         # 3 (killed) and 6 (unknown) are the default values of the popup-menus

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB ids
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_killed, $mouse);
     }
     # else ignore ...
  }

  # exit if no mice selected
  if (scalar @mice_to_be_killed == 0) {
     $page .= h2("Kill")
              . hr()
              . h3("No mice to kill")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # otherwise continue
  $page .= h2("Kill")
           . hr()
           . h3("Please confirm killing of animal(s) listed below")
           . start_form(-action=>url())    . "\n"
           . hidden(-name=>'mouse_select') . "\n"
           . "<ul>";                                                             # start tag for list

  # loop over mice to be killed
  foreach $mouse (@mice_to_be_killed) {
     # check if mouse is in mating
     $is_in_mating = db_is_in_mating($global_var_href, $mouse);

     $page .= li("selected for killing: mouse " . a( {-href=>"$url?choice=mouse_details&mouse_id=" . $mouse}, $mouse)
                 . ((defined($is_in_mating))
                    ?span({-class=>"red"}, "[Warning: mouse $mouse is currently in active "
                                           . a({-href=>"$url?choice=mating_view&mating_id=$is_in_mating", -style=>"color:red;", title=>"click to open mating details in separate window", -target=>"_blank"}, "mating $is_in_mating]")
                                           . "Confirm kill will remove mouse $mouse from mating $is_in_mating and potentially end the mating"
                     )
                    :''
                   )
                );
  }

  $page .= "</ul>"                                                              # end tag for list
           . h3("... and choose killing reasons")
           . p("Date and time of death "
               . textfield(-name      => 'datetime_of_death',
                           -id        => 'datetime_of_death',
                           -size      => '20',
                           -maxlength => '21',
                           -title     => 'date and time of death',
                           -value     => get_current_datetime_for_display()
                 )
               . "&nbsp;&nbsp;"
               . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=datetime_of_death', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
             )
           . p("Killing reason (how): " . $how_popup_menu)
           . p("Killing reason (why): " . $why_popup_menu)
           . p()
           . submit(-name => "choice", -value=>"confirm kill")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel killing (go to previous page)"))
           . end_form();

  return $page;
}
# end of kill_mouse()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_KIL002 confirmed_kill_mouse                          confirmed kill selected mice (do the real killing)
sub confirmed_kill_mouse {                                my $sr_name = 'SR_KIL002';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $killed_how_id = param('killed_how');                # death reason (how): "killed", "found dead", "died in experiment"
  my $killed_why_id = param('killed_why');                # death reason (why): "breeding excess", "ill", "final experiment"
  my $kill_datetime = param('datetime_of_death');         # date of death
  my @selected_mice = param('mouse_select');              # list of selected mice from CGI form
  my ($page, $mouse, $sql);
  my $url               = url();
  my @mice_to_be_killed = ();
  my ($error_code, $error_message);
  my ($killed_how, $killed_why);
  my @sql_parameters;

  # check input
  unless (param('killed_how') && param('killed_how') =~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: Please give a valid death reason (how)."));
     return $page;
  }
  unless (param('killed_why') && param('killed_why') =~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: Please give a valid death reason (how)."));
     return $page;
  }

  # date of death not given or invalid
  if (!param('datetime_of_death') || check_datetime_ddmmyyyy_hhmmss(param('datetime_of_death')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date/time of death not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is date of death in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('datetime_of_death')) eq 'future') {
     $page .= h2("Kill mouse ")
              . hr()
              . p({-class=>"red"}, b("Error: date/time of killing is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # just get names of kill reasons by id for display
  $sql = qq(select death_reason_name
            from   death_reasons
            where  death_reason_id = ?
           );

  @sql_parameters = ($killed_how_id);

  ($killed_how) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $sql = qq(select death_reason_name
            from   death_reasons
            where  death_reason_id = ?
           );

  @sql_parameters = ($killed_why_id);

  ($killed_why) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # check list of mouse ids for being MausDB ids
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_killed, $mouse);
     }
     # else ignore ...
  }

  $page .= h2("Kill")
           . hr()
           . h3("Killing animal(s) listed below")
           . p(qq(How: "$killed_how") . br() . qq(Why: "$killed_why"))
           . p()
           . "<ul>";

  # loop over mice to be killed
  foreach $mouse (@mice_to_be_killed) {
     # call kill transaction
     ($error_code, $error_message) = db_kill_mouse($global_var_href, $mouse, $killed_how_id, $killed_why_id, $kill_datetime);

     # display kill result
     $page .= li("trying to kill mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse}, reformat_number($mouse, 8)) . " ... " . $error_message);
  }

  $page .= "</ul>";

  return $page;
}
# end of confirmed_kill_mouse()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_KIL003 db_kill_mouse                                 kill a mouse in the database
sub db_kill_mouse {                                       my $sr_name = 'SR_KIL003';
  my $global_var_href = $_[0];                            # get reference to global vars hash
  my $mouse_id        = $_[1];                            # mouse to kill
  my $killed_how      = $_[2];                            # death reason (how): "killed", "found dead", "died in experiment"
  my $killed_why      = $_[3];                            # death reason (why): "breeding excess", "ill", "final experiment"
  my $kill_datetime   = $_[4];                            # date and time of death
  my $dbh             = $global_var_href->{'dbh'};        # DBI database handle
  my $session         = $global_var_href->{'session'};    # session handle
  my $move_user_id    = $session->param('user_id');
  my $datetime_now    = get_current_datetime_for_sql();
  my ($is_dead, $source_cage, $source_location, $target_location, $move_mode, $is_in_mating, $was_in_mating, $cage_of_this_mouse);
  my ($rc, $no_mice, $no_partners, $capacity, $return_value, $is_in_experiment, $experiment_end);
  my $target_cage     = -1;                                  # cage -1 is the collect cage for all dead mice
  my $datetime_sql    = format_display_datetime2sql_datetime($kill_datetime);
  my @current_matings = ();
  my $current_mating;
  my ($birth_datetime_sql, $import_datetime_sql);

  # 1. check mouse_id. exit on failure
  if (!defined($mouse_id) || $mouse_id !~ /^[0-9]{8}$/) {
     return (1, span({-class=>'red'}, "ignored (invalid mouse id)"));
  }

  # 2. check if mouse is still alive at all (makes no sense to kill a mouse that is already dead)
  ($is_dead) = $dbh->selectrow_array("select mouse_deathorexport_datetime
                                      from   mice
                                      where  mouse_id = $mouse_id
                                     ");

  # if there is a date of death, mouse is dead: we don't even start the transaction
  if (defined($is_dead)) {
     return (1, span({-class=>'red'}, "ignored (mouse is already dead)"));
  }

  # 3. get date of birth to prevent kill_date < birth_date
  ($birth_datetime_sql) = $dbh->selectrow_array("select mouse_birth_datetime
                                                 from   mice
                                                 where  mouse_id = $mouse_id
                                                ");

  # check if kill_date < birth_date: if so, return with error
  if (Delta_ddmmyyyhhmmss($kill_datetime, format_sql_datetime2display_datetime($birth_datetime_sql)) eq 'future') {
     return (1, span({-class=>'red'}, "ignored (date of death cannot be before date of birth)"));
  }

  # 4. get date of import to prevent kill_date < import_date
  ($import_datetime_sql) = $dbh->selectrow_array("select import_datetime
                                                  from   mice
                                                         left join imports on mouse_import_id = import_id
                                                  where  mouse_id = $mouse_id
                                                 ");

  # check if kill_date < import_date: if so, return with error
  if (defined($import_datetime_sql) && Delta_ddmmyyyhhmmss($kill_datetime, format_sql_datetime2display_datetime($import_datetime_sql)) eq 'future') {
     return (1, span({-class=>'red'}, "ignored (date of death cannot be before date of import)"));
  }

  # try to get a lock
  &get_semaphore_lock($global_var_href, $move_user_id);

  ############################################################################################
  # begin transaction
  $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start transaction)", $sr_name . "-" . __LINE__);

  # 0. determine cage in which mouse currently lives
  ($source_cage) = $dbh->selectrow_array("select m2c_cage_id
                                          from   mice2cages
                                          where  m2c_mouse_id = $mouse_id
                                                 and m2c_datetime_to IS NULL
                                         ");

  # 1. determine location in which mouse currently lives
  ($source_location) = $dbh->selectrow_array("select c2l_location_id
                                              from   cages2locations
                                              where  c2l_cage_id = $source_cage
                                                     and c2l_datetime_to IS NULL
                                             ");

  # 2. update source cage in mice2cages: add m2c_datetime_to for mouse_id and source cage
  $dbh->do("update  mice2cages
            set     m2c_datetime_to = ?
            where   m2c_mouse_id    = ?
                    and m2c_cage_id = ?
                    and m2c_datetime_to IS NULL
           ", undef, "$datetime_sql", $mouse_id, $source_cage
        ) or &error_message_and_exit($global_var_href, "SQL error (could not update cage)", $sr_name . "-" . __LINE__);

  # 2,5. determine next movement number (counter for number of cages of this particular mouse)
  ($cage_of_this_mouse) = $dbh->selectrow_array("select (max(m2c_cage_of_this_mouse)+1) as cage_of_this_mouse
                                                 from   mice2cages
                                                 where  m2c_mouse_id = '$mouse_id'
                                                ");

  # 3. insert target cage (final cage = -1) into mice2cages: add mouse_id, target_cage, datetime_from
  $dbh->do("insert
            into    mice2cages (m2c_mouse_id, m2c_cage_id, m2c_cage_of_this_mouse, m2c_datetime_from, m2c_datetime_to, m2c_move_user_id, m2c_move_datetime)
            values  (?, ?, ?, ?, NULL, ?, ?)
           ", undef, $mouse_id, $target_cage, $cage_of_this_mouse, "$datetime_sql", $move_user_id, $datetime_now
          ) or &error_message_and_exit($global_var_href, "SQL error (could not move mouse to final cage)", $sr_name . "-" . __LINE__);

  # 4. update mouse date in mice: change some fields
  $dbh->do("update  mice
            set     mouse_deathorexport_datetime = ?, mouse_deathorexport_how = ?, mouse_deathorexport_why = ?
            where   mouse_id  = ?
           ", undef, "$datetime_sql", $killed_how, $killed_why, $mouse_id
          ) or &error_message_and_exit($global_var_href, "SQL error (could not update mouse data)", $sr_name . "-" . __LINE__);

  # so far, this was the killing and the movement only, now check for any other consequences

  # 6. is the source cage empty now?
  ($no_mice) = $dbh->selectrow_array("select count(*)
                                      from   mice2cages
                                      where  m2c_cage_id = $source_cage
                                             and m2c_datetime_to IS NULL
                                     ");

  # yes, this was the last mouse in the source cage: clean up this cage and make it available for new mice to move in
  if ($no_mice == 0) {
     #  update cages: set cage_occupied='n', cage_project=null, cage_contact=null, cage_purpose=null for source_cage (= make cage free)
     $dbh->do("update cages
               set    cage_occupied = ?, cage_purpose = ?, cage_cardcolor = ?, cage_project = ?, cage_user = ?
               where  cage_id = ?
              ", undef, 'n', '-', 7, 1, 1, $source_cage
             ) or &error_message_and_exit($global_var_href, "SQL error (could not empty cage)", $sr_name . "-" . __LINE__);

     # update cages2locations: add c2l_datetime_to for source_cage and source_location (= make rack slot free)
     $dbh->do("update  cages2locations
               set     c2l_datetime_to      = ?
               where   c2l_cage_id          = ?
                       and c2l_location_id  = ?
                       and c2l_datetime_to  IS NULL
              ", undef, "$datetime_sql", $source_cage, $source_location
             ) or &error_message_and_exit($global_var_href, "SQL error (could not remove empty cage)", $sr_name . "-" . __LINE__);
  }

  # 7. was the mouse currently in any matings?
  @current_matings= db_is_in_matings($global_var_href, $mouse_id);             # list of all matings in which mouse is active partner

  foreach $current_mating (@current_matings) {
     # update parents2matings: set p2m_parent_end_date
     $dbh->do("update parents2matings
               set    p2m_parent_end_date = ?
               where  p2m_mating_id       = ?
                      and p2m_parent_id   = ?
              ", undef, "$datetime_sql", $current_mating, $mouse_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update parent table)", $sr_name . "-" . __LINE__);

     # stop mating if last female left mating
    ($no_partners) = $dbh->selectrow_array("select count(p2m_parent_id) as no_partners
                                            from   parents2matings
                                            where  p2m_mating_id = $current_mating
                                                   and p2m_parent_type like '%mothe%'
                                                   and p2m_parent_end_date IS NULL
                                           ");
    if ($no_partners == 0) {        # no mothers left!
       # 1) if no female left in mating => update matings, set mating_matingend_datetime
       $dbh->do("update matings
                 set    mating_matingend_datetime = ?
                 where  mating_id = ?
                ", undef, "$datetime_sql", $current_mating
             ) or &error_message_and_exit($global_var_href, "SQL error (could not set mating end datetime)", $sr_name . "-" . __LINE__);

       # 2) if no female left in mating => set mating_matingend_datetime for all remaining partners that have not been previously removed
       $dbh->do("update  parents2matings
                 set     p2m_parent_end_date = ?
                 where   p2m_mating_id = ?
                         and p2m_parent_end_date IS NULL
                ", undef, $datetime_sql, $current_mating
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update parentships of mating)", $sr_name . "-" . __LINE__);
    }
  }

  # 8. is the mouse currently in an experiment?
  $is_in_experiment = is_in_experiment($global_var_href, $mouse_id);

  # yes, mouse is in an experiment: set end date for this mouse, if not set yet
  if ($is_in_experiment > 0) {
     # check if experiment end date is set
    ($experiment_end) = $dbh->selectrow_array("select m2e_datetime_to
                                               from   mice2experiments
                                               where  m2e_mouse_id = $mouse_id
                                                      and m2e_experiment_id = $is_in_experiment
                                              ");
    if (!defined($experiment_end)) {
       # if no experiment end date set => update mice2experiments, set experiment end date (m2e_datetime_to)
       $dbh->do("update mice2experiments
                 set    m2e_datetime_to = ?, m2e_inserted_by = ?
                 where  m2e_mouse_id = ?
                        and m2e_experiment_id = ?
                ", undef, "$datetime_sql", $move_user_id, $mouse_id, $is_in_experiment
             ) or &error_message_and_exit($global_var_href, "SQL error (could not set mating end datetime)", $sr_name . "-" . __LINE__);
    }
  }

  # 9. set an end date in the mice2cost_accounts table
  $dbh->do("update mice2cost_accounts
            set    m2ca_datetime_to = ?
            where  m2ca_mouse_id = ?
                   and m2ca_datetime_to is NULL
           ", undef, "$datetime_sql", $mouse_id
          ) or &error_message_and_exit($global_var_href, "SQL error (could not set cost center end datetime)", $sr_name . "-" . __LINE__);

  $rc  = $dbh->commit or &error_message_and_exit($global_var_href, "SQL error (could not commit killing transaction)", $sr_name . "-" . __LINE__);

  # end of transaction
  ############################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $move_user_id);

  &write_textlog($global_var_href, "$datetime_now\t$move_user_id\t" . $session->param('username') . "\tkill_mouse\t$mouse_id\t$datetime_sql");

  return (0, "successfull");
}
# end of db_kill_mouse
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_KIL004 reanimate_mouse                               reanimate a given mouse
sub reanimate_mouse {                                     my $sr_name = 'SR_KIL004';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $mouse_id          = param('mouse_id');
  my $url               = url();
  my ($page, $transaction_status, $transaction_message, $cage_id);

  # check given mouse id
  if (!defined(param('mouse_id')) || param('mouse_id') !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid mouse id (must be a number)", $sr_name . "-" . __LINE__);
  }

  $page .= h2("Reanimate a mouse ")
           . hr();

  # call the subroutine to do the database transaction
  ($transaction_status, $transaction_message, $cage_id) = &db_reanimate_mouse($global_var_href, $mouse_id, 99999);

  if ($transaction_status == 0) {
     $page .=  p(b("Status"))

               . p("Ok, reanimated mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id"}, "$mouse_id")
                   . ' into cage ' . a({-href=>"$url?choice=cage_view&cage_id=$cage_id"}, "$cage_id")
                 )

               . p({-class=>"red"}, "Please move mouse to a real location now by clicking " . a({-href=>"$url?choice=move_mouse&mouse_id=$mouse_id"}, " here"));
  }
  elsif ($transaction_status == -1) {
     $page .=  p(b("Status"))
               . p({-class=>"red"}, "Sorry, could not reanimate mouse $mouse_id. It was not dead before. ");
  }

  return ($page);
}
# reanimate_mouse
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_KIL005 db_reanimate_mouse                            reanimate a given mouse (database transaction)
sub db_reanimate_mouse {                                  my $sr_name = 'SR_KIL005';
  my ($global_var_href) = $_[0];                          # get reference to global vars hash
  my $mouse_id          = $_[1];
  my $target_cage       = $_[2];
  my $dbh               = $global_var_href->{'dbh'};        # DBI database handle
  my $session           = $global_var_href->{'session'};    # session handle
  my $move_user_id      = $session->param('user_id');
  my $datetime_sql      = get_current_datetime_for_sql();
  my ($rc, $datetime_of_death, $source_cage, $source_location, $cage_of_this_mouse, $target_location, $datetime_of_death_sql);

  # try to get a lock
  &get_semaphore_lock($global_var_href, $move_user_id);

  ############################################################################################
  # begin transaction
  $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start reanimation transaction)", $sr_name . "-" . __LINE__);

  # 0. determine cage in which mouse currently lives (should be -1)
  ($source_cage, $cage_of_this_mouse) = $dbh->selectrow_array("select m2c_cage_id, m2c_cage_of_this_mouse
                                                               from   mice2cages
                                                               where  m2c_mouse_id = $mouse_id
                                                                      and m2c_datetime_to IS NULL
                                                              ");

  # 0. check if mouse is dead (mouse_deathorexport_datetime should be defined)
  ($datetime_of_death) = $dbh->selectrow_array("select mouse_deathorexport_datetime
                                                from   mice
                                                where  mouse_id = $mouse_id
                                               ");

  # dead mouse must be in collect cage (-1) and there must be a datetime of death for that mouse
  if ($source_cage != -1 || !defined($datetime_of_death)) {
     $rc  = $dbh->rollback;
     &release_semaphore_lock($global_var_href, $move_user_id);
     return (-1, "Could not re-animate. Mouse was not dead.", 0);
  }

  # 1. determine location in which mouse currently lives (should be the rack for death cage)
  ($source_location) = $dbh->selectrow_array("select c2l_location_id
                                              from   cages2locations
                                              where  c2l_cage_id = $source_cage
                                                     and c2l_datetime_to IS NULL
                                             ");

  # 2. update source cage in mice2cages: add m2c_datetime_to for mouse_id and source cage and last movement
  $dbh->do("update  mice2cages
            set     m2c_datetime_to = ?
            where   m2c_mouse_id    = ?
                    and m2c_cage_id = ?
                    and m2c_cage_of_this_mouse = ?
           ", undef, "$datetime_sql", $mouse_id, $source_cage, $cage_of_this_mouse
          ) or &error_message_and_exit($global_var_href, "SQL error (could not update cage)", $sr_name . "-" . __LINE__);

  # 2,5. determine next movement number (counter for number of cages of this particular mouse)
  ($cage_of_this_mouse) = $dbh->selectrow_array("select (max(m2c_cage_of_this_mouse)+1) as cage_of_this_mouse
                                                 from   mice2cages
                                                 where  m2c_mouse_id = '$mouse_id'
                                                ");

  # 3. insert target cage (reanimation cage = 99999) into mice2cages: add mouse_id, target_cage, datetime_from
  $dbh->do("insert
            into    mice2cages (m2c_mouse_id, m2c_cage_id, m2c_cage_of_this_mouse, m2c_datetime_from, m2c_datetime_to, m2c_move_user_id, m2c_move_datetime)
            values  (?, ?, ?, ?, NULL, ?, ?)
           ", undef, $mouse_id, $target_cage, $cage_of_this_mouse, "$datetime_sql", $move_user_id, $datetime_sql
          ) or &error_message_and_exit($global_var_href, "SQL error (could not move mouse to final cage)", $sr_name . "-" . __LINE__);

  # 1. determine target location
  ($target_location) = $dbh->selectrow_array("select c2l_location_id
                                              from   cages2locations
                                              where  c2l_cage_id = $target_cage
                                                     and c2l_datetime_to IS NULL
                                             ");

  if (!defined($target_location)) {
     $dbh->do("insert
               into    cages2locations (c2l_cage_id, c2l_location_id, c2l_datetime_from, c2l_datetime_to, c2l_move_user_id, c2l_move_datetime)
               values  (?, ?, ?, NULL, ?, ?)
              ", undef, $target_cage, 0, $datetime_sql, $move_user_id, $datetime_sql
           ) or &error_message_and_exit($global_var_href, "SQL error (could not update new rack)", $sr_name . "-" . __LINE__);
  }

  # 5. mark target cage as occupied:
  $dbh->do("update  cages
            set     cage_occupied = ?, cage_project = ?, cage_user = ?, cage_purpose = ?
            where   cage_id = ?
           ", undef, "y", 1, 1, '-', $target_cage
          ) or &error_message_and_exit($global_var_href, "SQL error (could not update reanimation cage)", $sr_name . "-" . __LINE__);

  # store datetime of death before NULLing it (we need it later)
  ($datetime_of_death_sql) = $dbh->selectrow_array("select mouse_deathorexport_datetime
                                                    from   mice
                                                    where  mouse_id = $mouse_id
                                                   ");

  # 4. update mouse data in table 'mice': change some fields
  $dbh->do("update  mice
            set     mouse_deathorexport_datetime = ?, mouse_deathorexport_how = ?, mouse_deathorexport_why = ?
            where   mouse_id  = ?
           ", undef, undef, 1, 2, $mouse_id
          ) or &error_message_and_exit($global_var_href, "SQL error (could not update mouse data)", $sr_name . "-" . __LINE__);

  # 5. remove experiment end date for this mouse that have been set before when mouse was killed
  $dbh->do("update mice2experiments
            set    m2e_datetime_to = ?, m2e_inserted_by = ?
            where  m2e_mouse_id = ?
                   and m2e_datetime_to = ?
           ", undef, undef, $move_user_id, $mouse_id, "$datetime_of_death_sql"
          ) or &error_message_and_exit($global_var_href, "SQL error (could not un-end experiment)", $sr_name . "-" . __LINE__);

  # 6. remove cost account end date for this mouse that have been set before when mouse was killed
  $dbh->do("update mice2cost_accounts
            set    m2ca_datetime_to = ?
            where  m2ca_mouse_id = ?
                   and m2ca_datetime_to = ?
           ", undef, undef, $mouse_id, "$datetime_of_death_sql"
          ) or &error_message_and_exit($global_var_href, "SQL error (could not un-end cost center)", $sr_name . "-" . __LINE__);

  $rc  = $dbh->commit or &error_message_and_exit($global_var_href, "SQL error (could not commit reanimation transaction)", $sr_name . "-" . __LINE__);

  # end of transaction
  ############################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $move_user_id);

  &write_textlog($global_var_href, "$datetime_sql\t$move_user_id\t" . $session->param('username') . "\tre-animate_mouse\t$mouse_id");

  return (0, "ok", $target_cage);

}
# db_reanimate_mouse
#--------------------------------------------------------------------------------------




# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;