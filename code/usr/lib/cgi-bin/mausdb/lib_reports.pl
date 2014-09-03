# lib_reports.pl - a MausDB subroutine library file                                                                              #
#                                                                                                                                #
# Subroutines in this file provide reporting related functions                                                                   #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_REP001 report_overview():                           generates the initial report form                                       #
# SR_REP002 tep_1():                                     tep report start form                                                   #
# SR_REP003 tep_2():                                     tep report                                                              #
# SR_REP004 report_to_excel                              generate report in Excel format                                         #
# SR_REP005 check_database():                            check database                                                          #
# SR_REP006 versuchstiermeldung_1():                     versuchstiermeldung start form                                          #
# SR_REP007 versuchstiermeldung_2():                     versuchstiermeldung                                                     #
# SR_REP008 animal_numbers_1():                          animal_numbers_1 start form                                             #
# SR_REP009 animal_numbers_2():                          calculate animal numbers for any point in time                          #
# SR_REP010 animal_cage_time_1():                        calculate animal cage days (start form)                                 #
# SR_REP011 animal_cage_time_2():                        calculate animal cage occupation for a time range                       #
# SR_REP012 blob_info():                                 info about the blob database                                            #
# SR_REP013 statistics():                                some basic database statistics                                          #
# SR_REP014 start_GTAS_report_to_excel():                GTAS report start form                                                  #
# SR_REP015 GTAS_report_to_excel                         generate GTAS report in Excel format                                    #
# SR_REP016 start_maus_cat_to_excel                      MausNet Catalogue start form                                            #
# SR_REP017 maus_cat_to_excel                            generate MausNet Catalogue in Excel format                              #
# SR_REP018 animal_cage_time_excel                       show animal cage occupation numbers in Excel format                     #
# SR_REP019 rack_stock_taking_to_excel                   generate stock taking list in Excel format                              #
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
# SR_REP001 report_overview():                           generates the initial report form
sub report_overview {                                    my $sr_name = 'SR_REP001';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page);
  my $session  = $global_var_href->{'session'};          # get session handle
  my $username = $session->param(-name=>'username');


 $page = h2("Overviews ")
          . hr()
          . table( {-border=>1},
               Tr( td(a({-href=>"$url?choice=line_overview"},                   ' lines')),
                   td("live stock (grouped by lines) ")
               ) .
               Tr( td(a({-href=>"$url?choice=strain_overview"},                 ' strains')),
                   td("live stock (grouped by strains) ")
               ) .
               Tr( td(a({-href=>"$url?choice=parametersets_overview"},          ' parametersets ')),
                   td("parametersets overview ")
               ) .
               Tr( td(a({-href=>"$url?choice=parameters_overview"},             ' parameters ')),
                   td("parameters overview ")
               ) .
               Tr( td(a({-href=>"$url?choice=cohorts_overview"},                ' cohorts ')),
                   td("cohorts overview ")
               ) .
               Tr( td(a({-href=>"$url?choice=view_line_vs_parameterset_data"},  ' medical records ')),
                   td("medical records overview (line vs. parameterset) " . b(" (please be patient, this will take a while)"))
               ) .
               Tr( td(a({-href=>"$url?choice=experiment_overview"},             ' experiments ')),
                   td("experiments overview ")
               ) .
               Tr( td(a({-href=>"$url?choice=cost_centre_overview"},            ' cost centres ')),
                   td("list of all cost centres ")
               ) .
               Tr( td(a({-href=>"$url?choice=stored_files_overview"},           ' stored files')),
                   td("list of all stored files ")
               ) .
               Tr( td(a({-href=>"$url?choice=treatment_procedures_overview"},   ' treatment protocols')),
                   td("list of all treatment protocols ")
               ) .
               Tr( td(a({-href=>"$url?choice=status_codes_overview"},           ' status codes')),
                   td("list of all status codes ")
               ) .
               Tr( td(a({-href=>"$url?choice=sterile_matings_overview"},        ' sterile matings in my project(s)')),
                   td("list of all sterile matings in your project(s)")
               ) .
               Tr( td(a({-href=>"$url?choice=workflows_overview"},              ' workflows')),
                   td("list of all workflows ")
               )
            )

          . h2("Reports")
          . hr()
          . table( {-border=>1},
               Tr( td(a({-href=>"$url?choice=tep_start"}, " generate TEP report (weekly)")),
                   td("generate a report for the GSF TEP system. ")
               ) .
               Tr( td(a({-href=>"$url?choice=versuchstiermeldung_start"}, " generate Versuchstiermeldung (monthly)")),
                   td("generate a \"Versuchstiermeldung\" . ")
               ) .
               Tr( td(a({-href=>"$url?choice=animal_numbers"}, " snapshot tail count ")),
                   td("Snapshot count: get animal numbers for any point in time ")
               ) .
               Tr( td(a({-href=>"$url?choice=animal_cage_days"}, " animal cage occupation ")),
                   td("calculate animal cage occupation for a time range ")
               ) .
               Tr( td(a({-href=>"$url?choice=start_gtas_report_to_excel"}, " GTAS report ")),
                   td("generate GTAS report in Excel format ")
               ).
               ((current_app_is_mousenet($global_var_href) eq 'y')
               	?
               	Tr( td(a({-href=>"$url?choice=start_maus_cat_to_excel"}, "MouseNet Catalogue")),
                   td("generate MouseNet Catalogue in Excel format")
               )
               :''
               )
      		);

  return $page;
}
# end of report_overview()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_REP002 tep_1():                                     tep report start form
sub tep_1 {                                              my $sr_name = 'SR_REP002';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my ($page);

  $page = h2("TEP report")
          . hr()
          . h3("Generate a TEP report ... ")
          . start_form(-action => url())

          . p("Please choose the report period")

          . p("From " . get_calendar_week_popup_menu_3($global_var_href, 'week_from', add_to_date($global_var_href, get_monday_of_current_week($global_var_href), -42))
              . " to  " . get_calendar_week_popup_menu_3($global_var_href, 'week_to',   get_monday_of_current_week($global_var_href))
              . "&nbsp;"
              . submit(-name => "choice", -value=>"generate TEP report")
            )

          . end_form()

          . p("A TEP Excel file will be produced upon pressing the button. You can download the file to your local system or open it directly.");

  return $page;
}
# end of report_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_REP003 tep_2():                                     tep report start form
sub tep_2 {                                              my $sr_name = 'SR_REP003';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh       = $global_var_href->{'dbh'};             # DBI database handle
  my $url       = url();
  my $week_from = param('week_from');
  my $week_to   = param('week_to');
  my ($epoch_week_from, $epoch_week_to, $kw_epoch_week);
  my ($page, $sql, $result, $rows, $row, $i, $tepkey, $kw, $current_kw, $current_line);
  my ($kw_year, $kw_week, $tep_gvo, $tep_experiment, $tep_key_experiment);
  my ($excel_sheet, $local_filename, $data);
  my @xls_row = ();
  my %ZugangAbgesetzt;          # Spalte C [Zugang in den Zuchtbestand durch Weaning]
  my %ZugangGSFIntern;          # Spalte D [Zugang in den Zuchtbestand durch Import von innerhalb  der GSF]
  my %ZugangGSFExtern;          # Spalte E [Zugang in den Zuchtbestand durch Import von ausserhalb der GSF]
  my %ZugangUebergaenge;        # Spalte F [Uebergang in den Experimentbestand fuer Zuchtmaeuse bzw. in die Zucht fuer Experimentmaeuse]
  my %AbgangExperiment;         # Spalte G [Ueberfuehrung von Zuchtmaeusen ins Experiment (gilt nur fuer Zuchtmaeuse)]
  my %AbgangTod;                # Spalte H [Reduzierung des Lebendbestandes durch Tod]
  my %AbgangEntnahme;           # Spalte I [Reduzierung des Lebendbestandes wegen Organentnahme (gilt nur bei Zuchtmaeusen)]
  my %AbgangExport;             # Spalte J [Reduzierung des Lebendbestandes durch Export lebender Tiere in irgendein anderes Maushaus]
  my %AbgangZucht;              # Spalte K []
  my %UebergangExpExp;          # Spalte L
  my %AbgangExpExp;             # Spalte M
  my @tepkeys;
  my @all_kws;
  my @error_mice;
  my @log_mice;
  my @sql_parameters;
  my %mouse_seen;

  # check if report period given and in valid format
  if (param('week_from') && param('week_from') =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ &&
      param('week_to')   && param('week_to')   =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {

      # get the epoch week of report period start
      $sql = qq(select day_epoch_week
                from   days
                where  day_date = ?
             );

      @sql_parameters = ($week_from);

      ($epoch_week_from) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      # get the epoch week of report period end
      $sql = qq(select day_epoch_week
                from   days
                where  day_date = ?
             );

      @sql_parameters = ($week_to);

      ($epoch_week_to) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};
  }

  # include a module to write tables as Excel file in a simple way
  use Spreadsheet::WriteExcel::Simple;

  # create a new excel sheet object
  $excel_sheet = Spreadsheet::WriteExcel::Simple->new;

  # create a unique filename (using combination of user name and time) for server-side storage of temporary Excel file
  $local_filename = 'TEP_' . time() . '.xls';
  @xls_row = ('TEPKEY', 'KW', 'ZugangAbgesetzt', 'ZugangHMGUIntern', 'ZugangHMGUExtern', 'Zugang�berg�nge', 'AbgangExperiment', 'AbgangTod',
              'AbgangEntnahme', 'AbgangExport', 'AbgangZucht', 'ZugangExpausExp', 'AbgangExpinsExp');

  # write header line to Excel file
  $excel_sheet->write_row(\@xls_row);


  $page = h2("TEP report")
          . hr();

  # for all mice, get TEP-relevant information
  $sql = qq(select mouse_id, mouse_is_gvo, mouse_deathorexport_why as death_reason,
                   mouse_origin_type, location_is_internal as internal, line_name as mouse_line,
                   weaning.day_week_in_year as weaning_week, weaning.day_year as weaning_year, weaning.day_epoch_week as weaning_epoch_week,
                    import.day_week_in_year as  import_week,  import.day_year as  import_year,  import.day_epoch_week as  import_epoch_week,
                     death.day_week_in_year as   death_week,   death.day_year as   death_year,   death.day_epoch_week as   death_epoch_week,
                   experiment_name,
                   experiment_start.day_week_in_year as exp_start_week, experiment_start.day_year as exp_start_year, experiment_start.day_epoch_week as experiment_start_epoch_week,
                   experiment_end.day_week_in_year   as exp_end_week,   experiment_end.day_year   as exp_end_year,   experiment_end.day_epoch_week   as experiment_end_epoch_week
            from   mice
                   left join mouse_lines           on                         mouse_line = line_id
                   left join imports               on                    mouse_import_id = import_id
                   left join litters               on                    mouse_litter_id = litter_id
                   left join days weaning          on      date(litter_weaning_datetime) = weaning.day_date
                   left join days death            on date(mouse_deathorexport_datetime) = death.day_date
                   left join locations             on             import_origin_location = location_id
                   left join days import           on              date(import_datetime) = import.day_date
                   left join mice2experiments      on                           mouse_id = m2e_mouse_id
                   left join experiments           on                  m2e_experiment_id = experiment_id
                   left join days experiment_start on            date(m2e_datetime_from) = experiment_start.day_date
                   left join days experiment_end   on              date(m2e_datetime_to) = experiment_end.day_date
            where  mouse_origin_type in ('import', 'weaning')
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      # avoid double counting of mice that have multiple experiment entries
      if (defined($mouse_seen{$row->{'mouse_id'}})) {
         push(@error_mice, 'A'.$row->{'mouse_id'});
         next;
      }

      # register mouse as seen
      $mouse_seen{$row->{'mouse_id'}}++;

      $current_line = $row->{'mouse_line'};

      # determine GVO status and set TEP key modifier
      if ($row->{'mouse_is_gvo'} eq 'y') { $tep_gvo = '-transgen'; }
      else                               { $tep_gvo = '';          }

      # zaehle Zugaenge
      if    ($row->{'mouse_origin_type'} eq 'weaning') {
         # bei abgesetzten Tieren (origin_type = 'weaning'): zaehle Weaning-Datum
         $kw = $row->{'weaning_year'} . '/' . reformat_number($row->{'weaning_week'}, 2);

         # (either there is no experiment start defined)
         # or
         # (experiment start defined, but experiment started at least one week after birth)
         if (!defined($row->{'experiment_start_epoch_week'})
             ||
             (defined($row->{'experiment_start_epoch_week'}) && ($row->{'experiment_start_epoch_week'} > $row->{'weaning_epoch_week'}))
            ) {
            $ZugangAbgesetzt{'Z::1400::' . $current_line . $tep_gvo}{$kw}++;
         }

         # raise error if experiment start is before weaning
         elsif (defined($row->{'experiment_start_epoch_week'}) && ($row->{'experiment_start_epoch_week'} < $row->{'weaning_epoch_week'})) {
            $ZugangAbgesetzt{'Error:dob>exp_start'}{$kw}++;
            push(@error_mice, 'B'.$row->{'mouse_id'});
         }

         # everything ok if experiment start is in same week as weaning
         elsif (defined($row->{'experiment_start_epoch_week'}) && ($row->{'experiment_start_epoch_week'} == $row->{'weaning_epoch_week'})) {
            $ZugangAbgesetzt{'T::1400::' . $current_line . $tep_gvo . '::' . $row->{'experiment_name'}}{$kw}++;
         }

         # in all other cases: raise error
         else {
            $ZugangAbgesetzt{'Error:unknown'}{$kw}++;
            push(@error_mice, 'C'.$row->{'mouse_id'});
         }
      }
      elsif ($row->{'mouse_origin_type'} eq 'import') {
         # bei importierten Tieren (origin_type = 'import'): zaehle Importdatum
         $kw = $row->{'import_year'} . '/' . reformat_number($row->{'import_week'}, 2);

         # Import von innerhalb der GSF?
         if (defined($row->{'internal'}) && $row->{'internal'} eq 'y') {
            # (either there is no experiment start defined)
            # or
            # (experiment start defined, but experiment started at least one week after import)
            if (!defined($row->{'experiment_start_epoch_week'})
                ||
                (defined($row->{'experiment_start_epoch_week'}) && ($row->{'experiment_start_epoch_week'} > $row->{'import_epoch_week'}))
               ) {
               $ZugangGSFIntern{'Z::1400::' . $current_line . $tep_gvo}{$kw}++;
            }

            # raise error if experiment start is before import
            elsif (defined($row->{'experiment_start_epoch_week'}) && ($row->{'experiment_start_epoch_week'} < $row->{'import_epoch_week'})) {
               $ZugangGSFIntern{'Error:doi>exp_start'}{$kw}++;
               push(@error_mice, 'D'.$row->{'mouse_id'});
            }

            # everything ok if experiment start is in same week as import
            elsif (defined($row->{'experiment_start_epoch_week'}) && ($row->{'experiment_start_epoch_week'} == $row->{'import_epoch_week'})) {
               $ZugangGSFIntern{'T::1400::' . $current_line . $tep_gvo . '::' . $row->{'experiment_name'}}{$kw}++;
            }

            # in all other cases: raise error
            else {
               $ZugangGSFIntern{'Error:unknown'}{$kw}++;
               push(@error_mice, 'E'.$row->{'mouse_id'});
            }
         }
         # Import von ausserhalb der GSF
         else {
            # (either there is no experiment start defined)
            # or
            # (experiment start defined, but experiment started at least one week after import)
            if (!defined($row->{'experiment_start_epoch_week'})
                ||
                (defined($row->{'experiment_start_epoch_week'}) && ($row->{'experiment_start_epoch_week'} > $row->{'import_epoch_week'}))
               ) {
               $ZugangGSFExtern{'Z::1400::' . $current_line . $tep_gvo}{$kw}++;
            }

            # raise error if experiment start is before import
            elsif (defined($row->{'experiment_start_epoch_week'}) && ($row->{'experiment_start_epoch_week'} < $row->{'import_epoch_week'})) {
               $ZugangGSFExtern{'Error:doi>exp_start'}{$kw}++;
               push(@error_mice, 'F'.$row->{'mouse_id'});
            }

            # everything ok if experiment start is in same week as import
            elsif (defined($row->{'experiment_start_epoch_week'}) && ($row->{'experiment_start_epoch_week'} == $row->{'import_epoch_week'})) {
               $ZugangGSFExtern{'T::1400::' . $current_line . $tep_gvo . '::' . $row->{'experiment_name'}}{$kw}++;
            }

            # in all other cases: raise error
            else {
               $ZugangGSFExtern{'Error:unknown'}{$kw}++;
               push(@error_mice, 'G'.$row->{'mouse_id'});
            }
         }
      }
      else { # should not happen
         push(@error_mice, 'H'.$row->{'mouse_id'});
      }

      # registriere die Zugangswoche
      push(@all_kws, $kw);

      # check experiment status and set TEP key modifier
      if (defined($row->{'exp_start_week'})) {
         $tep_experiment     = '::' . $row->{'experiment_name'};
         $tep_key_experiment = 'T';
      }
      else {
         $tep_experiment     = '';
         $tep_key_experiment = 'Z';
      }

      # Experimente
      # Normalfall: Ueberfuehrung von Zuchtmaeusen ins Experiment
      if (defined($row->{'exp_start_week'})
          && ( ($row->{'experiment_start_epoch_week'} > $row->{'weaning_epoch_week'} && $row->{'mouse_origin_type'} eq 'weaning')
               ||
               ($row->{'experiment_start_epoch_week'} > $row->{'import_epoch_week'}  && $row->{'mouse_origin_type'} eq 'import')
             )
         ) {

         $kw = $row->{'exp_start_year'} . '/' . reformat_number($row->{'exp_start_week'}, 2);

         $AbgangExperiment{'Z::1400::' . $current_line . $tep_gvo}{$kw}++;
         $ZugangUebergaenge{'T::1400::' . $current_line . $tep_gvo . '::' . $row->{'experiment_name'}}{$kw}++;

#          # Sonderfall: Rueckfuehrung von Experimentmaeusen in die Zucht
#          if (defined($row->{'exp_end_week'})                                                                      # falls Experiment-Ende definiert
#              &&                                                                                                   # und
#              (!defined($row->{'death_week'})                                                                      #   entweder kein Todesdatum definiert
#               ||                                                                                                  #   oder
#               ($row->{'death_epoch_week'} > $row->{'experiment_end_epoch_week'})                                  #   Todesdatum groesser Experiment-Ende
#              )
#             ) { &error_message_and_exit($global_var_href, $row->{'mouse_id'}, "");
#             $kw = $row->{'exp_end_year'} . '/' . reformat_number($row->{'exp_end_week'}, 2);
#
#             $AbgangZucht{'T::1400::' . $current_line . $tep_gvo . '::' . $row->{'experiment_name'}}{$kw}++;
#             $ZugangUebergaenge{'Z::1400::' . $current_line . $tep_gvo}{$kw}++;
#
#             # write some mice to a log list: have ids for control purposes
#             #if ($row->{'exp_end_year'} == 2005) { push(@log_mice, $row->{'mouse_id'}); }
#
#             $tep_experiment     = '';
#             $tep_key_experiment = 'Z';
#          }
#          # well-known error from GHS
#          elsif (defined($row->{'exp_end_week'}) && !defined($row->{'exp_start_week'})) {
#             push(@error_mice, 'I'.$row->{'mouse_id'});
#          }
#          # the normal case: keine Rueckfuehrung ins Experiment
#          elsif (!defined($row->{'experiment_end_epoch_week'})) {
#             # do nothing, this is the normal case (keine Rueckfuehrung ins Experiment)
#          }
#          else {
#             push(@error_mice, 'J'.$row->{'mouse_id'} . '-' . $row->{'experiment_start_epoch_week'} . '-' . $row->{'experiment_end_epoch_week'} . '-' . $row->{'weaning_epoch_week'} . '-' . $row->{'death_epoch_week'} . ';');
#          }
      }

      push(@all_kws, $kw);

      # Abgaenge
      if    (defined($row->{'death_week'})) {
         $kw = $row->{'death_year'} . '/' . reformat_number($row->{'death_week'}, 2);

         # Grund: Organentnahme
         if ($row->{'death_reason'} == 10) {
            $AbgangEntnahme{$tep_key_experiment . '::1400::' . $current_line . $tep_gvo . $tep_experiment}{$kw}++;
         }
         # Grund: Export in andere Einrichtung
         elsif ($row->{'death_reason'} == 9) {
            $AbgangExport{$tep_key_experiment . '::1400::' . $current_line . $tep_gvo . $tep_experiment}{$kw}++;
         }
         # Grund: Tod
         else {
            $AbgangTod{$tep_key_experiment . '::1400::' . $current_line . $tep_gvo . $tep_experiment}{$kw}++;
         }
      }

      # registriere die Abgangswoche
      push(@all_kws, $kw);

  }

#   # first generate table header ...
#   $page .= start_table( {-border=>"1", -summary=>"TEP"})
#            . Tr( {-align=>'center'},
#                th("TEPKEY"),
#                th("KW"),
#                th("ZugangAbgesetzt"),
#                th("ZugangGSFIntern"),
#                th("ZugangGSFExtern"),
#                th("Zugang&Uuml;berg&auml;nge"),
#                th("AbgangExperiment"),
#                th("AbgangTod"),
#                th("AbgangEntnahme"),
#                th("AbgangExport"),
#                th("AbgangZucht")
#              );

  # get all TEP keys (they are keys in the counting hashes)
  @tepkeys = (keys %ZugangAbgesetzt, keys %ZugangGSFIntern, keys %ZugangGSFExtern, keys %ZugangUebergaenge, keys %AbgangExperiment,
              keys %AbgangTod,       keys %AbgangEntnahme,  keys %AbgangExport,    keys %AbgangZucht);

  # make TEP key list non-redundant
  @tepkeys = unique_list(@tepkeys);

  # make calendar week list non-redundant
  @all_kws = unique_list(@all_kws);


  # ... then loop over all calendar weeks in which an event was recorded
  foreach $kw (@all_kws) {

      ($kw_year, $kw_week) = split(/\//, $kw);

      # get epoch week of calendar week
      $sql = qq(select day_epoch_week
                from   days
                where  day_week_in_year = ?
                       and     day_year = ?
             );

      @sql_parameters = ($kw_week, $kw_year);

      ($kw_epoch_week) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      # skip this week if outside report period
      if ($kw_epoch_week < $epoch_week_from || $kw_epoch_week > $epoch_week_to) {
         next;
      }

      foreach $tepkey (@tepkeys) {

           if (!defined($ZugangAbgesetzt{$tepkey}{$kw})   && !defined($ZugangGSFIntern{$tepkey}{$kw})  && !defined($ZugangGSFExtern{$tepkey}{$kw}) &&
               !defined($ZugangUebergaenge{$tepkey}{$kw}) && !defined($AbgangExperiment{$tepkey}{$kw}) && !defined($AbgangTod{$tepkey}{$kw}) &&
               !defined($AbgangEntnahme{$tepkey}{$kw})    && !defined($AbgangExport{$tepkey}{$kw})     && !defined($AbgangZucht{$tepkey}{$kw})
              ) {
              next;
           }

           # write HTML
#            $page .= Tr({-align=>'center'},
#                       td({-align=>'left'}, $tepkey),
#                       td($kw),
#                       td(defined($ZugangAbgesetzt{$tepkey}{$kw})?$ZugangAbgesetzt{$tepkey}{$kw}:''),           # Spalte C
#                       td(defined($ZugangGSFIntern{$tepkey}{$kw})?$ZugangGSFIntern{$tepkey}{$kw}:''),           # Spalte D
#                       td(defined($ZugangGSFExtern{$tepkey}{$kw})?$ZugangGSFExtern{$tepkey}{$kw}:''),           # Spalte E
#                       td(defined($ZugangUebergaenge{$tepkey}{$kw})?$ZugangUebergaenge{$tepkey}{$kw}:''),       # Spalte F
#                       td(defined($AbgangExperiment{$tepkey}{$kw})?$AbgangExperiment{$tepkey}{$kw}:''),         # Spalte G
#                       td(defined($AbgangTod{$tepkey}{$kw})?$AbgangTod{$tepkey}{$kw}:''),                       # Spalte H
#                       td(defined($AbgangEntnahme{$tepkey}{$kw})?$AbgangEntnahme{$tepkey}{$kw}:''),             # Spalte I
#                       td(defined($AbgangExport{$tepkey}{$kw})?$AbgangExport{$tepkey}{$kw}:''),                 # Spalte J
#                       td(defined($AbgangZucht{$tepkey}{$kw})?$AbgangZucht{$tepkey}{$kw}:'')                    # Spalte K
#                     );

           # write Excel
           @xls_row = ($tepkey,
                       $kw_week,
                       (defined($ZugangAbgesetzt{$tepkey}{$kw})?$ZugangAbgesetzt{$tepkey}{$kw}:''),
                       (defined($ZugangGSFIntern{$tepkey}{$kw})?$ZugangGSFIntern{$tepkey}{$kw}:''),
                       (defined($ZugangGSFExtern{$tepkey}{$kw})?$ZugangGSFExtern{$tepkey}{$kw}:''),
                       (defined($ZugangUebergaenge{$tepkey}{$kw})?$ZugangUebergaenge{$tepkey}{$kw}:''),
                       (defined($AbgangExperiment{$tepkey}{$kw})?$AbgangExperiment{$tepkey}{$kw}:''),
                       (defined($AbgangTod{$tepkey}{$kw})?$AbgangTod{$tepkey}{$kw}:''),
                       (defined($AbgangEntnahme{$tepkey}{$kw})?$AbgangEntnahme{$tepkey}{$kw}:''),
                       (defined($AbgangExport{$tepkey}{$kw})?$AbgangExport{$tepkey}{$kw}:''),
                       (defined($AbgangZucht{$tepkey}{$kw})?$AbgangZucht{$tepkey}{$kw}:''),
                      );

           # write current row to Excel object
           $excel_sheet->write_row(\@xls_row);
      }
  }

#   $page .= end_table();

  @error_mice = unique_list(@error_mice);

  #$page .=   p('Mice with errors: '   . (scalar @log_mice) . '   ' . join(',', @log_mice));
  @xls_row = ('Errors', @error_mice);
  $excel_sheet->write_row(\@xls_row);

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

  return $page;
}
# end of tep_2()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_REP004 report_to_excel                              generate report in Excel format
sub report_to_excel {                                    my $sr_name = 'SR_REP004';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session      = $global_var_href->{'session'};      # get session handle
  my $dbh          = $global_var_href->{'dbh'};          # DBI database handle
  my $username     = $session->param(-name=>'username');
  my $line_id      = param('line');
  my $sex          = param('sex');
  my $url          = url();
  my @xls_row      = ();
  my ($excel_sheet, $local_filename, $data);
  my ($page, $sql, $result, $rows, $row, $i);
  my ($current_mating);
  my %sex_sql  = ("1" => "mouse_sex in ('m','f')", "2" => "mouse_sex = 'm' ", "3" => "mouse_sex = 'f' " );
  my $line_sql;
  my @sql_parameters;

  # check if line id given
  if (param('line') && param('line') =~ /^[0-9]+$/) {              # line id given and a number: select for line
     $line_sql = "and mouse_line = $line_id";
  }
  elsif (param('line') && param('line') eq 'all') {                # line id given and "all": do not select for line = select all
     $line_sql = '';
  }
  else {
     $page = p({-class=>"red"}, b("Error: Please choose a valid line."));
     return $page;
  }

  # check if sex given
  if (!param('sex') || param('sex') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: Please choose sex."));
     return $page;
  }

  # include a module to write tables as Excel file in a simple way
  use Spreadsheet::WriteExcel::Simple;

  # create a new excel sheet object
  $excel_sheet = Spreadsheet::WriteExcel::Simple->new;

  # create a unique filename (using combination of user name and time) for server-side storage of temporary Excel file
  $local_filename = $username . '_' . time() . '.xls';
  @xls_row = ('number', 'mouse_id', 'ear', 'sex', 'born', 'age', 'death', 'strain', 'line', 'room/rack', 'comment');

  # write header line to Excel file
  $excel_sheet->write_row(\@xls_row);

  $page .= h3("Export to Excel")
           . hr();

  # collect some details about mice in cart
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
                   dr1.death_reason_name as how, dr2.death_reason_name as why
            from   mice
                   join mouse_strains      on            mouse_strain = strain_id
                   join mouse_lines        on              mouse_line = line_id
                   join mice2cages         on                mouse_id = m2c_mouse_id
                   join cages2locations    on             m2c_cage_id = c2l_cage_id
                   join locations          on             location_id = c2l_location_id
                   join cages              on                 cage_id = c2l_cage_id
                   join death_reasons dr1  on mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2  on mouse_deathorexport_why = dr2.death_reason_id
            where  $sex_sql{$sex}
                   $line_sql
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
                   and mouse_deathorexport_datetime IS NULL
                   and mouse_origin_type in ('import', 'weaning')
            order  by cage_id asc
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if mice from cart cannot be found in database (should not happen): tell user and exit
  unless ($rows > 0) {
     $page .= p("No mice found ");
     return $page;
  }

  # proceed with displaying details about mice in cart
  $page .= p("Found mice");

  # loop over all mice in cart
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     @xls_row = (($i+1),
                 $row->{'mouse_id'},
                 $row->{'mouse_earmark'},
                 $row->{'mouse_sex'},
                 format_datetime2simpledate($row->{'mouse_birth_datetime'}),
                 get_age($row->{'mouse_birth_datetime'},
                 $row->{'mouse_deathorexport_datetime'}),
                 (defined($row->{'mouse_deathorexport_datetime'})?$row->{'mouse_deathorexport_datetime'}:'-'),
                 &get_all_genotypes_in_one_line($global_var_href, $row->{'mouse_id'}),
                 $row->{'strain_name'},
                 $row->{'line_name'},
                 ((!defined($row->{'mouse_deathorexport_datetime'}))                                                             # check if mouse is alive
                  ?$row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'}
                  :'-'
                 ),
                 ((defined($current_mating))?qq((in mating $current_mating)):'') . $row->{'mouse_comment'}
                );

     # write current row to Excel object
     $excel_sheet->write_row(\@xls_row);
  }

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

  $page .= p("Finished");

  return $page;
}
# end of report_to_excel
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_REP005a check_database_1():                            check database subroutine 1
sub check_database_1 {                                      my $sr_name = 'SR_REP005a';
  my ($global_var_href) = @_;                               # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # checking for errors in mouse cage/location tables

  $sql = qq(select m2c_mouse_id as mouse_id, count(m2c_cage_id) as number_of_cages
            from   mice2cages
            where  m2c_datetime_to IS NULL
            group  by mouse_id
            having number_of_cages <> ?
           );

  @sql_parameters = (1);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows == 0) {
     $page .= p("... no errors found");
  }
  else {
     $page .= p("... multiple cage/location entries for the following mouse/mice")
              . start_table({-border=>1})
              . Tr(
                  th('mouse ID'),
                  th('number of cages')
                );

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $page .= Tr(
                    td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $row->{'mouse_id'}}, $row->{'mouse_id'})),
                    td({-align=>'right'}, $row->{'number_of_cages'})
                  );
      }

      $page .= end_table();
  }

  return $page;
}
# end of check_database_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_REP005b check_database_2():                            check database subroutine 2
sub check_database_2 {                                      my $sr_name = 'SR_REP005b';
  my ($global_var_href) = @_;                               # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # Checking for living mice with wrong status

  $sql = qq(select mouse_id, dr1.death_reason_name as how, dr2.death_reason_name as why
            from   mice
                   join death_reasons dr1 on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2 on  mouse_deathorexport_why = dr2.death_reason_id
            where  mouse_deathorexport_datetime IS NULL
                   and (mouse_deathorexport_how <> ?
                        OR
                        mouse_deathorexport_why <> ?
                       )
           );

  @sql_parameters = (1, 2);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows == 0) {
     $page .= p("... no errors found");
  }
  else {
     $page .= p("... found living mice with wrong status")
              . start_table({-border=>1})
              . Tr(
                  th('mouse ID'),
                  th('date of death'),
                  th('how'),
                  th('why')
                );

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $page .= Tr(
                    td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $row->{'mouse_id'}}, $row->{'mouse_id'})),
                    td('-'),
                    td($row->{'how'}),
                    td($row->{'why'})
                  );
      }

      $page .= end_table();
  }

  return $page;
}
# end of check_database_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_REP005c check_database_3():                            check database subroutine 3
sub check_database_3 {                                      my $sr_name = 'SR_REP005c';
  my ($global_var_href) = @_;                               # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # Checking for living mice in wrong cage

  $sql = qq(select mouse_id, dr1.death_reason_name as how, dr2.death_reason_name as why, m2c_cage_id
            from   mice
                   join death_reasons dr1 on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2 on  mouse_deathorexport_why = dr2.death_reason_id
                   join mice2cages        on             m2c_mouse_id = mouse_id
            where  mouse_deathorexport_datetime IS NULL
                   and m2c_datetime_to IS NULL
                   and m2c_cage_id < ?
           );

  @sql_parameters = (0);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows == 0) {
     $page .= p("... no errors found");
  }
  else {
     $page .= p("... found living mice with wrong status")
              . start_table({-border=>1})
              . Tr(
                  th('mouse ID'),
                  th('date of death'),
                  th('how'),
                  th('why'),
                  th('cage')
                );

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $page .= Tr(
                    td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $row->{'mouse_id'}}, $row->{'mouse_id'})),
                    td('-'),
                    td($row->{'how'}),
                    td($row->{'why'}),
                    td($row->{'m2c_cage_id'})
                  );
      }

      $page .= end_table();
  }

  return $page;
}
# end of check_database_3()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_REP005d check_database_4():                            check database subroutine 4
sub check_database_4 {                                      my $sr_name = 'SR_REP005d';
  my ($global_var_href) = @_;                               # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # Checking for dead mice with wrong status

  $sql = qq(select mouse_id, mouse_deathorexport_datetime, dr1.death_reason_name as how, dr2.death_reason_name as why
            from   mice
                   join death_reasons dr1 on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2 on  mouse_deathorexport_why = dr2.death_reason_id
            where  not (mouse_deathorexport_datetime IS NULL)
                   and (mouse_deathorexport_how = ?
                        OR
                        mouse_deathorexport_why = ?
                       )
           );

  @sql_parameters = (1, 2);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows == 0) {
     $page .= p("... no errors found");
  }
  else {
     $page .= p("... found dead mice with wrong status")
              . start_table({-border=>1})
              . Tr(
                  th('mouse ID'),
                  th('date of death'),
                  th('how'),
                  th('why')
                );

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $page .= Tr(
                    td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $row->{'mouse_id'}}, $row->{'mouse_id'})),
                    td(format_sql_datetime2display_datetime($row->{'mouse_deathorexport_datetime'})),
                    td($row->{'how'}),
                    td($row->{'why'})
                  );
      }

      $page .= end_table();
  }

  return $page;
}
# end of check_database_4()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_REP005e check_database_5():                            check database subroutine 5
sub check_database_5 {                                      my $sr_name = 'SR_REP005e';
  my ($global_var_href) = @_;                               # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # Checking for dead mice in wrong cage

  $sql = qq(select mouse_id, mouse_deathorexport_datetime, dr1.death_reason_name as how, dr2.death_reason_name as why, m2c_cage_id
            from   mice
                   join death_reasons dr1 on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2 on  mouse_deathorexport_why = dr2.death_reason_id
                   join mice2cages        on             m2c_mouse_id = mouse_id
            where  not (mouse_deathorexport_datetime IS NULL)
                   and m2c_datetime_to IS NULL
                   and m2c_cage_id > ?
           );

  @sql_parameters = (0);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows == 0) {
     $page .= p("... no errors found");
  }
  else {
     $page .= p("... found dead mice with wrong status")
              . start_table({-border=>1})
              . Tr(
                  th('mouse ID'),
                  th('date of death'),
                  th('how'),
                  th('why'),
                  th('cage')
                );

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $page .= Tr(
                    td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $row->{'mouse_id'}}, $row->{'mouse_id'})),
                    td(format_sql_datetime2display_datetime($row->{'mouse_deathorexport_datetime'})),
                    td($row->{'how'}),
                    td($row->{'why'}),
                    td($row->{'m2c_cage_id'})
                  );
      }

      $page .= end_table();
  }

  return $page;
}
# end of check_database_5()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_REP005f check_database_6():                            check database subroutine 6
sub check_database_6 {                                      my $sr_name = 'SR_REP005f';
  my ($global_var_href) = @_;                               # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;
  my %cage_count;
  my @error_cages;

  # Checking for errors in cage status

  # get all cages which have the 'occupied' flag
  $sql = qq(select cage_id
            from   cages
            where  cage_occupied = ?
                   and   cage_id > ?
           );

  @sql_parameters = ('y', 0);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      $cage_count{$row->{'cage_id'}}++;
  }

  # get all cages which have no end datetime in table 'mice2cages'
  $sql = qq(select distinct m2c_cage_id
            from   mice2cages
            where  m2c_datetime_to IS NULL
                   and   m2c_cage_id > ?
           );

  @sql_parameters = (0);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      $cage_count{$row->{'m2c_cage_id'}}++;
  }

  # no check for cages that did not occur in both result lists
  foreach (keys %cage_count) {
     if ($cage_count{$_} != 2) {
        push(@error_cages, $_);
     }
  }

  if (scalar(@error_cages) == 0) {
     $page .= p("... no errors found");
  }
  else {
     $page .= p("... please check status of the following cages: ")
              . p('cage list: ' . join(',', @error_cages));
  }

  return $page;
}
# end of check_database_6()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_REP005g check_database_7():                            check database subroutine 7
sub check_database_7 {                                      my $sr_name = 'SR_REP005g';
  my ($global_var_href) = @_;                               # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # Checking for errors in cage moves

  # find all cages with more than one current rack location
  $sql = qq(select c2l_cage_id as cage, count(c2l_location_id) as current_locations
            from   cages2locations
            where  c2l_datetime_to is null
            group  by c2l_cage_id
            having current_locations > ?
           );

  @sql_parameters = (1);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows == 0) {
     $page .= p("... no errors found");
  }
  else {
     $page .= p("... multiple current rack entries for the following cage(s)")
              . start_table({-border=>1})
              . Tr(
                  th('cage ID'),
                  th('number of current racks')
                );

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $page .= Tr(
                    td(a({-href=>"$url?choice=show_cage&cage_id=" . $row->{'cage_id'}}, $row->{'cage_id'})),
                    td({-align=>'right'}, $row->{'current_locations'})
                  );
      }

      $page .= end_table();
  }

  return $page;
}
# end of check_database_7()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_REP005h check_database_8():                            check database subroutine 8
sub check_database_8 {                                      my $sr_name = 'SR_REP005h';
  my ($global_var_href) = @_;                               # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;
  my ($query_column, $table_string);
  my @check_tables;

  # Checking tables

  # collect all tables to check
  $query_column = 'Tables_in_' . $global_var_href->{'db_name'};

  $sql = qq(show tables);

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@check_tables, $row->{$query_column});
  }

  $table_string = join(', ', @check_tables);

  $sql = qq(CHECK TABLE $table_string);

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows == 0) {
     $page .= p("... no errors found");
  }
  else {
     $page .= p("... result of checking tables")
              . start_table({-border=>1})
              . Tr(
                  th('Table'),
                  th('Op'),
                  th('Msg_type'),
                  th('Msg_text')
                );

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $page .= Tr(
                    td($row->{'Table'}),
                    td($row->{'Op'}),
                    td($row->{'Msg_type'}),
                    td($row->{'Msg_text'})
                  );
      }

      $page .= end_table();
  }

  return $page;
}
# end of check_database_8()
#--------------------------------------------------------------------------------------




#--------------------------------------------------------------------------------------
# SR_REP005i check_database_9():                            check database subroutine 9
sub check_database_9 {                                      my $sr_name = 'SR_REP005i';
  my ($global_var_href) = @_;                               # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # Checking for errors in experiment status

  # find mice where alive/dead status does not match experiment_end status
  $sql = qq(select mouse_id, mouse_deathorexport_datetime, m2e_datetime_to
            from   mice
                   join mice2experiments on mouse_id = m2e_mouse_id
            where  ( (mouse_deathorexport_datetime is null and m2e_datetime_to is not null)
                     or
                     (mouse_deathorexport_datetime is not null and m2e_datetime_to is null)
                   )
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows == 0) {
     $page .= p("... no errors found");
  }
  else {
     $page .= p("... mice with mismatch in date of death and experiment end:")
              . start_table({-border=>1})
              . Tr(
                  th('mouse ID'),
                  th('date/time of death'),
                  th('date/time of experiment end')
                );

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $page .= Tr(
                    td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $row->{'mouse_id'}}, $row->{'mouse_id'})),
                    td({-align=>'right'}, format_sql_datetime2display_datetime($row->{'mouse_deathorexport_datetime'})),
                    td({-align=>'right'}, format_sql_datetime2display_datetime($row->{'m2e_datetime_to'}))
                  );
      }

      $page .= end_table();
  }

  return $page;
}
# end of check_database_9()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_REP005 check_database():                            check database
sub check_database {                                     my $sr_name = 'SR_REP005';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  $page = h2("Check database (" . $global_var_href->{'db_name'} . '@' . $global_var_href->{'db_server'} . ")")
          . hr();

  #---------------------------------------------------------------
  $page .= p(b("1) Checking for errors in mouse cage/location tables ..."));
  $page .= check_database_1($global_var_href);
  #---------------------------------------------------------------

  #---------------------------------------------------------------
  $page .= p(b("2) Checking for living mice with wrong status ..."));
  $page .= check_database_2($global_var_href);
  #---------------------------------------------------------------

  #---------------------------------------------------------------
  $page .= p(b("3) Checking for living mice in wrong cage ..."));
  $page .= check_database_3($global_var_href);
  #---------------------------------------------------------------

  #---------------------------------------------------------------
  $page .= p(b("4) Checking for dead mice with wrong status ..."));
  $page .= check_database_4($global_var_href);
  #---------------------------------------------------------------

  #---------------------------------------------------------------
  $page .= p(b("5) Checking for dead mice in wrong cage ..."));
  $page .= check_database_5($global_var_href);
  #---------------------------------------------------------------

  #---------------------------------------------------------------
  $page .= p(b("6) Checking for errors in cage status ..."));
  $page .= check_database_6($global_var_href);
  #---------------------------------------------------------------

  #---------------------------------------------------------------
  $page .= p(b("7) Checking for errors in cage moves ..."));
  $page .= check_database_7($global_var_href);
  #---------------------------------------------------------------

  #---------------------------------------------------------------
  $page .= p(b("8) Checking tables ..."));
  $page .= check_database_8($global_var_href);
  #---------------------------------------------------------------

  #---------------------------------------------------------------
  $page .= p(b("9) Checking for errors in experiment status ..."));
  $page .= check_database_9($global_var_href);
  #---------------------------------------------------------------

  return $page;
}
# end of check_database()
#--------------------------------------------------------------------------------------




#--------------------------------------------------------------------------------------
# SR_REP006 versuchstiermeldung_1():                     versuchstiermeldung start form
sub versuchstiermeldung_1 {                              my $sr_name = 'SR_REP006';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my ($page, $sql, $result, $rows, $row, $i);
  my @years  = (2000..2015);                             # ordered list of years
  my %experiment_labels;                                 # map experiment ids to experiment names
  my @experiments;
  my @sql_parameters;

  # get list of all experiments for popup-menu
  $sql = qq(select experiment_id, experiment_name
            from   experiments
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $experiment_labels{$row->{'experiment_id'}} = $row->{'experiment_name'};
  }

  @experiments = sort keys %experiment_labels;

  # start over...
  $page = h2("Versuchstiermeldung (monthly)")
          . hr()
          . h3("Generate a \"Versuchstiermeldung\" ... ")
          . p("(number of mice that started into experiment each month)")
          . start_form(-action => url())

          . table({-border=>0},
               Tr( th("Choose experiment: "),
                   td(popup_menu( -name    => "experiment",
                                  -values  => [@experiments],
                                  -labels  => \%experiment_labels,
                                  -default => 1
                      )
                   )
               ) .

               Tr( th("Choose year: "),
                   td(popup_menu( -name    => "year",
                                  -values  => [@years],
                                  -default => 2006
                     )
                   )
               )
            )

          . br()
          . submit(-name => "choice", -value=>"generate Versuchstiermeldung")

          . end_form();

  return $page;
}
# end of versuchstiermeldung_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_REP007 versuchstiermeldung_2():                     versuchstiermeldung
sub versuchstiermeldung_2 {                              my $sr_name = 'SR_REP007';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $url               = url();
  my $experiment        = param('experiment');
  my $year              = param('year');
  my $month_filter_sql;
  my ($page, $sql, $mice_this_month);
  my @experiments;
  my @months = (1..12);                                  # ordered list of numeric months :-)
  my %month_names = (1 => 'Jan', 2 => 'Feb', 3 => 'Mar',  4 => 'Apr',  5 => 'May',  6 => 'Jun',          # map month numbers to names
                     7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec');
  my ($experiment_name, $month, $mouse_counter_total, $mouse_counter_gvo, $mouse_counter_ngvo);
  my $year_sum_total = 0;
  my $year_sum_gvo   = 0;
  my $year_sum_ngvo  = 0;
  my @sql_parameters;

  # check if year given and in valid format
  if (!param('year') || param('year') !~ /^[0-9]{4}$/ || param('year') < 2000 || param('year') > 2015) {
      $page .= h2("Versuchstiermeldung")
               . hr()
               . p({-class=>'red'}, "Invalid year ");
      return $page;
  }

  # check if experiment given and in valid format
  if (!param('experiment') || param('experiment') !~ /^[0-9]+$/) {
      $page .= h2("Versuchstiermeldung")
               . hr()
               . p({-class=>'red'}, "Invalid experiment");
      return $page;
  }
  # ok, experiment id is given and formally valid, now check if experiment really exists
  else {
      # get experiment name by its id
      ($experiment_name) = $dbh->selectrow_array("select experiment_name
                                                  from   experiments
                                                  where  experiment_id = $experiment
                                                 ");
      # raise error if no such experiment found
      if (!defined($experiment_name)) {
         $page .= h2("Versuchstiermeldung")
                  . hr()
                  . p({-class=>'red'}, "No such experiment");
         return $page;
      }
  }

  # everything fine, so start...
  $page = h2("Versuchstiermeldung " . '[' . a({-href=>"$url?choice=versuchstiermeldung_start"}, 'new') . ']')
          . hr()
          . table({-border=>0},
               Tr( th({-colspan=>2}, "Mice that started into ")
               ),
               Tr( th("experiment:"),
                   td($experiment_name)
               ),
               Tr( th("in year"),
                   td($year)
               )
            )

          . p()

          . start_table( {-border=>"1", -summary=>"TEP"})
          . Tr( {-align=>'center'},
                th({-rowspan=>2}, "Experiment"),
                th({-colspan=>4}, "number")
            )
          . Tr( {-align=>'center'},
                th("GVO"),
                th("Non-GVO"),
                td(),
                th("total")
            );

  # loop over months
  foreach $month (@months) {
     # reset counter
     $mouse_counter_total = 0;
     $mouse_counter_gvo   = 0;
     $mouse_counter_ngvo  = 0;

     # set filter for this month in sql (prepare for LIKE search)
     $month_filter_sql = $year . '-' . reformat_number($month, 2) . '%';

     #################################################################
     # select all mice that went into chosen experiment in this month
     $sql = qq(select count(m2e_mouse_id) as mice_this_month
               from   mice2experiments
                      join mice on m2e_mouse_id = mouse_id
               where  m2e_datetime_from like ?
                      and m2e_experiment_id = ?
                      and mouse_origin_type in ('import', 'weaning')
              );

     @sql_parameters = ($month_filter_sql, $experiment);

     ($mice_this_month) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

     # total
     if   (defined($mice_this_month) && $mice_this_month > 0) { $mouse_counter_total = $mice_this_month; }
     else                                                     { $mouse_counter_total = 0;                }

     #################################################################
     # select all mice that went into chosen experiment in this month: gvo
     $sql = qq(select count(m2e_mouse_id) as mice_this_month
               from   mice2experiments
                      join mice on m2e_mouse_id = mouse_id
               where  m2e_datetime_from like ?
                      and m2e_experiment_id = ?
                      and mouse_origin_type in ('import', 'weaning')
                      and mouse_is_gvo = ?
              );

     @sql_parameters = ($month_filter_sql, $experiment, 'y');

     ($mice_this_month) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

     # gvo
     if   (defined($mice_this_month) && $mice_this_month > 0) { $mouse_counter_gvo = $mice_this_month; }
     else                                                     { $mouse_counter_gvo = 0;                }

     #################################################################
     # select all mice that went into chosen experiment in this month: non-gvo
     @sql_parameters = ($month_filter_sql, $experiment, 'n');

     ($mice_this_month) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

     # non-gvo
     if   (defined($mice_this_month) && $mice_this_month > 0) { $mouse_counter_ngvo = $mice_this_month; }
     else                                                     { $mouse_counter_ngvo = 0;                }



     # cumulate over year
     $year_sum_gvo   += $mouse_counter_gvo;
     $year_sum_ngvo  += $mouse_counter_ngvo;
     $year_sum_total += $mouse_counter_total;

     $page .= Tr({-align=>'center'},
                 th({-align=>'left'},  $month_names{$month}),
                 td({-align=>'right'}, $mouse_counter_gvo),
                 td({-align=>'right'}, $mouse_counter_ngvo),
                 td(),
                 td({-align=>'right'}, $mouse_counter_total)
              );
  }

  $page .=   Tr( td({-colspan=>5}, ' ')
             )
           . Tr({-align=>'center'},
                 th({-align=>'left'}, 'TOTAL'),
                 td({-align=>'right'}, b($year_sum_gvo)),
                 td({-align=>'right'}, b($year_sum_ngvo)),
                 td(),
                 td({-align=>'right'}, b($year_sum_total))
              )
           . end_table();

  return $page;
}
# end of versuchstiermeldung_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_REP008 animal_numbers_1():                          animal_numbers_1 start form
sub animal_numbers_1 {                                   my $sr_name = 'SR_REP008';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my ($page);

  # start over...
  $page = h2("Snapshot tail count")
          . hr()
          . h3("Calculate animal numbers for any point in time ")
          . start_form(-action => url())

          . table({-border=>0},
               Tr( th("Please define point in time: "),
                   td(textfield(-name => "point_in_time", -id=>"point_in_time", -size=>"20", -maxlength=>"21", -value=>get_current_datetime_for_display())
                      . "&nbsp;&nbsp;"
                      . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=point_in_time', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                     )
               ) .
               Tr( th("Please specify area: "),
                   td(get_area_popup_menu($global_var_href, 'area'))
               )
            )

          . submit(-name => "choice", -value=>"generate animal numbers")

          . end_form();

  return $page;
}
# end of animal_numbers_1()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_REP009 animal_numbers_2():                          calculate animal numbers for any point in time
sub animal_numbers_2 {                                   my $sr_name = 'SR_REP009';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $point_in_time     = param('point_in_time');
  my $area              = param('area');
  my $area_clean;
  my $point_in_time_sql;
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;
  my ($experiment);
  my $number_total_experiment_gvo     = 0;
  my $number_total_experiment_non_gvo = 0;
  my %animal_numbers;

  # date of point in time not given or invalid
  if (!param('point_in_time') || check_datetime_ddmmyyyy_hhmmss(param('point_in_time')) != 1) {
     $page .= p({-class=>"red"}, b("Error: point in time has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # prevent SQL injection: remove dangerous content
  $area_clean = $area;
  $area_clean =~ s/'|;|-{2}//g;

  # check input
  if (!param('area')) {
     $page .= p({-class=>"red"}, b("Error: area not valid "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # convert display datetime to SQL datetime
  $point_in_time_sql = format_display_datetime2sql_datetime($point_in_time);

  # prepare output
  $page = h2("Snapshot tail count")
          . hr()
          . h3("Calculate animal numbers for any point in time ")
          . hr({-align=>'left', -width=>'30%'});

  # prepare statement DATE_SUB(?, INTERVAL 1 SECOND)
  $sql = qq(select count(*) as number_total_living_gvo
            from   mice
                   left join imports         on mouse_import_id = import_id
                   left join litters         on mouse_litter_id = litter_id
                   left join mice2cages      on        mouse_id = m2c_mouse_id
                   left join cages2locations on     m2c_cage_id = c2l_cage_id
                   left join locations       on c2l_location_id = location_id
            where  ( ( mouse_origin_type = ?
                       and import_datetime <= DATE_SUB(?, INTERVAL 1 SECOND)
                       and mouse_is_gvo = ?
                       and ( (mouse_deathorexport_datetime is null)
                             or
                             (mouse_deathorexport_datetime > DATE_SUB(?, INTERVAL 1 SECOND))
                           )
                     )
                     or
                     ( mouse_origin_type = ?
                       and litter_weaning_datetime <= DATE_SUB(?, INTERVAL 1 SECOND)
                       and mouse_is_gvo = ?
                       and ( (mouse_deathorexport_datetime is null)
                             or
                             (mouse_deathorexport_datetime > DATE_SUB(?, INTERVAL 1 SECOND))
                           )
                     )
                   )
                   and mouse_origin_type in ('import', 'weaning')
                   and m2c_datetime_from <= DATE_SUB(?, INTERVAL 1 SECOND)
                   and (m2c_datetime_to  >  DATE_SUB(?, INTERVAL 1 SECOND)
                        or
                        m2c_datetime_to IS NULL
                       )
                   and c2l_datetime_from <= DATE_SUB(?, INTERVAL 1 SECOND)
                   and (c2l_datetime_to  >  DATE_SUB(?, INTERVAL 1 SECOND)
                        or
                        c2l_datetime_to IS NULL
                       )
                   and location_subbuilding = ?
         );

  # get total number of living GVO mice at point_in_time
  @sql_parameters = ('import', $point_in_time_sql, 'y', $point_in_time_sql, 'weaning', $point_in_time_sql, 'y', $point_in_time_sql,
                     $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $area_clean);
  ($animal_numbers{'total'}{'GVO'}) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # get total number of living non-GVO mice at point_in_time
  @sql_parameters = ('import', $point_in_time_sql, 'n', $point_in_time_sql, 'weaning', $point_in_time_sql, 'n', $point_in_time_sql,
                     $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $area_clean);
  ($animal_numbers{'total'}{'non-GVO'}) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # prepare statement (Lebendbestand total am Stichdatum mit Experimenten)
  $sql = qq(select count(m2e_mouse_id) as mouse_number, experiment_name
            from   mice
                   left join imports         on   mouse_import_id = import_id
                   left join litters         on   mouse_litter_id = litter_id
                   left join mice2cages      on          mouse_id = m2c_mouse_id
                   left join cages2locations on       m2c_cage_id = c2l_cage_id
                   left join locations       on   c2l_location_id = location_id
                   join mice2experiments     on      m2e_mouse_id = mouse_id
                   join experiments          on m2e_experiment_id = experiment_id
            where  ( ( mouse_origin_type = ?
                       and import_datetime <= DATE_SUB(?, INTERVAL 1 SECOND)
                       and mouse_is_gvo = ?
                       and ( (mouse_deathorexport_datetime is null)
                             or
                             (mouse_deathorexport_datetime > DATE_SUB(?, INTERVAL 1 SECOND))
                           )
                     )
                     or
                     ( mouse_origin_type = ?
                       and litter_weaning_datetime <= DATE_SUB(?, INTERVAL 1 SECOND)
                       and mouse_is_gvo = ?
                       and ( (mouse_deathorexport_datetime is null)
                             or
                             (mouse_deathorexport_datetime > DATE_SUB(?, INTERVAL 1 SECOND))
                           )
                     )
                   )
                   and
                   (m2e_datetime_from <= DATE_SUB(?, INTERVAL 1 SECOND))
                   and
                   ( (m2e_datetime_to > DATE_SUB(?, INTERVAL 1 SECOND))
                     or
                     (m2e_datetime_to is null)
                   )
                   and mouse_origin_type in ('import', 'weaning')
                   and m2c_datetime_from <= DATE_SUB(?, INTERVAL 1 SECOND)
                   and (m2c_datetime_to  >  DATE_SUB(?, INTERVAL 1 SECOND)
                        or
                        m2c_datetime_to IS NULL
                       )
                   and c2l_datetime_from <= DATE_SUB(?, INTERVAL 1 SECOND)
                   and (c2l_datetime_to  >  DATE_SUB(?, INTERVAL 1 SECOND)
                        or
                        c2l_datetime_to IS NULL
                       )
                   and location_subbuilding = ?
            group by m2e_experiment_id
           );

  # GVO
  @sql_parameters = ('import', $point_in_time_sql, 'y', $point_in_time_sql, 'weaning', $point_in_time_sql, 'y', $point_in_time_sql, $point_in_time_sql, $point_in_time_sql,
                     $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $area_clean);
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $animal_numbers{$row->{'experiment_name'}}{'GVO'} = $row->{'mouse_number'};
      $number_total_experiment_gvo += $row->{'mouse_number'};
  }

  # non-GVO
  @sql_parameters = ('import', $point_in_time_sql, 'n', $point_in_time_sql, 'weaning', $point_in_time_sql, 'n', $point_in_time_sql, $point_in_time_sql, $point_in_time_sql,
                     $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $area_clean);
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $animal_numbers{$row->{'experiment_name'}}{'non-GVO'} = $row->{'mouse_number'};
      $number_total_experiment_non_gvo += $row->{'mouse_number'};
  }

  $animal_numbers{'breeding'}{'GVO'}     = $animal_numbers{'total'}{'GVO'}     - $number_total_experiment_gvo;
  $animal_numbers{'breeding'}{'non-GVO'} = $animal_numbers{'total'}{'non-GVO'} - $number_total_experiment_non_gvo;

  $page .= p(b('Total number of living mice at '. $point_in_time . " in area: \"$area\""))
           . start_table({-border=>1})
           . Tr(th('Experiment'),
                th('GVO'),
                th('non-GVO'),
                th('sum (GVO + non-GVO)')
             );

  foreach $experiment (sort keys %animal_numbers) {
    $page .= Tr( td({-align=>'right'}, b($experiment)),
                 td({-align=>'right'}, defined($animal_numbers{$experiment}{'GVO'})?$animal_numbers{$experiment}{'GVO'}:'-'),
                 td({-align=>'right'}, defined($animal_numbers{$experiment}{'non-GVO'})?$animal_numbers{$experiment}{'non-GVO'}:'-'),
                 td({-align=>'right'}, $animal_numbers{$experiment}{'GVO'} + $animal_numbers{$experiment}{'non-GVO'})
             );
  }

  $page .= end_table();

  return $page;
}
# end of animal_numbers_2()
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------
# SR_REP010 animal_cage_time_1():                        calculate animal cage days (start form)
sub animal_cage_time_1 {                                 my $sr_name = 'SR_REP010';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my ($page);

  # start over...
  $page = h2("Animal cage occupation")
          . hr()
          . h3("Calculate animal cage occupation for a time range")
          . start_form(-action => url())

          . table({-border=>0},
               Tr( th("Please define a start date: "),
                   td(textfield(-name => "start_date", -id=>"start_date", -size=>"20", -maxlength=>"21", -value=>get_current_datetime_for_display())
                      . "&nbsp;&nbsp;"
                      . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=start_date', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                     )
               ) .
               Tr( th("Please define an end date: "),
                   td(textfield(-name => "end_date", -id=>"end_date", -size=>"20", -maxlength=>"21", -value=>get_current_datetime_for_display())
                      . "&nbsp;&nbsp;"
                      . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=end_date', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                     )
               ) .
               Tr( th("Please specify area: "),
                   td(get_area_popup_menu($global_var_href, 'area'))
               )
            )

          . submit(-name => "choice", -value=>"generate animal cage occupation")

          . end_form();

  return $page;
}
# end of animal_cage_time_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_REP011 animal_cage_time_2():                        calculate animal cage occupation for a time range
sub animal_cage_time_2 {                                 my $sr_name = 'SR_REP011';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session      		= $global_var_href->{'session'};
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $start_date        = param('start_date');
  my $end_date          = param('end_date');
  my $area              = param('area');
  my $username    		= $session->param(-name=>'username');
  my $area_clean;
  my $start_date_sql;
  my $end_date_sql;
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;
  my %animal_numbers;
  my ($number, $experiment, $number_total_experiment_gvo, $cost_centre);
  my ($number_total_experiment_non_gvo, $current_day, $point_in_time_sql, $day_add);
  my %cost_centres;
  
  my $ALL_total;
  my $page_temp;
  my @xls_row      = ();
  my ($excel_sheet, $local_filename, $data);

  # include a module to write tables as Excel file in a simple way
  use Spreadsheet::WriteExcel::Simple;
  # create a new excel sheet object
  $excel_sheet = Spreadsheet::WriteExcel::Simple->new;

  # start date not given or invalid
  if (!param('start_date') || check_datetime_ddmmyyyy_hhmmss(param('start_date')) != 1) {
     $page .= p({-class=>"red"}, b("Error: start date has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # end date not given or invalid
  if (!param('end_date') || check_datetime_ddmmyyyy_hhmmss(param('end_date')) != 1) {
     $page .= p({-class=>"red"}, b("Error: end date has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # make sure end_date is after start_date
  if (Delta_ddmmyyyhhmmss(param('end_date'), param('start_date')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: end date should be after start date "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # prevent SQL injection: remove dangerous content
  $area_clean = $area;
  $area_clean =~ s/'|;|-{2}//g;

  # check input
  if (!param('area')) {
     $page .= p({-class=>"red"}, b("Error: area not valid "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # convert display datetime to SQL datetime
  $start_date_sql = format_display_datetime2sql_datetime($start_date);
  $end_date_sql   = format_display_datetime2sql_datetime($end_date);

  # prepare output
  $page .= h2("Animal cage occupation in area: \"$area\"")
          . hr()
          . h3("Total number of mouse days from \""
               . b(format_sql_datetime2display_date($start_date_sql))
               . "\" to \""
               . b(format_sql_datetime2display_date($end_date_sql))
               . "\" in area: \"$area\""
            )
          . hr({-align=>'left', -width=>'30%'});

	#prepare Excel output
	# create a unique filename (using combination of user name and time) for server-side storage of temporary Excel file
    $local_filename = $username . '_' . time() . '.xls';
	@xls_row = ("Animal cage occupation in area: \"$area\"");
    $excel_sheet->write_bold_row(\@xls_row);
    @xls_row = ("");
    $excel_sheet->write_row(\@xls_row);
    @xls_row = ("Total number of mouse days from \"". (format_sql_datetime2display_date($start_date_sql))
    		."\" to \"".
    		(format_sql_datetime2display_date($end_date_sql)). "\" in area: \"$area\"");
  	$excel_sheet->write_bold_row(\@xls_row);
  	
  	#three empty rows
  	@xls_row = ("");
    $excel_sheet->write_row(\@xls_row);
    @xls_row = ("");
    $excel_sheet->write_row(\@xls_row);
    @xls_row = ("");
    $excel_sheet->write_row(\@xls_row);
  	
  	$page .= start_form(-action => url());
    $page .= submit(-name => "choice", -value=>"generate Excel report");
    $page .= hidden(-name => "local_filename", -value=>$local_filename);
    $page .= end_form();

  # write cost centres to a hash
  $sql = qq(select cost_account_id, cost_account_name
            from   cost_accounts
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and generate user lookup hash table
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $cost_centres{$row->{'cost_account_id'}} = $row->{'cost_account_name'};
  }

  # loop over all cost centres
  foreach $cost_centre (sort keys %cost_centres) {

     # init
     $day_add = 0;
     %animal_numbers = ();
     $number_total_experiment_gvo = 0;
     $number_total_experiment_non_gvo = 0;

     # loop over all days between start_date and end_date, both inclusive
     # we collect all mice that sit in an area at 12:00 for every day during this time period
     while (add_to_date($global_var_href, format_display_datetime2sql_date($start_date), $day_add)
            ne
            add_to_date($global_var_href, format_display_datetime2sql_date($end_date), 1)
           ) {

        # determine the current loop day
        $current_day = add_to_date($global_var_href, format_display_datetime2sql_date($start_date), $day_add++);
        $point_in_time_sql = $current_day . ' 12:00:00';

        # prepare statement
        $sql = qq(select count(*) as number_total_living_gvo
                  from   mice
                         left join imports            on mouse_import_id = import_id
                         left join litters            on mouse_litter_id = litter_id
                         left join mice2cages         on        mouse_id = m2c_mouse_id
                         left join cages2locations    on     m2c_cage_id = c2l_cage_id
                         left join locations          on c2l_location_id = location_id
                         left join mice2cost_accounts on        mouse_id = m2ca_mouse_id
                  where  ( ( mouse_origin_type = ?
                             and import_datetime <= DATE_SUB(?, INTERVAL 1 SECOND)
                             and mouse_is_gvo = ?
                             and ( (mouse_deathorexport_datetime is null)
                                   or
                                   (mouse_deathorexport_datetime > DATE_SUB(?, INTERVAL 1 SECOND))
                                 )
                           )
                           or
                           ( mouse_origin_type = ?
                             and litter_weaning_datetime <= DATE_SUB(?, INTERVAL 1 SECOND)
                             and mouse_is_gvo = ?
                             and ( (mouse_deathorexport_datetime is null)
                                   or
                                   (mouse_deathorexport_datetime > DATE_SUB(?, INTERVAL 1 SECOND))
                                 )
                           )
                         )
                         and mouse_origin_type in ('import', 'weaning')
                         and m2c_datetime_from < ?
                         and (m2c_datetime_to  > ?
                              or
                              m2c_datetime_to IS NULL
                             )
                         and c2l_datetime_from < ?
                         and (c2l_datetime_to  > ?
                              or
                              c2l_datetime_to IS NULL
                             )
                         and location_subbuilding = ?
                         and m2ca_datetime_from < ?
                         and (m2ca_datetime_to  > ?
                              or
                              m2ca_datetime_to IS NULL
                             )
                         and m2ca_cost_account_id = ?
               );

        # get total number of living GVO mice at point_in_time
        @sql_parameters = ('import', $point_in_time_sql, 'y', $point_in_time_sql, 'weaning', $point_in_time_sql, 'y', $point_in_time_sql,
                           $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $area_clean, $point_in_time_sql, $point_in_time_sql, $cost_centre);
        ($number) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

        $animal_numbers{'total'}{'GVO'} += $number;

		#total number of mice for all cost centres
		$ALL_total += $number;

        # get total number of living non-GVO mice at point_in_time
        @sql_parameters = ('import', $point_in_time_sql, 'n', $point_in_time_sql, 'weaning', $point_in_time_sql, 'n', $point_in_time_sql,
                           $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $area_clean, $point_in_time_sql, $point_in_time_sql, $cost_centre);
        ($number) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

        $animal_numbers{'total'}{'non-GVO'} += $number;

		#total number of mice for all cost centres
		$ALL_total += $number; 

        ####################################################

        # prepare statement (Lebendbestand total am Stichdatum mit Experimenten)
        $sql = qq(select count(m2e_mouse_id) as mouse_number, experiment_name
                  from   mice
                         left join imports            on   mouse_import_id = import_id
                         left join litters            on   mouse_litter_id = litter_id
                         left join mice2cages         on          mouse_id = m2c_mouse_id
                         left join cages2locations    on       m2c_cage_id = c2l_cage_id
                         left join locations          on   c2l_location_id = location_id
                         left join mice2cost_accounts on          mouse_id = m2ca_mouse_id
                         join mice2experiments        on      m2e_mouse_id = mouse_id
                         join experiments             on m2e_experiment_id = experiment_id
                  where  ( ( mouse_origin_type = ?
                             and import_datetime <= DATE_SUB(?, INTERVAL 1 SECOND)
                             and mouse_is_gvo = ?
                             and ( (mouse_deathorexport_datetime is null)
                                   or
                                   (mouse_deathorexport_datetime > DATE_SUB(?, INTERVAL 1 SECOND))
                                 )
                           )
                           or
                           ( mouse_origin_type = ?
                             and litter_weaning_datetime <= DATE_SUB(?, INTERVAL 1 SECOND)
                             and mouse_is_gvo = ?
                             and ( (mouse_deathorexport_datetime is null)
                                   or
                                   (mouse_deathorexport_datetime > DATE_SUB(?, INTERVAL 1 SECOND))
                                 )
                           )
                         )
                         and
                         (m2e_datetime_from <= DATE_SUB(?, INTERVAL 1 SECOND))
                         and
                         ( (m2e_datetime_to > DATE_SUB(?, INTERVAL 1 SECOND))
                           or
                           (m2e_datetime_to is null)
                         )
                         and mouse_origin_type in ('import', 'weaning')
                         and m2c_datetime_from < ?
                         and (m2c_datetime_to  > ?
                              or
                              m2c_datetime_to IS NULL
                             )
                         and c2l_datetime_from < ?
                         and (c2l_datetime_to  > ?
                              or
                              c2l_datetime_to IS NULL
                             )
                         and location_subbuilding = ?
                         and m2ca_datetime_from < ?
                         and (m2ca_datetime_to  > ?
                              or
                              m2ca_datetime_to IS NULL
                             )
                         and m2ca_cost_account_id = ?
                  group by m2e_experiment_id
               );

        # GVO
        @sql_parameters = ('import', $point_in_time_sql, 'y', $point_in_time_sql, 'weaning', $point_in_time_sql, 'y', $point_in_time_sql, $point_in_time_sql, $point_in_time_sql,
                           $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $area_clean, $point_in_time_sql, $point_in_time_sql, $cost_centre);
        ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

        for ($i=0; $i<$rows; $i++) {
            $row = $result->[$i];

            $animal_numbers{$row->{'experiment_name'}}{'GVO'} += $row->{'mouse_number'};
            $number_total_experiment_gvo += $row->{'mouse_number'};
        }

        # non-GVO
        @sql_parameters = ('import', $point_in_time_sql, 'n', $point_in_time_sql, 'weaning', $point_in_time_sql, 'n', $point_in_time_sql, $point_in_time_sql, $point_in_time_sql,
                           $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $point_in_time_sql, $area_clean, $point_in_time_sql, $point_in_time_sql, $cost_centre);
        ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

        for ($i=0; $i<$rows; $i++) {
            $row = $result->[$i];

            $animal_numbers{$row->{'experiment_name'}}{'non-GVO'} += $row->{'mouse_number'};
            $number_total_experiment_non_gvo += $row->{'mouse_number'};
        }

     } # end of the while - loop

     $animal_numbers{'breeding'}{'GVO'}     = $animal_numbers{'total'}{'GVO'}     - $number_total_experiment_gvo;
     $animal_numbers{'breeding'}{'non-GVO'} = $animal_numbers{'total'}{'non-GVO'} - $number_total_experiment_non_gvo;

	#added temp page to add sum of all animal numbers
     $page_temp .= p(b("Cost centre: " . $cost_centres{$cost_centre}))
              . start_table({-border=>1})
              . Tr(th('Experiment'),
                   th('GVO'),
                   th('non-GVO'),
                   th('sum (GVO + non-GVO)')
                );
                
     @xls_row = ("Cost centre: " . $cost_centres{$cost_centre});
     $excel_sheet->write_bold_row(\@xls_row);
     @xls_row = ('Experiment', 'GVO', 'non-GVO', 'sum (GVO + non-GVO)');
     $excel_sheet->write_bold_row(\@xls_row);

     foreach $experiment (sort keys %animal_numbers) {
       $page_temp .= Tr( td({-align=>'right'}, b($experiment)),
                    td({-align=>'right'}, defined($animal_numbers{$experiment}{'GVO'})?$animal_numbers{$experiment}{'GVO'}:'-'),
                    td({-align=>'right'}, defined($animal_numbers{$experiment}{'non-GVO'})?$animal_numbers{$experiment}{'non-GVO'}:'-'),
                    td({-align=>'right'}, $animal_numbers{$experiment}{'GVO'} + $animal_numbers{$experiment}{'non-GVO'})
                );
                
       @xls_row = ($experiment,
       				defined($animal_numbers{$experiment}{'GVO'})?$animal_numbers{$experiment}{'GVO'}:'-',
       				defined($animal_numbers{$experiment}{'non-GVO'})?$animal_numbers{$experiment}{'non-GVO'}:'-',
       				$animal_numbers{$experiment}{'GVO'} + $animal_numbers{$experiment}{'non-GVO'});
       $excel_sheet->write_row(\@xls_row);
     }

	 #empty row
	 @xls_row = ("");
	 $excel_sheet->write_row(\@xls_row);

     $page_temp .= end_table()
              . hr();

  } # foreach loop over cost centres

	#add sum of all mice at the beginning of the page
	$page .= p(b('total number of all mice: '), $ALL_total);
	$page .= $page_temp;
	
	my $sheet = $excel_sheet->sheet;
	$sheet->write('4','0','total number of all mice: ');
	$sheet->write('4','3',$ALL_total);

	# ... save Excel object to local Excel file
  	$excel_sheet->save("./files/$local_filename");

  return $page;
}
# end of animal_cage_time_2()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_REP012 blob_info():                                     info about the blob database
sub blob_info {                                              my $sr_name = 'SR_REP012';
  my ($global_var_href) = @_;                                     # get reference to global vars hash
  my $blob_database     = $global_var_href->{'blob_database'};    # name of the blob_database
  my ($page, $sql, $number_of_blobs, $total_size);
  my @sql_parameters;

  $page = h2("Blob database info")
          . hr();

  # how many entries in the blob database
  $sql = qq(select count(blob_id)
            from   $blob_database.blob_data
         );

  @sql_parameters = ();

  ($number_of_blobs) =  @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # total size of all entries in the blob database
  $sql = qq(select sum(length(blob_itself)+length(blob_comment)) as total_size
            from   $blob_database.blob_data
         );

  @sql_parameters = ();

  ($total_size) =  @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $page .= table({-border=>1},
              Tr( th('number of files in the blob database'),
                  td($number_of_blobs)
              ) .
              Tr( th('total size of all files in the blob database' . br() . '(in compressed format)'),
                  td(round_number($total_size / 1024 / 1024, 0) . ' MB')
              )
           );

  return $page;
}
# end of blob_info()
#-------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_REP013 statistics():                                     some basic database statistics
sub statistics {                                              my $sr_name = 'SR_REP013';
  my ($global_var_href) = @_;                                 # get reference to global vars hash
  my ($page);
  my ($total_mice, $living_mice, $max_mouse_id, $total_lines, $alive_lines,
      $free_cages, $total_cage_capacity, $number_medical_records, $distinct_mr_mice) = db_stats($global_var_href);

  $page = h2("Some basic database statistics")
          . hr();


  $page .= table({-border=>1},
              Tr( th('number of mice (total)'),
                  td($total_mice)
              ) .
              Tr( th('number of mice (alive)'),
                  td($living_mice)
              ) .
              Tr( th('max mouse_id'),
                  td($max_mouse_id)
              ) .
              Tr( th('number of lines (total)'),
                  td($total_lines)
              ) .
              Tr( th('number of lines (with living mice)'),
                  td($alive_lines)
              ) .
              Tr( th('number of free cages'),
                  td($free_cages)
              ) .
              Tr( th('total rack capacity (cages)'),
                  td($total_cage_capacity)
              ) .
              Tr( th('total number of medical records'),
                  td($number_medical_records)
              ) .
              Tr( th('total number of distinct ' . br() . 'mice with medical records'),
                  td($distinct_mr_mice)
              )
           );

  return $page;
}
# end of statistics()
#-------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_REP014 start_GTAS_report_to_excel():                GTAS report start form
sub start_GTAS_report_to_excel {                         my $sr_name = 'SR_REP014';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my ($page);

  $page = h2("GTAS report")
          . hr()
          . h3("Generate a GTAS report ... ")
          . start_form(-action => url())

          . p("A GTAS report for genetically modified mouse lines will be generated in Excel format.")

          . p("Please decide if status of reported mouse lines should be set on \"already reported\" after generating the report.")

          . p(radio_group(-name=>'gli_generate_GTAS_report', -values=>['y', 'n'], -default=>' ')
              . br()
              . submit(-name => "choice", -value=>"generate GTAS report")
            )

          . end_form()

          . p("A GTAS Excel file will be produced upon pressing the button. You can download the file to your local system or open it directly.");

  return $page;
}
# end of start_GTAS_report_to_excel()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_REP015 GTAS_report_to_excel                         generate GTAS report in Excel format
sub GTAS_report_to_excel {                               my $sr_name = 'SR_REP015';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session      = $global_var_href->{'session'};      # get session handle
  my $dbh          = $global_var_href->{'dbh'};          # DBI database handle
  my $username     = $session->param(-name=>'username');
  my $url          = url();
  my @xls_row      = ();
  my ($excel_sheet, $local_filename, $data);
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # include a module to write tables as Excel file in a simple way
  use Spreadsheet::WriteExcel::Simple;

  # create a new excel sheet object
  $excel_sheet = Spreadsheet::WriteExcel::Simple->new;

  # create a unique filename (using combination of user name and time) for server-side storage of temporary Excel file
  $local_filename = $username . '_' . time() . '.xls';
  @xls_row = ('Projektnr', 'Institutscode', 'Bemerkungen', 'Spenderorganismen', 'Nukleinsaeure_Bezeichnung', 'Nukleinsaeure_Merkmale',
              'Vektoren',  'Empfaengerorganismen', 'GVO_Merkmale', 'GVO_ErzeugtAm', 'Risikogruppe_Empfaenger', 'Risikogruppe_GVO',
              'Risikogruppe_Spender', 'Lagerung', 'Sonstiges', 'TepID', 'SysID', 'GVO_EntsorgtAm', 'OrgCode');

  # write header line to Excel file
  $excel_sheet->write_row(\@xls_row);

  $page .= h3("GTAS report")
           . hr();

  # collect some details about mice in cart
  $sql = qq(select *
            from   GTAS_line_info
            where  gli_mouse_line_is_gvo = 'y'
                   and gli_generate_GTAS_report = 'y'
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no GTAS information found: tell user and exit
  unless ($rows > 0) {
     $page .= p("No GTAS information found ");
     return $page;
  }

  # proceed with displaying details about mice in cart
  $page .= p("Found GTAS line info");

  # loop over all results
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     @xls_row = ($row->{'gli_Projektnr'},
                 $row->{'gli_Institutscode'},
                 $row->{'gli_Bemerkungen'},
                 $row->{'gli_Spenderorganismen'},
                 $row->{'gli_Nukleinsaeure_Bezeichnung'},
                 $row->{'gli_Nukleinsaeure_Merkmale'},
                 $row->{'gli_Vektoren'},
                 $row->{'gli_Empfaengerorganismen'},
                 $row->{'gli_GVO_Merkmale'},
                 format_sql_date2display_date($row->{'gli_GVO_ErzeugtAm'}),
                 $row->{'gli_Risikogruppe_Empfaenger'},
                 $row->{'gli_Risikogruppe_GVO'},
                 $row->{'gli_Risikogruppe_Spender'},
                 $row->{'gli_Lagerung'},
                 $row->{'gli_Sonstiges'},
                 $row->{'gli_TepID'},
                 $row->{'gli_SysID'},
                 '',
                 $row->{'gli_OrgCode'}
                );

     # write current row to Excel object
     $excel_sheet->write_row(\@xls_row);
  }

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


  if (param('gli_generate_GTAS_report') && param('gli_generate_GTAS_report') eq 'y') {
      $dbh->do("update GTAS_line_info
                set    gli_generate_GTAS_report = ?
                where  gli_generate_GTAS_report = ?
               ", undef, 'n', 'y'
           ) or &error_message_and_exit($global_var_href, "SQL error (could not update generate_GTAS_report flag)", $sr_name . "-" . __LINE__);
  }

  $page .= p("Finished");

  return $page;
}
# end of GTAS_report_to_excel
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_REP016 start_maus_cat_to_excel                      generate MouseNet Catalogue in Excel format
 sub start_maus_cat_to_excel {                           my $sr_name = 'SR_REP016';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my ($page);

  $page = h2("MouseNet Catalogue")
          . hr()
          . h3("Generate a MouseNet Catalogue ... ")
          . start_form(-action => url())

          . p("A MouseNet Catalogue for all living mice will be generated in Excel format.")

          #. p("Please decide if status of reported mouse lines should be set on \"already reported\" after generating the report.")

          #. p(radio_group(-name=>'gli_generate_GTAS_report', -values=>['y', 'n'], -default=>' ')
          #    . br()
          #    . submit(-name => "choice", -value=>"generate GTAS report")
          #  )
		  . p(submit(-name => "choice", -value=>"Mouse Catalogue"))
          . end_form()

          #. p("A MouseNet Catalogue Excel file will be produced upon pressing the button. You can download the file to your local system or open it directly.")
          ;

  return $page;
}
# end of start_maus_cat_to_excel()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
#SR_REP017 maus_cat_to_excel                            generate MouseNet Catalogue in Excel format 
 sub maus_cat_to_excel {                                my $sr_name = 'SR_REP017';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session      = $global_var_href->{'session'};      # get session handle
  my $dbh          = $global_var_href->{'dbh'};          # DBI database handle
  my $username     = $session->param(-name=>'username');
  my $url          = url();
  my @xls_row      = ();
  my ($excel_sheet, $local_filename, $data);
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # include a module to write tables as Excel file in a simple way
  use Spreadsheet::WriteExcel::Simple;

  # create a new excel sheet object
  $excel_sheet = Spreadsheet::WriteExcel::Simple->new;

  # create a unique filename (using combination of user name and time) for server-side storage of temporary Excel file
  $local_filename = $username . '_' . time() . '.xls';

  @xls_row = ('CATID','earTag','conTag','Strain','sex','DOB','PaId','MaId1','MaId2','location','LinCod','Pur','LOwn','COwn','Prj','PTyp','GTyp');

  # write header line to Excel file
  $excel_sheet->write_row(\@xls_row);

  $page .= h3("MouseNet Catalogue")
           . hr();

  # collect mice
  $sql = qq(select mice.mouse_id            as  CATID
    			, mice.mouse_earmark        as earTag
    			, mice2cages.m2c_cage_id    as conTag
    			, mouse_strains.strain_name as Strain
    			, mice.mouse_sex            as sex
    			, mice.mouse_birth_datetime as DOB
    			, lp1.l2p_parent_id         as PaId
    			, lp2.l2p_parent_id         as MaId1
    			, lp3.l2p_parent_id         as MaId2
    			, concat_ws('-',locations.location_building, locations.location_room, locations.location_rack)
                                			as location
    			,mouse_lines.line_name      as LinCod
    			,COALESCE(m2g1.m2g_genotype,'ukn') as PTyp
    			,concat(COALESCE(m2g2.m2g_genotype,'ukn'), " (", genes.gene_name, ")") as GTyp

			from mice

			left join litters2parents lp1 
            			                on (mice.mouse_litter_id = lp1.l2p_litter_id and lp1.l2p_parent_type = 'father')
			left join litters2parents lp2 
                        			    on (mice.mouse_litter_id = lp2.l2p_litter_id and lp2.l2p_parent_type = 'mother')
			left join litters2parents lp3 
                            			on (mice.mouse_litter_id = lp3.l2p_litter_id and lp3.l2p_parent_type = 'mother' 
            	                			and lp2.l2p_parent_id <> lp3.l2p_parent_id)
			left join mice2cages        on        mice.mouse_id = mice2cages.m2c_mouse_id
			left join cages2locations   on     cages2locations.c2l_cage_id = mice2cages.m2c_cage_id
			left join locations         on cages2locations.c2l_location_id = locations.location_id
			left join mouse_lines       on mice.mouse_line=mouse_lines.line_id
			left join mice2genes m2g1   on (mice.mouse_id = m2g1.m2g_mouse_id and m2g1.m2g_genotype_method = 'phenotyping')
			left join mice2genes m2g2   on (mice.mouse_id = m2g2.m2g_mouse_id and m2g2.m2g_genotype_method = 'genotyping')
			left join genes             on m2g2.m2g_gene_id = genes.gene_id
			left join mouse_strains     on mice.mouse_strain = mouse_strains.strain_id

			where mice.mouse_deathorexport_datetime                 IS NULL
        			and          mice2cages.m2c_datetime_to         IS NULL
        			and          cages2locations.c2l_datetime_to    IS NULL
			group by mouse_id);

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mouse information found: tell user and exit
  unless ($rows > 0) {
     $page .= p("No living mice information found ");
     return $page;
  }

  # proceed with displaying details
  $page .= p("Found living mice info");

  #2. Zeile Leerzeile mit Strichen
  @xls_row = ('-----','------','------','------','---','---','----','-----','-----','--------','------','---','----','----','---','----','----');

  # write header line to Excel file
  $excel_sheet->write_row(\@xls_row);

  # loop over all results
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     @xls_row = ($row->{'CATID'},
                 $row->{'earTag'},
                 $row->{'conTag'},
                 $row->{'Strain'},
                 $row->{'sex'},
                 format_sql_date2display_date($row->{'DOB'}),
                 $row->{'PaId'},
                 $row->{'MaId1'},
                 $row->{'MaId2'},
                 $row->{'location'},
                 $row->{'LinCod'},
                 '',
                 '',
                 '',
                 '',
                 $row->{'PTyp'},
                 $row->{'GTyp'},
                );


     # write current row to Excel object
     $excel_sheet->write_row(\@xls_row);
  }

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

  $page .= p("Finished");

  return $page;
 }

# end of maus_cat_to_excel
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
#SR_REP018 animal_cage_time_excel                            show animal cage occupation numbers in Excel format 

 sub animal_cage_time_excel {                                my $sr_name = 'SR_REP018';
  my ($global_var_href) = @_;                            	 # get reference to global vars hash
  my $local_filename	= param('local_filename');			 # reference to local_filename in hidden field
  my $data;

  # now send the just-saved Excel file to browser
  # print the html header with correct MIME-type, so that client browser knows what to do with this content (and hopefully offers to open with Excel)
  print header(-Content_disposition => "attachment; filename=$local_filename",
               -type => 'application/vnd.ms-excel');

  # open local Excel file for read
  open (XLS, "< ./files/$local_filename") or &error_message_and_exit($global_var_href, "Could not open Excel file", "");

  # write Excel file in binary mode to STDOUT
  binmode XLS;
  binmode STDOUT;

  while(read(XLS, $data, 1024)) {
     print $data;
  }

  close(XLS);
 }

# end of animal_cage_time_excel
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_REP019 rack_stock_taking_to_excel                   generate stock taking list in Excel format
sub rack_stock_taking_to_excel {                         my $sr_name = 'SR_REP019';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session      = $global_var_href->{'session'};      # get session handle
  my $dbh          = $global_var_href->{'dbh'};          # DBI database handle
  my $username     = $session->param(-name=>'username');
  my $rack         = param('rack_id');
  my $datetime_now = format_sql_datetime2display_datetime(get_current_datetime_for_sql());
  my $url          = url();
  my @xls_row      = ();
  my ($excel_sheet, $local_filename, $data);
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # include a module to write tables as Excel file in a simple way
  use Spreadsheet::WriteExcel::Simple;

  # create a new excel sheet object
  $excel_sheet = Spreadsheet::WriteExcel::Simple->new;

  # create a unique filename (using combination of user name and time) for server-side storage of temporary Excel file
  $local_filename = $username . '_' . time() . '.xls';

  $page .= h3("Stock taking list")
           . hr();

  # collect mouse data for given rack
  $sql = qq(select mouse_id,
                   mouse_earmark,
                   m2c_cage_id,
                   strain_name,
                   mouse_sex,
                   mouse_birth_datetime,
                   line_name,
                   experiment_name,
                   mice_genotypes(mouse_id) as genotype,
                   location_building,
                   location_room,
                   location_subbuilding,
                   location_rack,
                   location_subrack,
                   location_comment
            from   mice
                   left join mice2cages        on          mouse_id = m2c_mouse_id
                   left join cages2locations   on       c2l_cage_id = m2c_cage_id
                   left join locations         on   c2l_location_id = location_id
                   left join mouse_lines       on        mouse_line = line_id
                   left join mice2genes        on          mouse_id = m2g_mouse_id
                   left join genes             on       m2g_gene_id = gene_id
                   left join mouse_strains     on      mouse_strain = strain_id
                   left join mice2experiments  on      m2e_mouse_id = mouse_id
                   left join experiments       on m2e_experiment_id = experiment_id
            where  mouse_deathorexport_datetime IS NULL
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
                   and c2l_location_id = ?
            order  by m2c_cage_id asc, mouse_earmark asc
         );

  @sql_parameters = ($rack);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mouse information found: tell user and exit
  unless ($rows > 0) {
     $page .= p("No living mice information found ");
     return $page;
  }

  # proceed with displaying details
  $page .= p("Found living mice info");

  # fetch 1st row
  $row = $result->[1];

  # 1st header row:
  @xls_row = ($row->{'location_subbuilding'} . '-' . $row->{'location_building'} .
               '-' . $row->{'location_room'} . '-' . $row->{'location_rack'} . ' (' . $row->{'location_subrack'} . '), ' .
              $datetime_now . ': ' . $rows . ' mice '
             );

  # write header line to Excel file
  $excel_sheet->write_row(\@xls_row);

  @xls_row = ('');

  # write header line to Excel file
  $excel_sheet->write_row(\@xls_row);
  # 2nd header row
  @xls_row = ('cage', 'ear', 'mouse_id', 'strain', 'line', 'sex', 'birth', 'genotype', 'experiment', 'comment');

  # write header line to Excel file
  $excel_sheet->write_row(\@xls_row);



  # loop over all results
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     @xls_row = ($row->{'m2c_cage_id'},
                 $row->{'mouse_earmark'},
                 $row->{'mouse_id'},
                 $row->{'strain_name'},
                 $row->{'line_name'},
                 $row->{'mouse_sex'},
                 format_datetime2simpledate($row->{'mouse_birth_datetime'}),
                 $row->{'genotype'},
                 $row->{'experiment_name'},
                 ''
                );


     # write current row to Excel object
     $excel_sheet->write_row(\@xls_row);
  }

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

  $page .= p("Finished");

  return $page;
 }

# end of rack_stock_taking_to_excel
#--------------------------------------------------------------------------------------


# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;