# lib_stat.pl - a MausDB subroutine library file                                                                                 #
#                                                                                                                                #
# Subroutines in this file provide statistics related functions                                                                  #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_STA001 select_R_analysis                             select R analysis                                                      #
# SR_STA002 start_R_analysis                              start R analysis                                                       #
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
# SR_STA001 select_R_analysis                             select R analysis
sub select_R_analysis {                                   my $sr_name = 'SR_STA001';
  my ($global_var_href)   = @_;                           # get reference to global vars hash
  my ($page, $mouse);
  my $url                 = url();
  my @mice_to_be_analysed = ();

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB ids
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_analysed, $mouse);
     }
     # else ignore ...
  }

  # exit if no mice selected
  if (scalar @mice_to_be_analysed == 0) {
     $page .= h2("Apply R script")
              . hr()
              . h3("No mice to analyse!")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # otherwise continue
  $page .= h2("Apply R script")
           . hr()
           . h3("Please choose R script to apply on selected mice")
           . start_form(-action=>url())    . "\n"
           . hidden(-name=>'mouse_select') . "\n"
           . hidden('orderlist_id') . "\n"
           . get_R_scripts($global_var_href)
           . p()
           . submit(-name => "choice", -value=>"apply R script!")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel (go to previous page)"))
           . end_form();

  return $page;
}
# end of select_R_analysis()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_STA002 start_R_analysis                              start R analysis
sub start_R_analysis {                                    my $sr_name = 'SR_STA002';
  my ($global_var_href)   = @_;                           # get reference to global vars hash
  my $url                 = url();
  my @mice_to_be_analysed = ();
  my $dbh                 = $global_var_href->{'dbh'};    # DBI database handle
  my $session             = $global_var_href->{'session'};
  my $username            = $session->param(-name=>'username');
  my $script_basename     = param('R_script');
  my @selected_mice       = param('mouse_select');
  my $orderlist_id        = param('orderlist_id');
  my $R_options           = '--quiet --slave --no-save --no-restore --silent';
  my ($page, $sth, $sql, $result, $rows, $row, $i, $column);
  my ($row_line, $mouse, $mouse_id_string);
  my ($URL_image_output_directory, $local_cgi_basedir, $local_htdoc_basedir, $URL_data_filename, $session_directory);
  my ($data_filename, $R_script_filename, $R_output_filename, $output_directory, $local_htdoc_output_directory, $lock_filename);
  my ($system_commandline, $system_result, $embedded_R_result_file, $sql_filename, $sql_out_filename, $modified_R_script_filename, $R_file);
  my @current_row;
  my @headers;

  $page .= h2("Run R script \"$script_basename\" on a selection of " . (scalar @selected_mice) . " mice")
           . hr()
           . p("Checking input");

  # check if orderlist_id is given
  if (defined(param('orderlist_id'))) {
     # check if it is valid (orderlist is used to be written to SQL file)
     if ($orderlist_id !~ /^[0-9]+$/) {
        &error_message_and_exit($global_var_href, "invalid orderlist id", $sr_name . "-" . __LINE__);
     }
  }

  # formally check script base name with regular expression (required by tainted mode as this goes to system call)
  # TODO: use better check :-)
  if ($script_basename =~ /^(.+)$/) {
     $script_basename = $1;
  }

  # check list of selected mouse ids for being mouse ids
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_analysed, $mouse);
     }
     # else ignore ...
  }

  # make mouse list SQL compatible
  $mouse_id_string = join(',', @mice_to_be_analysed);

  # exit if no mice selected
  if (scalar @mice_to_be_analysed == 0) {
     $page .= h3("No mice to analyse!")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  $page .= p("Setting up R environment");

  # adjust directories and filenames
  $session_directory            = $username . '_' . time();
  $output_directory             = 'output/' . $session_directory;
  $R_script_filename            = $script_basename . '.r';
  $sql_filename                 = $script_basename . '.sql';
  $local_cgi_basedir            = $global_var_href->{'local_cgi_basedir'};
  $local_htdoc_basedir          = $global_var_href->{'local_htdoc_basedir'} . '/R/';
  $URL_image_output_directory   = $global_var_href->{'URL_htdoc_basedir'}   . '/R/' . $output_directory . '/';
  $local_htdoc_output_directory = $local_htdoc_basedir . $output_directory  . '/';
  $R_script_filename            = $local_htdoc_basedir . $R_script_filename;
  $sql_filename                 = $local_htdoc_basedir . $sql_filename;
  $data_filename                = $local_htdoc_output_directory . $script_basename . '_data.txt';
  $URL_data_filename            = $URL_image_output_directory   . $script_basename . '_data.txt';
  $R_output_filename            = $local_htdoc_output_directory . $script_basename . '_out.txt';
  $sql_out_filename             = $local_htdoc_output_directory . $script_basename . '.sql';
  $modified_R_script_filename   = $local_htdoc_output_directory . $script_basename . '.r';
  $lock_filename                = $local_htdoc_output_directory . $script_basename . '.lock';

  mkdir($local_htdoc_output_directory);

  $page .= p("Reading SQL file [download: " . a({-href=>$URL_image_output_directory . $script_basename . '.sql'}, $script_basename . '.sql') . "]");

  ####################################################################
  # modify SQL template: insert actual mouse_ids
  ####################################################################
  # read in SQL file
  open(SQL_FILE, "< $sql_filename") or &error_message_and_exit($global_var_href, "Error reading SQL file $!", $sr_name . "-" . __LINE__);  

  # read in SQL_FILE
  while (<SQL_FILE>) {
     $sql .= $_;
  }

  close(SQL_FILE);
  #-------------------------------

  # replace placeholder MYMOUSESELECTION in SQL file with SQL compatible list of mouse_ids
  $sql =~ s/MYMOUSESELECTION/$mouse_id_string/g;

  # replace placeholder MYORDERLIST_ID in SQL file with actual orderlist_id (if given)
  if (defined(param('orderlist_id'))) {
     $sql =~ s/MYORDERLIST_ID/$orderlist_id/g;
  }

  #-------------------------------
  # write modified SQL file to output directory, so users can directly download and use it
  open(SQL_FILE, "> $sql_out_filename") or &error_message_and_exit($global_var_href, "Error writing SQL file $!", $sr_name . "-" . __LINE__);
  print SQL_FILE $sql;
  close(SQL_FILE);
  ####################################################################

  ####################################################################
  # modify R script template: insert actual mouse_ids
  ####################################################################
  # read in R script file
  open(R_FILE, "< $R_script_filename") or &error_message_and_exit($global_var_href, "Error reading R file $!", $sr_name . "-" . __LINE__);

  # read in R script file
  while (<R_FILE>) {
     $R_file .= $_;
  }

  close(R_FILE);
  #-------------------------------

  # replace placeholder MYMOUSESELECTION in R script file with SQL compatible list of mouse_ids
  $R_file =~ s/MYMOUSESELECTION/$mouse_id_string/g;

  # replace placeholder MYSESSIONDIR in R script file
  $R_file =~ s/MYSESSIONDIR/$session_directory/g;

  # replace placeholder MYORDERLIST_ID in R script file with actual orderlist_id (if given)
  if (defined(param('orderlist_id'))) {
     $R_file =~ s/MYORDERLIST_ID/$orderlist_id/g;
  }

  #-------------------------------
  # write modified R script file to output directory, so users can directly download and use it
  open(R_FILE, "> $modified_R_script_filename")  or &error_message_and_exit($global_var_href, "Error writing R file $!", $sr_name . "-" . __LINE__);
  print R_FILE $R_file;
  close(R_FILE);
  ####################################################################

  $page .= p("Query database");

  #-------------------------------
  # query database
  $sth = $dbh->prepare($sql)              or &error_message_and_exit($global_var_href, 'problem with prepare', $sr_name . "-" . __LINE__);
  $sth->execute()                         or &error_message_and_exit($global_var_href, 'problem with execute', $sr_name . "-" . __LINE__);
  $result = $sth->fetchall_arrayref({})   or &error_message_and_exit($global_var_href, 'problem with fetch',   $sr_name . "-" . __LINE__);
  $rows = scalar @{$result};
  $sth->finish()                          or &error_message_and_exit($global_var_href, 'problem with finish',  $sr_name . "-" . __LINE__);

  # empty resultset returned
  if ($rows == 0) {
     $page .= p({-class=>"red"}, "No data for chosen script in database!");

     return $page;
  }

  # resultset returned: write SQL query data to file
  else {
     $page .= p("Write data file [download as TAB delimited file: " . a({-href=>$URL_data_filename}, $script_basename . '_data.txt') . "]");

     open(DATAFILE, "> $data_filename") or &error_message_and_exit($global_var_href, "Error writing data file $!", $sr_name . "-" . __LINE__);

     # generate header row
     @headers = @{ $sth->{NAME} };                             # get column headers in correct order (as given by query)

     # write header row to file
     print DATAFILE join("\t", @headers) . "\n";

     # now loop over data rows
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];          # get next row
         @current_row = ();             # reset row

         # loop over columns
         for ($column=0; $column<=$#headers; $column++) {
             push(@current_row, defined($row->{$headers[$column]})?$row->{$headers[$column]}:"(NULL)");
         }

         # write current data row to file
         print DATAFILE join("\t", @current_row) . "\n";
      }

      close(DATAFILE);
  }
  #-------------------------------


  #-------------------------------
  # run R script on data file and write results to output file
  $page .=   p("Running R script [download file: " . a({-href=>$global_var_href->{'URL_htdoc_basedir'}   . '/R/output/' . $session_directory . '/' . $script_basename . '.r'}, $script_basename . '.r') . "]");

  # note: we need to run a virtual X server (xvfb) since we generate graphics output
  #   $system_commandline =  qq(/usr/bin/xvfb-run -a /usr/bin/R CMD BATCH $R_options $modified_R_script_filename $R_output_filename);
  #   $system_result = system($system_commandline);

  $ENV{'PATH'} = "$local_cgi_basedir:/usr/lib/bin:/usr/bin:/bin";
  $system_result = system('/usr/bin/xvfb-run', '-a', '/usr/bin/R', 'CMD', 'BATCH', $R_options, $modified_R_script_filename, $R_output_filename);

  if ($system_result != 0){
    #&error_message_and_exit($global_var_href, "Error calling R $?", $sr_name . "-" . __LINE__);
    carp("An error occured when running the R script (R $system_result)");
    $page .= hr()
             . h2({-class=>"red"}, "An error occured when running the R script (R $system_result)")
             . p({-class=>"red"},  "please use results with caution.\n")
             . hr();
  }

  $page .= p("Download result file: " . a({-href=>$URL_image_output_directory . $script_basename . '_out.txt'}, $script_basename . '_out.txt'))
          . hr({-width=>"50%", -align=>"left"});
  #-------------------------------

  #-------------------------------
  # read R output file
  open(RESULT_FILE, "< $R_output_filename")  or &error_message_and_exit($global_var_href, "Error reading data file $!", $sr_name . "-" . __LINE__);

  # read log RESULT_FILE line by line ...
  while (<RESULT_FILE>) {
     $embedded_R_result_file .= $_;
  }

  close(RESULT_FILE);
  #-------------------------------

  # release lock file
  if ( -e $lock_filename ) {
    unlink($lock_filename);
  }

  #-------------------------------
  # make R output look nicer, less cryptic: do some replacing operations to adapt raw R output to inline HMTL display

  # remove invisible stuff
  $embedded_R_result_file =~ s/Loading required package.*$//mg;
  $embedded_R_result_file =~ s/Attaching package:.*\n//g;
  $embedded_R_result_file =~ s/^.*masked from package.*$//mg;
  $embedded_R_result_file =~ s/lowes.*\n//g;

  # convert linebreaks to HTML (\n -> <br>)
  $embedded_R_result_file =~ s/\n/<br>/g;

  # remove invisible stuff
  $embedded_R_result_file =~ s/\> invisible\(options\(echo = FALSE\)\)//g;

  # remove [..]
  $embedded_R_result_file =~ s/\[[0-9]+\]\s//g;

  # remove NULL
  $embedded_R_result_file =~ s/\>NULL/>/g;

  # grep image names from script and replace by HTML image tags to display them inline
  $embedded_R_result_file =~ s/__(.*?)__/<img src=\"$URL_image_output_directory$1\" border=1 \/>/g;

  # grep format tags from script and replace by HTML tags for proper HTML display
  $embedded_R_result_file =~ s/--B(.*?)B--/<span><b>$1<\/b><\/span>/g;

  # grep format tags from script and replace by HTML tags for proper HTML display
  $embedded_R_result_file =~ s/--sub(.*?)sub--/<span><sub>$1<\/sub><\/span>/g;

  # grep format tags from script and replace by HTML tags for proper HTML display
  $embedded_R_result_file =~ s/--H1(.*?)H1--/<H1>$1<\/H1>/g;

  # grep format tags from script and replace by HTML tags for proper HTML display
  $embedded_R_result_file =~ s/--H2(.*?)H2--/<H2>$1<\/H2>/g;

  # grep format tags from script and replace by HTML tags for proper HTML display
  $embedded_R_result_file =~ s/--H3(.*?)H3--/<H3>$1<\/H3>/g;

  # print R output in div block with monospace preserving whitespaces style
  $page .= qq{<div style="white-space:pre; font-family:monospace; ">
              $embedded_R_result_file cut_end
              </div>
             };

  # remove R runtime information, tagged by cut_start-...-cut_end
  $page =~ s/cut_start(.*?)cut_end//g;
  #-------------------------------


  return $page;
}
# end of start_R_analysis()
#--------------------------------------------------------------------------------------



# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;