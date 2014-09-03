# lib_import.pl - a MausDB subroutine library file                                                                               #
#                                                                                                                                #
# Subroutines in this file provide functions related to import mice                                                              #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_IMP001 import_step_1():                             import mice (1. step: initial form)                                     #
# SR_IMP002 upload_import_file():                        import step 2a: upload Excel file for import                            #
# SR_IMP003 generate_import_mice():                      import step 2b: generate initial input form for form-based import       #
# SR_IMP004 import_step_3():                             import step 3: assign cages, allow editing of initial input             #
# SR_IMP005 import_step_4():                             import step 4: final confirmation                                       #
# SR_IMP006 import_step_5():                             import step 5: database transaction                                     #
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
# SR_IMP001 import_step_1():                             import mice (1. step: initial form)
sub import_step_1 {                                      my $sr_name = 'SR_IMP001';
  my ($global_var_href)  = @_;                           # get reference to global vars hash
  my $url                      = url();
  my $session                  = $global_var_href->{'session'};
  my $user_id                  = $session->param(-name=>'user_id');
  my %gvo_labels               = ('y' => 'yes', 'n' => 'no');
  my $sex_color                = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my %radio_labels_screen      = ("user_only" => "", "all"        => "");
  my %radio_labels_import_mode = ("from_file" => "", "form_based" => "");
  my ($page);

  $page = h2("Import: 1. step")
          . hr();

  # first table (litter details)
  $page .= h3("1. Please enter some details for your import")
           . start_form(-action=>url(), -name=>"myform", -enctype=>"multipart/form-data")
           . hidden(-name=>"coach_user", -value=>"$user_id")
           . table( {-border=>1, -summary=>"table"},
                Tr({-bgcolor=>"#DDDDDD"},
                  th(" date of import "),
                  td({-colspan=>3}, textfield(-name=>'import_datetime', -id=>"import_datetime", -size=>"20", -maxlength=>"21", -title=>"date of import", -value=>get_current_datetime_for_display())
                                    . "&nbsp;&nbsp;"
                                    . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=import_datetime', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                                    . span({-class=>"red"}, b("please check date of import!"))
                    )
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                   td({-align=>"center"}, b("import type") . br() . small("please specify")),
                   td(radio_group(-name=>'import_type', -values=>['regular', 'external'], -default=>3)),
                   td({-colspan=>2}, "\'external\' mice will not be taken into account for TEP reporting or cost calculations "
                                     . br()
                                     . span({-class=>"red"}, "caution: \'external\' does not refer to where the mice come from")
                   )
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                   td({-align=>"center"}, b("strain") . br() . small("strain that litter from this import will be assigned to")),
                   td(get_strains_popup_menu($global_var_href, 'please choose')),
                   td({-colspan=>"2"}, "if you need a new strain entry, please contact a MausDB administrator")
#                    td({-align=>"right", -title=>qq(if you chose "new strain", please propose a name for the new strain)}, qq(&nbsp;&nbsp;&nbsp;[optional: for "new strain" only: name of the new strain] )),
#                    td({-title=>qq(if you chose "new strain", please propose a name for the new strain)}, textfield(-name => "new_strain_name", -size=>"20"))
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                   td({-align=>"center"}, b("line") . br() . small("line that litter from this import will be assigned to")),
                   td(get_lines_popup_menu($global_var_href, 'please choose')),
                   td({-colspan=>"2"}, "if you need a new line entry, please contact a MausDB administrator")
#                    td({-align=>"right", -title=>qq(if you chose "new line", please propose a name for the new line)}, qq(&nbsp;&nbsp;&nbsp;[optional: for "new line" only: name of the new line] )),
#                    td({-title=>qq(if you chose "new line", please propose a name for the new line)}, textfield(-name => "new_line_name", -size=>"20"))
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                  th(" are imported mice " . br() . " genetically modified " . br() . " (GVOs)? "),
                  td({-colspan=>3}, radio_group(-name=>'import_is_gvo', -values=>['y', 'n'], -default=>3, -labels=>\%gvo_labels)
                     . "&nbsp;&nbsp;&nbsp;" . span({-class=>"red"}, " please choose GVO status of imported mice!")
                    )
                ) .
                Tr({-bgcolor=>"#DDDDDD"},
                  td({-align=>"center"}, b("import for project") . br() . small("assign a screen/project") . br() . small('Which project will take care for the mice?')),
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
                  td({-align=>"center"}, b(" provider ") . br()
                                         . small(" who sent you the mice? ")
                  ),
                  td({-colspan=>3}, textfield(-name => "import_provider_name", -size=>"80", -title=>"example: \"Dr. Hans Mustermann, Uni XYZ\"")
                                    . span({-class=>"red"}, " please enter name, institution and country!")
                  )
                ) .
                Tr(
                  td({-align=>"center"}, b(" optional: ") . br() . b("owner(s)") . br() . small(" (of intellectual property) ")),
                  td({-colspan=>3}, textfield(-name => "import_owner_name", -size=>"80", -title=>"example: \"Prof. Wichtig, Uni XYZ\""))
                ) .
                Tr(
                  th(" optional: " . br() . " import name "),
                  td({-colspan=>3}, textfield(-name => "import_name", -size=>"80", -title=>"give this import a name if you want"))
                ) .
                Tr(
                  th(" optional: " . br() . " import comment "),
                  td({-colspan=>3}, textarea(-name=>"import_comment", -columns=>"40", -rows=>"5", -title=>"enter any comment on this litter" ))
                )
             )

           . p()

           . h3("2. how do you want to import your mice?")

           . table( {-border=>0, -summary=>"table"},
                  Tr(
                    td(radio_group(-name=>'import_mode', -values=>['from_file'], -default=>'from_file', -labels=>\%radio_labels_import_mode)),
                    td({-colspan=>2}, b(" a) Upload from Excel file ") . " (You can find a sample Excel file " . a({-href=>$global_var_href->{'URL_htdoc_basedir'} . '/static_content/import_template.xls'}, " here ") . ")"
                                      . br() . br()
                                      . filefield(-name=>'import_file', -default=>'', -size=>80, -maxlength=>80,
                                                  -onclick=>"document.myform.import_mode[0].checked=true")
                    )
                  )
             )

           . p() . p(b("-OR-")) . p()

           . table( {-border=>0, -summary=>"table"},
                  Tr(
                    td(radio_group(-name=>'import_mode', -values=>['form_based'], -default=>'from_file', -labels=>\%radio_labels_import_mode)),
                    td({-colspan=>2}, b(" b) use form to import mice manually ")
                                      . br() . br()
                                      . "import "
                                      . popup_menu(-name=>'number_of_males',   -values=>["0" .. "100"], -default=>"0", -title=>"number of males to import",
                                                   -onclick=>"document.myform.import_mode[1].checked=true")
                                      . " males and "
                                      . popup_menu(-name=>'number_of_females', -values=>["0" .. "100"], -default=>"0", -title=>"number of females to import",
                                                   -onclick=>"document.myform.import_mode[1].checked=true")
                                      . " females"
                    )
                  )
             )

           . p()
           . hidden(-name=>"step",   -value=>"import_step_1", -override=>1)
           . hidden(-name=>"first",  -value=>"1")
           . submit(-name=>"choice", -value=>"next step", -title=>"next step")
           . "&nbsp;&nbsp;or&nbsp;&nbsp;"
           . a({-href=>"javascript:back()"}, "go back")
           . end_form();

  return $page;
}
# end of import_step_1
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_IMP002 upload_import_file():                        import step 2a: upload Excel file for import
sub upload_import_file {                                 my $sr_name = 'SR_IMP002';
  my ($global_var_href)    = @_;                                 # get reference to global vars hash
  my $dbh                  = $global_var_href->{'dbh'};          # database handle
  my $session              = $global_var_href->{'session'};      # session handle
  my $username             = $session->param(-name=>'username'); # read username from session
  my $import_datetime      = param('import_datetime');
  my $import_type          = param('import_type');
  my $import_strain        = param('strain');
  my $new_strain_name      = param('new_strain_name');
  my $cost_centre          = param('cost_centre');
  my $line                 = param('line');
  my $new_line_name        = param('new_line_name');
  my $which_projects       = param('which_projects');            # switch to decide if project selection from 'all_projects' or from 'user_only'
  my $all_projects         = param('all_projects');
  my $user_projects_only   = param('user_projects');
  my $coach_user           = param('coach_user');
  my $import_is_gvo        = param('import_is_gvo');
  my $import_provider_name = param('import_provider_name');
  my $import_owner_name    = param('import_owner_name');
  my $import_name          = param('import_name');
  my $import_comment       = param('import_comment');
  my $sex_color            = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my %sex_labels           = ('m' => "m", 'f' => 'f');
  my $filesize             = 0;                                 # counter for size of uploaded file
  my ($page);
  my ($dbh_file, $sth_file, $result_file, $rows_file, $i, $row_file);
  my ($upload_filename, $local_filename, $data, $bgcolor, $fehlertext, $column_name, $type);
  my %cell_bgc;                                                # cell background color
  my %column_names;
  my %valid_column_names;
  my @sheets;
  my ($external_id, $ear, $sex, $external_cage, $born, $import_project, $father, $mother1, $mother2, $year, $number_of_mice);

  $page .= h2("Import: 2. step")
           . hr();

  # check input: is strain given? is it a number?
  if (!param('strain') || param('strain') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid strain"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is line given? is it still the default?
  if (param('strain') eq 'please choose') {
     $page .= p({-class=>"red"}, b("Error: please choose a valid strain"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check provider name
  if (!param('import_provider_name') || length(param('import_provider_name')) < 10) {
     $page .= p({-class=>"red"}, b("Error: please enter name of provider (at least 10 characters)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is line given? is it a number?
  if (param('line') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid line"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is line given? is it still the default?
  if (param('line') eq 'please choose') {
     $page .= p({-class=>"red"}, b("Error: please choose a valid line"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is cost_centre given? is it a number?
  if (param('cost_centre') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid cost centre"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check import date
  if (!param('import_datetime') || check_datetime_ddmmyyyy_hhmmss(param('import_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of birth not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is import datetime in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('import_datetime')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: date/time of import is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # import_is_gvo must be given and it must be either 'y' or 'n'
  if (!param('import_is_gvo') || !(param('import_is_gvo') eq 'y' || param('import_is_gvo') eq 'n')) {
     $page .= p({-class=>"red"}, b("Error: please choose whether imported mice are genetically modified (GVOs)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # import_type must be given and it must be either 'regular' or 'external'
  if (!param('import_type') || !(param('import_type') eq 'regular' || param('import_type') eq 'external')) {
     $page .= p({-class=>"red"}, b("Error: please choose between import type \"regular\" and \"external\". \"external\" mice will not be taken into account for TEP reporting or cost calculations "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # determine import project
  if ($which_projects eq 'user_only') { $import_project = $user_projects_only; }
  else                                { $import_project = $all_projects;       }

  if (!defined($import_project) || $import_project !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid project"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (get_strain_name_by_id($global_var_href, $import_strain) eq "new strain" && (!defined($new_strain_name) || $new_strain_name eq '')) {
     $page .= p({-class=>"red"}, "You chose \"new strain\", but you did not specify the name of the new strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_strain_name_by_id($global_var_href, $import_strain) eq "choose strain") {
     $page .= p({-class=>"red"}, "Please choose a strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_line_name_by_id($global_var_href, $line) eq "new line" && (!defined($new_line_name) || $new_line_name eq '')) {
     $page .= p({-class=>"red"}, "You chose \"new line\", but you did not specify the name of the new line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_line_name_by_id($global_var_href, $line) eq "choose line") {
     $page .= p({-class=>"red"}, "Please choose a line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  $page .= h3("Trying to upload Excel file ... ")
           . start_form(-action=>url(), -name=>"myform")
           . hidden('import_datetime') . hidden('import_type')          . hidden('strain') . hidden('new_strain_name') . hidden('line')
           . hidden('new_line_name')   . hidden('coach_user')           . hidden(-name=>'import_project', -value=>$import_project)
           . hidden('import_is_gvo')   . hidden('import_provider_name') . hidden('import_owner_name') . hidden('import_name')
           . hidden('import_comment')  . hidden('cost_centre');

  # check if filename submitted
  if (!param("import_file") || param("import_file") eq '') {
     $page .= p({-class=>"red"}, b("Error: please specify an import file"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check if filename ends with "xls" (ok, this is not really sufficient to check if it is an excel file)
  elsif (param("import_file") !~ /xls$/) {
     $page .= p({-class=>"red"}, b("File needs to be an Excel file (ending with .xls)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # get upload_filename from HTML form
  $upload_filename = param("import_file");                   # save original filename (we need this for doing the upload)

  # assign a local filename (composed from user and Unix timestamp)
  $local_filename = $username . '_' . time() . '.xls';

  # open write handle for uploaded file on server
  open(DAT, "> ./uploads/$local_filename") or &error_message_and_exit($global_var_href, "Error processing file $!", $sr_name . "-" . __LINE__);

  binmode $upload_filename;                                               # switch to binary mode
  binmode DAT;                                                            # switch to binary mode

  while(read $upload_filename, $data, 1024) {                             # actually write uploaded file on server
      print DAT $data;
      $filesize += length($data);
  }

  close DAT;                                                              # close write handle

  # write upload_log ...
  &write_upload_log($dbh, $session->param(-name=>'user_id'), $session->param(-name=>'username'), $dbh->quote($upload_filename), $local_filename);

  $page .= h3("... file $upload_filename successfully uploaded");

  # upload done, now connect to uploaded file assuming it is an excel file. Use database emulation on excel file
  $dbh_file = DBI->connect("DBI:Excel:file=./uploads/$local_filename") or &error_message_and_exit($global_var_href, "Error: cannot open $upload_filename. Are you sure it is an Excel file?", $sr_name . "-" . __LINE__);

  # get all sheet names
  @sheets  = $dbh_file->func('list_tables');

  # read relevant data from upload Excel file (only first sheet)
  $sth_file = $dbh_file->prepare("select CATID, earTag, conTag, sex, DOB, PaId, MaId1, MaId2
                                  from   mise_imp
                                 ");

  $sth_file->execute() or &error_message_and_exit($global_var_href, "Error: cannot open $upload_filename. Please rename the data sheet into: mise_imp", $sr_name . "-" . __LINE__);
  $result_file = $sth_file->fetchall_arrayref({});
  $sth_file->finish();

  # number of data lines in uploaded excel file
  $rows_file = @{$result_file};

  # read column headers from excel file
  %column_names = %{$sth_file->{'NAME_hash'}};

  $page .= p("Using the first sheet of uploaded file " . b($upload_filename) . " ($filesize bytes), which contains $rows_file rows of data: ");

  # print table with header lines
  $page .= start_table( {-border=>'1', -summary=>"table"} )
           . Tr(
               th("Line"),
               th("MausDB ID"),
               th("external ID"),
               th("ear tag"),
               th("cage"),
               th("sex"),
               th("born"),
               th("father"),
               th("1. mother"),
               th("2. mother"),
               th("comment")
             );

  # now print data lines, loop over rows
  for ($i=0; $i<$rows_file; $i++) {
      $row_file = $result_file->[$i];

      # reset
      undef $born;

      # external id
      $external_id = $row_file->{'CATID'};
      if (!defined($external_id)) { $external_id = 'n/a'; }

      # ear tag must be a number
      $ear = $row_file->{'earTag'};
      if (!defined($ear) || $ear eq '')            { $ear = '??'; }
#       elsif ($ear !~ /^[0-9]{1,2}$/) { $ear = $ear; }

      # sex must be defined and it must be either 'm' or 'f'
      $sex = $row_file->{'sex'};
      if (!defined($sex) || $sex =~ /^[^mf]$/) { $sex = '?'; }

      # cage
      $external_cage = $row_file->{'conTag'};
      if (!defined($external_cage))     { $external_cage = "any"; }

      # father
      $father = $row_file->{'PaId'};
      if (!defined($father))            { $father = "n/a"; }

      # 1. mother
      $mother1 = $row_file->{'MaId1'};
      if (!defined($mother1))           { $mother1 = "n/a"; }

      # 2. mother
      $mother2 = $row_file->{'MaId2'};
      if (!defined($mother2))           { $mother2 = "n/a"; }

      # date of birth
      if ($row_file->{'DOB'} =~ /^([0-9]{1,2})-([0-9]{1,2})-([0-9]{2,4})$/) {
         if    ($3 > 1990)            { $year = $3;        $born = reformat_number($2, 2) . '.' . reformat_number($1, 2) . '.' . $year; }
         elsif ($3 > 90)              { $year = 1900 + $3; $born = reformat_number($2, 2) . '.' . reformat_number($1, 2) . '.' . $year; }
         elsif ($3 >= 0 && $3 < 90  ) { $year = 2000 + $3; $born = reformat_number($2, 2) . '.' . reformat_number($1, 2) . '.' . $year; }
         else                         { $born = '00.00.0000';                                                                           }
      }

      $page .= Tr( {-bgcolor=>$sex_color->{$sex}},
                 td({-align=>'right'}, ($i + 2)),
                 td({-style=>"color: #888888;"}, 'to be assigned'),
                 td(textfield(-name=>"external_id_" . ($i+1), -class=>"input", -value=>$external_id,   -size=>10, -title=>"external id")),
                 td(textfield(-name=>"earmark_"     . ($i+1), -class=>"input", -value=>$ear,           -size=>6,  -title=>"ear tag" )),
                 td(textfield(-name=>"cage_"        . ($i+1), -class=>"input", -value=>"new_" . $external_cage, -size=>9,  -title=>"mice having same entry here will be place together")),
                 td(radio_group(-name=>"sex_"       . ($i+1), -values=>['m', 'f'], -default=>$sex, -labels=>\%sex_labels)),
                 td(textfield(-name=>"born_"        . ($i+1), -class=>"input", -value=>$born,          -size=>10, -title=>"date of birth" )),
                 td(textfield(-name=>"father_"      . ($i+1), -class=>"input", -value=>$father,        -size=>8,  -title=>"external id of father" )),
                 td(textfield(-name=>"mother1_"     . ($i+1), -class=>"input", -value=>((defined($row_file->{'MaId1'}))?$mother1:''), -size=>8,  -title=>"external id of 1. mother" )),
                 td(textfield(-name=>"mother2_"     . ($i+1), -class=>"input", -value=>((defined($row_file->{'MaId2'}))?$mother2:''), -size=>8,  -title=>"external id of 2. mother" )),
                 td(textfield(-name=>"comment_"     . ($i+1), -class=>"input", -value=>'',             -size=>20, -title=>"any comment" ))
               );
  }

  # we want to send total number of mice as hidden field
  $number_of_mice = $i;

  $page .= end_table()
           . p()
           . hidden(-name=>"number_of_mice", -value=>"$number_of_mice")
           . hidden(-name=>"step",           -value=>"import_step_2", -override=>1)
           . hidden(-name=>"first",          -value=>"1")
           . submit(-name=>"choice",         -value=>"next step", -title=>"next step")
           . "&nbsp;&nbsp;or&nbsp;&nbsp;"
           . a({-href=>"javascript:back()"}, "go back")
           . end_form();

  # close Excel file
  $dbh_file->disconnect();

  return $page;
}
# end of upload_import_file()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_IMP003 generate_import_mice():                      import step 2b: generate initial input form for form-based import
sub generate_import_mice {                               my $sr_name = 'SR_IMP003';
  my ($global_var_href)    = @_;                                 # get reference to global vars hash
  my $dbh                  = $global_var_href->{'dbh'};          # database handle
  my $session              = $global_var_href->{'session'};      # session handle
  my $username             = $session->param(-name=>'username'); # read username from session
  my $import_datetime      = param('import_datetime');
  my $import_type          = param('import_type');
  my $import_strain        = param('strain');
  my $new_strain_name      = param('new_strain_name');
  my $line                 = param('line');
  my $cost_centre          = param('cost_centre');
  my $new_line_name        = param('new_line_name');
  my $which_projects       = param('which_projects');            # switch to decide if project selection from 'all_projects' or from 'user_only'
  my $all_projects         = param('all_projects');
  my $user_projects_only   = param('user_projects');
  my $coach_user           = param('coach_user');
  my $import_is_gvo        = param('import_is_gvo');
  my $import_provider_name = param('import_provider_name');
  my $import_owner_name    = param('import_owner_name');
  my $import_name          = param('import_name');
  my $import_comment       = param('import_comment');
  my $number_of_males      = param('number_of_males');
  my $number_of_females    = param('number_of_females');
  my $sex_color            = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my $cage_suffix          = 0;
  my ($page, $i, $j);
  my ($external_id, $ear, $sex, $external_cage, $born, $import_project, $father, $mother1, $mother2, $year, $number_of_mice);
  my @cage_list;

  $page .= h2("Import: 2. step")
           . hr();

  # check input: is strain given? is it a number?
  if (!param('strain') || param('strain') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid strain"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check provider name
  if (!param('import_provider_name') || length(param('import_provider_name')) < 10) {
     $page .= p({-class=>"red"}, b("Error: please enter name of provider (at least 10 characters)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is strain given? is it a number?
  if (param('line') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid line"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is cost_centre given? is it a number?
  if (param('cost_centre') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid cost centre"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('import_datetime') || check_datetime_ddmmyyyy_hhmmss(param('import_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of birth not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # import_type must be given and it must be either 'regular' or 'external'
  if (!param('import_type') || !(param('import_type') eq 'regular' || param('import_type') eq 'external')) {
     $page .= p({-class=>"red"}, b("Error: please choose between import type \"regular\" and \"external\". \"external\" mice will not be taken into account for TEP reporting or cost calculations "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is import datetime in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('import_datetime')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: date/time of import is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # import_is_gvo must be given and it must be either 'y' or 'n'
  if (!param('import_is_gvo') || !(param('import_is_gvo') eq 'y' || param('import_is_gvo') eq 'n')) {
     $page .= p({-class=>"red"}, b("Error: please choose whether imported mice are genetically modified (GVOs)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('number_of_males') || param('number_of_males') !~ /^[0-9]+$/) {
     $number_of_males = 0;
  }

  if (!param('number_of_females') || param('number_of_females') !~ /^[0-9]+$/) {
     $number_of_females = 0;
  }

  if ($number_of_males + $number_of_females == 0) {
     $page .= p({-class=>"red"}, b("You need to select at least one male or female to start an import!"))
              . p(a({-href=>"javascript:back()"}, "please go back and check your input"));
     return $page;
  }

  # determine import project
  if ($which_projects eq 'user_only') { $import_project = $user_projects_only; }
  else                                { $import_project = $all_projects;       }

  if (!defined($import_project) || $import_project !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid project"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (get_strain_name_by_id($global_var_href, $import_strain) eq "new strain" && (!defined($new_strain_name) || $new_strain_name eq '')) {
     $page .= p({-class=>"red"}, "You chose \"new strain\", but you did not specify the name of the new strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_strain_name_by_id($global_var_href, $import_strain) eq "choose strain") {
     $page .= p({-class=>"red"}, "Please choose a strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_line_name_by_id($global_var_href, $line) eq "new line" && (!defined($new_line_name) || $new_line_name eq '')) {
     $page .= p({-class=>"red"}, "You chose \"new line\", but you did not specify the name of the new line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_line_name_by_id($global_var_href, $line) eq "choose line") {
     $page .= p({-class=>"red"}, "Please choose a line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # generate list for new cages for males. Fill each cage with 5 mice
  for ($j=0; $j<$number_of_males; $j++) {            # this will of course create an excess of cages, but we don't care ...
      if ($j % 5 == 0) {                             # use modulo operator to decide when to start a new cage
         $cage_suffix++;
      }
      push(@cage_list, 'new_' . $cage_suffix);
  }

  # generate list for new cages for females. Fill each cage with 5 mice
  for ($j=0; $j<$number_of_females; $j++) {          # this will of course create an excess of cages, but we don't care ...
      if ($j % 5 == 0) {                             # use modulo operator to decide when to start a new cage
         $cage_suffix++;
      }
      push(@cage_list, 'new_' . $cage_suffix);
  }

  $page .= h3("Generating import preview ")
           . start_form(-action=>url(), -name=>"myform")
           . hidden('import_datetime') . hidden('import_type')          . hidden('strain') . hidden('new_strain_name') . hidden('line')
           . hidden('new_line_name')   . hidden('coach_user')           . hidden(-name=>'import_project', -value=>$import_project)
           . hidden('import_is_gvo')   . hidden('import_provider_name') . hidden('import_owner_name') . hidden('import_name')
           . hidden('import_comment')  . hidden('cost_centre');

  # if there are males to import ...
  unless ($number_of_males == 0) {
     # print table with header lines derived from valid column names
     $page .= h3("Males")
              . start_table( {-border=>'1', -summary=>"table"} )
              . Tr(
                  th(""),
                  th("MausDB ID"),
                  th("external ID"),
                  th("ear tag"),
                  th("cage"),
                  th("sex"),
                  th("born"),
                  th("father"),
                  th("1. mother"),
                  th("2. mother"),
                  th("comment")
                );

     # loop over all males
     for ($i=1; $i<=$number_of_males; $i++) {
         $external_cage = shift(@cage_list);
         $born          = '';

         $page .= Tr( {-bgcolor=>$sex_color->{'m'}},
                    td({-align=>'right'}, $i),
                    td({-style=>"color: #888888;"}, 'to be assigned'),
                    td(textfield(-name=>"external_id_" . $i, -value=>'',             -size=>10, -title=>"external id")),
                    td(textfield(-name=>"earmark_"     . $i, -value=>'',             -size=>6,  -title=>"ear tag" )),
                    td(textfield(-name=>"cage_"        . $i, -value=>$external_cage, -size=>9,  -title=>"mice having same entry here will be place together")),
                    td({-align=>'center'}, 'm'),
                    td(textfield(-name=>"born_"        . $i, -value=>$born,          -size=>10, -title=>"date of birth" )),
                    td(textfield(-name=>"father_"      . $i, -value=>'',             -size=>8,  -title=>"external id of father" )),
                    td(textfield(-name=>"mother1_"     . $i, -value=>'',             -size=>8,  -title=>"external id of 1. mother" )),
                    td(textfield(-name=>"mother2_"     . $i, -value=>'',             -size=>8,  -title=>"external id of 2. mother" )),
                    td(textfield(-name=>"comment_"     . $i, -value=>'',             -size=>20, -title=>"any comment" ))
                  )
                  . hidden(-name=>"sex_" . $i, -value=>"m");
     }

     $page .= end_table();
  } # end of males

  # if there are females to import ...
  unless ($number_of_females == 0) {
     # print table with header lines derived from valid column names
     $page .= p()
              . h3("Females")
              . start_table( {-border=>'1', -summary=>"table"} )
              . Tr(
                  th(""),
                  th("MausDB ID"),
                  th("external ID"),
                  th("ear tag"),
                  th("cage"),
                  th("sex"),
                  th("born"),
                  th("father"),
                  th("1. mother"),
                  th("2. mother"),
                  th("comment")
                );

     # loop over rows
     for ($i=($number_of_males + 1); $i<=($number_of_females + $number_of_males); $i++) {
         $external_cage = shift(@cage_list);
         $born          = '';

         $page .= Tr( {-bgcolor=>$sex_color->{'f'}},
                    td({-align=>'right'}, $i),
                    td({-style=>"color: #888888;"}, 'to be assigned'),
                    td(textfield(-name=>"external_id_" . $i, -value=>'',             -size=>10, -title=>"external id")),
                    td(textfield(-name=>"earmark_"     . $i, -value=>'',             -size=>6,  -title=>"ear tag" )),
                    td(textfield(-name=>"cage_"        . $i, -value=>$external_cage, -size=>9,  -title=>"mice having same entry here will be place together")),
                    td({-align=>'center'}, 'f'),
                    td(textfield(-name=>"born_"        . $i, -value=>$born,          -size=>10, -title=>"date of birth" )),
                    td(textfield(-name=>"father_"      . $i, -value=>'',             -size=>8,  -title=>"external id of father" )),
                    td(textfield(-name=>"mother1_"     . $i, -value=>'',             -size=>8,  -title=>"external id of 1. mother" )),
                    td(textfield(-name=>"mother2_"     . $i, -value=>'',             -size=>8,  -title=>"external id of 2. mother" )),
                    td(textfield(-name=>"comment_"     . $i, -value=>'',             -size=>20, -title=>"any comment" ))
                  )
                  . hidden(-name=>"sex_" . $i, -value=>"f");
     }

     $page .= end_table();
  } # end of females

  # we want to send total number of mice as hidden field
  $number_of_mice = $i - 1;

  $page .= p()
           . hidden(-name=>"number_of_mice", -value=>"$number_of_mice")
           . hidden(-name=>"step",           -value=>"import_step_2", -override=>1)
           . hidden(-name=>"first",          -value=>"1")
           . submit(-name=>"choice",         -value=>"next step", -title=>"next step")
           . "&nbsp;&nbsp;or&nbsp;&nbsp;"
           . a({-href=>"javascript:back()"}, "go back")
           . end_form();

  return $page;
}
# end of generate_import_mice()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_IMP004 import_step_3():                              import step 3: assign cages, allow editing of initial input
sub import_step_3 {                                       my $sr_name = 'SR_IMP004';
  my ($global_var_href)    = @_;                                 # get reference to global vars hash
  my $dbh                  = $global_var_href->{'dbh'};          # database handle
  my $session              = $global_var_href->{'session'};      # session handle
  my $import_datetime      = param('import_datetime');
  my $import_type          = param('import_type');
  my $import_strain        = param('strain');
  my $new_strain_name      = param('new_strain_name');
  my $line                 = param('line');
  my $cost_centre          = param('cost_centre');
  my $new_line_name        = param('new_line_name');
  my $coach_user           = param('coach_user');
  my $import_project       = param('import_project');
  my $import_is_gvo        = param('import_is_gvo');
  my $import_provider_name = param('import_provider_name');
  my $import_owner_name    = param('import_owner_name');
  my $import_name          = param('import_name');
  my $import_comment       = param('import_comment');
  my $number_of_mice       = param('number_of_mice');
  my $url                  = url();
  my $import_datetime_sql  = format_display_datetime2sql_datetime($import_datetime);
  my $sex_color            = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}, 'b' => $global_var_href->{'bg_color_mixed_sex'}};
  my %new_cage             = ();
  my %new_cage_sex         = ();
  my %cage_candidates      = ();
  my %ear_in_cage          = ();
  my $hide_next_button     = 0;
  my ($page, $sql, $result, $rows, $row, $i, $j);
  my ($mouse, $free_beds_in_cage, $default_rack, $info, $remark);
  my ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, $cage_capacity, $location_room, $location_rack);
  my ($external_id, $earmark, $cage, $sex, $born, $father, $mother1, $mother2, $comment, $rack);
  my @sql_parameters;

  $page = h2("Import: 3. step")
          . hr();

  # check input: is strain given? is it a number?
  if (!param('strain') || param('strain') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid strain"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input type: must be pure letters
  if (!param('import_type') || param('import_type') !~ /^[a-zA-Z]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid import type"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is coach user id given? is it a number?
  if (!param('coach_user') || param('coach_user') !~ /^[0-9]+$/) {
     $coach_user = $session->param(-name=>'user_id');
  }

  # check input: is strain given? is it a number?
  if (param('line') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid line"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is cost centre given? is it a number?
  if (param('cost_centre') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid cost centre"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('import_datetime') || check_datetime_ddmmyyyy_hhmmss(param('import_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of birth not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # import_is_gvo must be given and it must be either 'y' or 'n'
  if (!param('import_is_gvo') || !(param('import_is_gvo') eq 'y' || param('import_is_gvo') eq 'n')) {
     $page .= p({-class=>"red"}, b("Error: please choose whether imported mice are genetically modified (GVOs)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('number_of_mice') || param('number_of_mice') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: Cannot determine number of mice"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!defined($import_project) || $import_project !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose a valid project"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (get_strain_name_by_id($global_var_href, $import_strain) eq "new strain" && (!defined($new_strain_name) || $new_strain_name eq '')) {
     $page .= p({-class=>"red"}, "You chose \"new strain\", but you did not specify the name of the new strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_strain_name_by_id($global_var_href, $import_strain) eq "choose strain") {
     $page .= p({-class=>"red"}, "Please choose a strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_line_name_by_id($global_var_href, $line) eq "new line" && (!defined($new_line_name) || $new_line_name eq '')) {
     $page .= p({-class=>"red"}, "You chose \"new line\", but you did not specify the name of the new line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_line_name_by_id($global_var_href, $line) eq "choose line") {
     $page .= p({-class=>"red"}, "Please choose a line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }


  $page .= h3("3. step: check/update form data ")
           . start_form(-action=>url(), -name=>"myform");

  # now check if there alread is an import with same/similiar parameters (try to prevent double imports)
  $sql = qq(select import_id, import_type, import_datetime
            from   imports
            where  import_type         = ?
                   and import_datetime = ?
                   and import_strain   = ?
                   and import_line     = ?
           );

  @sql_parameters = ($import_type, $import_datetime_sql, $import_strain, $line);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if there is at least one import having same import_type, import_datetime, import_strain and import_line ...
  if ($rows > 0) {
     # ... display warning and require user to check an 'ignore' checkbox
     $page .= hr()
              . h3({-class=>"red"},  "Warning: another import with same/similar parameters (same date/time, strain and line) already exists!")
              . p({-class=>"red"}, "Please use " . a({-href=>"$url?choice=import_view&import_id=" . $result->[0]->{'import_id'}, -target=>"_blank"}, "this link")
                  . " to check if your current import has already been done!"
                 )
              . hidden(-name=>"import_exists", -value=>"is_true")
              . p({-class=>"red"}, "You need to activate the checkbox to ignore the warning and continue with import ")
              . p({-class=>"red"}, checkbox(-name=>'do_import', -checked=>0, -value=>'do_it', -label=>'') . " ignore warning and continue import")
              . hr();
  }

  # all base parameters checked, so enter import loop
  $page .= hidden('import_datetime') . hidden('import_type')          . hidden('strain')            . hidden('new_strain_name') . hidden('line')
           . hidden('new_line_name') . hidden('import_project')       . hidden('coach_user')        . hidden('number_of_mice')  . hidden('cost_centre')
           . hidden('import_is_gvo') . hidden('import_provider_name') . hidden('import_owner_name') . hidden('import_name')     . hidden('import_comment')

           . p()
           . start_table( {-border=>'1', -summary=>"table"} )
           . Tr(
               th(""),
               th("MausDB ID"),
               th("external ID"),
               th("ear tag"),
               th("cage"),
               th("rack"),
               th("sex"),
               th("born"),
               th("father"),
               th("1. mother"),
               th("2. mother"),
               th("comment"),
               th("remark")
             );

  # loop over mice to be imported
  for ($i=1; $i<=$number_of_mice; $i++) {
      $sex     = param("sex_$i");
      $cage    = param("cage_$i");
      $born    = param("born_$i");
      $earmark = param("earmark_$i");

      $remark  = '';

      # applies for "first round" only: if we use an existing cage for this mouse (= it is a number), get its rack information for display
      if (defined(param('first')) && $cage =~ /^[0-9]+$/) {
         (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, get_cage_location($global_var_href, $cage));
         $rack = $location_room . "-" . $location_rack;
      }

      # applies for "first round" only: if we need to create a new cage for this mouse, display a note that rack needs to be selected
      elsif (defined(param('first'))  && $cage =~ /^new_[0-9]+$/) {
         $rack = span({-class=>"red"}, 'select rack below!');
         $new_cage{$cage}++;                                         # increase new cage counter for this cage
         $new_cage_sex{$cage} = $sex;
         $hide_next_button++;                                        # hide "next button" as long as information is missing
      }

      # applies for "update" views: if an existing cage is given, recheck if this cage can be used to wean male
      elsif (defined(param("cage_$i")) && param("cage_$i") =~ /^[0-9]+$/) {
         # get some cage info
         ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, param("cage_$i"));

         # calculate free "beds" in this cage
         $free_beds_in_cage = $cage_capacity - $mice_in_cage;

         # keep track how many mice are to be placed in this cage
         $cage_candidates{param("cage_$i")}++;

         # only if there is at least one "bed" left and it is a cage of matching sex, accept
         if (($free_beds_in_cage >= $cage_candidates{param("cage_$i")})
             && ( (($sex eq 'm') && ($males_in_cage > 0)   && ($females_in_cage == 0))
                  ||
                  (($sex eq 'f') && ($females_in_cage > 0) && ($males_in_cage == 0))
                )
            ) {
            (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, get_cage_location($global_var_href, param("cage_$i")));
            $rack = $location_room . "-" . $location_rack;
         }
         # matching sex, but no space left
         elsif (($free_beds_in_cage < $cage_candidates{param("cage_$i")})
                && ( (($sex eq 'm') && ($males_in_cage > 0)   && ($females_in_cage == 0))
                     ||
                     (($sex eq 'f') && ($females_in_cage > 0) && ($males_in_cage == 0))
                   )
            ) {
            $rack = span({-class=>"red"}, 'cannot use this cage, no space left! ' . a({-href=>"$url?choice=cage_view&cage_id=" . param("cage_$i"), -target=>"_blank"}, "(see why)"));
            $hide_next_button++;                                        # hide "next button" as long as information is missing
         }
         # any other problem
         else {
            $rack = span({-class=>"red"}, 'cannot use this cage! ' . a({-href=>"$url?choice=cage_view&cage_id=" . param("cage_$i"), -target=>"_blank"}, "(see why)"));
            $hide_next_button++;                                        # hide "next button" as long as information is missing
         }
      }

      # applies for "update" views: we use a new cage for weaning
      else {
         # if field is not given or empty, set it to "any"
         if (!defined(param("cage_$i")) || param("cage_$i") eq "") { param(-name=>"cage_$i", -value=>"any"); }

         $new_cage{$cage}++;                                       # increase new cage counter for this cage

         # determine cage color of new cage
         if (defined($new_cage_sex{$cage}) && $new_cage_sex{$cage} ne $sex) {
            $new_cage_sex{$cage} = 'b';
         }
         else {
            $new_cage_sex{$cage} = $sex;
         }

         # now check if there is already a rack defined for this new cage
         if (defined(param('rack_' . param("cage_$i")))) {
            $rack = param('rack_' . param("cage_$i"));
            (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, $rack);
            $rack = $location_room . "-" . $location_rack;
         }
         else {
           $rack = span({-class=>"red"}, 'select rack below!');
           $hide_next_button++;                                        # hide "next button" as long as information is missing
         }
      }

      # there must be a valid date of birth
      if (check_date_ddmmyyyy($born) == 0) {
         $remark .= span({-class=>"red"}, "date missing or wrong format!");
         $hide_next_button++;                                          # hide "next button" as long as information is missing
      }

      # date of import must not be before any date of birth
      if (Delta_ddmmyyyhhmmss(param('import_datetime'), $born . ' 00:00:00') eq 'future') {
         $remark .= span({-class=>"red"}, "date of birth must not be before date of import ($import_datetime)!");
         $hide_next_button++;                                          # hide "next button" as long as information is missing
      }

#       if (!defined($earmark) || $earmark !~ /^[0-9]+$/) {
      if (!defined($earmark) || $earmark eq '??' || $earmark eq '') {
         $earmark = '??';
         $remark .= span({-class=>"red"}, "please provide a valid ear tag (either number or text)!");
         $hide_next_button++;                                          # hide "next button" as long as information is missing
      }

      # remember ear tag used per cage
      $ear_in_cage{$cage}{$earmark}++;

      # place warning if same eartag used more than once in one cage
      if ($ear_in_cage{$cage}{$earmark} > 1) {
         $remark .= span({-class=>"red"}, "warning: same eartag in cage!");
      }

      $page .= Tr( {-bgcolor=>$sex_color->{$sex}},
                 td({-align=>'right'}, $i),
                 td({-style=>"color: #888888;"}, 'to be assigned'),
                 td(textfield(-name=>"external_id_" . $i, -value=>'',             -class=>"input", -size=>10, -title=>"external id")),
                 td(textfield(-name=>"earmark_"     . $i, -value=>$earmark,       -class=>"input", -size=>6,  -title=>"ear tag", -override=>1 )),
                 td(textfield(-name=>"cage_"        . $i, -value=>$cage,          -class=>"input", -size=>9,  -title=>"mice having same entry here will be place together")),
                 td($rack),
                 td({-align=>'center'}, $sex),
                 td(textfield(-name=>"born_"        . $i, -value=>$born,          -class=>"input", -size=>10, -title=>"date of birth", -override=>1 )),
                 td(textfield(-name=>"father_"      . $i, -value=>'',             -class=>"input", -size=>8,  -title=>"external id of father" )),
                 td(textfield(-name=>"mother1_"     . $i, -value=>'',             -class=>"input", -size=>8,  -title=>"external id of 1. mother" )),
                 td(textfield(-name=>"mother2_"     . $i, -value=>'',             -class=>"input", -size=>8,  -title=>"external id of 2. mother" )),
                 td(textfield(-name=>"comment_"     . $i, -value=>'',             -class=>"input", -size=>20, -title=>"any comment" )),
                 td($remark)
               )
               . hidden(-name=>"sex_" . $i, -value=>"");
  }

  $page .= end_table()
           . p()
           . p(submit(-name=>"choice", -value=>"update import preview", -title=>"update import preview") );

  # display rack selector table only if necessary
  if (scalar (keys %new_cage) > 0) {
     $default_rack = 1;

     $page .= h3("choose racks for new cages")
              . start_table( {-border=>1, -cellpadding=>"2", -summary=>"table"})
              . Tr(
                  th('cage'),
                  th('rack'),
                  th('info')
                )
              . Tr(
                  th('all cages'),
                  td(get_locations_popup_menu_for_weaning($global_var_href, $default_rack, 'male_selector', 'male_selector', 'males_rack_', 'yes')),
                  th('choose rack for all cages')
                )
              . Tr();

     foreach $cage (sort keys %new_cage) {
        if    ($new_cage_sex{$cage} eq 'm') { $info = "male(s)";   }
        elsif ($new_cage_sex{$cage} eq 'b') { $info = "mixed, you need to decide later if this constitutes a mating";   }
        elsif ($new_cage_sex{$cage} eq 'f') { $info = "female(s)";   }

        $page .= Tr( {-bgcolor=>$sex_color->{$new_cage_sex{$cage}}},
                   td($cage),
                   td(get_locations_popup_menu_for_weaning($global_var_href, $default_rack, 'rack_' . $cage, 'males_rack_' . $cage, 'males_rack_', 'no')),
                   td($new_cage{$cage} . " " . $info)
                 );
     }

     $page .= end_table()
              . p()
              . p(submit(-name=>"choice", -value=>"update import preview", -title=>"update import preview") );
  }

  # display "next button" only if we have all information to continue
  if ($hide_next_button == 0) {
     $page .= hr()
              . hidden(-name=>"step",           -value=>"import_step_3", -override=>1)
              . submit(-name=>"choice",         -value=>"next step",     -title=>"next step");
  }
  else {
     $page .= hr() . p({-class=>"red"}, "There were errors. Please check the remarks and fix the problem in your Excel file. ")
                   . p({-class=>"red"}, "You may want to remove surplus lines in your Excel file. ");
  }

  $page .= end_form();

  return $page;
}
# end of import_step_3
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_IMP005 import_step_4():                              import step 4: final confirmation
sub import_step_4 {                                       my $sr_name = 'SR_IMP005';
  my ($global_var_href)    = @_;                                 # get reference to global vars hash
  my $dbh                  = $global_var_href->{'dbh'};          # database handle
  my $session              = $global_var_href->{'session'};      # session handle
  my $import_datetime      = param('import_datetime');
  my $import_type          = param('import_type');
  my $import_strain        = param('strain');
  my $new_strain_name      = param('new_strain_name');
  my $line                 = param('line');
  my $cost_center          = param('cost_centre');
  my $new_line_name        = param('new_line_name');
  my $coach_user           = param('coach_user');
  my $import_project       = param('import_project');
  my $import_is_gvo        = param('import_is_gvo');
  my $import_provider_name = param('import_provider_name');
  my $import_owner_name    = param('import_owner_name');
  my $import_name          = param('import_name');
  my $import_comment       = param('import_comment');
  my $number_of_mice       = param('number_of_mice');
  my $import_checkcode     = param('import_checkcode');
  my $url                  = url();
  my $sex_color            = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}, 'b' => $global_var_href->{'bg_color_mixed_sex'}};
  my %new_cage             = ();
  my %new_cage_sex         = ();
  my %cage_candidates      = ();
  my %ear_in_cage          = ();
  my $hide_next_button     = 0;
  my ($page, $sql, $result, $rows, $row, $i, $j);
  my ($mouse, $free_beds_in_cage, $default_rack, $remark);
  my ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, $cage_capacity, $location_room, $location_rack);
  my ($external_id, $earmark, $cage, $sex, $born, $father, $mother1, $mother2, $comment, $rack);

  $page = h2("Import: 4. step")
          . hr()
          . h3("4. step: confirm import data ")
          . start_form(-action=>url(), -name=>"myform");

  # generate a timestamp for this import and write it as hidden field
  # (use this import_checkcode to avoid double import by pressing brower reload button)
  if (!defined(param('import_checkcode'))) {
     $import_checkcode = get_current_datetime_for_sql();
     $page .= hidden(-name=>'import_checkcode', -value=>$import_checkcode, -override=>1);
  }
  else {
     $import_checkcode = param('import_checkcode');
     $page .= hidden(-name=>'import_checkcode', -value=>$import_checkcode, -override=>1);
  }

  # prevent import if same/similar import already exists and user did not agree to override warning
  if (defined(param('import_exists')) && (param('import_exists') eq "is_true")
      && (!defined(param('do_import')) || (param('do_import') ne 'do_it')) ) {
     $page .= p({-class=>"red"}, b("There is already an import with same/similar parameters. You need to activate the checkbox to ignore and continue with import."))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is strain given? is it a number?
  if (!param('strain') || param('strain') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: not a valid strain"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is coach user id given? is it a number?
  if (!param('coach_user') || param('coach_user') !~ /^[0-9]+$/) {
     $coach_user = $session->param(-name=>'user_id');
  }

  # check input: is line id given? is it a number?
  if (param('line') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: not a valid line"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is cost centre given? is it a number?
  if (param('cost_centre') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: not a valid cost centre"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('import_datetime') || check_datetime_ddmmyyyy_hhmmss(param('import_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of birth not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is import datetime in the future? if so, reject
  if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('import_datetime')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: date/time of import is in the future "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # import_is_gvo must be given and it must be either 'y' or 'n'
  if (!param('import_is_gvo') || !(param('import_is_gvo') eq 'y' || param('import_is_gvo') eq 'n')) {
     $page .= p({-class=>"red"}, b("Error: invalid GVO status"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('number_of_mice') || param('number_of_mice') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: Cannot determine number of mice"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!defined($import_project) || $import_project !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: not a valid project"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (get_strain_name_by_id($global_var_href, $import_strain) eq "new strain" && (!defined($new_strain_name) || $new_strain_name eq '')) {
     $page .= p({-class=>"red"}, "for chosen \"new strain\", no valid name has been specified.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_strain_name_by_id($global_var_href, $import_strain) eq "choose strain") {
     $page .= p({-class=>"red"}, "not a valid strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_line_name_by_id($global_var_href, $line) eq "new line" && (!defined($new_line_name) || $new_line_name eq '')) {
     $page .= p({-class=>"red"}, "for chosen \"new line\", no valid name has been specified.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_line_name_by_id($global_var_href, $line) eq "choose line") {
     $page .= p({-class=>"red"}, "not a valid line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # all base parameters checked, so enter loop
  $page .=  hidden('import_datetime') . hidden('import_type')          . hidden('strain')            . hidden('new_strain_name') . hidden('line')
           . hidden('new_line_name')  . hidden('import_project')       . hidden('coach_user')        . hidden('number_of_mice')  . hidden('cost_centre')
           . hidden('import_is_gvo')  . hidden('import_provider_name') . hidden('import_owner_name') . hidden('import_name')     . hidden('import_comment')
           . p()
           . start_table( {-border=>'1', -summary=>"table"} )
           . Tr(
               th(""),
               th("MausDB ID"),
               th("external ID"),
               th("ear tag"),
               th("cage"),
               th("rack"),
               th("sex"),
               th("born"),
               th("father"),
               th("1. mother"),
               th("2. mother"),
               th("comment"),
               th("remark")
             );

  # loop over mice to bee imported
  for ($i=1; $i<=$number_of_mice; $i++) {

      # read hidden fields from previous step
      $external_id = param("external_id_$i");
      $earmark     = param("earmark_$i");
      $cage        = param("cage_$i");
      $sex         = param("sex_$i");
      $born        = param("born_$i");
      $father      = param("father_$i");
      $mother1     = param("mother1_$i");
      $mother2     = param("mother2_$i");
      $comment     = param("comment_$i");
      $rack        = param("rack_$cage");

      $remark      = '';

      # $cage is a pure number, so we suppose it is an already existing cage
      if ($cage =~ /^[0-9]+$/) {
            # get some cage info
            ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, $cage);
            # calculate free "beds" in this cage
            $free_beds_in_cage = $cage_capacity - $mice_in_cage;

            # keep track how many mice are to be placed in this cage
            $cage_candidates{$cage}++;

            # only if there is at least one "bed" left and it is a cage of matching sex, accept
            if (($free_beds_in_cage >= $cage_candidates{param("cage_$i")})
                && ( (($sex eq 'm') && ($males_in_cage > 0)   && ($females_in_cage == 0))
                     ||
                     (($sex eq 'f') && ($females_in_cage > 0) && ($males_in_cage == 0))
                   )
            ) {
               (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, get_cage_location($global_var_href, $cage));
               $rack = $location_room . "-" . $location_rack;
            }
            # matching sex, but no space left
            elsif (($free_beds_in_cage < $cage_candidates{param("cage_$i")})
                   && ( (($sex eq 'm') && ($males_in_cage > 0)   && ($females_in_cage == 0))
                        ||
                        (($sex eq 'f') && ($females_in_cage > 0) && ($males_in_cage == 0))
                      )
            ) {
               $rack = span({-class=>"red"}, 'cannot use this cage, no space left! ' . a({-href=>"$url?choice=cage_view&cage_id=" . $cage, -target=>"_blank"}, "(see why)"));
               $hide_next_button++;                                        # hide "next button" as long as information is missing
            }
            # any other problem
            else {
               $rack = span({-class=>"red"}, 'cannot use this cage! ' . a({-href=>"$url?choice=cage_view&cage_id=" . $cage, -target=>"_blank"}, "(see why)"));
               $hide_next_button++;                                        # hide "next button" as long as information is missing
            }
      }
      # $cage is not a number, so it is an anonymous new cage
      else {
         # for display, get rack info from rack id
            $new_cage{$cage}++;
            (undef, undef, $location_room, $location_rack) = get_location_details_by_id($global_var_href, $rack);
            $rack = $location_room . "-" . $location_rack;
      }

      # catch eventual rack errors
      if ($rack eq "0000-00") {
            $rack = span({-class=>"red"}, "rack not defined");
            $hide_next_button++;
      }

      # remember ear tag used per cage
      $ear_in_cage{$cage}{$earmark}++;

      # place warning if same eartag used more than once in one cage
      if ($ear_in_cage{$cage}{$earmark} > 1) {
         $remark .= "same eartag in cage!";
      }

      $page .= Tr( {-bgcolor=>$sex_color->{$sex}},
                 td({-align=>'right'}, $i),
                 td({-style=>"color: #888888;"}, 'to be assigned'),
                 td($external_id),
                 td($earmark),
                 td({-style=>"color: #888888;"}, $cage),
                 td($rack),
                 td({-align=>'center'}, $sex),
                 td($born),
                 td($father),
                 td($mother1),
                 td($mother2),
                 td($comment),
                 td($remark)
               )
               . hidden("external_id_" . $i) . hidden("earmark_" . $i) . hidden("cage_" . $i)    . hidden("sex_" . $i)     . hidden("born_" . $i)
               . hidden("father_" . $i)      . hidden("mother1_" . $i) . hidden("mother2_" . $i) . hidden("comment_" . $i);
  }

  $page .= end_table()
           . p();

  # write racks for new cages as hidden fields
  if (scalar (keys %new_cage) > 0) {
     foreach $cage (sort keys %new_cage) {
        $page .= hidden(-name=>"rack_$cage", -value=>$new_cage{"rack_$cage"});
     }
  }

  # display "next button" only if we have all information to continue
  if ($hide_next_button == 0) {
     $page .= hr()
              . submit(-name=>"choice",         -value=>"import!",     -title=>"do the import");
  }

  $page .= end_form();

  return $page;
}
# end of import_step_4
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_IMP006 import_step_5():                              import step 5: database transaction
sub import_step_5 {                                       my $sr_name = 'SR_IMP006';
  my ($global_var_href)    = @_;                                      # get reference to global vars hash
  my $dbh                  = $global_var_href->{'dbh'};               # database handle
  my $session              = $global_var_href->{'session'};           # session handle
  my $database             = $global_var_href->{'db_name'};           # which database are we working on?
  my $server               = $global_var_href->{'db_server'};         # on which server is the database currently running?
  my $start_mouse_id       = $global_var_href->{'start_mouse_id'};    # mouse ID to start with if very first mouse in DB
  my $move_user_id         = $session->param('user_id');
  my $datetime_now         = get_current_datetime_for_sql();
  my $import_datetime      = param('import_datetime');
  my $import_datetime_sql  = format_display_datetime2sql_datetime($import_datetime);
  my $import_type          = param('import_type');
  my $import_strain        = param('strain');
  my $new_strain_name      = param('new_strain_name');
  my $line                 = param('line');
  my $cost_centre          = param('cost_centre');
  my $new_line_name        = param('new_line_name');
  my $coach_user           = param('coach_user');
  my $import_project       = param('import_project');
  my $import_is_gvo        = param('import_is_gvo');
  my $import_provider_name = param('import_provider_name');
  my $import_owner_name    = param('import_owner_name');
  my $import_name          = param('import_name');
  my $import_comment       = param('import_comment');
  my $number_of_mice       = param('number_of_mice');
  my $url                  = url();
  my $generation           = '';
  my $batch                = '';
  my $import_checkcode     = param('import_checkcode');
  my $color                = 1;
  my $sex_color            = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}, 'b' => $global_var_href->{'bg_color_mixed_sex'}};
  my %all_cages            = ();
  my %new_cage             = ();
  my %new_cage_sex         = ();
  my %cage_candidates      = ();
  my @cagemates            = ();
  my $hide_next_button     = 0;
  my ($page, $rc, $sql, $result, $rows, $row, $i, $j, $short_comment, $mouse_done, $print_cage, $property_id);
  my ($mouse, $free_beds_in_cage, $default_rack, $import_id, $import_remark, $mouse_id, $number_of_cages, $cage_done);
  my ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, $cage_capacity, $location_room, $location_rack);
  my ($external_id, $earmark, $cage, $sex, $born, $father, $mother1, $mother2, $comment, $rack, $rack_capacity);
  my ($import_notification, $strain_name, $new_strain_id, $new_strain_order, $line_name, $new_line_id, $new_line_order);
  my $import_type_insert   = 'import';               # default is 'import' (in contrast to 'import_external')
  my @imported_mice;
  my @sql_parameters;
  my ($admin_mail, $mailbody, $entry_date_sql);
  my %mail_to_admin;

  $page = h2("Import: 5. step")
          . hr();

  # check input: is strain given? is it a number?
  if (!param('strain') || param('strain') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: not a valid strain"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # is coach user id given? is it a number?
  if (!param('coach_user') || param('coach_user') !~ /^[0-9]+$/) {
     $coach_user = $session->param(-name=>'user_id');
  }

  # check input: is line id given? is it a number?
  if (param('line') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: not a valid line"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is cost centre given? is it a number?
  if (param('cost_centre') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: not a valid cost centre"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('import_datetime') || check_datetime_ddmmyyyy_hhmmss(param('import_datetime')) != 1) {
     $page .= p({-class=>"red"}, b("Error: date of import not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # import_is_gvo must be given and it must be either 'y' or 'n'
  if (!param('import_is_gvo') || !(param('import_is_gvo') eq 'y' || param('import_is_gvo') eq 'n')) {
     $page .= p({-class=>"red"}, b("Error: invalid GVO status"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!param('number_of_mice') || param('number_of_mice') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: Cannot determine number of mice"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (!defined($import_project) || $import_project !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: not a valid project"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  if (get_strain_name_by_id($global_var_href, $import_strain) eq "new strain" && (!defined($new_strain_name) || $new_strain_name eq '')) {
     $page .= p({-class=>"red"}, "for chosen \"new strain\", no valid name has been specified.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_strain_name_by_id($global_var_href, $import_strain) eq "choose strain") {
     $page .= p({-class=>"red"}, "not a valid strain.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_line_name_by_id($global_var_href, $line) eq "new line" && (!defined($new_line_name) || $new_line_name eq '')) {
     $page .= p({-class=>"red"}, "for chosen \"new line\", no valid name has been specified.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  if (get_line_name_by_id($global_var_href, $line) eq "choose line") {
     $page .= p({-class=>"red"}, "not a valid line.")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # if user wants to generate a new strain and/or new line on the fly, we need the mailing module in order to send a mail to the administrators
  if (get_strain_name_by_id($global_var_href, $import_strain) eq "new strain" || get_line_name_by_id($global_var_href, $line) eq "new line" ) {
     use Mail::Sendmail;                                # include mailing module

     ($admin_mail) = $dbh->selectrow_array("select setting_value_text as admin_mail
                                            from   settings
                                            where  setting_category = 'admin'
                                                   and setting_item = 'admin_mail'
                                           ");
  }

  if ($import_type eq 'regular') {
     $import_type_insert = 'import';
  }
  else {
     $import_type_insert = 'import_external';
  }

  # all base parameters checked, so enter loop
  $page .= h3("5. step: import")
           . start_form(-action=>url(), -name=>"myform")
           . p();

  if (defined(param('import_checkcode'))) {
     # now check if there already is an import with same/similiar parameters (try to prevent double importing of same mice)
     $sql = qq(select import_id
               from   imports
               where  import_checkcode = ?
           );

     @sql_parameters = ($import_checkcode);

     ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

     # there is at least one import having same import_type, import_datetime, import_strain and import_line
     if ($rows > 0) {
        $page .= hr()
                 . h3({-class=>"red"},  "Warning: another import with same/similar parameters already exists!")
                 . p({-class=>"red"},   "Please use " . a({-href=>"$url?choice=import_view&import_id=" . $result->[0]->{'import_id'}, -target=>"_blank"}, "this link")
                                        . " to view the conflicting import!");
        return $page;
      }
  }
  else {
     $import_checkcode = get_current_datetime_for_sql();
  }

  # try to get a lock
  &get_semaphore_lock($global_var_href, $move_user_id);

  ############################################################################################
  # begin transaction
  $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start import transaction)", $sr_name . "-" . __LINE__);

  #------------------------------------------------------------------
  if ($number_of_mice > 0) {

     $page .= h3("imported mice")
              . start_table( {-border=>"1", -cellpadding=>"2", -summary=>"table"})
              . Tr(
                  th("#"),
                  th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
                  th("MausDB ID"),
                  th("external ID"),
                  th("ear"),
                  th("sex"),
                  th("color"),
                  th("born"),
                  th("age"),
                  th("strain"),
                  th("line"),
                  th("room/rack"),
                  th("cage"),
                  th("father"),
                  th("1. mother"),
                  th("2. mother"),
                  th("comment (shortened)"),
                  th("import remark")
                );

     # ok, now check if this import requires a new strain
     ($strain_name) = $dbh->selectrow_array("select strain_name
                                             from   mouse_strains
                                             where  strain_id = '$import_strain'
                                            ");

#      if ($strain_name eq 'new strain') {
#         # get new strain id for insert
#         ($new_strain_id, $new_strain_order) = $dbh->selectrow_array("select (max(strain_id) + 1) as new_strain_id, (max(strain_order) + 1) as new_strain_order
#                                                                      from   mouse_strains
#                                                                     ");
#         # insert a new strain
#         $sql = qq(insert
#                   into   mouse_strains (strain_id, strain_name, strain_order, strain_show, strain_description)
#                   values (?, ?, ?, ?, ?)
#                  );
#
#         $dbh->do($sql, undef,
#                  $new_strain_id, $new_strain_name, $new_strain_order, 'y', 'New strain inserted at import by ' . $session->param('username') . ' at ' . $import_datetime_sql
#                 ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new strain)", $sr_name . "-" . __LINE__);
#
#         # use new strain id for import insert down below
#         $import_strain = $new_strain_id;
#
#         # tell user to inform administrators about new strain
#         $import_notification .= p()
#                                 . p({-class=>"red"}, b("Important: new strain \"$new_strain_name\" (id: $new_strain_id) has been generated. "
#                                                        . "Please inform MausDB administrators about this as soon as possible!")
#                                    );
#
#         &write_textlog($global_var_href, "$datetime_now\t$move_user_id\t" . $session->param('username') . "\tnew_imported_strain\t$new_strain_name\tnew_strain_id\t$new_strain_id");
#
#         #-------------------------------------------------------
#         # send mail to admin that new strain has been inserted
#         $mailbody =  "MausDB notification: a new strain has been inserted by user \"" . $session->param(-name=>'username') . "\"\n\n"
#                     . "name of new strain: \"$new_strain_name\"\n"
#                     . "id of new strain  : \"$new_strain_id\"\n\n"
#                     . "Please check this new strain!" . "\n";
#
#         %mail_to_admin = ( From    => $admin_mail,
#                            To      => $admin_mail,
#                            Subject => "Message from MausDB ($database on $server): new strain inserted at import",
#                            Message => $mailbody
#                          );
#
#         if (sendmail(%mail_to_admin)) {
#            &write_textlog($global_var_href, "$datetime_now\t$move_user_id\t" . $session->param('username') . "\tmail_sent:_new_imported_strain\t$new_strain_name\tnew_strain_id\t$new_strain_id");
#         }
#         else {
#            &write_textlog($global_var_href, "$datetime_now\t$move_user_id\t" . $session->param('username') . "\tcould_not_send_mail:_new_imported_strain\t$new_strain_name\tnew_strain_id\t$new_strain_id");
#            &error_message_and_exit($global_var_href, "Could not send mail for new strain to $admin_mail ($Mail::Sendmail::error)", $sr_name . "-" . __LINE__);
#         }
#         #-------------------------------------------------------
#      }

     # ok, now check if this import requires a new line
     ($line_name) = $dbh->selectrow_array("select line_name
                                           from   mouse_lines
                                           where  line_id = '$line'
                                          ");
#      if ($line_name eq 'new line') {
#         # get new line id for insert
#         ($new_line_id, $new_line_order) = $dbh->selectrow_array("select (max(line_id) + 1) as new_line_id, (max(line_order) + 1) as new_line_order
#                                                                  from   mouse_lines
#                                                                 ");
#         # insert a new line
#         $sql = qq(insert
#                   into   mouse_lines (line_id, line_name, line_long_name, line_order, line_show, line_info_URL, line_comment)
#                   values (?, ?, ?, ?, ?, ?, ?)
#                  );
#
#         $dbh->do($sql, undef,
#                  $new_line_id, $new_line_name, $new_line_name, $new_line_order, 'y', '', 'New line inserted at import by ' . $session->param('username') . ' at ' . $import_datetime_sql
#                 ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new line)", $sr_name . "-" . __LINE__);
#
#         # use new line id for import insert down below
#         $line = $new_line_id;
#
#         # tell user to inform administrators about new strain
#         $import_notification .= p()
#                                 . p({-class=>"red"}, b("Important: a new line \"$new_line_name\" (id: $new_line_id) has been generated. "
#                                                        . "Please inform MausDB administrators about this as soon as possible!")
#                                    );
#
#         &write_textlog($global_var_href, "$datetime_now\t$move_user_id\t" . $session->param('username') . "\tnew_imported_line\t$new_line_name\tnew_line_id\t$new_line_id");
#
#         #-------------------------------------------------------
#         # send mail to admin that new line has been inserted
#         $mailbody =  "MausDB notification: a new line has been inserted by user \"" . $session->param(-name=>'username') . "\"\n\n"
#                     . "name of new line: \"$new_line_name\"\n"
#                     . "id of new line  : \"$new_line_id\"\n\n"
#                     . "Please check this new line!" . "\n";
#
#         %mail_to_admin = ( From    => $admin_mail,
#                            To      => $admin_mail,
#                            Subject => "Message from MausDB ($database on $server): new line inserted at import",
#                            Message => $mailbody
#                         );
#
#         if (sendmail(%mail_to_admin)) {
#            &write_textlog($global_var_href, "$datetime_now\t$move_user_id\t" . $session->param('username') . "\tmail_sent:_new_imported_line\t$new_line_name\tnew_line_id\t$new_line_id");
#         }
#         else {
#            &write_textlog($global_var_href, "$datetime_now\t$move_user_id\t" . $session->param('username') . "\tcould_not_send_mail:_new_imported_line\t$new_line_name\tnew_line_id\t$new_line_id");
#            &error_message_and_exit($global_var_href, "Could not send mail for new line to $admin_mail", $sr_name . "-" . __LINE__);
#         }
#         #-------------------------------------------------------
#      }

     # get an import id
     ($import_id) = $dbh->selectrow_array("select (max(import_id)+1) as new_import_id
                                           from   imports
                                          ");

     # ok, this is only neccessary for the very first import when (max(import_id)+1) = (NULL + 1) is undefined
     if (!defined($import_id)) { $import_id = 1; }

     # loop over mice to be imported
     for ($i=1; $i<=$number_of_mice; $i++) {
         # reset weaning_remark
         $import_remark = "ok";

         # read hidden fields from previous step
         $external_id = param("external_id_$i");
         $earmark     = param("earmark_$i");
         $cage        = param("cage_$i");
         $sex         = param("sex_$i");
         $born        = param("born_$i");
         $father      = param("father_$i");
         $mother1     = param("mother1_$i");
         $mother2     = param("mother2_$i");
         $comment     = param("comment_$i");
         $rack        = param("rack_$cage");

         # check/correct earmark
         if (!defined($earmark) || $earmark eq '') {
             $earmark = '??';
         }

         # get a new mouse id
         ($mouse_id) = $dbh->selectrow_array("select (max(mouse_id)+1) as new_mouse_id
                                              from   mice
                                             ");

         # ok, this is only neccessary for the very first mouse when (max(mouse_id)+1) = (NULL + 1) is undefined
         if (!defined($mouse_id)) { $mouse_id = $start_mouse_id; }

         push(@imported_mice, $mouse_id);

         # insert mouse
         $sql = qq(insert
                   into   mice (mouse_id, mouse_earmark, mouse_origin_type, mouse_litter_id, mouse_import_id, mouse_import_litter_group, mouse_sex,
                                mouse_strain, mouse_line, mouse_generation, mouse_batch, mouse_coat_color, mouse_birth_datetime,
                                mouse_deathorexport_datetime, mouse_deathorexport_how, mouse_deathorexport_why,
                                mouse_deathorexport_contact, mouse_deathorexport_location, mouse_is_gvo, mouse_comment)
                   values (?, ?, ?, ?, ?, NULL, ?, ?, ?, ?, ?, ?, ?, NULL, ?, ?, NULL, NULL, ?, ?)
                );

         $dbh->do($sql, undef,
                  $mouse_id,  $earmark, $import_type_insert, 0, $import_id, $sex,
                  $import_strain, $line, $generation, $batch, $color, format_display_date2sql_datetime($born),
                  1, 2, $import_is_gvo, $comment
                 ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new mouse)", $sr_name . "-" . __LINE__);


         # check if mouse has been generated
         ($mouse_done) = $dbh->selectrow_array("select count(mouse_id)
                                                from   mice
                                                where  mouse_id = $mouse_id
                                               ");

         # no: -> rollback and exit
         if ($mouse_done != 1) {
            $rc    = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (something went wrong with import, but rollback failed)", $sr_name . "-" . __LINE__);

            &release_semaphore_lock($global_var_href, $move_user_id);
            $page .= p({-class=>"red"}, "Something went wrong when trying to import.$start_mouse_id");
            return $page;
         }

         # mouse created, now we need to put the mouse in a cage and the cage in a rack
         # first case: we put the mouse in an existing cage (=> $cage is a pure number)
         if ($cage =~ /^[0-9]+$/) {
            # get some cage info
            ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, $cage, $import_datetime_sql);

            # calculate free "beds" in this cage
            $free_beds_in_cage = $cage_capacity - $mice_in_cage;

            # is/was given cage in use at all? (-> does it contain > 1 mice?)
            if ($mice_in_cage == 0) {
               $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back)", $sr_name . "-" . __LINE__);

               &release_semaphore_lock($global_var_href, $move_user_id);

               $page = h2("Import: 5. step")
                       . hr()
                       . h3({-class=>"red"}, "Import not possible")
                       . p({-class=>"red"}, "Given target cage (" . reformat_number($cage, 4) .  ") not in use at import time") . hr()
                       . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try with another selection");

               return $page;
            }

            # check if in given cage, there was at least one place left between datetime of import and *now*
            if (was_there_a_place_for_this_mouse_between_datetime_of_move_and_now($global_var_href, $cage,
                                                                                                    $import_datetime_sql,
                                                                                                    $datetime_now) eq 'no') {
               # do exactly the same as in the "else" part down below (place in new cage in virtual rack)
               # TO DO: reduce both cases to one (just with specific remark)

               # notify user about placing mouse in extra cage in virtual rack
               $import_remark = span({-class=>"red"}, "during given time and now there was no place left in target cage at some time point. " . br() . "mouse placed in separate cage in virtual rack");

               # get the next free cage for the import
               $cage = give_me_a_cage($global_var_href, $import_datetime_sql);

               # if no free cages left (at given datetime of move): rollback and exit
               if (!defined($cage)) {
                  $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back)", $sr_name . "-" . __LINE__);

                  &release_semaphore_lock($global_var_href, $move_user_id);

                  $page .= p({-class=>"red"}, "mouse import cancelled: no free cage found at given date/time of move (more recent or current move date/time will work more likely)");

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
                        ", undef, $cage, 0, $import_datetime_sql, $move_user_id, $datetime_now
                       ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new cage into virtual rack)", $sr_name . "-" . __LINE__);
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

            # whatever goes wrong, place mouse into a new cage on its own and place this cage in the virtual rack
            else {
               # notify user about placing mouse in extra cage in virtual rack
               $import_remark = span({-class=>"red"}, "problems occured, mouse placed in separate cage in virtual rack");

               # get the next free cage for the import
               $cage = give_me_a_cage($global_var_href, $import_datetime_sql);

               # if no free cages left (at given datetime of move): rollback and exit
               if (!defined($cage)) {
                  $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back)", $sr_name . "-" . __LINE__);

                  &release_semaphore_lock($global_var_href, $move_user_id);

                  $page .= p({-class=>"red"}, "mouse import cancelled: no free cage found at given date/time of move (more recent or current move date/time will work more likely)");

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
                        ", undef, $cage, 0, $import_datetime_sql, $move_user_id, $datetime_now
                       ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new cage into virtual rack)", $sr_name . "-" . __LINE__);

            }

            # keep track of all cages used in this weaning (to offer "print cage card" link for all those cages at the end)
            $all_cages{$cage}++;

            # in any case, place mouse in a) given and existing cage or b) new cage in virtual rack
            $dbh->do("insert
                      into    mice2cages (m2c_mouse_id, m2c_cage_id, m2c_cage_of_this_mouse, m2c_datetime_from, m2c_datetime_to, m2c_move_user_id, m2c_move_datetime)
                      values  (?, ?, ?, ?, NULL, ?, ?)
                     ", undef, $mouse_id, $cage, 1, $import_datetime_sql, $move_user_id, $datetime_now
                    ) or &error_message_and_exit($global_var_href, "SQL error (could not insert mouse into cage)", $sr_name . "-" . __LINE__);
         }

         # second case: we put the mouse into a new cage
         else {
           # check if a new cage named $cage was already used (look up %new_cage)
           unless (defined($new_cage{$cage})) {
              # get the next free cage for import
              $new_cage{$cage} = give_me_a_cage($global_var_href, $import_datetime_sql);

              # if no free cages left (at given datetime): rollback and exit
              if (!defined($new_cage{$cage})) {
                  $rc = $dbh->rollback() or &error_message_and_exit($global_var_href, "SQL error (could not roll back)", $sr_name . "-" . __LINE__);

                  &release_semaphore_lock($global_var_href, $move_user_id);
                  $page .= p({-class=>"red"}, "mouse move cancelled: no free cage found at given date/time of move (more recent or current move date/time will work more likely)");
                  return $page;
              }

              # mark new cage as occupied
              $dbh->do("update  cages
                        set     cage_occupied = ?
                        where   cage_id = ?
                       ", undef, "y", $new_cage{$cage}
                      ) or &error_message_and_exit($global_var_href, "SQL error (could not set new cage to occupied)", $sr_name . "-" . __LINE__);
           }

           # keep track of all cages used in this weaning (to offer "print cage card" link for all those cages at the end)
           $all_cages{$new_cage{$cage}}++;

           # in any case, place mouse in a) given and existing cage or b) new cage in virtual rack
           $dbh->do("insert
                     into    mice2cages (m2c_mouse_id, m2c_cage_id, m2c_cage_of_this_mouse, m2c_datetime_from, m2c_datetime_to, m2c_move_user_id, m2c_move_datetime)
                     values  (?, ?, ?, ?, NULL, ?, ?)
                    ", undef, $mouse_id, $new_cage{$cage}, 1, $import_datetime_sql, $move_user_id, $datetime_now
                   ) or &error_message_and_exit($global_var_href, "SQL error (could not insert mouse into cage)", $sr_name . "-" . __LINE__);


           # look up free slots in given $rack (TO DO: at import datetime)
           $number_of_cages = get_cages_in_location($global_var_href, $rack);

           ($rack_capacity) = $dbh->selectrow_array("select location_capacity
                                                     from   locations
                                                     where  location_id = $rack
                                                    ");

           # if no free slots: place $cage in virtual rack
           if (($rack_capacity - $number_of_cages) < 1) {
              # before setting rack to virtual rack, check if cage already is in a normal rack
              ($cage_done) = $dbh->selectrow_array("select count(c2l_cage_id) as number_of_cages
                                                    from   cages2locations
                                                    where            c2l_cage_id = $new_cage{$cage}
                                                           and   c2l_location_id = $rack
                                                           and c2l_datetime_from = '$import_datetime_sql'
                                                   ");

              # only set a cage into the virtual rack, if this cage is not already placed in another rack
              if ($cage_done == 0) {
                 $rack = 0;               # id of virtual rack

                 # notify user about placing mouse in extra cage in virtual rack
                 $import_remark = span({-class=>"red"}, "rack being occupied in the meanwhile, cage placed in virtual rack");
              }
           }

           # check if cage already created
           ($cage_done) = $dbh->selectrow_array("select count(c2l_cage_id) as number_of_cages
                                                 from   cages2locations
                                                 where            c2l_cage_id = $new_cage{$cage}
                                                        and   c2l_location_id = $rack
                                                        and c2l_datetime_from = '$import_datetime_sql'
                                                ");
           # add this cage to rack only once
           unless ($cage_done > 0) {
              # insert the new cage into a) given rack or b) virtual rack
              $dbh->do("insert
                        into    cages2locations (c2l_cage_id, c2l_location_id, c2l_datetime_from, c2l_datetime_to, c2l_move_user_id, c2l_move_datetime)
                        values  (?, ?, ?, NULL, ?, ?)
                       ", undef, $new_cage{$cage}, $rack, $import_datetime_sql, $move_user_id, $datetime_now
                      ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new cage into virtual rack)", $sr_name . "-" . __LINE__);
           }
         }

         # add foreignID of this mouse
         if (defined($external_id) && ($external_id ne '')) {
             # get the next property id
             ($property_id) = $dbh->selectrow_array("select (max(property_id)+1) as next_id
                                                     from   properties
                                                    ");

             # ok, this is only neccessary for the very first property when (max(property_id)+1) = (NULL + 1) is undefined
             if (!defined($property_id)) { $property_id = 1; }

             $dbh->do("insert
                       into    properties (property_id, property_category, property_key, property_type, property_value_integer,
                                           property_value_bool, property_value_float, property_value_text)
                       values  (?, ?, ?, ?, NULL, NULL, NULL, ?)
                      ", undef,
                      $property_id, 'mouse', 'foreignID', 'text', $external_id
                     ) or &error_message_and_exit($global_var_href, "SQL error (could not insert father of mouse)", $sr_name . "-" . __LINE__);

             $dbh->do("insert
                       into    mice2properties (m2pr_mouse_id, m2pr_property_id, m2pr_datetime, m2pr_user)
                       values  (?, ?, ?, ?)
                      ", undef,
                      $mouse_id, $property_id, $import_datetime_sql, $coach_user
                     ) or &error_message_and_exit($global_var_href, "SQL error (could not insert father of mouse)", $sr_name . "-" . __LINE__);
         }

         # add father of this mouse
         if (defined($father) && ($father ne '')) {
             # get the next property id
             ($property_id) = $dbh->selectrow_array("select (max(property_id)+1) as next_id
                                                     from   properties
                                                    ");

             # ok, this is only neccessary for the very first property when (max(property_id)+1) = (NULL + 1) is undefined
             if (!defined($property_id)) { $property_id = 1; }

             $dbh->do("insert
                       into    properties (property_id, property_category, property_key, property_type, property_value_integer,
                                           property_value_bool, property_value_float, property_value_text)
                       values  (?, ?, ?, ?, NULL, NULL, NULL, ?)
                      ", undef,
                      $property_id, 'mouse', 'genetic_father', 'text', $father
                     ) or &error_message_and_exit($global_var_href, "SQL error (could not insert father of mouse)", $sr_name . "-" . __LINE__);

             $dbh->do("insert
                       into    mice2properties (m2pr_mouse_id, m2pr_property_id, m2pr_datetime, m2pr_user)
                       values  (?, ?, ?, ?)
                      ", undef,
                      $mouse_id, $property_id, $import_datetime_sql, $coach_user
                     ) or &error_message_and_exit($global_var_href, "SQL error (could not insert father of mouse)", $sr_name . "-" . __LINE__);
         }

         # add 1. mother of this mouse
         if (defined($mother1) && ($mother1 ne '')) {
             # get the next property id
             ($property_id) = $dbh->selectrow_array("select (max(property_id)+1) as next_id
                                                     from   properties
                                                    ");

             # ok, this is only neccessary for the very first property when (max(property_id)+1) = (NULL + 1) is undefined
             if (!defined($property_id)) { $property_id = 1; }

             $dbh->do("insert
                       into    properties (property_id, property_category, property_key, property_type, property_value_integer,
                                           property_value_bool, property_value_float, property_value_text)
                       values  (?, ?, ?, ?, NULL, NULL, NULL, ?)
                      ", undef,
                      $property_id, 'mouse', 'genetic_mother', 'text', $mother1
                     ) or &error_message_and_exit($global_var_href, "SQL error (could not insert father of mouse)", $sr_name . "-" . __LINE__);

             $dbh->do("insert
                       into    mice2properties (m2pr_mouse_id, m2pr_property_id, m2pr_datetime, m2pr_user)
                       values  (?, ?, ?, ?)
                      ", undef,
                      $mouse_id, $property_id, $import_datetime_sql, $coach_user
                     ) or &error_message_and_exit($global_var_href, "SQL error (could not insert father of mouse)", $sr_name . "-" . __LINE__);
         }

         # add 2. mother of this mouse
         if (defined($mother2) && ($mother2 ne '')) {
             # get the next property id
             ($property_id) = $dbh->selectrow_array("select (max(property_id)+1) as next_id
                                                     from   properties
                                                    ");

             # ok, this is only neccessary for the very first property when (max(property_id)+1) = (NULL + 1) is undefined
             if (!defined($property_id)) { $property_id = 1; }

             $dbh->do("insert
                       into    properties (property_id, property_category, property_key, property_type, property_value_integer,
                                           property_value_bool, property_value_float, property_value_text)
                       values  (?, ?, ?, ?, NULL, NULL, NULL, ?)
                      ", undef,
                      $property_id, 'mouse', 'genetic_mother', 'text', $mother2
                     ) or &error_message_and_exit($global_var_href, "SQL error (could not insert father of mouse)", $sr_name . "-" . __LINE__);

             $dbh->do("insert
                       into    mice2properties (m2pr_mouse_id, m2pr_property_id, m2pr_datetime, m2pr_user)
                       values  (?, ?, ?, ?)
                      ", undef,
                      $mouse_id, $property_id, $import_datetime_sql, $coach_user
                     ) or &error_message_and_exit($global_var_href, "SQL error (could not insert father of mouse)", $sr_name . "-" . __LINE__);
         }

         # add the mouse to a cost centre
         $dbh->do("insert
                   into   mice2cost_accounts (m2ca_cost_account_id, m2ca_mouse_id, m2ca_datetime_from, m2ca_datetime_to)
                   values (?, ?, ?, NULL)
                  ", undef, $cost_centre, $mouse_id,  $import_datetime_sql
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

         $page .= Tr({-bgcolor=>$sex_color->{$sex}},
                    td($i),
                    td(checkbox('mouse_select', '0', $mouse_id, '')),
                    td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse_id, -title=>"click for mouse details"}, &reformat_number($mouse_id, 8))),
                    td($external_id),
                    td($row->{'mouse_earmark'}),
                    td($row->{'mouse_sex'}),
                    td(get_color_name_by_id($global_var_href, $row->{'mouse_coat_color'})),
                    td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                    td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                    td($row->{'strain_name'}),
                    td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                    td($row->{'location_room'} . '-' . $row->{'location_rack'}),
                    td(a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"}, &reformat_number($row->{'cage_id'}, 4))),
                    td($father),
                    td($mother1),
                    td($mother2),
                    td({-align=>'left'}, $short_comment),
                    td($import_remark)
                  );
     }
     # end of loop over mice

     $page .= end_table()
              . p();


     # finally insert import
     $dbh->do("insert
               into    imports (import_id, import_group, import_name, import_type, import_strain, import_line, import_datetime,
                                import_owner_name, import_provider_name, import_provider_contact, import_coach_user, import_purpose,
                                import_origin_code, import_origin_location, import_project, import_checkcode, import_comment)
               values  (?, ?, ?, ?, ?, ?, ?,
                        ?, ?, NULL, ?, ?,
                        ?, NULL, ?, ?, ?)
              ", undef,
              $import_id, $import_id, $import_name, $import_type, $import_strain, $line, $import_datetime_sql,
              $dbh->quote($import_owner_name), $dbh->quote($import_provider_name), $coach_user, 'purpose',
              '', $import_project, $import_checkcode, $import_comment
             ) or &error_message_and_exit($global_var_href, "SQL error (could not set weaning date)", $sr_name . "-" . __LINE__);

     # reset GTAS report flag in GTAS_line_info, set new import date
     $entry_date_sql = format_display_date2sql_date(format_sql_datetime2display_date($import_datetime_sql));

     $dbh->do("update GTAS_line_info
               set    gli_generate_GTAS_report     = ?, gli_GVO_ErzeugtAm = ?
               where      gli_mouse_line_id        = ?
                      and gli_generate_GTAS_report = ?
             ", undef, 'y', "$entry_date_sql", $line, 'n'
          ) or &error_message_and_exit($global_var_href, "SQL error (could not update GTAS info)", $sr_name . "-" . __LINE__);
  }
  else {
     $page .= h3(" no mice to import ");
  }

  # import generated, so commit
  $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

  # end transaction
  ############################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $move_user_id);

  &write_textlog($global_var_href, "$datetime_now\t$move_user_id\t" . $session->param('username') . "\timport\t$import_id\t$import_datetime_sql\t" . join(',', @imported_mice));

  if (defined($import_notification) && $import_notification ne "") { $import_notification .= hr(); }
  else                                                             { $import_notification = '';    }

  # Provide links to set up matings for mixed cages
  $page .= hr()
           . $import_notification
           . h3("Print cage cards [and optionally: set up matings for mixed cages]")
           . p("You may want to print (new) cage cards for all cages involved in the import. Please use the links below.")
           . p("You may also want to setup matings for all cages containing both males and females. ")
           . p()
           . start_table( {-border=>1, -summary=>"table"})
           . Tr(
               td({-align=>"center", -valign=>"top"}, b("[Optional: set up mating(s) in separate windows first ... ]") . br() . small("(mating setup dialog will open in new window)")),
               td({-align=>"center", -valign=>"top"}, b("then print cage card(s)"))
             );

  # loop over all cages to provide 1) "set up mating" links if applicable and 2) "print cage card" links
  foreach $print_cage (sort {$a <=> $b} keys %all_cages) {
     # find out if mixed cage
     ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, undef, undef, $cage_capacity) = get_mice_in_cage($global_var_href, $print_cage);

     if ($sex_mixed eq 'true') {
        # reset cagemates
        @cagemates = ();

        # find out all mice in this cage
        $sql = qq(select m2c_mouse_id
                  from   mice2cages
                  where  m2c_cage_id = ?
                         and m2c_datetime_to IS NULL
                 );

        @sql_parameters = ($print_cage);

        ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

        for ($i=0; $i<$rows; $i++) {
            $row = $result->[$i];
            push(@cagemates, $row->{'m2c_mouse_id'});
        }

        @cagemates = unique_list(@cagemates);

        $page .= Tr(
                   td({-align=>"center"}, a({-href=>"$url?job=mate&mouse_select=" . join('&mouse_select=', @cagemates) . "&move_mode=no_move", -target=>"_blank"}, "set up mating for mice in cage " . reformat_number($print_cage, 4))),
                   td({-align=>"center"}, a({-href=>"$url?choice=print_card&cage_id=" . $print_cage, -target=>"_blank"}, "print card for cage " . reformat_number($print_cage, 4)))
                 );
     }
     else {
        $page .= Tr(
                   td(),
                   td({-align=>"center"}, a({-href=>"$url?choice=print_card&cage_id=" . $print_cage, -target=>"_blank"}, "print card for cage " . reformat_number($print_cage, 4)))
                 );
     }
  }

  $page .= end_table();


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
              . h3("Import successful! ")
              . p("You may want to see imported mice " . a({-href=>"$url?choice=import_view&import_id=" . $import_id}, "here"))
              . hr()
              . submit(-name => "job", -value=>"Add selected mice to cart");
  }

  $page .= end_form();

  return $page;
}
# end of import_step_5
#--------------------------------------------------------------------------------------


# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;