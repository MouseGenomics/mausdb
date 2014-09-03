# lib_weaning.pl - a MausDB subroutine library file                                                                              #
#                                                                                                                                #
# Subroutines in this file provide functions related to wean litter                                                              #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_WEA001 wean_litter_step_1():                        wean litter (1. step: initial form)                                     #
# SR_WEA002 wean_litter_step_2():                        wean litter (2. step: pups form)                                        #
# SR_WEA003 wean_litter_step_3():                        wean litter (3. step: confirmation step)                                #
# SR_WEA004 wean_litter_step_4():                        wean litter (4. step: database transaction)                             #
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
# SR_WEA001 wean_litter():                               wean litter (1. step: initial form)
sub wean_litter_step_1 {                                 my $sr_name = 'SR_WEA001';
  my ($global_var_href)  = @_;                              # get reference to global vars hash
  my $dbh                = $global_var_href->{'dbh'};       # DBI database handle
  my $litter_id          = param('litter_id');
  my $url                = url();
  my $datetime_sql       = get_current_datetime_for_sql();
  my $date;
  my $sex_color          = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my ($page, $sql, $result, $rows, $row, $i);
  my ($mating_id, $litter_count, $is_gvo);
  my %gvo_labels = ('y' => 'yes', 'n' => 'no');
  my @sql_parameters;

  $page = h2("Weaning: 1. step")
          . hr();

  # check input: is litter id given? is it a number?
  if (!param('litter_id') || param('litter_id') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please provide a valid litter id"));
     return $page;
  }

  # get gvo status of parents
  $sql = qq(select max(mouse_is_gvo)
            from   litters2parents
                   join mice on l2p_parent_id = mouse_id
            where  l2p_litter_id = ?
           );

  @sql_parameters = ($litter_id);

  ($is_gvo) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # get litter info
  $sql = qq(select litter_id, litter_born_datetime, litter_weaning_datetime, litter_in_mating, litter_reduced,
                   litter_alive_total, litter_alive_male, litter_alive_female, litter_mating_id,
                   strain_name, line_name
            from   litters
                   join matings       on litter_mating_id = mating_id
                   join mouse_strains on    mating_strain = strain_id
                   join mouse_lines   on      mating_line = line_id
            where  litter_id = ?
           );

  @sql_parameters = ($litter_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no litter found to wean: tell and quit
  unless ($rows > 0) {
     $page .= p("No such litter found");
     return $page;
  }

  # otherwise continue with litter details table
  $row = $result->[0];

  ($date, undef) = split(/\s/, $row->{'litter_born_datetime'});

  $page .= h3("1. step: Please enter litter details for $row->{'litter_in_mating'}. litter from " . a({-href=>"$url?choice=mating_view&mating_id=" . $row->{'litter_mating_id'}}, "mating " . $row->{'litter_mating_id'}))
           . start_form(-action=>url(), -name=>"myform")
           . hidden(-name=>"litter_id")
           . hidden(-name=>"litter_line",   -value=>$row->{'line_name'})
           . hidden(-name=>"litter_strain", -value=>$row->{'strain_name'})
           . table( {-border=>1, -summary=>"table"},
                Tr({-bgcolor=>"#DDDDDD"},
                  th(" line "),
                  td({-colspan=>2}, "&nbsp;" . $row->{'line_name'})
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                  th(" strain "),
                  td({-colspan=>2}, "&nbsp;" . $row->{'strain_name'})
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                  th(" date of birth "),
                  td({-colspan=>2}, textfield(-name=>'litter_born_datetime', -id=>"litter_born_datetime", -size=>"20", -maxlength=>"21", -title=>"litter date of birth", -value=>format_sql_datetime2display_datetime($row->{'litter_born_datetime'}))
                     . "&nbsp;&nbsp;"
                     . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=litter_born_datetime', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                     . span({-class=>"red"}, b("please check date of birth!"))
                    )
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                  th(" date of weaning "),
                  td({-colspan=>2}, textfield(-name=>'litter_weaning_datetime', -id=>'litter_weaning_datetime', -size=>'20', -maxlength=>'21', -title=>'weaning date (default: today)', -value=>format_sql_datetime2display_datetime(add_to_date($global_var_href, $date, 21) . ' 09:00:00'))
                     . "&nbsp;&nbsp;"
                     . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=litter_weaning_datetime', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                     . ((format_sql_datetime2display_date($row->{'litter_born_datetime'}) eq get_current_date_for_display())?span({-class=>"red"}, b("date of birth and date of weaning cannot be equal!")):'')
                    )
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                   td({-align=>"center"}, b("weaning type") . br() . small("please specify")),
                   td(radio_group(-name=>'weaning_type', -values=>['regular', 'external'], -default=>3)),
                   td({-colspan=>2}, "\'external\' mice will not be taken into account for TEP reporting or cost calculations ")
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                  th(" are these mice " . br() . " genetically modified " . br() . " (GVOs)? "),
                  td(radio_group(-name=>'litter_is_gvo', -values=>['y', 'n'], -default=>$is_gvo, -labels=>\%gvo_labels, -linebreak=>'true') ),
                  td(small(" default has been determined " . br() . "automatically by parent gvo status, so please check!"))
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                  td({-align=>"center"}, b("cost centre ["
                                           . a({-href=>"$url?choice=cost_centre_overview", -title=>'click to see all cost centres in new window', -target=>'_blank'}, 'help')
                                           . ']'
                                         )
                                         . br() . small("assign a cost centre") . br() . small('Who will pay for the mouse housing costs?')
                  ),
                  td({-colspan=>"3"}, " Cost centre to bill mouse housing costs to: " . get_cost_centre_popup_menu($global_var_href)                  )
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                  th(""),
                  th({-bgcolor=>$sex_color->{'m'}}, b(" males   ") ),
                  th({-bgcolor=>$sex_color->{'f'}}, b(" females ") )
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                  th(" how many pups " . br() . " from this litter " . br() . " do you want to wean? "),
                  td({-bgcolor=>$sex_color->{'m'}},
                     popup_menu(-name=>'number_of_males',    -values=>["0" .. "25"], -default=>$row->{'litter_alive_male'},   -title=>"number of males to be weaned"   )
                  ),
                  td({-bgcolor=>$sex_color->{'f'}},
                     popup_menu(-name=>'number_of_females',  -values=>["0" .. "25"], -default=>$row->{'litter_alive_female'}, -title=>"number of females to be weaned" )
                  )
                ) .
                Tr(
                  th(" optional: " . br() . " maximum number " . br() . " in one cage "),
                  td({-bgcolor=>$sex_color->{'m'}},
                     radio_group(-name=>'males_per_cage',   -values=>[1 .. 5], -default=>5, -title=>"max number of males in one cage")
                     . br()
                     . small(" (only applies for new cages) ")
                  ),
                  td({-bgcolor=>$sex_color->{'f'}},
                     radio_group(-name=>'females_per_cage', -values=>[1 .. 5], -default=>5, -title=>"max number of females in one cage")
                     . br()
                     . small(" (only applies for new cages) ")
                  )
                ) .
                Tr(
                  th(" optional: " . br() . " start ear tag "),
                  td({-bgcolor=>$sex_color->{'m'}},
                     popup_menu(-name=>'male_eartag_start',    -values=>["by_id", "01" .. "99"], -default=>"01", -title=>"starting ear tag for males" )
                  ),
                  td({-bgcolor=>$sex_color->{'f'}},
                     popup_menu(-name=>'female_eartag_start',  -values=>["by_id", "01" .. "99"], -default=>"01", -title=>"starting ear tag for females" )
                  )
                ) .
                Tr(
                  th(" optional: " . br() . " use existing cages "),
                  td({-bgcolor=>$sex_color->{'m'}},
                     textfield(-name=>'use_male_cages',    -size=>"30", -title=>"cage ids separated by blanks or by ;," ) . br()
                     . small("(example: 13, 543 8;876)")
                  ),
                  td({-bgcolor=>$sex_color->{'f'}},
                     textfield(-name=>'use_female_cages',  -size=>"30", -title=>"cage ids separated by blanks or by ;," ) . br()
                     . small("(example: 17; 0548 89)")
                  )
                ) .
                Tr(
                  th(" optional: " . br() . " litter comment "),
                  td({-colspan=>3}, textarea(-name=>"litter_comment", -columns=>"40", -rows=>"5", -title=>"enter any comment on this litter" ))
                )
             )
           . p()
           . hidden(-name=>"step",   -value=>"wean_step_1", -override=>1)
           . hidden(-name=>"first",  -value=>"1")
           . submit(-name=>"choice", -value=>"next step", -title=>"next step")
           . "&nbsp;&nbsp;or&nbsp;&nbsp;"
           . a({-href=>"javascript:back()"}, "go back")
           . end_form();


  return $page;
}
# end of wean_litter_step_1
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_WEA002 wean_litter_step_2():                        wean litter (2. step: pups form)
sub wean_litter_step_2 {                                 my $sr_name = 'SR_WEA002';
  my ($global_var_href)       = @_;                              # get reference to global vars hash
  my $dbh                     = $global_var_href->{'dbh'};       # DBI database handle
  my $litter_id               = param('litter_id');
  my $litter_born_datetime    = param('litter_born_datetime');
  my $litter_line             = param('litter_line');
  my $litter_strain           = param('litter_strain');
  my $cost_centre             = param('cost_centre');
  my $litter_weaning_datetime = param('litter_weaning_datetime');
  my $number_of_males         = param('number_of_males');
  my $number_of_females       = param('number_of_females');
  my $males_per_cage          = param('males_per_cage');
  my $females_per_cage        = param('females_per_cage');
  my $male_eartag_start       = param('male_eartag_start');
  my $female_eartag_start     = param('female_eartag_start');
  my $use_male_cages          = param('use_male_cages');
  my $use_female_cages        = param('use_female_cages');
  my $weaning_type            = param('weaning_type');
  my $is_gvo                  = param('litter_is_gvo');
  my @use_male_cages          = ($use_male_cages =~ /(\d+)/g);          # grep all numbers from param('use_male_cages') into list
  my @use_female_cages        = ($use_female_cages =~ /(\d+)/g);        # grep all numbers from param('use_female_cages') into list
  my $url                     = url();
  my @cage_list               = ();
  my $cage_suffix             = 0;
  my %new_cage                = ();
  my %ear_in_cage             = ();
  my %cage_candidates         = ();
  my $hide_next_button        = 0;
  my $overflow_cage           = 'a';
  my $sex_color               = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my ($page, $sql, $result, $rows, $row, $i, $j);
  my ($mouse, $cage, $free_beds_in_cage, $default_rack, $one_mother, $earmark, $age_weeksdays, $age_days, $age_weeks, $remark);
  my ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, $cage_capacity, $location_room, $location_rack, $rack);
  my $mating_start_datetime_sql;
  my $female_eartag_warning = '';
  my $male_eartag_warning   = '';
  my @sql_parameters;

  $page = h2("Weaning: 2. step")
          . hr();

  # check input: is litter id given? is it a number?
  if (!param('litter_id') || param('litter_id') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please provide a valid litter id"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is litter line given?
  if (!param('litter_line') || param('litter_line') eq '') {
     $litter_line = 'warning: problem with line!';
  }

  # check input: is litter strain given?
  if (!param('litter_strain') || param('litter_strain') eq '') {
     $litter_strain = 'warning: problem with strain!';
  }

  # check input: is cost centre given? is it a number?
  if (!param('cost_centre') || param('cost_centre') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please provide a valid cost centre"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # litter date of birth not given or invalid
  if (!param('litter_born_datetime') || check_datetime_ddmmyyyy_hhmmss(param('litter_born_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of birth not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is litter born datetime in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('litter_born_datetime')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: date/time of litter birth is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # date of weaning not given or invalid
  if (!param('litter_weaning_datetime') || check_datetime_ddmmyyyy_hhmmss(param('litter_weaning_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of birth not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is litter weaning datetime in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('litter_weaning_datetime')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: date/time of weaning is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # litter born datetime must not be later than litter weaning datetime!
  if (Delta_ddmmyyyhhmmss(param('litter_weaning_datetime'), param('litter_born_datetime')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: weaning cannot be before birth! "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # date of birth must not equal date of weaning
  if (param('litter_weaning_datetime') eq param('litter_born_datetime')) {
     $page .= p({-class=>"red"}, b("Error: date of birth cannot be the same as date of weaning!"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # weaning_type must be given and it must be either 'regular' or 'external'
  if (!param('weaning_type') || !(param('weaning_type') eq 'regular' || param('weaning_type') eq 'external')) {
     $page .= p({-class=>"red"}, b("Error: please choose between weaning type \"regular\" and \"external\". \"external\" mice will not be taken into account for TEP reporting or cost calculations "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # get date of mating start to prevent litter_born_date < mating_start_date
  $sql = qq(select mating_matingstart_datetime
            from   matings
                   join litters on litter_mating_id = mating_id
            where  litter_id = ?
           );

  @sql_parameters = ($litter_id);

  ($mating_start_datetime_sql) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # check if litter_born_date < mating_start_date: if so, return with error
  if (Delta_ddmmyyyhhmmss(param('litter_born_datetime'), format_sql_datetime2display_datetime($mating_start_datetime_sql)) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: date/time of litter birth cannot be before mating was started. "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # get age at day of weaning (we want to print a warning if younger than 16 days at time of weaning)
  $age_weeksdays = get_age(format_display_datetime2sql_datetime(param('litter_born_datetime')), format_display_datetime2sql_datetime(param('litter_weaning_datetime')));

  # function get_age returns a string like "2w3d" (meaning 2 weeks and 3 days), so we need to split and extract values from this string
  ($age_weeks, $age_days) = split(/[wd]/, $age_weeksdays);

  # calculate age in days
  $age_days = $age_weeks * 7 + $age_days;

  # warn if too young
  #if ($age_days < 16) {
  if ($age_weeksdays < 16) {
     #$page .= p({-class=>"red"}, b("Warning: pups are only $age_days days old at time of weaning!"))
     $page .= p({-class=>"red"}, b("Warning: pups are only $age_weeksdays days old at time of weaning!"))
              . hr();
  }

  # warn if too old
  #if ($age_days > 27) {
  if ($age_weeksdays > 27) {
    # $page .= p({-class=>"red"}, b("Warning: pups are already $age_days days old at time of weaning!"))
     $page .= p({-class=>"red"}, b("Warning: pups are already $age_weeksdays days old at time of weaning!"))
              . hr();
  }

  # make sure number of males is defined
  if (!param('number_of_males') || param('number_of_males') !~ /^[0-9]+$/) {
     $number_of_males = 0;
  }

  # make sure number of females is defined
  if (!param('number_of_females') || param('number_of_females') !~ /^[0-9]+$/) {
     $number_of_females = 0;
  }

  # are there pups to wean at all?
  if ($number_of_males + $number_of_females == 0) {
     $page .= p({-class=>"red"}, b("no pups to wean!"))
              . p(a({-href=>"javascript:back()"}, "please go back and check your input"));
     return $page;
  }

  # set males per cage if not given or invalid
  if (!param('males_per_cage') || param('males_per_cage') !~ /^[0-9]+$/) {
     $males_per_cage = 5;
  }

  # set females per cage if not given or invalid
  if (!param('females_per_cage') || param('females_per_cage') !~ /^[0-9]+$/) {
     $females_per_cage = 5;
  }

  # same for male and female eartag start values
  if (!param('male_eartag_start') || param('male_eartag_start') !~ /^[0-9]+$/) {
     $male_eartag_start = '01';
  }
  if (defined(param('male_eartag_start')) && param('male_eartag_start') eq 'by_id') {
     $male_eartag_start = 'id';
     $male_eartag_warning = p({-class=>'red'}, "Info: eartags for males will be set on last two digits of assigned mouse id");
  }

  if (!param('female_eartag_start') || param('female_eartag_start') !~ /^[0-9]+$/) {
     $female_eartag_start = '01';
  }
  if (defined(param('female_eartag_start')) && param('female_eartag_start') eq 'by_id') {
     $female_eartag_start = 'id';
     $female_eartag_warning = p({-class=>'red'}, "Info: eartags for females will be set on last two digits of assigned mouse id.");
  }

  # first table (litter details)
  $page .= h3("2. step: assign eartags and weaning cages ")
           . start_form(-action=>url(), -name=>"myform")
           . hidden(-name=>"litter_id")
           . hidden('litter_born_datetime') . hidden('litter_weaning_datetime') . hidden('number_of_males')   . hidden('number_of_females')
           . hidden('males_per_cage')       . hidden('females_per_cage')        . hidden('use_male_cages')    . hidden('use_female_cages')
           . hidden('litter_is_gvo')        . hidden('litter_comment')          . hidden('male_eartag_start') . hidden('female_eartag_start')
           . hidden('litter_line')          . hidden('litter_strain')           . hidden('weaning_type')      . hidden('cost_centre');

  #------------------------------------------------------------------
  # begin with males
  if ($number_of_males > 0) {

     # if user wants to use existing cages, use these cages in the given order to create a default list for weaning cages. Every existing cage
     # is filled to its cage capacity (usually 5).
     while ($cage = shift(@use_male_cages)) {
        # get some cage info
        ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, $cage);
        # calculate free "beds" in this cage
        $free_beds_in_cage = $cage_capacity - $mice_in_cage;

        # add current cage to weaning cage list so many times as there are free beds in this cage ...
        for ($j=1; $j<=$free_beds_in_cage; $j++) {
            # ... but only if this cage contains males only
            if (($males_in_cage > 0) && ($females_in_cage == 0)) {
               push(@cage_list, $cage);
            }
        }
     }

     # so far, any existing cages from user input are processed. For the remaining males to be weaned, create new cages.
     # Use param('males_per_cage') input to limit number of mice per cage.
     for ($j=0; $j<$number_of_males; $j++) {            # this will of course create an excess of cages, but we don't care ...
         if ($j % $males_per_cage == 0) {               # use modulo operator to decide when to start a new cage
            $cage_suffix++;
         }

         # add this new cage to the list of weaning cages
         push(@cage_list, 'new_' . $cage_suffix);
     }

     # add this point, there is a @cage_list containing either real cage ids or "new_1", "new_2", ... placeholders. For every male to be weaned,
     # a default cage is taken from the beginning of that list.

     $page .= h3("male pups")
              . $male_eartag_warning
              . start_table( {-border=>"1", -cellpadding=>"2", -summary=>"table"} )
              . Tr(
                  th("#"),
                  th("mouse id"),
                  th("eartag"),
                  th("sex"),
                  th("born"),
                  th("line"),
                  th("strain"),
                  th("color"),
                  th("cage"),
                  th("rack"),
                  th("comment"),
                  th("remark")
                 );

     # loop over all male mice to be weaned
     for ($mouse = 1; $mouse <= $number_of_males; $mouse++) {
         # take next cage from beginning of @cage_list
         $cage = shift(@cage_list);

         $remark = '';

         # applies for "first round" only: if we use an existing cage for this mouse (= it is a number), get its rack information for display
         if (defined(param('first')) && $cage =~ /^[0-9]+$/) {
            (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, get_cage_location($global_var_href, $cage));
            $rack = $location_room . "-" . $location_rack;
         }

         # applies for "first round" only: if we need to create a new cage for this mouse, display a note that rack needs to be selected
         elsif (defined(param('first'))  && $cage =~ /^new_[0-9]+$/) {
            $rack = span({-class=>"red"}, 'select rack below!');
            $new_cage{$cage}++;                                         # increase new cage counter for this cage
            $hide_next_button++;                                        # hide "next button" as long as information is missing
         }

         # applies for "update" views: if an existing cage is given, recheck if this cage can be used to wean male
         elsif (defined(param("cage_$mouse")) && param("cage_$mouse") =~ /^[0-9]+$/) {
            # get some cage info
            ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, param("cage_$mouse"));
            # calculate free "beds" in this cage
            $free_beds_in_cage = $cage_capacity - $mice_in_cage;

            # keep track how many mice are to be placed in this cage
            $cage_candidates{param("cage_$mouse")}++;

            # only if there is at least one "bed" left and it is a pure male cage, accept
            if (($free_beds_in_cage >= $cage_candidates{param("cage_$mouse")}) && ($males_in_cage > 0) && ($females_in_cage == 0)) {
               (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, get_cage_location($global_var_href, param("cage_$mouse")));
               $rack = $location_room . "-" . $location_rack;
            }
            elsif (($free_beds_in_cage < $cage_candidates{param("cage_$mouse")}) && ($males_in_cage > 0) && ($females_in_cage == 0)) {
               $rack = span({-class=>"red"}, 'cannot use this cage, no space left! ' . a({-href=>"$url?choice=cage_view&cage_id=" . param("cage_$mouse"), -target=>"_blank"}, "(see why)"));
               $hide_next_button++;                                        # hide "next button" as long as information is missing
            }
            else {
               $rack = span({-class=>"red"}, 'cannot use this cage! ' . a({-href=>"$url?choice=cage_view&cage_id=" . param("cage_$mouse"), -target=>"_blank"}, "(see why)"));
               $hide_next_button++;                                        # hide "next button" as long as information is missing
            }
         }

         # applies for "update" views: we use a new cage for weaning
         else {
            # if field is not given or empty, set it to "any"
            if (!defined(param("cage_$mouse")) || param("cage_$mouse") eq "") { param(-name=>"cage_$mouse", -value=>"any"); }

            $new_cage{param("cage_$mouse")}++;                             # increase new cage counter for this cage

            # make sure that also new cages are not filled with more than 5 mice or the defined cage limit
            if (($new_cage{param("cage_$mouse")} > $males_per_cage) || ($new_cage{param("cage_$mouse")} > 5)) {
               param(-name=>"cage_$mouse", -value=>param("cage_$mouse") . $overflow_cage++);
               $cage_candidates{param("cage_$mouse")}++;
               $new_cage{param("cage_$mouse")}++;
            }

            # now check if there is already a rack defined for this new cage
            if (defined(param('rack_' . param("cage_$mouse")))) {
               $rack = param('rack_' . param("cage_$mouse"));
               (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, $rack);
               $rack = $location_room . "-" . $location_rack;
            }
            else {
              $rack = span({-class=>"red"}, 'select rack below!');
              $hide_next_button++;                                        # hide "next button" as long as information is missing
            }
         }

         # now check earmark
         if (defined(param("earmark_$mouse"))) {                           # an earmark is given
            if (param("earmark_$mouse") =~ /^[0-9]+$/) {                   # accept if it is a number
               $earmark = param("earmark_$mouse");
            }
            else {                                                         # it is not a number...
               if (param('male_eartag_start') eq 'by_id' ||                # ... but maybe we want auto earmark (last two digits of id)
                   param("earmark_$mouse") eq 'id') {
                  $earmark = 'id';
               }
               else {
                  $earmark = '??';
                  $hide_next_button++;                                     # hide "next button" as long as information is missing
               }
            }
         }
         elsif (param('male_eartag_start') ne 'by_id') {                   # we increment earmark from a given start number
            if ($male_eartag_start > 99) { $male_eartag_start = 0; }       # limit to 2 digits
            $earmark = $male_eartag_start++;
         }
         else {                                                            # we want auto_id
            $earmark = 'id';
         }

         if (!defined(param('first'))) {
            # remember ear tag used per cage
            $ear_in_cage{param("cage_$mouse")}{param("earmark_$mouse")}++;

            if ($ear_in_cage{param("cage_$mouse")}{param("earmark_$mouse")} > 1) {
               $remark .= "same eartag in cage!";
            }
         }

         $page .= Tr({-bgcolor=>$sex_color->{'m'}},
                    td($mouse),
                    td({-style=>"color: #888888;"}, "to be assigned"),
                    td({-align=>"right"}, textfield(-class=>(($earmark eq '??')?'red':''), -name=>"earmark_$mouse", -size=>"2", -maxlength=>"4", -value=>$earmark, -override=>1) ),
                    td({-align=>"center"}, "m" . hidden(-name=>"sex_$mouse",  -value=>"m")),
                    td(format_display_datetime2display_date($litter_born_datetime)),
                    td($litter_line),
                    td($litter_strain),
                    td(get_colors_popup_menu($global_var_href, 1, "color_$mouse")),
                    td(textfield(-name=>"cage_$mouse", -size=>"6", -value=>( (defined(param("cage_$mouse")))
                                                                              ?param("cage_$mouse")
                                                                              :$cage
                                                                           )
                                )
                    ),
                    td($rack),
                    td(textfield(-name=>"comment_$mouse", -size=>"40")),
                    td($remark)
                  );
     }

     $page .= end_table()
              . p();

     # display rack selector table only if necessary
     if (scalar (keys %new_cage) > 0) {
        # determine default rack: take the rack where the litter's mother(s) cage is placed
        $sql = qq(select max(l2p_parent_id) as one_mother
                  from   litters2parents
                  where  l2p_litter_id       = ?
                         and l2p_parent_type = ?
                 );

        @sql_parameters = ($litter_id, 'mother');

        ($one_mother) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

        # if we can determine one mother, get her rack
        if (defined($one_mother) and $one_mother =~ /^[0-9]{8}$/) {
           $default_rack = get_cage_location($global_var_href, get_cage($global_var_href, $one_mother));
        }
        else {     # otherwise take first rack
           $default_rack = 1;
        }

        $page .= h3("choose racks for new male cages")
                 . start_table( {-border=>1, -cellpadding=>"2", -summary=>"table"})
                 . Tr(
                     th('cage'),
                     th('rack'),
                     th('info')
                   )
                 . Tr(
                     th('all'),
                     td(get_locations_popup_menu_for_weaning($global_var_href, $default_rack, 'male_selector', 'male_selector', 'males_rack_', 'yes')),
                     th('choose rack for all cages')
                   ) . Tr();

        foreach $cage (sort keys %new_cage) {
           $page .= Tr({-bgcolor=>$sex_color->{'m'}},
                      td($cage),
                      td(get_locations_popup_menu_for_weaning($global_var_href, $default_rack, 'rack_' . $cage, 'males_rack_' . $cage, 'males_rack_', 'no')),
                      td()
                    );
        }

        $page .= end_table();
     }

  }
  else {
     $page .= h3(" no male pups to wean ");
  }
  # males done
  #------------------------------------------------------------------

  # reset things
  @cage_list       = ();
  %new_cage        = ();
  %cage_candidates = ();

  $page .= p(submit(-name=>"choice", -value=>"update weaning preview", -title=>"update weaning preview")
             . "&nbsp;&nbsp;or&nbsp;&nbsp;"
             . a({-href=>"$url?choice=wean_litter_1&litter_id=" . $litter_id}, "go back")
           )
           . hr({-align=>"left", -width=>"50%"});

  #------------------------------------------------------------------
  # now the females
  if ($number_of_females > 0) {

     # if user wants to use existing cages, use these cages in the given order to create a default list for weaning cages. Every existing cage
     # is filled to its cage capacity (usually 5).
     while ($cage = shift(@use_female_cages)) {
        # get some cage info
        ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, $cage);
        # calculate free "beds" in this cage
        $free_beds_in_cage = $cage_capacity - $mice_in_cage;

        # add current cage to weaning cage list so many times as there are free beds in this cage ...
        for ($j=1; $j<=$free_beds_in_cage; $j++) {
            # ... but only if this cage contains females only
            if (($females_in_cage > 0) && ($males_in_cage == 0)) {
               push(@cage_list, $cage);
            }
        }
     }

     # so far, any existing cages from user input are processed. For the remaining females to be weaned, create new cages.
     # Use param('females_per_cage') input to limit number of mice per cage.
     for ($j=0; $j<$number_of_females; $j++) {            # this will of course create an excess of cages, but we don't care ...
         if ($j % $females_per_cage == 0) {               # use modulo operator to decide when to start a new cage
            $cage_suffix++;
         }

         push(@cage_list, 'new_' . $cage_suffix);
     }

     # add this point, there is a @cage_list containing either real cage ids or "new_1", "new_2", ... placeholders. For every female to be weaned,
     # a default cage is taken from the beginning of that list.

     $page .= h3("female pups")
              . $female_eartag_warning
              . start_table( {-border=>"1", -cellpadding=>"2", -summary=>"table"})
              . Tr(
                  th("#"),
                  th("mouse id"),
                  th("eartag"),
                  th("sex"),
                  th("born"),
                  th("line"),
                  th("strain"),
                  th("color"),
                  th("cage"),
                  th("rack"),
                  th("comment"),
                  th("remark")
                 );

     for ($mouse = ($number_of_males + 1); $mouse <= ($number_of_males + $number_of_females); $mouse++) {
         $cage = shift(@cage_list);                                  # take next cage from beginning of @cage_list
         $remark = '';

         # applies for "first round" only: if we use an existing cage for this mouse (= it is a number), get its rack information for display
         if (defined(param('first')) && $cage =~ /^[0-9]+$/) {
            (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, get_cage_location($global_var_href, $cage));
            $rack = $location_room . "-" . $location_rack;
         }

         # applies for "first round" only: if we need to create a new cage for this mouse, display a note that rack needs to be selected
         elsif (defined(param('first'))  && $cage =~ /^new_[0-9]+$/) {
            $rack = span({-class=>"red"}, 'select rack below!');
            $new_cage{$cage}++;                                         # increase new cage counter for this cage
            $hide_next_button++;                                        # hide "next button" as long as information is missing
         }

         # applies for "update" views: if an existing cage is given, recheck if this cage can be used to wean female
         elsif (defined(param("cage_$mouse")) && param("cage_$mouse") =~ /^[0-9]+$/) {
            # get some cage info
            ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, param("cage_$mouse"));
            # calculate free "beds" in this cage
            $free_beds_in_cage = $cage_capacity - $mice_in_cage;

            # keep track how many mice are to be placed in this cage
            $cage_candidates{param("cage_$mouse")}++;

            # only if there is at least one "bed" left and it is a pure female cage, accept
            if (($free_beds_in_cage >= $cage_candidates{param("cage_$mouse")}) && ($females_in_cage > 0) && ($males_in_cage == 0)) {
               (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, get_cage_location($global_var_href, param("cage_$mouse")));
               $rack = $location_room . "-" . $location_rack;
            }
            elsif (($free_beds_in_cage < $cage_candidates{param("cage_$mouse")}) && ($females_in_cage > 0) && ($males_in_cage == 0)) {
               $rack = span({-class=>"red"}, 'cannot use this cage, no space left! ' . a({-href=>"$url?choice=cage_view&cage_id=" . param("cage_$mouse"), -target=>"_blank"}, "(see why)"));
               $hide_next_button++;                                        # hide "next button" as long as information is missing
            }
            else {
               $rack = span({-class=>"red"}, 'cannot use this cage! ' . a({-href=>"$url?choice=cage_view&cage_id=" . param("cage_$mouse"), -target=>"_blank"}, "(see why)"));
               $hide_next_button++;                                        # hide "next button" as long as information is missing
            }
         }

         # applies for "update" views: we use a new cage for weaning
         else {
            # if field is not given or empty, set it to "any"
            if (!defined(param("cage_$mouse")) || param("cage_$mouse") eq "") { param(-name=>"cage_$mouse", -value=>"any"); }

            $new_cage{param("cage_$mouse")}++;                                        # increase new cage counter for this cage

            # make sure that also new cages are not filled with more than 5 mice or the defined cage limit
            if (($new_cage{param("cage_$mouse")} > $females_per_cage) || ($new_cage{param("cage_$mouse")} > 5)) {
               param(-name=>"cage_$mouse", -value=>param("cage_$mouse") . $overflow_cage++);
               $cage_candidates{param("cage_$mouse")}++;
               $new_cage{param("cage_$mouse")}++;
            }

            # now check if there is already a rack defined for this new cage
            if (defined(param('rack_' . param("cage_$mouse")))) {
               $rack = param('rack_' . param("cage_$mouse"));
               (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, $rack);
               $rack = $location_room . "-" . $location_rack;
            }
            else {
              $rack = span({-class=>"red"}, 'select rack below!');
              $hide_next_button++;                                        # hide "next button" as long as information is missing
            }
         }

         # now check earmark
         if (defined(param("earmark_$mouse"))) {                           # an earmark is given
            if (param("earmark_$mouse") =~ /^[0-9]+$/) {                   # accept if it is a number
               $earmark = param("earmark_$mouse");
            }
            else {                                                         # it is not a number...
               if (param('female_eartag_start') eq 'by_id' ||              # ... but maybe we want auto earmark (last two digits of id)
                   param("earmark_$mouse") eq 'id') {
                  $earmark = 'id';
               }
               else {
                  $earmark = '??';
                  $hide_next_button++;                                     # hide "next button" as long as information is missing
               }
            }
         }
         elsif (param('female_eartag_start') ne 'by_id') {                 # we increment earmark from a given start number
            if ($female_eartag_start > 99) { $female_eartag_start = 0; }   # limit to 2 digits
            $earmark = $female_eartag_start++;
         }
         else {                                                            # we want auto_id
            $earmark = 'id';
         }

         if (!defined(param('first'))) {
            # remember ear tag used per cage
            $ear_in_cage{param("cage_$mouse")}{param("earmark_$mouse")}++;

            if ($ear_in_cage{param("cage_$mouse")}{param("earmark_$mouse")} > 1) {
               $remark .= "same eartag in cage!";
            }
         }

         $page .= Tr({-bgcolor=>$sex_color->{'f'}},
                    td($mouse),
                    td({-style=>"color: #888888;"}, "to be assigned"),
                    td({-align=>"right"}, textfield(-class=>(($earmark eq '??')?'red':''), -name=>"earmark_$mouse", -size=>"2", -maxlength=>"4", -value=>$earmark, -override=>1) ),
                    td({-align=>"center"}, "f" . hidden(-name=>"sex_$mouse",  -value=>"f")),
                    td(format_display_datetime2display_date($litter_born_datetime)),
                    td($litter_line),
                    td($litter_strain),
                    td(get_colors_popup_menu($global_var_href, 1, "color_$mouse")),
                    td(textfield(-name=>"cage_$mouse", -size=>"6", -value=>( (defined(param("cage_$mouse")))
                                                                             ?param("cage_$mouse")
                                                                             :$cage
                                                                           )
                                )
                    ),
                    td($rack),
                    td(textfield(-name=>"comment_$mouse", -size=>"40")),
                    td($remark)
                  );
     }

     $page .= end_table()
              . p();

     # display rack selector table only if necessary
     if (scalar (keys %new_cage) > 0) {
        # determine default rack: take the rack where the litter's mother(s) cage is placed
        $sql = qq(select max(l2p_parent_id) as one_mother
                  from   litters2parents
                  where  l2p_litter_id       = ?
                         and l2p_parent_type = ?
                 );

        @sql_parameters = ($litter_id, 'mother');

        ($one_mother) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

        # if we can determine one mother, get her rack
        if (defined($one_mother) and $one_mother =~ /^[0-9]{8}$/) {
           $default_rack = get_cage_location($global_var_href, get_cage($global_var_href, $one_mother));
        }
        else {     # otherwise take first rack
           $default_rack = 1;
        }

        $page .= h3("choose racks for new female cages")
                 . start_table( {-border=>1, -cellpadding=>"2", -summary=>"table"})
                 . Tr(
                     th('cage'),
                     th('rack'),
                     th('info')
                   )
                 . Tr(
                     th('all cages'),
                     td(get_locations_popup_menu_for_weaning($global_var_href, $default_rack, 'female_selector', 'female_selector', 'female_rack_', 'yes')),
                     th('choose rack for all cages')
                   );

        foreach $cage (sort keys %new_cage) {
           $page .= Tr({-bgcolor=>$sex_color->{'f'}},
                      td($cage),
                      td(get_locations_popup_menu_for_weaning($global_var_href, $default_rack, 'rack_' . $cage, 'female_rack_' . $cage, 'female_rack_', 'no')),
                      td()
                    );
        }

        $page .= end_table();
     }

  }
  else {
     $page .= h3(" no female pups to wean ");
  }
  # females done
  #------------------------------------------------------------------

  $page .= p()
           . hidden(-name=>"step",   -value=>"wean_step_2", -override=>1)
           . p(submit(-name=>"choice", -value=>"update weaning preview", -title=>"update weaning preview")
              . "&nbsp;&nbsp;or&nbsp;&nbsp;"
              . a({-href=>"$url?choice=wean_litter_1&litter_id=" . $litter_id}, "go back")
             );

  # display "next button" only if we have all information to continue
  if ($hide_next_button == 0) {
     $page .= hr()
              . submit(-name=>"choice", -value=>"next step", -title=>"next step");
  }

  $page .= end_form();


  return $page;
}
# end of wean_litter_step_2
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_WEA003 wean_litter_step_3():                        wean litter (3. step: confirmation step)
sub wean_litter_step_3 {                                 my $sr_name = 'SR_WEA003';
  my ($global_var_href)       = @_;                              # get reference to global vars hash
  my $litter_id               = param('litter_id');
  my $litter_born_datetime    = param('litter_born_datetime');
  my $litter_line             = param('litter_line');
  my $litter_strain           = param('litter_strain');
  my $cost_centre             = param('cost_centre');
  my $litter_weaning_datetime = param('litter_weaning_datetime');
  my $number_of_males         = param('number_of_males');
  my $number_of_females       = param('number_of_females');
  my $weaning_type            = param('weaning_type');
  my $is_gvo                  = param('litter_is_gvo');
  my $url                     = url();
  my %new_cage                = ();
  my %cage_candidates         = ();
  my %ear_in_cage             = ();
  my $hide_next_button        = 0;
  my $sex_color = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my ($page, $sql, $result, $rows, $row, $i, $j);
  my ($mouse, $free_beds_in_cage);
  my ($earmark, $sex, $color, $cage, $comment, $rack, $remark);
  my ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, $cage_capacity, $location_room, $location_rack);
  my $female_eartag_warning = '';
  my $male_eartag_warning   = '';

  $page = h2("Weaning: 3. step")
          . hr();

  # check input: is litter id given? is it a number?
  if (!param('litter_id') || param('litter_id') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please provide a valid litter id"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('litter_born_datetime') || check_datetime_ddmmyyyy_hhmmss(param('litter_born_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of birth not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('litter_weaning_datetime') || check_datetime_ddmmyyyy_hhmmss(param('litter_weaning_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of birth not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is litter line given?
  if (!param('litter_line') || param('litter_line') eq '') {
     $litter_line = 'warning: problem with line!';
  }

  # check input: is litter strain given?
  if (!param('litter_strain') || param('litter_strain') eq '') {
     $litter_strain = 'warning: problem with strain!';
  }

  # check input: is cost centre given? is it a number?
  if (!param('cost_centre') || param('cost_centre') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please provide a valid cost centre"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('number_of_males') || param('number_of_males') !~ /^[0-9]+$/) {
     $number_of_males = 0;
  }

  if (!param('number_of_females') || param('number_of_females') !~ /^[0-9]+$/) {
     $number_of_females = 0;
  }

  if (defined(param('male_eartag_start')) && param('male_eartag_start') eq 'by_id') {
     $male_eartag_warning = p({-class=>'red'}, "Info: eartags for males will be set on last two digits of assigned mouse id");
  }

  if (defined(param('female_eartag_start')) && param('female_eartag_start') eq 'by_id') {
     $female_eartag_warning = p({-class=>'red'}, "Info: eartags for females will be set on last two digits of assigned mouse id");
  }

  # first table (litter details)
  $page .= h3("3. step: check and confirm ")
           . start_form(-action=>url(), -name=>"myform")
           . hidden(-name=>"litter_id")
           . hidden('litter_born_datetime') . hidden('litter_weaning_datetime') . hidden('number_of_males')   . hidden('number_of_females')
           . hidden('litter_is_gvo')        . hidden('litter_comment')          . hidden('litter_line')       . hidden('litter_strain')
           . hidden('weaning_type')         . hidden('cost_centre');

  #------------------------------------------------------------------
  # begin with males
  if ($number_of_males > 0) {

     $page .= h3("male pups")
              . $male_eartag_warning
              . start_table( {-border=>"1", -cellpadding=>"2", -summary=>"table"})
              . Tr(
                  th("#"),
                  th("mouse id"),
                  th("eartag"),
                  th("sex"),
                  th("born"),
                  th("line"),
                  th("strain"),
                  th("color"),
                  th("cage"),
                  th("rack"),
                  th("comment"),
                  th("remark")
                 );

     for ($mouse = 1; $mouse <= $number_of_males; $mouse++) {

         # read hidden fields from previous step
         $earmark = param("earmark_$mouse");
         $sex     = param("sex_$mouse");
         $color   = param("color_$mouse");
         $cage    = param("cage_$mouse");
         $comment = param("comment_$mouse");
         $rack    = param("rack_$cage");

         $remark  = '';

         # cage is given
         if ($cage =~ /^[0-9]+$/) {
            # get some cage info
            ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, $cage);
            # calculate free "beds" in this cage
            $free_beds_in_cage = $cage_capacity - $mice_in_cage;

            # keep track how many mice are to be placed in this cage
            $cage_candidates{$cage}++;

            # only if there is at least one "bed" left and it is a pure female cage, accept
            if (($free_beds_in_cage >= $cage_candidates{$cage}) && ($males_in_cage > 0) && ($females_in_cage == 0)) {
               (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, get_cage_location($global_var_href, $cage));
               $rack = $location_room . "-" . $location_rack;
            }
            elsif (($free_beds_in_cage < $cage_candidates{$cage}) && ($males_in_cage > 0) && ($females_in_cage == 0)) {
               $rack = span({-class=>"red"}, 'cannot use this cage, no space left! ' . a({-href=>"$url?choice=cage_view&cage_id=" . $cage, -target=>"_blank"}, "(see why)"));
               $hide_next_button++;                                        # hide "next button" as long as information is missing
            }
            else {
               $rack = span({-class=>"red"}, 'cannot use this cage! ' . a({-href=>"$url?choice=cage_view&cage_id=" . $cage, -target=>"_blank"}, "(see why)"));
               $hide_next_button++;                                        # hide "next button" as long as information is missing
            }
         }
         # new cages
         else {
            $new_cage{$cage}++;

            # make sure that also new cages are not filled with more than 5 mice or the defined cage limit
            # this check is neccessary for people who did not press "update" before "next step"
            if ($new_cage{$cage} > 5) {
               $rack = span({-class=>"red"}, "no more than 5 mice per cage!");
               $hide_next_button++;
            }
            else {
               # for display, get rack info from rack id
               (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, $rack);
               $rack = $location_room . "-" . $location_rack;
            }
         }

         # now check input
         if ($rack eq "0000-00") {
            $rack = span({-class=>"red"}, "rack not defined");
            $hide_next_button++;
         }

         # only accept 2 digit earmarks or auto_id
         unless ($earmark =~ /^[0-9]+$/ || $earmark eq 'id') {
            $earmark = span({-class=>"red"}, "earmark must be a given (number)");
            $hide_next_button++;
         }

         # remember ear tag used per cage
         $ear_in_cage{param("cage_$mouse")}{param("earmark_$mouse")}++;

         # place warning if same eartag used more than once in one cage
         if ($ear_in_cage{param("cage_$mouse")}{param("earmark_$mouse")} > 1) {
            $remark .= "same eartag in cage!";
         }

         $page .= Tr({-bgcolor=>$sex_color->{'m'}},
                    td($mouse),
                    td({-style=>"color: #888888;"}, "to be assigned"),
                    td({-align=>"right"},  "$earmark"),
                    td({-align=>"center"}, "$sex"),
                    td(format_display_datetime2display_date($litter_born_datetime)),
                    td($litter_line),
                    td($litter_strain),
                    td(get_color_name_by_id($global_var_href, $color)),
                    td($cage),
                    td($rack),
                    td($comment),
                    td($remark)
                  )
                  # re-write hidden fields from previous step
                  . hidden("earmark_$mouse") . hidden("sex_$mouse")     . hidden("color_$mouse")
                  . hidden("cage_$mouse")    . hidden("comment_$mouse");
                  ;
     }

     $page .= end_table()
              . p();

     # write racks for new cages as hidden fields
     if (scalar (keys %new_cage) > 0) {
        foreach $cage (sort keys %new_cage) {
           $page .= hidden(-name=>"rack_$cage", -value=>$new_cage{"rack_$cage"});
        }
     }
  }
  else {
     $page .= h3(" no male pups to wean ");
  }
  # males done
  #------------------------------------------------------------------

  # reset things
  %new_cage        = ();
  %cage_candidates = ();

  $page .= hr({-align=>"left", -width=>"50%"});

  #------------------------------------------------------------------
  # now the females
  if ($number_of_females > 0) {

     $page .= h3("female pups")
              . $female_eartag_warning
              . start_table( {-border=>"1", -cellpadding=>"2", -summary=>"table"})
              . Tr(
                  th("#"),
                  th("mouse id"),
                  th("eartag"),
                  th("sex"),
                  th("born"),
                  th("line"),
                  th("strain"),
                  th("color"),
                  th("cage"),
                  th("rack"),
                  th("comment"),
                  th("remark")
                 );

     for ($mouse = ($number_of_males + 1); $mouse <= ($number_of_males + $number_of_females); $mouse++) {

         # read hidden fields from previous step
         $earmark = param("earmark_$mouse");
         $sex     = param("sex_$mouse");
         $color   = param("color_$mouse");
         $cage    = param("cage_$mouse");
         $comment = param("comment_$mouse");
         $rack    = param("rack_$cage");

         $remark  = '';

         if ($cage =~ /^[0-9]+$/) {
            # get some cage info
            ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, $cage);
            # calculate free "beds" in this cage
            $free_beds_in_cage = $cage_capacity - $mice_in_cage;

            # keep track how many mice are to be placed in this cage
            $cage_candidates{$cage}++;

            # only if there is at least one "bed" left and it is a pure female cage, accept
            if (($free_beds_in_cage >= $cage_candidates{$cage}) && ($females_in_cage > 0) && ($males_in_cage == 0)) {
               (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, get_cage_location($global_var_href, $cage));
               $rack = $location_room . "-" . $location_rack;
            }
            elsif (($free_beds_in_cage < $cage_candidates{$cage}) && ($females_in_cage > 0) && ($males_in_cage == 0)) {
               $rack = span({-class=>"red"}, 'cannot use this cage, no space left! ' . a({-href=>"$url?choice=cage_view&cage_id=" . $cage, -target=>"_blank"}, "(see why)"));
               $hide_next_button++;                                        # hide "next button" as long as information is missing
            }
            else {
               $rack = span({-class=>"red"}, 'cannot use this cage! ' . a({-href=>"$url?choice=cage_view&cage_id=" . $cage, -target=>"_blank"}, "(see why)"));
               $hide_next_button++;                                        # hide "next button" as long as information is missing
            }
         }
         # new cages
         else {
            $new_cage{$cage}++;

            # make sure that also new cages are not filled with more than 5 mice or the defined cage limit
            # this check is neccessary for people who did not press "update" before "next step"
            if ($new_cage{$cage} > 5) {
               $rack = span({-class=>"red"}, "no more than 5 mice per cage!");
               $hide_next_button++;
            }
            else {
               # for display, get rack info from rack id
               (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, $rack);
               $rack = $location_room . "-" . $location_rack;
            }
         }

         # now check input
         if ($rack eq "0000-00") {
            $rack = span({-class=>"red"}, "rack not defined");
            $hide_next_button++;
         }

         # only accept 2 digit earmarks
         unless ($earmark =~ /^[0-9]+$/ || $earmark eq 'id') {
            $earmark = span({-class=>"red"}, "earmark must be a given (number)");
            $hide_next_button++;
         }

         # remember ear tag used per cage
         $ear_in_cage{param("cage_$mouse")}{param("earmark_$mouse")}++;

         # place warning if same eartag used more than once in one cage
         if ($ear_in_cage{param("cage_$mouse")}{param("earmark_$mouse")} > 1) {
            $remark .= "same eartag in cage!";
         }

         $page .= Tr({-bgcolor=>$sex_color->{'f'}},
                    td($mouse),
                    td({-style=>"color: #888888;"}, "to be assigned"),
                    td({-align=>"right"},  "$earmark"),
                    td({-align=>"center"}, "$sex"),
                    td(format_display_datetime2display_date($litter_born_datetime)),
                    td($litter_line),
                    td($litter_strain),
                    td(get_color_name_by_id($global_var_href, $color)),
                    td($cage),
                    td($rack),
                    td($comment),
                    td($remark)
                  )
                  # re-write hidden fields from previous step
                  . hidden("earmark_$mouse") . hidden("sex_$mouse")     . hidden("color_$mouse")
                  . hidden("cage_$mouse")    . hidden("comment_$mouse") #. hidden(-name=>"rack_$mouse", -value=>param("rack_$cage"))
                  ;
     }

     $page .= end_table()
              . p();

     # write racks for new cages as hidden fields
     if (scalar (keys %new_cage) > 0) {
        foreach $cage (sort keys %new_cage) {
           $page .= hidden(-name=>"rack_$cage", -value=>$new_cage{"rack_$cage"});
        }
     }
  }
  else {
     $page .= h3(" no female pups to wean ");
  }
  # females done
  #------------------------------------------------------------------

  $page .= p()
           . hidden(-name=>"step",   -value=>"wean_step_3");

  # display "next button" only if we have all information to continue
  if ($hide_next_button == 0) {
     $page .= hr()
              . h3("Please check weaning data carefully!")
              . p("If anything is wrong in the tables above, go back to the previous step and make your changes")
              . p(submit(-name=>"choice", -value=>"wean!", -title=>"do the weaning")
                  . "&nbsp;&nbsp;or&nbsp;&nbsp;"
                  . a({-href=>"javascript:back()"}, "go back")
                );
  }
  else {
     $page .= hr()
              . h3("There are still wrong or missing data!")
              . p("Please go back to the previous step and make your changes")
              . p(a({-href=>"javascript:back()"}, "go back"));
  }

  $page .= end_form();

  return $page;
}
# end of wean_litter_step_3
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_WEA004 wean_litter_step_4():                        wean litter (4. step: database transaction)
sub wean_litter_step_4 {                                 my $sr_name = 'SR_WEA004';
  my ($global_var_href)       = @_;                                      # get reference to global vars hash
  my $dbh                     = $global_var_href->{'dbh'};               # DBI database handle
  my $start_mouse_id          = $global_var_href->{'start_mouse_id'};    # mouse ID to start with if very first mouse in DB
  my $litter_id               = param('litter_id');
  my $litter_born_datetime    = param('litter_born_datetime');
  my $litter_weaning_datetime = param('litter_weaning_datetime');
  my $number_of_males         = param('number_of_males');
  my $number_of_females       = param('number_of_females');
  my $weaning_type            = param('weaning_type');
  my $is_gvo                  = param('litter_is_gvo');
  my $cost_centre             = param('cost_centre');
  my $url                     = url();
  my %new_cage                = ();
  my %cage_candidates         = ();
  my %all_cages               = ();
  my $hide_next_button        = 0;
  my $datetime_sql            = get_current_datetime_for_sql();
  my $session                 = $global_var_href->{'session'};   # session handle
  my $move_user_id            = $session->param('user_id');
  my $weaning_remark          = '';
  my ($strain, $line, $generation);
  my $litter_weaning_datetime_sql;
  my $sex_color = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my ($page, $sql, $result, $rows, $row, $i, $j, $rc);
  my ($mouse, $mouse_id, $free_beds_in_cage, $litter_count, $mouse_done, $cage_done, $number_of_cages);
  my ($earmark, $sex, $color, $cage, $comment, $rack, $short_comment, $print_cage);
  my ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, $cage_capacity, $location_room, $location_rack, $rack_capacity);
  my @weaned_mice;
  my @sql_parameters;
  my $weaning_type_insert   = 'weaning';               # default is 'weaning' (in contrast to 'weaning_external')

  $page = h2("Weaning: 4. step ")
          . hr();

  # check input: is litter id given? is it a number?
  if (!param('litter_id') || param('litter_id') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please provide a valid litter id"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is cost centre given? is it a number?
  if (!param('cost_centre') || param('cost_centre') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please provide a valid cost centre"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('litter_born_datetime') || check_datetime_ddmmyyyy_hhmmss(param('litter_born_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of birth not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('litter_weaning_datetime') || check_datetime_ddmmyyyy_hhmmss(param('litter_weaning_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of birth not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  $litter_weaning_datetime_sql = format_display_datetime2sql_datetime($litter_weaning_datetime);

  if (!param('number_of_males') || param('number_of_males') !~ /^[0-9]+$/) {
     $number_of_males = 0;
  }

  if (!param('number_of_females') || param('number_of_females') !~ /^[0-9]+$/) {
     $number_of_females = 0;
  }

  if ($weaning_type eq 'regular') {
     $weaning_type_insert = 'weaning';
  }
  else {
     $weaning_type_insert = 'weaning_external';
  }


  # first table (litter details)
  $page .= h3("4. step: wean ")
           . start_form(-action=>url(), -name=>"myform");

  # first check if this litter is already weaned (prevent user from pressing browser reload button)
  $sql = qq(select count(*) as litter_count
            from   mice
            where  mouse_litter_id = ?
           );

  @sql_parameters = ($litter_id);

  ($litter_count) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if ($litter_count > 0) {
     $page .= p({-class=>"red"}, b("Error: this litter is already weaned (did you press \"Reload\"?)"))
              . p("Click " . a({-href=>"$url?choice=litter_view&litter_id=" . $litter_id}, " here ") . " to see weaned pups from this litter. ")
              . end_form();
     return $page;
  }

  # now get some additional weaning data from parent mating
  $sql = qq(select mating_strain, mating_line, mating_generation
            from   matings
                   join litters on litter_mating_id = mating_id
            where  litter_id = ?
           );

  @sql_parameters = ($litter_id);

  ($strain, $line, $generation) =  @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};


  # try to get a lock
  &get_semaphore_lock($global_var_href, $move_user_id);

  ############################################################################################
  # begin transaction
  $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start weaning transaction)", $sr_name . "-" . __LINE__);

  # first check again if this litter is already weaned
  $sql = qq(select count(*) as litter_count
            from   mice
            where  mouse_litter_id = ?
           );

  @sql_parameters = ($litter_id);

  ($litter_count) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if ($litter_count > 0) {
     $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back cage move transaction)", $sr_name . "-" . __LINE__);

     &release_semaphore_lock($global_var_href, $move_user_id);
     $page .= p({-class=>'red'}, "weaning cancelled: litter already weaned (" . a({-href=>"$url?choice=litter_view&litter_id=" . $litter_id}, " see litter ") . ')');
     return ($page);
  }

  #------------------------------------------------------------------
  # begin with males
  if ($number_of_males > 0) {

     $page .= h3("male pups")
              . start_table( {-border=>"1", -cellpadding=>"2", -summary=>"table"})
              . Tr(
                  th("#"),
                  th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
                  th("mouse ID"),
                  th("ear"),
                  th("sex"),
                  th("color"),
                  th("born"),
                  th("age"),
                  th("strain"),
                  th("line"),
                  th("room/rack"),
                  th("cage"),
                  th("comment (shortened)"),
                  th("weaning remark")
                );

     for ($mouse = 1; $mouse <= $number_of_males; $mouse++) {
         # reset weaning_remark
         $weaning_remark = "ok";

         # read hidden fields from previous step
         $earmark = param("earmark_$mouse");
         $sex     = param("sex_$mouse");
         $color   = param("color_$mouse");
         $cage    = param("cage_$mouse");
         $comment = param("comment_$mouse");
         $rack    = param("rack_$cage");

         # get a new mouse id
         $sql = qq(select (max(mouse_id)+1) as new_mouse_id
                   from   mice
                  );

         @sql_parameters = ();

         ($mouse_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

         if (!defined($mouse_id)) { $mouse_id = $start_mouse_id; }

         push(@weaned_mice, $mouse_id);          # remember mouse_ids for log

         # user wants earmark to be last two digits of mouse_id
         if ($earmark eq 'id') {
            if ($mouse_id =~ /^[0-9]{6}([0-9]{2})$/) {        # grab last two digits of mouse_id => earmark
               $earmark = $1;
            }
         }

         # insert mouse
         $sql = qq(insert
                   into   mice (mouse_id, mouse_earmark, mouse_origin_type, mouse_litter_id, mouse_import_id, mouse_import_litter_group, mouse_sex,
                                mouse_strain, mouse_line, mouse_generation, mouse_batch, mouse_coat_color, mouse_birth_datetime,
                                mouse_deathorexport_datetime, mouse_deathorexport_how, mouse_deathorexport_why,
                                mouse_deathorexport_contact, mouse_deathorexport_location, mouse_is_gvo, mouse_comment)
                   values (?, ?, ?, ?, ?, NULL, ?, ?, ?, ?, ?, ?, ?, NULL, ?, ?, NULL, NULL, ?, ?)
                );

         $dbh->do($sql, undef,
                  $mouse_id,  $earmark, $weaning_type_insert, $litter_id, 0, $sex,
                  $strain, $line, $generation, '', $color, format_display_datetime2sql_datetime($litter_born_datetime),
                  1, 2, $is_gvo, $comment
                 ) or &error_message_and_exit($global_var_href, "please wait a few seconds, then go back and try again", '');


         # check if mouse has been generated
         $sql = qq(select count(mouse_id)
                   from   mice
                   where  mouse_id = ?
                  );

          @sql_parameters = ($mouse_id);

         ($mouse_done) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};


         # no: -> rollback and exit
         if ($mouse_done != 1) {
            $rc    = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (something went wrong, but rollback failed)", $sr_name . "-" . __LINE__);

            &release_semaphore_lock($global_var_href, $move_user_id);
            $page .= p({-class=>"red"}, "Something went wrong when trying to wean a mouse (could not insert new mouse).");
            return $page;
         }

         # mouse created, now we need to put the mouse in a cage and the cage in a rack
         # first case: we put the mouse in an existing cage (=> $cage is a pure number)
         if ($cage =~ /^[0-9]+$/) {
            # get some cage info (at date/time of weaning)
            ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, $cage, $litter_weaning_datetime_sql);

            # calculate free "beds" in this cage (at date/time of weaning)
            $free_beds_in_cage = $cage_capacity - $mice_in_cage;

            # is/was given cage in use at all? (-> does it contain > 1 mice?)
            if ($mice_in_cage == 0) {
               $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back)", $sr_name . "-" . __LINE__);

               &release_semaphore_lock($global_var_href, $move_user_id);

               $page = h2("Weaning: 4. step")
                       . hr()
                       . h3({-class=>"red"}, "Weaning not possible")
                       . p({-class=>"red"}, "Given target cage (" . $cage .  ") not in use at weaning time") . hr()
                       . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another cage selection");

               return ($page);
            }

            # check if in given cage, there was at least one place left between datetime of import and *now*
            if (was_there_a_place_for_this_mouse_between_datetime_of_move_and_now($global_var_href, $cage,
                                                                                                    $litter_weaning_datetime_sql,
                                                                                                    $datetime_sql) eq 'no') {
               $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back)", $sr_name . "-" . __LINE__);

               &release_semaphore_lock($global_var_href, $move_user_id);

               $page = h2("Weaning: 4. step")
                       . hr()
                       . h3({-class=>"red"}, "Weaning not possible")
                       . p({-class=>"red"}, "during given time and now there was no place left in target cage at some time point") . hr()
                       . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another cage selection");

               return $page;
            }

            # only if there is at least one "bed" left and it is a cage of matching sex, accept
            elsif (($free_beds_in_cage >= 0)
                 &&
                 ( (($sex eq 'm') && ($males_in_cage > 0)   && ($females_in_cage == 0))
                      ||
                   (($sex eq 'f') && ($females_in_cage > 0) && ($males_in_cage == 0))
                 )
            )  {
               # all fine, do nothing
            }

            # whatever goes wrong, place mouse into a new cage on its own and place this cage in the virtual rack (there is always plenty of space left)
            else {
                # notify user about placing mouse in extra cage in virtual rack
                $weaning_remark = span({-class=>"red"}, "cage being occupied in the meanwhile, mouse placed in separate cage in virtual rack");

                # get the next free cage for the weaning
                $cage = give_me_a_cage($global_var_href, $litter_weaning_datetime_sql);

                # if no free cages left (at given datetime): rollback and exit
                if (!defined($cage)) {
                   $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back)", $sr_name . "-" . __LINE__);

                   &release_semaphore_lock($global_var_href, $move_user_id);

                   $page .= p({-class=>"red"}, "weaning cancelled: no free cage found at given date/time of move (more recent or current move date/time will work more likely)");
                   return $page;
                }

                # mark new cage as occupied
                $dbh->do("update  cages
                          set     cage_occupied = ?, cage_cardcolor = ?
                          where   cage_id = ?
                         ", undef, "y", 7, $cage
                        ) or &error_message_and_exit($global_var_href, "SQL error (could not set new cage to occupied)", $sr_name . "-" . __LINE__);

                # insert the new cage into virtual rack
                $dbh->do("insert
                          into    cages2locations (c2l_cage_id, c2l_location_id, c2l_datetime_from, c2l_datetime_to, c2l_move_user_id, c2l_move_datetime)
                          values  (?, ?, ?, NULL, ?, ?)
                         ", undef, $cage, 0, $litter_weaning_datetime_sql, $move_user_id, $datetime_sql
                        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new cage into virtual rack)", $sr_name . "-" . __LINE__);
            }

            # keep track of all cages used in this weaning (to offer "print cage card" link for all those cages at the end)
            $all_cages{$cage}++;

            # in any case, place mouse in a) given and existing cage or b) new cage in virtual rack
            $dbh->do("insert
                      into    mice2cages (m2c_mouse_id, m2c_cage_id, m2c_cage_of_this_mouse, m2c_datetime_from, m2c_datetime_to, m2c_move_user_id, m2c_move_datetime)
                      values  (?, ?, ?, ?, NULL, ?, ?)
                     ", undef, $mouse_id, $cage, 1, $litter_weaning_datetime_sql, $move_user_id, $datetime_sql
                    ) or &error_message_and_exit($global_var_href, "SQL error (could not insert mouse into cage)", $sr_name . "-" . __LINE__);
         }

         # second case: we put the mouse into a new cage
         else {
           # check if a new cage named $cage was already used (look up %new_cage)
           unless (defined($new_cage{$cage})) {
              # get the next free cage for the weaning
              $new_cage{$cage} = give_me_a_cage($global_var_href, $litter_weaning_datetime_sql);

              # if no free cages left (at given datetime): rollback and exit
              if (!defined($cage)) {
                 $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back)", $sr_name . "-" . __LINE__);

                 &release_semaphore_lock($global_var_href, $move_user_id);
                 $page .= p({-class=>"red"}, "weaning cancelled: no free cage found at given date/time of move (more recent or current move date/time will work more likely)");
                 return $page;
              }

              # mark new cage as occupied
              $dbh->do("update  cages
                        set     cage_occupied = ?, cage_cardcolor = ?
                        where   cage_id = ?
                       ", undef, "y", 7, $new_cage{$cage}
                      ) or &error_message_and_exit($global_var_href, "SQL error (could not set new cage to occupied)", $sr_name . "-" . __LINE__);
           }

           # keep track of all cages used in this weaning (to offer "print cage card" link for all those cages at the end)
           $all_cages{$new_cage{$cage}}++;

           # in any case, place mouse in a) given and existing cage or b) new cage in virtual rack
           $dbh->do("insert
                     into    mice2cages (m2c_mouse_id, m2c_cage_id, m2c_cage_of_this_mouse, m2c_datetime_from, m2c_datetime_to, m2c_move_user_id, m2c_move_datetime)
                     values  (?, ?, ?, ?, NULL, ?, ?)
                    ", undef, $mouse_id, $new_cage{$cage}, 1, $litter_weaning_datetime_sql, $move_user_id, $datetime_sql
                   ) or &error_message_and_exit($global_var_href, "SQL error (could not insert mouse into cage)", $sr_name . "-" . __LINE__);


           # look up free slots in given $rack
           $number_of_cages = get_cages_in_location($global_var_href, $rack);

           $sql = qq(select location_capacity
                     from   locations
                     where  location_id = ?
                  );

           @sql_parameters = ($rack);

           ($rack_capacity) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};


           # if no free slots: place $cage in virtual rack
           if (($rack_capacity - $number_of_cages) < 1) {
              # before setting rack to virtual rack, check if cage already is in a normal rack
              ($cage_done) = $dbh->selectrow_array("select count(c2l_cage_id) as number_of_cages
                                                    from   cages2locations
                                                    where            c2l_cage_id = $new_cage{$cage}
                                                           and   c2l_location_id = $rack
                                                           and c2l_datetime_from = '$litter_weaning_datetime_sql'
                                                   ");

              # only set a cage into the virtual rack, if this cage is not already placed in another rack
              if ($cage_done == 0) {
                 # notify user about placing mouse in extra cage in virtual rack
                 $weaning_remark = span({-class=>"red"}, "rack being occupied in the meanwhile, cage placed in virtual rack");

                 $rack = 0;               # id of virtual rack
              }

           }

           # check if cage already created
           $sql = qq(select count(c2l_cage_id) as number_of_cages
                     from   cages2locations
                     where            c2l_cage_id = ?
                            and   c2l_location_id = ?
                            and c2l_datetime_from = ?
                  );

           @sql_parameters = ($new_cage{$cage}, $rack, $litter_weaning_datetime_sql);

           ($cage_done) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

           # add this cage to rack only once
           unless ($cage_done > 0) {
              # insert the new cage into a) given rack or b) virtual rack
              $dbh->do("insert
                        into    cages2locations (c2l_cage_id, c2l_location_id, c2l_datetime_from, c2l_datetime_to, c2l_move_user_id, c2l_move_datetime)
                        values  (?, ?, ?, NULL, ?, ?)
                       ", undef, $new_cage{$cage}, $rack, $litter_weaning_datetime_sql, $move_user_id, $datetime_sql
                      ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new cage into virtual rack)", $sr_name . "-" . __LINE__);
           }
         }

         # add the mouse to a cost centre
         $dbh->do("insert
                   into   mice2cost_accounts (m2ca_cost_account_id, m2ca_mouse_id, m2ca_datetime_from, m2ca_datetime_to)
                   values (?, ?, ?, NULL)
                  ", undef, $cost_centre, $mouse_id, $litter_weaning_datetime_sql
               ) or &error_message_and_exit($global_var_href, "SQL error (could not insert cost centre of mouse)", $sr_name . "-" . __LINE__);


         # mouse has been generated. Now select info for display
         $sql = qq(select mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment, mouse_coat_color,
                          mouse_birth_datetime, location_room, location_rack, cage_id, mouse_deathorexport_datetime,
                          dr1.death_reason_name as how, dr2.death_reason_name as why
                   from   mice
                          join mouse_strains      on             mouse_strain = strain_id
                          join mouse_lines        on               mouse_line = line_id
                          join mice2cages         on                 mouse_id = m2c_mouse_id
                          join cages2locations    on              m2c_cage_id = c2l_cage_id
                          join locations          on              location_id = c2l_location_id
                          join cages              on                  cage_id = c2l_cage_id
                          join death_reasons dr1  on  mouse_deathorexport_how = dr1.death_reason_id
                          join death_reasons dr2  on  mouse_deathorexport_why = dr2.death_reason_id
                   where  mouse_id = ?
                          and m2c_datetime_to IS NULL
                          and c2l_datetime_to IS NULL
                  );

         @sql_parameters = ($mouse_id);

         ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

         $row = $result->[0];         # read first (and hopefully only) set of results

         # shorten comment
         if ($row->{'mouse_comment'} =~ /(^.{20})/) {
            $short_comment = $1 . ' ...';
         }
         else {
            $short_comment = $row->{'mouse_comment'};
         }

         # remove quoting marks
         $short_comment =~ s/^'//g; $short_comment =~ s/'$//g;

         $page .= Tr({-bgcolor=>$sex_color->{'m'}},
                    td($mouse),
                    td(checkbox('mouse_select', '0', $mouse_id, '')),
                    td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse_id, -title=>"click for mouse details"}, &reformat_number($mouse_id, 8))),
                    td($row->{'mouse_earmark'}),
                    td($row->{'mouse_sex'}),
                    td(get_color_name_by_id($global_var_href, $row->{'mouse_coat_color'})),
                    td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                    td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                    td($row->{'strain_name'}),
                    td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                    td($row->{'location_room'} . '-' . $row->{'location_rack'}),
                    td(a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"}, $row->{'cage_id'})),
                    td({-align=>'left'}, $short_comment),
                    td($weaning_remark)
                  );
     }

     $page .= end_table()
              . p();

  }
  else {
     $page .= h3(" no male pups to wean ");
  }
  # males done
  #------------------------------------------------------------------

  # reset things
  %new_cage        = ();
  %cage_candidates = ();

  $page .= hr({-align=>"left", -width=>"50%"});

  #------------------------------------------------------------------
  # now the females
 if ($number_of_females > 0) {

     $page .= h3("female pups")
              . start_table( {-border=>"1", -cellpadding=>"2", -summary=>"table"})
              . Tr(
                  th("#"),
                  th(checkbox(-name=>"checkall2", -label=>"", -onClick=>"checkAll2(document.myform)", -title=>"select/unselect all")),
                  th("mouse ID"),
                  th("ear"),
                  th("sex"),
                  th("color"),
                  th("born"),
                  th("age"),
                  th("strain"),
                  th("line"),
                  th("room/rack"),
                  th("cage"),
                  th("comment (shortened)"),
                  th("weaning remark")
                );

     for ($mouse = ($number_of_males + 1); $mouse <= ($number_of_females + $number_of_males); $mouse++) {
         # reset weaning_remark
         $weaning_remark = "ok";

         # read hidden fields from previous step
         $earmark = param("earmark_$mouse");
         $sex     = param("sex_$mouse");
         $color   = param("color_$mouse");
         $cage    = param("cage_$mouse");
         $comment = param("comment_$mouse");
         $rack    = param("rack_$cage");

         # get a new mouse id
         $sql = qq(select (max(mouse_id)+1) as new_mouse_id
                   from   mice
                  );

         @sql_parameters = ();

         ($mouse_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

         if (!defined($mouse_id)) { $mouse_id = $start_mouse_id; }

         push(@weaned_mice, $mouse_id);          # remember mouse_ids for log

         # user wants earmark to be last two digits of mouse_id
         if ($earmark eq 'id') {
            if ($mouse_id =~ /^[0-9]{6}([0-9]{2})$/) {        # grab last two digits of mouse_id => earmark
               $earmark = $1;
            }
         }

         # insert mouse
         $sql = qq(insert
                   into   mice (mouse_id, mouse_earmark, mouse_origin_type, mouse_litter_id, mouse_import_id, mouse_import_litter_group, mouse_sex,
                                mouse_strain, mouse_line, mouse_generation, mouse_batch, mouse_coat_color, mouse_birth_datetime,
                                mouse_deathorexport_datetime, mouse_deathorexport_how, mouse_deathorexport_why,
                                mouse_deathorexport_contact, mouse_deathorexport_location, mouse_is_gvo, mouse_comment)
                   values (?, ?, ?, ?, ?, NULL, ?, ?, ?, ?, ?, ?, ?, NULL, ?, ?, NULL, NULL, ?, ?)
                );

         $dbh->do($sql, undef,
                  $mouse_id,  $earmark, $weaning_type_insert, $litter_id, 0, $sex,
                  $strain, $line, $generation, '', $color, format_display_datetime2sql_datetime($litter_born_datetime),
                  1, 2, $is_gvo, $comment
                 ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new mouse)", $sr_name . "-" . __LINE__);


         # check if mouse has been generated
         $sql = qq(select count(mouse_id)
                   from   mice
                   where  mouse_id = ?
                  );

         @sql_parameters = ($mouse_id);

         ($mouse_done) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

         # no: -> rollback and exit
         if ($mouse_done != 1) {
            $rc    = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (something went wrong, but rollback failed)", $sr_name . "-" . __LINE__);

            &release_semaphore_lock($global_var_href, $move_user_id);
            $page .= p({-class=>"red"}, "Something went wrong when trying to wean.");
            return $page;
         }

         # mouse created, now we need to put the mouse in a cage and the cage in a rack
         # first case: we put the mouse in an existing cage (=> $cage is a pure number)
         if ($cage =~ /^[0-9]+$/) {
            # get some cage info (at given weaning datetime)
            ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, $cage, $litter_weaning_datetime_sql);

            # calculate free "beds" in this cage (at given weaning datetime)
            $free_beds_in_cage = $cage_capacity - $mice_in_cage;

            # is/was given cage in use at all? (-> does it contain > 1 mice?)
            if ($mice_in_cage == 0) {
               $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back)", $sr_name . "-" . __LINE__);

               &release_semaphore_lock($global_var_href, $move_user_id);
               $page .= p({-class=>'red'}, "weaning cancelled: given target cage (" . $cage .  ") not in use at import time");
               return ($page);
            }

            # check if in given cage, there was at least one place left between datetime of import and *now*
            if (was_there_a_place_for_this_mouse_between_datetime_of_move_and_now($global_var_href, $cage,
                                                                                                    $litter_weaning_datetime_sql,
                                                                                                    $datetime_sql) eq 'no') {
               $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back)", $sr_name . "-" . __LINE__);

               &release_semaphore_lock($global_var_href, $move_user_id);

               $page .= p({-class=>"red"}, "could not place mouse into given cage (during given time and now there was no place left in target cage at some time point)");
               return $page;
            }

            # only if there is at least one "bed" left and it is a cage of matching sex, accept
            elsif (($free_beds_in_cage >= 0)
                 &&
                 ( (($sex eq 'm') && ($males_in_cage > 0)   && ($females_in_cage == 0))
                      ||
                   (($sex eq 'f') && ($females_in_cage > 0) && ($males_in_cage == 0))
                 )
            )  {
               # all fine, do nothing
            }

            # whatever goes wrong, place mouse into a new cage on its own and place this cage in the virtual rack (there is always plenty of space left)
            else {
               # notify user about placing mouse in extra cage in virtual rack
               $weaning_remark = span({-class=>"red"}, "cage being occupied in the meanwhile, mouse placed in separate cage in virtual rack");

               # get the next free cage for the weaning
               $cage = give_me_a_cage($global_var_href, $litter_weaning_datetime_sql);

               # if no free cages left (at given datetime): rollback and exit
               if (!defined($cage)) {
                  $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back)", $sr_name . "-" . __LINE__);
                  &release_semaphore_lock($global_var_href, $move_user_id);

                  $page .= p({-class=>"red"}, "weaning cancelled: no free cage found at given date/time of move (more recent or current move date/time will work more likely)");
                  return $page;
               }

               # mark new cage as occupied
               $dbh->do("update  cages
                         set     cage_occupied = ?, cage_cardcolor = ?
                         where   cage_id = ?
                        ", undef, "y", 7, $cage
                       ) or &error_message_and_exit($global_var_href, "SQL error (could not set new cage to occupied)", $sr_name . "-" . __LINE__);

               # insert the new cage into virtual rack
               $dbh->do("insert
                         into    cages2locations (c2l_cage_id, c2l_location_id, c2l_datetime_from, c2l_datetime_to, c2l_move_user_id, c2l_move_datetime)
                         values  (?, ?, ?, NULL, ?, ?)
                        ", undef, $cage, 0, $litter_weaning_datetime_sql, $move_user_id, $datetime_sql
                       ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new cage into virtual rack)", $sr_name . "-" . __LINE__);

            }

            # keep track of all cages used in this weaning (to offer "print cage card" link for all those cages at the end)
            $all_cages{$cage}++;

            # in any case, place mouse in a) given and existing cage or b) new cage in virtual rack
            $dbh->do("insert
                      into    mice2cages (m2c_mouse_id, m2c_cage_id, m2c_cage_of_this_mouse, m2c_datetime_from, m2c_datetime_to, m2c_move_user_id, m2c_move_datetime)
                      values  (?, ?, ?, ?, NULL, ?, ?)
                     ", undef, $mouse_id, $cage, 1, $litter_weaning_datetime_sql, $move_user_id, $datetime_sql
                    ) or &error_message_and_exit($global_var_href, "SQL error (could not insert mouse into cage)", $sr_name . "-" . __LINE__);
         }

         # second case: we put the mouse into a new cage
         else {
           # check if a new cage named $cage was already used (look up %new_cage)
           unless (defined($new_cage{$cage})) {
              # get the next free cage for the weaning
              $new_cage{$cage} = give_me_a_cage($global_var_href, $litter_weaning_datetime_sql);

              # if no free cages left (at given datetime): rollback and exit
              if (!defined($cage)) {
                 $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back)", $sr_name . "-" . __LINE__);

                 &release_semaphore_lock($global_var_href, $move_user_id);
                 $page .= p({-class=>"red"}, "weaning cancelled: no free cage found at given date/time of move (more recent or current move date/time will work more likely)");
                 return $page;
              }

              # mark new cage as occupied
              $dbh->do("update  cages
                        set     cage_occupied = ?, cage_cardcolor = ?
                        where   cage_id = ?
                       ", undef, "y", 7, $new_cage{$cage}
                      ) or &error_message_and_exit($global_var_href, "SQL error (could not set new cage to occupied)", $sr_name . "-" . __LINE__);
           }

           # keep track of all cages used in this weaning (to offer "print cage card" link for all those cages at the end)
           $all_cages{$new_cage{$cage}}++;

           # in any case, place mouse in a) given and existing cage or b) new cage in virtual rack
           $dbh->do("insert
                     into    mice2cages (m2c_mouse_id, m2c_cage_id, m2c_cage_of_this_mouse, m2c_datetime_from, m2c_datetime_to, m2c_move_user_id, m2c_move_datetime)
                     values  (?, ?, ?, ?, NULL, ?, ?)
                    ", undef, $mouse_id, $new_cage{$cage}, 1, $litter_weaning_datetime_sql, $move_user_id, $datetime_sql
                   ) or &error_message_and_exit($global_var_href, "SQL error (could not insert mouse into cage)", $sr_name . "-" . __LINE__);


           # look up free slots in given $rack
           $number_of_cages = get_cages_in_location($global_var_href, $rack);

           $sql = qq(select location_capacity
                     from   locations
                     where  location_id = ?
                  );

           @sql_parameters = ($rack);

           ($rack_capacity) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

           # if no free slots: place $cage in virtual rack
           if (($rack_capacity - $number_of_cages) < 1) {
              # before setting rack to virtual rack, check if cage already is in a normal rack
              ($cage_done) = $dbh->selectrow_array("select count(c2l_cage_id) as number_of_cages
                                                    from   cages2locations
                                                    where            c2l_cage_id = $new_cage{$cage}
                                                           and   c2l_location_id = $rack
                                                           and c2l_datetime_from = '$litter_weaning_datetime_sql'
                                                   ");

              # only set a cage into the virtual rack, if this cage is not already placed in another rack
              if ($cage_done == 0) {
                 # notify user about placing mouse in extra cage in virtual rack
                 $weaning_remark = span({-class=>"red"}, "rack being occupied in the meanwhile, cage placed in virtual rack");

                 $rack = 0;               # id of virtual rack
              }

           }

           $sql = qq(select count(c2l_cage_id) as number_of_cages
                     from   cages2locations
                     where            c2l_cage_id = ?
                            and   c2l_location_id = ?
                            and c2l_datetime_from = ?
                  );

           @sql_parameters = ($new_cage{$cage}, $rack, $litter_weaning_datetime_sql);

           ($cage_done) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};


           # add this cage to rack only once
           unless ($cage_done > 0) {
              # insert the new cage into a) given rack or b) virtual rack
              $dbh->do("insert
                        into    cages2locations (c2l_cage_id, c2l_location_id, c2l_datetime_from, c2l_datetime_to, c2l_move_user_id, c2l_move_datetime)
                        values  (?, ?, ?, NULL, ?, ?)
                       ", undef, $new_cage{$cage}, $rack, $litter_weaning_datetime_sql, $move_user_id, $datetime_sql
                      ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new cage into virtual rack)", $sr_name . "-" . __LINE__);
           }
         }

         # add the mouse to a cost centre
         $dbh->do("insert
                   into   mice2cost_accounts (m2ca_cost_account_id, m2ca_mouse_id, m2ca_datetime_from, m2ca_datetime_to)
                   values (?, ?, ?, NULL)
                  ", undef, $cost_centre, $mouse_id, $litter_weaning_datetime_sql
               ) or &error_message_and_exit($global_var_href, "SQL error (could not insert cost centre of mouse)", $sr_name . "-" . __LINE__);


         # mouse has been generated. Now select info for display
         $sql = qq(select mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment, mouse_coat_color,
                          mouse_birth_datetime, location_room, location_rack, cage_id, mouse_deathorexport_datetime,
                          dr1.death_reason_name as how, dr2.death_reason_name as why
                   from   mice
                          join mouse_strains      on             mouse_strain = strain_id
                          join mouse_lines        on               mouse_line = line_id
                          join mice2cages         on                 mouse_id = m2c_mouse_id
                          join cages2locations    on              m2c_cage_id = c2l_cage_id
                          join locations          on              location_id = c2l_location_id
                          join cages              on                  cage_id = c2l_cage_id
                          join death_reasons dr1  on  mouse_deathorexport_how = dr1.death_reason_id
                          join death_reasons dr2  on  mouse_deathorexport_why = dr2.death_reason_id
                   where  mouse_id = ?
                          and m2c_datetime_to IS NULL
                          and c2l_datetime_to IS NULL
                  );

         @sql_parameters = ($mouse_id);

         ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

         $row = $result->[0];         # read first (and hopefully only) set of results

         # shorten comment
         if ($row->{'mouse_comment'} =~ /(^.{20})/) {
            $short_comment = $1 . ' ...';
         }
         else {
            $short_comment = $row->{'mouse_comment'};
         }

         # remove quoting marks
         $short_comment =~ s/^'//g; $short_comment =~ s/'$//g;

         $page .= Tr({-bgcolor=>$sex_color->{'f'}},
                    td($mouse),
                    td(checkbox('mouse_select', '0', $mouse_id, '')),
                    td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse_id, -title=>"click for mouse details"}, &reformat_number($mouse_id, 8))),
                    td($row->{'mouse_earmark'}),
                    td($row->{'mouse_sex'}),
                    td(get_color_name_by_id($global_var_href, $row->{'mouse_coat_color'})),
                    td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                    td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                    td($row->{'strain_name'}),
                    td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                    td($row->{'location_room'} . '-' . $row->{'location_rack'}),
                    td(a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"}, $row->{'cage_id'})),
                    td({-align=>'left'}, $short_comment),
                    td($weaning_remark)
                  );
     }

     $page .= end_table()
              . p();

  }
  else {
     $page .= h3(" no female pups to wean ");
  }
  # females done
  #------------------------------------------------------------------

  # finally update the litter table, enter weaning date
  $dbh->do("update  litters
            set     litter_weaning_datetime = ?, litter_comment = ?
            where   litter_id = ?
           ", undef, $litter_weaning_datetime_sql, param('litter_comment'), $litter_id
          ) or &error_message_and_exit($global_var_href, "SQL error (could not set weaning date)", $sr_name . "-" . __LINE__);

  # mating generated, so commit
  $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

  # end transaction
  ############################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $move_user_id);


  &write_textlog($global_var_href, "$datetime_sql\t$move_user_id\t" . $session->param('username') . "\twean_litter\t$litter_id\t" . format_display_datetime2sql_datetime($litter_born_datetime) . "\t" . join(',', @weaned_mice));

  # offer cage card printing
  $page .= hr()
           . h3("Print cage cards")
           . p("You may want to print (new) cage cards for all cages involved in the weaning. Please use the links below.")
           . p()
           . "<ul>";

  foreach $print_cage (sort {$a <=> $b} keys %all_cages) {
    $page .= li(a({-href=>"$url?choice=print_card&cage_id=" . $print_cage, -target=>"_blank"}, "print card for cage " . $print_cage));
  }

  $page .= "</ul>";

  # display "next button" only if we have all information to continue
  if ($hide_next_button > 0) {
     $page .= hr()
              . h3("There are still wrong or missing data!")
              . p("Please go back to the previous step and make your changes")
              . p(a({-href=>"javascript:back()"}, "go back"));
  }
  else {
     # delete the previous choice
     Delete('choice');

     $page .= hr()
              . hidden(-name=>"choice", -value=>"show_cart")
              . h3("Weaning successful! ")
              . p("You may want to see weaned litter " . a({-href=>"$url?choice=litter_view&litter_id=" . $litter_id}, "here"))
              . hr()
              . submit(-name => "job", -value=>"Add selected mice to cart");
  }

  $page .= end_form();

  return $page;
}
# end of wean_litter_step_4
#--------------------------------------------------------------------------------------



# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;