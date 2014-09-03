# lib_move.pl - a MausDB subroutine library file                                                                                 #
#                                                                                                                                #
# Subroutines in this file provide functions related to move mice and cage                                                       #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_MOV001 move_cage():                                 move a cage (form)                                                      #
# SR_MOV002 confirmed_cage_move                          confirmed cage move (wrapper for cage move transaction)                 #
# SR_MOV003 db_move_cage():                              move a cage (do the transaction)                                        #
# SR_MOV004 move_mouse():                                move a mouse (form)                                                     #
# SR_MOV005 confirmed_mouse_move                         confirmed mouse move (wrapper for mouse move transaction)               #
# SR_MOV006 db_move_mouse():                             move a mouse (do the transaction)                                       #
# SR_MOV007 move_cages():                                move selected cages                                                     #
# SR_MOV008 confirmed_cages_move                         confirmed cages move (wrapper for cage move transaction)                #
# SR_MOV009 move_mice():                                 move selected mice                                                      #
# SR_MOV010 confirmed_mice_move                          confirmed mice move (wrapper for mouse move transaction)                #
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
# SR_MOV001 move_cage():                                 move a cage
sub move_cage {                                          my $sr_name = 'SR_MOV001';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $cage_id           = param('cage_id');
  my %radio_labels      = ("screen" => "", "all" => "");
  my ($page, $location_id, $location_room, $location_rack);

  if (!defined($cage_id) || $cage_id !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid cage id (must be a number).", $sr_name . "-" . __LINE__);
  }

  # do not allow to move re-animation cage 99999 to another rack
  if ($cage_id == 99999) {
     $page .= h2("Move cage ")
              . hr()
              . p({-class=>"red"}, b("Error: Move of re-animation cage to another rack is not allowed "));
     return $page;
  }

  # get rack in which cage is currently placed + details
  $location_id = get_cage_location($global_var_href, $cage_id);
  (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, $location_id);

  $page .= h2("Move cage ")
          . hr()
          . h3("Move cage " . $cage_id . " from rack " . a({-href=>"$url?choice=location_details&location_id=" . $location_id}, "$location_room-$location_rack"))
          . start_form(-action=>url(), -name=>"myform")
          . p("1) Move date "
              . textfield(-name=>'datetime_of_move',
                          -id=>"datetime_of_move",
                          -size=>"20",
                          -maxlength=>"21",
                          -title=>"date and time of move",
                          -value=>get_current_datetime_for_display()
                )
              . "&nbsp;&nbsp;"
              . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=datetime_of_move', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
            )
          . p("2) Please choose target rack ")
          . table({-border=>0, -summary=>"table"},
                  Tr(
                    td(),
                    th("racks from your screen"),
                    th({-colspan=>2}, "or"),
                    th("all racks")
                  ) .
                  Tr(
                    td(radio_group(-name=>'which_racks', -values=>['screen'], -default=>'screen', -labels=>\%radio_labels)),
                    td(span({-onclick=>"document.myform.which_racks[0].checked=true"}, get_locations_popup_menu($global_var_href, undef, 'cage_count', 'screen_racks_only'))),
                    td("&nbsp;&nbsp;&nbsp;&nbsp;"),
                    td(radio_group(-name=>'which_racks', -values=>['all'], -default=>'screen', -labels=>\%radio_labels)),
                    td(span({-onclick=>"document.myform.which_racks[1].checked=true"}, get_locations_popup_menu($global_var_href, undef, 'cage_count')))
                  )
            )
          . hidden(-name=>'cage_id')
          . p()
          . submit(-name => "choice", -value=>"move cage!") . "&nbsp;&nbsp;&nbsp;or&nbsp;&nbsp;&nbsp;" . a({-href=>"javascript:back()"}, "cancel (go to previous page)")
          . end_form();

  return $page;
}
# end of move_cage
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MOV002 confirmed_cage_move                          confirmed cage move (wrapper for cage move transaction)
sub confirmed_cage_move {                                my $sr_name = 'SR_MOV002';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $cage_id          = param('cage_id');               # cage to be moved
  my $which_racks      = param('which_racks');           # switch to decide if target rack selection from 'all_racks' or from 'screen_racks'
  my $all_racks        = param('all_racks');
  my $screen_racks     = param('screen_racks');
  my $datetime_of_move = param('datetime_of_move');
  my $url              = url();
  my ($page, $sql);
  my ($error_code, $error_message, $target_rack);
  my ($current_rack, $current_location_room, $current_location_rack);
  my ($target_location_room,  $target_location_rack);

  # check input
  if (!defined($cage_id) || $cage_id !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid cage id (must be a number).", $sr_name . "-" . __LINE__);
  }
  if (!defined($which_racks) || !( ($which_racks eq 'screen') || ($which_racks eq 'all') ) ) {
     &error_message_and_exit($global_var_href, "invalid target rack selector", $sr_name . "-" . __LINE__);
  }

  # do not allow to move re-animation cage 99999 to another rack
  if ($cage_id == 99999) {
     $page .= h2("Move cage ")
              . hr()
              . p({-class=>"red"}, b("Error: Move of re-animation cage to another rack is not allowed "));
     return $page;
  }

  if ($which_racks eq 'screen') {
     if (!defined($screen_racks) || $screen_racks !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid target rack (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $target_rack = $screen_racks;
     }
  }
  if ($which_racks eq 'all') {
     if (!defined($all_racks) || $all_racks !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid target rack (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $target_rack = $all_racks;
     }
  }

  # date of move not given or invalid
  if (!param('datetime_of_move') || check_datetime_ddmmyyyy_hhmmss(param('datetime_of_move')) != 1) {
     $page .= h2("Move cage ")
              . hr()
              . p({-class=>"red"}, b("Error: date/time of move not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # ok, now check if datetime of move is acceptable

  # is move datetime in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('datetime_of_move')) eq 'future') {
     $page .= h2("Move cage ")
              . hr()
              . p({-class=>"red"}, b("Error: date/time of move is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # ok, obviously the move is not in the future, so we can proceed
  # in order to avoid error-prone situations resulting from dating back movements in the past, we only accept
  # 1) movements that occur in the time period between now (system time) and the very last movement.
  # 2) movements into 2a) either a new cage or 2b) a cage having less than 5 mice since last movement (no matter how complex situation is)
  # 3) for new cages, we need to find a new cage that was free at all times between back-dated datetime of move and now

  # 1) check if movement is in the time period between now (system time) and the very last movement of this cage
  if (Delta_ddmmyyyhhmmss(datetime_of_last_cage_move($global_var_href, $cage_id), param('datetime_of_move')) ne 'future') {
     $page .= h2("Move cage ")
              . hr()
              . p({-class=>"red"}, b("Error: date/time of move is before last movement of this cage, can't insert a movement before last movement (this is too complicated) "))
              . p(a({-href=>"javascript:back()"}, "go back and check your input or contact administrators"));
     return $page;
  }

  # find out rack in which cage is currently placed + details
  $current_rack = get_cage_location($global_var_href, $cage_id);
  (undef, undef, $current_location_room, $current_location_rack) = get_location_details_by_id($global_var_href, $current_rack);
  (undef, undef, $target_location_room,  $target_location_rack)  = get_location_details_by_id($global_var_href, $target_rack);

  $page .= h2("Move cage")
           . hr()
           . h3("Moving cage "  . a({-href=>"$url?choice=cage_view&cage_id=" . $cage_id}, $cage_id)
                . " from rack " . a({-href=>"$url?choice=location_details&location_id=" . $current_rack}, "$current_location_room-$current_location_rack")
                . " to rack "   . a({-href=>"$url?choice=location_details&location_id=" . $target_rack},  "$target_location_room-$target_location_rack")
                . " at " . $datetime_of_move
             )
           . p();

  # actually move cage (call move transaction)
  ($error_code, $error_message) = db_move_cage($global_var_href, $cage_id, $current_rack, $target_rack, $datetime_of_move);
  $page .= p("trying to move cage  ... " . $error_message);

  # offer option to print new cage card if move was successful
  if ($error_code == 0) {
     $page .= p(a({-href=>"$url?choice=print_card&cage_id=$cage_id", -target=>"_blank"}, "print new cage card" ))
              . p();
  }
  else {
     $page .= p(b("Cage stays where it is"))
              . p();
  }

  return $page;
}
# end of confirmed_cage_move()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MOV003 db_move_cage():                              move a cage (do the transaction)
sub db_move_cage {                                       my $sr_name = 'SR_MOV003';
  my $global_var_href      = $_[0];                           # get reference to global vars hash
  my $cage_id              = $_[1];                           # cage to move ...
  my $source_rack          = $_[2];                           # ... from which rack ...
  my $target_rack          = $_[3];                           # ... to which rack
  my $datetime_of_move     = $_[4];                           # when
  my $dbh                  = $global_var_href->{'dbh'};       # DBI database handle
  my $session              = $global_var_href->{'session'};   # session handle
  my $move_user_id         = $session->param('user_id');
  my $datetime_now         = get_current_datetime_for_sql();
  my $datetime_of_move_sql = format_display_datetime2sql_datetime($datetime_of_move);
  my ($rc, $no_mice, $capacity, $return_value, $mice_in_cage, $no_cages, $current_location);

  # check if cage id given and valid
  if (!defined($cage_id) || $cage_id !~ /^[0-9]+$/) {
     return (1, span({-class=>'red'}, "cage move cancelled (invalid cage id)"));
  }

  # check if source rack given and valid
  if (!defined($source_rack) || $source_rack !~ /^[0-9]+$/) {
     return (1, span({-class=>'red'}, "cage move cancelled (invalid source rack)"));
  }

  # check if target rack given and valid
  if (!defined($target_rack) || $target_rack !~ /^[0-9]+$/) {
     return (1, span({-class=>'red'}, "cage move cancelled (invalid target rack)"));
  }

  # check if date of move given and invalid
  if (!defined($datetime_of_move) || check_datetime_ddmmyyyy_hhmmss($datetime_of_move) != 1) {
     return (1, span({-class=>'red'}, "cage move cancelled (invalid date)"));
  }

  # is move datetime in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), $datetime_of_move) eq 'future') {
     return (1, span({-class=>'red'}, "cage move cancelled (date/time of move is in the future)"));
  }

  # check if cage move is in the time period between now (system time) and the very last movement of this cage
  if (Delta_ddmmyyyhhmmss(datetime_of_last_cage_move($global_var_href, $cage_id), $datetime_of_move) ne 'future') {
     return (1, span({-class=>'red'}, "cage move cancelled (date/time of move is before last movement of this cage, can't insert a movement before last movement)"));
  }

  # check if $source_rack = $target_rack
  if ($source_rack == $target_rack) {
     return (1, span({-class=>'red'}, "cage move cancelled (cannot move to same rack)"));
  }

  # check if cage empty
  ($mice_in_cage, undef, undef, undef, undef, undef, undef) = get_mice_in_cage($global_var_href, $cage_id);

  # check if cage is empty
  if (!defined($mice_in_cage) || ($mice_in_cage == 0)) {
     return (1, span({-class=>'red'}, "cage move cancelled (there are no mice in cage)"));
  }

  # ok, checked everything. transaction can start

  # try to get a lock
  &get_semaphore_lock($global_var_href, $move_user_id);

  ##########################################################################################
  # begin transaction
  $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start transaction)", $sr_name . "-" . __LINE__);

  # check if cage move is in the time period between now (system time) and the very last movement of this cage
  if (Delta_ddmmyyyhhmmss(datetime_of_last_cage_move($global_var_href, $cage_id), $datetime_of_move) ne 'future') {
     &release_semaphore_lock($global_var_href, $move_user_id);
     return (1, span({-class=>'red'}, "cage move cancelled (date/time of move is before last movement of this cage, can't insert a movement before last movement)"));
  }

  # 0. check if cage is still in source rack (within transaction to avoid "dirty reads")
  ($current_location) = $dbh->selectrow_array("select c2l_location_id
                                               from   cages2locations
                                               where  c2l_cage_id = '$cage_id'
                                                      and c2l_datetime_to IS NULL
                                              ");
  if ($current_location != $source_rack) {
     &release_semaphore_lock($global_var_href, $move_user_id);
     return (1, span({-class=>'red'}, "cage move cancelled (cage away, someone was faster)"));
  }

  # 1. update source location in cages2locations: add c2l_datetime_to for cage_id and source location
  $dbh->do("update  cages2locations
            set     c2l_datetime_to     = ?
            where   c2l_cage_id         = ?
                    and c2l_location_id = ?
                    and c2l_datetime_to IS NULL
           ", undef, $datetime_of_move_sql, $cage_id, $source_rack
          ) or &error_message_and_exit($global_var_href, "SQL error (could not update old rack)", $sr_name . "-" . __LINE__);

  # 2. insert target location into cages2locations: add cage_id, target_location, datetime_from
  $dbh->do("insert
            into    cages2locations (c2l_cage_id, c2l_location_id, c2l_datetime_from, c2l_datetime_to, c2l_move_user_id, c2l_move_datetime)
            values  (?, ?, ?, NULL, ?, ?)
           ", undef, $cage_id, $target_rack, $datetime_of_move_sql, $move_user_id, $datetime_now
           ) or &error_message_and_exit($global_var_href, "SQL error (could not update new rack)", $sr_name . "-" . __LINE__);


  # this was the cage movement, now check for the consequences

  # 5. does the number of cages in the new location exceed the location capacity?
  ($no_cages) = $dbh->selectrow_array("select count(*)
                                       from   cages2locations
                                       where  c2l_location_id = $target_rack
                                              and c2l_datetime_to IS NULL
                                      ");

  ($capacity) = $dbh->selectrow_array("select location_capacity
                                       from   locations
                                       where  location_id = $target_rack
                                      ");

  # yes: -> rollback and exit
  if ($no_cages > $capacity) {
     $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back cage move transaction)", $sr_name . "-" . __LINE__);
     &release_semaphore_lock($global_var_href, $move_user_id);
     return(-1, span({-class=>'red'}, "cage move cancelled (not enough space in target rack)"));
  }

  $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit cage move transaction)", $sr_name . "-" . __LINE__);
  ##########################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $move_user_id);

  &write_textlog($global_var_href, "$datetime_now\t$move_user_id\t" . $session->param('username') . "\tmove_cage\t$cage_id\t$datetime_of_move_sql\t$source_rack\t$target_rack");

  return (0, b("successful."));
}
# end of db_move_cage()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MOV004 move_mouse():                                move a mouse
sub move_mouse {                                         my $sr_name = 'SR_MOV004';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $mouse_id          = param('mouse_id');
  my ($page);
  my ($location_id, $location_room, $location_rack);
  my ($cage_id);
  my %rack_labels = ("screen" => "", "all"      => "");
  my %cage_labels = ("new"    => "", "existing" => "");

  # check input
  if (!defined($mouse_id) || $mouse_id !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid mouse id (must be an 8 digit number).", $sr_name . "-" . __LINE__);
  }

  # find out cage in which mouse is currently placed
  $cage_id = get_cage($global_var_href, $mouse_id);

  # find out rack in which cage is currently placed + details
  $location_id = get_cage_location($global_var_href, $cage_id);
  (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, $location_id);

  # So far, we know current cage and rack of chosen mouse. Now display move dialog

  $page .= h2("Move mouse ")
           . hr()
           . h3("Move mouse " . reformat_number($mouse_id, 8) . " from cage " . a({-href=>"$url?choice=cage_view&cage_id=" . $cage_id}, $cage_id)  . " in rack " . a({-href=>"$url?choice=location_details&location_id=" . $location_id}, "$location_room-$location_rack"))
           . start_form(-action=>url(), -name=>"myform")
           . p(u("1. Step: please choose target cage "))
           . table({-border=>0, -summary=>"table"},
                   Tr(
                     td({-colspan=>5}, b("move mouse ..."))
                   ) .
                   Tr(
                     td(radio_group(-name=>'which_cage', -values=>['new'],      -default=>'new',    -labels=>\%cage_labels)),
                     td(" to a new cage "),
                     td("&nbsp;&nbsp;&nbsp;" . b("or") . "&nbsp;&nbsp;&nbsp;"),
                     td(radio_group(-name=>'which_cage', -values=>['existing'], -default=>'screen', -labels=>\%cage_labels)),
                     td(" to an existing cage: "
                        . textfield(-title=>"cage id", -name => "existing_cage", -size=>"5", -onclick=>"document.myform.which_cage[1].checked=true")
                        . " (please enter existing cage id)")
                   ) .
                   Tr(
                     td(),
                     td(small("(a new cage will be placed " . br() . "in the rack chosen below)")),
                     td(),
                     td(),
                     td(small("(this cage will stay where it is, " . br() . "below rack selection will be ignored)"))
                   )
             )

           . p(u("2. Step: please choose target rack"))
           . table({-border=>0, -summary=>"table"},
                   Tr(
                     td(),
                     th("racks from your screen"),
                     th({-colspan=>2}, " or "),
                     th("all racks")
                   ) .
                   Tr(
                     td(radio_group(-name=>'which_racks', -values=>['screen'], -default=>'screen', -labels=>\%rack_labels)),
                     td(span({-onclick=>"document.myform.which_racks[0].checked=true"}, get_locations_popup_menu($global_var_href, undef, 'cage_count', 'screen_racks_only'))),
                     td("&nbsp;&nbsp;&nbsp;&nbsp;"),
                     td(radio_group(-name=>'which_racks', -values=>['all'], -default=>'screen', -labels=>\%rack_labels)),
                     td(span({-onclick=>"document.myform.which_racks[1].checked=true"}, get_locations_popup_menu($global_var_href, undef, 'cage_count')))
                   )
             )

           . p(u("[optional step: please specify move date]"))
           . table({-border=>0, -summary=>"table"},
                   Tr(
                     td(textfield(-name=>'datetime_of_move',
                                  -id=>"datetime_of_move",
                                  -size=>"20",
                                  -maxlength=>"21",
                                  -title=>"date and time of move",
                                  -value=>get_current_datetime_for_display()
                                  )
                        . "&nbsp;&nbsp;"
                        . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=datetime_of_move', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                        )
                   )
             )
           . p()
           . hidden(-name=>'mouse_id')
           . hidden(-name=>'confirmed', -value=>'no')
           . p()
           . submit(-name => "choice", -value=>"move mouse!") . "&nbsp;&nbsp;&nbsp;or&nbsp;&nbsp;&nbsp;" . a({-href=>"javascript:back()"}, "cancel (go to previous page)")
           . end_form();

  return $page;
}
# end of move_mouse
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MOV005 confirmed_mouse_move                         confirmed mouse move (wrapper for mouse move transaction)
sub confirmed_mouse_move {                               my $sr_name = 'SR_MOV005';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $mouse_id          = param('mouse_id');             # mouse to be moved
  my $which_racks       = param('which_racks');          # switch to decide if target rack selection from 'all_racks' or from 'screen_racks'
  my $all_racks         = param('all_racks');
  my $screen_racks      = param('screen_racks');
  my $which_cage        = param('which_cage');           # switch to decide if target cage selection is 'new' or from 'existing' (then read out 'existing_cage')
  my $existing_cage     = param('existing_cage');
  my $datetime_of_move  = param('datetime_of_move');
  my $sex_color         = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my $warning           = '';
  my $is_mating         = 0;
  my @cagemates         = ();
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($error_code, $error_message, $target_rack, $target_cage, $real_target_cage);
  my ($current_cage, $current_rack, $current_location_room, $current_location_rack);
  my ($target_location_room,  $target_location_rack);
  my ($mice_in_target_cage, $males_in_cage, $females_in_cage, $sex_mixed, $cage_capacity);
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;

  # check mouse id
  if (!defined($mouse_id) || $mouse_id !~ /^[0-9]{8}$/) {
     &error_message_and_exit($global_var_href, "invalid mouse id (must be an 8 digit number).", $sr_name . "-" . __LINE__);
  }

  # check if target rack info given
  if (!defined($which_racks) || !( ($which_racks eq 'screen') || ($which_racks eq 'all') ) ) {
     &error_message_and_exit($global_var_href, "invalid target rack selector", $sr_name . "-" . __LINE__);
  }
  if ($which_racks eq 'screen') {
     if (!defined($screen_racks) || $screen_racks !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid target rack (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $target_rack = $screen_racks;
     }
  }
  if ($which_racks eq 'all') {
     if (!defined($all_racks) || $all_racks !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid target rack (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $target_rack = $all_racks;
     }
  }

  # check if target cage info given
  if (!defined($which_cage) || !( ($which_cage eq 'new') || ($which_cage eq 'existing') ) ) {
     &error_message_and_exit($global_var_href, "invalid target cage selector", $sr_name . "-" . __LINE__);
  }
  if ($which_cage eq 'new') {
     $target_cage = 'new';
  }
  if ($which_cage eq 'existing') {
     if (!defined($existing_cage) || $existing_cage !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid target cage (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $target_cage = $existing_cage;

        # in case user specifies an existing cage, leave that cage in its current rack and overwrite above target rack selection
        # (= ignore rack selection, don't implicitely move existing cage)
        $target_rack = get_cage_location($global_var_href, $target_cage);
     }
  }

  # date of move not given or invalid
  if (!param('datetime_of_move') || check_datetime_ddmmyyyy_hhmmss(param('datetime_of_move')) != 1) {
     $page .= h2("Move mouse ")
              . hr()
              . p({-class=>"red"}, b("Error: date/time of move not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # ok, now check if datetime of move is acceptable

  # 0) is it in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('datetime_of_move')) eq 'future') {
     $page .= h2("Move mouse ")
              . hr()
              . p({-class=>"red"}, b("Error: date/time of move is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # ok, obviously the move is not in the future, so we can proceed
  # in order to avoid error-prone situations resulting from dating back movements in the past, we only accept
  # 1) movements that occur in the time period between now (system time) and the very last movement.
  # 2) movements into 2a) either a new cage or 2b) a cage having less than 5 mice since last movement (no matter how complex situation is)
  # 3) for new cages, we need to find a new cage that was free at all times between back-dated datetime of move and now

  # 1) check if movement is in the time period between now (system time) and the very last movement of this mouse
  if (Delta_ddmmyyyhhmmss(datetime_of_last_move($global_var_href, $mouse_id), param('datetime_of_move')) ne 'future') {
     $page .= h2("Move mouse ")
              . hr()
              . p({-class=>"red"}, b("Error: date/time of move is before last movement, can't insert a movement before last movement (this is too complicated) "))
              . p(a({-href=>"javascript:back()"}, "go back and check your input or contact administrators"));
     return $page;
  }

  # 2b) for existing cage: check if chosen cage has ever had more than 4 mice at any point in time between last movement and now
  if ($target_cage =~ /^[0-9]+$/) {
     if (was_there_a_place_for_this_mouse_between_datetime_of_move_and_now($global_var_href,
                                                                           $target_cage,
                                                                           format_display_datetime2sql_datetime(param('datetime_of_move')),
                                                                           format_display_datetime2sql_datetime(get_current_datetime_for_display())) eq 'no') {
        $page .= h2("Move mouse ")
                 . hr()
                 . p({-class=>"red"}, b("Error: could not place mouse into given cage (during given time and now there was no place left in target cage at some time point)"))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }
  }
  # 2a) for new cage: need to check if new cage id was never in use during desired datetime of move and now
  #     can't do this here => need to look for a new cage id within transaction
  elsif ($target_cage eq 'new') {
     # do nothing (at this point)
  }
  # given cage is neither a number nor 'new' cage, so what is it? a joke?
  else {
        $page .= h2("Move mouse ")
                 . hr()
                 . p({-class=>"red"}, b("Error: invalid target cage)"))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
  }

  # 3) for new cages, we need to find a new cage that was free at all times between back-dated datetime of move and now
  # that means: looping over candidate cages and check if they were free at all times between back-dated datetime of move and now
  # of course, this has to be done within the transaction

  # formal check of input passed, now check if move makes sense

  $page .= h2("Move mouse ")
           . hr();

  # for a given cage, we need to check some details
  if (($which_cage eq 'existing') && defined(param('confirmed')) && (param('confirmed') eq 'no')) {
     # move to existing cage requires information and confirmation step, so we need to preserve parameters using hidden fields
     $page .= start_form(-action=>url(), -name=>"myform")
              . hidden('mouse_id')         . hidden('which_racks')   . hidden('all_racks') . hidden('screen_racks')
              . hidden('which_cage')       . hidden('existing_cage')
              . hidden('datetime_of_move') . hidden(-name=>'confirmed', -value=>'yes', -override=>'yes');

     # find out number of mice and sexes in an existing cage at the given datetime of move
     ($mice_in_target_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, $target_cage, format_display_datetime2sql_datetime(param('datetime_of_move')));

     # is given cage in use at all? (-> does it contain > 1 mice?)
     if ($mice_in_target_cage == 0) {
        $page .= h3({-class=>"red"}, "Move not possible")
                 . p({-class=>"red"}, "Given target cage (" . $target_cage .  ") not in use") . hr()
                 . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection");
        return $page;
     }

     # enough space in target cage? If not, exit
     if (($cage_capacity - $mice_in_target_cage) < 1) {
        $page .= h3({-class=>"red"}, "Move not possible")
                 . p({-class=>"red"}, "There is/was not enough space left in the target cage (already $mice_in_target_cage mice)") . hr()
                 . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection");
        return $page;
     }

     $page .= h3("Please check and confirm if this is the cage where you want your mouse move to");

     # check if male is moved to a male cage. If so, generate warning, but dont exit
     if ( (get_sex($global_var_href, $mouse_id) eq 'm' ) && ($males_in_cage > 0) ) {
        $page .= p({-class=>"red"}, "Warning: You are about to move a male mouse to a cage with $males_in_cage male(s).");
     }

     # check if male is moved to a female cage. if so: exit and ask to do use the mating function
     if ( (get_sex($global_var_href, $mouse_id) eq 'm' ) && ($females_in_cage > 0)) {
        $page .= p({-class=>"red"}, "Warning! You are about to move a male mouse to a cage with $females_in_cage female(s)!");
     }

     # check if female is moved to a male cage. if so: exit and ask to do use the mating function
     if ( (get_sex($global_var_href, $mouse_id) eq 'f' ) && ($males_in_cage > 0)) {
        $page .= p({-class=>"red"}, "Warning! You are about to move a female to a male cage!");
     }

     # show content of target cage here to enable user to decide whether this is what he/she wanted
     $sql = qq(select c2l_cage_id, cage_capacity,
                      mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_is_gvo, mouse_comment, location_id, location_room, location_rack, cage_id,
                      mouse_birth_datetime, mouse_deathorexport_datetime, project_shortname
               from   cages2locations
                      join locations          on  c2l_location_id = location_id
                      join cages              on          cage_id = c2l_cage_id
                      join mice2cages         on      m2c_cage_id = cage_id
                      join mice               on     m2c_mouse_id = mouse_id
                      join mouse_strains      on     mouse_strain = strain_id
                      join mouse_lines        on       mouse_line = line_id
                      left join projects      on location_project = project_id
               where  m2c_cage_id = ?
                      and c2l_datetime_to IS NULL
                      and m2c_datetime_to IS NULL
                      and mouse_deathorexport_datetime IS NULL
               order  by mouse_id asc
              );

     @sql_parameters = ($target_cage);

     ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

     # if there are no mice in target cage, notify user (this should not happen normally, since there is a check for unused cage before)
     if ($rows == 0) {
        $page .= p({-class=>"red"}, "Error: target cage " . $target_cage . " is currently not in use (cannot move to a specified cage that is currently not in use)")
                 . hr()
                 . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection");
        return $page;
     }

     # this is the expected case
     else {
        $page .= hr()
                 . h3("Target cage " . $target_cage . " (placed in rack "
                 . a({-href=>"$url?choice=location_details&location_id=" . $result->[0]->{'location_id'}}, "$result->[0]->{'location_room'}/$result->[0]->{'location_rack'}")
                 . ", $result->[0]->{'project_shortname'}) contains $rows " . (($rows == 1)?'mouse':'mice' ))

                 . start_form(-action=>url(), -name=>"myform")
                 . start_table( {-border=>1, -summary=>"table"})

                 . Tr(
                     th(span({-title=>"this is just the table row number"}, "#")),
                     th("mouse ID"),
                     th("ear"),
                     th("sex"),
                     th("born"),
                     th("age"),
                     th("death"),
                     th("genotype"),
                     th("strain"),
                     th("line"),
                     th("room/rack-cage")
                   );

        # loop over all mice in target cage
        for ($i=0; $i<$rows; $i++) {
            $row = $result->[$i];

            # get first genotype
            ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

            # add table row for current line
            $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                       td($i+1),
                       td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                       td($row->{'mouse_earmark'}),
                       td($row->{'mouse_sex'}),
                       td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                       td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                       td(format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
                       td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
                       td($row->{'strain_name'}),
                       td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                       td((!defined($row->{'mouse_deathorexport_datetime'}))?$row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'}:'-')
                     );
        }

        $page .= end_table()
                 . p();
     }

     $page .= hr()
              . p(submit(-name => "choice", -value=>"move mouse!") . "&nbsp;&nbsp;&nbsp;or&nbsp;&nbsp;&nbsp;" . a({-href=>"javascript:back()"}, "cancel (go to previous page)"))
              . end_form();
  }

  # either target cage is a new cage or we have a confirmation from a previous move to existing cage
  else {

     # get current cage and rack:
     $current_cage = get_cage($global_var_href, $mouse_id);
     $current_rack = get_cage_location($global_var_href, $current_cage);

     # get details about current and target rack
     (undef, undef, $current_location_room, $current_location_rack) = get_location_details_by_id($global_var_href, $current_rack);
     (undef, undef, $target_location_room,  $target_location_rack)  = get_location_details_by_id($global_var_href, $target_rack);

     $page .= h3("Moving mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse_id}, reformat_number($mouse_id, 8)))
              . table(
                  Tr({-border=>1, -summary=>"table"},
                    th(" from origin cage: "),
                    td(a({-href=>"$url?choice=cage_view&cage_id=" . $current_cage},   " cage " . $current_cage)),
                    th(" in origin rack: "),
                    td(a({-href=>"$url?choice=location_details&location_id=" . $current_rack}, " rack $current_location_room-$current_location_rack"))
                  ) .
                  Tr(
                    th(" to target cage: "),
                    td((($target_cage eq 'new')
                        ?" new cage "
                        :a({-href=>"$url?choice=cage_view&cage_id=" . $target_cage}, " cage " . $target_cage)
                       )
                    ),
                    th(" in target rack: "),
                    td(a({-href=>"$url?choice=location_details&location_id=" . $target_rack}, " rack $target_location_room-$target_location_rack"))
                  )
                )
              . p();

     # actually perform move by calling transaction and receive move status
     # transaction may return values for real_target_cage and target rack that are different from chosen ones because in case of a problem,
     # mouse is moved to new cage on its own. real_target_cage and target rack are used to inform user about new location of mouse
     # returned value $is_mating is used to offer "new mating" link if move produces sex mixed cage
     ($error_code, $error_message, $real_target_cage, $target_rack, $is_mating) = db_move_mouse($global_var_href, $mouse_id, $current_cage, $current_rack, $target_cage, $target_rack, $datetime_of_move);

     # if move leads to mating situation, offer "set up mating" link
     if (defined($is_mating) && $is_mating > 0) {
        # collect all mice from target cage
        $sql = qq(select m2c_mouse_id
                  from   mice2cages
                  where  m2c_cage_id = ?
                         and m2c_datetime_to IS NULL
              );

        @sql_parameters = ($target_cage);

        ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

        for ($i=0; $i<$rows; $i++) {
            $row = $result->[$i];
            push(@cagemates, $row->{'m2c_mouse_id'});
        }

        # "set up mating" link for all mice in target cage
        $page .= p("trying to move mouse  ... " . $error_message)
                 . p(a({-href=>"$url?job=mate&mouse_select=" . join('&mouse_select=', @cagemates) . "&move_mode=no_move&move_datetime=" . $datetime_of_move, -target=>"_blank"}, "[CLICK TO SET UP MATING WITH MICE IN CAGE " . $target_cage . "]"));
     }
     else {
        $page .= p("trying to move mouse  ... " . $error_message);
     }

     # offer option to print new cage card if move was successful
     if ($error_code == 0) {
        if ($target_cage eq 'new' ) {
           $page .= p("New cage: " . a({-href=>"$url?choice=cage_view&cage_id=" . $real_target_cage},   " cage " . $real_target_cage));
        }

        $page .= hr()
                 . p(a({-href=>"$url?choice=print_card&cage_id=$real_target_cage", -target=>"_blank"}, "print new cage card" ))
                 . p();
     }
     else {
        $page .= p(b("Mouse stays where it is"))
                 . p();
     }
  }

  return $page;
}
# end of confirmed_mouse_move()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MOV006 db_move_mouse():                             move a mouse (do the transaction)
sub db_move_mouse {                                      my $sr_name = 'SR_MOV006';
  my $global_var_href      = $_[0];                           # get reference to global vars hash
  my $mouse_id             = $_[1];                           # mouse to move ...
  my $origin_cage          = $_[2];                           # ... from cage ...
  my $origin_rack          = $_[3];                           # ... in rack
  my $target_cage          = $_[4];                           # to cage ...
  my $target_rack          = $_[5];                           # ... in rack
  my $datetime_of_move     = $_[6];                           # when
  my $dbh                  = $global_var_href->{'dbh'};       # DBI database handle
  my $session              = $global_var_href->{'session'};   # session handle
  my $move_user_id         = $session->param('user_id');
  my $datetime_now         = get_current_datetime_for_sql();
  my $datetime_of_move_sql = format_display_datetime2sql_datetime($datetime_of_move);
  my $warning              = '';
  my $is_mating            = 0;
  my ($rc, $no_mice, $return_value);
  my ($mice_in_target_cage, $males_in_cage, $females_in_cage, $sex_mixed, $cage_capacity, $number_of_cages, $rack_capacity);
  my ($current_cage, $target_cage_id, $target_cage_capacity, $mice_in_origin_cage, $next_free_cage, $cage_of_this_mouse);

  # check if mouse id given and valid
  if (!defined($mouse_id) || $mouse_id !~ /^[0-9]+$/) {
     return (1, span({-class=>'red'}, "mouse move cancelled (invalid mouse id)"), undef, undef);
  }

  # check if origin cage given and valid
  if (!defined($origin_cage) || $origin_cage !~ /^[0-9]+$/) {
     return (1, span({-class=>'red'}, "mouse move cancelled (invalid source cage)"), undef, undef);
  }

  # check if origin rack given and valid
  if (!defined($origin_rack) || $origin_rack !~ /^[0-9]+$/) {
     return (1, span({-class=>'red'}, "mouse move cancelled (invalid source rack)"), undef, undef);
  }

  # check if target cage given and valid
  if (!defined($target_cage) || !( ($target_cage =~ /^[0-9]+$/) || $target_cage eq 'new') ) {
     return (1, span({-class=>'red'}, "mouse move cancelled (invalid target cage)"), undef, undef);
  }

  # check if target rack given and valid
  if (!defined($target_rack) || $target_rack !~ /^[0-9]+$/) {
     return (1, span({-class=>'red'}, "mouse move cancelled (invalid target rack)"), undef, undef);
  }

  # check if origin cage = target cage
  if ( ($target_cage ne 'new') && ($origin_cage == $target_cage)) {
     return (1, span({-class=>'red'}, "mouse move cancelled (cannot move to same cage)"), undef, undef);
  }

  # check if cage empty
  ($mice_in_origin_cage, undef, undef, undef, undef, undef, undef) = get_mice_in_cage($global_var_href, $origin_cage);

  # check if cage is empty
  if (!defined($mice_in_origin_cage) || ($mice_in_origin_cage == 0)) {
     return (1, span({-class=>'red'}, "mouse move cancelled (there are no mice in origin cage: someone moved out mouse in between)"), undef, undef);
  }

  # check if date of move given and invalid
  if (!defined($datetime_of_move) || check_datetime_ddmmyyyy_hhmmss($datetime_of_move) != 1) {
     return (1, span({-class=>'red'}, "cage move cancelled (invalid date)"));
  }

  # with a new cage, there will be no problems at this point, but for an existing cage, we need to check some details
  unless ($target_cage eq 'new') {
     # ask for number of mice and sexes in an existing cage
     ($mice_in_target_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, $target_cage, format_display_datetime2sql_datetime($datetime_of_move));

     # enough space in target cage?
     if (($cage_capacity - $mice_in_target_cage) < 1) {
        return (1, span({-class=>'red'}, "mouse move cancelled. There is not enough space left in the target cage (already $mice_in_target_cage mice)"), undef, undef);
     }

     # check if male is moved to a male cage. If so, generate warning, but dont exit
     if ( (get_sex($global_var_href, $mouse_id) eq 'm' ) && ($males_in_cage > 0) ) {
        $warning .= "&nbsp;&nbsp;&nbsp;" . span({-class=>"red"}, "[moved male mouse to a cage with $males_in_cage male(s)]");
     }

     # check if male is moved to a female cage. if so: exit and ask to do use the mating function
     if ( (get_sex($global_var_href, $mouse_id) eq 'm' ) && ($females_in_cage > 0)) {
        $warning .= "&nbsp;&nbsp;&nbsp;" . span({-class=>"red"}, "[moved male to female(s), but didn't mate automatically]");
        $is_mating++;
     }

     # check if female is moved to a male cage. if so: exit and ask to do use the mating function
     if ( (get_sex($global_var_href, $mouse_id) eq 'f' ) && ($males_in_cage > 0)) {
        $warning .= "&nbsp;&nbsp;&nbsp;" . span({-class=>"red"}, "[moved female to male(s), but didn't mate automatically]");
        $is_mating++;
     }
  }
  # ok, checked everything. transaction can start

  # try to get a lock
  &get_semaphore_lock($global_var_href, $move_user_id);

  ########################################################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start transaction)", $sr_name . "-" . __LINE__);

  # 0. if new cage is required, get one
  if ($target_cage eq 'new') {
     $next_free_cage = give_me_a_cage($global_var_href, $datetime_of_move_sql);

     # if no free cages left (at given datetime of move): rollback and exit
     if (!defined($next_free_cage)) {
        $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back cage move transaction)", $sr_name . "-" . __LINE__);

        &release_semaphore_lock($global_var_href, $move_user_id);
        return (1, span({-class=>'red'}, "mouse move cancelled: no free cage found at given date/time of move (more recent or current move date/time will work more likely)"), undef, undef);
     }

     $target_cage_id = $next_free_cage;
  }
  # else (if target cage is specified): use given cage
  else {
     $target_cage_id = $target_cage;
  }

  # check if candidate cage has ever had more than 4 mice at any point in time between last movement and now
  if (was_there_a_place_for_this_mouse_between_datetime_of_move_and_now($global_var_href,
                                                                        $target_cage_id,
                                                                        $datetime_of_move_sql,
                                                                        get_current_datetime_for_sql()) eq 'no') {
     &release_semaphore_lock($global_var_href, $move_user_id);
     return (1, span({-class=>'red'}, "mouse move cancelled: could not place mouse into given cage (during given time and now there was no place left in target cage at some time point)"), undef, undef);
  }

  # 0,5. determine next movement number (counter for number of cages of this particular mouse)
  ($cage_of_this_mouse) = $dbh->selectrow_array("select (max(m2c_cage_of_this_mouse)+1) as cage_of_this_mouse
                                                 from   mice2cages
                                                 where  m2c_mouse_id = '$mouse_id'
                                                ");

  # 1. check if mouse is still in origin_cage (within transaction to avoid "dirty reads")
  ($current_cage) = $dbh->selectrow_array("select m2c_cage_id
                                           from   mice2cages
                                           where  m2c_mouse_id = '$mouse_id'
                                                  and m2c_datetime_to IS NULL
                                          ");
  if ($current_cage != $origin_cage) {
     $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back cage move transaction)", $sr_name . "-" . __LINE__);

     &release_semaphore_lock($global_var_href, $move_user_id);
     return (1, span({-class=>'red'}, "mouse move cancelled: mouse away (someone was faster)"), undef, undef);
  }

  # 2. update cage in mice2cages: add m2c_datetime_to for cage_id
  $dbh->do("update  mice2cages
            set     m2c_datetime_to = ?
            where   m2c_mouse_id    = ?
                    and m2c_cage_id = ?
                    and m2c_datetime_to IS NULL
           ", undef, "$datetime_of_move_sql", $mouse_id, $current_cage
          ) or &error_message_and_exit($global_var_href, "SQL error (could not update old cage)", $sr_name . "-" . __LINE__);

  # 2. insert target cage into mice2cages: add mouse_id, target_cage, datetime_from
  $dbh->do("insert
            into    mice2cages (m2c_mouse_id, m2c_cage_id, m2c_cage_of_this_mouse, m2c_datetime_from, m2c_datetime_to, m2c_move_user_id, m2c_move_datetime)
            values  (?, ?, ?, ?, NULL, ?, ?)
           ", undef, $mouse_id, $target_cage_id, $cage_of_this_mouse, "$datetime_of_move_sql", $move_user_id, $datetime_now
          ) or &error_message_and_exit($global_var_href, "SQL error (could not insert mouse into new cage)", $sr_name . "-" . __LINE__);

  # 3. if new cage:
  if ($target_cage eq 'new') {
     # 3a. mark new cage as occupied
     $dbh->do("update  cages
               set     cage_occupied = ?, cage_cardcolor = ?
               where   cage_id = ?
              ", undef, "y", 8, $target_cage_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not set new cage to occupied)", $sr_name . "-" . __LINE__);

     # 3b. insert the new cage into target rack
     $dbh->do("insert
               into    cages2locations (c2l_cage_id, c2l_location_id, c2l_datetime_from, c2l_datetime_to, c2l_move_user_id, c2l_move_datetime)
               values  (?, ?, ?, NULL, ?, ?)
              ", undef, $target_cage_id, $target_rack, "$datetime_of_move_sql", $move_user_id, $datetime_now
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new cage into target rack)", $sr_name . "-" . __LINE__);

     # 3c. does the number of cages in the new location exceed the location capacity when inserting new cage?
     ($number_of_cages) = $dbh->selectrow_array("select count(*)
                                                 from   cages2locations
                                                 where  c2l_location_id = $target_rack
                                                        and c2l_datetime_to IS NULL
                                                ");

     ($rack_capacity) = $dbh->selectrow_array("select location_capacity
                                               from   locations
                                               where  location_id = $target_rack
                                              ");

     # yes: -> rollback and exit
     if ($number_of_cages > $rack_capacity) {
        $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back cage move transaction)", $sr_name . "-" . __LINE__);

        &release_semaphore_lock($global_var_href, $move_user_id);
        return(-1, "mouse move cancelled (not enough space for new cage in target rack)", undef, undef);
     }
  }

  # this was the mouse movement only, now check for the consequences

  # 4. does the number of mice in the new cage exceed the cage capacity?
  # TO DO: not only check for current overloading of cage, but also check for cage overload at any timepoint between now and back-dated time of move
  ($mice_in_target_cage) = $dbh->selectrow_array("select count(m2c_mouse_id) as mouse_number
                                                  from   mice2cages
                                                  where  m2c_cage_id = $target_cage_id
                                                         and m2c_datetime_to IS NULL
                                                 ");

  ($target_cage_capacity) = $dbh->selectrow_array("select cage_capacity
                                                   from   cages
                                                   where  cage_id = $target_cage_id
                                                  ");

  # yes: -> rollback and exit
  if ($mice_in_target_cage > $target_cage_capacity) {
     $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back mouse move transaction)", $sr_name . "-" . __LINE__);

     &release_semaphore_lock($global_var_href, $move_user_id);
     return(-1, "mouse move cancelled (not enough space in target cage)", undef, undef);
  }

  # 5. now check if the source cage is empty now?
  ($mice_in_origin_cage) = $dbh->selectrow_array("select count(m2c_mouse_id) as mouse_number
                                                  from   mice2cages
                                                  where  m2c_cage_id = $current_cage
                                                         and m2c_datetime_to IS NULL
                                                 ");

  # yes: make empty source cage free
  if ($mice_in_origin_cage == 0) {
     #  update cages: set cage_occupied='n', cage_project=null, cage_contact=null, cage_purpose=null for source_cage
     $dbh->do("update  cages
               set     cage_occupied = 'n', cage_cardcolor = 8, cage_project = 1, cage_user = 1, cage_purpose = '-'
               where   cage_id = '$current_cage'
              "
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update empty origin cage)", $sr_name . "-" . __LINE__);

     # update cages2locations: add c2l_datetime_to for source_cage and source_location bei letztem Eintrag dieser Kombination (2l_datetime_to IS NULL)
     $dbh->do("update  cages2locations
               set     c2l_datetime_to      = ?
               where   c2l_cage_id          = ?
                       and c2l_location_id  = ?
                       and c2l_datetime_to  IS NULL
              ", undef, "$datetime_of_move_sql", $current_cage, $origin_rack
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update empty origin cage rack)", $sr_name . "-" . __LINE__);
  }

  $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit cage move transaction)", $sr_name . "-" . __LINE__);
  ########################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $move_user_id);

  &write_textlog($global_var_href, "$datetime_now\t$move_user_id\t" . $session->param('username') . "\tmove_mouse\t$mouse_id\t$datetime_of_move_sql\t$origin_rack\t$current_cage\t$target_rack\t$target_cage_id");

  return (0, b("successful.") . $warning, $target_cage_id, $target_rack, $is_mating);
}
# end of db_move_mouse()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MOV007 move_cages():                                move selected cages
sub move_cages {                                         my $sr_name = 'SR_MOV007';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my @selected_cages    = param('cage_select');
  my $location_id       = param('location_id');
  my @cages_to_be_moved;
  my $cage_id;
  my %radio_labels      = ("screen" => "", "all" => "");
  my ($page, $location_room, $location_rack);

  # check list of cages to be moved
  foreach $cage_id (@selected_cages) {
     if ($cage_id =~ /^[0-9]{1,8}$/) {
        push(@cages_to_be_moved, $cage_id);
     }
  }

  if (scalar @cages_to_be_moved == 0) {
     $page .= h2("Move multiple cages ")
              . hr()
              . h3("No cages to move!")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # get rack in which cage is currently placed + details
  (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, $location_id);

  $page .= h2("Move multiple cages ")
          . hr()
          . p("Selected cages: " . join(", ", @cages_to_be_moved))
          . hr()
          . h3("Move cages from rack " . a({-href=>"$url?choice=location_details&location_id=" . $location_id}, "$location_room-$location_rack"))
          . start_form(-action=>url(), -name=>"myform")
          . p("1) Move date "
              . textfield(-name=>'datetime_of_move',
                          -id=>"datetime_of_move",
                          -size=>"20",
                          -maxlength=>"21",
                          -title=>"date and time of move",
                          -value=>get_current_datetime_for_display()
                )
              . "&nbsp;&nbsp;"
              . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=datetime_of_move', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
            )
          . p("2) Please choose target rack ")
          . table({-border=>0, -summary=>"table"},
                  Tr(
                    td(),
                    th("racks from your screen"),
                    th({-colspan=>2}, "or"),
                    th("all racks")
                  ) .
                  Tr(
                    td(radio_group(-name=>'which_racks', -values=>['screen'], -default=>'screen', -labels=>\%radio_labels)),
                    td(span({-onclick=>"document.myform.which_racks[0].checked=true"}, get_locations_popup_menu($global_var_href, undef, 'cage_count', 'screen_racks_only'))),
                    td("&nbsp;&nbsp;&nbsp;&nbsp;"),
                    td(radio_group(-name=>'which_racks', -values=>['all'], -default=>'screen', -labels=>\%radio_labels)),
                    td(span({-onclick=>"document.myform.which_racks[1].checked=true"}, get_locations_popup_menu($global_var_href, undef, 'cage_count')))
                  )
            )
          . hidden('cage_select')
          . hidden('location_id')
          . p()
          . submit(-name => "choice", -value=>"move cages!") . "&nbsp;&nbsp;&nbsp;or&nbsp;&nbsp;&nbsp;" . a({-href=>"javascript:back()"}, "cancel (go to previous page)")
          . end_form();

  return $page;
}
# end of move_cages
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MOV008 confirmed_cages_move                         confirmed cages move (wrapper for cage move transaction)
sub confirmed_cages_move {                               my $sr_name = 'SR_MOV008';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my @selected_cages    = param('cage_select');
  my $cage_id;
  my $which_racks      = param('which_racks');           # switch to decide if target rack selection from 'all_racks' or from 'screen_racks'
  my $all_racks        = param('all_racks');
  my $screen_racks     = param('screen_racks');
  my $datetime_of_move = param('datetime_of_move');
  my $url              = url();
  my ($page, $sql);
  my ($error_code, $error_message, $target_rack);
  my ($current_rack, $current_location_room, $current_location_rack);
  my ($target_location_room,  $target_location_rack);

  # check input
  if (!defined($which_racks) || !( ($which_racks eq 'screen') || ($which_racks eq 'all') ) ) {
     &error_message_and_exit($global_var_href, "invalid target rack selector", $sr_name . "-" . __LINE__);
  }

  # decide about target rack depending on user selection
  if ($which_racks eq 'screen') {
     if (!defined($screen_racks) || $screen_racks !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid target rack (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $target_rack = $screen_racks;
     }
  }
  if ($which_racks eq 'all') {
     if (!defined($all_racks) || $all_racks !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid target rack (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $target_rack = $all_racks;
     }
  }

  # date of move not given or invalid
  if (!param('datetime_of_move') || check_datetime_ddmmyyyy_hhmmss(param('datetime_of_move')) != 1) {
     $page .= h2("Move cage ")
              . hr()
              . p({-class=>"red"}, b("Error: date/time of move not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is move datetime in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('datetime_of_move')) eq 'future') {
     $page .= h2("Move cage ")
              . hr()
              . p({-class=>"red"}, b("Error: date/time of move is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  ################

  # checks done, now move cage by cage

  $page .= h2("Move multiple cages")
           . hr();

  # check list of cages to be moved
  foreach $cage_id (@selected_cages) {
     if ($cage_id =~ /^[0-9]{1,8}$/) {

        # do not allow to move re-animation cage 99999 to another rack
        if ($cage_id == 99999) {
           $page .= p("Moving cage $cage_id ... "
                      . span({-class=>"red"},
                             b("skipped (move of re-animation cage to another rack is not allowed)")
                        )
                    );
        }

        # (normal cages)
        # in order to avoid error-prone situations resulting from dating back movements in the past, we only accept
        # 1) movements that occur in the time period between now (system time) and the very last movement.
        # 2) movements into 2a) either a new cage or 2b) a cage having less than 5 mice since last movement (no matter how complex situation is)
        # 3) for new cages, we need to find a new cage that was free at all times between back-dated datetime of move and now

        # find out rack in which cage is currently placed + details
        $current_rack = get_cage_location($global_var_href, $cage_id);
        (undef, undef, $current_location_room, $current_location_rack) = get_location_details_by_id($global_var_href, $current_rack);
        (undef, undef, $target_location_room,  $target_location_rack)  = get_location_details_by_id($global_var_href, $target_rack);
        # 1) check if movement is in the time period between now (system time) and the very last movement of this cage
        if (Delta_ddmmyyyhhmmss(datetime_of_last_cage_move($global_var_href, $cage_id), param('datetime_of_move')) ne 'future') {
           $page .= p("Moving cage "  . a({-href=>"$url?choice=cage_view&cage_id=" . $cage_id}, $cage_id)
                      . " from rack " . a({-href=>"$url?choice=location_details&location_id=" . $current_rack}, "$current_location_room-$current_location_rack")
                      . " to rack "   . a({-href=>"$url?choice=location_details&location_id=" . $target_rack},  "$target_location_room-$target_location_rack")
                      . " at " . $datetime_of_move . ": "
                      . span({-class=>"red"},
                             b("skipped (date/time of move is before last movement of this cage, can't insert a movement before last movement)")
                        )
                    );
           next;
        }

        # actually move cage (call move transaction)
        ($error_code, $error_message) = db_move_cage($global_var_href, $cage_id, $current_rack, $target_rack, $datetime_of_move);

        # check error code of move transaction, offer option to print new cage card if move was successful
        if ($error_code == 0) {
           $page .= p("Moving cage "  . a({-href=>"$url?choice=cage_view&cage_id=" . $cage_id}, $cage_id)
                      . " from rack " . a({-href=>"$url?choice=location_details&location_id=" . $current_rack}, "$current_location_room-$current_location_rack")
                      . " to rack "   . a({-href=>"$url?choice=location_details&location_id=" . $target_rack},  "$target_location_room-$target_location_rack")
                      . " at " . $datetime_of_move . ": "
                      . b("done ")
                      . "["
                      . a({-href=>"$url?choice=print_card&cage_id=$cage_id", -target=>"_blank"}, "print new cage card" )
                      . "]"
                    );
        }
        else {
           $page .= p("Moving cage "  . a({-href=>"$url?choice=cage_view&cage_id=" . $cage_id}, $cage_id)
                      . " from rack " . a({-href=>"$url?choice=location_details&location_id=" . $current_rack}, "$current_location_room-$current_location_rack")
                      . " to rack "   . a({-href=>"$url?choice=location_details&location_id=" . $target_rack},  "$target_location_room-$target_location_rack")
                      . " at " . $datetime_of_move . ": "
                      . span({-class=>"red"},
                             b("skipped ($error_message)")
                        )
                    );
        }
     }
  }

  return $page;
}
# end of confirmed_cages_move()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MOV009 move_mice():                                 move selected mice
sub move_mice {                                          my $sr_name = 'SR_MOV009';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my @selected_mice     = param('mouse_select');
  my @mice_to_be_moved;
  my $mouse_id;
  my %rack_labels = ("screen" => "", "all"      => "");
  my %cage_labels = ("new"    => "", "existing" => "");
  my ($page, $location_room, $location_rack, $location_id, $cage_id);

  # check list of mice to be moved
  foreach $mouse_id (@selected_mice) {
     if ($mouse_id =~ /^[0-9]{1,8}$/) {
        push(@mice_to_be_moved, $mouse_id);
     }
  }

  if (scalar @mice_to_be_moved == 0) {
     $page .= h2("Move multiple mice ")
              . hr()
              . h3("No mice to move!")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (scalar @mice_to_be_moved > 5) {
     $page .= h2("Move multiple mice ")
              . hr()
              . h3("Cannot move more than 5 mice!")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # Display move dialog
  $page .= h2("Move multiple mice ")
           . hr();

  foreach $mouse_id (@mice_to_be_moved) {
       # find out cage in which mouse is currently placed
       $cage_id = get_cage($global_var_href, $mouse_id);

       # find out rack in which cage is currently placed + details
       $location_id = get_cage_location($global_var_href, $cage_id);

       (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, $location_id);

       $page .= p("Move mouse " . reformat_number($mouse_id, 8) . " from cage " . a({-href=>"$url?choice=cage_view&cage_id=" . $cage_id}, $cage_id)  . " in rack " . a({-href=>"$url?choice=location_details&location_id=" . $location_id}, "$location_room-$location_rack"));
  }

  $page .= hr()
           . start_form(-action=>url(), -name=>"myform")
           . p(u("1. Step: please choose target cage "))
           . table({-border=>0, -summary=>"table"},
                   Tr(
                     td({-colspan=>5}, b("move mouse ..."))
                   ) .
                   Tr(
                     td(radio_group(-name=>'which_cage', -values=>['new'],      -default=>'new',    -labels=>\%cage_labels)),
                     td(" to a new cage "),
                     td("&nbsp;&nbsp;&nbsp;" . b("or") . "&nbsp;&nbsp;&nbsp;"),
                     td(radio_group(-name=>'which_cage', -values=>['existing'], -default=>'screen', -labels=>\%cage_labels)),
                     td(" to an existing cage: "
                        . textfield(-title=>"cage id", -name => "existing_cage", -size=>"5", -onclick=>"document.myform.which_cage[1].checked=true")
                        . " (please enter existing cage id)")
                   ) .
                   Tr(
                     td(),
                     td(small("(a new cage will be placed " . br() . "in the rack chosen below)")),
                     td(),
                     td(),
                     td(small("(this cage will stay where it is, " . br() . "below rack selection will be ignored)"))
                   )
             )

           . p(u("2. Step: please choose target rack"))
           . table({-border=>0, -summary=>"table"},
                   Tr(
                     td(),
                     th("racks from your screen"),
                     th({-colspan=>2}, " or "),
                     th("all racks")
                   ) .
                   Tr(
                     td(radio_group(-name=>'which_racks', -values=>['screen'], -default=>'screen', -labels=>\%rack_labels)),
                     td(span({-onclick=>"document.myform.which_racks[0].checked=true"}, get_locations_popup_menu($global_var_href, undef, 'cage_count', 'screen_racks_only'))),
                     td("&nbsp;&nbsp;&nbsp;&nbsp;"),
                     td(radio_group(-name=>'which_racks', -values=>['all'], -default=>'screen', -labels=>\%rack_labels)),
                     td(span({-onclick=>"document.myform.which_racks[1].checked=true"}, get_locations_popup_menu($global_var_href, undef, 'cage_count')))
                   )
             )

           . p(u("[optional step: please specify move date]"))
           . table({-border=>0, -summary=>"table"},
                   Tr(
                     td(textfield(-name=>'datetime_of_move',
                                  -id=>"datetime_of_move",
                                  -size=>"20",
                                  -maxlength=>"21",
                                  -title=>"date and time of move",
                                  -value=>get_current_datetime_for_display()
                                  )
                        . "&nbsp;&nbsp;"
                        . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=datetime_of_move', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                        )
                   )
             )
           . p()
           . hidden(-name=>'mouse_select')
           . p()
           . submit(-name => "choice", -value=>"move mice!") . "&nbsp;&nbsp;&nbsp;or&nbsp;&nbsp;&nbsp;" . a({-href=>"javascript:back()"}, "cancel (go to previous page)")
           . end_form();

  return $page;
}
# end of move_mice
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MOV010 confirmed_mice_move                          confirmed mice move (wrapper for mouse move transaction)
sub confirmed_mice_move {                                my $sr_name = 'SR_MOV010';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my @selected_mice     = param('mouse_select');
  my $which_racks       = param('which_racks');          # switch to decide if target rack selection from 'all_racks' or from 'screen_racks'
  my $all_racks         = param('all_racks');
  my $screen_racks      = param('screen_racks');
  my $which_cage        = param('which_cage');           # switch to decide if target cage selection is 'new' or from 'existing' (then read out 'existing_cage')
  my $existing_cage     = param('existing_cage');
  my $datetime_of_move  = param('datetime_of_move');
  my $sex_color         = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my $warning           = '';
  my $is_mating         = 0;
  my @cagemates         = ();
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($error_code, $error_message, $target_rack, $target_cage, $real_target_cage);
  my ($current_cage, $current_rack, $current_location_room, $current_location_rack);
  my ($target_location_room,  $target_location_rack);
  my ($mice_in_target_cage, $males_in_cage, $females_in_cage, $sex_mixed, $cage_capacity);
  my ($first_gene_name, $first_genotype, $mouse_id, $move_message);
  my @sql_parameters;
  my @mice_to_be_moved;

  # check list of mice to be moved
  foreach $mouse_id (@selected_mice) {
     if ($mouse_id =~ /^[0-9]{1,8}$/) {
        push(@mice_to_be_moved, $mouse_id);
     }
  }

  # check if target rack info given
  if (!defined($which_racks) || !( ($which_racks eq 'screen') || ($which_racks eq 'all') ) ) {
     &error_message_and_exit($global_var_href, "invalid target rack selector", $sr_name . "-" . __LINE__);
  }
  if ($which_racks eq 'screen') {
     if (!defined($screen_racks) || $screen_racks !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid target rack (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $target_rack = $screen_racks;
     }
  }
  if ($which_racks eq 'all') {
     if (!defined($all_racks) || $all_racks !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid target rack (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $target_rack = $all_racks;
     }
  }

  # check if target cage info given
  if (!defined($which_cage) || !( ($which_cage eq 'new') || ($which_cage eq 'existing') ) ) {
     &error_message_and_exit($global_var_href, "invalid target cage selector", $sr_name . "-" . __LINE__);
  }
  if ($which_cage eq 'new') {
     $target_cage = 'new';
  }
  if ($which_cage eq 'existing') {
     if (!defined($existing_cage) || $existing_cage !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid target cage (must be a number)", $sr_name . "-" . __LINE__);
     }
     else {
        $target_cage = $existing_cage;

        # in case user specifies an existing cage, leave that cage in its current rack and overwrite above target rack selection
        # (= ignore rack selection, don't implicitely move existing cage)
        $target_rack = get_cage_location($global_var_href, $target_cage);
     }
  }

  # date of move not given or invalid
  if (!param('datetime_of_move') || check_datetime_ddmmyyyy_hhmmss(param('datetime_of_move')) != 1) {
     $page .= h2("Move mouse ")
              . hr()
              . p({-class=>"red"}, b("Error: date/time of move not given or has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # ok, now check if datetime of move is acceptable

  # 0) is it in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('datetime_of_move')) eq 'future') {
     $page .= h2("Move mouse ")
              . hr()
              . p({-class=>"red"}, b("Error: date/time of move is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # for existing cage: some checks
  if ($target_cage =~ /^[0-9]+$/) {

     # find out number of mice and sexes in an existing cage at the given datetime of move
     ($mice_in_target_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, $target_cage, format_display_datetime2sql_datetime(param('datetime_of_move')));

     # is given cage in use at all? (-> does it contain > 1 mice?)
     if ($mice_in_target_cage == 0) {
        $page .= h2("Move multiple mice ")
                 . hr()
                 . h3({-class=>"red"}, "Move not possible")
                 . p({-class=>"red"}, "Given target cage (" . $target_cage .  ") not in use") . hr()
                 . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection");
        return $page;
     }

     # enough space in target cage? If not, exit
     if (($cage_capacity - $mice_in_target_cage) < scalar @mice_to_be_moved) {
        $page .= h2("Move multiple mice ")
                 . hr()
                 . h3({-class=>"red"}, "Move not possible")
                 . p({-class=>"red"}, "There is/was not enough space left in the target cage (already $mice_in_target_cage mice)") . hr()
                 . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection");
        return $page;
     }
  }
  # 2a) for new cage: need to check if new cage id was never in use during desired datetime of move and now
  #     can't do this here => need to look for a new cage id within transaction
  elsif ($target_cage eq 'new') {
     # do nothing (at this point)
  }
  # given cage is neither a number nor 'new' cage, so what is it?
  else {
        $page .= h2("Move multiple mice ")
                 . hr()
                 . h3({-class=>"red"}, "Move not possible")
                 . p({-class=>"red"}, b("\tError: invalid target cage)")) . hr()
                 . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection");
  }

  #######################################################
  # global checks done, now try to move mouse by mouse...

  $page .= h2("Move multiple mice ")
           . hr();

  foreach $mouse_id (@selected_mice) {

     $page .= p("Trying to move mouse $mouse_id ...");

     # get details about current and target rack
     $current_cage = get_cage($global_var_href, $mouse_id);
     $current_rack = get_cage_location($global_var_href, $current_cage);

     (undef, undef, $current_location_room, $current_location_rack) = get_location_details_by_id($global_var_href, $current_rack);
     (undef, undef, $target_location_room,  $target_location_rack)  = get_location_details_by_id($global_var_href, $target_rack);

     # ok, obviously the move is not in the future, so we can proceed
     # in order to avoid error-prone situations resulting from dating back movements in the past, we only accept
     # 1) movements that occur in the time period between now (system time) and the very last movement.
     # 2) movements into 2a) either a new cage or 2b) a cage having less than 5 mice since last movement (no matter how complex situation is)
     # 3) for new cages, we need to find a new cage that was free at all times between back-dated datetime of move and now

     # 1) check if movement is in the time period between now (system time) and the very last movement of this mouse
     if (Delta_ddmmyyyhhmmss(datetime_of_last_move($global_var_href, $mouse_id), param('datetime_of_move')) ne 'future') {
        $page .= p({-class=>"red"}, "Error: date/time of move is before last movement, can't insert a movement before last movement (this is too complicated) "
                                    . br()
                                    . "mouse stays in cage " . a({-href=>"$url?choice=cage_view&cage_id=" . $current_cage},   " cage " . $current_cage)
                 )
                 . hr({-width=>"30%", -align=>"left"});

        # continue with next mouse
        next;
     }

     # 2b) for existing cage: check if chosen cage has ever had more than 4 mice at any point in time between last movement and now
     if ($target_cage =~ /^[0-9]+$/) {
        if (was_there_a_place_for_this_mouse_between_datetime_of_move_and_now($global_var_href,
                                                                              $target_cage,
                                                                              format_display_datetime2sql_datetime(param('datetime_of_move')),
                                                                              format_display_datetime2sql_datetime(get_current_datetime_for_display())) eq 'no') {
           $page .= p({-class=>"red"}, "Error: could not place mouse into given cage (during given time and now there was no place left in target cage at some time point)"
                                       . br()
                                       . "mouse stays in cage " . a({-href=>"$url?choice=cage_view&cage_id=" . $current_cage},   " cage " . $current_cage)
                    )
                    . hr({-width=>"30%", -align=>"left"});

           # continue with next mouse
           next;
        }
     }

     # 3) for new cages, we need to find a new cage that was free at all times between back-dated datetime of move and now
     # that means: looping over candidate cages and check if they were free at all times between back-dated datetime of move and now
     # of course, this has to be done within the transaction

     # actually perform move by calling transaction and receive move status
     # transaction may return values for real_target_cage and target rack that are different from chosen ones because in case of a problem,
     # mouse is moved to new cage on its own. real_target_cage and target rack are used to inform user about new location of mouse
     ($error_code, $error_message, $real_target_cage, $target_rack, $is_mating) = db_move_mouse($global_var_href, $mouse_id, $current_cage, $current_rack, $target_cage, $target_rack, $datetime_of_move);

     if ($error_code == 0) {
         $page .= p($error_message . ": moved mouse from cage" . a({-href=>"$url?choice=cage_view&cage_id=" . $current_cage},   " cage " . $current_cage) .  " to cage " . a({-href=>"$url?choice=cage_view&cage_id=" . $real_target_cage},   " cage " . $real_target_cage))
                  . hr({-width=>"30%", -align=>"left"});
     }
     else {
         $page .= p($error_message . ": mouse stays in cage "  . a({-href=>"$url?choice=cage_view&cage_id=" . $current_cage},   " cage " . $current_cage))
                  . hr({-width=>"30%", -align=>"left"});
     }

     # make sure all mice go to same target cage as first mouse when "new cage" was required
     $target_cage = $real_target_cage;
  }


  # finally, show content of target cage
  $sql = qq(select c2l_cage_id, cage_capacity,
                   mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_is_gvo, mouse_comment, location_id, location_room, location_rack, cage_id,
                   mouse_birth_datetime, mouse_deathorexport_datetime, project_shortname
            from   cages2locations
                   join locations          on  c2l_location_id = location_id
                   join cages              on          cage_id = c2l_cage_id
                   join mice2cages         on      m2c_cage_id = cage_id
                   join mice               on     m2c_mouse_id = mouse_id
                   join mouse_strains      on     mouse_strain = strain_id
                   join mouse_lines        on       mouse_line = line_id
                   left join projects      on location_project = project_id
            where  m2c_cage_id = ?
                   and c2l_datetime_to IS NULL
                   and m2c_datetime_to IS NULL
                   and mouse_deathorexport_datetime IS NULL
            order  by mouse_id asc
           );

  @sql_parameters = ($target_cage);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if there are no mice in target cage, notify user (this should not happen normally, since there is a check for unused cage before)
  if ($rows == 0) {
     $page .= p({-class=>"red"}, "Error: target cage " . $target_cage . " is currently not in use (cannot move to a specified cage that is currently not in use)")
              . hr()
              . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection");
     return $page;
  }

  # display target cage content
  else {
     # get target cage summary info - find out if mixed cage
     ($mice_in_target_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity)= get_mice_in_cage($global_var_href, $target_cage);

     @cagemates = get_current_cage_mates($global_var_href, $target_cage);


     $page .= hr()
              . h3("Target cage " . $target_cage . " (placed in rack "
                   . a({-href=>"$url?choice=location_details&location_id=" . $result->[0]->{'location_id'}}, "$result->[0]->{'location_room'}/$result->[0]->{'location_rack'}")
                   . ", $result->[0]->{'project_shortname'}) now contains $rows " . (($rows == 1)?'mouse':'mice' )
                )

              # offer link to print cage card (and link to set up mating for mixed cages)
              . p(a({-href=>"$url?choice=print_card&cage_id=$target_cage", -target=>"_blank"}, "print new cage card" )

                  # offer link to set up mating (for mixed cages only)
                  . (($sex_mixed eq 'true')
                     ?"&nbsp;&nbsp;&nbsp;" . a({-href=>"$url?job=mate&mouse_select=" . join('&mouse_select=', @cagemates) . "&move_mode=no_move", -target=>"_blank"}, "set up mating for mice in cage " . $target_cage)
                     :''
                    )
                )

              . start_form(-action=>url(), -name=>"myform")
              . start_table( {-border=>1, -summary=>"table"})
              . Tr(
                  th(span({-title=>"this is just the table row number"}, "#")),
                  th("mouse ID"),
                  th("ear"),
                  th("sex"),
                  th("born"),
                  th("age"),
                  th("death"),
                  th("genotype"),
                  th("strain"),
                  th("line"),
                  th("room/rack-cage")
                );

     # loop over all mice in target cage
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         # get first genotype
         ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

         # add table row for current line
         $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                    td($i+1),
                    td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                    td($row->{'mouse_earmark'}),
                    td($row->{'mouse_sex'}),
                    td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                    td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                    td(format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
                    td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
                    td($row->{'strain_name'}),
                    td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                    td((!defined($row->{'mouse_deathorexport_datetime'}))?$row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'}:'-')
                  );
     }

     $page .= end_table()
              . p()
              . p(a({-href=>"$url?choice=location_details&location_id=$current_rack"}, "go back to start rack"));
  }

  return $page;
}
# end of confirmed_mice_move()
#--------------------------------------------------------------------------------------


# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;