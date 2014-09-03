# lib_convert.pl - a MausDB subroutine library file                                                                              #
#                                                                                                                                #
# Subroutines in this file provide converting and reformatting functions                                                         #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_CON001 get_current_datetime_for_sql():              current time -> "2005-04-26 00:00:00"                                   #
# SR_CON002 format_datetime2simpledate():                "2005-04-26 00:00:00" => "26.04.2005" (without time)                    #
# SR_CON003 get_current_datetime_for_display():          current time -> "26.04.2005 14:56:00"                                   #
# SR_CON004 format_sql_datetime2display_datetime():      "2005-10-14 11:12:13" -> "14.10.2005 11:12:13"                          #
# SR_CON005 format_display_datetime2sql_datetime():      "14.10.2005 11:12:13" -> "2005-10-14 11:12:13"                          #
# SR_CON006 format_timestamp2display_datetime():         "20051005115655" => "05.10.2005, 11:56:55"                              #
# SR_CON007 get_age():                                   date_of_birth, date_of_death => "2w5d"  (age in weeks and days)         #
# SR_CON008 reformat_number():                           expands number to digits by adding leading '0's                         #
# SR_CON009 get_sql_time_by_given_current_age():         current age in days => "2005-04-12"                                     #
# SR_CON010 get_current_date_for_display():              current time -> "26.04.2005"                                            #
# SR_CON011 format_sql_datetime2display_date():          "2005-10-14 11:12:13" -> "14.10.2005"                                   #
# SR_CON012 check_date_ddmmyyyy():                       returns '1', if date string is valid                                    #
# SR_CON013 format_display_date2sql_datetime():          "14.10.2005" -> "2005-10-14 00:00:00"                                   #
# SR_CON014 format_sql_date2display_date():              "2005-10-14" -> "14.10.2005"                                            #
# SR_CON015 check_datetime_ddmmyyyy_hhmmss():            returns '1', if datetime string is valid                                #
# SR_CON016 Delta_ddmmyyyhhmmss():                       returns 'future', if datetime2 is past datetime1                        #
# SR_CON017 Delta_seconds():                             returns difference in seconds between datetime1 and datetime2           #
# SR_CON018 format_sql_datetime2display_day_and_month(): "2005-10-14 11:12:13" -> "14. Sep"                                      #
# SR_CON019 get_current_date_for_logs():                 current date -> "2005-04-26"                                            #
# SR_CON020 format_display_date2sql_date():              "14.10.2005" -> "2005-10-14"                                            #
# SR_CON023 mouse_list2link_list():                      converts a list of mice to list of linked mice                          #
# SR_CON024 format_display_datetime2sql_date():          "14.10.2005 11:12:13" -> "2005-10-14"                                   #
# SR_CON025 round_number():                              round a floating number to a number of decimals                         #
# SR_CON026 format_sql_datetime2calendar_week_year():    returns calendar week and year for a given sql datetime                 #
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

#-------------------------------------------------------------------------------
# SR_CON001 get_current_datetime_for_sql():              current time -> "2005-04-26 00:00:00"
sub get_current_datetime_for_sql {
  my ($sec, $min, $hour, $day, $month, $yyyyear) = (localtime)[0,1,2,3,4,5];
  my $datetime;

  # create sql datetime format: 2005-04-26 00:00:00
  $month++;                                      # start with january = 1, not 0
  if ($month < 10) { $month = '0' . $month; }
  if ($day   < 10) { $day   = '0' . $day;   }
  if ($hour  < 10) { $hour  = '0' . $hour;  }
  if ($min   < 10) { $min   = '0' . $min;   }
  if ($sec   < 10) { $sec   = '0' . $sec;   }

  $datetime = ($yyyyear + 1900) . '-' . $month . '-' . $day . ' ' . $hour . ':' . $min . ':' . $sec;

  return ($datetime);
}
# end of get_current_datetime_for_sql()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON002 format_datetime2simpledate():                "2005-04-26 00:00:00" => "26.04.2005" (without time)
sub format_datetime2simpledate {
  my ($datetime) = @_;
  my ($yyyy, $mm, $dd, $hour, $min, $sec);

  if (defined($datetime)) {
     ($yyyy, $mm, $dd, $hour, $min, $sec) = split(/\s|-|:/, $datetime);
  }
  else {
     return '-';
  }

  if    ($datetime eq "0000-00-00")  { return '-';                             }
  elsif ($datetime eq "")            { return '-';                             }
  else                               { return ($dd . '.' . $mm . '.' . $yyyy); }
}
# format_datetime2simpledate
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON003 get_current_datetime_for_display():          current time -> "26.04.2005 14:56:00"
sub get_current_datetime_for_display {
  my ($sec, $min, $hour, $dd, $mm, $yyyy) = (localtime)[0,1,2,3,4,5];
  my $datetime;

  # create sql datetime format: 26.04.2005 14:56:00
  $mm++;                                      # start with january = 1, not 0
  if ($mm   < 10) { $mm   = '0' . $mm;   }
  if ($dd   < 10) { $dd   = '0' . $dd;   }
  if ($hour < 10) { $hour = '0' . $hour; }
  if ($min  < 10) { $min  = '0' . $min;  }
  if ($sec  < 10) { $sec  = '0' . $sec;  }

  $datetime = $dd . '.' . $mm . '.' . ($yyyy + 1900) . ' ' . $hour . ':' . $min . ':' . $sec;

  return ($datetime);
}
# end of get_current_datetime_for_display()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON004 format_sql_datetime2display_datetime():      "2005-10-14 11:12:13" -> "14.10.2005 11:12:13"
sub format_sql_datetime2display_datetime {
  my ($datetime) = @_;

  # make it short if no valid $datetime given
  if    (!defined($datetime))        { return '-'; }
  elsif ($datetime eq "0000-00-00")  { return '-'; }
  elsif ($datetime eq "")            { return '-'; }

  # otherwise continue
  else  {
    my ($yyyy, $mm, $dd, $hour, $min, $sec) = split(/\s|-|:/, $datetime);
    return ($dd . '.' . $mm . '.' . $yyyy . " " . $hour . ":" . $min . ":" . $sec);
  }
}
# end of format_sql_datetime2display_datetime()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON005 format_display_datetime2sql_datetime():      "14.10.2005 11:12:13" -> "2005-10-14 11:12:13"
sub format_display_datetime2sql_datetime {
  my ($datetime) = @_;

  # make it short if no valid $datetime given
  if    (!defined($datetime))        { return '-'; }
  elsif ($datetime eq "0000-00-00")  { return '-'; }
  elsif ($datetime eq "")            { return '-'; }

  # otherwise continue
  else                      {
     my ($dd, $mm, $yyyy, $hour, $min, $sec) = split(/\s|\.|:/, $datetime);
     return $yyyy . '-' . $mm . '-' . $dd . ' ' . $hour . ':' . $min . ':' . $sec;
  }
}
# end of format_display_datetime2sql_datetime()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON006 format_timestamp2display_datetime():         "20051005115655" => "05.10.2005, 11:56:55"
sub format_timestamp2display_datetime {
  my ($datetime) = @_;

  if    (!defined($datetime))                                       { return '-';                                                            }
  elsif ($datetime =~ /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/) { return $3 . '.' . $2 . '.' . $1 . ' at ' . $4 . ':' . $5 . ':' . $6;   }
  else                                                              { return '-';                                                            }
}
# end of format_timestamp2display_datetime()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON007 get_age():                                   date_of_birth, date_of_death => "2w5d"  (age in weeks and days)
sub get_age {
  my ($born_datetime, $death_datetime) = @_;
  my ($born_yyyy, $born_mm, $born_dd, $delta_days, $days, $weeks);
  my ($ref_dd, $ref_mm, $ref_yyyy);

  # make it short if no date of birth given
  if (!defined($born_datetime) || $born_datetime eq '0000-00-00' || $born_datetime eq '') { return '-'; }

  # include date calculation module
  use Date::Calc qw(Delta_Days);

  # get year, month, day of birthdate
  ($born_yyyy, $born_mm, $born_dd, undef, undef, undef) = split(/\s|-|:/, $born_datetime);

  # If no date of death given, take current local time as reference date
  if (!defined($death_datetime)) {
    ($ref_dd, $ref_mm, $ref_yyyy) = (localtime)[3,4,5];

    # calculate absolute year and absolute month
    $ref_yyyy += 1900;
    $ref_mm   += 1;
  }

  # if date of death given, take time of death as reference date
  else {
    ($ref_yyyy, $ref_mm, $ref_dd, undef, undef, undef) = split(/\s|-|:/, $death_datetime);
  }

  # either way, calculate difference in days between birthday and refence date
  $delta_days = Delta_Days($born_yyyy, $born_mm, $born_dd, $ref_yyyy, $ref_mm, $ref_dd);

  # now we have the age in days, but we need to calculate weeks and days: 17d => 2w3d
  $days  = $delta_days % 7;                    # use modulo operator
  $weeks = ($delta_days - $days) / 7;

  # weeks and days: 3w5d
  #return $weeks . 'w' . $days . 'd';

  # days only
  return $delta_days;
}
# end of get_age()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON008 reformat_number():                           expands number to digits by adding leading '0's
sub reformat_number {
  my $number = $_[0];             # the number that has to be reformatted
  my $digits = $_[1];             # total number of digits desired

  # if the number is not defined (=NULL), return "-"
  unless (defined($number)) {
    return "-";
  }

  # else add so many tailing '0's to the number until $digits digits reached
  my $length   = '%' . '0' . $digits . 'd';
  my $expanded = sprintf ($length, $number);

  return $expanded;
}
# reformat_number
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON009 get_sql_time_by_given_current_age():         current age in days => "2005-04-12"
sub get_sql_time_by_given_current_age {
  my ($days_of_age) = @_;

  # make it short if no valid $datetime given
  if    (!defined($days_of_age))     { return '-'; }
  elsif ($days_of_age eq ""    )     { return '-'; }

  # otherwise calculate age
  else      {
    use Date::Calc qw(Add_Delta_Days);

    # don't add the days, but subtract them
    $days_of_age *= (-1);

    # get current local system time
    my ($dd, $mm, $yyyy) = (localtime)[3,4,5];

    # calculate absolute year and absolute month
    $yyyy += 1900;
    $mm   += 1;

    my ($year, $month, $day) = Add_Delta_Days($yyyy, $mm, $dd, $days_of_age);

    return ($year . '-' . $month . '-' . $day);
  }
}
# end of get_sql_time_by_given_current_age()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON010 get_current_date_for_display():              current time -> "26.04.2005"
sub get_current_date_for_display {
  my ($sec, $min, $hour, $dd, $mm, $yyyy) = (localtime)[0,1,2,3,4,5];
  my $date;

  # create sql datetime format: 26.04.2005 14:56:00
  $mm++;
  if ($mm   < 10) { $mm   = '0' . $mm;   }
  if ($dd   < 10) { $dd   = '0' . $dd;   }
  if ($hour < 10) { $hour = '0' . $hour; }
  if ($min  < 10) { $min  = '0' . $min;  }
  if ($sec  < 10) { $sec  = '0' . $sec;  }

  $date = $dd . '.' . $mm . '.' . ($yyyy + 1900);

  return ($date);
}
# end of get_current_date_for_display()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON011 format_sql_datetime2display_date():          "2005-10-14 11:12:13" -> "14.10.2005"
sub format_sql_datetime2display_date {
  my ($datetime) = @_;

  # make it short if no valid $datetime given
  if    (!defined($datetime))        { return '-'; }
  elsif ($datetime eq "0000-00-00")  { return '-'; }
  elsif ($datetime eq "")            { return '-'; }

  # otherwise continue
  else  {
    my ($yyyy, $mm, $dd, undef, undef, undef) = split(/\s|-|:/, $datetime);
    return ($dd . '.' . $mm . '.' . $yyyy);
  }
}
# end of format_sql_datetime2display_date()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON012 check_date_ddmmyyyy():                       returns '1', if date string is valid
sub check_date_ddmmyyyy {
  my ($datestring) = @_;
  my ($dd, $mm, $yyyy);

  if ($datestring =~ /^([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{4})$/) {
     ($dd, $mm, $yyyy) = ($1, $2, $3);
     use Date::Calc qw(check_date);

     return check_date($yyyy, $mm, $dd);
  }
  else {
     return 0;
  }

}
# end of check_date_ddmmyyyy()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON013 format_display_date2sql_datetime():          "14.10.2005" -> "2005-10-14 00:00:00"
sub format_display_date2sql_datetime {
  my ($datetime) = @_;

  # make it short if no valid $datetime given
  if    (!defined($datetime))        { return '0000-00-00 00:00:00'; }
  elsif ($datetime eq "0000-00-00")  { return '0000-00-00 00:00:00'; }
  elsif ($datetime eq "")            { return '0000-00-00 00:00:00'; }

  # otherwise continue
  else                      {
     my ($dd, $mm, $yyyy, $hour, $min, $sec) = split(/\s|\.|:/, $datetime);
     return $yyyy . '-' . $mm . '-' . $dd . ' 06:00:00';
  }
}
# end of format_display_date2sql_datetime()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON014 format_sql_date2display_date():              "2005-10-14" -> "14.10.2005"
sub format_sql_date2display_date {
  my ($datetime) = @_;

  # make it short if no valid $datetime given
  if    (!defined($datetime))        { return '-'; }
  elsif ($datetime eq "0000-00-00")  { return '-'; }
  elsif ($datetime eq "")            { return '-'; }

  # otherwise continue
  else  {
    my ($yyyy, $mm, $dd) = split(/\s|-|:/, $datetime);
    return ($dd . '.' . $mm . '.' . $yyyy);
  }
}
# end of format_sql_date2display_date()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON015 check_datetime_ddmmyyyy_hhmmss():                       returns '1', if datetime string is valid
sub check_datetime_ddmmyyyy_hhmmss {
  my ($datetimestring) = @_;
  my ($dd, $mm, $yyyy, $hh, $mi, $ss);

  if ($datetimestring =~ /^([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{4})\s([0-9]{1,2}):([0-9]{1,2}):([0-9]{1,2})$/) {
     ($dd, $mm, $yyyy, $hh, $mi, $ss) = ($1, $2, $3, $4, $5, $6);
     use Date::Calc qw(check_date);

     if ($hh > -1 && $hh < 25 && $mi > -1 && $mi < 60 && $ss > -1 && $ss < 60) {
        return check_date($yyyy, $mm, $dd);
     }
     else {
        return 0;
     }
  }
  else {
     return 0;
  }

}
# end of check_datetime_ddmmyyyy_hhmmss()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON016 Delta_ddmmyyyhhmmss():                       returns 'future', if datetime2 is past datetime1
sub Delta_ddmmyyyhhmmss {
  my ($datetimestring_1, $datetimestring_2) = @_;
  my ($dd1, $mm1, $yyyy1, $hh1, $mi1, $ss1);
  my ($dd2, $mm2, $yyyy2, $hh2, $mi2, $ss2);
  my ($epoch_seconds1, $epoch_seconds2);

  # use module for datetime comparison. Mktime() calculates epoch seconds from (yyyy, mm, dd, hh, mi, ss) input
  use Date::Calc qw(Mktime);

  # if both date/time strings are given and represent valid dates
  if (check_datetime_ddmmyyyy_hhmmss($datetimestring_1) == 1 && check_datetime_ddmmyyyy_hhmmss($datetimestring_2) == 1) {
     # split $datetimestring_1 into pieces in order to calculate epoch seconds
     if ($datetimestring_1 =~ /([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{4})\s([0-9]{1,2}):([0-9]{1,2}):([0-9]{1,2})/) {
        ($dd1, $mm1, $yyyy1, $hh1, $mi1, $ss1) = ($1, $2, $3, $4, $5, $6);

        $epoch_seconds1 = Mktime($yyyy1, $mm1, $dd1, $hh1, $mi1, $ss1);
     }

     # split $datetimestring_2 into pieces in order to calculate epoch seconds
     if ($datetimestring_2 =~ /([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{4})\s([0-9]{1,2}):([0-9]{1,2}):([0-9]{1,2})/) {
        ($dd2, $mm2, $yyyy2, $hh2, $mi2, $ss2) = ($1, $2, $3, $4, $5, $6);

        $epoch_seconds2 = Mktime($yyyy2, $mm2, $dd2, $hh2, $mi2, $ss2);
     }

     # if we have both epoch second values defined and > 0 ...
     if (defined($epoch_seconds1) && ($epoch_seconds1 > 0) && defined($epoch_seconds2) && ($epoch_seconds2 > 0)) {
        # ... determine their relation
        if ($epoch_seconds2 > $epoch_seconds1) {
           return 'future';
        }
        elsif ($epoch_seconds2 == $epoch_seconds1) {
           return 'present';
        }
        else {
           return 'past';
        }

     }
     # error with epoch second calculation: return error
     else {
        return '-';
     }

  }
  # error with input datetime string: return error
  else {
     return '--';
  }

}
# end of Delta_ddmmyyyhhmmss()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# SR_CON017 Delta_seconds():                       returns difference in seconds between datetime1 and datetime2
sub Delta_seconds {
  my ($datetimestring_1, $datetimestring_2) = @_;
  my ($dd1, $mm1, $yyyy1, $hh1, $mi1, $ss1);
  my ($dd2, $mm2, $yyyy2, $hh2, $mi2, $ss2);
  my ($epoch_seconds1, $epoch_seconds2);

  # use module for datetime comparison. Mktime() calculates epoch seconds from (yyyy, mm, dd, hh, mi, ss) input
  use Date::Calc qw(Mktime);

  # if both date/time strings are given and represent valid dates
  if (check_datetime_ddmmyyyy_hhmmss($datetimestring_1) == 1 && check_datetime_ddmmyyyy_hhmmss($datetimestring_2) == 1) {
     # split $datetimestring_1 into pieces in order to calculate epoch seconds
     if ($datetimestring_1 =~ /([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{4})\s([0-9]{1,2}):([0-9]{1,2}):([0-9]{1,2})/) {
        ($dd1, $mm1, $yyyy1, $hh1, $mi1, $ss1) = ($1, $2, $3, $4, $5, $6);

        $epoch_seconds1 = Mktime($yyyy1, $mm1, $dd1, $hh1, $mi1, $ss1);
     }

     # split $datetimestring_2 into pieces in order to calculate epoch seconds
     if ($datetimestring_2 =~ /([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{4})\s([0-9]{1,2}):([0-9]{1,2}):([0-9]{1,2})/) {
        ($dd2, $mm2, $yyyy2, $hh2, $mi2, $ss2) = ($1, $2, $3, $4, $5, $6);

        $epoch_seconds2 = Mktime($yyyy2, $mm2, $dd2, $hh2, $mi2, $ss2);
     }

     # if we have both epoch second values defined and > 0 ...
     if (defined($epoch_seconds1) && ($epoch_seconds1 > 0) && defined($epoch_seconds2) && ($epoch_seconds2 > 0)) {
        # ... return difference
        return abs($epoch_seconds2 - $epoch_seconds1);
     }
     # error with epoch second calculation: return error
     else {
        return '-';
     }

  }
  # error with input datetime string: return error
  else {
     return '-';
  }

}
# end of Delta_seconds()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON018 format_sql_datetime2display_day_and_month():          "2005-10-14 11:12:13" -> "14. Sep"
sub format_sql_datetime2display_day_and_month {
  my ($datetime) = @_;
  my $month_name = {'01' => 'Jan', '02' => 'Feb', '03' => 'Mar', '04' => 'Apr', '05' => 'May', '06' => 'Jun',
                    '07' => 'Jul', '08' => 'Aug', '09' => 'Sep', '10' => 'Oct', '11' => 'Nov', '12' => 'Dec'
                   };

  # make it short if no valid $datetime given
  if    (!defined($datetime))        { return '-'; }
  elsif ($datetime eq "0000-00-00")  { return '-'; }
  elsif ($datetime eq "")            { return '-'; }

  # otherwise continue
  else  {
    my ($yyyy, $mm, $dd, undef, undef, undef) = split(/\s|-|:/, $datetime);
    return ($dd . '. ' . $month_name->{$mm});
  }
}
# end of format_sql_datetime2display_day_and_month()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_CON019 get_current_date_for_logs():              current date -> "2005-04-26"
sub get_current_date_for_logs {
  my ($sec, $min, $hour, $day, $month, $yyyyear) = (localtime)[0,1,2,3,4,5];
  my $datetime;

  # create sql datetime format: 2005-04-26 00:00:00
  $month++;                                      # start with january = 1, not 0
  if ($month < 10) { $month = '0' . $month; }
  if ($day   < 10) { $day   = '0' . $day;   }
  if ($hour  < 10) { $hour  = '0' . $hour;  }
  if ($min   < 10) { $min   = '0' . $min;   }
  if ($sec   < 10) { $sec   = '0' . $sec;   }

  $datetime = ($yyyyear + 1900) . '-' . $month . '-' . $day;

  return ($datetime);
}
# end of get_current_date_for_logs()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# SR_CON020 format_display_date2sql_date():          "14.10.2005" -> "2005-10-14"
sub format_display_date2sql_date {
  my ($datetime) = @_;

  # make it short if no valid $datetime given
  if    (!defined($datetime))        { return '0000-00-00'; }
  elsif ($datetime eq "0000-00-00")  { return '0000-00-00'; }
  elsif ($datetime eq "")            { return '0000-00-00'; }

  # otherwise continue
  else                      {
     my ($dd, $mm, $yyyy, $hour, $min, $sec) = split(/\s|\.|:/, $datetime);
     return $yyyy . '-' . $mm . '-' . $dd;
  }
}
# end of format_display_date2sql_date()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# SR_CON021 format_display_datetime2display_date():      "14.10.2005 11:12:13" -> "14.10.2005"
sub format_display_datetime2display_date {
  my ($datetime) = @_;

  # make it short if no valid $datetime given
  if    (!defined($datetime))        { return '-'; }
  elsif ($datetime eq "0000-00-00")  { return '-'; }
  elsif ($datetime eq "")            { return '-'; }

  # otherwise continue
  else                      {
     my ($dd, $mm, $yyyy, $hour, $min, $sec) = split(/\s|\.|:/, $datetime);
     return $dd . '.' . $mm . '.' . $yyyy;
  }
}
# end of format_display_datetime2display_date()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# SR_CON022 get_age_in_days():                           date_of_birth, date_of_death => "51" (age in days)
sub get_age_in_days {
  my ($born_datetime, $death_datetime) = @_;
  my ($born_yyyy, $born_mm, $born_dd, $delta_days, $days, $weeks);
  my ($ref_dd, $ref_mm, $ref_yyyy);

  # make it short if no date of birth given
  if (!defined($born_datetime) || $born_datetime eq '0000-00-00' || $born_datetime eq '') { return '-'; }

  # include date calculation module
  use Date::Calc qw(Delta_Days);

  # get year, month, day of birthdate
  ($born_yyyy, $born_mm, $born_dd, undef, undef, undef) = split(/\s|-|:/, $born_datetime);

  # If no date of death given, take current local time as reference date
  if (!defined($death_datetime)) {
    ($ref_dd, $ref_mm, $ref_yyyy) = (localtime)[3,4,5];

    # calculate absolute year and absolute month
    $ref_yyyy += 1900;
    $ref_mm   += 1;
  }

  # if date of death given, take time of death as reference date
  else {
    ($ref_yyyy, $ref_mm, $ref_dd, undef, undef, undef) = split(/\s|-|:/, $death_datetime);
  }

  # either way, calculate difference in days between birthday and refence date
  $delta_days = Delta_Days($born_yyyy, $born_mm, $born_dd, $ref_yyyy, $ref_mm, $ref_dd);

  return $delta_days;
}
# end of get_age_in_days()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# SR_CON023 mouse_list2link_list():                      converts a list of mice to list of linked mice
sub mouse_list2link_list {
  my ($mouselist_ref) = @_;
  my @mouse_list = @{$mouselist_ref};
  my $url = url();
  my $mouse;
  my $linked_mice;

  foreach $mouse (@mouse_list) {
     $linked_mice .= a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse}, $mouse) . ' ';
  }

  return $linked_mice;
}
# end of mouse_list2link_list()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# SR_CON024 format_display_datetime2sql_date():      "14.10.2005 11:12:13" -> "2005-10-14"
sub format_display_datetime2sql_date {
  my ($datetime) = @_;

  # make it short if no valid $datetime given
  if    (!defined($datetime))        { return '-'; }
  elsif ($datetime eq "0000-00-00")  { return '-'; }
  elsif ($datetime eq "")            { return '-'; }

  # otherwise continue
  else                      {
     my ($dd, $mm, $yyyy, $hour, $min, $sec) = split(/\s|\.|:/, $datetime);
     return $yyyy . '-' . $mm. '-'. $dd;
  }
}
# end of format_display_datetime2sql_date()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# SR_CON025 round_number():                             round a floating number to a number of decimals
sub round_number {
  my $number = $_[0];             # the number that has to be rounded
  my $digits = $_[1];             # total number of digits desired
  my $rounded;

  if    ($digits == 0) { $rounded = sprintf("%.0f", $number); }
  elsif ($digits == 1) { $rounded = sprintf("%.1f", $number); }
  elsif ($digits == 2) { $rounded = sprintf("%.2f", $number); }
  elsif ($digits == 3) { $rounded = sprintf("%.3f", $number); }
  elsif ($digits == 4) { $rounded = sprintf("%.4f", $number); }
  elsif ($digits == 5) { $rounded = sprintf("%.5f", $number); }
  elsif ($digits == 6) { $rounded = sprintf("%.6f", $number); }

  return $rounded;
}
# round_number
#-------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_CON026 format_sql_datetime2calendar_week_year():    returns calendar week and year for a given sql datetime
sub format_sql_datetime2calendar_week_year {             my $sr_name = 'SR_CON026';
  my $global_var_href  = $_[0];                          # get reference to global vars hash
  my $date             = $_[1];
  my ($sql, $day_week_and_year, $the_date);
  my @sql_parameters;

  # extract the date part from current datetime
  ($the_date, undef) = split(/\s/, $date);

  # query current epoch week
  $sql = qq(select day_week_and_year
            from   days
            where  day_date = ?
           );

  @sql_parameters = ($the_date);

  ($day_week_and_year) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $day_week_and_year;

}
# end of format_sql_datetime2calendar_week_year()
#--------------------------------------------------------------------------------------



# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;