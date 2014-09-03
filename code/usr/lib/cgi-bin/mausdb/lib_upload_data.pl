# lib_upload.pl - a MausDB subroutine library file                                                                               #
#                                                                                                                                #
# Subroutines in this file provide functions related to upload of phenotyping data                                               #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_UPL001 upload_step_1():                             upload phenotyping data (1. step: initial form)                         #
# SR_UPL002 upload_step_1a():                            choose worksheet (1a. step: choose worksheet)                           #
# SR_UPL003 upload_step_2():                             upload phenotyping data (2. step: upload Excel file)                    #
# SR_UPL004 upload_step_3():                             upload phenotyping data (3. step: store in database)                    #
# SR_UPL005 upload_blob_step_1():                        upload blob (1. step: initial form)                                     #
# SR_UPL006 upload_blob_step_2():                        upload blob (2. step: store in database)                                #
# SR_UPL007 upload_line_blob_step_1():                   upload line blob (1. step: initial form)                                #
# SR_UPL008 upload_line_blob_step_2():                   upload line blob (2. step: store in database)                           #
# SR_UPL009 upload_multi_blob_for_mouse_step_1():        upload multiple blobs for a mouse (1. step: initial form)               #
# SR_UPL010 upload_multi_blob_for_mouse_step_2():        upload multiple blobs for a mouse (2. step: store in database)          #
# SR_UPL011 assign_media_files_step_1():                 assign media files to mice from orderlist (1. step: initial form)       #
# SR_UPL012 assign_media_files_step_2():                 assign media files to mice from orderlist (2. step: store in database ) #
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
# SR_UPL001 upload_step_1():                             upload phenotyping data (1. step: initial form)
sub upload_step_1 {                                      my $sr_name = 'SR_UPL001';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url     = url();
  my $parameterset = param('parameterset');
  my $session = $global_var_href->{'session'};
  my $user_id = $session->param(-name=>'user_id');
  my ($page);

  # check orderlist: 1) an orderlist id must be given, 2) it has to be strictly numeric (prevent SQL injections)
  if (!defined(param('orderlist_id')) || param('orderlist_id') !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid or missing orderlist id (must be a number)", $sr_name . "-" . __LINE__);
  }

  $page = h2("Upload phenotyping data: 1. step")
          . hr();

  # first table (litter details)
  $page .= start_form(-action=>url(), -name=>"myform", -enctype=>"multipart/form-data")
           . hidden('parameterset')
#            h3("1) Please choose the parameterset for data to be uploaded")
#
#            . start_form(-action=>url(), -name=>"myform", -enctype=>"multipart/form-data")
#
#            . table(
#                Tr( th("parameterset"),
#                    td(get_parametersets_popup_menu($global_var_href, $parameterset))
#                )
#              )

           . h3("Please choose the Excel file containing the phenotyping data and proceed")

           . p()

           . table( {-border=>0, -summary=>"table"},
                  Tr(
                    td({-colspan=>2},   b(" Upload from Excel file ")
                                      . br() . br()
                                      . filefield(-name=>'data_file', -default=>'', -size=>80, -maxlength=>80,
                                                  -onclick=>"document.myform.import_mode[0].checked=true")
                    )
                  )
             )

           . p()
           . hidden(-name=>"step",   -value=>"upload_step_1", -override=>1)
           . hidden(-name=>"first",  -value=>"1")
           . hidden('mouse_select')
           . hidden('orderlist_id')
           . submit(-name=>"choice", -value=>"next step", -title=>"next step")
           . "&nbsp;&nbsp;or&nbsp;&nbsp;"
           . a({-href=>"javascript:back()"}, "go back")
           . end_form();

  return $page;
}
# end of upload_step_1
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_UPL002 upload_step_1a():                            choose worksheet (1a. step: choose worksheet)
sub upload_step_1a {                                     my $sr_name = 'SR_UPL002';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh = $global_var_href->{'dbh'};                   # database handle
  my $url = url();
  my $upload_filename = param('data_file');              # save original filename (we need this for doing the upload)
  my ($local_filename);
  my $session  = $global_var_href->{'session'};
  my $user_id  = $session->param(-name=>'user_id');
  my $username = $session->param(-name=>'username');
  my ($page, $xls, $i, $data, $sheet_object, $filesize, $orderlist_id);
  my @sheets;
  my %sheetname_by_id;
  my %public_labels = ('y' => 'yes', 'n' => 'no');

  # check orderlist: 1) an orderlist id must be given, 2) it has to be strictly numeric (prevent SQL injections)
  if (!defined(param('orderlist_id')) || param('orderlist_id') !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid or missing orderlist id (must be a number)", $sr_name . "-" . __LINE__);
  }
  
  # untaint orderlist id
  if (param('orderlist_id') =~ /^([0-9]+)$/) {
     $orderlist_id = $1;
  }

  use Spreadsheet::ParseExcel::Simple;
  use Spreadsheet::ParseExcel;

  ########################################
  # upload the Excel file to a local directory

  # assign a local filename (composed from user name and Unix timestamp)
  $local_filename = 'orderlist_' . $orderlist_id . '_' . $username . '_' . time() . '.xls';

  # open write handle for uploaded file on server
  open(DAT, "> ./uploads/$local_filename") or &error_message_and_exit($global_var_href, "Error processing file $!", $sr_name . "-" . __LINE__);

  binmode $upload_filename;                                               # switch to binary mode
  binmode DAT;                                                            # switch to binary mode

  while(read $upload_filename, $data, 1024) {                             # actually write uploaded file on server
      print DAT $data;
      $filesize += length($data);
  }

  close DAT;                                                              # close write handle

  # file has been uploaded to the server now
  # write upload_log ...
  &write_upload_log($dbh, $session->param(-name=>'user_id'), $session->param(-name=>'username'), $dbh->quote($upload_filename), $local_filename);

  ##########################################

  # create Spreadsheet::ParseExcel::Simple excel object from uploaded file
  $xls = Spreadsheet::ParseExcel::Simple->read("./uploads/$local_filename");

  # check if we can access and open the file on the server directory
  unless (defined($xls)) {
    $page .= h3("... could not open $upload_filename !");
    return $page;
  }

  # get all sheets from this object
  @sheets = $xls->sheets;

  # loop over all sheets and create a look-up hash (sheet id --> sheet name)
  for ($i=0; $i<=$#sheets; $i++) {
      $sheetname_by_id{$i} = $sheets[$i]->sheet->{Name};
  }

  $page .= h2("Upload phenotyping data: 1a. step")
          . hr();

  # first table
  $page .= h3("1) Please choose the worksheet")

           . start_form(-action=>url(), -name=>"myform", -enctype=>"multipart/form-data")
           . popup_menu( -name    => 'sheet',
                         -values  => [sort keys %sheetname_by_id],
                         -labels  => \%sheetname_by_id
                       )
           . p()
           . p(b("Transpose sheet upon upload? &nbsp;&nbsp;") . radio_group(-name=>'transpose', -values=>['y', 'n'], -default=>'n', -labels=>\%public_labels))
           . p()
           . hidden(-name=>"step",   -value=>"upload_step_1a", -override=>1)
           . hidden(-name=>"first",  -value=>"1")
           . hidden('parameterset')
           . hidden('data_file')
           . hidden('mouse_select')
           . hidden('orderlist_id')
           . hidden(-name=>'local_filename', -value=>$local_filename)

           . submit(-name=>"choice", -value=>"next step", -title=>"next step")
           . "&nbsp;&nbsp;or&nbsp;&nbsp;"
           . a({-href=>"javascript:back()"}, "go back")
           . end_form();

  return $page;
}
# end of upload_step_1a
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_UPL003 upload_step_2():                             upload phenotyping data (2. step: upload Excel file)
sub upload_step_2 {                                      my $sr_name = 'SR_UPL003';
  my ($global_var_href) = @_;                                 # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};          # database handle
  my $session           = $global_var_href->{'session'};      # session handle
  my $user_id           = $session->param(-name=>'user_id');  # read username from session
  my $username          = $session->param(-name=>'username'); # read username from session
  my $parameterset      = param('parameterset');
  my $sheet_number      = param('sheet');
  my $orderlist_id      = param('orderlist_id');
  my $transpose_yn;
  my @status_code_list  = get_mr_status_codes_list($global_var_href);
  my $is_code_instead_value;
  my $filesize          = 0;                                  # counter for size of uploaded file
  my $url               = url();
  my ($page, $i, $j, $sheet, $xls, $data, $field);
  my ($sql, $result, $rows, $row, $k, $sheet_counter);
  my ($upload_filename, $local_filename, $column_number, $current_mouse, $current_date, $checked, $converted_date);
  my ($cell_bgcolor, $td_align, $cell_comment, $current_value, $candidate_orderlists, $selected_mouse, $status_code);
  my @sql_parameters;
  my ($dd, $mm, $yy, $hh, $min, $ss, $within_bounds);
  my @sheets;
  my @row_data;
  my @row_for_display;
  my %parameter_id_by_column;              # map Excel colum to parameter id
  my %parameter_shortname_by_id;           # map parameter id to parameter shortname
  my %parameter_name_by_id;                # map parameter id to parameter name
  my %parameter_id_by_name;                # map parameter name to parameter id
  my %parameter_type_by_id;                # map parameter id to parameter type
  my %parameter_unit_by_id;                # map parameter id to parameter unit
  my %parameter_upload_name_by_id;         # map parameter id to upload column name
  my %parameter_decimals_by_id;            # map parameter id to decimals
  my %parameter_is_serial_by_column;
  my %increment_value_by_column;
  my %increment_unit_by_column;
  my %parameter_required_by_column;
  my $mouse_id_column     = get_column_in_upload_file($global_var_href, 'mouse_id',     $parameterset);
  my $measure_date_column = get_column_in_upload_file($global_var_href, 'measure_date', $parameterset);
  my %sheetname_by_id;
  my $error_count           = 0;
  my $table_bgcolor         = '#80FFFF';
  my $error_type_bgcolor    = '#FFC0C0';
  my $error_novalue_bgcolor = '#FFFFC0';
  my %public_labels         = ('y' => 'yes', 'n' => 'no');
  my %mouse_chosen;
  my %mouse_seen;
  my @mice;
  my @current_row;
  my @table;
  my $current_row_ref;

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB ids
  foreach $selected_mouse (@selected_mice) {
     if ($selected_mouse =~ /^[0-9]{8}$/) {
        $mouse_chosen{$selected_mouse}++;
     }
  }

  use Spreadsheet::ParseExcel::Simple;
  use Spreadsheet::ParseExcel;
  use Array::Transpose;

  $page .= h2("Upload phenotyping data: 2. step")
           . hr();

  $page .= h3("Trying to upload Excel file ... ")
           . start_form(-action=>url(), -name=>"myform");

  # check parameterset: 1) a parameterset id must be given, 2) it has to be strictly numeric (prevent SQL injections)
  if (!defined(param('parameterset')) || param('parameterset') !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid parameterset id (must be a number)", $sr_name . "-" . __LINE__);
  }

  # check if filename submitted
  if (!param("data_file") || param("data_file") eq '') {
     $page .= p({-class=>"red"}, b("Error: please specify an import file"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }
  # check if filename ends with "xls" (ok, this is not really sufficient to check if it is an excel file)
  elsif (param("data_file") !~ /xls$/) {
     $page .= p({-class=>"red"}, b("File needs to be an Excel file (ending with .xls)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check orderlist: 1) an orderlist id must be given, 2) it has to be strictly numeric (prevent SQL injections)
  if (!defined(param('orderlist_id')) || param('orderlist_id') !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid or missing orderlist id (must be a number)", $sr_name . "-" . __LINE__);
  }

  # check if table is to be transposed
  if (defined(param("transpose")) && param("transpose") eq 'y') {
     $transpose_yn = 'y';
  }
  else {
     $transpose_yn = 'n';
  }

  ########################################
  # pull parameterset data from database in order to align parameters to upload columns

  $sql = qq(select parameterset_name, parameter_id, parameter_name, parameter_shortname, p2p_upload_column, parameter_decimals,
                   p2p_upload_column_name, parameter_type, parameter_unit,
                   p2p_parameter_category, p2p_increment_value, p2p_increment_unit, p2p_parameter_required
            from   parametersets2parameters
                   join parameters    on    parameter_id = p2p_parameter_id
                   join parametersets on parameterset_id = p2p_parameterset_id
            where  p2p_parameterset_id = ?
            order  by p2p_upload_column
          );

  @sql_parameters = ($parameterset);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and generate mapping tables
  for ($k=0; $k<$rows; $k++) {
      $row = $result->[$k];

      $parameter_id_by_column{$row->{'p2p_upload_column'}}        = $row->{'parameter_id'};
      $parameter_is_serial_by_column{$row->{'p2p_upload_column'}} = $row->{'p2p_parameter_category'};
      $increment_value_by_column{$row->{'p2p_upload_column'}}     = $row->{'p2p_increment_value'};
      $increment_unit_by_column{$row->{'p2p_upload_column'}}      = $row->{'p2p_increment_unit'};
      $parameter_required_by_column{$row->{'p2p_upload_column'}}  = $row->{'p2p_parameter_required'};
      $parameter_upload_name_by_id{$row->{'p2p_upload_column'}}   = $row->{'p2p_upload_column_name'};
      $parameter_name_by_id{$row->{'parameter_id'}}               = $row->{'parameter_name'};
      $parameter_type_by_id{$row->{'parameter_id'}}               = $row->{'parameter_type'};
      $parameter_unit_by_id{$row->{'parameter_id'}}               = $row->{'parameter_unit'};
      $parameter_decimals_by_id{$row->{'parameter_id'}}           = $row->{'parameter_decimals'};
      $parameter_shortname_by_id{$row->{'parameter_id'}}          = $row->{'parameter_shortname'};
      $parameter_id_by_name{$row->{'parameter_name'}}             = $row->{'parameter_id'};
  }

  ########################################
  # get upload_filename and local_filename from previous form
  $upload_filename = param("data_file");
  $local_filename  = param('local_filename');
  ##########################################

  # parse and display Excel file content. Use parameterset data stored in database

  # create Spreadsheet::ParseExcel::Simple excel object from uploaded file
  $xls = Spreadsheet::ParseExcel::Simple->read("./uploads/$local_filename");

  unless (defined($xls)) {
    $page .= h3("... could not open $upload_filename !");
    return $page;
  }

  # get all sheets from this object and create hashtable
  @sheets = $xls->sheets;

  for ($sheet_counter=0; $sheet_counter<=$#sheets; $sheet_counter++) {
      $sheetname_by_id{$sheet_counter} = $sheets[$sheet_counter]->sheet->{Name};
  }

  $page .= h3("... file \"$upload_filename\" successfully uploaded.")
           . p("Using sheet \"$sheetname_by_id{$sheet_number}\" of uploaded file \"$upload_filename\"")
           . p("Please use the checkboxes to select or de-select rows (mice) and/or columns (values) for data upload.");

  $page .= start_table( {-border=>'1', -summary=>"table", -bgcolor=>$table_bgcolor} );

  ##################################
  # first row: we need a header line
  # read sheet into memory table
  while ($sheets[$sheet_number]->has_data) {                   # as long as there are lines with content ...
     @current_row = $sheets[$sheet_number]->next_row;          # ... fetch the next row
     push(@table, [@current_row]);                             # add row array to table array: @table is a 2D-array (we copy the Excel table to a 2D-array)
  }

  # transpose 2D table if requested (using Array::Transpose function)
  if ($transpose_yn eq 'y') {
     @table = transpose(\@table);
  }

  #compare expected columns to columns in excel data
  my $key;
  @row_data = @{$table[0]}; #Excel data
  foreach $key (keys (%parameter_upload_name_by_id)){
  	
  	unless($parameter_upload_name_by_id{$key} eq $row_data[$key - 1]) {
  		
  		#error only for required values
  		if ($parameter_required_by_column{$key} eq 'y') {
  			$page .= h3({-class=>"red"}, "Error: missing required data ($parameter_upload_name_by_id{$key}) assigned to this orderlist! ");
  		}
  	}
  }

  # now loop over rows from 2D-array
  foreach $current_row_ref (@table) {
     @row_data = @{$current_row_ref};                          # ... fetch the next row
     @row_for_display = ();                                    # reset output row
     $i++;

     if ($i > 1) { last; }       # restrict to first row with column headers

     # add fixed columns to header
     push(@row_for_display, th('select'),
                            th('mouse_id'),
                            th('measure_date')
     );

     # add parameterset-specific columns to header row
     for ($field = 0; $field <=$#row_data; $field++) {
         if (defined($parameter_id_by_column{$field+1})) {
            # check if column header from uploaded Excel file equals the column header defined in the database
            # "do we get what we expect in column 13?"

            # 1. case: all fine ...
            if ($parameter_upload_name_by_id{$field+1} eq $row_data[$field]) {
               push(@row_for_display, th($parameter_upload_name_by_id{$field+1} . br() . small('[' . $parameter_is_serial_by_column{$field+1} . ']')));
            }
            # 2. case: mismatch ...
            else {
               push(@row_for_display, th(span({-class=>"red"}, 'column' . br() . 'mismatch') . br()
                                                          . 'Expected: ' . $parameter_upload_name_by_id{$field+1} . br()
                                                          . 'Excel: ' . $row_data[$field]
                                      )
               );
               $error_count++;
            }
         }
     }

     $page .= Tr(@row_for_display);
  }
  # end of header
  ##################################
  
  # reset
  $i = 0;
  @sheets = $xls->sheets;       # this is to reset the sheet object, thereby putting cursor back to A1
  @table = ();

  ##################################
  # now the data...

  # read sheet into memory table
  while ($sheets[$sheet_number]->has_data) {                   # as long as there are lines with content ...
     @current_row = $sheets[$sheet_number]->next_row;          # ... fetch the next row
     push(@table, [@current_row]);                             # add row array to table array: @table is a 2D-array (we copy the Excel table to a 2D-array)
  }

  # transpose 2D table if requested
  if ($transpose_yn eq 'y') {
     @table = transpose(\@table);
  }

  # now loop over rows from 2D-array
  foreach $current_row_ref (@table) {
     @row_data = @{$current_row_ref};                          # ... fetch the next row
     @row_for_display = ();                                    # reset output row
     $i++;

     # skip first row = header row (we already used it above)
     if ($i == 1) { next; };

     ##################################
     # get mouse id
     $current_mouse = $row_data[$mouse_id_column - 1];

     # skip line if mouse not on order list
     if (!defined($mouse_chosen{$current_mouse})) { next; }

     # skip row if not a valid mouse id
     if ($current_mouse !~ /^[0-9]{8}$/) {
        push(@row_for_display, td({-class=>'red'}, b('no mouse id, line skipped')), td($current_mouse));
        $page .= Tr(@row_for_display);
        next;
     }

     # mark mouse as already seen
     $mouse_seen{$current_mouse}++;
     ##################################

#      ##################################
#      # get date/time of sample taking / date of measurement (whichever is more relevant)
#      $current_date  = $row_data[$measure_date_column - 1];
#
#      # try to convert Excel-formatted date "22/05/06 12:02:02" into human-readable format "22.05.2006"
#      if ($current_date =~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2}$/) {
#         ($dd, $mm, $yy, $hh, $min, $ss) = split(/\/\s/, $current_date);
#         $converted_date = $dd . '.' . $mm . '.' . (2000 + $yy) . ' ' . $hh . ':' . $min . ':' . $ss;
#      }
#      elsif ($current_date =~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{4}\s[0-9]{2}:[0-9]{2}:[0-9]{2}$/) {
#         ($dd, $mm, $yy, $hh, $min, $ss) = split(/[\/\s\:]/, $current_date);
#         $converted_date = $dd . '.' . $mm . '.' . $yy . ' ' . $hh . ':' . $min . ':' . $ss;
#      }
#      # try to convert Excel-formatted date "05-22-06" into human-readable format "22.05.2006"
#      elsif ($current_date =~ /^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2}$/) {
#         ($mm, $dd, $yy, $hh, $min, $ss) = split(/-\s/, $current_date);
#         $converted_date = reformat_number($dd, 2) . '.' . reformat_number($mm, 2) . '.' . (2000 + $yy) . ' ' . $hh . ':' . $min . ':' . $ss;
#      }
#      # try to convert Excel-formatted date "05/22/2006 9:34:34 AM" into human-readable format "22.05.2006"
#      elsif ($current_date =~ /^[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}\s[0-9]{1,2}\:[0-9]{2}\:[0-9]{2}\s[A-Z]{2}$/) {
#         ($mm, $dd, $yy) = split(/\//, $current_date);
#         ($yy, undef) = split(/\s/, $yy);
#         $converted_date = reformat_number($dd, 2) . '.' . reformat_number($mm, 2) . '.' . $yy;
#      }
#      # try to convert Excel-formatted date "05/22/06 9:34" into human-readable format "22.05.2006"
#      elsif ($current_date =~ /^[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}\s[0-9]{1,2}\:[0-9]{2}$/) {
#         ($mm, $dd, $yy) = split(/\//, $current_date);
#         ($yy, undef) = split(/\s/, $yy);
#         $converted_date = reformat_number($dd, 2) . '.' . reformat_number($mm, 2) . '.' . $yy;
#      }
#      else {
#         $converted_date = $current_date;
#      }
#
#      # skip row if not a valid measure date
#      if ($converted_date !~ /^[0-9]{2}\.[0-9]{2}\.[0-9]{4}\s[0-9]{2}:[0-9]{2}:[0-9]{2}$/ || check_datetime_ddmmyyyy_hhmmss($converted_date) != 1) {
#         push(@row_for_display, td({-class=>'red'}, b("not a valid date, line skipped")), td($current_mouse), td($converted_date));
#         $page .= Tr(@row_for_display);
#         next;
#      }
#      ##################################

     ################################## as currently active on castor
     # get date of sample taking / date of measurement (whichever is more relevant)
     $current_date  = $row_data[$measure_date_column - 1];

     # try to convert Excel-formatted date "22/05/06" into human-readable format "22.05.2006"
     if ($current_date =~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{2}$/) {
        ($dd, $mm, $yy) = split(/\//, $current_date);
        $converted_date = $dd . '.' . $mm . '.' . (2000 + $yy);
     }
     # try to convert Excel-formatted date "05-22-06" into human-readable format "22.05.2006"
     elsif ($current_date =~ /^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$/) {
        ($mm, $dd, $yy) = split(/-/, $current_date);
        $converted_date = reformat_number($dd, 2) . '.' . reformat_number($mm, 2) . '.' . (2000 + $yy);
     }
     # try to convert Excel-formatted date "05/22/2006 9:34:34 AM" into human-readable format "22.05.2006"
     elsif ($current_date =~ /^[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}\s[0-9]{1,2}\:[0-9]{2}\:[0-9]{2}\s[A-Z]{2}$/) {
        ($mm, $dd, $yy) = split(/\//, $current_date);
        ($yy, undef) = split(/\s/, $yy);
        $converted_date = reformat_number($dd, 2) . '.' . reformat_number($mm, 2) . '.' . $yy;
     }
     # try to convert Excel-formatted date "05/22/06 9:34" into human-readable format "22.05.2006"
     elsif ($current_date =~ /^[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}\s[0-9]{1,2}\:[0-9]{2}$/) {
        ($mm, $dd, $yy) = split(/\//, $current_date);
        ($yy, undef) = split(/\s/, $yy);
        $converted_date = reformat_number($dd, 2) . '.' . reformat_number($mm, 2) . '.' . $yy;
     }
     else {
        $converted_date = $current_date;
     }

     # skip row if not a valid measure date
     if ($converted_date !~ /^[0-9]{2}\.[0-9]{2}\.[0-9]{4}$/ || check_date_ddmmyyyy($converted_date) != 1) {
        push(@row_for_display, td({-class=>'red'}, b('not a valid date, line skipped')), td($current_mouse), td($current_date));
        $page .= Tr(@row_for_display);
        next;
     }

     # skip row if measure date in the future
     if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), $converted_date . ' 00:00:00') eq 'future') {
        push(@row_for_display, td({-class=>'red'}, b('measure date is in future, line skipped')), td($current_mouse), td($converted_date));
        $page .= Tr(@row_for_display);
        next;
     }

     # skip row if measure date is past date of death for current mouse
     if (defined(get_date_of_death($global_var_href, $current_mouse))) {
        if (Delta_ddmmyyyhhmmss(format_sql_datetime2display_datetime(get_date_of_death($global_var_href, $current_mouse)), $converted_date . ' 00:00:00') eq 'future') {
           push(@row_for_display, td({-class=>'red'}, b('measure date is past date of death, line skipped')), td($current_mouse), td($converted_date));
           $page .= Tr(@row_for_display);
           next;
        }
     }
     ##################################

     # checks for mouse_id and date/time passed, so continue with values
     push(@mice, $current_mouse);

     # add a checkbox as first column
     push(@row_for_display, td({-align=>'center'}, checkbox('mouse_select', (($current_mouse =~ /^[0-9]{8}$/)?'1':'0'), $current_mouse, '')));
     push(@row_for_display, td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $current_mouse}, $current_mouse)));
     push(@row_for_display, td({-align=>"center"}, $converted_date));

     # loop over all columns of current row
     for ($field = 0; $field <=$#row_data; $field++) {

         # reset ...
         $cell_bgcolor  = $table_bgcolor;
         $td_align      = 'left';
         $cell_comment  = 'ok';
         $current_value = $row_data[$field];
         undef $is_code_instead_value;
         undef $status_code;

         # CHECK if a parameter is defined and expected for the current column, otherwise just ignore this column
         # yes, column defined (ie. value expected): process column
         if (defined($parameter_id_by_column{$field + 1})) {

            # CHECK if field content is not a value but a status code (from a defined list): get number of matches
            $is_code_instead_value = grep {$_ eq $current_value} @status_code_list;

            # yes, status code: display it
            if ($is_code_instead_value > 0) {
                $cell_bgcolor  = $error_novalue_bgcolor;
                $status_code   = $current_value;
                $cell_comment  = "no value, status code: $status_code";
                $current_value = '[' . $current_value . ']';
            }

            # no status code, proceed normally
            else {

                # CHECK if empty or undefined cell
                # yes, empty or undefined
                if (!defined($row_data[$field]) || $row_data[$field] eq '') {

                   # CHECK: is value required?
                   # yes, it is required: error message
                   if ($parameter_required_by_column{$field + 1} eq 'y') {
                      # error message
                              $cell_bgcolor = $error_type_bgcolor;
                              $cell_comment = "values required but missing: please provide value or status code!";
                              $error_count++;
                   }

                   # no, not required: skip silently
                   else {
                      # skip silently
                      $cell_bgcolor  = $error_novalue_bgcolor;
                      $cell_comment = "ok (missing, but not required)";
                   }

                   $current_value = '[missing]';
                }

                # no, there is something in it: proceed normally
                else {
                    # CHECK type: float
                    if ($parameter_type_by_id{$parameter_id_by_column{$field + 1}} eq 'f') {
                        $td_align = 'right';

                        # we have not the expected float, but something different
                        if ($current_value !~ /^[\-]{0,1}[0-9\.]+$/) {
                              $cell_bgcolor = $error_type_bgcolor;
                              $cell_comment = "not a float number";
                              $error_count++;
                              $current_value = '[type error]';
                        }
                        # we have a float: round to number of decimals defined in parameter definition
                        else {
                           # round floating number according to decimals defined in the database
                           $current_value = round_number($current_value, $parameter_decimals_by_id{$parameter_id_by_column{$field + 1}});
                        }
                    }

                    # CHECK type: integer
                    if ($parameter_type_by_id{$parameter_id_by_column{$field + 1}} eq 'i') {
                       $td_align = 'right';

                       # we have not the expected int, but something different
                       if ($current_value !~ /^[\-]{0,1}[0-9]+$/ && $current_value ne '-') {
                             $cell_bgcolor = $error_type_bgcolor;
                             $cell_comment = "not an integer number";
                             $error_count++;
                             $current_value = '[type error]';
                       }
                       # we have an int: all fine
                       else {
                          # round floating number according to decimals defined in the database
                          $current_value = round_number($current_value, $parameter_decimals_by_id{$parameter_id_by_column{$field + 1}});
                       }
                    }

#                     # CHECK type: datetime
#                     if ($parameter_type_by_id{$parameter_id_by_column{$field + 1}} eq 't') {
#                        $td_align = 'right';
# 
#                        # we have not the expected datetime, but something different
#                        if (check_datetime_ddmmyyyy_hhmmss($current_value) != 1) {
#                              $cell_bgcolor = $error_type_bgcolor;
#                              $cell_comment = "not a valid datetime (18.06.2010 14:28:00)";
#                              $error_count++;
#                              $current_value = '[type error]';
#                        }
#                        # we have a datetime: all fine
#                        else {
#                           # all fine, take it
#                        }
#                     }
                }
            }

            # CHECK bounds: is value within bounds that are defined for this parameter?
            # TODO: currently stub procedure, always returns 'y'
            $within_bounds = is_value_within_bounds($global_var_href, $current_value, $parameter_id_by_column{$field + 1});

            # value failed bound check
            if ($within_bounds ne 'y') {
                $cell_bgcolor = $error_type_bgcolor;
                $cell_comment = "value not within bounds";
                $error_count++;
                $current_value = $current_value . ' [bounds error]';
            }

            # value within bounds: all fine
            else {
                # do nothing
            }

            push(@row_for_display, td({-bgcolor=>$cell_bgcolor, -align=>$td_align, -title=>$cell_comment}, $current_value));
         }

         # no, column not defined, no value expected: skip it
         else {
            # silently skip line, do nothing
         }
     }

     # add the row to the table
     if ($mouse_seen{$current_mouse} > 1) {
        $page .= Tr({-bgcolor=>"yellow", -title=>"warning: multiple use of same mouse ID"}, @row_for_display);
     }
     else {
        $page .= Tr(@row_for_display);
     }
  }
  # end of data
  ##################################

  $page .= end_table()
           . p("$error_count errors ");

  $page .= hr({-align=>'left', -width=>'50%'})
           . h3("Please provide some additional data:")

           . table({-border=>1, -bgcolor=>$table_bgcolor},
                  Tr( td(b("project, to which data belongs")),
                      td(get_projects_popup_menu($global_var_href, 2, undef)),       # variable name. "all_projects"
                      td(b("is data public?")),
                      td(radio_group(-name=>'data_is_public', -values=>['y', 'n'], -default=>3, -labels=>\%public_labels))
                  )
                . Tr( td(b("user (responsible)")),
                      td({-colspan=>3}, get_users_popup_menu($global_var_href, $user_id, 'responsible_user'))
                  )
                . Tr( td(b("user (measured)")),
                      td({-colspan=>3}, get_users_popup_menu($global_var_href, $user_id, 'measure_user'))
                  )
             );

   if (get_number_medical_records_of_orderlist($global_var_href, $orderlist_id) > 0) {
      $page .= h3({-class=>"red"}, "Warning: found data assigned to this orderlist! " . br()
                                   . "Please " . a({-href=>"$url?choice=orderlist_view&orderlist_id=$orderlist_id", -target=>"_blank"}, "check orderlist here (opens in new window)")
                                   . " before upload to avoid multiple entries!"
               );
   }

#   # try to find candidate orderlists
#   $candidate_orderlists = get_candidate_orderlists_table($global_var_href, \@mice, $parameterset, $table_bgcolor);
#
#   if ($candidate_orderlists eq "no_orderlist") {
#      $page .= p(b("no orderlist found"))
#               . hidden(-name=>"orderlist_id", -value=>"0");
#   }
#   else {
#      $page .= $candidate_orderlists;
#   }

# remark: skip asking for update or insert: just insert (HM, 20.11.2008)
#
#   $page .= h3("Insert or update?")
#            . p("What has to be done if data from this orderlist already exists?")
#            . p(radio_group(-name=>'insert_or_update', -values=>['insert', 'update'], -default=>3));

  $page .= hidden(-name=>"insert_or_update", -value=>"insert");

  ########################################
  if ($error_count == 0) {
     $page .= p()
              . hidden(-name=>"step",           -value=>"upload_step_2", -override=>1)
              . hidden(-name=>"first",          -value=>"1")
              . hidden('data_file')
              . hidden('local_filename')
              . hidden('parameterset')
              . hidden('orderlist_id')
              . hidden('sheet')
              . hidden(-name=>"transpose", -value=>$transpose_yn)
              . submit(-name=>"choice",         -value=>"upload!", -title=>"upload!")
              . "&nbsp;&nbsp;or&nbsp;&nbsp;"
              . a({-href=>"javascript:back()"}, "go back")
              . end_form();
  }
  else {
     $page .= end_form()
              . p({-class=>"red"}, "$error_count errors found, please go back and try to fix them. Move the mouse over an error cell to see reason for error.")
              . p(a({-href=>"javascript:back()"}, "go back"));
  }

  return $page;
}
# end of upload_step_2()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_UPL004 upload_step_3():                             upload phenotyping data (3. step: store in database)
sub upload_step_3 {                                      my $sr_name = 'SR_UPL004';
  my ($global_var_href) = @_;                                 # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};          # database handle
  my $session           = $global_var_href->{'session'};      # session handle
  my $user_id           = $session->param(-name=>'user_id');  # read username from session
  my $username          = $session->param(-name=>'username'); # read username from session
  my $parameterset      = param('parameterset');
  my $orderlist_id      = param('orderlist_id');
  my $sheet_number      = param('sheet');
  my $insert_or_update  = param('insert_or_update');
  my @status_code_list  = get_mr_status_codes_list($global_var_href);
  my $is_code_instead_value;
  my $filesize          = 0;                                  # counter for size of uploaded file
  my $url               = url();
  my $transpose_yn;
  my ($page, $i, $j, $sheet, $xls, $data, $field, $new_mr_id);
  my ($sql, $result, $rc, $rows, $row, $k, $sheet_counter);
  my ($upload_filename, $local_filename, $column_number, $current_mouse, $current_date, $checked, $converted_date);
  my ($cell_bgcolor, $td_align, $cell_comment, $current_value, $candidate_orderlists, $parameter, $selected_mouse);
  my ($insert_int, $insert_float, $insert_bool, $insert_text, $insert_status_code, $existing_medical_records, $new_mr_group_id, $status_code);
  my @sql_parameters;
  my ($dd, $mm, $yy, $hh, $min, $ss, $within_bounds);
  my @sheets;
  my @row_data;
  my @row_for_display;
  my %parameter_id_by_column;              # map Excel colum to parameter id
  my %parameter_shortname_by_id;           # map parameter id to parameter shortname
  my %parameter_name_by_id;                # map parameter id to parameter name
  my %parameter_id_by_name;                # map parameter name to parameter id
  my %parameter_type_by_id;                # map parameter id to parameter type
  my %parameter_unit_by_id;                # map parameter id to parameter unit
  my %parameter_upload_name_by_id;         # map parameter id to upload column name
  my %parameter_decimals_by_id;            # map parameter id to decimals
  my %parameter_required_by_column;
  my %parameter_is_serial_by_column;
  my %increment_value_by_column;
  my %increment_unit_by_column;
  my $mouse_id_column     = get_column_in_upload_file($global_var_href, 'mouse_id',     $parameterset);
  my $measure_date_column = get_column_in_upload_file($global_var_href, 'measure_date', $parameterset);
  my %sheetname_by_id;
  my $error_count           = 0;
  my $warning_count         = 0;
  my $table_bgcolor         = '#80FFFF';
  my $error_type_bgcolor    = '#FFC0C0';
  my $error_novalue_bgcolor = '#FFFFC0';
  my %public_labels         = ('y' => 'yes', 'n' => 'no');
  my $datetime_now          = get_current_datetime_for_sql();
  my @mice;
  my @selected_mice = param('mouse_select');
  my %mouse_chosen;
  my ($increment_value, $increment_unit);
  my @current_row;
  my @table;
  my $current_row_ref;
  my %existing_records;

  use Spreadsheet::ParseExcel::Simple;
  use Spreadsheet::ParseExcel;
  use Array::Transpose;

  $page .= h2("Upload phenotyping data: 3. step")
           . hr();

  $page .= h3("Trying to store data in database");

  # check parameterset: 1) a parameterset id must be given, 2) it has to be strictly numeric (prevent SQL injections)
  if (!defined(param('parameterset')) || param('parameterset') !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid parameterset id (must be a number)", $sr_name . "-" . __LINE__);
  }

  # check orderlist: 1) an orderlist id must be given, 2) it has to be strictly numeric (prevent SQL injections)
  if (!defined(param('orderlist_id')) || param('orderlist_id') !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid or missing orderlist id (must be a number)", $sr_name . "-" . __LINE__);
  }

  # check 'is_public' field: is it defined? is it either 'y' or 'n'?
  if (!defined(param('data_is_public')) || param('data_is_public') !~ /^[yn]{1}$/) {
     &error_message_and_exit($global_var_href, "please go back and choose if records are public or not", $sr_name . "-" . __LINE__);
  }

  # check 'insert_or_update' field: is it defined? is it either 'insert' or 'update'?
  if (!defined(param('insert_or_update')) || !(param('insert_or_update') eq 'insert' || param('insert_or_update') eq 'update')) {
     &error_message_and_exit($global_var_href, "please go back and choose if insert or update data in case of conflict", $sr_name . "-" . __LINE__);
  }

  # check if filename submitted
  if (!param("data_file") || param("data_file") eq '') {
     $page .= p({-class=>"red"}, b("Error: please specify an import file"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }
  # check if filename ends with "xls" (ok, this is not really sufficient to check if it is an excel file)
  elsif (param("data_file") !~ /xls$/) {
     $page .= p({-class=>"red"}, b("File needs to be an Excel file (ending with .xls)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check if table is to be transposed
  if (defined(param("transpose")) && param("transpose") eq 'y') {
     $transpose_yn = 'y';
  }
  else {
     $transpose_yn = 'n';
  }

  # check list of mouse ids for formally being MausDB ids
  foreach $selected_mouse (@selected_mice) {
     if ($selected_mouse =~ /^[0-9]{8}$/) {
        $mouse_chosen{$selected_mouse}++;
     }
  }

  ########################################
  # pull parameterset data from database in order to align parameters to upload columns

  $sql = qq(select parameterset_name, parameter_id, parameter_name, parameter_shortname, p2p_upload_column, parameter_decimals,
                   p2p_upload_column_name, parameter_type, parameter_unit,
                   p2p_parameter_category, p2p_increment_value, p2p_increment_unit
            from   parametersets2parameters
                   join parameters    on    parameter_id = p2p_parameter_id
                   join parametersets on parameterset_id = p2p_parameterset_id
            where  p2p_parameterset_id = ?
            order  by p2p_upload_column
           );

  @sql_parameters = ($parameterset);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and generate mapping tables
  for ($k=0; $k<$rows; $k++) {
      $row = $result->[$k];


      $parameter_id_by_column{$row->{'p2p_upload_column'}}        = $row->{'parameter_id'};
      $parameter_is_serial_by_column{$row->{'p2p_upload_column'}} = $row->{'p2p_parameter_category'};
      $increment_value_by_column{$row->{'p2p_upload_column'}}     = $row->{'p2p_increment_value'};
      $increment_unit_by_column{$row->{'p2p_upload_column'}}      = $row->{'p2p_increment_unit'};
      $parameter_required_by_column{$row->{'p2p_upload_column'}}  = $row->{'p2p_parameter_required'};
      $parameter_upload_name_by_id{$row->{'p2p_upload_column'}}   = $row->{'p2p_upload_column_name'};
      $parameter_name_by_id{$row->{'parameter_id'}}               = $row->{'parameter_name'};
      $parameter_type_by_id{$row->{'parameter_id'}}               = $row->{'parameter_type'};
      $parameter_unit_by_id{$row->{'parameter_id'}}               = $row->{'parameter_unit'};
      $parameter_decimals_by_id{$row->{'parameter_id'}}           = $row->{'parameter_decimals'};
      $parameter_shortname_by_id{$row->{'parameter_id'}}          = $row->{'parameter_shortname'};
      $parameter_id_by_name{$row->{'parameter_name'}}             = $row->{'parameter_id'};
  }

  ########################################
  # get upload_filename and local_filename from previous form
  $upload_filename = param('data_file');
  $local_filename  = param('local_filename');
  ##########################################

  # parse and display Excel file content. Use parameterset data stored in database

  # create Spreadsheet::ParseExcel::Simple excel object from uploaded file
  $xls = Spreadsheet::ParseExcel::Simple->read("./uploads/$local_filename");

  unless (defined($xls)) {
    $page .= h3("... could not open $upload_filename !");
    return $page;
  }

  # get all sheets from this object
  @sheets = $xls->sheets;

  for ($sheet_counter=0; $sheet_counter<=$#sheets; $sheet_counter++) {
      $sheetname_by_id{$sheet_counter} = $sheets[$sheet_counter]->sheet->{Name};
  }

  $page .= start_table( {-border=>'1', -summary=>"table", -bgcolor=>$table_bgcolor} );

  ##################################
  # first row: we need a header line
  while ($sheets[$sheet_number]->has_data) {                   # as long as there are lines with content ...
     @current_row = $sheets[$sheet_number]->next_row;          # ... fetch the next row
     push(@table, [@current_row]);                             # add row array to table array: @table is a 2D-array (we copy the Excel table to a 2D-array)
  }

  # transpose 2D table if requested
  if ($transpose_yn eq 'y') {
     @table = transpose(\@table);
  }

  # now loop over rows from 2D-array
  foreach $current_row_ref (@table) {
     @row_data = @{$current_row_ref};                          # ... fetch the next row
     @row_for_display = ();                                    # reset output row
     $i++;

     if ($i > 1) { last; }       # restrict to first row with column headers

     # add fixed columns to header
     push(@row_for_display, th('mouse_id'),
                            th('measure_date')
     );

     # add parameterset-specific columns to header row
     for ($field = 0; $field <=$#row_data; $field++) {
         if (defined($parameter_id_by_column{$field+1})) {
            # check if column header from uploaded Excel file equals the column header defined in the database
            # "do we get what we expect in column 13?"
            if ($parameter_upload_name_by_id{$field+1} eq $row_data[$field]) {
               push(@row_for_display, th($parameter_upload_name_by_id{$field+1}));
            }
            else {
               push(@row_for_display, th({-class=>"red"}, 'columne' . br() . 'mismatch'));
            }
         }
     }

     $page .= Tr(@row_for_display);
  }
  # end of header
  ##################################

  # reset
  $i = 0;
  @sheets = $xls->sheets;       # this is to reset the sheet object
  @table = ();

  # try to get a lock
  &get_semaphore_lock($global_var_href, $user_id);

  ############################################################################################
  # begin transaction
  $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start import transaction)", $sr_name . "-" . __LINE__);

  ##################################
  # now the data...
  while ($sheets[$sheet_number]->has_data) {                   # as long as there are lines with content ...
     @current_row = $sheets[$sheet_number]->next_row;          # ... fetch the next row
     push(@table, [@current_row]);                             # add row array to table array: @table is a 2D-array (we copy the Excel table to a 2D-array)
  }

  # transpose 2D table if requested
  if ($transpose_yn eq 'y') {
     @table = transpose(\@table);
  }

  #######################################
  # first check if there already is a medical record in the database from this orderlist and parameterset and increment for this mouse
  $sql = qq(select m2mr_mouse_id, mr_parameterset_id, mr_parameter, mr_increment_value
            from   medical_records
                   join mice2medical_records on m2mr_mr_id = mr_id
            where  mr_orderlist_id = ?
  );

  @sql_parameters = ($orderlist_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . '-' . __LINE__ );

  # loop over all records found (if any)
  for ($i=0; $i<$rows; $i++) {               # $rows is the number of racks returned from the above query
      $row = $result->[$i];                  # get a reference on the current rack

      $existing_records{$row->{'m2mr_mouse_id'}}{$row->{'mr_parameterset_id'}}{$row->{'mr_parameter'}}{$row->{'mr_increment_value'}}++;
  }

  #######################################

  # now loop over rows from 2D-array
  foreach $current_row_ref (@table) {
     @row_data = @{$current_row_ref};                          # ... fetch the next row
     @row_for_display = ();                                    # reset output row
     $i++;

     ############################
     # in order to be able to persistently group all data from the current row together, there is a group ID
     # example: multiple rows for same mouse and same parameters in one file. Rows represent repeated measurements or time series experiments
     # get next group id
     ($new_mr_group_id) = $dbh->selectrow_array("select coalesce((max(mr_parent_mr_group) + 1), 1) as new_group_id
                                                 from   medical_records
                                                ");

     # special case: set start group ID higher than the highest mr_id (we introduced the group ID when already having lots of medical records)
     if ($new_mr_group_id == 1) {
        ($new_mr_group_id) = $dbh->selectrow_array("select coalesce((max(mr_id) + 1), 1) as new_mr_id
                                                    from   medical_records
                                                   ");
     }
     # all medical records from the current row will have the same group ID
     ############################

     # skip first row = header row (we already used it above)
     if ($i == 1) { next; };

     ############################
     # get mouse id
     $current_mouse = $row_data[$mouse_id_column - 1];

     if (!defined($mouse_chosen{$current_mouse})) {
        next;
     }

     # skip row if not a valid mouse id
     if ($current_mouse !~ /^[0-9]{8}$/) {
        push(@row_for_display, td('no mouse id, line skipped'), td($current_mouse));
        $page .= Tr(@row_for_display);
        next;
     }
     ############################

#      ############################
#      # get date/time of sample taking / date of measurement (whichever is more relevant)
#      $current_date  = $row_data[$measure_date_column - 1];
#
#      # try to convert Excel-formatted date "22/05/06" into human-readable format "22.05.2006"
#      if ($current_date =~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2}$/) {
#         ($dd, $mm, $yy, $hh, $min, $ss) = split(/\/\s/, $current_date);
#         $converted_date = $dd . '.' . $mm . '.' . (2000 + $yy) . ' ' . $hh . ':' . $min . ':' . $ss;
#      }
#      # try to convert Excel-formatted date "05-22-06" into human-readable format "22.05.2006"
#      elsif ($current_date =~ /^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2}$/) {
#         ($mm, $dd, $yy, $hh, $min, $ss) = split(/-\s/, $current_date);
#         $converted_date = reformat_number($dd, 2) . '.' . reformat_number($mm, 2) . '.' . (2000 + $yy) . ' ' . $hh . ':' . $min . ':' . $ss;
#      }
#      # try to convert Excel-formatted date "05/22/2006 9:34:34 AM" into human-readable format "22.05.2006"
#      elsif ($current_date =~ /^[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}\s[0-9]{1,2}\:[0-9]{2}\:[0-9]{2}\s[A-Z]{2}$/) {
#         ($mm, $dd, $yy, $hh, $min, $ss) = split(/-\s/, $current_date);
#         $converted_date = reformat_number($dd, 2) . '.' . reformat_number($mm, 2) . '.' . $yy;
#      }
#      # try to convert Excel-formatted date "05/22/06 9:34" into human-readable format "22.05.2006"
#      elsif ($current_date =~ /^[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}\s[0-9]{1,2}\:[0-9]{2}$/) {
#         ($mm, $dd, $yy) = split(/\//, $current_date);
#         ($yy, undef) = split(/\s/, $yy);
#         $converted_date = reformat_number($dd, 2) . '.' . reformat_number($mm, 2) . '.' . $yy;
#      }
#      else {
#         $converted_date = $current_date;
#      }
#
#      # skip row if not a valid measure date
#      if ($converted_date !~ /^[0-9]{2}\.[0-9]{2}\.[0-9]{4}\s[0-9]{2}:[0-9]{2}:[0-9]{2}$/ || check_datetime_ddmmyyyy_hhmmss($converted_date) != 1) {
#         push(@row_for_display, td({-class=>'red'}, b('not a valid date, line skipped')), td($current_mouse), td($converted_date));
#         $page .= Tr(@row_for_display);
#         next;
#      }
#      ##################################


     ############################ as currently active on castor
     # get date of sample taking / date of measurement (whichever is more relevant)
     $current_date  = $row_data[$measure_date_column - 1];

     # try to convert Excel-formatted date "22/05/06" into human-readable format "22.05.2006"
     if ($current_date =~ /^[0-9]{2}\/[0-9]{2}\/[0-9]{2}$/) {
        ($dd, $mm, $yy) = split(/\//, $current_date);
        $converted_date = $dd . '.' . $mm . '.' . (2000 + $yy);
     }
     # try to convert Excel-formatted date "05-22-06" into human-readable format "22.05.2006"
     elsif ($current_date =~ /^[0-9]{1,2}-[0-9]{1,2}-[0-9]{2}$/) {
        ($mm, $dd, $yy) = split(/-/, $current_date);
        $converted_date = reformat_number($dd, 2) . '.' . reformat_number($mm, 2) . '.' . (2000 + $yy);
     }
     # try to convert Excel-formatted date "05/22/06 9:34:34 AM" into human-readable format "22.05.2006"
     elsif ($current_date =~ /^[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}\s[0-9]{1,2}\:[0-9]{2}\:[0-9]{2}\s[A-Z]{2}$/) {
        ($mm, $dd, $yy) = split(/\//, $current_date);
        ($yy, undef) = split(/\s/, $yy);
        $converted_date = reformat_number($dd, 2) . '.' . reformat_number($mm, 2) . '.' . $yy;
     }
     # try to convert Excel-formatted date "05/22/06 9:34" into human-readable format "22.05.2006"
     elsif ($current_date =~ /^[0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}\s[0-9]{1,2}\:[0-9]{2}$/) {
        ($mm, $dd, $yy) = split(/\//, $current_date);
        ($yy, undef) = split(/\s/, $yy);
        $converted_date = reformat_number($dd, 2) . '.' . reformat_number($mm, 2) . '.' . $yy;
     }
     else {
        $converted_date = $current_date;
     }
     ##################################

     push(@row_for_display, td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $current_mouse}, $current_mouse)));
     push(@row_for_display, td({-align=>"center"}, $converted_date));

     # loop over all columns of current row
     for ($field = 0; $field <=$#row_data; $field++) {

         # reset ...
         $cell_bgcolor       = $table_bgcolor;
         $td_align           = 'left';
         $cell_comment       = 'ok';
         $insert_status_code = 'ok';
         $current_value      = $row_data[$field];
         $error_count        = 0;

         undef $is_code_instead_value;
         undef $status_code;
         undef $is_code_instead_value;
         undef $status_code;
         undef $insert_int;
         undef $insert_float;
         undef $insert_bool;
         undef $insert_text;
         undef $increment_value;
         undef $increment_unit;

         # CHECK if a parameter is defined and expected for the current column, otherwise just ignore this column
         # yes, column defined (ie. value expected): process column
         if (defined($parameter_id_by_column{$field + 1})) {

            # CHECK if field content is not a value but a status code (from a defined list): get number of matches
            $is_code_instead_value = grep {$_ eq $current_value} @status_code_list;

            # yes, status code: display it, store it
            if ($is_code_instead_value > 0) {
                $cell_bgcolor       = $error_novalue_bgcolor;
                $status_code        = $current_value;
                $cell_comment       = "no value, status code: $status_code";
                $current_value      = '[' . $current_value . ']';
                $insert_status_code = $status_code;

                # CHECK if we have a serial parameter. If yes, write serial increment to medical record
                if ($parameter_is_serial_by_column{$field + 1} eq 'series') {
                   $increment_value = $increment_value_by_column{$field + 1};
                   $increment_unit  = $increment_unit_by_column{$field + 1};
                }
            }

            # no status code, proceed normally
            else {

                # CHECK if empty or undefined cell
                # yes, empty or undefined
                if (!defined($row_data[$field]) || $row_data[$field] eq '') {

                   # CHECK: is value required?
                   # yes, it is required: error message, do not store
                   if ($parameter_required_by_column{$field + 1} eq 'y') {
                      # error message
                      $cell_bgcolor = $error_type_bgcolor;
                      $cell_comment = "values required but missing: please provide value or status code!";
                   }

                   # no, not required: message, do not store
                   else {
                      # skip silently
                      $cell_bgcolor = $error_novalue_bgcolor;
                      $cell_comment = "ok (missing, but not required)";
                   }

                   $current_value = '[missing]';
                   $error_count++;
                }

                # no, there is something in it: proceed normally
                else {
                    # CHECK type: float
                    if ($parameter_type_by_id{$parameter_id_by_column{$field + 1}} eq 'f') {
                        $td_align = 'right';

                        # we have not the expected float, but something different, display message, do not store
                        if ($current_value !~ /^[\-]{0,1}[0-9\.]+$/) {
                           $cell_bgcolor  = $error_type_bgcolor;
                           $cell_comment  = '[type error: not a float number]';
                           $error_count++;
                        }
                        # we have a float: round to number of decimals defined in parameter definition and store
                        else {
                           # round floating number according to decimals defined in the database
                           $insert_float  = round_number($current_value, $parameter_decimals_by_id{$parameter_id_by_column{$field + 1}});
                           $cell_comment  = 'ok';
                        }
                    }

                    # CHECK type: integer
                    if ($parameter_type_by_id{$parameter_id_by_column{$field + 1}} eq 'i') {
                       $td_align = 'right';

                       # we have not the expected int, but something different, display message, do not store
                       if ($current_value !~ /^[\-]{0,1}[0-9]+$/ && $current_value ne '-') {
                          $cell_bgcolor  = $error_type_bgcolor;
                          $cell_comment  = '[type error: not an integer number]';
                          $error_count++;
                       }
                       # we have an int: all fine, store
                       else {
                          $insert_int   = $current_value;
                          $cell_comment = 'ok';
                       }
                    }

                    # CHECK type: bool
                    if ($parameter_type_by_id{$parameter_id_by_column{$field + 1}} eq 'b') {
                       $td_align = 'right';

                       # we have not the expected bool, but something different, display message, do not store
                       if ($current_value !~ /^[01yn]{1}$/ && $current_value ne '-') {
                          $cell_bgcolor  = $error_type_bgcolor;
                          $cell_comment  = '[type error: not a bool value]';
                          $error_count++;
                       }
                       # we have a bool: store it
                       else {
                          $insert_bool  = $current_value;
                          $cell_comment = 'ok';
                       }
                    }

                    # CHECK type: text
                    if ($parameter_type_by_id{$parameter_id_by_column{$field + 1}} eq 'c') {
                       $td_align = 'left';

                       # store text unless it is a status code (see above)
                       $insert_text   = $current_value;
                       $cell_comment  = 'ok';
                    }

                    # CHECK type: date
                    if ($parameter_type_by_id{$parameter_id_by_column{$field + 1}} eq 'd') {
                       $td_align = 'left';

                       # store text unless it is a status code (see above)
                       $insert_text   = $current_value;
                       $cell_comment  = 'ok';
                    }

                    # CHECK type: datetime
                    if ($parameter_type_by_id{$parameter_id_by_column{$field + 1}} eq 't') {
                       $td_align = 'left';

                       # store text unless it is a status code (see above)
                       $insert_text   = $current_value;
                       $cell_comment  = 'ok';
                    }

                    # CHECK if we have a serial parameter. If yes, write serial increment to medical record
                    if ($parameter_is_serial_by_column{$field + 1} eq 'series') {
                       $increment_value = $increment_value_by_column{$field + 1};
                       $increment_unit  = $increment_unit_by_column{$field + 1};
                    }
                }
            }

            # CHECK bounds: is value within bounds that are defined for this parameter?
            # TODO: activate this validation
            $within_bounds = is_value_within_bounds($global_var_href, $current_value, $parameter_id_by_column{$field + 1});

            # value failed bound check
            if ($within_bounds ne 'y') {
               $cell_bgcolor  = $error_type_bgcolor;
               $cell_comment  = '[value not within bounds]';
               $error_count++;
            }

            # no errors, all fine, let's store it
            if ($error_count == 0) {
               # do transaction
               ###################################

               # first check if there already is a medical record in the database from this orderlist and parameterset and increment for this mouse
               $existing_medical_records = $existing_records{$current_mouse}{$parameterset}{$parameter_id_by_column{$field + 1}}{$increment_value_by_column{$field + 1}};

               # undefined means 0 in this context
               unless (defined($existing_medical_records)) {
                  $existing_medical_records = 0;
               }

               #######################################################################
               # THIS CASE IS INACTIVATED BY FIXED SELECTION "INSERT" ON PREVIOUS FORM
               # yes, there are and user chose 'update': update
               if ($existing_medical_records > 0 && $insert_or_update eq 'update') {

                  # get highest mr_id (in case there are more than one) to update
                  $sql = qq(select max(mr_id)
                                   from medical_records
                                   join mice2medical_records on m2mr_mr_id = mr_id
                            where           m2mr_mouse_id = ?
                                   and    mr_orderlist_id = ?
                                   and mr_parameterset_id = ?
                                   and       mr_parameter = ?
                                   and mr_increment_value = ?
                         );

                  @sql_parameters = ($current_mouse, $orderlist_id, $parameterset, $parameter_id_by_column{$field + 1}, $increment_value_by_column{$field + 1});

                  ($new_mr_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

                  # update table medical_records
                  $sql = qq(update medical_records
                            set    mr_is_dependent = ?, mr_project_id = ?, mr_orderlist_id = ?, mr_parameterset_id = ?, mr_parameter = ?,
                                   mr_integer = ?, mr_float = ?, mr_bool = ?, mr_text = ?, mr_responsible_user = ?, mr_measure_user = ?,
                                   mr_is_public = ?, mr_measure_datetime = ?, mr_comment = ?
                            where  mr_id = ?
                           );

                  $dbh->do($sql, undef,
                           'n', param('all_projects'), $orderlist_id, $parameterset, $parameter_id_by_column{$field + 1},
                           $insert_int, $insert_float, $insert_bool, $insert_text, param('responsible_user'), param('measure_user'), param('data_is_public'),
                           format_display_datetime2sql_datetime($converted_date . ' 07:00:00'), $insert_status_code, $new_mr_id
                          ) or &error_message_and_exit($global_var_href, "SQL error (could not update medical record)", $sr_name . "-" . __LINE__);

               }
               # END OF INACTIVATED CASE
               #######################################################################

               # there are no conflicting records or user chose 'insert': insert
               else {
                  # get next medical record id
                  ($new_mr_id) = $dbh->selectrow_array("select coalesce((max(mr_id) + 1), 1) as new_mr_id
                                                        from   medical_records
                                                       ");
                  # insert into medical_records
                  $sql = qq(insert
                            into   medical_records (mr_id, mr_parent_mr_group, mr_is_dependent, mr_project_id, mr_orderlist_id, mr_parameterset_id, mr_parameter,
                                                    mr_integer, mr_float, mr_bool, mr_text, mr_responsible_user, mr_measure_user, mr_is_public,
                                                    mr_measure_datetime, mr_comment, mr_increment_value, mr_increment_unit
                                                   )
                            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                           );

                  $dbh->do($sql, undef,
                           $new_mr_id, $new_mr_group_id, 'n', param('all_projects'), $orderlist_id, $parameterset, $parameter_id_by_column{$field + 1},
                           $insert_int, $insert_float, $insert_bool, $insert_text, param('responsible_user'), param('measure_user'), param('data_is_public'),
                           format_display_datetime2sql_datetime($converted_date . ' 07:00:00'), $insert_status_code, $increment_value, $increment_unit
                        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert medical record)", $sr_name . "-" . __LINE__);


                  # insert into mice2medical_records
                  $sql = qq(insert
                            into   mice2medical_records (m2mr_mouse_id, m2mr_mr_id, m2mr_mouse_role)
                            values (?, ?, ?)
                           );

                  $dbh->do($sql, undef,
                           $current_mouse, $new_mr_id, 'role'
                          ) or &error_message_and_exit($global_var_href, "SQL error (could not assign mouse to medical record)", $sr_name . "-" . __LINE__);
               }

               ###################################

               push(@row_for_display, td({-bgcolor=>$cell_bgcolor, -align=>$td_align, -title=>$cell_comment, -style=>'color: #808080;'},
                                         a({-href=>"$url?choice=phenotype_record_details&phenotype_record_id=$new_mr_id"}, $current_value)
                                      )
               );
            }

            # there were errors: display error message
            else {
               push(@row_for_display, td({-bgcolor=>$cell_bgcolor, -align=>$td_align, -title=>$cell_comment, -style=>'color: #808080;'}, $current_value));
            }
         }

         # no, column not defined, no value expected: skip it
         else {
            # silently skip line, do nothing
         }
     }

     # add the row to the table
     $page .= Tr(@row_for_display);
  }
  # end of data
  ##################################

  $page .= end_table();

  # commit
  $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

  # end transaction
  ############################################################################################

  # release lock
  &release_semaphore_lock($global_var_href, $user_id);

  # log upload
  &write_textlog($global_var_href, "$datetime_now\t$user_id\t$username\tupload_records_for_orderlist\t$orderlist_id");

  $page .= hr({-align=>'left', -width=>'50%'})
           . h3("Additional data used:")

           . table({-border=>1, -bgcolor=>$table_bgcolor},
                  Tr( td(b("project, to which data belongs")),
                      td({-align=>'center', -style=>'color: #808080;'}, get_project_name_by_id($global_var_href, param('all_projects'))),       # variable name. "all_projects"
                      td(b("is data public?")),
                      td({-style=>'color: #808080;'}, ((param('data_is_public') eq 'y')?'yes':'no'))
                  )
                . Tr( td(b("user (responsible)")),
                      td({-colspan=>3, -style=>'color: #808080;'}, get_user_name_by_id($global_var_href, param('responsible_user')))
                  )
                . Tr( td(b("user (measured)")),
                      td({-colspan=>3, -style=>'color: #808080;'}, get_user_name_by_id($global_var_href, param('measure_user')))
                  )
             );

  $page .= p()
           . p('All done! Data successfully uploaded!');

  return $page;
}
# end of upload_step_3()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_UPL005 upload_blob_step_1():                        upload blob (1. step: initial form)
sub upload_blob_step_1 {                                 my $sr_name = 'SR_UPL005';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $parameterset      = param('parameterset');
  my $session           = $global_var_href->{'session'};
  my $user_id           = $session->param(-name=>'user_id');
  my ($page, $mouse);
  my @selected_mice;
  my @mice_to_link;
  my %radio_labels      = ('experiment'     => '',
                           'control'        => '',
                           'representative' => '',
                           'y'              => '',
                           'n'              => '');

  $page = h2("Upload and link file to mice: 1. step")
          . hr();

  # first table
  $page .= h3("In order to upload a file to the database, some information is needed")

           . start_form(-action=>url(), -name=>"myform", -enctype=>"multipart/form-data")

           . h3("1) File to be uploaded")

           . table( {-border=>0, -summary=>"table"},
                  Tr(
                    td({-colspan=>2},   filefield(-name=>'data_file', -default=>'', -size=>80, -maxlength=>80,
                                                  -onclick=>"document.myform.import_mode[0].checked=true")
                    )
                  )
             );

  $page .= h3("2) Please specify the file type")

          . table({-border=>1},
               Tr(td(radio_group(-name=>'file_type', -values=>['Excel'], -default=>'none', -override=>1)),
                  td("files that can be opened by Microsoft Excel or OpenOffice.org (xls, csv, gpr)")
               ) .
               Tr(td(radio_group(-name=>'file_type', -values=>['Word'],  -default=>'none', -override=>1)),
                  td("files that can be opened by Microsoft Word or OpenOffice.org (doc)")
               ) .
               Tr(td(radio_group(-name=>'file_type', -values=>['jpeg'],  -default=>'none', -override=>1)),
                  td("jpeg image files")
               ) .
               Tr(td(radio_group(-name=>'file_type', -values=>['pdf'],   -default=>'none', -override=>1)),
                  td("Adobe PDF file")
               )
            );

  $page .= h3("3) Please specify the role of every mouse");

  # read list of selected mice from CGI form
  @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_link, $mouse);
     }
  }

  if (!(scalar @mice_to_link > 0)) {
     $page .= p("No mice selected. Please " . a({-href=>"javascript:back()"}, "go back") . " and select which mice are to be linked to the uploaded file.");

     return $page;
  }
  else {
     $page .= start_table({-border=>1})
              . Tr(th({-rowspan=>2, -valign=>'bottom'}, 'mouse ID'),
                   th({-colspan=>3}, 'role')
                )
              . Tr(th('experiment'),
                   th('control'),
                   th('representative')
                );

     foreach $mouse (@mice_to_link) {
        $page .= Tr(td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse}, $mouse)),
                    td({-align=>'center'}, radio_group(-name=>'mouse_role_' . $mouse, -values=>['experiment'],     -default=>'none', -labels=>\%radio_labels, -override=>1)),
                    td({-align=>'center'}, radio_group(-name=>'mouse_role_' . $mouse, -values=>['control'],        -default=>'none', -labels=>\%radio_labels, -override=>1)),
                    td({-align=>'center'}, radio_group(-name=>'mouse_role_' . $mouse, -values=>['representative'], -default=>'none', -labels=>\%radio_labels, -override=>1))
                   )
     }

     $page .= end_table();
  }

  $page .= h3("4) Please add an appropriate description or metadata (will be stored together with the uploaded file)")

           . textarea(-name=>"blob_comment", -columns=>"80", -rows=>"10");

  $page .= h3("5) Please specify if file is public or not")

          . table({-border=>1},
               Tr(td({-align=>'right'}, b('public ')    . radio_group(-name=>'is_public', -values=>['y'],  -default=>'-', -labels=>\%radio_labels, -override=>1)),
                  td(" File can be downloaded by any user")
               ) .
               Tr(td({-align=>'right'}, b('not public') . radio_group(-name=>'is_public', -values=>['n'],  -default=>'-', -labels=>\%radio_labels, -override=>1)),
                  td(" File can be downloaded only by users who share projects with you")
               )
            );
  $page .= p()
           . hidden(-name=>"step",   -value=>"upload_blob_step_1", -override=>1)
           . hidden(-name=>"first",  -value=>"1")
           . hidden('orderlist_id')
           . hidden('parameterset')
           . hidden('mouse_select')
           . hr()
           . p(submit(-name=>"choice", -value=>"next step", -title=>"next step")
               . "&nbsp;&nbsp;or&nbsp;&nbsp;"
               . a({-href=>"javascript:back()"}, "go back")
             )
           . end_form();

  return $page;
}
# end of upload_blob_step_1
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_UPL006 upload_blob_step_2():                         upload blob (2. step: store in database)
sub upload_blob_step_2 {                                  my $sr_name = 'SR_UPL006';
  my ($global_var_href) = @_;                                  # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};           # database handle
  my $session           = $global_var_href->{'session'};       # session handle
  my $blob_database     = $global_var_href->{'blob_database'}; # name of the blob_database
  my $user_id           = $session->param(-name=>'user_id');   # read username from session
  my $username          = $session->param(-name=>'username');  # read username from session
  my $upload_filename   = param('data_file');
  my $file_type         = param('file_type');
  my $blob_comment      = param('blob_comment');
  my $blob_is_public    = param('is_public');
  my $filesize          = 0;                                  # counter for size of uploaded file
  my $url               = url();
  my ($page, $sth, $i, $j, $sheet, $xls, $data, $field, $new_mr_id);
  my ($sql, $result, $rc, $rows, $row);
  my ($local_filename, $current_mouse, $selected_mouse, $filehandle, $file_content, $file_mime_type, $insert_id, $mouse_role);
  my @sql_parameters;
  my ($dd, $mm, $yy);
  my @mice;
  my @selected_mice = param('mouse_select');
  my %mouse_chosen;
  my $datetime_now = get_current_datetime_for_sql();
  my %filetype_hash = ('Excel' => 'application/vnd.ms-excel', 'jpeg' => 'image/jpeg', 'pdf' => 'application/pdf', 'Word' => 'application/vnd.ms-word');

  $page .= h2("Upload and link file to mice: 2. step")
           . hr();

  $page .= h3("Trying to upload file");

  # check if filename submitted
  if (!param("data_file") || param("data_file") eq '') {
     $page .= p({-class=>"red"}, b("Error: please specify a file"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check if file type submitted
  if (!param("file_type") || param("file_type") eq '') {
     $page .= p({-class=>"red"}, b("Error: please specify a file type"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check if file is_public submitted
  if (!param("is_public") || param("is_public") eq '') {
     $page .= p({-class=>"red"}, b("Error: please specify if file is public or not"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  $file_mime_type = $filetype_hash{$file_type};

  # check list of mouse ids for formally being MausDB ids
  foreach $selected_mouse (@selected_mice) {
     if ($selected_mouse =~ /^[0-9]{8}$/) {
        $mouse_chosen{$selected_mouse}++;
     }
  }

  ########################################
  # upload the Excel file to a local directory

  # assign a local filename (composed from user name and Unix timestamp)
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

  # file has been uploaded to the server now
  # write upload_log ...
  &write_upload_log($dbh, $session->param(-name=>'user_id'), $session->param(-name=>'username'), $dbh->quote($upload_filename), $local_filename);

  ##########################################

  ########################################################################################
  # NO TRANSACTION, BECAUSE blob table is MYISAM                                         #
  ########################################################################################
  # read file, and store it (in compressed form) into blob
  $sth = $dbh->prepare(qq(INSERT
                          INTO   $blob_database.blob_data (blob_id, blob_name, blob_content_type,
                                 blob_mime_type, blob_itself, blob_upload_datetime, blob_comment,
                                 blob_upload_user, blob_is_public)
                          VALUES (NULL, ?, ?, ?, COMPRESS(?), ?, ?, ?, ?)
                       )
               );

  open($filehandle, "< ./uploads/$local_filename") or &error_message_and_exit($global_var_href, "Error processing file $!", $sr_name . "-" . __LINE__);
  read($filehandle, $file_content, -s $filehandle);

  $sth->execute($upload_filename, $file_type, $file_mime_type, $file_content, $datetime_now, $blob_comment, $user_id, $blob_is_public) or &error_message_and_exit($global_var_href, "Error saving file $!", $sr_name . "-" . __LINE__);

  # get insert id
  $sql = qq(select blob_id
            from   $blob_database.blob_data
            where  blob_name = ?
                   and blob_upload_datetime = ?
         );

  @sql_parameters = ($upload_filename, $datetime_now);

  # get id of inserted blob
  ($insert_id) = @{&do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, __LINE__)};

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $username . "\tinsert_blob\t$insert_id\t$upload_filename");
  ########################################################################################
  # NO TRANSACTION, BECAUSE blob table is MYISAM                                         #
  ########################################################################################

  ########################################################################################
  # try to get a lock
  &get_semaphore_lock($global_var_href, $user_id);
  ########################################################################################
  # begin transaction
  $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start transaction)", $sr_name . "-" . __LINE__);

  foreach $current_mouse (keys %mouse_chosen) {

     # insert mouse
     $sql = qq(insert
               into   mice2blob_data (m2b_mouse_id, m2b_blob_id, m2b_mouse_role)
               values (?, ?, ?)
            );

     if (defined(param('mouse_role_' . $current_mouse))) { $mouse_role = param('mouse_role_' . $current_mouse); }
     else                                                { $mouse_role = 'unknown';                             }

     $dbh->do($sql, undef,
              $current_mouse, $insert_id, $mouse_role
           ) or &error_message_and_exit($global_var_href, "could not link mouse $current_mouse to blob $insert_id ", '');

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $username . "\tlink_mouse_to_blob\t$current_mouse\t$insert_id\t$mouse_role");
  }

  # mating generated, so commit
  $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################################################
  # release lock
  &release_semaphore_lock($global_var_href, $user_id);
  ########################################################################################

  $page .= p()
           . p('All done! File successfully uploaded! Click ' . a({-href=>"$url?choice=download_file&file=" . $insert_id}, " here ") . ' to test downloading file from database.');

  return $page;
}
# end of upload_blob_step_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_UPL007 upload_line_blob_step_1():                   upload line blob (1. step: initial form)
sub upload_line_blob_step_1 {                            my $sr_name = 'SR_UPL007';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $line_id           = param('line_id');
  my $session           = $global_var_href->{'session'};
  my $user_id           = $session->param(-name=>'user_id');
  my ($page);
  my %radio_labels      = ('y' => '', 'n' => '');

  $page = h2("Upload and link file to line: 1. step")
          . hr();

  # first table
  $page .= h3("In order to upload a file to the database, some information is needed")

           . start_form(-action=>url(), -name=>"myform", -enctype=>"multipart/form-data")

           . h3("1) File to be uploaded")

           . table( {-border=>0, -summary=>"table"},
                  Tr(
                    td({-colspan=>2},   filefield(-name=>'data_file', -default=>'', -size=>80, -maxlength=>80,
                                                  -onclick=>"document.myform.import_mode[0].checked=true")
                    )
                  )
             );

  $page .= h3("2) Please specify the file type")

          . table({-border=>1},
               Tr(td(radio_group(-name=>'file_type', -values=>['Excel'], -default=>'none', -override=>1)),
                  td("files that can be opened by Microsoft Excel or OpenOffice.org (xls, csv, gpr)")
               ) .
               Tr(td(radio_group(-name=>'file_type', -values=>['Word'],  -default=>'none', -override=>1)),
                  td("files that can be opened by Microsoft Word or OpenOffice.org (doc)")
               ) .
               Tr(td(radio_group(-name=>'file_type', -values=>['jpeg'],  -default=>'none', -override=>1)),
                  td("jpeg image files")
               ) .
               Tr(td(radio_group(-name=>'file_type', -values=>['pdf'],   -default=>'none', -override=>1)),
                  td("Adobe PDF file")
               )
            );


  $page .= h3("3) Please add an appropriate description or metadata (will be stored together with the uploaded file)")

           . textarea(-name=>"blob_comment", -columns=>"80", -rows=>"10");

  $page .= h3("4) Please specify if file is public or not")

          . table({-border=>1},
               Tr(td({-align=>'right'}, b('public ')    . radio_group(-name=>'is_public', -values=>['y'],  -default=>'-', -labels=>\%radio_labels, -override=>1)),
                  td(" File can be downloaded by any user")
               ) .
               Tr(td({-align=>'right'}, b('not public') . radio_group(-name=>'is_public', -values=>['n'],  -default=>'-', -labels=>\%radio_labels, -override=>1)),
                  td(" File can be downloaded only by users who share projects with you")
               )
            );

  $page .= p()
           . hidden(-name=>"step",   -value=>"upload_line_blob_step_1", -override=>1)
           . hidden(-name=>"first",  -value=>"1")
           . hidden('line_id')
           . hr()
           . p(submit(-name=>"choice", -value=>"attach file to line!", -title=>"next step")
               . "&nbsp;&nbsp;or&nbsp;&nbsp;"
               . a({-href=>"javascript:back()"}, "go back")
             )
           . end_form();

  return $page;
}
# end of upload_line_blob_step_1
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_UPL008 upload_line_blob_step_2():                    upload line blob (2. step: store in database)
sub upload_line_blob_step_2 {                             my $sr_name = 'SR_UPL008';
  my ($global_var_href) = @_;                                  # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};           # database handle
  my $session           = $global_var_href->{'session'};       # session handle
  my $blob_database     = $global_var_href->{'blob_database'}; # name of the blob_database
  my $user_id           = $session->param(-name=>'user_id');   # read username from session
  my $username          = $session->param(-name=>'username');  # read username from session
  my $line_id           = param('line_id');
  my $upload_filename   = param('data_file');
  my $file_type         = param('file_type');
  my $blob_comment      = param('blob_comment');
  my $blob_is_public    = param('is_public');
  my $filesize          = 0;                                  # counter for size of uploaded file
  my $url               = url();
  my ($page, $sth, $i, $j);
  my ($sql, $result, $rc, $rows, $row);
  my ($local_filename, $filehandle, $file_content, $file_mime_type, $insert_id, $data);
  my @sql_parameters;
  my ($dd, $mm, $yy);
  my $datetime_now = get_current_datetime_for_sql();
  my %filetype_hash = ('Excel' => 'application/vnd.ms-excel', 'jpeg' => 'image/jpeg', 'pdf' => 'application/pdf', 'Word' => 'application/vnd.ms-word');

  $page .= h2("Upload and link file to mouse line: 2. step")
           . hr();

  $page .= h3("Trying to upload file");

  # check input: is line id given? is it a number?
  if (!param('line_id') || param('line_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid line id"));
     return $page;
  }

  # check if filename submitted
  if (!param("data_file") || param("data_file") eq '') {
     $page .= p({-class=>"red"}, b("Error: please specify a file"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check if file type submitted
  if (!param("file_type") || param("file_type") eq '') {
     $page .= p({-class=>"red"}, b("Error: please specify a file type"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check if file is_public submitted
  if (!param("is_public") || param("is_public") eq '') {
     $page .= p({-class=>"red"}, b("Error: please specify if file is public or not"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  $file_mime_type = $filetype_hash{$file_type};


  ########################################
  # upload the file to a local directory

  # assign a local filename (composed from user name and Unix timestamp)
  $local_filename = $username . '_' . time();

  # open write handle for uploaded file on server
  open(DAT, "> ./uploads/$local_filename") or &error_message_and_exit($global_var_href, "Error processing file $!", $sr_name . "-" . __LINE__);

  binmode $upload_filename;                                               # switch to binary mode
  binmode DAT;                                                            # switch to binary mode

  while(read $upload_filename, $data, 1024) {                             # actually write uploaded file on server
      print DAT $data;
      $filesize += length($data);
  }

  close DAT;                                                              # close write handle

  # file has been uploaded to the server now
  # write upload_log ...
  &write_upload_log($dbh, $session->param(-name=>'user_id'), $session->param(-name=>'username'), $dbh->quote($upload_filename), $local_filename);

  ##########################################

  ########################################################################################
  # NO TRANSACTION, BECAUSE blob table is MYISAM                                         #
  ########################################################################################
  # read file, and store it (in compressed form) into blob
  $sth = $dbh->prepare(qq(INSERT
                          INTO   $blob_database.blob_data (blob_id, blob_name, blob_content_type,
                                 blob_mime_type, blob_itself, blob_upload_datetime, blob_comment,
                                 blob_upload_user, blob_is_public)
                          VALUES (NULL, ?, ?, ?, COMPRESS(?), ?, ?, ?, ?)
                       )
               );

  open($filehandle, "< ./uploads/$local_filename") or &error_message_and_exit($global_var_href, "Error processing file $!", $sr_name . "-" . __LINE__);
  read($filehandle, $file_content, -s $filehandle);

  $sth->execute($upload_filename, $file_type, $file_mime_type, $file_content, $datetime_now, $blob_comment, $user_id, $blob_is_public) or &error_message_and_exit($global_var_href, "Error saving file $!", $sr_name . "-" . __LINE__);

  # get insert id
  $sql = qq(select blob_id
            from   $blob_database.blob_data
            where  blob_name = ?
                   and blob_upload_datetime = ?
         );

  @sql_parameters = ($upload_filename, $datetime_now);

  # get id of inserted blob
  ($insert_id) = @{&do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, __LINE__)};

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $username . "\tinsert_blob\t$insert_id\t$upload_filename");
  ########################################################################################
  # NO TRANSACTION, BECAUSE blob table is MYISAM                                         #
  ########################################################################################

  ########################################################################################
  # try to get a lock
  &get_semaphore_lock($global_var_href, $user_id);
  ########################################################################################
  # begin transaction
  $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start transaction)", $sr_name . "-" . __LINE__);

  # link uploaded file to line
  $sql = qq(insert
            into   line2blob_data (l2b_line_id, l2b_blob_id)
            values (?, ?)
           );

  $dbh->do($sql, undef,
           $line_id, $insert_id
        ) or &error_message_and_exit($global_var_href, "could not link line $line_id to blob $insert_id ", '');

  # commit
  $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################################################
  # release lock
  &release_semaphore_lock($global_var_href, $user_id);
  ########################################################################################


  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $username . "\tlink_blob_to_line\t$line_id\t$insert_id");

  $page .= p()
           . p('All done! File successfully uploaded! Click ' . a({-href=>"$url?choice=download_file&file=" . $insert_id}, " here ") . ' to test downloading file from database.');

  return $page;
}
# end of upload_line_blob_step_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_UPL009 upload_multi_blob_for_mouse_step_1():        upload multiple blobs for a mouse (1. step: initial form)
sub upload_multi_blob_for_mouse_step_1 {                 my $sr_name = 'SR_UPL009';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $session           = $global_var_href->{'session'};
  my $user_id           = $session->param(-name=>'user_id');
  my $mouse_id          = param('mouse_id');
  my ($page);

  $page = h2("Upload and link file(s) to mouse $mouse_id: 1. step")
          . hr();

  # first table
  $page .= h3("In order to upload file(s) to the database, some information is needed")

           . start_form(-action=>url(), -name=>"myform", -enctype=>"multipart/form-data")

           . h3("1) File(s) to be uploaded")

           . table( {-border=>0, -summary=>"table"},
                  Tr(th('1. file'),
                     td({-colspan=>2}, filefield(-name=>'data_file', -default=>'', -size=>80, -maxlength=>200))
                  ) .
                  Tr(th('2. file'),
                     td({-colspan=>2}, filefield(-name=>'data_file', -default=>'', -size=>80, -maxlength=>200))
                  ) .
                  Tr(th('3. file'),
                     td({-colspan=>2}, filefield(-name=>'data_file', -default=>'', -size=>80, -maxlength=>200))
                  ) .
                  Tr(th('4. file'),
                     td({-colspan=>2}, filefield(-name=>'data_file', -default=>'', -size=>80, -maxlength=>200))
                  ) .
                  Tr(th('5. file'),
                     td({-colspan=>2}, filefield(-name=>'data_file', -default=>'', -size=>80, -maxlength=>200))
                  )
             );

  $page .= h3("2) Please specify the file type (applies to all file(s) specified above)")

          . table({-border=>1},
               Tr(td(radio_group(-name=>'file_type', -values=>['Excel'], -default=>'none', -override=>1)),
                  td("files that can be opened by Microsoft Excel or OpenOffice.org (xls, csv, gpr)")
               ) .
               Tr(td(radio_group(-name=>'file_type', -values=>['Word'],  -default=>'none', -override=>1)),
                  td("files that can be opened by Microsoft Word or OpenOffice.org (doc)")
               ) .
               Tr(td(radio_group(-name=>'file_type', -values=>['jpeg'],  -default=>'none', -override=>1)),
                  td("jpeg image files")
               ) .
               Tr(td(radio_group(-name=>'file_type', -values=>['pdf'],   -default=>'none', -override=>1)),
                  td("Adobe PDF file")
               )
            );

  $page .= h3("3) Please add an appropriate description or metadata (will be stored with file(s) specified above)")

           . textarea(-name=>"blob_comment", -columns=>"80", -rows=>"10");

  $page .= h3("5) Please specify if file(s) is/are public or not (applies to all file(s) specified above)")

          . table({-border=>1},
               Tr(td({-align=>'right'}, b('public ')    . radio_group(-name=>'is_public', -values=>['y'],  -default=>'-', -override=>1)),
                  td(" File can be downloaded by any user")
               ) .
               Tr(td({-align=>'right'}, b('not public') . radio_group(-name=>'is_public', -values=>['n'],  -default=>'-', -override=>1)),
                  td(" File can be downloaded only by users who share projects with you")
               )
            );
  $page .= p()
           . hidden(-name=>"step",   -value=>"upload_blobs_step_1", -override=>1)
           . hidden(-name=>"first",  -value=>"1")
           . hidden('mouse_id')
           . hr()
           . p(submit(-name=>"choice", -value=>"next step", -title=>"next step")
               . "&nbsp;&nbsp;or&nbsp;&nbsp;"
               . a({-href=>"javascript:back()"}, "go back")
             )
           . end_form();

  return $page;
}
# end of upload_multi_blob_for_mouse_step_1
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_UPL010 upload_multi_blob_for_mouse_step_2():        upload multiple blobs for a mouse (2. step: store in database)
sub upload_multi_blob_for_mouse_step_2 {                 my $sr_name = 'SR_UPL010';
  my ($global_var_href) = @_;                                  # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};           # database handle
  my $session           = $global_var_href->{'session'};       # session handle
  my $blob_database     = $global_var_href->{'blob_database'}; # name of the blob_database
  my $user_id           = $session->param(-name=>'user_id');   # read username from session
  my $username          = $session->param(-name=>'username');  # read username from session
  my @upload_filenames  = param('data_file');
  my $file_type         = param('file_type');
  my $blob_comment      = param('blob_comment');
  my $blob_is_public    = param('is_public');
  my $mouse_id          = param('mouse_id');
  my $filesize          = 0;                                  # counter for size of uploaded file
  my $url               = url();
  my $upload_filename;
  my ($page, $sth, $i, $j, $sheet, $xls, $data, $field, $new_mr_id);
  my ($sql, $result, $rc, $rows, $row);
  my ($local_filename, $filehandle, $file_content, $file_mime_type, $insert_id);
  my @sql_parameters;
  my ($dd, $mm, $yy);
  my $datetime_now = get_current_datetime_for_sql();
  my %filetype_hash = ('Excel' => 'application/vnd.ms-excel', 'jpeg' => 'image/jpeg', 'pdf' => 'application/pdf', 'Word' => 'application/vnd.ms-word');

  $page .= h2("Upload and link file(s) to mouse $mouse_id: 2. step")
           . hr();

  $page .= h3("Trying to upload file(s)");

  # check if filename submitted
  if (scalar @upload_filenames == 0) {
     $page .= p({-class=>"red"}, b("Error: please specify at least one file"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check if file type submitted
  if (!param("file_type") || param("file_type") eq '') {
     $page .= p({-class=>"red"}, b("Error: please specify a file type"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check if file is_public submitted
  if (!param("is_public") || param("is_public") eq '') {
     $page .= p({-class=>"red"}, b("Error: please specify if file is public or not"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  $file_mime_type = $filetype_hash{$file_type};


  # loop over all files
  foreach $upload_filename (@upload_filenames) {
     # skip if no file provided
     if (!defined($upload_filename) || $upload_filename eq '' || length($upload_filename) == 0) { next; }

     ########################################
     # upload the file(s) to a local directory
     $datetime_now = get_current_datetime_for_sql();

     # assign a local filename (composed from user name and Unix timestamp)
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

     # file has been uploaded to the server now
     # write upload_log ...
     &write_upload_log($dbh, $session->param(-name=>'user_id'), $session->param(-name=>'username'), $dbh->quote($upload_filename), $local_filename);

     ##########################################

     ########################################################################################
     # NO TRANSACTION, BECAUSE blob table is MYISAM                                         #
     ########################################################################################
     # read file, and store it (in compressed form) into blob
     $sth = $dbh->prepare(qq(INSERT
                             INTO   $blob_database.blob_data (blob_id, blob_name, blob_content_type,
                                    blob_mime_type, blob_itself, blob_upload_datetime, blob_comment,
                                    blob_upload_user, blob_is_public)
                             VALUES (NULL, ?, ?, ?, COMPRESS(?), ?, ?, ?, ?)
                          )
                  );

     open($filehandle, "< ./uploads/$local_filename") or &error_message_and_exit($global_var_href, "Error processing file $!", $sr_name . "-" . __LINE__);
     read($filehandle, $file_content, -s $filehandle);

     $sth->execute($upload_filename, $file_type, $file_mime_type, $file_content, $datetime_now, $blob_comment, $user_id, $blob_is_public) or &error_message_and_exit($global_var_href, "Error saving file $!", $sr_name . "-" . __LINE__);

     # get insert id
     $sql = qq(select blob_id
               from   $blob_database.blob_data
               where  blob_name = ?
                      and blob_upload_datetime = ?
            );

     @sql_parameters = ($upload_filename, $datetime_now);

     # get id of inserted blob
     ($insert_id) = @{&do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, __LINE__)};

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $username . "\tinsert_blob\t$insert_id\t$upload_filename");
     ########################################################################################
     # NO TRANSACTION, BECAUSE blob table is MYISAM                                         #
     ########################################################################################

     ########################################################################################
     # try to get a lock
     &get_semaphore_lock($global_var_href, $user_id);
     ########################################################################################
     # begin transaction
     $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start transaction)", $sr_name . "-" . __LINE__);

     # insert mouse
     $sql = qq(insert
               into   mice2blob_data (m2b_mouse_id, m2b_blob_id, m2b_mouse_role)
               values (?, ?, ?)
            );

     $dbh->do($sql, undef,
              $mouse_id, $insert_id, 'mouse'
           ) or &error_message_and_exit($global_var_href, "could not link mouse $mouse_id to blob $insert_id ", '');

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $username . "\tlink_mouse_to_blob\t$mouse_id\t$insert_id");


     # mating generated, so commit
     $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

     # end transaction
     ########################################################################################
     # release lock
     &release_semaphore_lock($global_var_href, $user_id);
     ########################################################################################
  }

  $page .= p()
           . p('All done! File(s) successfully uploaded and attached to mouse '
               . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id"}, $mouse_id)
               . " (click to see uploaded files in mouse details view)"
             );

  return $page;
}
# end of upload_multi_blob_for_mouse_step_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_UPL011 assign_media_files_step_1():                 assign media files to mice from orderlist (1. step: initial form)
sub assign_media_files_step_1 {                          my $sr_name = 'SR_UPL011';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $parameterset      = param('parameterset');
  my $session           = $global_var_href->{'session'};
  my $user_id           = $session->param(-name=>'user_id');
  my ($page, $mouse, $file);
  my ($parameterset_media_path, $parameterset_media_parameter);
  my @selected_mice;
  my @mice_to_link;
  my %media_file_by_mouse_id;
  my @files;

  $page = h2("Assigning image files: 1. step")
          . hr();

  # read path for parameterset from settings table
  $parameterset_media_path = get_media_path_for_parameterset($global_var_href, $parameterset);


  # check if media path configured for parameterset. If undefined, stop here
  if (!defined($parameterset_media_path)) {
     $page .= p("No media path configured for parameterset \"" . get_parameterset_name_by_id($global_var_href, $parameterset) . "\"");

     return $page;
  }

  # read media parameter ID for parameterset from settings table
  $parameterset_media_parameter = get_media_parameter_for_parameterset($global_var_href, $parameterset);

  # check if media parameter configured for parameterset. If undefined, stop here
  if (!defined($parameterset_media_parameter)) {
     $page .= p("No media parameter configured for parameterset \"" . get_parameterset_name_by_id($global_var_href, $parameterset) . "\"");

     return $page;
  }

  # checks passed, continue...

  # collect all files in parameterset-specific media directory and subdirectories to array
  @files = `/usr/bin/find $parameterset_media_path`;

  # loop over all files ...
  foreach $file (@files) {
      # ... grab those with 8 digit mouseID in filename ...
      if ($file =~ /([0-9]{8})/) {
         # ... and write them to a hash with mouseID as key
         $media_file_by_mouse_id{$1} = $file;
      }
  }

  # read list of selected mice from CGI form
  @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_link, $mouse);
     }
  }

  # no mice chosen: warning
  if (!(scalar @mice_to_link > 0)) {
     $page .= p("No mice selected in orderlist. Please " . a({-href=>"javascript:back()"}, "go back") . " and select which mice are to be linked to media files.");

     return $page;
  }
  # mice chosen: fine, continue
  else {
     $page .= h3("Looking for images on configured media path ... ")
              . p()

              . start_table({-border=>1})
              . Tr(th('mouse ID'),
                   th('media file')
                );

     # loop over mice chosen on orderlist
     foreach $mouse (@mice_to_link) {

        $page .= Tr(td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse}, $mouse)),
                    td((defined($media_file_by_mouse_id{$mouse})
                        ?$media_file_by_mouse_id{$mouse}
                        :i("[no media file found]")
                       )
                    )
                   )
     }

     $page .= end_table();
  }


  $page .= start_form(-action=>url(), -name=>"myform")

           . p()
           . hidden('orderlist_id')
           . hidden('parameterset')
           . hidden('mouse_select')
           . submit(-name=>"choice", -value=>"assign media files!")
           . "&nbsp;&nbsp;or&nbsp;&nbsp;"
           . a({-href=>"javascript:back()"}, "go back")
           . end_form();

  return $page;
}
# end of assign_media_files_step_1
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_UPL012 assign_media_files_step_2():                 assign media files to mice from orderlist (2. step: store in database )
sub assign_media_files_step_2 {                          my $sr_name = 'SR_UPL012';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $dbh               = $global_var_href->{'dbh'};                   # database handle
  my $parameterset      = param('parameterset');
  my $orderlist         = param('orderlist_id');
  my $session           = $global_var_href->{'session'};
  my $user_id           = $session->param(-name=>'user_id');
  my $username          = $session->param(-name=>'username');
  my $datetime_now      = get_current_datetime_for_sql();
  my ($page, $mouse, $file);
  my ($parameterset_media_path, $parameterset_media_parameter, $medical_record_id, $transaction_result);
  my ($sql, $result, $rc, $rows, $row);
  my @selected_mice;
  my @mice_to_link;
  my %media_file_by_mouse_id;
  my @files;
  my @sql_parameters;


  $page = h2("Assigning image files: 2. step")
          . hr();

  # read path for parameterset from settings table
  $parameterset_media_path = get_media_path_for_parameterset($global_var_href, $parameterset);


  # check if media path configured for parameterset. If undefined, stop here
  if (!defined($parameterset_media_path)) {
     $page .= p("No media path configured for parameterset \"" . get_parameterset_name_by_id($global_var_href, $parameterset) . "\"");

     return $page;
  }

  # read media parameter ID for parameterset from settings table
  $parameterset_media_parameter = get_media_parameter_for_parameterset($global_var_href, $parameterset);

  # check if media parameter configured for parameterset. If undefined, stop here
  if (!defined($parameterset_media_parameter)) {
     $page .= p("No media parameter configured for parameterset \"" . get_parameterset_name_by_id($global_var_href, $parameterset) . "\"");

     return $page;
  }

  # checks passed, continue...

  # collect all files in parameterset-specific media directory and subdirectories to array
  @files = `/usr/bin/find $parameterset_media_path`;

  # loop over all files ...
  foreach $file (@files) {
      # ... grab those with 8 digit mouseID in filename ...
      if ($file =~ /([0-9]{8})/) {
         # ... and write them to a hash with mouseID as key
         $media_file_by_mouse_id{$1} = $file;
      }
  }

  # read list of selected mice from CGI form
  @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_link, $mouse);
     }
  }

  # no mice chosen: warning
  if (!(scalar @mice_to_link > 0)) {
     $page .= p("No mice selected in orderlist. Please " . a({-href=>"javascript:back()"}, "go back") . " and select which mice are to be linked to media files.");

     return $page;
  }
  # mice chosen: fine, continue
  else {
     $page .= h3("Looking for images on configured media path ... ")
              . p()

              . start_table({-border=>1})
              . Tr(th('mouse ID'),
                   th('media file'),
                   th('result')
                );

     # loop over mice chosen on orderlist
     foreach $mouse (@mice_to_link) {

        ########################################################################################
        # try to get a lock
        &get_semaphore_lock($global_var_href, $user_id);
        ########################################################################################
        # begin transaction
        $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start transaction)", $sr_name . "-" . __LINE__);

        # check if media parameter for current parameterset and mouse is already stored (we need to update it)
        $sql = qq(select mr_id
                  from   mice2medical_records
                         join medical_records on mr_id = m2mr_mr_id
                  where        m2mr_mouse_id = ?
                         and mr_orderlist_id = ?
                         and    mr_parameter = ?
               );

        @sql_parameters = ($mouse, $orderlist, $parameterset_media_parameter);

        # get medical record id we need to update for this mouse
        ($medical_record_id) = @{&do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, __LINE__)};

        # if there is a media file ...
        if (defined($media_file_by_mouse_id{$mouse})) {
            # ... and placeholder medical record already there:
            if (defined($medical_record_id)) {
               # update medical record
               $sql = qq(update medical_records
                         set    mr_text = ?, mr_comment = ?
                         where  mr_id = ?
                      );

               $dbh->do($sql, undef,
                        $media_file_by_mouse_id{$mouse}, 'ok', $medical_record_id
               ) or &error_message_and_exit($global_var_href, "could not update medical_record $medical_record_id! ", '');

               &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $username . "\tupdate_media_file_record\t$mouse\tparameterset\t$parameterset");

               $transaction_result = "success";
            }
            # ... and placeholder medical record not there yet:
            else {
               # we cannot update - notify user
               $transaction_result = "please upload data first, then assign media files!";
            }
        }

        # no media file found for this mouse ...
        else {
            # ... but placeholder medical record already there:
            if (defined($medical_record_id)) {
               # update medical record with status code for missing media file
               $sql = qq(update medical_records
                         set    mr_text = ?, mr_comment = ?
                         where  mr_id = ?
                      );

               $dbh->do($sql, undef,
                        undef, '_PNM-EQ_', $medical_record_id
               ) or &error_message_and_exit($global_var_href, "could not update medical_record $medical_record_id! ", '');

               &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $username . "\tupdate_media_file_record\t$mouse\tparameterset\t$parameterset");

               $transaction_result = "success";
            }
            # ... and placeholder medical record not there yet:
            else {
               # we cannot update - notify user
               $transaction_result = "please upload data first, then assign media files!";
            }
        }

        # commit
        $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

        # end transaction
        ########################################################################################
        # release lock
        &release_semaphore_lock($global_var_href, $user_id);
        ########################################################################################

        $page .= Tr(td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse}, $mouse)),
                    td((defined($media_file_by_mouse_id{$mouse})
                        ?$media_file_by_mouse_id{$mouse}
                        :i("[no media file found]")
                       )
                    ),
                    td($transaction_result)
                   )
     }

     $page .= end_table();
  }

  $page .= p();

  return $page;
}
# end of assign_media_files_step_2
#--------------------------------------------------------------------------------------



# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;