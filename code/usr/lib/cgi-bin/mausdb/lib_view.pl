# lib_view.pl - a MausDB subroutine library file                                                                                 #
#                                                                                                                                #
# Subroutines in this file provide overview and detail view functions                                                            #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_VIE001 location_overview():                         rack overview with just summary rack info                               #
# SR_VIE002 location_details():                          detailed rack view with all cage contents                               #
# SR_VIE003 print_cage_card():                           printable cage card view                                                #
# SR_VIE004 mouse_details():                             detailed view on a certain mouse                                        #
# SR_VIE005 show_cart                                    show mice in cart                                                       #
# SR_VIE006 show_cage                                    show a cage                                                             #
# SR_VIE007 gene_details                                 show gene details                                                       #
# SR_VIE008 import_view                                  show import details                                                     #
# SR_VIE009 contact_view                                 show contact details                                                    #
# SR_VIE010 mating_view                                  show mating details                                                     #
# SR_VIE011 litter_view                                  show litter details                                                     #
# SR_VIE012 mating_overview():                           mating overview                                                         #
# SR_VIE013 import_overview():                           import overview                                                         #
# SR_VIE014 external_mouse_details():                    detailed view on an external mouse                                      #
# SR_VIE015 cage_history():                              show cage and rack history of a mouse                                   #
# SR_VIE016 view_carts():                                cart overview                                                           #
# SR_VIE017 view_healthreport                            show health report                                                      #
# SR_VIE018 history_of_cage():                           show history of a cage                                                  #
# SR_VIE019 experiment_overview():                       experiment overview                                                     #
# SR_VIE020 experiment_view                              show experiment details                                                 #
# SR_VIE021 line_overview():                             line overview                                                           #
# SR_VIE022 line_view                                    line view                                                               #
# SR_VIE023 start_page():                                start page: user start page                                             #
# SR_VIE024 user_overview():                             user overview                                                           #
# SR_VIE025 show_ancestors():                            show_ancestors                                                          #
# SR_VIE026 show_admin_message():                        show admin message(s) ****CURRENTLY NOT USED****                        #
# SR_VIE027 embryo_transfer_view                         embryo transfer view                                                    #
# SR_VIE028 download_file                                download info                                                           #
# SR_VIE029 view_mice_of_mr                              show mice (with role) assigned to a given medical record                #
# SR_VIE030 view_blob_info                               show blob info together with linked mice                                #
# SR_VIE031 strain_view                                  strain view                                                             #
# SR_VIE032 strain_overview():                           strain overview                                                         #
# SR_VIE033 user_details                                 show user details                                                       #
# SR_VIE034 cost_centres_overview():                     cost centres overview                                                   #
# SR_VIE035 blob_overview():                             blob overview                                                           #
# SR_VIE036 projects_overview():                         projects overview                                                       #
# SR_VIE037 project_view():                              project view                                                            #
# SR_VIE038 genotypes_overview():                        genotypes overview                                                      #
# SR_VIE039 show_sanitary_status():                      sanitary status view                                                    #
# SR_VIE040 view_sanitary_report():                      view detailed sanitary report                                           #
# SR_VIE041 view_global_metadata():                      view global metadata                                                    #
# SR_VIE042 cohort_view                                  cohort view                                                             #
# SR_VIE043 line_parameterset_matrix():                  medical record summary (line vs. parameterset matrix)                   #
# SR_VIE044 line_orderlists_for_parameterset():          show all orderlists for a given line and parameterset                   #
# SR_VIE045 data_overview_for_line():                    medical record summary for a line                                       #
# SR_VIE046 treatment_procedures_overview()              treatment procedures overview                                           #
# SR_VIE047 treatment_procedure_view                     treatment procedure details view                                        #
# SR_VIE048 mouse_treatment_view                         mouse treatment details view                                            #
# SR_VIE049 cohorts_overview():                          cohorts overview                                                        #
# SR_VIE050 status_codes_overview():                     status codes overview                                                   #
# SR_VIE051 sterile_matings_overview():                  sterile matings overview                                                #
# SR_VIE052 workflows_overview():                        workflows overview                                                      #
# SR_VIE053 workflow_details                             workflow details view                                                   #
# SR_VIE054 find_orderlists_with_multiple_uploads:       find line by keyword                                                    #
# SR_VIE055 line_breeding_stats                          breeding statistics for a line                                          #
# SR_VIE056 line_breeding_genotype_stats                 breeding genotype statistics for a line                                 #
# SR_VIE057 display_images                               display_images available for a mouse                                    #
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
# SR_VIE001 location_overview():                         rack overview with just summary rack info
sub location_overview {                                  my $sr_name = 'SR_VIE001';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};   # session handle
  my $user_id           = $session->param('user_id');
  my @user_projects     = get_user_projects($global_var_href, $user_id);
  my $url               = url();
  my $old_room          = '';
  my ($page, $sql, $result, $rows, $row, $i);
  my ($mice_in_rack, $free_bar, $short_comment, $project_filter);
  my ($total_cages_in_use, $total_mice, $cages_in_rack, $cages_free, $total_cage_slots_free);
  my @sql_parameters;

  # decide if we restrict output to "own racks" of user or if we show all racks
  if (defined(param('all_racks')) && param('all_racks') eq 'true') { $project_filter = 'no';  }
  else                                                             { $project_filter = 'yes'; }

  $page = start_form(-action => url())
          . h2('Rack overview '
                . a({-href=>"$url?choice=location_overview", -title=>'reload page'},
                    img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
                  )
             . '&nbsp;&nbsp;&nbsp;or enter cage number(s) '
             . textfield(-name => 'cage_ids', -size => '20', -maxlength => '30', -title => 'enter cage number(s) separated with blanks')
             . submit(-name => 'choice', -value => 'Search cage(s)')
            )
          . end_form()

          . hr();

  $sql = qq(select location_id, project_name, location_building, location_subbuilding, location_room, location_rack, location_subrack, location_capacity,
                   location_project, location_comment
            from   locations
                   left join projects on location_project = project_id
            where  location_is_internal   =  ?
                   and location_is_active =  ?
                   and location_id        >= ?
                   and location_id        <  ?
            order  by  location_display_order
           );

  @sql_parameters = ('y', 'y', 0, 99999);

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . '-' . __LINE__ );

  # no racks found ...
  unless ($rows > 0) {
    $page .= p('No racks found. ');
    return $page;
  }

  # ... otherwise continue with result table

  # first generate table header ...
  $page .= p(b('Showing active racks ') . '[ '
             . a({-href => "$url?choice=location_overview&all_racks=true", -title => 'show all racks'}, 'show all racks') . ' | '
             . a({-href => "$url?choice=location_overview", -title => 'show racks from your screen(s) only'}, 'show racks from your screen(s) only') . ' ] '
            )
           . start_table( {-border => '1', -summary => 'rack_overview'})

           . Tr(  {-align => 'center'},
               td({-rowspan => '2'}, b('Room') . br() . 'racks'),
               th({-colspan => '3'}, 'Cage summary'),
               th({-rowspan => '2'}, 'total number' . br() . 'of mice in' . br() . 'this rack'),
               th({-rowspan => '2'}, 'project assignment'),
               th({-rowspan => '2'}, 'comment (shortened)')
             )
           . Tr( {-align=>'center'},
               th("total" . br() . "capacity"),
               th("in use/free"),
               th("cage slots in use (*) and free (.)")
             );

  # ... then loop over all (internal and active) racks
  for ($i=0; $i<$rows; $i++) {               # $rows is the number of racks returned from the above query
      $row = $result->[$i];                  # get a reference on the current rack

      # skip this rack if it is not one of the user's racks (and user did not want to see all racks)
      if (is_in_list($row->{'location_project'}, \@user_projects) == 0 && $project_filter eq 'yes') {
         next;
      }

      ##############################
      # how many cages in this rack?
      $sql = qq(select count(c2l_cage_id) as cages_in_rack
                from   cages2locations
                where  c2l_location_id = ?
                       and c2l_datetime_to IS NULL
             );

      @sql_parameters = ($row->{'location_id'});

      ($cages_in_rack) =  @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};
      ##############################

      # calculate rack usage bar (graphical representation of free rack space)
      $free_bar = int($cages_in_rack / $row->{'location_capacity'} * $global_var_href->{'rack_usage_bar_width'});
      $free_bar = tt('*' x $free_bar . '.' x ($global_var_href->{'rack_usage_bar_width'} - $free_bar) );

      $total_cages_in_use    += $cages_in_rack;
      $total_cage_slots_free += $row->{'location_capacity'} - $cages_in_rack;

      # subquery to determine the number of mice in current rack
      ($mice_in_rack) = get_mice_in_location($global_var_href, $row->{'location_id'});

      $total_mice += $mice_in_rack;

      # shorten comment to fit on page
      if ($row->{'location_comment'} =~ /(^.{30})/) {
         $short_comment = $1 . ' ...';
      }
      else {
         $short_comment = $row->{'location_comment'};
      }

      # generate an extra row that shows the room number, in case we entered a new room in this loop
      if ($old_room ne $row->{'location_room'}) {
          $page .= Tr({-bgcolor=>'lightblue'},
                      td(b($row->{'location_room'})),
                      td({-colspan=>'8'}, b($row->{'location_subbuilding'}) . ' ' . b($row->{'location_subrack'}))
                   );
      }

      # generate the current rack summary row
      $page .= Tr({-align=>'center'},
                 td(a({-href=>"$url?choice=location_details&location_id=$row->{'location_id'}", -title=>"click for rack details"},
                      "rack $row->{'location_rack'}"
                     )
                 ),
                 td($row->{'location_capacity'}),
                 td($cages_in_rack . " / " . ($row->{'location_capacity'} - $cages_in_rack)),
                 td("$free_bar"),
                 td($mice_in_rack),
                 td($row->{'project_name'}),
                 td($short_comment)
               );

      $old_room = $row->{'location_room'};              # update room (be able to recognize new room and to generate room line in table)
  }

  # how many total cages free
  $sql = qq(select count(cage_id) as cages_free
            from   cages
            where  cage_occupied = ?
         );

  @sql_parameters = ('n');

  ($cages_free) =  @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $page .= Tr(
             td({-colspan=>2, -align=>'right'}, b('cages')),
             td({-align=>'center'}, b($total_cages_in_use . '/' . $total_cage_slots_free)),
             td({-align=>'right'},  b('total mice')),
             td({-align=>'center'}, b($total_mice))
           )
           . end_table();

  return $page;
}
# end of location_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE002 location_details():                          detailed rack view with all cage contents
sub location_details {                                   my $sr_name = 'SR_VIE002';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $location_id       = param('location_id');          # get location id from CGI
  my $location_comment  = param('location_comment');     # get location comment from form if change requested
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $session           = $global_var_href->{'session'};            # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $datetime_now      = get_current_datetime_for_sql();
  my $old_cage          = "";
  my $url               = url();
  my @parameters        = param();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($mice_in_rack, $free_bar, $div_id, $time, $mouse_counter, $sex_color, $bg_color, $gene_info);
  my ($total_in_cage, $mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, $strain_in_cage, $line_in_cage);
  my ($current_mating, $short_comment, $parameter, $first_gene_name, $first_genotype, $location_comment_sql);
  my %labels;
  my @sql_parameters;

  # check input parameter:1) a location id must be given, 2) it has to be strictly numeric (prevent SQL injections)
  if (!defined(param('location_id')) || param('location_id') !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid rack id (must be a number)", $sr_name . "-" . __LINE__);
  }

  ################################################################
  # update rack comment if requested
  if (defined(param('job')) && param('job') eq "update rack comment") {

     $location_comment_sql = $location_comment;
     $location_comment_sql =~ s/'|;|-{2}//g;                  # remove dangerous content

     # update rack comment
     $dbh->do("update  locations
               set     location_comment = ?
               where   location_id = ?
              ", undef, $location_comment_sql, $location_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update rack comment)", $sr_name . "-" . __LINE__);

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdate_rack_comment\t$location_id\tnew:$location_comment_sql");
  }
  ################################################################

  #########################################################
  # rack overview (for first table)
  $page = h2("Rack details "
             . a({-href=>"$url?choice=location_details&location_id=$location_id", -title=>"reload page"},
                 img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
               )
          )
          . hr();

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href);
  }

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select location_id, project_name, location_building, location_subbuilding, location_room, location_rack, location_subrack, location_capacity,
                   location_project, location_comment, count(c2l_cage_id) as occupied, (location_capacity - count(c2l_cage_id)) as free
            from   locations
                   left join cages2locations on      location_id = c2l_location_id
                   left join projects        on location_project = project_id
            where  location_id = ?
                   and location_is_internal = ?
                   and location_is_active   = ?
                   and c2l_datetime_to      IS NULL
                   and location_project     = project_id
            group  by location_id
            order  by location_room desc
           );

  @sql_parameters = ($location_id, 'y', 'y');

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no such rack found ...
  unless ($rows > 0) {
    $page .= p(b("Currently no cages in this rack (or rack does not exist)")
             . '&nbsp;&nbsp;'
             . '['
             . a({-href=>"$url?choice=show_sanitary_status&rack_id=" . $location_id}, 'sanitary status')
             . ']');

    return $page;
  }

  # get first (and only) row of result
  $row = $result->[0];

  $page .= p(b("Overview: rack $row->{'location_rack'} in room " . $row->{'location_building'} . "-" . $row->{'location_subbuilding'}
               . "-" .  $row->{'location_room'}
               . (defined($row->{'location_subrack'})?' (' . $row->{'location_subrack'} . ')':'')
             )
             . '&nbsp;&nbsp;'
             . '['
             . a({-href=>"$url?choice=show_sanitary_status&rack_id=" . $row->{'location_id'}}, 'sanitary status')
             . ']'
             . '&nbsp;&nbsp;'
             . '['
             . a({-href=>"$url?choice=stock_taking_list&rack_id=" . $location_id}, 'spreadsheet stock taking list')
             . ']'
           )
           . start_form(-action=>url(), -name=>"myform1")
           . hidden('location_id')
           . hidden('choice')
           . start_table( {-border=>1, -cellspacing=>"1", -cellpadding=>"2", -bgcolor=>"#EEFFEE", -summary=>"table"})

           . Tr( {-align=>'center', -bgcolor=>"#DDFFDD"},
               th({-colspan=>"3"}, "Cages"),
               th({-rowspan=>"2"}, "total number" . br() . "of mice in" . br() . "this rack"),
               th({-rowspan=>"2"}, "project assignment"),
               th({-rowspan=>"2"}, "rack info")
             )
           . Tr( {-align=>'center', -bgcolor=>"#DDFFDD"},
               th("total" . br() . "capacity"),
               th("in use/free"),
               th("cages in use (*) and free cages (.)")
             );

  # calculate rack usage bar (graphical representation of free rack space)
  $free_bar = int($row->{'occupied'} / $row->{'location_capacity'} * $global_var_href->{"rack_usage_bar_width"});
  $free_bar = tt('*' x $free_bar . '.' x ($global_var_href->{"rack_usage_bar_width"} - $free_bar) );

  # subquery to determine the number of mice in current rack
  ($mice_in_rack) = get_mice_in_location($global_var_href, $row->{'location_id'});

  $page .= Tr({-align=>'center'},
              td($row->{'location_capacity'}),
              td($row->{'occupied'} . " / " . $row->{'free'}),
              td("$free_bar"),
              td($mice_in_rack),
              td($row->{'project_name'}),
              td(textfield(-name => 'location_comment', -size => '20', -value=>$row->{'location_comment'}, -maxlength => '30',
                           -title => 'edit rack name'
                 )
                 . submit(-name => 'job', -value => 'update rack comment')
              )
           )
           . end_table()
           . end_form();

  # end of the first table (rack summary table)
  #########################################################

  #########################################################
  # select all cages in this rack (for second table)
  $sql = qq(select c2l_cage_id, cage_name, cage_purpose, cage_cardcolor, project_name, cage_capacity,
                   mouse_id, mouse_earmark, mouse_sex, strain_name, line_id, line_name, mouse_is_gvo, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime
            from   cages2locations
                   join cages         on      cage_id = c2l_cage_id
                   join projects      on cage_project = project_id
                   join mice2cages    on  m2c_cage_id = cage_id
                   join mice          on m2c_mouse_id = mouse_id
                   join mouse_strains on mouse_strain = strain_id
                   join mouse_lines   on   mouse_line = line_id
            where  c2l_location_id = ?
                   and c2l_datetime_to IS NULL
                   and m2c_datetime_to IS NULL
                   and mouse_deathorexport_datetime IS NULL
            order  by c2l_cage_id asc, mouse_sex desc, mouse_id asc
           );

  @sql_parameters = ($location_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no cage found in this rack: tell user and exit
  unless ($rows > 0) {
    $page .= p(b("Currently no cages in this rack"));
    return $page;
  }

  # show rack table if there are any cages at all
  $page .= p(b("Cages currently in this rack"))
           . span( {-style=>"font-family : Verdana, Helvetica, Arial, sans-serif; font-size : 14px; font-weight : normal;"},
                     a({-href=>"javascript:hide_all('cage')", -style=>"text-decoration: none; display: none;",   -name=>"toggle", -id=>"hide_all"}, "- (collapse all)")
                   . a({-href=>"javascript:show_all('cage')", -style=>"text-decoration: none; display: inline;", -name=>"toggle", -id=>"show_all"}, "+ (expand all)"  )
             )
           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>"1", -summary=>"table", -cellspacing=>"1", -cellpadding=>"2", -style=>"table-layout: fixed; background: #EEFFEE;"})
           . Tr( {-align=>'center', -bgcolor=>"#DDFFDD"},
               th({-colspan=>'10'}, "cage info"),
               th({-colspan=>'3'},  "cage action"),
               th({-rowspan=>'2'},  "comment (shortened)")
             )
           . Tr( {-align=>'center', -bgcolor=>"#DDFFDD"},
               th("Cage #"),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th("mouse ID" . br() . "click for details"),
               th("ear"),
               th("sex"),
               th("born"),
               th("age"),
               th("genotype"),
               th("strain"),
               th("line"),
               th("move"),
               th("print"),
               th("select" . br() . checkbox(-name=>"checkallcages", -label=>"", -onClick=>"checkAllcages(document.myform);", -title=>"select/unselect all"))
             );

  # loop over all cages found in this rack
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                       # get reference on current result row

      if ($old_cage ne $row->{'c2l_cage_id'}) {   # it is a new cage, so generate cage summary header row in table
          $mouse_counter = 0;                     # reset cage mouse counter if cage changes

          # generate cage id tag for <div> elements (needed to collapse/expand cages in table view)
          $div_id = "cage_" . $row->{'c2l_cage_id'};

          # get cage summary info
          ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, $strain_in_cage, $line_in_cage, undef) = &get_mice_in_cage($global_var_href, $row->{'c2l_cage_id'});

          # do some formatting depending on cage content (male<->female, ...)
          if    ($sex_mixed eq "true")  { $bg_color = "#FFFFDD";                              }
          elsif ($males_in_cage > 0  )  { $bg_color = $global_var_href->{'bg_color_male'};    }
          else                          { $bg_color = $global_var_href->{'bg_color_female'};  }

          if    ($males_in_cage == 0)   { $total_in_cage = "";                                }
          elsif ($males_in_cage == 1)   { $total_in_cage = "$males_in_cage male";             }
          elsif ($males_in_cage > 1 )   { $total_in_cage = "$males_in_cage males";            }

          if    ($females_in_cage == 0) { $total_in_cage .= "";                               }
          elsif ($females_in_cage == 1) { $total_in_cage .= " $females_in_cage female";       }
          elsif ($females_in_cage > 1 ) { $total_in_cage .= " $females_in_cage females";      }

          # generate the actual header row
          $page .= Tr(
                     td({-align=>'center', -colspan=>'13', -style=>"visibility: hidden; height: 0.2em;"}, "")
                   )
                   . Tr({-bgcolor=>"$bg_color"},
                      td(a({-href=>"javascript:show('$div_id','$mice_in_cage')", -style=>"text-decoration: none; display: inline; ", -name=>"toggle", -id=>"$div_id" . "-show"}, "+ ") .
                         a({-href=>"javascript:hide('$div_id','$mice_in_cage')", -style=>"text-decoration: none; display: none;",    -name=>"toggle", -id=>"$div_id" . "-hide"}, "- ") .
                         b(a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'c2l_cage_id'}}, $row->{'c2l_cage_id'}))
                        ),
                      td({-colspan=>'9'},  b($total_in_cage . ", strain: $strain_in_cage, line: $line_in_cage ")
                        ),
                      td(a({-href => "$url?choice=move_cage&cage_id=$row->{'c2l_cage_id'}" }, "cage")),
                      td(a({-href => "$url?choice=print_card&cage_id=$row->{'c2l_cage_id'}", -target=>"_blank"}, "print card") ),
                      td({-align=>'center'}, checkbox(-name=>'cage_select', -checked=>'0', -value=>$row->{'c2l_cage_id'}, -label=>'')),
                      td()
                     );
      }

      # count mice in current cage
      $mouse_counter++;

      # sex-dependent row coloring
      if    ($row->{'mouse_sex'} eq 'm') { $sex_color = $global_var_href->{"bg_color_male"};   }
      elsif ($row->{'mouse_sex'} eq 'f') { $sex_color = $global_var_href->{"bg_color_female"}; }

      # check if current mouse is already in a mating (use this information to add mating remark to mouse comment)
      $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

      $labels{"$row->{'mouse_id'}"} = "";

      # shorten comment
      if (defined($row->{'mouse_comment'}) && $row->{'mouse_comment'} =~ /(^.{30})/) {
         $short_comment = $1 . ' ...';
      }
      else {
         $short_comment = $row->{'mouse_comment'};
      }

      # get first genotype
      ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

      # generate actual mouse row
      $page .= Tr({-align=>'center', -bgcolor=>"$sex_color", -name=>"cage_row", -id=>"$div_id" . "-" . $mouse_counter, -style=>"display: none;"},
                 td($mouse_counter),
                 td(checkbox('mouse_select', '0', $row->{'mouse_id'}, '')),
                 td(a({-href=>"$url?choice=mouse_details&mouse_id=$row->{'mouse_id'}", -style=>"text-decoration: none;"}, b($row->{'mouse_id'})) ),
                 td($row->{'mouse_earmark'}),
                 td($row->{'mouse_sex'}),
                 td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                 td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                 td({-style=>"width: 20mm; white-space: nowrap; overflow: hidden;", -title=>(defined($first_gene_name)?$first_gene_name:'no genotype for this mouse')},
                    (defined($first_gene_name)?$first_genotype:'-')
                 ),
                 td({-style=>"width: 20mm; white-space: nowrap; overflow: hidden;"}, $row->{'strain_name'}),
                 td({-style=>"width: 20mm; white-space: nowrap; overflow: hidden;"}, a({-href=>"$url?choice=line_view&line_id=" . $row->{'line_id'}}, $row->{'line_name'})),
                 td(a({-href => "$url?choice=move_mouse&mouse_id=$row->{'mouse_id'}"}, "mouse")),
                 td(),
                 td(),
                 td({-style=>"width: 20mm; white-space: nowrap; overflow: hidden;"},
                    ((defined($current_mating))
                     ?span({-class=>"red"}, "(in mating " . a({-href=>"$url?choice=mating_view&mating_id=$current_mating"}, $current_mating)
                                              . ' ' . get_transfer_info($global_var_href, $current_mating) . ') ')
                     :""
                    )
                    . "&nbsp;&nbsp;" . $short_comment
                   )
               );

      $old_cage = $row->{'c2l_cage_id'};
  }

$page .= end_table()
           . p();

  # store CGI parameters in hidden fields. Yes, I know, there are better ways to do this, but input from hidden fields will be checked
  foreach $parameter (@parameters) {
     unless ($parameter eq 'mouse_select' || $parameter eq 'job') {
        $page .= hidden(-name=>$parameter, -value=>param("$parameter")) . "\n";
     }
  }

  $page .=   submit(-name => "job", -value=>"Add selected mice to cart") . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"Move selected cages")       . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"Move selected mice")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")               . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre") . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")
           . end_form();

  return $page;
}
# end of location_details()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE003 print_cage_card():                           printable cage card view
sub print_cage_card {                                    my $sr_name = 'SR_VIE003';
  my ($global_var_href) = @_;                                   # get reference to global vars hash
  my $url               = url();
  my $cage_id           = param('cage_id');
  my $is_mating_cage    = "";
  my $how_many_matings  = 0;
  my ($page, $sql, $result, $rows, $row, $i);
  my ($current_mating, $cage_barcode_filename);
  my ($cage_string, $location_id, $location_room, $location_rack, $project_shortname, $cage_bar_color);
  my ($mouses, $old_room, $old_cage, $mouse_counter, $bg_color, $gene_info, $div_id, $mouse_comment);
  my ($total_in_cage, $mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, $strain_in_cage, $line_in_cage);
  my @mothers;
  my @sql_parameters;

  # check input first: a cage id must be provided and it has to be a number (prevent SQL injections)
  if (!param('cage_id') || param('cage_id') !~ /^[0-9]+$/) {
      &error_message_and_exit($global_var_href, "invalid cage id (must be a number)", $sr_name . "-" . __LINE__);
  }

  # include barcode modules
  use GD::Barcode::ITF;
  use GD::Barcode::Code39;

  # get details from this cage
  $sql = qq(select c2l_cage_id, cage_name, cage_purpose, cage_cardcolor, project_name, cage_capacity,
                   mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_is_gvo, mouse_comment,
                   mouse_birth_datetime
            from   cages2locations
                   join cages         on      cage_id = c2l_cage_id
                   join projects      on cage_project = project_id
                   join mice2cages    on  m2c_cage_id = cage_id
                   join mice          on m2c_mouse_id = mouse_id
                   join mouse_strains on mouse_strain = strain_id
                   join mouse_lines   on   mouse_line = line_id
            where  c2l_cage_id = ?
                   and c2l_datetime_to IS NULL
                   and m2c_datetime_to IS NULL
                   and mouse_deathorexport_datetime IS NULL
            order  by c2l_cage_id asc, mouse_sex desc, mouse_id asc
            );

  @sql_parameters = ($cage_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no rows returned: cage empty
  unless ($rows > 0) {
     $page = h2("Cage card")
             . hr()
             . p("Currently no mice in this cage");
     return $page;
  }

  ###############################################################
  # generate card frame
  # we dont want the usual page header with logo, but a pure printable cage card, so print header here
  $page = header()
          . start_html(-title=>"(MausDB)", -style=>{-src=>$global_var_href->{'URL_htdoc_basedir'} . '/css/print.css', -media=>"screen, print"})
          . style({-type=>"text/css"},
                   '@page' . ' { size:20.0cm 29.7cm; margin:0.1cm; marks:cross; }' . "\n"
                   . '@media print{ a { display: none; } }'                        . "\n"
            )
          . "\n\n";

  # cage summary: just get first result (as information we want is contained in there as well as in any other row)
  $row = $result->[0];

  # read cage bar color from database
  $cage_bar_color = get_cage_color_by_id($global_var_href, $row->{'cage_cardcolor'});

  # generate cage barcode png
  $cage_barcode_filename = $global_var_href->{'local_htdoc_basedir'} . '/maustmp/cage_' . $row->{'c2l_cage_id'} . '.png';
  open(OUTFILE, "> $cage_barcode_filename");
  binmode(OUTFILE);
  print OUTFILE GD::Barcode::Code39->new('*' . $row->{'c2l_cage_id'} . '*')->plot(NoText=>1, Height => 5)->png;
  close(OUTFILE);

  $div_id = "cage_" . $row->{'c2l_cage_id'};

  # $page .= start_div({-id=>"print_card", -style=>"position: absolute; top: 0mm; left: 1mm; width: 146mm; height: 105mm; border: 0px solid;"});
  $page .= start_div({-id=>"print_card", -style=>"position: absolute; top: 0mm; left: 1mm; width: 146mm; height: 70mm; border: 0px solid;"});
  # end of card frame
  ###############################################################

  ###############################################################
  # generate right part of cage card

  # get info about rack in which cage currently sits
  $location_id = get_cage_location($global_var_href, $cage_id);

  # get some basic info about that location
  $sql = qq(select location_room, location_rack, project_shortname
            from   locations
                   left join projects on location_project = project_id
            where  location_id = ?
           );

  @sql_parameters = ($location_id);

  ($location_room, $location_rack, $project_shortname) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $page .= start_div({-id=>"right", -style=>"position: relative: top: 10mm; margin-left: 71mm; width: 70mm; height: 85mm; border: 0px solid;"})
           . div({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 16px; border-bottom: 1px solid;"},
                  "&nbsp; $location_room-$location_rack &nbsp;"
                  . img({-src=>$global_var_href->{'URL_htdoc_basedir'} . "/maustmp/cage_$cage_id" . '.png', -border=>0, -style=>'width: 20mm; height: 5mm;', -alt=>'[barcode]'})
                  . span({-style=>"font-size: 22px; font-weight: bold;"}, $cage_id)
             )
           . start_table( {-border=>"0", -summary=>"table", -cellspacing=>"1", -cellpadding=>"1", -style=>"table-layout: fixed; width: 65mm; "});


  # now loop over all mice in cage
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      # generate barcode png
      open(OUTFILE, "> $global_var_href->{'local_htdoc_basedir'}" . '/maustmp/' . $row->{'mouse_id'} . '.png');
      binmode(OUTFILE);
      print OUTFILE GD::Barcode::ITF->new($row->{'mouse_id'})->plot(NoText=>1, Height => 5)->png;
      close(OUTFILE);

      # count mice
      $mouse_counter++;

      # if at least one female mouse is currently in a mating, set status "MATING CAGE"
      if ($row->{'mouse_sex'} eq 'f') {
         # check if female mouse is currently in a mating
         $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

         # if mouse is in mating, print "MATING CAGE" on card
         if (defined($current_mating)) {
            $is_mating_cage = "MATING CAGE";
            $how_many_matings++;
         }
      }

      # collect all mothers of this mouse
      @mothers = @{get_mother($global_var_href, $row->{'mouse_id'})};

      $page .= Tr( {-valign=>'top'},
                 td({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 10px; width: 30mm; align: left;"},
                    "&nbsp;&nbsp;"
                    . img({-src=>$global_var_href->{'URL_htdoc_basedir'} . "/maustmp/$row->{'mouse_id'}" . '.png', -border=>0, -style=>'width: 25mm; height: 8mm;', -alt=>'[barcode]'})
                    . br()
                    . "&nbsp;&nbsp;"
                    . (($row->{'mouse_sex'} eq 'm')?'M':'F') . " $row->{'mouse_id'}-" . $row->{'mouse_earmark'}
                    . p()
                   ),
                 td({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 12px; width: 8mm; align: left;"},
                     'orig:' . br() . 'fa: ' . br() . 'mo: '
                   ),
                 td({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 12px; align: left; "},
                    &get_origin($global_var_href, $row->{'mouse_id'})
                    . br()
                    . &reformat_number(@{get_father($global_var_href, $row->{'mouse_id'})}[0], 8)
                    . br()
                    . &reformat_number($mothers[0], 8)      # simply take the first mother of all mothers
                    . ((scalar @mothers > 1)?'+':'')        # show '+' if there is more than one mother
                   )
               );
  }

  $page .= end_table();

  $page .= span({-style=>"font-size: 8px;"}, "Printed " . localtime())
           . end_div();

  # end of right part of the cage card
  ###############################################################

  ###############################################################
  # generate left part of cage card

  # get info about rack in which cage currently sits
  $location_id = get_cage_location($global_var_href, $cage_id);

  # get some basic info about that location
  $sql = qq(select location_room, location_rack, project_shortname
            from   locations
                   left join projects on location_project = project_id
            where  location_id = ?
           );

  @sql_parameters = ($location_id);

  ($location_room, $location_rack, $project_shortname) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # Wasserzeichen: -style=>"background-image:url(http://darvas.gsf.de/mausdb/images/reload.gif);background-repeat:repeat-y;"

  $page .= start_div({-id=>"left",  -style=>"position: absolute; top: 0; margin-left: 0; width: 70mm;  height: 80mm; border: 0px solid;"})
           . div({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 16px; border-bottom: 1px solid;"},
                 span({-style=>"font-size: 16px;"},   " $location_room-$location_rack "
                                                    . "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
               # Hier wird die Position des Farbbalkens auf der linken Seite der Kaefigkarte eingestellt
               . span({-id=>"colorbox", -style=>"position: absolute; left: 20mm; top: 1mm; width: 16mm; height: 5mm; background: $cage_bar_color;"}, "")
               . span({-style=>"font-size: 22px; font-weight: bold; "}, $cage_id)
             )
           . start_table( {-border=>"0", -summary=>"table", -cellspacing=>"1", -cellpadding=>"1", -style=>"table-layout: fixed; width: 70mm; "});

  # loop over all mice in cage
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $mouse_counter++;

      $current_mating = '';

      if ($row->{'mouse_sex'} eq 'f') {
         # get mating id if female mouse is in a mating
         $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

         if (defined($current_mating)) {
            $current_mating = span({-style=>"font-weight: bold; background-color: #FF0;"}, 'Mating ' . $current_mating) . ' ' . get_transfer_info($global_var_href, $current_mating);
            $how_many_matings++;
         }
         else {
            $current_mating = '';
         }
      }

      $gene_info = &get_gene_info_print($global_var_href, $row->{'mouse_id'});

      if (!defined($row->{'mouse_comment'}) || $row->{'mouse_comment'} eq '') {
         $mouse_comment = "";
      }
      else {
         $mouse_comment = $row->{'mouse_comment'};
      }

      $page .= Tr(
                 td({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 13px; font-weight: bold; width: 24mm; align: left; "},
                     "$row->{'mouse_id'}-" . $row->{'mouse_earmark'}
                   ),
                 td({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 13px; font-weight: bold; width: 8mm;"},
                     "&nbsp;" . b(($row->{'mouse_sex'} eq "m")?"M":"F")
                   ),
                 td({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 13px; white-space: nowrap;"},
                    "*" . format_datetime2simpledate($row->{'mouse_birth_datetime'})
                    . "&nbsp;"
                    . b(($row->{'mouse_is_gvo'} eq "y")?span({-style=>"color: #ff0000;"}, "G"):'')
                    . b((is_in_experiment($global_var_href, $row->{'mouse_id'}) < 0)?'':span({-style=>"color: #ff0000;"}, "E"))
                   )
               )
               . Tr(
                   td({-colspan=>3, -style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 10px; align: left; white-space: nowrap; overflow:hidden;"},
                      $row->{'line_name'} . ", " .$row->{'strain_name'}
                   )
                 )
               . Tr(
                   td({-colspan=>3, -style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 10px; align: left; white-space: nowrap;"},
                      $gene_info
                   )
                 )
               . Tr(
                   td({-colspan=>3, -style=>"font-family: Verdana, Helvetica, Arial, sans-serif; align: left; border-bottom: 1px solid gray; font-size: 10px; white-space: nowrap; overflow:hidden;"},
                      $current_mating . "&nbsp;" . $mouse_comment
                   )
                 );
  }

  $page .= end_table();

  # for mating cages, print litter table instead of action barcodes
  if ($how_many_matings > 0) {
     $page .= start_table( {-border=>"1", -summary=>"table", -cellspacing=>"0", -cellpadding=>"1", -style=>"border-collapse:collapse;"} )
              . Tr(
                  td({-align=>"center"}, small("&nbsp;#&nbsp;")),
                  td({-align=>"center"}, small("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")),
                  td({-align=>"center"}, small("&nbsp;&nbsp;m/f&nbsp;&nbsp;&nbsp;")),
                  td({-align=>"center"}, small("&nbsp;dead/comment&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"))
                );

     for ($i=0; $i<7; $i++) {
         $page .=  Tr(
                     td({-align=>"center"}, ""),
                     td({-align=>"center"}, ""),
                     td({-align=>"center"}, ""),
                     td({-style=>"height: 15px;",  -align=>"center"}, "")
                   );
     }

     $page .= end_table();
  }

  $page .=  end_div();

  # this was the left part of the cage card
  ###############################################################

  # for screen display only (will not be printed on card)
  $page .= p("&nbsp;") . p("&nbsp;") . a({-href=>"javascript:window.print()"}, "Print this cage card")
           . p()
           . a({-href=>"javascript:window.close()"}, "close this window")
           . end_div()
           . end_html();

  # rather than returning the page to MAIN, we print $page directly to STDOUT, because
  # don't need the usual page header and tail, but a pure cage card
  print $page;

  # exit without error
  exit(0);
}
# end of print_cage_card()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE004 mouse_details():                             detailed view on a certain mouse
sub mouse_details {                                      my $sr_name = 'SR_VIE004';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $blob_database     = $global_var_href->{'blob_database'};    # name of the blob_database
  my $cryo_database     = $global_var_href->{'cryo_database'};    # is cryo database configured (read from config.rc)?
  my $olympus_database  = $global_var_href->{'olympus_database'}; # is olympus database configured (read from config.rc)?
  my $url               = url();
  my $session           = $global_var_href->{'session'};            # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $mouse_id          = param('mouse_id');
  my $mouse_comment     = param('mouse_comment');
  my $blob_id           = param('file_id');
  my $gene_id           = param('gene_id');
  my $cohort_id         = param('cohort_id');
  my $sex_color         = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my $datetime_now      = get_current_datetime_for_sql();
  my @parameters        = param();                               # read all CGI parameter keys
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my ($mouse_sex, $gene_info, $project_info);
  my ($first_gene_name, $first_genotype);
  my ($current_mating, $parameter, $mouse_comment_sql);
  my @sql_parameters;

  # check input first: a mouse id must be provided and it has to be an 8 digit number: exit on failure
  if (!param('mouse_id') || param('mouse_id') !~ /^[0-9]{8}$/) {

     # so it's not a mouse ID. But if it is a number, we interpret it as a cage ID
     if (param('mouse_id') =~ /^[0-9]+$/) {
        param(-name=>'cage_ids', -value=>param('mouse_id'));
        require 'lib_searching.pl';
        return find_mice_by_cage($global_var_href);
     }

     &error_message_and_exit($global_var_href, "invalid mouse id (must be an 8 digit number).", $sr_name . "-" . __LINE__);
  }

  $page = h2("Mouse details "        . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id", -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'}))
             . "&nbsp;&nbsp;&nbsp;[" . a({-href=>"$url?choice=mouse_details&mouse_id=" . ($mouse_id - 1)}, 'previous')
             . "&nbsp;"              . a({-href=>"$url?choice=mouse_details&mouse_id=" . ($mouse_id + 1)}, 'next')
             . "]"
          )
          . hr();

  ################################################################
  # add mouse to cart if requested
  if (defined(param('job')) && param('job') eq "Add mouse to cart") {
     $page .= add_to_cart($global_var_href);
  }

  ################################################################
  # update comment if requested
  if (defined(param('job')) && param('job') eq "update comment") {

     $mouse_comment_sql = $mouse_comment;
     $mouse_comment_sql =~ s/'|;|-{2}//g;                  # remove dangerous content

     # update mouse comment
     $dbh->do("update  mice
               set     mouse_comment = ?
               where   mouse_id = ?
              ", undef, $mouse_comment_sql, $mouse_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update mouse comment)", $sr_name . "-" . __LINE__);

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdate_mouse_comment\t$mouse_id\tnew:$mouse_comment_sql");
  }

  ################################################################
  # delete attached blob file if requested
  if (defined(param('job')) && param('job') eq "delete_file") {

     if (param('file_id') && param('file_id') =~ /[0-9]+$/) {

        # begin transaction
        $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start file delete transaction)", $sr_name . "-" . __LINE__);

        # delete blob
        $dbh->do("delete
                  from   $blob_database.blob_data
                  where  blob_id = ?
                 ", undef, $blob_id
                ) or &error_message_and_exit($global_var_href, "SQL error (could not delete file)", $sr_name . "-" . __LINE__);

        # delete entry in mice2blob_data
        $dbh->do("delete
                  from   mice2blob_data
                  where      m2b_mouse_id = ?
                         and m2b_blob_id  = ?
                 ", undef, $mouse_id, $blob_id
                ) or &error_message_and_exit($global_var_href, "SQL error (could not delete file)", $sr_name . "-" . __LINE__);

        $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

        &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tdelete_file\tmouse:$mouse_id\tfile:$blob_id");
     }
  }
  ################################################################
  # delete assigned genotype if requested
  if (defined(param('job')) && param('job') eq "delete_genotype") {

     if (param('gene_id') && param('gene_id') =~ /[0-9]+$/) {

        # begin transaction
        $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start genotype delete transaction)", $sr_name . "-" . __LINE__);

        # delete entry in mice2blob_data
        $dbh->do("delete
                  from   mice2genes
                  where      m2g_mouse_id = ?
                         and m2g_gene_id  = ?
                 ", undef, $mouse_id, $gene_id
                ) or &error_message_and_exit($global_var_href, "SQL error (could not delete genotype)", $sr_name . "-" . __LINE__);

        $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

        &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tdelete_genotype\tmouse:$mouse_id\tgene:$gene_id");
     }
  }
  ################################################################
  # remove mouse from cohort if requested
  if (defined(param('job')) && param('job') eq "remove_from_cohort") {

     if (param('cohort_id') && param('cohort_id') =~ /[0-9]+$/) {

        # begin transaction
        $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start remove from cohort transaction)", $sr_name . "-" . __LINE__);

        # delete entry in mice2cohorts
        $dbh->do("delete
                  from   mice2cohorts
                  where      m2co_mouse_id   = ?
                         and m2co_cohort_id  = ?
                 ", undef, $mouse_id, $cohort_id
                ) or &error_message_and_exit($global_var_href, "SQL error (could not remove cohort assignment)", $sr_name . "-" . __LINE__);

        $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

        &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tremove_from_cohort\tmouse:$mouse_id\tcohort:$cohort_id");
     }
  }
  ################################################################

  # query mouse details
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_id, line_name, mouse_comment, mouse_is_gvo, mouse_generation,
                   mouse_origin_type, mouse_import_id, mouse_litter_id, coat_color_name as color,
                   litter_mating_id, litter_id, litter_in_mating,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
                   dr1.death_reason_name as how, dr2.death_reason_name as why
            from   mice
                   join mouse_strains          on             mouse_strain = strain_id
                   join mouse_lines            on               mouse_line = line_id
                   join mice2cages             on                 mouse_id = m2c_mouse_id
                   join cages2locations        on              m2c_cage_id = c2l_cage_id
                   join locations              on              location_id = c2l_location_id
                   join cages                  on                  cage_id = c2l_cage_id
                   join death_reasons dr1      on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2      on  mouse_deathorexport_why = dr2.death_reason_id
                   left join litters           on          mouse_litter_id = litter_id
                   left join mouse_coat_colors on         mouse_coat_color = coat_color_id
            where  mouse_id = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
           );

  @sql_parameters = ($mouse_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # exit if requested mouse not found in database
  unless ($rows > 0) {
     $page .= p("No mouse found test having id $mouse_id.");
     return $page;
  }

  # (else continue...)
  $page .= h3("Details for mouse $mouse_id " . "&nbsp;&nbsp; [" . a({-href=>"$url?choice=edit_mouse_details&mouse_id=" . $mouse_id}, "edit details") . "]")

           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>1, -summary=>"table", -bgcolor=>'#DDFFFF'})

           . Tr(
               th("mouse ID"       ),
               th("ear"            ),
               th("sex"            ),
               th("born"           ),
               th("age"            ),
               th("death"          ),
               th("genotype"       ),
               th("strain"         ),
               th("line"           ),
               th("generation"     ),
               th("color"          ),
               th("is GVO"         ),
               th("room/rack-cage"
                  . br()
                  . a({-href=>"$url?choice=cage_history&mouse_id=" . $mouse_id}, "[cage history]")
               )
             );

  # get first (and only) result line
  $row = $result->[0];

  ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

  # add table row for current mouse
  $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
              td(a({-href=>"$url?choice=mouse_details&mouse_id=". $row->{'mouse_id'}}, &reformat_number($row->{'mouse_id'}, 8))),
              td($row->{'mouse_earmark'}),
              td($row->{'mouse_sex'}),
              td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
              td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
              td({-title=>"$row->{'how'}, $row->{'why'}"}, format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
              td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
              td($row->{'strain_name'}),
              td('&nbsp;' . a({-href=>"$url?choice=line_view&line_id=$row->{'line_id'}", -title=>"click for line details", -target=>'_blank'}, $row->{'line_name'}) . '&nbsp;'),
              td($row->{'mouse_generation'}),
              td($row->{'color'}),
              td('&nbsp;' . $row->{'mouse_is_gvo'} . '&nbsp;'),
              td(((!defined($row->{'mouse_deathorexport_datetime'}))                                                             # check if mouse is alive
                   ?a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"},              # yes: print cage link
                      $row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'})
                   :'-'                                                                                                          # no: don't print cage link
                 )
                )
            ) .
            Tr( td({-colspan=>"2"}, b("experimental" . br() . "status")),
                td({-colspan=>"11"}, get_experimental_status($global_var_href, $row->{'mouse_id'}))
            ) .
            Tr( td({-colspan=>"2"}, b("cost centre" . br() . "status ["
                                      . a({-href=>"$url?choice=cost_centre_overview", -title=>'click to see all cost centres in new window', -target=>'_blank'}, 'help')
                                      . ']'
                                    )
                ),
                td({-colspan=>"11"}, get_cost_account_status($global_var_href, $row->{'mouse_id'}))
            ) .
            Tr( td({-colspan=>"2"}, b("cohorts")),
                td({-colspan=>"11"}, get_cohort_table($global_var_href, $row->{'mouse_id'}))
            ) .
            Tr( td({-colspan=>"2"}, b("carts")),
                td({-colspan=>"11"}, get_carts_table($global_var_href, $row->{'mouse_id'}))
            ) .
            Tr( td({-colspan=>"2"}, b("treatments")),
                td({-colspan=>"11"}, get_treatments_table($global_var_href, $row->{'mouse_id'}))
            ) .
            Tr( td({-colspan=>"2"}, b("phenotyping" . br() . "status")),
                td({-colspan=>"11"}, get_phenotyping_status($global_var_href, $row->{'mouse_id'}))
            ) .
            Tr( td({-colspan=>"2"}, b("phenotyping" . br() . "data")),
                td({-colspan=>"11"}, get_medical_records($global_var_href, $row->{'mouse_id'}))
            ) .
            # only if a cryo database is configured, display this row
            ((defined($cryo_database) && $cryo_database eq 'yes')
             ?Tr( td({-colspan=>"2"}, b("cryo" . br() . "samples")),
                  td({-colspan=>"11"}, get_cryo_samples($global_var_href, $row->{'mouse_id'}))
              )
             :''
            ) .
            # only if an image database is configured, display this row
            ((defined($olympus_database) && $olympus_database eq 'yes')
             ?Tr( td({-colspan=>"2"}, b("images")),
                  td({-colspan=>"11"}, get_olympus_images_link($global_var_href, $row->{'mouse_id'}))
              )
             :''
            ) .
            Tr( td({-colspan=>"2"}, b("comments")),
                td({-colspan=>"11"}, textarea(-name=>"mouse_comment", -columns=>"80", -rows=>"5",
                                              -value=>($row->{'mouse_comment'} ne '')?$row->{'mouse_comment'}:'no comments for this mouse'
                                     )
                                     . br()
                                     . submit(-name => "job", -value=>"update comment")
                )
            );

  $page .= end_table()
           . hr({-align=>'left', -width=>'50%'});

  # print origin information
  $page .= h3("Origin of mouse $mouse_id: ");

  # mating or import?
  if ($row->{'mouse_origin_type'} eq 'weaning') {
     $page .= p(   a({-href=>"$url?choice=litter_view&litter_id=" . $row->{'litter_id'}}, " $row->{'litter_in_mating'}. litter")
                 . " from "
                 . a({-href=>"$url?choice=mating_view&mating_id=" . $row->{'litter_mating_id'}}, "mating " . $row->{'litter_mating_id'})
                 . "&nbsp;&nbsp; (" . a({-href=>"$url?choice=show_ancestors&mouse_id=" . $mouse_id}, 'show ancestors') . ")"
               );
  }
  elsif ($row->{'mouse_origin_type'} eq 'weaning_external') {
     $page .= p(   a({-href=>"$url?choice=litter_view&litter_id=" . $row->{'litter_id'}}, " $row->{'litter_in_mating'}. litter")
                 . " from "
                 . a({-href=>"$url?choice=mating_view&mating_id=" . $row->{'litter_mating_id'}}, "mating " . $row->{'litter_mating_id'})
                 . "&nbsp;&nbsp; (" . a({-href=>"$url?choice=show_ancestors&mouse_id=" . $mouse_id}, 'show ancestors') . ")"
                . b(" (EXTERNAL ANIMAL)")
               );
  }
  elsif ($row->{'mouse_origin_type'} eq 'import') {
     $page .= p(a({-href=>"$url?choice=import_view&import_id=" . $row->{'mouse_import_id'}},  "import " . $row->{'mouse_import_id'}));
  }
  elsif ($row->{'mouse_origin_type'} eq 'import_external') {
     $page .= p(a({-href=>"$url?choice=import_view&import_id=" . $row->{'mouse_import_id'}},  "import " . $row->{'mouse_import_id'})
                . b(" (EXTERNAL ANIMAL)")
              );
  }
  else {
     $page .= p("Origin unclear");
  }

  $page .= hr({-align=>'left', -width=>'50%'});

  # print out breeding record: list all matings in which current mouse was/is parent
  $page .= h3("Breeding record for mouse $mouse_id (all matings in which mouse $mouse_id was/is parent) ")
           . &get_breeding_info($global_var_href, $mouse_id)
           . hr({-align=>'left', -width=>'50%'});

  # print out genotype information: includes all genotypes
  $page .= h3("Genotype information for mouse $mouse_id")
           . &get_gene_info($global_var_href, $mouse_id)
           . hr({-align=>'left', -width=>'50%'});

  # print out properties information: any other attribute information, for example foreign ID
  $page .= h3("Properties/attributes for mouse $mouse_id ")
           . &get_properties_table($global_var_href, $mouse_id)
           . hr({-align=>'left', -width=>'50%'});

  # print out file information: which files are linked to this mouse?
  $page .= h3("Files available for mouse $mouse_id [" . a({-href=>"$url?choice=upload_files_to_mouse&mouse_id=$mouse_id"}, 'upload and attach file(s) to this mouse') . ']')
           . &get_blob_table($global_var_href, $mouse_id);

  # store CGI parameters in hidden fields. Yes, I know, there are better ways to do this, but input from hidden fields will be checked
  foreach $parameter (@parameters) {
     unless ($parameter eq 'mouse_select' || $parameter eq 'job') {
        $page .= hidden(-name=>$parameter, -value=>param("$parameter")) . "\n";
     }
  }

  $page .= hidden(-name=>'mouse_select', -value=>$row->{'mouse_id'}) . "\n"
           . hr()
           . submit(-name => "job", -value=>"Add mouse to cart")
           . hr()
           . h3("What do you want to do with this mouse?");

  # if mouse is alive, offer some options...
  if (!defined($row->{'mouse_deathorexport_datetime'})) {
     $page .=   submit(-name => "job", -value=>"kill")                   . '&nbsp;&nbsp;&nbsp;'
              . submit(-name => "job", -value=>"mate")                   . '&nbsp;&nbsp;&nbsp;'
              . submit(-name => "job", -value=>"genotype")               . '&nbsp;&nbsp;&nbsp;'
              . submit(-name => "job", -value=>"add/change experiment")  . '&nbsp;&nbsp;&nbsp;'
              . submit(-name => "job", -value=>"add/change cost centre") . '&nbsp;&nbsp;&nbsp;'
              . submit(-name => "job", -value=>"order phenotyping");
  }

  # else offer other options
  else {
     $page .=   submit(-name => "job", -value=>"reanimate")              . '&nbsp;&nbsp;&nbsp;'
              . submit(-name => "job", -value=>"mate")                   . '&nbsp;&nbsp;&nbsp;'
              . submit(-name => "job", -value=>"genotype")               . '&nbsp;&nbsp;&nbsp;'
              . submit(-name => "job", -value=>"add treatment");
  }

  $page .= end_form();

  return $page;
}
# end of mouse_details()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE005 show_cart                                    show mice in cart
sub show_cart {                                          my $sr_name = 'SR_VIE005';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};      # get session handle
  my $dbh               = $global_var_href->{'dbh'};          # DBI database handle
  my $username          = $session->param(-name=>'username');
  my $mouse_ids         = '';
  my $sort_column       = param('sort_by');
  my $sort_order        = param('sort_order');
  my $cart_id           = param('cart_id');
  my $subset_size       = param('random_subset_size');
  my $url               = url();
  my $save_message      = '';
  my $rev_order         = {'asc' => 'desc', 'desc' => 'asc'};     # toggle table
  my $sex_color         = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my @loaded_mice       = ();
  my @xls_row           = ();
  my @random_subset     = ();
  my %random_mice       = ();
  my @total_set         = ();
  my @random_mouse_list = ();
  my @parameters        = param();
  my ($excel_sheet, $local_filename, $data, $parameter, $cart_name, $count_loaded);
  my ($page, $sql, $result, $rows, $row, $i);
  my ($line_name, $id, $sql_mouse_list, $short_comment, $current_mating, $random_mouse, $total_mice);
  my ($first_gene_name, $first_genotype);
  my @id_list;
  my @sql_id_list;
  my @sql_parameters;

  # hide real database column names from user (security issue)
  my $columns  = {'id'  => 'mouse_id', 'earmark' => 'mouse_earmark',  'dob' => 'mouse_birth_datetime', 'genotype' => 'm2g_genotype',
                  'sex' => 'mouse_sex', 'strain' => 'strain_name',   'line' => 'line_name',            'location' => 'cage_name',
                  'dod' => 'mouse_deathorexport_datetime', 'cage' => 'cage_id', 'rack' => 'concat(location_room,location_rack)'};

  # add selected mice to cart
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href);
  }

  # check if cart has to be emptied. If so, just clear session value for cart
  if (defined(param('job')) && param('job') eq "Empty cart") {
     $session->clear(["cart"]);
  }

  # check if selected mice have to be removed from cart
  if (defined(param('job')) && param('job') eq "Remove selected from cart") {
     $save_message = remove_from_cart($global_var_href);
  }

  # check if males have to be removed from cart
  if (defined(param('job')) && param('job') eq "Remove males from cart") {
     $save_message = remove_males_from_cart($global_var_href);
  }

  # check if females have to be removed from cart
  if (defined(param('job')) && param('job') eq "Remove females from cart") {
     $save_message = remove_females_from_cart($global_var_href);
  }

  # check if selected mice have to be kept (remove all but those which are selected)
  if (defined(param('job')) && param('job') eq "Keep selected in cart") {
     $save_message = keep_in_cart($global_var_href);
  }

  # check if cart has to be saved
  if (defined(param('job')) && param('job') eq "Save cart") {
     $save_message = save_cart($global_var_href);
  }

  #------------------------------------
  # check if cart has to be exported to Excel
  if (defined(param('job')) && param('job') eq "Export cart to Excel") {
     # include a module to write tables as Excel file in a simple way
     use Spreadsheet::WriteExcel::Simple;

     # create a new excel sheet object
     $excel_sheet = Spreadsheet::WriteExcel::Simple->new;

     # create a unique filename (using combination of user name and time) for server-side storage of temporary Excel file
     $local_filename = $username . '_' . time() . '.xls';

     # header line
     @xls_row = ('number', 'mouse_id', 'ear', 'sex', 'born', 'age', 'death', 'strain', 'line', 'room/rack', 'cage', 'comment', 'pathoID', 'locus', 'genotype');

     # write header line to Excel file
     $excel_sheet->write_row(\@xls_row);
  }
  #------------------------------------

  # make sure a sort column is defined
  if (!param('sort_by')) {
     $sort_column = 'id';
  }
  # raise error if invalid sort column given
  elsif (!defined($columns->{$sort_column})) {
     $page = p({-class=>"red"}, b("Error: invalid sort column $sort_column"));
     return $page;
  }

  # if sort order is given and 'desc': set it to 'desc'
  if (param('sort_order') && param('sort_order') eq 'desc') {
     $sort_order = 'desc';
  }
  # else default to 'asc'
  else {
     $sort_order = 'asc';
  }

  #------------------------------------
  # check if there is a cart to be restored
  if (!defined(param('job')) && defined(param('choice')) && (param('choice') eq 'restore_cart') && defined(param('cart_id')) && (param('cart_id') =~ /^[0-9]+$/)) {
     # if so, load mice from stored cart
     ($mouse_ids, $cart_name) = $dbh->selectrow_array("select cart_content, cart_name
                                                       from   carts
                                                       where  cart_id = $cart_id
                                                      ");

     # mouse ids in stored cart are comma-separated, so need to split back into array
     @loaded_mice = split(/\W/, $mouse_ids);
     $count_loaded = scalar @loaded_mice;            # how many mice in uploaded cart?

     # notification
     $save_message = p("Added $count_loaded mice from previously stored cart " . b($cart_name) . ": ")
                     . p(join(", ", @loaded_mice)) . hr();
  }
  #------------------------------------

  # read current cart content from session ...
  $mouse_ids = $session->param('cart');

  # if there are mice in session, check cart content for being mouse ids ...
  if (defined($mouse_ids) and $mouse_ids ne '') {
     @id_list = split(/\W/, $mouse_ids);
     foreach $id (@id_list) {
       if ($id =~ /^[0-9]{8}$/) {
          push(@sql_id_list, $id);
       }
     }
  }

  # copy the list of all mice in the cart
  @total_set = @sql_id_list;

  #------------------------------------
  # check if random selection requested
  if (defined(param('job')) && param('job') eq "select random subset") {
     # initialize the random number generator
     srand();

     # loop number equals the number of mice to be randomly selected (given subset size)
     for ($i=1; $i<=$subset_size; $i++) {
         $total_mice   = scalar (@total_set);                           # number of mice left (not yet selected randomly)
         $random_mouse = $total_set[int(rand($total_mice))];            # pick a mouse using a random array index number
         push(@random_subset, $random_mouse);                           # collect randomly collected mice
         @total_set = remove_from_list($random_mouse, \@total_set);     # reduce the mouse list by the mouse just picked in this loop
         push(@random_mouse_list, b($i) . ':' . $random_mouse);
     }

     $save_message = p("Randomly selected $subset_size out of " . (scalar @sql_id_list) . " mice")
                     . p("In random order: " . join(', ', @random_mouse_list))
                     . hr();
  }
  #------------------------------------

  #------------------------------------
  # check if mouse list requested
  if (defined(param('job')) && param('job') eq "create mouse list") {

     $save_message = p((scalar @sql_id_list) . " mice in cart as comma-separated list (in ascending order): ")
                     . p(join(', ', sort @sql_id_list))
                     . hr();
  }
  #------------------------------------

  # join session cart with restored cart
  push(@sql_id_list, @loaded_mice);

  # make the list non-redundant
  @sql_id_list = unique_list(@sql_id_list);

  # serialize list
  $mouse_ids = join(",", @sql_id_list);

  # after combining mice from session cart and from restored cart, save non-empty list to session
  if ($mouse_ids ne '') {
     # store it to session
     $session->param(-name=>'cart', -value=>"$mouse_ids");
  }

  # now check again if cart is empty. If so, tell user and exit
  if (!defined($session->param('cart')) ) {
     $page .= h2(qq(Your mouse "shopping cart" ) . a({-href=>"$url?choice=show_cart", -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})))
              . hr()
              . p(qq(Your mouse "shopping cart" is empty.))
              . hr()
              . start_form(-action=>url(), -name=>"myform")
              . hidden(-name=>"own_carts_only", -value=>"y")
              . submit(-name=>"job", -value=>"Load cart")
              . end_form();
     return $page;
  }

  # (else continue...)

  # convert the list of mouse ids to an SQL-compatible expression: '30000001','30000002',...
  $sql_mouse_list = qq(') . join(qq(','), @sql_id_list) . qq(');

  $page .= h3(qq(Your mouse "shopping cart" ) . a({-href=>"$url?choice=show_cart", -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})))
           . hr()
           . $save_message;

  # collect some details about mice in cart
  $sql = qq(select distinct mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
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
                   left join mice2genes    on                 mouse_id = m2g_mouse_id
            where  mouse_id in ($sql_mouse_list)
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
            order  by $columns->{$sort_column} $sort_order
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sql . $sr_name . "-" . __LINE__ );

  # if mice from cart cannot be found in database (should not happen): tell user and exit
  unless ($rows > 0) {
     $page .= p("No mice found having matching ids from your shopping cart. This is a strange situation that should not happen")
              . p("Please press the \"Empty card\" button below to clear cart. This will only clear the cart and not affect in any way mice in the database.")
              . br()
              . start_form(-action=>url(), -name=>"myform")
              . hidden(-name=>"choice")
              . submit(-name=>"job", -value=>"Empty cart")
              . end_form();
     return $page;
  }

  # proceed with displaying details about mice in cart
  $page .= p(b("There " . (($rows == 1)?'is':'are' ) . " $rows " . (($rows == 1)?'mouse':'mice' ) . qq( in your "shopping cart")))
           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=id",       -title=>"click to sort by mouse id, click again to change sort order"},       "mouse ID")      ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=earmark",  -title=>"click to sort by earmark, click again to change sort order"},        "ear")           ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=sex",      -title=>"click to sort by sex, click again to change sort order"},            "sex")           ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=dob",      -title=>"click to sort by date of birth, click again to change sort order"},  "born")          ),
               th(span({-title=>"To sort by age, click on column header \"born\""}, "age")),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=dod",      -title=>"click to sort by date of death, click again to change sort order"},  "death")         ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=genotype", -title=>"click to sort by genotype, click again to change sort order"},       "genotype")      ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=strain",   -title=>"click to sort by strain, click again to change sort order"},         "strain")        ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=line",     -title=>"click to sort by line, click again to change sort order"},           "line")          ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=rack",     -title=>"click to sort by rack, click again to change sort order"},           "room/rack")
                . ' / '
                . a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=cage",     -title=>"click to sort by cage, click again to change sort order"},           "cage")
               ),
               th("comment (shortened)")
             );

  # loop over all mice in cart
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     @xls_row = ();

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     # if export to excel was requested, in addition to generate table row for display also generate row for Excel
     if (defined(param('job')) && param('job') eq "Export cart to Excel") {
        @xls_row = (($i+1),
                    $row->{'mouse_id'},
                    $row->{'mouse_earmark'},
                    $row->{'mouse_sex'},
                    format_datetime2simpledate($row->{'mouse_birth_datetime'}),
                    get_age_in_days($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'}),
                    (defined($row->{'mouse_deathorexport_datetime'})?format_datetime2simpledate($row->{'mouse_deathorexport_datetime'}):'-'),
                    $row->{'strain_name'},
                    $row->{'line_name'},
                    ((!defined($row->{'mouse_deathorexport_datetime'}))                                                             # check if mouse is alive
                     ?$row->{'location_room'} . '/' . $row->{'location_rack'}
                     :'-'
                    ),
                    ((!defined($row->{'mouse_deathorexport_datetime'}))                                                             # check if mouse is alive
                     ?$row->{'cage_id'}
                     :'-'
                    ),
                    ((defined($current_mating))
                     ?qq((in mating $current_mating))
                     :''
                    )
                    . $row->{'mouse_comment'},
                    get_pathoID($global_var_href, $row->{'mouse_id'}),
                    &get_all_genotypes_in_one_line($global_var_href, $row->{'mouse_id'})
                   );

        # write current row to Excel object
        $excel_sheet->write_row(\@xls_row);
     }

     # shorten comment to fit on page
     if (defined($row->{'mouse_comment'}) && $row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
     }
     elsif (!defined($row->{'mouse_comment'})) {
        $short_comment = '';
     }
     else {
        $short_comment = $row->{'mouse_comment'};
     }

     $short_comment =~ s/^'(.*)'$/$1/g;

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current line
     $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                td($i+1),
                td(checkbox(-name=>'mouse_select', -id=>$row->{'mouse_id'}, -value=>$row->{'mouse_id'}, -label=>'', -override=>1,
                            -checked=>((is_in_list($row->{'mouse_id'}, \@random_subset) == 1)?1:0)                                  # check box if mouse is in list of randomly picked mice
                   )
                ),
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
                  ),
                td({-align=>'left'},
                   ((defined($current_mating))
                    ?"(in mating " . a({-href=>"$url?choice=mating_view&mating_id=$current_mating"}, $current_mating)
                       . ' ' . get_transfer_info($global_var_href, $current_mating) . ') '
                    :''
                   )
                   . $short_comment
                )
              );
  }

  # print bottom navigation bar
  $page .= Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall2", -label=>"", -onClick=>"checkAll2(document.myform)", -title=>"select/unselect all")),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=id",       -title=>"click to sort by mouse id, click again to change sort order"},       "mouse ID")      ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=earmark",  -title=>"click to sort by earmark, click again to change sort order"},        "ear")           ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=sex",      -title=>"click to sort by sex, click again to change sort order"},            "sex")           ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=dob",      -title=>"click to sort by date of birth, click again to change sort order"},  "born")          ),
               th(span({-title=>"To sort by age, click on column header \"born\""}, "age")),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=dod",      -title=>"click to sort by date of death, click again to change sort order"},  "death")         ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=genotype", -title=>"click to sort by genotype, click again to change sort order"},       "genotype")      ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=strain",   -title=>"click to sort by strain, click again to change sort order"},         "strain")        ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=line",     -title=>"click to sort by line, click again to change sort order"},           "line")          ),
               th(a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=rack",     -title=>"click to sort by rack, click again to change sort order"},           "room/rack")
                . ' / '
                . a({-href=>"$url?choice=show_cart&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=cage",     -title=>"click to sort by cage, click again to change sort order"},           "cage")
               ),
               th("comment (shortened)")
           )
           . end_table()
           . p();

  # if export to excel was requested ...
  if (defined(param('job')) && param('job') eq "Export cart to Excel") {
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
  }

  # store CGI parameters in hidden fields. Yes, I know, there are better ways to do this, but input from hidden fields will be checked
  foreach $parameter (@parameters) {
     unless ($parameter eq 'mouse_select' || $parameter eq 'job' || $parameter eq 'cart_name' || $parameter eq 'random_subset_size') {
        $page .= hidden(-name=>$parameter, -value=>param("$parameter")) . "\n";
     }
  }

  $page .=   submit(-name=>"job",          -value=>"Empty cart")                . '&nbsp;&nbsp;&nbsp;'
           . submit(-name=>"job",          -value=>"Remove selected from cart") . '&nbsp;&nbsp;&nbsp;'
           . submit(-name=>"job",          -value=>"Keep selected in cart")     . '&nbsp;&nbsp;&nbsp;'
           . submit(-name=>"job",          -value=>"Remove males from cart")    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name=>"job",          -value=>"Remove females from cart")  . '&nbsp;&nbsp;&nbsp;'
           . p()
           . p(b("cart name ")
               . textfield(-name=>"cart_name", -value=>'cart_' . $session->param(-name=>'username') . '_' . get_current_date_for_display(), -size=>30, -onFocus=>"this.select();")
               . '&nbsp;&nbsp;&nbsp;'
               . b("public? ")
               . checkbox(-name=>'cart_is_public', -checked=>0, -value=>'y', -label=>'')
               . submit(-name=>"job",          -value=>"Save cart") . b('or') . '&nbsp;&nbsp;&nbsp;'
               . submit(-name=>"job",          -value=>"Load cart") . '&nbsp;&nbsp;&nbsp;' . b('or') . '&nbsp;&nbsp;&nbsp;'
               . submit(-name=>"job",          -value=>"Export cart to Excel")
             )
           . hr()
           . h3("What do you want to do with mice selected above?")
           . p(  submit(-name => "job", -value=>"kill")                   . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"mate")                   . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"embryotransfer")         . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"genotype")               . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"assign coat color")      . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"add/change experiment")  . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"add/change cost centre") . '&nbsp;&nbsp;&nbsp;'
             )
           . p(  submit(-name => "job", -value=>"order phenotyping")      . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"view phenotyping data")  . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"append comment")         . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"build a cohort")         . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"upload and link file to selected mice")
             )
           . p(  submit(-name => "job", -value=>"add treatment")          . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"delete comments")        . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"move selected mice")     . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"apply R script")
             )
           . p(  popup_menu(-name => 'random_subset_size', -values  => [1..($rows-1)], -default=>1)
               . submit(-name => "job", -value=>"select random subset")   . '&nbsp;&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"create mouse list")
             )
           . end_form();

  return $page;
}
# end of show_cart
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE006 show_cage                                    show a cage
sub show_cage {                                          my $sr_name = 'SR_VIE006';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $cage_id           = param('cage_id');
  my $card_color        = param('card_color');
  my $url               = url();
  my $sex_color         = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my @parameters        = param();                                # read all CGI parameter keys
  my ($page, $sql, $result, $rows, $row, $i);
  my ($gene_info, $project_info, $card_color_sql, $parameter);
  my ($current_mating, $short_comment, $color_code, $first_gene_name, $first_genotype);
  my @sql_parameters;

  # check input "cage_id": is it given at all ? is it a number? On failure, exit
  if (!param('cage_id') || param('cage_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: Please enter a valid cage ID (1-8 digits, for example: 1234)."));
     return $page;
  }

  $page = start_form(-action => url())
          . h2("Cage view " . a({-href=>"$url?choice=cage_view&cage_id=$cage_id", -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'}))
             . "&nbsp;&nbsp;&nbsp;or view another cage "
             . textfield(-name => "cage_ids", -size=>"20", -maxlength=>"30", -title=>"enter cage number(s) separated with blanks")
             . submit(-name => "choice", -value=>"Search cage(s)")
            )
          . end_form()
          . hr();

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href);
  }

  # update cage color if requested
  if (defined(param('job')) && param('job') eq "update color") {

     $card_color_sql = $card_color;
     $card_color_sql =~ s/'|;|-{2}//g;                  # remove dangerous content

     # update mouse comment
     $dbh->do("update  cages
               set     cage_cardcolor = ?
               where   cage_id = ?
              ", undef, $card_color_sql, $cage_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update cage color)", $sr_name . "-" . __LINE__);
  }

  # query detailed info about chosen cage and mice in that cage
  $sql = qq(select c2l_cage_id, cage_capacity, cage_cardcolor,
                   mouse_id, mouse_earmark, mouse_sex, strain_name, line_id, line_name, mouse_is_gvo, mouse_comment, location_id, location_room, location_rack, cage_id,
                   mouse_birth_datetime, mouse_deathorexport_datetime, project_shortname
            from   cages2locations
                   join locations          on c2l_location_id = location_id
                   join cages              on         cage_id = c2l_cage_id
                   join mice2cages         on     m2c_cage_id = cage_id
                   join mice               on    m2c_mouse_id = mouse_id
                   join mouse_strains      on    mouse_strain = strain_id
                   join mouse_lines        on      mouse_line = line_id
                   left join projects      on location_project = project_id
            where  m2c_cage_id = ?
                   and c2l_datetime_to IS NULL
                   and m2c_datetime_to IS NULL
                   and mouse_deathorexport_datetime IS NULL
            order  by mouse_id asc
           );

  @sql_parameters = ($cage_id);

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no such cage found or no mice in that cage found (the latter one should not happen, as there should be no empty cages)
  unless ($rows > 0) {
     $page .= p("Cage " . $cage_id . " currently not in use");
     return $page;
  }

  $color_code = get_cage_color_by_id($global_var_href, $result->[0]->{'cage_cardcolor'});

  # (else continue ...)
  $page .= h3("Cage " . $cage_id . " (placed in rack "
              . a({-href=>"$url?choice=location_details&location_id=" . $result->[0]->{'location_id'}}, "$result->[0]->{'location_room'}/$result->[0]->{'location_rack'}")
              . ", $result->[0]->{'project_shortname'}) contains $rows " . (($rows == 1)?'mouse':'mice' ))
           . p(
             a({-href=>"$url?choice=print_card&cage_id=$cage_id", -target=>"_blank"}, "print cage card" )
                         . '&nbsp;&nbsp;&nbsp;'
                         . a({-href => "$url?choice=move_cage&cage_id=$cage_id"}, "move cage")
                         . '&nbsp;&nbsp;&nbsp;'
                         . a({-href => "$url?choice=history_of_cage&cage_id=$cage_id"}, "rack history of cage ID")
            )

           . start_form(-action=>url(), -name=>"myform")

           . p(b("Current cage color: ") . span({-style=>"background-color: $color_code;"}, '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;')
               . '&nbsp;&nbsp;'
               . b("Change to: ")
               . get_cage_color_popup_menu($global_var_href, $result->[0]->{'cage_cardcolor'})
               . '&nbsp;&nbsp;'
               . submit(-name => "job", -value=>"update color")
             )

           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th("mouse ID"),
               th("ear"),
               th("sex"),
               th("born"),
               th("age"),
               th("death"),
               th("genotype"),
               th("strain"),
               th("line"),
               th("room/rack-cage"),
               th("comment (shortened)"),
               th("move mouse")
             );

  # loop over all mice
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # shorten comment to fit on page
     if (defined($row->{'mouse_comment'}) && $row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
     }
     else {
        $short_comment = $row->{'mouse_comment'};
     }

     $short_comment =~ s/^'(.*)'$/$1/g;

     # add table row for current line
     $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                td($i+1),
                td(checkbox('mouse_select', '0', $row->{'mouse_id'}, '')),
                td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                td($row->{'mouse_earmark'}),
                td($row->{'mouse_sex'}),
                td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                td(format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
                td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
                td($row->{'strain_name'}),
                td('&nbsp;' . a({-href=>"$url?choice=line_view&line_id=" . $row->{'line_id'}}, $row->{'line_name'}) . '&nbsp;'),
                td((!defined($row->{'mouse_deathorexport_datetime'}))?$row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'}:'-'),
                td({-align=>'left'},
                   ((defined($current_mating))
                    ?"(in mating " . a({-href=>"$url?choice=mating_view&mating_id=$current_mating"}, $current_mating)
                       . ' ' . get_transfer_info($global_var_href, $current_mating) . ') '
                    :''
                   )
                   . $short_comment
                ),
                td({-bgcolor=>"#EEEEEE"}, a({-href=>"$url?choice=move_mouse&mouse_id=" . $row->{'mouse_id'}, -title=>"click to move mouse"}, "move mouse"))
              );
  }

  $page .= end_table()
           . p();

  # store CGI parameters in hidden fields. Yes, I know, there are better ways to do this, but input from hidden fields will be checked
  foreach $parameter (@parameters) {
     unless ($parameter eq 'mouse_select' || $parameter eq 'job') {
        $page .= hidden(-name=>$parameter, -value=>param("$parameter")) . "\n";
     }
  }

  $page .= submit(-name => "job", -value=>"Add selected mice to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")               . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre") . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")
           . end_form();

  return $page;
}
# end of show_cage
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE007 gene_details                                 show gene details
sub gene_details {                                       my $sr_name = 'SR_VIE007';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $gene_id           = param('gene_id');
  my $url               = url();
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my ($page, $sql, $result, $rows, $row, $i);
  my ($gene_name, $gene_shortname, $gene_description, $displayed_link, $real_link, $genotype_qualifiers);
  my @sql_parameters;

  # check input "gene_id": is it given at all ? is it a number?
  if (!param('gene_id') || param('gene_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: Please enter a valid gene"));
     return $page;
  }

  # get some basic gene info (name, short name, description) by gene_id
  $sql = qq(select gene_name, gene_shortname, gene_description, gene_valid_qualifiers
            from   genes
            where  gene_id = ?
           );

  @sql_parameters = ($gene_id);

  ($gene_name, $gene_shortname, $gene_description, $genotype_qualifiers) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  ######################################################################################################################################
  # check if a custom link is to be added
  if (param('job') && param('job') eq 'Add gene link') {
     if (!param('gene_link') || param('gene_link') eq '') {
        $page = h2(qq(Gene details: "$gene_name"))
                . hr()
                . p({-class=>"red"}, b("Error: please enter a link!"));
        return $page;
     }

     if (!param('link_description') || param('link_description') eq '') {
        $page = h2(qq(Gene details: "$gene_name"))
                . hr()
                . p({-class=>"red"}, b("Error: please enter a description!"));
        return $page;
     }

     ############################################################################################
     # add a link to an external database
     $dbh->do("insert
               into   genes2externalDBs (g2e_gene_id, g2e_externalDB_id, g2e_description, g2e_id_in_externalDB, g2e_externalDB_URL, g2e_local_URL)
               values (?, ?, ?, ?, ?, NULL)"
             , undef, $gene_id, 1, $dbh->quote(param('link_description')), $dbh->quote(param('gene_link')), $dbh->quote(param('gene_link'))
             ) or &error_message_and_exit($global_var_href, "SQL error (could not add gene link)", $sr_name . "-" . __LINE__);
     ############################################################################################
  }
  ######################################################################################################################################

  $page = h2(qq(Gene details: "$gene_name"))
          . hr();


  $page .= h3("Basic information") .
           table( {-border=>1, -summary=>"table"},
                Tr(
                  th("gene name"),
                  td($gene_name)
                ),
                Tr(
                  th("gene short name"),
                  td($gene_shortname)
                ),
                Tr(
                  th("gene description"),
                  td($gene_description)
                ),
                Tr(
                  th("valid genotype qualifiers for this gene"),
                  td($genotype_qualifiers)
                )
           );

  $page .= p()
           . h3("External links");

  # now collect external links
  $sql = qq(select g2e_description, g2e_externalDB_URL, g2e_id_in_externalDB
            from   genes2externalDBs
            where  g2e_gene_id = ?
           );

  @sql_parameters = ($gene_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if there are no links for this gene, tell user
  if ($rows == 0) {
     $page .= p("no external links for this gene");
  }
  else {
     # (otherwise continue displaying these links ...)
     $page .= start_table( {-border=>1, -summary=>"table"})
              . Tr(
                  th(" description  "),
                  th(" link or info ")
                );

     # loop over all links found for current gene
     for ($i=0; $i<$rows; $i++) {
        $row = $result->[$i];                # fetch next row

        # remove quoting marks
        $displayed_link = $row->{'g2e_externalDB_URL'};
        $displayed_link =~ s/'+//g;

        $real_link = $row->{'g2e_externalDB_URL'};
        $real_link =~ s/'+//g;

        $gene_description = $row->{'g2e_description'};
        $gene_description =~ s/'+//g;

        # add table row for current line
        $page .= Tr({-align=>'center'},
                   td($gene_description),
                   td(($displayed_link =~ /^http/)?a({-href=>"$displayed_link"}, $displayed_link):$displayed_link)
                 );
     }

     $page .= end_table();
  }

  $page .= p()
           . h3("Add an own link")
           . start_form(-action => url())
           . hidden('choice') . hidden('gene_id')
           . table( {-border=>1},
               Tr( th("link description"),
                   td(textfield(-name=>"link_description", -size=>"60", -maxlength=>"100", -title=>"a description for your link",    -override=>1))
                 ) .
               Tr( th("gene link "),
                   td(textfield(-name=>"gene_link",        -size=>"60", -maxlength=>"100", -title=>"enter a gene link or an other information", -override=>1))
                 )
             )
           . br()
           . submit(-name => "job", -value=>"Add gene link")
           . end_form();

  return $page;
}
# end of gene_details
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE008 import_view                                  show import details
sub import_view {                                        my $sr_name = 'SR_VIE008';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};           # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $dbh               = $global_var_href->{'dbh'};               # DBI database handle
  my $import_id         = param('import_id');
  my $sort_column       = param('sort_by');
  my $sort_order        = param('sort_order');
  my $import_comment    = param('import_comment');
  my $url               = url();
  my $previous_litter   = 0;
  my $rev_order         = {'asc' => 'desc', 'desc' => 'asc'};  # toggle table
  my $sex_color         = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my $datetime_now      = get_current_datetime_for_sql();
  my @parameters        = param();                             # read all CGI parameter keys
  my ($page, $sql, $result, $rows, $row, $i);
  my ($parameter, $owners, $import_comment_sql, $first_gene_name, $first_genotype);
  my @sql_parameters;

  # hide real database column names from user (security issue)
  my $columns  = {'id'  => 'mouse_id', 'earmark' => 'mouse_earmark', 'dob' => 'mouse_birth_datetime', 'genotype' => 'm2g_genotype',
                  'sex' => 'mouse_sex', 'strain' => 'strain_name',  'line' => 'line_name',            'location' => 'cage_name',
                  'dod' => 'mouse_deathorexport_datetime'};

  # check input: is import id given? is it a number? On failure, exit
  if (!param('import_id') || param('import_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid import id"));
     return $page;
  }

  # update comment if requested
  if (defined(param('job')) && param('job') eq "update import comment") {

     $import_comment_sql = $import_comment;
     $import_comment_sql =~ s/'|;|-{2}//g;                  # remove dangerous content

     # update import comment
     $dbh->do("update  imports
               set     import_comment = ?
               where   import_id = ?
              ", undef, $import_comment_sql, $import_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update mating comment)", $sr_name . "-" . __LINE__);

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdate_import_comment\t$import_id\tnew:$import_comment_sql");
  }

  # make sure a sort column is defined
  if (!param('sort_by')) {
     $sort_column = 'id';
  }
  # raise error if invalid sort column given
  elsif (!defined($columns->{$sort_column})) {
     $page = p({-class=>"red"}, b("Error: invalid sort column $sort_column"));
     return $page;
  }

  # if sort order is given and 'desc': set it to 'desc'
  if (param('sort_order') && param('sort_order') eq 'desc') {
     $sort_order = 'desc';
  }
  # else default to 'asc'
  else {
     $sort_order = 'asc';
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href);
  }

  # get owners of this import
  $sql = qq(select contact_id, contact_title, contact_first_name, contact_last_name
            from   imports2contacts
                   join contacts on i2c_contact_id = contact_id
            where  i2c_import_id = ?
           );

  @sql_parameters = ($import_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no owners defined, tell
  unless ($rows > 0) {
    $owners = 'no owners defined';
  }

  # otherwise, list owners (with links)
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $owners .= a({-href=>"$url?choice=contact_view&contact_id=" . $row->{'contact_id'}}, "$row->{'contact_title'} $row->{'contact_first_name'} $row->{'contact_last_name'}")
                 . br();
  }

  # first table (basic import data)
  $page .= h2(qq(Import details ) . "&nbsp;&nbsp;&nbsp;" . a({-href=>"$url?choice=import_view&import_id=" . ($import_id - 1)}, 'previous') . "&nbsp;" . a({-href=>"$url?choice=import_view&import_id=" . ($import_id + 1)}, 'next'))
           . hr();

  # query import details
  $sql = qq(select import_id, import_name, import_type, import_datetime, import_purpose, import_comment, import_provider_name,
                   c2.contact_id as provider_id, c2.contact_title as provider_title,
                   c2.contact_first_name as provider_first_name, c2.contact_last_name as provider_last_name,
                   user_name, user_id, user_contact, strain_name, line_name, project_name, healthreport_id
            from   imports
                   join mouse_strains      on               strain_id = import_strain
                   join mouse_lines        on                 line_id = import_line
                   left join contacts c2   on import_provider_contact = c2.contact_id
                   left join users         on       import_coach_user = user_id
                   join projects           on              project_id = import_project
                   left join healthreports on     import_healthreport = healthreport_id
            where  import_id = ?
           );

  @sql_parameters = ($import_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no such import, tell
  unless ($rows > 0) {
     $page .= p("No details on this import");
     return $page;
  }

  # otherwise, get result handle and display import details
  $row = $result->[0];

  $page .= h3(qq(Import $import_id details))
           . start_form(-action=>url(), -name=>"myform")
           . table( {-border=>1, -summary=>"table", -bgcolor=>'#DDFFFF'},
               Tr(
                 th("Import number"),
                 td($row->{'import_id'})
               ),
               Tr(
                 th("Import name"),
                 td(qq("$row->{'import_name'}"))
               ),
               Tr(
                 th("Strain"),
                 td($row->{'strain_name'})
               ),
               Tr(
                 th("Line"),
                 td($row->{'line_name'})
               ),
               Tr(
                 th("Project"),
                 td($row->{'project_name'})
               ),
               Tr(
                 th("Import type"),
                 td($row->{'import_type'})
               ),
               Tr(
                 th("Date of import"),
                 td(format_datetime2simpledate($row->{'import_datetime'}))
               ),
               Tr(
                 th("Import purpose"),
                 td($row->{'import_purpose'})
               ),
               Tr(
                 th("Owner"),
                 td($owners)
               ),
               Tr(
                 th("Provider name"),
                 td($row->{'import_provider_name'})
               ),
               Tr(
                 th("Provider"),
                 td((defined($row->{'provider_id'}))?a({-href=>"$url?choice=contact_view&contact_id=" . $row->{'provider_id'}}, $row->{'provider_title'} . ' ' . $row->{'provider_first_name'} . ' ' . $row->{'provider_last_name'}):'-')
               ),
               Tr(
                 th("Import by"),
                 td((defined($row->{'user_name'}))?a({-href=>"$url?choice=user_details&user_id=" . $row->{'user_id'}, -title=>"MausDB user who is responsible for the mice"}, $row->{'user_name'}):'-')
               ),
               Tr(
                 th("Healthreports"),
                 td((defined($row->{'healthreport_id'}))?a({-href=>"$url?choice=healthreport_view&healthreport_id=" . $row->{'healthreport_id'}, -title=>"Link to health report", -target=>"_blank"}, "show health reports "):' no health report available ')
               ),
               Tr(
                 th("Import comment"),
                 td(textarea(-name=>"import_comment", -columns=>"40", -rows=>"5",
                             -value=>($row->{'import_comment'} ne qq(''))?$row->{'import_comment'}:'-'
                    )
                    . br()
                    . submit(-name => "job", -value=>"update import comment")
                 )
               )
             )
           . hr({-align=>'left', -width=>'50%'});


  # second table (import mates, all mice from that import)
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment, mouse_import_litter_group,
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
            where  mouse_origin_type in (?, ?)
                   and mouse_import_id = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
            order  by mouse_import_litter_group, $columns->{$sort_column} $sort_order
           );

  @sql_parameters = ('import', 'import_external', $import_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no mice from import (strange, should not happen), tell
  unless ($rows > 0) {
     $page .= p("No mice found from this import");
     return $page;
  }

  # otherwise display mice from this import
  $page .= h3("Mice/mouse from this import")

           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th(a({-href=>"$url?choice=import_view&import_id=" . $import_id . "&sort_order=$rev_order->{$sort_order}&sort_by=id",       -title=>"click to sort by mouse id, click again to change sort order"},       "mouse ID")      ),
               th(a({-href=>"$url?choice=import_view&import_id=" . $import_id . "&sort_order=$rev_order->{$sort_order}&sort_by=earmark",  -title=>"click to sort by earmark, click again to change sort order"},        "ear")           ),
               th(a({-href=>"$url?choice=import_view&import_id=" . $import_id . "&sort_order=$rev_order->{$sort_order}&sort_by=sex",      -title=>"click to sort by sex, click again to change sort order"},            "sex")           ),
               th(a({-href=>"$url?choice=import_view&import_id=" . $import_id . "&sort_order=$rev_order->{$sort_order}&sort_by=dob",      -title=>"click to sort by date of birth, click again to change sort order"},  "born")          ),
               th(span({-title=>"To sort by age, click on column header \"born\""}, "age")),
               th(a({-href=>"$url?choice=import_view&import_id=" . $import_id . "&sort_order=$rev_order->{$sort_order}&sort_by=dod",      -title=>"click to sort by date of death, click again to change sort order"},  "death")         ),
               th(a({-href=>"$url?choice=import_view&import_id=" . $import_id . "&sort_order=$rev_order->{$sort_order}&sort_by=genotype", -title=>"click to sort by genotype, click again to change sort order"},       "genotype")      ),
               th(a({-href=>"$url?choice=import_view&import_id=" . $import_id . "&sort_order=$rev_order->{$sort_order}&sort_by=strain",   -title=>"click to sort by strain, click again to change sort order"},         "strain")        ),
               th(a({-href=>"$url?choice=import_view&import_id=" . $import_id . "&sort_order=$rev_order->{$sort_order}&sort_by=line",     -title=>"click to sort by line, click again to change sort order"},           "line")          ),
               th(a({-href=>"$url?choice=import_view&import_id=" . $import_id . "&sort_order=$rev_order->{$sort_order}&sort_by=location", -title=>"click to sort by cage, click again to change sort order"},           "room/rack-cage"))
             );

  # loop over all mice from this import
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # add separator line if litter_group changes
     if (defined($row->{'mouse_import_litter_group'}) && $row->{'mouse_import_litter_group'}!= $previous_litter) {
        $page .= Tr(
                   td({-colspan=>"12"},"known littermates")
                 );
     }

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current line
     $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                td($i+1),
                td(checkbox('mouse_select', '0', $row->{'mouse_id'}, '')),
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
                    ?a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"},     # yes: print cage link
                       $row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'})
                    :'-'                                                                                                          # no: don't print cage link
                  )
              );

     if (defined($row->{'mouse_import_litter_group'})) {
        $previous_litter = $row->{'mouse_import_litter_group'};
     }
  }

  $page .= end_table()
           . p();

  # store CGI parameters in hidden fields. Yes, I know, there are better ways to do this, but input from hidden fields will be checked
  foreach $parameter (@parameters) {
     unless ($parameter eq 'mouse_select' || $parameter eq 'job') {
        $page .= hidden(-name=>$parameter, -value=>param("$parameter")) . "\n";
     }
  }

  $page .=   submit(-name => "job", -value=>"Add selected mice to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")               . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")
           . end_form();

  return $page;
}
# end of import_view
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE009 contact_view                                 show contact details
sub contact_view {                                       my $sr_name = 'SR_VIE009';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};               # DBI database handle
  my $session           = $global_var_href->{'session'};           # get session handle
  my $contact_id        = param('contact_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($user_roles);
  my @sql_parameters;

  # check input: is contact id given? is it a number?
  if (param('contact_id') == 0) {
     # this is just a hack to allow contact_id = 0
  }
  elsif (!param('contact_id') || param('contact_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid contact id"));
     return $page;
  }

  # first table
  $page .= h2(qq(Contact details))
           . hr();

  $sql = qq(select *
            from   contacts
                   join users on user_contact = contact_id
            where  contact_id = ?
           );

  @sql_parameters = ($contact_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no such contact found, tell
  unless ($rows > 0) {
     $page .= p("No details on this contact");
     return $page;
  }

  # otherwise continue: get result handle
  $row = $result->[0];

  $page .= h3(qq(Contact details))

           . table( {-border=>1, -summary=>"table"},
               Tr(
                 th("Name"),
                 td($row->{'contact_title'} . ' ' . $row->{'contact_first_name'} . ' ' . $row->{'contact_last_name'})
               ),
               Tr(
                 th("is internal"),
                 td($row->{'contact_is_internal'})
               ),
               Tr(
                 th("Function"),
                 td($row->{'contact_function'})
               ),
               Tr(
                 th("Email"),
                 td(join(br(), split(/,/, $row->{'contact_emails'})))
               ),
               Tr(
                 th("Comment"),
                 td($row->{'contact_comment'})
               )
             )
           . hr({-align=>'left', -width=>'50%'});

  ###############################################################
  # second table (address list for current contact): there may be more than one address for one contact
  $sql = qq(select address_id, address_institution, address_street, address_postal_code, address_other_info, address_city,
                   address_state, address_country, address_telephone, address_fax
            from   contacts2addresses
                   join addresses on c2a_address_id = address_id
            where  c2a_contact_id = ?
           );

  @sql_parameters = ($contact_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no addresses found, tell
  unless ($rows > 0) {
     $page .= p("No addresses found for this contact");
     return $page;
  }

  # else continue ...
  $page .= h3("Addresses for this contact")
           . start_table( {-border=>1, -summary=>"table"})
           . Tr(
               th(' '),
               th('Institution'),
               th('Address'),
               th('State'),
               th('Country'),
               th('Other info'),
               th('Telephone'),
               th('Fax')
             );

  # loop over all addresses
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # add table row for current address
     $page .= Tr({-align=>'center'},
                td($i+1),
                td($row->{'address_institution'}),
                td($row->{'address_street'} . br() .
                   $row->{'address_postal_code'} . ' ' . $row->{'address_city'}
                ),
                td(defined($row->{'address_state'})?$row->{'address_state'}:''),
                td(defined($row->{'address_country'})?$row->{'address_country'}:''),
                td(defined($row->{'address_other_info'})?$row->{'address_other_info'}:''),
                td(defined($row->{'address_telephone'})?join(br(), split(/,/, $row->{'address_telephone'})):''),
                td(defined($row->{'address_fax'})?join(br(), split(/,/, $row->{'address_fax'})):'')
              );
  }

  $page .= end_table();

  ###############################################################

  # third table: assigned user accounts for this contact
  $sql = qq(select user_id, user_name, user_roles
            from   users
            where  user_contact = ?
           );

  @sql_parameters = ($contact_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no addresses found, tell
  unless ($rows > 0) {
     $page .= p("No user accounts found for this contact");
     return $page;
  }

  # else continue ...
  $page .= h3("User accounts for this contact")
           . start_table( {-border=>1, -summary=>"table"})
           . Tr(
               th(' '),
               th('username'),
               th('roles')
             );

  # loop over all addresses
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      $user_roles = $row->{'user_roles'};
      $user_roles =~ s/u/ user /g;
      $user_roles =~ s/a/ admin /g;

      # add table row for current address
      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td(a({-href=>"$url?choice=user_details&user_id=" . $row->{'user_id'}}, $row->{'user_name'})),
                 td($user_roles)
               );
  }

  $page .= end_table();

  return $page;
}
# end of contact_view
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE010 mating_view                                  show mating details
sub mating_view {                                        my $sr_name = 'SR_VIE010';
  my ($global_var_href)    = @_;                         # get reference to global vars hash
  my $session              = $global_var_href->{'session'};           # get session handle
  my $dbh                  = $global_var_href->{'dbh'};               # DBI database handle
  my $mating_id            = param('mating_id');
  my $litter_id            = param('litter_id');
  my $mating_end_datetime  = param('mating_end_datetime');
  my $litter_born_datetime = param('litter_born_datetime');
  my $mating_comment       = param('mating_comment');
  my $mating_user_id       = $session->param('user_id');
  my $url                  = url();
  my $sex_color            = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my @parameters           = param();                                 # read all CGI parameter keys
  my $datetime_sql         = get_current_datetime_for_sql();
  my @parents              = ();
  my @checked_parents      = ();
  my %sex_counter          = ();
  my $errors               = 0;
  my ($page, $sql, $result, $rows, $row, $i);
  my ($mating_comment_sql, $mating_end_datetime_sql, $litter_born_datetime_sql);
  my ($dd, $mm, $yyyy, $rc, $updated, $new_litter_id, $litter_in_mating, $current_litter, $number_weaned, $number_reported, $parameter);
  my ($parent, $sex, $warning, $mice_from_this_litter, $litter_mating_id, $is_embryo_transfer);
  my ($first_gene_name, $first_genotype, $mating_start_datetime_sql);
  my @sql_parameters;

  $page .= h2(qq(Mating details ) . a({-href=>"$url?choice=mating_view&mating_id=$mating_id", -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'}))
              . "&nbsp;&nbsp;&nbsp;" . a({-href=>"$url?choice=mating_view&mating_id=" . ($mating_id - 1)}, 'previous') . "&nbsp;" . a({-href=>"$url?choice=mating_view&mating_id=" . ($mating_id + 1)}, 'next')
             )
           . hr();

  # check input: is mating id given? is it a number?
  if (!param('mating_id') || param('mating_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid mating id"));
     return $page;
  }

  ###################################################################################################################################
  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href);
  }
  ###################################################################################################################################

  ###################################################################################################################################
  # stop a mating if requested
  if (defined(param('job')) && param('job') eq "Stop mating") {
     # 1. check if mating end datetime is given and valid
     if (!param('mating_end_datetime') || check_datetime_ddmmyyyy_hhmmss(param('mating_end_datetime')) != 1) {
        $page .= p({-class=>"red"}, b("Error: date/time of death not given or has invalid format "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     # 2. is mating end datetime in the future? if so, reject
     if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('mating_end_datetime')) eq 'future') {
        $page .= p({-class=>"red"}, b("Error: date/time of mating end is in the future "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     # 3. get date of mating start to prevent mating_end_date < mating_start_date
     ($mating_start_datetime_sql) = $dbh->selectrow_array("select mating_matingstart_datetime
                                                           from   matings
                                                           where  mating_id = $mating_id
                                                          ");

     # check if mating_end_date < mating_start_date: if so, return with error
     if (Delta_ddmmyyyhhmmss(param('mating_end_datetime'), format_sql_datetime2display_datetime($mating_start_datetime_sql)) eq 'future') {
        $page .= p({-class=>"red"}, b("Error: date/time of mating end cannot be before mating was started. "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     $mating_end_datetime_sql = format_display_datetime2sql_datetime($mating_end_datetime);

     # everything checked: do it

     # try to get a lock
     &get_semaphore_lock($global_var_href, $mating_user_id);

     ############################################################################################
     # begin transaction
     $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start mating transaction)", $sr_name . "-" . __LINE__);

     # stop the mating by setting an end date to the whole mating
     $dbh->do("update  matings
               set     mating_matingend_datetime = ?
               where   mating_id = ?
              ", undef, $mating_end_datetime_sql, $mating_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update mating)", $sr_name . "-" . __LINE__);

     # check if updated
     ($updated) =  $dbh->selectrow_array("select count(mating_id)
                                          from   matings
                                          where  mating_id = $mating_id
                                                 and mating_matingend_datetime = '$mating_end_datetime_sql'
                                         ");
     # roll back if update failed
     if ($updated != 1) {
        $rc = $dbh->rollback() or &error_message_and_exit($global_var_href,"SQL error (could not roll back cage mating update transaction)", $sr_name . "-" . __LINE__);
        &release_semaphore_lock($global_var_href, $mating_user_id);
        $page .= p({-class=>"red"}, "Stop mating cancelled for an unknown reason");
        return $page;
     }

     # now also set an end date for all parents involved in the mating (which have not been previously removed from the mating)
     $dbh->do("update  parents2matings
               set     p2m_parent_end_date = ?
               where   p2m_mating_id = ?
                       and p2m_parent_end_date IS NULL
              ", undef, $mating_end_datetime_sql, $mating_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update parentships of mating)", $sr_name . "-" . __LINE__);

     $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

     # end transaction
     ############################################################################################

     # release lock
     &release_semaphore_lock($global_var_href, $mating_user_id);

     &write_textlog($global_var_href, "$datetime_sql\t$mating_user_id\t" . $session->param('username') . "\tstop_mating\t$mating_id\t$mating_end_datetime_sql");

  } # (end of stop mating)
  ###################################################################################################################################

  ###################################################################################################################################
  # delete not-weaned litter if requested
  if (defined(param('job')) && param('job') eq "delete_litter") {
     # check if mating end datetime is given and valid
     if (!param('litter_id') || param('litter_id') !~ /^[0-9]+$/) {
        $page .= p({-class=>"red"}, b("Error: litter id not given or not a number"))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     # try to get a lock
     &get_semaphore_lock($global_var_href, $mating_user_id);

     ############################################################################################
     # begin transaction
     $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start litter delete transaction)", $sr_name . "-" . __LINE__);

     # check if there are mice from this litter
     ($mice_from_this_litter) =  $dbh->selectrow_array("select count(mouse_id) as mice_from_this_litter
                                                        from   mice
                                                        where  mouse_litter_id = $litter_id
                                                       ");

     # get mating id and current litter number
     ($litter_in_mating, $litter_mating_id) =  $dbh->selectrow_array("select litter_in_mating, litter_mating_id
                                                                      from   litters
                                                                      where  litter_id = $litter_id
                                                                     ");

     # get all litters from this mating that came after current litter
     $sql = qq(select litter_id
               from   litters
               where  litter_mating_id = ?
                      and litter_in_mating > ?
            );

     @sql_parameters = ($litter_mating_id, $litter_in_mating);

    ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

     # loop over all litters that came after litter to be deleted
     for ($i=0; $i<$rows; $i++) {
        $row = $result->[$i];                # fetch next row

        ($litter_in_mating) =  $dbh->selectrow_array("select litter_in_mating
                                                      from   litters
                                                      where  litter_id = $row->{'litter_id'}
                                                     ");

        $litter_in_mating = $litter_in_mating - 1;

        $dbh->do("update  litters
                  set     litter_in_mating = ?
                  where   litter_id = ?
                 ", undef, $litter_in_mating, $row->{'litter_id'}
                ) or &error_message_and_exit($global_var_href, "SQL error (could not delete litter)", $sr_name . "-" . __LINE__);

     }

     # if no mice have this litter id, delete litter entry
     if ($mice_from_this_litter == 0) {
        $dbh->do("delete
                  from    litters
                  where   litter_id = ?
                 ", undef, $litter_id
                ) or &error_message_and_exit($global_var_href, "SQL error (could not delete litter)", $sr_name . "-" . __LINE__);

        $dbh->do("delete
                  from    litters2parents
                  where   l2p_litter_id = ?
                 ", undef, $litter_id
                ) or &error_message_and_exit($global_var_href, "SQL error (could not delete litter)", $sr_name . "-" . __LINE__);
     }

     $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

     # end transaction
     ############################################################################################

     # release lock
     &release_semaphore_lock($global_var_href, $mating_user_id);

     &write_textlog($global_var_href, "$datetime_sql\t$mating_user_id\t" . $session->param('username') . "\tdelete_litter\t$litter_id\tmating_$mating_id\t$datetime_sql");

  } # (end of delete litter)
  ###################################################################################################################################


  ###################################################################################################################################
  # update comment if requested
  if (defined(param('job')) && param('job') eq "update mating comment") {

     $mating_comment_sql = $mating_comment;
     $mating_comment_sql =~ s/'|;|-{2}//g;                  # remove dangerous content

     # update mating comment
     $dbh->do("update  matings
               set     mating_comment = ?
               where   mating_id = ?
              ", undef, $mating_comment_sql, $mating_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update mating comment)", $sr_name . "-" . __LINE__);

     &write_textlog($global_var_href, "$datetime_sql\t$mating_user_id\t" . $session->param('username') . "\tupdate_mating_comment\t$mating_id\tnew:$mating_comment_sql");
  }
  ###################################################################################################################################


  ###################################################################################################################################
  # report litter if requested
  if (defined(param('job')) && param('job') eq "Report litter") {
     # 1. check if litter report date is valid
     if (!param('litter_born_datetime') || check_datetime_ddmmyyyy_hhmmss(param('litter_born_datetime')) != 1) {
        $page .= p({-class=>"red"}, b("Error: date/time of litter birth not given or has invalid format "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     # 2. is litter born datetime in the future? if so, reject
     if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('litter_born_datetime')) eq 'future') {
        $page .= p({-class=>"red"}, b("Error: date/time of litter born datetime is in the future "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     # 3. get date of mating start to prevent litter_born_date < mating_start_date
     ($mating_start_datetime_sql) = $dbh->selectrow_array("select mating_matingstart_datetime
                                                           from   matings
                                                           where  mating_id = $mating_id
                                                          ");

     # check if litter_born_date < mating_start_date: if so, return with error
     if (Delta_ddmmyyyhhmmss(param('litter_born_datetime'), format_sql_datetime2display_datetime($mating_start_datetime_sql)) eq 'future') {
        $page .= p({-class=>"red"}, b("Error: date/time of litter birth cannot be before mating was started. "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     $litter_born_datetime_sql = format_display_datetime2sql_datetime(param('litter_born_datetime'));

     # check input parameters for being numbers: quit on failure
     if (param('litter_alive_total')   !~ /^[0-9]+$/ || param('litter_alive_male') !~ /^[0-9]+$/ || param('litter_alive_female') !~ /^[0-9]+$/ ||
         param('litter_dead_total')    !~ /^[0-9]+$/ || param('litter_dead_male')  !~ /^[0-9]+$/ || param('litter_dead_female')  !~ /^[0-9]+$/ ||
         param('litter_reduced_total') !~ /^[0-9]+$/ ) {
         $page .= h3({-class=>"red"}, "Saving new litter not possible")
                  . p(qq(invalid number))
                  . p("Please " . a({-href=>"javascript:back()"}, "go back") . ", check your input and try again");
         return $page;
     }

     # (else continue...)

     # read list of parents
     @parents = param('litter_parents');

     # check list of parents for being 8 digit numbers
     foreach $parent (@parents) {
        if ($parent =~ /^[0-9]{8}$/) {
           push(@checked_parents, $parent);

           # register sex of parents
           $sex = get_sex($global_var_href, $parent);
           $sex_counter{$sex}++;
        }
     }

     # oh, there are no parents: place warning
     if (scalar @checked_parents == 0) {
        $errors++;
        $warning .= p("No parents selected for litter");
     }

     # now make sure that exactly one male and > 1 females are selected
     if (!defined($sex_counter{'m'}) || $sex_counter{'m'} == 0) {
        # if mating type embryo transfer: no father needed
        $is_embryo_transfer = get_transfer_id($global_var_href, $mating_id);

        unless (defined($is_embryo_transfer)) {
           $errors++;
           $warning .= p("you cannot remove the father from the list of parents");
        }
     }

     # only allow one male per mating
     if (defined($sex_counter{'m'}) && $sex_counter{'m'} > 1) {
        $errors++;
        $warning .= p("not more than one father allowed");
     }

     # we neeed at least one mother
     if (!defined($sex_counter{'f'}) || $sex_counter{'f'} == 0) {
        $errors++;
        $warning .= p("you need to select at least one mother for this litter");
     }

     # quit on errors
     if ($errors > 0) {
        $page .= h3({-class=>"red"}, "Litter reporting not possible")
                 . $warning
                 . p("Please " . a({-href=>"javascript:back()"}, "go back") . " and try again");
        return $page;
     }

     # everything checked, now do it

     # try to get a lock
     &get_semaphore_lock($global_var_href, $mating_user_id);

     ############################################################################################
     # begin transaction
     $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start litter report transaction)", $sr_name . "-" . __LINE__);

     # get next free litter id
     ($new_litter_id) = $dbh->selectrow_array("select (max(litter_id)+1) as new_litter_id
                                               from   litters
                                              ");

     if (!defined($new_litter_id)) { $new_litter_id = 1; }

     # get number of litters for current mating (add 1 to get litter_in_mating)
     ($litter_in_mating) = $dbh->selectrow_array("select max(litter_in_mating) as new_litter_in_mating
                                                  from   litters
                                                  where  litter_mating_id = '$mating_id'
                                                 ");

     if (defined($litter_in_mating)) { $litter_in_mating++;   }
     else                            { $litter_in_mating = 1; }           # for first litter of a mating

     # insert litter
     $dbh->do("insert
               into    litters (litter_id, litter_mating_id, litter_in_mating, litter_born_datetime, litter_alive_total,
                                litter_alive_male, litter_alive_female, litter_dead_total, litter_dead_male, litter_dead_female,
                                litter_reduced, litter_reduced_reason, litter_weaning_datetime, litter_comment)
               values  (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
              ", undef, $new_litter_id, $mating_id, $litter_in_mating, $litter_born_datetime_sql,
                        param('litter_alive_total'), param('litter_alive_male'), param('litter_alive_female'),
                        param('litter_dead_total'),  param('litter_dead_male'),  param('litter_dead_female'), param('litter_reduced_total'),
                        param('litter_reduced_reason'), undef, param('litter_comment')

             ) or &error_message_and_exit($global_var_href, "SQL error (could not update mating)", $sr_name . "-" . __LINE__);

     # check if inserted worked
     ($updated) =  $dbh->selectrow_array("select count(litter_id) as litter_number
                                          from   litters
                                          where  litter_id = $new_litter_id
                                                 and litter_mating_id = $mating_id
                                                 and litter_in_mating = $litter_in_mating
                                         ");
     # if not, roll back, tell and quit
     if ($updated != 1) {
        $rc = $dbh->rollback() or &error_message_and_exit($global_var_href,"SQL error (could not roll back litter report transaction)", $sr_name . "-" . __LINE__);

        &release_semaphore_lock($global_var_href, $mating_user_id);
        $page .= p({-class=>"red"}, "Report new litter cancelled for an unknown reason");
        return $page;
     }

     # now add selected parents to parents for this litter
     foreach $parent (@checked_parents) {
         # father or mother?
         $sex = get_sex($global_var_href, $parent);

         $dbh->do("insert
                   into    litters2parents (l2p_litter_id, l2p_parent_id, l2p_parent_type, l2p_evidence)
                   values  (?, ?, ?, ?)
                  ", undef, $new_litter_id, $parent, ($sex eq 'm')?'father':'mother', 's'

                 ) or &error_message_and_exit($global_var_href, "SQL error (could not update parent table)", $sr_name . "-" . __LINE__);
     }

     $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);
     # end transaction
     ############################################################################################

     # release lock
     &release_semaphore_lock($global_var_href, $mating_user_id);

     &write_textlog($global_var_href, "$datetime_sql\t$mating_user_id\t" . $session->param('username') . "\treport_litter\t$new_litter_id\tmating_$mating_id\t$litter_born_datetime_sql");

  } # (end of report new litter)
  ###################################################################################################################################


  #-----------------------------------------------------------------------------------
  # all jobs done, now display mating data

  # first table (parents of mating)
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

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  $page .= h3("Parents of " . a({-href=>"$url?choice=mating_view&mating_id=" . $mating_id}, 'mating ' . $mating_id))
           . start_form(-action=>url(), -name=>"myform");

  # if no parents found: tell (but don't quit)
  if ($rows == 0) {
     $page .= p("No parents found for mating $mating_id")
              . hr({-align=>'left', -width=>'50%'});
  }

  # there are parents: generate parent table
  else {
     $page .= start_table( {-border=>1, -summary=>"table"})

              . Tr(
                  th(span({-title=>"this is just the table row number"}, "#")),
                  th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
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
                  th("room/rack-cage"),
                  th("parental status")
                );

     # loop over all parents
     for ($i=0; $i<$rows; $i++) {

        $row = $result->[$i];                # fetch next row

        # get first genotype
        ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

        # add table row for current mouse
        $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                   td($i+1),
                   td(checkbox('mouse_select', '0', $row->{'mouse_id'}, '')),
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
                       ?a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"},     # yes: print cage link
                          $row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'})
                       :'-'                                                                                                          # no: don't print cage link
                     ),
                   td((defined($row->{'p2m_parent_end_date'})
                       ?'removed'
                       :a({-href=>"$url?choice=remove_parent_from_mating&mating_id=$mating_id&parent_id=" . $row->{'mouse_id'}, -title=>"remove this parent from mating"}, "remove")
                      )
                   )
                 );
     }

     $page .= end_table()
              . p()
              . submit(-name => "job", -value=>"Add selected mice to cart")
              . hr({-align=>'left', -width=>'50%'});
  } # (parents)

  #-----------------------------------------------------------------------------------

  # second table (litters)
  $page .= h3("Litters from " . a({-href=>"$url?choice=mating_view&mating_id=" . $mating_id}, 'mating ' . $mating_id)
              . "&nbsp;&nbsp;"
              . hidden('mating_id')
              . submit(-name => "choice", -value=>"report new litter")
           );

  # collect litter info for current mating
  $sql = qq(select litter_id, litter_born_datetime, litter_weaning_datetime, litter_in_mating, litter_reduced,
                   litter_alive_total, litter_alive_male, litter_alive_female, litter_comment
            from   litters
            where  litter_mating_id = ?
            order  by litter_in_mating asc
           );

  @sql_parameters = ($mating_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no litter found: tell and quit
  if ($rows == 0) {
     $page .= p("No litters found for " . a({-href=>"$url?choice=mating_view&mating_id=" . $mating_id}, 'mating ' . $mating_id) . " [" . sterile_mating_warning($global_var_href, $mating_id, 30) . "]");
  }
  else {
     # otherwise continue: display litter table
     $page .= start_table( {-border=>1, -summary=>"table"})
              . Tr(
                  th(span({-title=>"click for litter details"}, "#")),
                  th("born"),
                  th("weaned"),
                  th("# weaned or " . br() . "# alive"),
                  th("# reduced"),
                  th("comment")
                );

     # loop over all litters
     for ($i=0; $i<$rows; $i++) {
        $row = $result->[$i];                # fetch next row

        # find out how many pups are weaned in this litter (if any)
        $current_litter = $row->{'litter_id'};

        $sql = qq(select count(mouse_id) as number_weaned
                  from   litters
                         join mice on mouse_litter_id = litter_id
                  where  litter_id = ?
                 );

        @sql_parameters = ($current_litter);

        ($number_weaned) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

        # if no pups are weaned yet, we display number of reported
        # if newborn pups have been reported by sex, add male and female pups
        if (($row->{'litter_alive_male'} + $row->{'litter_alive_female'}) > 0) {
           $number_reported = $row->{'litter_alive_male'} + $row->{'litter_alive_female'};
        }
        # newborn pups have not been reported by sex, so use summary information
        else {
           $number_reported = $row->{'litter_alive_total'};
        }

        # add table row for current litter
        $page .= Tr({-align=>'center'},
                   td(a({-href=>"$url?choice=litter_view&litter_id=" . $row->{'litter_id'}, -title=>"click for litter details"}, $row->{'litter_in_mating'} . '. litter')),
                   td(format_datetime2simpledate($row->{'litter_born_datetime'})),
                   td((format_datetime2simpledate($row->{'litter_weaning_datetime'}) ne '-')
                      ?format_datetime2simpledate($row->{'litter_weaning_datetime'})
                      :b('not yet weaned: ')
                       . a({-href=>"$url?choice=mating_view&mating_id=$mating_id&job=delete_litter&litter_id=" . $row->{'litter_id'}}, "delete")
                       . "&nbsp;"
                       . a({-href=>"$url?choice=wean_litter_1&litter_id=" . $row->{'litter_id'}}, "wean")
                   ),
                   td((format_datetime2simpledate($row->{'litter_weaning_datetime'}) ne '-')
                      ?$number_weaned
                      :$number_reported
                   ),
                   td(defined($row->{'litter_reduced'})?$row->{'litter_reduced'}:0),
                   td($row->{'litter_comment'})
                 );
     }

     $page .= end_table()
              . p();
  }

  #-----------------------------------------------------------------------------------

  # third table (basic mating data)
  $sql = qq(select mating_id, mating_name, mating_matingstart_datetime, mating_matingend_datetime,
                   mating_scheme, mating_purpose, mating_generation, mating_comment, project_name,
                   strain_name, line_name
            from   matings
                   join mouse_strains on      strain_id = mating_strain
                   join mouse_lines   on        line_id = mating_line
                   left join projects on mating_project = project_id
            where  mating_id = ?
           );

  @sql_parameters = ($mating_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no such mating found: tell and quit
  unless ($rows > 0) {
     $page .= p("No details on mating $mating_id");
     return $page;
  }

  # else continue: get result handle and display table
  $row = $result->[0];

  $is_embryo_transfer = get_transfer_id($global_var_href, $mating_id);

  $page .= hr()
           . h3(qq(Details for mating ) . a({-href=>"$url?choice=mating_view&mating_id=" . $mating_id}, 'mating ' . $mating_id))
           . start_form(-action=>url(), -name=>"myform1")
           . hidden('mating_id')
           . hidden('choice')
           . table( {-border=>1, -summary=>"table", -bgcolor=>'#DDFFFF'},
               Tr(
                 th("Mating type"),
                 td({-align=>'center'}, b(defined($is_embryo_transfer)?a({-href=>"$url?choice=transfer_view&transfer_id=" . $is_embryo_transfer}, 'embryo transfer ' . $is_embryo_transfer):'normal mating') )
               ),
               Tr(
                 th("Mating name"),
                 td({-align=>'center'}, ($row->{'mating_name'} ne qq(''))?qq("$row->{'mating_name'}"):'-')
               ),
               Tr(
                 th("Mating start"),
                 td({-align=>'center'}, format_sql_datetime2display_date($row->{'mating_matingstart_datetime'}))
               ),
               Tr(
                 th("Mating end"),
                 td({-align=>'center'}, (defined($row->{'mating_matingend_datetime'})
                                         ?format_sql_datetime2display_datetime($row->{'mating_matingend_datetime'})
                                         :b('Stop mating: ')
                                          . textfield(-name=>"mating_end_datetime", -id=>'mating_end_datetime', -size=>"20", -maxlength=>"21", -title=>"mating end date", -value=>get_current_datetime_for_display()) . "&nbsp;&nbsp;"
                                          . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=mating_end_datetime', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                                          . submit(-name => "job", -value=>"Stop mating")
                                          . br()
                                          . small("enter date/time for mating end")
                                        )
                 )
               ),
               Tr(
                 th("Strain"),
                 td({-align=>'center'}, ($row->{'strain_name'} ne qq(''))?$row->{'strain_name'}:'-')
               ),
               Tr(
                 th("Line"),
                 td({-align=>'center'}, ($row->{'line_name'} ne qq(''))?$row->{'line_name'}:'-')
               ),
               Tr(
                 th("Mating scheme"),
                 td({-align=>'center'}, ($row->{'mating_scheme'} ne qq(''))?$row->{'mating_scheme'}:'-')
               ),
               Tr(
                 th("Mating purpose"),
                 td({-align=>'center'}, ($row->{'mating_purpose'} ne qq(''))?$row->{'mating_purpose'}:'-')
               ),
               Tr(
                 th("Mating generation"),
                 td({-align=>'center'}, ($row->{'mating_generation'} ne qq(''))?$row->{'mating_generation'}:'-')
               ),
               Tr(
                 th("assigned project"),
                 td({-align=>'center'}, $row->{'project_name'})
               ),
               Tr(
                 th("mating comment"),
                 td(textarea(-name=>"mating_comment", -columns=>"40", -rows=>"5",
                             -value=>($row->{'mating_comment'} ne qq(''))?$row->{'mating_comment'}:'-'
                    )
                    . br()
                    . submit(-name => "job", -value=>"update mating comment")
                 )
               )
             )
           . end_form()
           . hr({-align=>'left', -width=>'50%'});
  #-----------------------------------------------------------------------------------

  # store CGI parameters in hidden fields. Yes, I know, there are better ways to do this, but input from hidden fields will be checked
  foreach $parameter (@parameters) {
     unless ($parameter eq 'mouse_select' || $parameter eq 'job') {
        $page .= hidden(-name=>$parameter, -value=>param("$parameter")) . "\n";
     }
  }

  $page .= end_form();

  return $page;
}
# end of mating_view
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE011 litter_view                                  show litter details
sub litter_view {                                        my $sr_name = 'SR_VIE011';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};           # get session handle
  my $dbh               = $global_var_href->{'dbh'};
  my $litter_id         = param('litter_id');
  my $litter_comment    = param('litter_comment');
  my $url               = url();
  my $sex_color         = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my $user_id           = $session->param(-name=>'user_id');
  my $datetime_now      = get_current_datetime_for_sql();
  my @parameters        = param();                            # read all CGI parameter keys
  my ($litter_count, $mating_id, $used_in_matings, $is_weaned, $litter_born_datetime, $litter_loss_datetime_sql);             # DBI database handle
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my ($first_gene_name, $first_genotype, $litter_comment_sql, $parameter);
  my @sql_parameters;

  # check input: is litter id given? is it a number?
  if (!param('litter_id') || param('litter_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid litter id"));
     return $page;
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href);
  }

  # update comment if requested
  if (defined(param('job')) && param('job') eq "update litter comment") {

     $litter_comment_sql = $litter_comment;
     $litter_comment_sql =~ s/'|;|-{2}//g;                  # remove dangerous content

     # update litter comment
     $dbh->do("update  litters
               set     litter_comment = ?
               where   litter_id = ?
              ", undef, $litter_comment_sql, $litter_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update litter comment)", $sr_name . "-" . __LINE__);

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdate_litter_comment\t$litter_id\tnew:$litter_comment_sql");
  }

  #######################################
  # report litter loss if requested
  if (defined(param('job')) && param('job') eq "Report litter loss") {
     # 0. check if litter id given
     if (!param('litter_id') || param('litter_id') !~ /^[0-9]+$/) {
        $page .= p({-class=>"red"}, b("Error: litter id not given or not a number "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     # 1. check if litter loss datetime is valid
     if (!param('litter_loss_datetime') || check_datetime_ddmmyyyy_hhmmss(param('litter_loss_datetime')) != 1) {
        $page .= p({-class=>"red"}, b("Error: date/time of litter loss not given or has invalid format "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     # 2. is litter loss datetime in the future? if so, reject
     if (Delta_ddmmyyyhhmmss(get_current_datetime_for_display(), param('litter_loss_datetime')) eq 'future') {
        $page .= p({-class=>"red"}, b("Error: date/time of litter loss is in the future "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     # 3. get date of litter_born_datetime to prevent litter_loss_datetime < litter_born_datetime
     ($litter_born_datetime) = $dbh->selectrow_array("select litter_born_datetime
                                                      from   litters
                                                      where  litter_id = $litter_id
                                                     ");

     # check if litter_born_date < mating_start_date: if so, return with error
     if (Delta_ddmmyyyhhmmss(param('litter_born_datetime'), format_sql_datetime2display_datetime($litter_born_datetime)) eq 'future') {
        $page .= p({-class=>"red"}, b("Error: date/time of litter loss cannot be before litter was born. "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     $litter_loss_datetime_sql = format_display_datetime2sql_datetime(param('litter_loss_datetime'));

     # check input parameters for being numbers: quit on failure
     if (param('litter_dead_total')    !~ /^[0-9]+$/ || param('litter_dead_male')  !~ /^[0-9]+$/ || param('litter_dead_female')  !~ /^[0-9]+$/ ||
         param('litter_reduced_total') !~ /^[0-9]+$/ ) {
         $page .= h3({-class=>"red"}, "Updating litter not possible")
                  . p(qq(invalid number))
                  . p("Please " . a({-href=>"javascript:back()"}, "go back") . ", check your input and try again");
         return $page;
     }

     # (else continue...)

     # try to get a lock
     &get_semaphore_lock($global_var_href, $user_id);

     ############################################################################################
     # begin transaction
     $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start litter update transaction)", $sr_name . "-" . __LINE__);

     # update litter
     $dbh->do("update litters
               set    litter_alive_total      = ?, litter_alive_male     = ?, litter_alive_female = ?,
                      litter_dead_total       = ?, litter_dead_male      = ?, litter_dead_female  = ?,
                      litter_reduced          = ?, litter_reduced_reason = ?,
                      litter_weaning_datetime = ?,
                      litter_comment = ?
               where  litter_id = ?
              ", undef, 0, 0, 0,
                        param('litter_dead_total'),    param('litter_dead_male'),  param('litter_dead_female'),
                        param('litter_reduced_total'), param('litter_reduced_reason'),
                        $litter_loss_datetime_sql,
                        param('litter_comment'),
                        $litter_id

             ) or &error_message_and_exit($global_var_href, "SQL error (could not update litter)", $sr_name . "-" . __LINE__);

     $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);
     # end transaction
     ############################################################################################

     # release lock
     &release_semaphore_lock($global_var_href, $user_id);

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\treport_litter_loss\tlitter_id\t$litter_loss_datetime_sql");

  } # (end of report litter loss)
  #######################################


  #######################################
  # update litter details if requested
  if (defined(param('job')) && param('job') eq "Update litter details") {
     # 0. check if litter id given
     if (!param('litter_id') || param('litter_id') !~ /^[0-9]+$/) {
        $page .= p({-class=>"red"}, b("Error: litter id not given or not a number "))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }

     # check input parameters for being numbers: quit on failure
     if (param('litter_alive_total')   !~ /^[0-9]+$/ || param('litter_alive_male') !~ /^[0-9]+$/ || param('litter_alive_female') !~ /^[0-9]+$/ ||
         param('litter_dead_total')    !~ /^[0-9]+$/ || param('litter_dead_male')  !~ /^[0-9]+$/ || param('litter_dead_female')  !~ /^[0-9]+$/ ||
         param('litter_reduced_total') !~ /^[0-9]+$/ ) {
         $page .= h3({-class=>"red"}, "Updating litter not possible")
                  . p(qq(invalid number))
                  . p("Please " . a({-href=>"javascript:back()"}, "go back") . ", check your input and try again");
         return $page;
     }

     # (else continue...)

     # try to get a lock
     &get_semaphore_lock($global_var_href, $user_id);

     ############################################################################################
     # begin transaction
     $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start litter update transaction)", $sr_name . "-" . __LINE__);

     # update litter
     $dbh->do("update litters
               set    litter_alive_total      = ?, litter_alive_male     = ?, litter_alive_female = ?,
                      litter_dead_total       = ?, litter_dead_male      = ?, litter_dead_female  = ?,
                      litter_reduced          = ?, litter_reduced_reason = ?,
                      litter_comment = ?
               where  litter_id = ?
              ", undef, param('litter_alive_total'),   param('litter_alive_male'), param('litter_alive_female'),
                        param('litter_dead_total'),    param('litter_dead_male'),  param('litter_dead_female'),
                        param('litter_reduced_total'), param('litter_reduced_reason'),
                        param('litter_comment'),
                        $litter_id

             ) or &error_message_and_exit($global_var_href, "SQL error (could not update litter details)", $sr_name . "-" . __LINE__);

     $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);
     # end transaction
     ############################################################################################

     # release lock
     &release_semaphore_lock($global_var_href, $user_id);

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdate_litter_details\tlitter_id");

  } # (end of update litter details)
  #######################################


  $page .= h2(qq(Litter details ) . a({-href=>"$url?choice=litter_view&litter_id=$litter_id", -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})))
           . hr()
           . start_form(-action=>url(), -name=>"myform");

  # first table (basic litter data)
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
  $mating_id    = $row->{'litter_mating_id'};
  $litter_count = $row->{'litter_in_mating'};
  $is_weaned    = $row->{'litter_weaning_datetime'};

  $page .= h3($litter_count . ". Litter from " . a({-href=>"$url?choice=mating_view&mating_id=" . $mating_id}, "mating $mating_id") . ": weaning overview")
           . table( {-border=>1, -summary=>"table", -bgcolor=>'#DDFFFF'},
                Tr(
                  th({-rowspan=>2, -valign=>"bottom"}, "birth date"),
                  th({-rowspan=>2, -valign=>"bottom"}, "weaning date"),
                  th({-colspan=>3}, "reported alive"),
                  th({-colspan=>3}, "reported dead"),
                  th({-colspan=>2}, "reported reduced")
                ),
                Tr(
                  th("total"),
                  th("male"),
                  th("female"),
                  th("total"),
                  th("male"),
                  th("female"),
                  th("total"),
                  th("why")
                ),
                Tr( {-align=>'center'},
                  td(format_datetime2simpledate($row->{'litter_born_datetime'})),
                  td(format_datetime2simpledate($row->{'litter_weaning_datetime'})),
                  td((defined($row->{'litter_alive_total'})   && ($row->{'litter_alive_total'} > 0)  )?$row->{'litter_alive_total'}:'0'),
                  td((defined($row->{'litter_alive_male'})    && ($row->{'litter_alive_male'} > 0)   )?$row->{'litter_alive_male'}:'0'),
                  td((defined($row->{'litter_alive_female'})  && ($row->{'litter_alive_female'} > 0) )?$row->{'litter_alive_female'}:'0'),
                  td((defined($row->{'litter_dead_total'})    && ($row->{'litter_dead_total'} > 0)   )?$row->{'litter_dead_total'}:'0'),
                  td((defined($row->{'litter_dead_male'})     && ($row->{'litter_dead_male'} > 0)    )?$row->{'litter_dead_male'}:'0'),
                  td((defined($row->{'litter_dead_female'})   && ($row->{'litter_dead_female'} > 0)  )?$row->{'litter_dead_female'}:'0'),
                  td((defined($row->{'litter_reduced'})       && ($row->{'litter_reduced'} > 0))?$row->{'litter_reduced'}:'0'),
                  td(($row->{'litter_reduced_reason'} ne qq(''))?$row->{'litter_reduced_reason'}:'-')
                ),
                Tr( {-align=>'center'},
                  th("comment"),
                  td({-colspan=>9, -align=>'left'},
                     textarea(-name=>"litter_comment", -columns=>"40", -rows=>"5",
                             -value=>($row->{'litter_comment'} ne qq(''))?$row->{'litter_comment'}:'-'
                     )
                     . br()
                     . submit(-name => "job", -value=>"update litter comment")
                  )
                )
             )
           . p()
           . hr({-align=>'left', -width=>'50%'});


  # second table (parents)
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
                   dr1.death_reason_name as how, dr2.death_reason_name as why,
                   l2p_parent_type
            from   litters2parents
                   join mice               on            l2p_parent_id = mouse_id
                   join mouse_strains      on             mouse_strain = strain_id
                   join mouse_lines        on               mouse_line = line_id
                   join mice2cages         on                 mouse_id = m2c_mouse_id
                   join cages2locations    on              m2c_cage_id = c2l_cage_id
                   join locations          on              location_id = c2l_location_id
                   join cages              on                  cage_id = c2l_cage_id
                   join death_reasons dr1  on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2  on  mouse_deathorexport_why = dr2.death_reason_id
            where  l2p_litter_id = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
            order  by l2p_parent_type asc
           );

  @sql_parameters = ($litter_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  $page .= h3($litter_count . ". litter from " . a({-href=>"$url?choice=mating_view&mating_id=" . $mating_id}, "mating $mating_id") . ": parents");

  # if no parents found for this litter: tell (but don't quit)
  if ($rows == 0) {
     $page .= p("No parents found for this litter")
              . hr({-align=>'left', -width=>'50%'});
  }

  # else continue: display parent table
  else {
     $page .= start_table( {-border=>1, -summary=>"table"})

              . Tr(
                  th(span({-title=>"this is just the table row number"}, "#")),
                  th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
                  th("role"),
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

     # loop over all parents
     for ($i=0; $i<$rows; $i++) {

        $row = $result->[$i];                # fetch next row

        # get first genotype
        ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

        # add table row for current parent
        $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                   td($i+1),
                   td(checkbox('mouse_select', '0', $row->{'mouse_id'}, '')),
                   td($row->{'l2p_parent_type'}),
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
                       ?a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"},     # yes: print cage link
                          $row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'})
                       :'-'                                                                                                          # no: don't print cage link
                     )
                 );
     }

     $page .= end_table()
              . p()
              . submit(-name => "job", -value=>"Add selected mice to cart")
              . hr({-align=>'left', -width=>'50%'});
  }

  # third table (littermates)
  $sql = qq(select mouse_litter_id, mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
                   dr1.death_reason_name as how, dr2.death_reason_name as why,
                   litter_weaning_datetime
            from   mice
                   join litters            on                litter_id = mouse_litter_id
                   join mouse_strains      on             mouse_strain = strain_id
                   join mouse_lines        on               mouse_line = line_id
                   join mice2cages         on                 mouse_id = m2c_mouse_id
                   join cages2locations    on              m2c_cage_id = c2l_cage_id
                   join locations          on              location_id = c2l_location_id
                   join cages              on                  cage_id = c2l_cage_id
                   join death_reasons dr1  on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2  on  mouse_deathorexport_why = dr2.death_reason_id
            where  litter_id = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
            order  by litter_id asc, mouse_id asc

           );

  @sql_parameters = ($litter_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if there are no pups, add weaning link and quit
  if ($rows == 0) {
     if (defined($is_weaned)) {
        $page .= p("No pups!");
     }
     else {
        $page .= p(  "Pups not weaned yet ("
                     . a({-href=>"$url?choice=wean_litter_1&litter_id=" . $litter_id}, "click to wean")
                     . " or "
                     . a({-href=>"$url?choice=update_litter_details&litter_id=" . $litter_id}, "update litter details")
                     . " or "
                     . a({-href=>"$url?choice=report_litter_loss&litter_id=" . $litter_id}, "report litter loss")
                     . ") "
                 );
     }
  }

  else {
    # else continue: display pups table
    $page .= h3($litter_count . ". Litter from " . a({-href=>"$url?choice=mating_view&mating_id=" . $mating_id}, "mating $mating_id") . ": littermates")
             . start_table( {-border=>1, -summary=>"table"})
             . Tr(
                 th(span({-title=>"this is just the table row number"}, "#")),
                 th(checkbox(-name=>"checkall2", -label=>"", -onClick=>"checkAll2(document.myform)", -title=>"select/unselect all")),
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

    # loop over all pups
    for ($i=0; $i<$rows; $i++) {
       $row = $result->[$i];                # fetch next row

       # count matings in which this mouse was parent
       $sql = qq(select count(p2m_mating_id) as used_in_matings
                 from   parents2matings
                 where  p2m_parent_id = ?
              );

       @sql_parameters = ($row->{'mouse_id'});

       ($used_in_matings) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

       # get first genotype
       ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

       # add table row for current pup mouse
       $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                  td($i+1),
                  td(checkbox('mouse_select', '0', $row->{'mouse_id'}, '')),
                  td({-align=>'left'}, a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))
                         . (($used_in_matings > 0)?'+':'')
                  ),
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
             . p(small("(+ means that this mouse was/is used as parent in a mating)"))
             . p()
             . submit(-name => "job", -value=>"Add selected mice to cart");
  }

  # store CGI parameters in hidden fields. Yes, I know, there are better ways to do this, but input from hidden fields will be checked
  foreach $parameter (@parameters) {
     unless ($parameter eq 'mouse_select' || $parameter eq 'job') {
        $page .= hidden(-name=>$parameter, -value=>param("$parameter")) . "\n";
     }
  }

  $page .= hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")               . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre") . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")
           . end_form();

  return $page;
}
# end of litter_view
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE012 mating_overview():                           mating overview
sub mating_overview {                                    my $sr_name = 'SR_VIE012';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $show_rows         = $global_var_href->{'show_rows'};
  my $start_row         = param('start_row');
  my ($page, $sql, $result, $rows, $row, $i);
  my ($active_only_sql, $active_only);
  my @sql_parameters;

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  # user wants to see active matings only: generate SQL condition
  if (param('active_only') && param('active_only') eq 'y') {
     $active_only = 'y';

     # restrict to matings whose mating_matingend_datetime is at least 21 days before current date
     $active_only_sql = "where ( (mating_matingend_datetime IS NULL)
                                  OR
                                 (mating_matingend_datetime >= \'" . get_sql_time_by_given_current_age('21') . "'))";
  }
  else {          # otherwise skip age condition from SQL
     $active_only     = 'n';
     $active_only_sql = '';
  }

  $page = start_form(-action => url())
          . h2("Mating overview " . a({-href=>"$url?choice=mating_overview&active_only=$active_only" , -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'}))
               . "&nbsp;&nbsp;&nbsp;&nbsp;["
               . small("quick find: ")
               . textfield(-name => "mating_id", -size=>"9", -maxlength=>"8")
               . submit(-name => "choice", -value=>"Search by mating ID")
               . "]"
            )
          . end_form()
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select mating_id, mating_name, mating_matingstart_datetime, mating_matingend_datetime, mating_scheme, mating_purpose,
                   mating_generation, mating_comment, project_name, strain_name, line_name, count(litter_id) as litter_number
            from   matings
                   join projects      on mating_project = project_id
                   join mouse_strains on      strain_id = mating_strain
                   join mouse_lines   on        line_id = mating_line
                   left join litters  on      mating_id = litter_mating_id
            $active_only_sql
            group  by mating_id
            order  by mating_id desc
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no matings found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No matings found.");
    return $page;
  }

  # ... otherwise continue with matings table

  # first generate table header ...
  $page .= h3("Found $rows " . (($active_only eq 'y')?"active ":"") . "matings. [Select: " . a({-href=>"$url?choice=mating_overview&active_only=n"}, "all matings") . "&nbsp;or&nbsp;" . a({-href=>"$url?choice=mating_overview&active_only=y"}, "only active matings"). "]")
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=mating_overview&active_only=$active_only" . '&start_row=1'}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=mating_overview&active_only=$active_only" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=mating_overview&active_only=$active_only" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=mating_overview&active_only=$active_only" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
              )
              :''
             )
           . start_table( {-border=>"1", -summary=>"mating_overview"})
           . Tr( {-align=>'center'},
               th("#"),
               th("mating id"),
               th("mating name"),
               th("mating start"),
               th("mating end"),
               th("strain"),
               th("line"),
               th("mating scheme"),
               th("mating purpose"),
               th("generation"),
               th("project"),
               th("litter number"),
               th("comment")
             );

  # ... then loop over all matings
  for ($i=0; $i<$rows; $i++) {
      if ($i+1 < $start_row )              { next; }               # skip all rows with (row index < $start_row)
      if ($i+1 >= $start_row + $show_rows) { last; }               # skip all rows with (row index > $start_row+$show_rows): exit loop

      $row = $result->[$i];

      # generate the current mating row
      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td(a({-href=>"$url?choice=mating_view&mating_id=$row->{'mating_id'}", -title=>"click for mating details"}, "mating $row->{'mating_id'}")),
                 td(($row->{'mating_name'} ne qq(''))?qq($row->{'mating_name'}):'-'),
                 td(format_datetime2simpledate($row->{'mating_matingstart_datetime'})),
                 td(format_datetime2simpledate($row->{'mating_matingend_datetime'})),
                 td(defined($row->{'strain_name'})?$row->{'strain_name'}:'-'),
                 td(defined($row->{'line_name'})?$row->{'line_name'}:'-'),
                 td(($row->{'mating_scheme'} ne qq(''))?$row->{'mating_scheme'}:'-'),
                 td(($row->{'mating_purpose'} ne qq(''))?$row->{'mating_purpose'}:'-'),
                 td(($row->{'mating_generation'} ne qq(''))?$row->{'mating_generation'}:'-'),
                 td(defined($row->{'project_name'})?$row->{'project_name'}:'-'),
                 td(defined($row->{'litter_number'})?$row->{'litter_number'}:'-'),
                 td(($row->{'mating_comment'} ne qq(''))?$row->{'mating_comment'}:'-')
               );
  }

  $page .= end_table();

  return $page;
}
# end of mating_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE013 import_overview():                           import overview
sub import_overview {                                    my $sr_name = 'SR_VIE013';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $show_rows         = $global_var_href->{'show_rows'};
  my $start_row         = param('start_row');
  my ($page, $sql, $result, $rows, $row, $i);
  my ($short_comment);
  my @sql_parameters;

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  $page = start_form(-action => url())
          . h2("Import overview " . a({-href=>"$url?choice=import_overview", -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'}))
             . "&nbsp;&nbsp;&nbsp;&nbsp;["
             . small("quick find: ")
             . textfield(-name => "import_id", -size=>"9", -maxlength=>"8")
             . submit(-name => "choice", -value=>"Search by import ID")
             . "]"
            )
          . end_form()
          . hr();

  $sql = qq(select import_id, import_name, import_type, import_datetime, import_purpose, import_comment, import_provider_name, location_name, location_is_internal,
                   c2.contact_id as provider_id, c2.contact_title as provider_title,
                   c2.contact_first_name as provider_first_name, c2.contact_last_name as provider_last_name,
                   user_name, user_id, user_contact, strain_name, line_name, project_name, count(mouse_id) as no_mice
            from   imports
                   left join contacts c2 on import_provider_contact = c2.contact_id
                   join mouse_strains    on               strain_id = import_strain
                   join mouse_lines      on                 line_id = import_line
                   join projects         on          import_project = project_id
                   left join users       on       import_coach_user = user_id
                   left join locations   on  import_origin_location = location_id
                   join mice             on         mouse_import_id = import_id
            group  by import_id
            order  by import_id desc
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no imports found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No imports in the database. " . "&nbsp;&nbsp;&nbsp;&nbsp;[" . a({-href=>"$url?choice=import_step_1"}, "new import") . "]");
     return $page;
  }

  # else continue: display imports table
  $page .= h3("Found $rows imports.  " . "&nbsp;&nbsp;&nbsp;&nbsp;[" . a({-href=>"$url?choice=import_step_1"}, "new import") . "]")
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=import_overview" . '&start_row=1'}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=import_overview" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=import_overview" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=import_overview" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
              )
              :''
             )
           . start_table( {-border=>"1", -summary=>"import_overview"})
           . Tr( {-align=>'center'},
               th("#"),
               th("Import number"),
               th("Import name"),
               th("Mice #"),
               th("Strain"),
               th("Line"),
              # th("Project"),
               th("Import type"),
               th("Date of import"),
              # th("Import purpose"),
               th("Provider"),
               th("Provider"),
               th("Origin"),
               th("Internal"),
               th("Import by"),
               th("Import comment (shortened)")
             );

  # ... loop over all imports
  for ($i=0; $i<$rows; $i++) {               # $rows is the number of racks returned from the above query
      if ($i+1 < $start_row )              { next; }               # skip all rows with (row index < $start_row)
      if ($i+1 >= $start_row + $show_rows) { last; }               # skip all rows with (row index > $start_row+$show_rows): exit loop

      $row = $result->[$i];                  # get a reference on the current result row

      # shorten comment to fit on table/page
      if (defined($row->{'import_comment'}) && $row->{'import_comment'} =~ /(^.{30})/) {
         $short_comment = $1 . ' ...';
      }
      else {
         $short_comment = $row->{'import_comment'};
      }

      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td(a({-href=>"$url?choice=import_view&import_id=" . $row->{'import_id'}}, "import " . $row->{'import_id'})),
                 td((defined($row->{'import_name'})?qq("$row->{'import_name'}"):'[n/a]')),
                 td($row->{'no_mice'}),
                 td($row->{'strain_name'}),
                 td($row->{'line_name'}),
                # td($row->{'project_name'}),
                 td($row->{'import_type'}),
                 td(format_datetime2simpledate($row->{'import_datetime'})),
                # td($row->{'import_purpose'}),
                 td($row->{'import_provider_name'}),
                 td((defined($row->{'provider_id'}))
                    ?a({-href=>"$url?choice=contact_view&contact_id=" . $row->{'provider_id'}}, $row->{'provider_title'} . ' ' . $row->{'provider_first_name'} . ' ' . $row->{'provider_last_name'})
                    :'-'
                 ),
                 td($row->{'location_name'}),
                 td($row->{'location_is_internal'}),
                 td((defined($row->{'user_name'}))?a({-href=>"$url?choice=user_details&user_id=" . $row->{'user_id'}, -title=>"MausDB user who is responsible for the mice"}, $row->{'user_name'}):'-'),
                 td($short_comment)
               );

  }

  $page .= end_table();

  return $page;
}
# end of import_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE014 external_mouse_details():                    detailed view on an external mouse
sub external_mouse_details {                             my $sr_name = 'SR_VIE014';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $mouse_id          = param('mouse_id');
  my $sex_color         = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my ($page, $sql, $result, $rows, $row, $i);
  my ($mouse_sex, $gene_info, $first_gene_name, $first_genotype);
  my @sql_parameters;

  # check input first: a mouse id must be provided and it has to be an 8 digit number
  if (!param('mouse_id') || param('mouse_id') !~ /^[0-9]{8}$/) {
     &error_message_and_exit($global_var_href, "invalid mouse id (must be a negative 8 digit number).", $sr_name . "-" . __LINE__);
  }

  $page = h2("External mouse details " . a({-href=>"$url?choice=external_mouse_details&mouse_id=$mouse_id", -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})))
          . hr();

  $sql = qq(select mouse_id, mouse_birth_datetime, mouse_sex, strain_name, line_name, mouse_comment, mouse_is_gvo,
                   mouse_origin_type
            from   mice
                   join mouse_strains      on             mouse_strain = strain_id
                   join mouse_lines        on               mouse_line = line_id
            where  mouse_id = ?
                   and (m2g_gene_order = 1 or m2g_gene_order IS NULL)
           );

  @sql_parameters = ($mouse_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
 ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if there is no such mouse: tell and quit
  unless ($rows > 0) {
     $page .= p("No external mouse found having id $mouse_id.");
     return $page;
  }

  # else continue: display external mouse details
  $page .= p(h3("Details for external mouse " . qq(") . mouse_id2externalID($global_var_href, $mouse_id) . qq(")))

           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th("mouse ID"       ),
               th("sex"            ),
               th("born"           ),
               th("genotype"       ),
               th("strain"         ),
               th("line"           ),
               th("is GVO"         )
             );

  # get first (and only) result line
  $row = $result->[0];

  # get first genotype
  ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

  # write details
  $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
              td(a({-href=>"$url?choice=external_mouse_details&mouse_id=". $row->{'mouse_id'}}, mouse_id2externalID($global_var_href, $mouse_id))),
              td($row->{'mouse_sex'}),
              td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
              td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
              td($row->{'strain_name'}),
              td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
              td('&nbsp;' . $row->{'mouse_is_gvo'} . '&nbsp;')
            ) .
            Tr( td({-colspan=>"11"}, b("comments"))
            ) .
            Tr( td({-colspan=>"11"}, ($row->{'mouse_comment'} ne '')?pre($row->{'mouse_comment'}):'no comments for this mouse')
            );

  $page .= end_table()
           . hr({-align=>'left', -width=>'50%'});

  # print out genotype information
  $page .= h3("Genotype information for mouse " . qq(") . mouse_id2externalID($global_var_href, $mouse_id) . qq("))
           . &get_gene_info($global_var_href, $mouse_id)
           . hr({-align=>'left', -width=>'50%'});

  # print out properties information
  $page .= h3("Properties/attributes for mouse " . qq(") . mouse_id2externalID($global_var_href, $mouse_id) . qq("))
           . &get_properties_table($global_var_href, $mouse_id);

  return $page;
}
# end of external_mouse_details()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE015 cage_history():                              show cage and rack history of a mouse
sub cage_history {                                       my $sr_name = 'SR_VIE015';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $mouse_id          = param('mouse_id');
  my ($page, $sql, $result, $rows, $row, $i);
  my ($mouse_in_cage_from, $mouse_in_cage_to);
  my @cage_mates;
  my @cage_racks;
  my @sql_parameters;

  # check input: is mouse id given? is it a number?
  if (!param('mouse_id') || param('mouse_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid mouse id"));
     return $page;
  }

  $page .= h2("Cage history of mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id"}, reformat_number($mouse_id, 8)))
           . hr();

  # find all cages in which current mouse was placed until now
  $sql = qq(select m2c_mouse_id, m2c_cage_id, m2c_datetime_from, m2c_datetime_to
            from   mice2cages
            where  m2c_mouse_id = ?
            order  by m2c_cage_of_this_mouse asc
           );

  @sql_parameters = ($mouse_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no cage found (should not happen): tell and quit
  unless ($rows > 0) {
     $page .= p("No cage history for mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id"}, reformat_number($mouse_id, 8)));
     return $page;
  }

  # else continue: display historic cage table for this mouse
  $page .= h3(b("Mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id"}, reformat_number($mouse_id, 8)) . " was placed in the following cages:"))
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(" in cage       "),
               th(" from          "),
               th(" to            "),
               th(" together with "),
               th(" with cage being placed in rack ")
             );

  # loop over all historic cages for this mouse
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      # placed in current cage from ... to
      $mouse_in_cage_from = $row->{'m2c_datetime_from'};
      $mouse_in_cage_to   = $row->{'m2c_datetime_to'};

      # find out mice sitting in same cage during this particular time period
      @cage_mates = get_cage_mates($global_var_href, $row->{'m2c_cage_id'}, $mouse_in_cage_from, $mouse_in_cage_to, $mouse_id);

      # find out in which racks this cage was placed in this particular time period
      @cage_racks = get_cage_racks($global_var_href, $row->{'m2c_cage_id'}, $mouse_in_cage_from, $mouse_in_cage_to);

      $page .= Tr({-align=>'center'},
                 td(b(($row->{'m2c_cage_id'} == -1)?"final cage":$row->{'m2c_cage_id'})),
                 td(format_sql_datetime2display_datetime($mouse_in_cage_from)),
                 td((format_sql_datetime2display_datetime($mouse_in_cage_to) ne '-')?format_sql_datetime2display_datetime($mouse_in_cage_to):'(still there)'),
                 td({-align=>'left'},join(", ", @cage_mates)),
                 td({-align=>'left'},join(br(), @cage_racks))
               );

  }

  $page .= end_table();

  return $page;
}
# end of cage_history
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE016 view_carts():                                cart overview
sub view_carts {                                         my $sr_name = 'SR_VIE016';
  my ($global_var_href)       = @_;                            # get reference to global vars hash
  my $url                     = url();
  my $session                 = $global_var_href->{'session'};
  my $user_id                 = $session->param(-name=>'user_id');
  my $dbh                     = $global_var_href->{'dbh'};
  my $cart_id                 = param('cart_id');
  my $start_row               = param('start_row');
  my $sort_column             = param('sort_by');
  my $sort_order              = param('sort_order');
  my $show_rows               = $global_var_href->{'show_rows'};
  my @user_project_colleagues = get_user_projects_colleagues($global_var_href, $user_id);  # find all colleagues sharing projects
  my @mice                    = ();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($mice_in_cart, $own_carts_only, $own_carts_only_sql, $unquoted_cart_name);
  my @sql_parameters;

  if (scalar @user_project_colleagues == 0)  { @user_project_colleagues = ($user_id); }
  my $user_project_colleagues_sql = join(',', @user_project_colleagues);

  # hide real database column names from user (security issue): use translation hash table
  # left (key): identifier used in HTML form; right (value): database column name
  my $columns  = {'id' => 'cart_id', 'user' => 'cart_user', 'date'  => 'cart_creation_datetime', 'name' => 'cart_name'};
  my $rev_order    = {'asc' => 'desc', 'desc' => 'asc'};     # toggle table

  # make sure a sort column is defined
  if (!param('sort_by')) {
     $sort_column = 'id';
  }
  # raise error if invalid sort column given
  elsif (!defined($columns->{$sort_column})) {
     $page = p({-class=>"red"}, b("Error: invalid sort column $sort_column"));
     return $page;
  }

  # if sort order is given and 'desc': set it to 'desc'
  if (param('sort_order') && param('sort_order') eq 'desc') {
     $sort_order = 'desc';
  }
  # else default to 'asc'
  else {
     $sort_order = 'asc';
  }

  # first check if there is a cart to be deleted: if so, do it (no transaction needed)
  if (defined(param('choice')) && (param('choice') eq 'delete_cart') && defined(param('cart_id')) && (param('cart_id') =~ /^[0-9]+$/)) {
     $dbh->do("delete
               from   carts
               where  cart_id = $cart_id
              ");
  }

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }
  # user wants to see own carts only: generate SQL condition
  if (param('own_carts_only') && param('own_carts_only') eq 'y') {
     $own_carts_only = 'y';

     # restrict to matings whose mating_matingend_datetime is at least 21 days before current date
     $own_carts_only_sql = "where cart_user in ($user_project_colleagues_sql)";
  }
  else {          # otherwise skip age condition from SQL
     $own_carts_only     = 'n';
     $own_carts_only_sql = "where (cart_user in ($user_project_colleagues_sql) or cart_is_public = 'y')";
  }

  $page = h2("Stored carts " . a({-href=>"$url?job=load%20cart&own_carts_only=$own_carts_only", -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})))
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select cart_id, cart_name, cart_content, cart_creation_datetime, cart_end_datetime, cart_user, cart_is_public, user_name, contact_first_name, contact_last_name
            from   carts
                   left join users    on      user_id = cart_user
                   left join contacts on user_contact = contact_id
            $own_carts_only_sql
            order  by $columns->{$sort_column} $sort_order
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if there are no carts: tell and quit
  unless ($rows > 0) {
    $page .= p("No carts found.")
             . p(a({-href=>"$url?choice=show_carts"}, "list all carts"));
    return $page;
  }

  # ... otherwise continue: generate cart table
  $page .= h3("Found $rows "
              . (($own_carts_only eq 'y')?" own ":"")
              . "carts. [Select: " . a({-href=>"$url?choice=show_carts&own_carts_only=n"}, "all carts") . "&nbsp;or&nbsp;" . a({-href=>"$url?choice=show_carts&own_carts_only=y"}, "only own carts"). "]")

           . (($rows > $show_rows)
              ?p(b("Browse carts: ")
               . (($start_row > 1)?a({-href=>"$url?choice=show_carts&own_carts_only=$own_carts_only&sort_by=$sort_column&sort_order=$sort_order" . '&start_row=1'}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=show_carts&own_carts_only=$own_carts_only&sort_by=$sort_column&sort_order=$sort_order" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=show_carts&own_carts_only=$own_carts_only&sort_by=$sort_column&sort_order=$sort_order" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=show_carts&own_carts_only=$own_carts_only&sort_by=$sort_column&sort_order=$sort_order" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
              )
              :''
             )
           . start_table( {-border=>"1", -summary=>"mating_overview"})
           . Tr(
               th({-align=>'right'}, a({-href=>"$url?choice=show_carts&own_carts_only=$own_carts_only&sort_by=id&&sort_order=$rev_order->{$sort_order}&start_row=$start_row"},   "cart id")),
               th({-align=>'left'},  a({-href=>"$url?choice=show_carts&own_carts_only=$own_carts_only&sort_by=name&&sort_order=$rev_order->{$sort_order}&start_row=$start_row"}, "cart name")),
               th("public"),
               th("mice in cart"),
               th(a({-href=>"$url?choice=show_carts&own_carts_only=$own_carts_only&sort_by=date&&sort_order=$rev_order->{$sort_order}&start_row=$start_row"}, "cart stored")),
               th(a({-href=>"$url?choice=show_carts&own_carts_only=$own_carts_only&sort_by=user&&sort_order=$rev_order->{$sort_order}&start_row=$start_row"}, "stored by")),
               th("load cart"),
               th("delete cart")
             );

  # ... then loop over all carts
  for ($i=0; $i<$rows; $i++) {               # $rows is the number of racks returned from the above query
      if ($i+1 < $start_row )              { next; }               # skip all rows with (row index < $start_row)
      if ($i+1 >= $start_row + $show_rows) { last; }               # skip all rows with (row index > $start_row+$show_rows): exit loop

      $row = $result->[$i];                  # get a reference on the current result row

      # regenerate mouse list from comma-separated cart content string
      @mice = split(/,/, $row->{'cart_content'});
      $mice_in_cart = scalar @mice;                 # how many mice in cart

      # remove quoting marks
      $unquoted_cart_name = $row->{'cart_name'};
      $unquoted_cart_name =~ s/'//g;

      # generate the current rack summary row
      $page .= Tr( {-bgcolor=>($row->{'cart_user'} == $user_id)?'#AAFFFF':'white'},
                 td({-align=>'right'}, $row->{'cart_id'}),
                 td({-align=>'left'}, $unquoted_cart_name),
                 td({-align=>'center'}, ($row->{'cart_is_public'} eq 'y')?'y':''),
                 td({-align=>'center'}, $mice_in_cart),
                 td(format_datetime2simpledate($row->{'cart_creation_datetime'})),
                 td($row->{'contact_first_name'} . ' ' . $row->{'contact_last_name'}),
                 td(a({-href=>"$url?choice=restore_cart&cart_id=" . $row->{'cart_id'}}, "load cart")),
                 td(a({-href=>"$url?choice=delete_cart&&own_carts_only=$own_carts_only&cart_id="  . $row->{'cart_id'}}, "delete cart"))
               );
  }

  $page .= end_table();

  return $page;
}
# end of view_carts()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE017 view_healthreport                            show health report
sub view_healthreport {                                  my $sr_name = 'SR_VIE017';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $healthreport_id   = param('healthreport_id');
  my $url               = url();
  my $session           = $global_var_href->{'session'};           # get session handle
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # check input: is $healthreport_id given? is it a number?
  if (!param('healthreport_id') || param('healthreport_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid healthreport id"));
     return $page;
  }

  # first table
  $page .= h2("Health report ")
           . hr();

  $sql = qq(select healthreport_id, healthreport_document_URL, healthreport_date, healthreport_status
            from   healthreports
            where  healthreport_id = ?
           );

  @sql_parameters = ($healthreport_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("No details on this health report");
     return $page;
  }

  # else continue: get result handle to generate details table
  $row = $result->[0];

  $page .= h3("Health report ")
           . table( {-border=>1, -summary=>"table"},
               Tr(
                 th("Date of health report"),
                 td(format_sql_date2display_date($row->{'healthreport_date'}))
               ),
               Tr(
                 th("URL to health report"),
                 td(a({-href=>"$row->{'healthreport_document_URL'}"}, "$row->{'healthreport_document_URL'}"))
               ),
               Tr(
                 th("Status"),
                 td("$row->{'healthreport_status'}")
               )
             );

  return $page;
}
# end of view_healthreport
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE018 history_of_cage():                           show history of a cage
sub history_of_cage {                                    my $sr_name = 'SR_VIE018';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $cage_id           = param('cage_id');
  my ($page, $sql, $result, $rows, $row, $i);
  my ($in_rack_from, $in_rack_to);
  my @cage_mates;
  my @sql_parameters;

  # check input: is cage id given? is it a number?
  if (!param('cage_id') || param('cage_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid cage id"));
     return $page;
  }

  $page .= h2("Rack history of cage ID " . a({-href=>"$url?choice=cage_view&cage_id=$cage_id"}, $cage_id))
           . hr();

  # find all racks in which this cage has been placed ever
  $sql = qq(select location_room, location_rack, c2l_datetime_from, c2l_datetime_to
            from   cages2locations
                   join locations on location_id = c2l_location_id
            where  c2l_cage_id = ?
            order  by c2l_datetime_from asc
           );

  @sql_parameters = ($cage_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no cage history found: tell and quit
  unless ($rows > 0) {
     $page .= p("No rack history for cage ID " . a({-href=>"$url?choice=cage_view&cage_id=$cage_id"}, $cage_id));
     return $page;
  }

  # else continue: display historic cage occupation table
  $page .= h3(b("Cage ID " . a({-href=>"$url?choice=cage_view&cage_id=$cage_id"}, $cage_id) . " was assigned to the following racks:"))
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(" in rack       "),
               th(" from          "),
               th(" to            "),
               th(" cagemates     ")
             );

  # loop over all historic occupations for this cage
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      # cage placed in rack from ... to
      $in_rack_from = $row->{'c2l_datetime_from'};
      $in_rack_to   = $row->{'c2l_datetime_to'};

      # find out mice sitting in this cage during this particular time period (using fake mouse '1' as the one to exclude from cagemates is a little trick)
      @cage_mates = get_cage_mates($global_var_href, $cage_id, $in_rack_from, $in_rack_to, 1);

      $page .= Tr({-align=>'center'},
                 td(b($row->{'location_room'} . '-' . $row->{'location_rack'})),
                 td(format_sql_datetime2display_datetime($in_rack_from)),
                 td((format_sql_datetime2display_datetime($in_rack_to) ne '-')?format_sql_datetime2display_datetime($in_rack_to):'(still there)'),
                 td({-align=>'left'}, join(", ", @cage_mates))
               );

  }

  $page .= end_table();

  return $page;
}
# end of history_of_cage
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE019 experiment_overview():                       experiment overview
sub experiment_overview {                                my $sr_name = 'SR_VIE019';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  $page = h2("Experiment overview " . a({-href=>"$url?choice=experiment_overview", -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})));

  $sql = qq(select experiment_id, experiment_name, experiment_recordname, experiment_URL,
                   contact_first_name, contact_last_name, experiment_licence_valid_from, experiment_licence_valid_to, experiment_animalnumber
            from   experiments
                   left join contacts on experiment_granted_to_contact = contact_id
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no imports found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No experiments in the database");
     return $page;
  }

  # else continue: display imports table
  $page .= start_table( {-border=>"1", -summary=>"experiment_overview"})
          . Tr( {-align=>'center'},
              th("Experiment"),
              th("Experiment name"),
              th("Granted to"),
              th("Valid from"),
              th("Valid to"),
              th("Animals granted"),
              #th("Animals used")
            );

  # ... loop over all imports
  for ($i=0; $i<$rows; $i++) {               # $rows is the number of racks returned from the above query
      $row = $result->[$i];                  # get a reference on the current result row

      $page .= Tr({-align=>'center'},
                 td(a({-href=>"$url?choice=experiment_view&experiment_id=" . $row->{'experiment_id'}}, $row->{'experiment_name'})),
                 td(qq("$row->{'experiment_recordname'}")),
                 td($row->{'contact_first_name'} . ' ' . $row->{'contact_last_name'}),
                 td(format_datetime2simpledate($row->{'experiment_licence_valid_from'})),
                 td(format_datetime2simpledate($row->{'experiment_licence_valid_to'})),
                 td($row->{'experiment_animalnumber'}),
                 #td(count_mice_in_experiment($global_var_href, $row->{'experiment_id'}))
               );
  }

  $page .= end_table();

  return $page;
}
# end of experiment_overview()
#------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE020 experiment_view                              show experiment details
sub experiment_view {                                    my $sr_name = 'SR_VIE020';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $experiment_id     = param('experiment_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # check input: is experiment id given? is it a number?
  if (!param('experiment_id') || param('experiment_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid experiment id"));
     return $page;
  }

  # first table
  $page .= h2(qq(Experiment details))
           . hr();

  $sql = qq(select experiment_id, experiment_name, experiment_recordname, experiment_URL,
                   contact_id, contact_title, contact_first_name, contact_last_name,
                   experiment_licence_valid_from, experiment_licence_valid_to, experiment_animalnumber
            from   experiments
                   left join contacts on experiment_granted_to_contact = contact_id
            where  experiment_id = ?
           );

  @sql_parameters = ($experiment_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no such contact found, tell
  unless ($rows > 0) {
     $page .= p("No details on this experiment");
     return $page;
  }

  # otherwise continue: get result handle
  $row = $result->[0];

  $page .= h3(qq(Experiment details))
           . table( {-border=>1, -summary=>"table"},
               Tr(
                 th("Short name"),
                 td(qq("$row->{'experiment_name'}"))
               ),
               Tr(
                 th("Long name"),
                 td($row->{'experiment_recordname'})
               ),
               Tr(
                 th("Document"),
                 td($row->{'experiment_URL'})
               ),
               Tr(
                 th("Grant period"),
                 td(format_datetime2simpledate($row->{'experiment_licence_valid_from'}) . ' - ' . format_datetime2simpledate($row->{'experiment_licence_valid_to'}))
               ),
               Tr(
                 th("Animals granted"),
                 td({-align=>'right'}, $row->{'experiment_animalnumber'})
               ),
#                Tr(
#                  th("Animals used"),
#                  td({-align=>'right'}, count_mice_in_experiment($global_var_href, $row->{'experiment_id'}))
#                ),
               Tr(
                 th("Granted to"),
                 td(a({-href=>"$url?choice=contact_view&contact_id=" . $row->{'contact_id'}}, $row->{'contact_title'} . ' ' . $row->{'contact_first_name'} . ' ' . $row->{'contact_last_name'}))
               )
             );


  return $page;
}
# end of experiment_view
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE021 line_overview():                             line overview
sub line_overview {                                      my $sr_name = 'SR_VIE021';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $show_rows         = $global_var_href->{'show_rows'};
  my $url               = url();
  my $start_row         = param('start_row');
  my $only_gvo          = param('only_gvo');
  my $only_living       = param('only_living');
  my $first_letter      = param('first_letter');
  my ($page, $sql, $result, $rows, $row, $i);
  my ($males_from_this_line, $females_from_this_line, $total_total);
  my ($dead_males_from_this_line, $total_males_from_this_line, $dead_females_from_this_line, $total_females_from_this_line);
  my ($last_died_date, $last_died_date_cw, $gvo_only, $gvo_only_sql, $living_only, $living_only_sql, $first_letter_sql);
  my @sql_parameters;

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  #################################################################################
  # user wants to see genetically modified mouse lines only: generate SQL condition
  if (param('only_gvo') && param('only_gvo') eq 'y') {
     $gvo_only = 'y';

     # restrict to GVO mouse lines
     $gvo_only_sql = qq(and gli_mouse_line_is_gvo = 'y');
  }
  else {
     $gvo_only     = 'n';
     $gvo_only_sql = '';
  }

  #################################################################################
  # user wants to see mouse lines with living mice only: generate SQL condition
  if (param('only_living') && param('only_living') eq 'y') {
     $living_only = 'y';

     # restrict to mouse lines with living mice
     $living_only_sql = qq(and ((select count(mouse_id)
                                 from   mice
                                 where  mouse_line = line_id
                                        and mouse_deathorexport_datetime IS NULL) > 0));
  }
  else {
     $living_only     = 'n';
     $living_only_sql = '';
  }

  #################################################################################
  # user wants to filter for mouse lines with given first letter: generate SQL condition
  if (param('first_letter') && param('first_letter') =~ /[A-Z]/) {
     $first_letter_sql = qq(and line_name like '$first_letter%');
  }
  else {
     $first_letter_sql = '';
  }
  #################################################################################


  $page = h2("Mouse lines overview "
             . a({-href=>"$url?choice=line_overview", -title=>"reload page"},
                 img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
               )
          )
          . hr()
          . start_form(-action => url())
          . table( {-border=>0},
              Tr(td(b('show genetically modified lines only: ')),
                 td(radio_group(-name=>'only_gvo', -values=>['y', 'n'], -default=>'n'))
              ) .
              Tr(td(b('show lines with living mice only: ')),
                 td(radio_group(-name=>'only_living', -values=>['y', 'n'], -default=>'y'))
              ) .
              Tr(td(b('show only lines starting with: ')),
                 td(radio_group(-name=>'first_letter', -values=>['ignore', 'A'..'Z'], -default=>'ignore'))
              )
            )
          . br()
          . submit(-name => "choice", -value=>"apply mouse line filters")
          . end_form()
          . hr();


  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select line_id, line_name, line_long_name, line_order, line_show, line_info_URL, line_comment, gli_mouse_line_is_gvo
            from   mouse_lines
                   join GTAS_line_info on line_id = gli_mouse_line_id
                   $gvo_only_sql
                   $living_only_sql
                   $first_letter_sql
            where  line_name not in (?, ?)
            order  by line_name asc
           );

  @sql_parameters = ('new line', 'choose line');

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no mouse lines found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No mouse line found. ");
    return $page;
  }

  # else: first generate table header ...
  $page .= h3("$rows mouse lines found")
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=line_overview&first_letter=$first_letter&only_gvo=$gvo_only&only_living=$living_only" . '&start_row=1'}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=line_overview&first_letter=$first_letter&only_gvo=$gvo_only&only_living=$living_only" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=line_overview&first_letter=$first_letter&only_gvo=$gvo_only&only_living=$living_only" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=line_overview&first_letter=$first_letter&only_gvo=$gvo_only&only_living=$living_only" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
              )
              :''
             )
           . start_table( {-border=>"1", -summary=>"line_overview"})
           . Tr( {-align=>'center'},
               th({-rowspan=>2, -valign=>'bottom'}, "#"),
               th({-rowspan=>2, -valign=>'bottom'}, "line name (short)"),
               th({-rowspan=>2, -valign=>'bottom'}, "line name (long)"),
               th({-rowspan=>2, -valign=>'bottom'}, "line is GVO"),
               td({-colspan=>3}, b("alive") . br() . small('(click number for Excel file)')),
               td({-colspan=>3, -valign=>'top'}, b("dead") ),
               td({-colspan=>3, -valign=>'top'}, b("total")  . br() . small('(alive+dead)')),
               td({-colspan=>2, -valign=>'top'}, b("last died at") ),
             )
           . Tr( {-align=>'center'},
               th("males"),
               th("females"),
               th("both"),
               th("males"),
               th("females"),
               th("both"),
               th("males"),
               th("females"),
               th("both"),
               th("date"),
               th("week/year")
             );

  # ... then loop over all rows
  for ($i=0; $i<$rows; $i++) {
      if ($i+1 < $start_row )              { next; }               # skip all rows with (row index < $start_row)
      if ($i+1 >= $start_row + $show_rows) { last; }               # skip all rows with (row index > $start_row+$show_rows): exit loop

      $row = $result->[$i];

      # count living males from this line
      $males_from_this_line         = get_number_of_mice_from_line($global_var_href, $row->{'line_id'}, 'm', 'alive');
      $dead_males_from_this_line    = get_number_of_mice_from_line($global_var_href, $row->{'line_id'}, 'm', 'dead');
      $total_males_from_this_line   = get_number_of_mice_from_line($global_var_href, $row->{'line_id'}, 'm', 'total');

      # count living females from this line
      $females_from_this_line       = get_number_of_mice_from_line($global_var_href, $row->{'line_id'}, 'f', 'alive');
      $dead_females_from_this_line  = get_number_of_mice_from_line($global_var_href, $row->{'line_id'}, 'f', 'dead');
      $total_females_from_this_line = get_number_of_mice_from_line($global_var_href, $row->{'line_id'}, 'f', 'total');

      $total_total += $females_from_this_line + $males_from_this_line;

      if ($females_from_this_line + $males_from_this_line == 0) {
         ($last_died_date, $last_died_date_cw) = get_date_when_last_mouse_of_this_line_died($global_var_href, $row->{'line_id'});
      }
      else {
         ($last_died_date, $last_died_date_cw) = ('', '');
      }

      # generate the current mouse line row
      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td(a({-href=>"$url?choice=line_view&line_id=$row->{'line_id'}", -title=>"click for line details"}, "$row->{'line_name'}") ),
                 td($row->{'line_long_name'}),
                 td($row->{'gli_mouse_line_is_gvo'}),
                 td({-align=>'right'}, a({-href=>"$url?choice=report_to_excel&line=" . $row->{'line_id'} . "&sex=2"}, $males_from_this_line)),
                 td({-align=>'right'}, a({-href=>"$url?choice=report_to_excel&line=" . $row->{'line_id'} . "&sex=3"}, $females_from_this_line)),
                 td({-align=>'right'}, a({-href=>"$url?choice=report_to_excel&line=" . $row->{'line_id'} . "&sex=1"}, $females_from_this_line + $males_from_this_line)),
                 td({-align=>'right'}, $dead_males_from_this_line),
                 td({-align=>'right'}, $dead_females_from_this_line),
                 td({-align=>'right'}, $dead_males_from_this_line + $dead_females_from_this_line),
                 td({-align=>'right'}, $total_males_from_this_line),
                 td({-align=>'right'}, $total_females_from_this_line),
                 td({-align=>'right'}, $total_males_from_this_line + $total_females_from_this_line),
                 td($last_died_date),
                 td($last_died_date_cw)
               );
  }

#   # overall summary
#   if ($start_row + $show_rows > $rows) {
#       # count all living males
#       $sql = qq(select count(mouse_id) as males_from_this_line
#                 from   mice
#                 where  mouse_sex = ?
#                        and mouse_deathorexport_datetime IS NULL
#              );
#
#       @sql_parameters = ('m');
#
#       ($males_from_this_line) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};
#
#       # count all living females
#       $sql = qq(select count(mouse_id) as females_from_this_line
#                 from   mice
#                 where  mouse_sex = ?
#                        and mouse_deathorexport_datetime IS NULL
#              );
#
#       @sql_parameters = ('f');
#
#       ($females_from_this_line) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};
#
#       $total_total += $females_from_this_line + $males_from_this_line;
#
#       $page .=   Tr(
#                    td({-colspan=>'9'}, '')
#                  )
#                . Tr({-align=>'center'},
#                    td({-colspan=>'4'}, b('total living mice (all lines)')),
#                    td({-align=>'right'}, a({-href=>"$url?choice=report_to_excel&line=all&sex=2"}, $males_from_this_line)),
#                    td({-align=>'right'}, a({-href=>"$url?choice=report_to_excel&line=all&sex=3"}, $females_from_this_line)),
#                    td({-align=>'right'}, a({-href=>"$url?choice=report_to_excel&line=all&sex=1"}, $females_from_this_line + $males_from_this_line))
#                  );
#   }

  $page .= end_table();

  return $page;
}
# end of line_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE022 line_view                                    line view
sub line_view {                                          my $sr_name = 'SR_VIE022';
  my ($global_var_href)             = @_;                                       # get reference to global vars hash
  my $session                       = $global_var_href->{'session'};            # get session handle
  my $user_id                       = $session->param(-name=>'user_id');
  my $dbh                           = $global_var_href->{'dbh'};                # DBI database handle
  my $url                           = url();
  my $line_id                       = param('line_id');
  my $line_comment                  = param('line_comment');
  my $gli_mouse_line_is_gvo         = param('gli_mouse_line_is_gvo');
  my $gli_Projektnr                 = param('gli_Projektnr');
  my $gli_Institutscode             = param('gli_Institutscode');
  my $gli_SysID                     = param('gli_SysID');
  my $gli_OrgCode                   = param('gli_OrgCode');
  my $gli_TepID                     = param('gli_TepID');
  my $gli_GVO_ErzeugtAm             = param('gli_GVO_ErzeugtAm');
  my $gli_Spenderorganismen         = param('gli_Spenderorganismen');
  my $gli_Empfaengerorganismen      = param('gli_Empfaengerorganismen');
  my $gli_Risikogruppe_Empfaenger   = param('gli_Risikogruppe_Empfaenger');
  my $gli_Risikogruppe_GVO          = param('gli_Risikogruppe_GVO');
  my $gli_Risikogruppe_Spender      = param('gli_Risikogruppe_Spender');
  my $gli_Vektoren                  = param('gli_Vektoren');
  my $gli_GVO_Merkmale              = param('gli_GVO_Merkmale');
  my $gli_Bemerkungen               = param('gli_Bemerkungen');
  my $gli_Nukleinsaeure_Bezeichnung = param('gli_Nukleinsaeure_Bezeichnung');
  my $gli_Nukleinsaeure_Merkmale    = param('gli_Nukleinsaeure_Merkmale');
  my $gli_Lagerung                  = param('gli_Lagerung');
  my $gli_Sonstiges                 = param('gli_Sonstiges');
  my $gli_generate_GTAS_report      = param('gli_generate_GTAS_report');
  my $datetime_now                  = get_current_datetime_for_sql();
  my ($living_males, $living_females, $remarks, $gli_GVO_ErzeugtAm_sql);
  my ($line_comment_sql);
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # check input: is line id given? is it a number?
  if (!param('line_id') || param('line_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid line id"));
     return $page;
  }

  #####################################################################
  # update line comment if requested
  if (defined(param('job')) && param('job') eq "update line comment") {

     $line_comment_sql = $line_comment;
     $line_comment_sql =~ s/'|;|-{2}//g;                  # remove dangerous content

     # update line comment
     $dbh->do("update  mouse_lines
               set     line_comment = ?
               where   line_id = ?
              ", undef, $line_comment_sql, $line_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update line comment)", $sr_name . "-" . __LINE__);

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdate_line_comment\t$line_id\tnew:$line_comment_sql");

     $remarks = p({-class=>'red'}, 'Line comment updated')
                . hr();
  }
  #####################################################################

  #####################################################################
  # update line comment if requested
  if (defined(param('job')) && param('job') eq "update GTAS information") {

     # check date format (GVO_ErzeugtAm)
     if ($gli_GVO_ErzeugtAm !~ /[0-9]{2}\.[0-9]{2}\.[0-9]{4}/) {
        $gli_GVO_ErzeugtAm_sql = '0000-00-00';
        $remarks .= p({-class=>'red'}, 'Please check date (gli_GVO_ErzeugtAm)');
     }
     else {
        $gli_GVO_ErzeugtAm_sql = format_display_date2sql_date($gli_GVO_ErzeugtAm);
     }

     # check input: gli_Spenderorganismen
     if (!param('gli_Spenderorganismen') || param('gli_Spenderorganismen') eq '') {
        $remarks .= p({-class=>'red'}, 'Please check field: Spenderorganismen');
     }

     # check input: gli_Risikogruppe_GVO
     if (!param('gli_Risikogruppe_GVO') || param('gli_Risikogruppe_GVO') eq '') {
        $remarks .= p({-class=>'red'}, 'Please check field: Risikogruppe_GVO');
     }

     # check input: gli_Risikogruppe_Spender
     if (!param('gli_Risikogruppe_Spender') || param('gli_Risikogruppe_Spender') eq '') {
        $remarks .= p({-class=>'red'}, 'Please check field: Risikogruppe_Spender');
     }

     # check input: gli_Vektoren
     if (!param('gli_Vektoren') || param('gli_Vektoren') eq '') {
        $remarks .= p({-class=>'red'}, 'Please check field: Vektoren');
     }

     # check input: gli_GVO_Merkmale
     if (!param('gli_GVO_Merkmale') || param('gli_GVO_Merkmale') eq '') {
        $remarks .= p({-class=>'red'}, 'Please check field: GVO_Merkmale');
     }

     # update GTAS information for this line
     $dbh->do("update  GTAS_line_info
               set     gli_mouse_line_is_gvo = ?, gli_Projektnr         = ?, gli_Institutscode = ?, gli_SysID            = ?, gli_OrgCode = ?,
                       gli_Bemerkungen       = ?, gli_Spenderorganismen = ?, gli_Vektoren      = ?, gli_GVO_Merkmale     = ?,
                       gli_Lagerung          = ?, gli_Sonstiges         = ?, gli_TepID         = ?, gli_Risikogruppe_GVO = ?,
                       gli_Nukleinsaeure_Bezeichnung = ?, gli_Nukleinsaeure_Merkmale   = ?, gli_Empfaengerorganismen = ?,
                       gli_Risikogruppe_Empfaenger   = ?, gli_Risikogruppe_Spender     = ?, gli_GVO_ErzeugtAm        = ?, gli_generate_GTAS_report = ?
               where   gli_mouse_line_id = ?
              ", undef,
                 $gli_mouse_line_is_gvo, $gli_Projektnr, $gli_Institutscode, $gli_SysID, $gli_OrgCode,
                 $gli_Bemerkungen, $gli_Spenderorganismen, $gli_Vektoren, $gli_GVO_Merkmale,
                 $gli_Lagerung, $gli_Sonstiges, $gli_TepID, $gli_Risikogruppe_GVO,
                 $gli_Nukleinsaeure_Bezeichnung, $gli_Nukleinsaeure_Merkmale, $gli_Empfaengerorganismen,
                 $gli_Risikogruppe_Empfaenger, $gli_Risikogruppe_Spender, $gli_GVO_ErzeugtAm_sql, $gli_generate_GTAS_report,
                 $line_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update GTAS information)", $sr_name . "-" . __LINE__);

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdate_GTAS_information\t$line_id\tis_gvo:$gli_mouse_line_is_gvo"
                                      . "\tProjektnr=$gli_Projektnr\tInstitutscode=$gli_Institutscode\tSysID=$gli_SysID\tOrgCode=$gli_OrgCode"
                                      . "\tTepID=$gli_TepID\tGVO_ErzeugtAm=$gli_GVO_ErzeugtAm\tSpenderorganismen=$gli_Spenderorganismen"
                                      . "\tEmpfaengerorganismen=$gli_Empfaengerorganismen\tRisikogruppe_Empfaenger=$gli_Risikogruppe_Empfaenger"
                                      . "\tRisikogruppe_GVO=$gli_Risikogruppe_GVO\tRisikogruppe_Spender=$gli_Risikogruppe_Spender"
                                      . "\tVektoren=$gli_Vektoren\tGVO_Merkmale=$gli_GVO_Merkmale\tBemerkungen=$gli_Bemerkungen"
                                      . "\tNukleinsaeure_Bezeichnung=$gli_Nukleinsaeure_Bezeichnung\tNukleinsaeure_Merkmale=$gli_Nukleinsaeure_Merkmale"
                                      . "\tLagerung=$gli_Lagerung\tSonstiges=$gli_Sonstiges"
     );

     $remarks .= p({-class=>'red'}, 'GTAS information updated')
                . hr();
  }
  #####################################################################

  # first table
  $page .= h2("Mouse line information "
             . a({-href=>"$url?choice=line_view&line_id=$line_id", -title=>"reload page"},
                 img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
               ) . ' (' . a({-href=>"$url?choice=line_overview"}, 'all lines')
           . ')')
           . hr()
           . $remarks;

  $sql = qq(select line_id, line_name, line_long_name, line_order, line_show, line_info_URL, line_comment
            from   mouse_lines
            where  line_id = ?
           );

  @sql_parameters = ($line_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("No details on this mouse line");
     return $page;
  }

  # get number of living male animals from this line
  $sql = qq(select count(mouse_id) as living_males
            from   mice
            where  mouse_line = ?
                   and mouse_sex = ?
                   and mouse_deathorexport_datetime IS NULL
           );

  @sql_parameters = ($line_id, 'm');

  ($living_males) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # get number of living female animals from this line
  $sql = qq(select count(mouse_id) as living_females
            from   mice
            where  mouse_line = ?
                   and mouse_sex = ?
                   and mouse_deathorexport_datetime IS NULL
           );


  @sql_parameters = ($line_id, 'f');

  ($living_females) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # else continue: get result handle to generate details table
  $row = $result->[0];

  $page .= h3("1) Mouse Line " . qq("$row->{'line_name'}" ))
           . table( {-border=>1, -summary=>"table"},
               Tr(
                 th("Name of mouse line (short)"),
                 td($row->{'line_name'})
               ),
               Tr(
                 th("Name of mouse line (long)"),
                 td($row->{'line_long_name'})
               ),
               Tr(
                 th("Mouse line comment"),
                 td(start_form(-action => url())
                    . textarea(-name=>"line_comment", -columns=>"80", -rows=>"5",
                               -value=>($row->{'line_comment'} ne '')?$row->{'line_comment'}:'no comments for this line'
                      )
                    . br()
                    . hidden('line_id')
                    . submit(-name => "job", -value=>"update line comment")
                    . end_form()
                 )
               ),
               Tr(
                 th("Currently living"),
                 td( table({-border=>0},
                        Tr( td({-align=>'right'}, $living_males),
                            td('males')
                        ),
                        Tr( td({-align=>'right'}, $living_females),
                            td('females')
                        )
                     )
                 )
               ),
               Tr(
                 th("Phenotyping data overview"),
                 td(a({-href=>"$url?choice=data_overview_for_line&line=$line_id"}, "click to see phenotyping data overview"))
               ),
               Tr(
                 th("Breeding statistics"),
                 td(a({-href=>"$url?choice=line_breeding_stats&line=$line_id"}, "click to see breeding statistics for this line")
                    . br()
                    . a({-href=>"$url?choice=line_breeding_genotype_stats&line=$line_id"}, "click to see genotype statistics for this line")
                 )
               )
             );

  #################################################
  # GTAS info, second table
  $page .= hr()
           . h3("2) GTAS information (specific for Helmholtz Zentrum M&uuml;nchen)");

  $sql = qq(select *
            from   GTAS_line_info
            where  gli_mouse_line_id = ?
           );

  @sql_parameters = ($line_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  if ($rows == 0) {
     $page .= p("No GTAS info for this mouse line");
  }
  else {
     # else continue: get result handle to generate details table
     $row = $result->[0];

     if (current_user_is_admin($global_var_href) eq 'y') {

        $page .= start_form(-action => url())
                 . hidden('line_id')
                 . p(small('[mandatory fields are grey, optional fields are white]'))
                 . table( {-border=>1, -summary=>"table"},
                     Tr({-bgcolor=>'lightgrey'},
                       th("Genetically modified (GVO)?"),
                       td(radio_group(-name=>'gli_mouse_line_is_gvo',       -values=>['y', 'n'],           -default=>$row->{'gli_mouse_line_is_gvo'})),
                       td('')
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("Generate GTAS report for this mouse line?"),
                       td(radio_group(-name=>'gli_generate_GTAS_report',    -values=>['y', 'n'],           -default=>$row->{'gli_generate_GTAS_report'})),
                       td("This is usually set to \"n\" after generating a GTAS report.")
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("Projektnummer"),
                       td(textfield(-name => "gli_Projektnr",               -size=>"20", -maxlength=>"20", -value=>$row->{'gli_Projektnr'})),
                       td('please do not change')
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("Institutscode"),
                       td(textfield(-name => "gli_Institutscode",           -size=>"20", -maxlength=>"20", -value=>$row->{'gli_Institutscode'})),
                       td('please do not change')
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("SysID"),
                       td(textfield(-name => "gli_SysID",                   -size=>"10", -maxlength=>"10", -value=>$row->{'gli_SysID'})),
                       td('please do not change')
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("OrgCode"),
                       td(textfield(-name => "gli_OrgCode",                 -size=>"10", -maxlength=>"10", -value=>$row->{'gli_OrgCode'})),
                       td('please do not change')
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("TepID"),
                       td(textfield(-name => "gli_TepID",                   -size=>"30", -maxlength=>"30", -value=>$row->{'gli_TepID'})),
                       td('please do not change')
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("GVO_ErzeugtAm"),
                       td(textfield(-name => "gli_GVO_ErzeugtAm",           -size=>"10", -maxlength=>"10", -value=>format_sql_date2display_date($row->{'gli_GVO_ErzeugtAm'}))),
                       td('date of first import or date of re-import after stock decreased to 0'
                          . ((format_sql_date2display_date($row->{'gli_GVO_ErzeugtAm'}) eq '0000-00-00' || format_sql_date2display_date($row->{'gli_GVO_ErzeugtAm'}) eq '-')
                             ?br() . span({-class=>'red'}, 'please enter valid date')
                             :''
                            )
                       )
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("Spenderorganismen"),
                       td(textfield(-name=>"gli_Spenderorganismen",         -size=>"60", -maxlength=>"60", -value=>$row->{'gli_Spenderorganismen'} )),
                       td(''
                          . (($row->{'gli_Spenderorganismen'} eq '')
                             ?br() . span({-class=>'red'}, 'please enter: Spenderorganismen')
                             :''
                            )
                       )
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("Empf&#228;ngerorganismen"),
                       td(textfield(-name=>"gli_Empfaengerorganismen",      -size=>"60", -maxlength=>"60", -value=>$row->{'gli_Empfaengerorganismen'} )),
                       td(''
                          . (($row->{'gli_Empfaengerorganismen'} eq '')
                             ?br() . span({-class=>'red'}, 'please enter: Empfaengerorganismen')
                             :''
                            )
                       )
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("Risikogruppe-Empf&#228;nger"),
                       td(textfield(-name => "gli_Risikogruppe_Empfaenger", -size=>"10", -maxlength=>"10", -value=>$row->{'gli_Risikogruppe_Empfaenger'})),
                       td('')
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("Risikogruppe-GVO"),
                       td(textfield(-name => "gli_Risikogruppe_GVO",        -size=>"10", -maxlength=>"10", -value=>$row->{'gli_Risikogruppe_GVO'})),
                       td(''
                          . (($row->{'gli_Risikogruppe_GVO'} eq '')
                             ?br() . span({-class=>'red'}, 'please enter: Risikogruppe_GVO')
                             :''
                            )
                       )
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("Risikogruppe-Spender"),
                       td(textfield(-name => "gli_Risikogruppe_Spender",    -size=>"10", -maxlength=>"10", -value=>$row->{'gli_Risikogruppe_Spender'})),
                       td(''
                          . (($row->{'gli_Risikogruppe_Spender'} eq '')
                             ?br() . span({-class=>'red'}, 'please enter: Risikogruppe_Spender')
                             :''
                            )
                       )
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("Vektoren"),
                       td(textarea(-name=>"gli_Vektoren",                  -columns=>"60", -rows=>"2",     -value=>$row->{'gli_Vektoren'} )),
                       td(''
                          . (($row->{'gli_Vektoren'} eq '')
                             ?br() . span({-class=>'red'}, 'please enter: Vektoren')
                             :''
                            )
                       )
                     ),
                     Tr({-bgcolor=>'lightgrey'},
                       th("GVO-Merkmale"),
                       td(textarea(-name=>"gli_GVO_Merkmale",              -columns=>"60", -rows=>"2",     -value=>$row->{'gli_GVO_Merkmale'} )),
                       td(''
                          . (($row->{'gli_GVO_Merkmale'} eq '')
                             ?br() . span({-class=>'red'}, 'please enter: GVO_Merkmale')
                             :''
                            )
                       )
                     ),
                     Tr(
                       th("Bemerkungen"),
                       td(textarea(-name=>"gli_Bemerkungen",               -columns=>"60", -rows=>"2",     -value=>$row->{'gli_Bemerkungen'} )),
                       td('')
                     ),
                     Tr(
                       th("Nukleins&#228;ure-Bezeichnung"),
                       td(textarea(-name=>"gli_Nukleinsaeure_Bezeichnung", -columns=>"60", -rows=>"2",     -value=>$row->{'gli_Nukleinsaeure_Bezeichnung'} )),
                       td('')
                     ),
                     Tr(
                       th("Nukleins&#228;ure-Merkmale"),
                       td(textarea(-name=>"gli_Nukleinsaeure_Merkmale",    -columns=>"60", -rows=>"2",     -value=>$row->{'gli_Nukleinsaeure_Merkmale'} )),
                       td('')
                     ),
                     Tr(
                       th("Lagerung"),
                       td(textarea(-name=>"gli_Lagerung",                  -columns=>"60", -rows=>"2",     -value=>$row->{'gli_Lagerung'} )),
                       td('')
                     ),
                     Tr(
                       th("Sonstiges"),
                       td(textarea(-name=>"gli_Sonstiges",                 -columns=>"60", -rows=>"2",     -value=>$row->{'gli_Sonstiges'} )),
                       td('')
                     )
                   )
                   . submit(-name => "job", -value=>"update GTAS information")
                   . end_form();
     }
     else {
        $page .= p('Sorry, you need admin privileges to access this information');
     }
  }
  #################################################

  # list assigned gene loci for this line

  $page .= hr({-width=>"50%", align=>"left"})
           . h3("3) Gene loci assigned to this line")
           . hr();

  $sql = qq(select ml2g_gene_id, gene_name
            from   mouse_lines2genes
                   left join genes on gene_id = ml2g_gene_id
            where  ml2g_mouse_line_id = ?
         );

  @sql_parameters = ($line_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows == 0) {
     $page .= p("No gene loci assigned to this line");
  }
  else {
     $page .= start_table({-border=>1})
              . Tr( th("gene / locus")
                );

     # loop over gene loci
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $page .= Tr( td(a({-href=>"$url?choice=gene_details&gene_id=" . $row->{'ml2g_gene_id'}}, $row->{'gene_name'})));
     }

     $page .= end_table();
  }

  #################################################

  # print out file information: which files are linked to this line?
  $page .= hr()
           . h3("4) Files available for this line [" . a({-href=>"$url?choice=upload_line_blob&line_id=" . $line_id}, "upload and link file to this line") . "]")
           . &get_blob_table_for_line($global_var_href, $line_id);

  #################################################

  # offer search for all mice from this line
  $page .= hr()
           . h3("5) Search mice from this line")

           . start_form({-action => url()})
           . hidden(-name=>'line', -value=>$line_id)
           . table( {-border=>0, -summary=>"table"},
                    Tr( td({-align=>"right"}, b('sex: ')),
                        td(popup_menu(-name => "sex",
                                      -values => ["1", "2", "3"],
                                      -labels => {"1"  => "male or female",
                                                  "2"  => "male",
                                                  "3"  => "female"}
                           )
                        )
                    ),
                    Tr( td({-align=>"right"}, b('age from: ')),
                        td(popup_menu(-name   => "min_age",
                                      -values => ["0", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16",
                                                  "20", "24", "28", "32", "36", "40", "44", "48", "56", "64", "72", "80", "88", "96"],
                                      -default=> "0",
                                      -labels => {"0"  => "no min age", "3" =>  "3 weeks",  "4" => "4 weeks",   "5" =>  "5 weeks",
                                                  "6"  =>  "6 weeks",   "7" =>  "7 weeks",  "8" => "8 weeks",   "9" =>  "9 weeks", "10" => "10 weeks",
                                                  "11" => "11 weeks",  "12" => "12 weeks", "13" => "13 weeks", "14" => "14 weeks", "15" => "15 weeks",
                                                  "16" => "16 weeks",  "20" => "20 weeks", "24" => "24 weeks", "28" => "28 weeks", "32" => "32 weeks",
                                                  "36" => "36 weeks",  "40" => "40 weeks", "44" => "44 weeks", "48" => "48 weeks", "56" => "56 weeks",
                                                  "64" => "64 weeks",  "72" => "72 weeks", "80" => "80 weeks", "88" => "88 weeks", "96" => "96 weeks"
                                                  }
                           )
                           . b(' to: ')
                           . popup_menu(-name    => "max_age",
                                        -values  => ["0",  "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16",
                                                    "20", "24", "28", "32", "36", "40", "44", "48", "56", "64", "72", "80", "88", "96"],
                                        -default => "1",
                                        -labels => {"0"  => "no max age", "3" =>  "3 weeks",  "4" => "4 weeks",   "5" =>  "5 weeks",
                                                    "6"  => "6 weeks" ,   "7" =>  "7 weeks",  "8" => "8 weeks",   "9" =>  "9 weeks", "10" => "10 weeks",
                                                    "11" => "11 weeks",   "12" => "12 weeks", "13" => "13 weeks", "14" => "14 weeks", "15" => "15 weeks",
                                                    "16" => "16 weeks",   "20" => "20 weeks", "24" => "24 weeks", "28" => "28 weeks", "32" => "32 weeks",
                                                    "36" => "36 weeks",   "40" => "40 weeks", "44" => "44 weeks", "48" => "48 weeks", "56" => "56 weeks",
                                                    "64" => "64 weeks",   "72" => "72 weeks", "80" => "80 weeks", "88" => "88 weeks", "96" => "96 weeks"
                                                    }
                              )
                        )
                    ),
                    Tr( td({-align=>"right"}, b('genotype: ') ),
                        td(get_genotypes_popup_menu($global_var_href, undef, 'any', '21'))
                    ),
                    Tr( td({-align=>"right"}, b('include dead: ')),
                        td(checkbox('include_dead', '0', '1', ''))
                    ),
                    Tr( td({-align=>"right"}, b('only dead: ')),
                        td(checkbox('only_dead', '0', '1', ''))
                    )
             )
           . submit(-name => "choice", -value => "Search by line and sex")

. end_form();

  return $page;
}
# end of line_view
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE023 start_page():                                start page: user start page
sub start_page {                                         my $sr_name = 'SR_VIE023';
  my ($global_var_href) = @_;                                   # get reference to global vars hash
  my $session           = $global_var_href->{'session'};
  my $user_id           = $session->param(-name=>'user_id');
  my $url               = url();
  my $old_date          = 0;
  my ($page, $sql, $user_name, $first_name, $last_name, $age, $weeks, $mice_on_orderlist);
  my ($result, $rows, $row, $i);
  my ($parametersets_own_screens_only_sql, $matings_own_screens_only_sql);
  my @sql_parameters;

  # user wants to see things from own screen only: generate SQL condition
  if (!param('own_screens_only') || param('own_screens_only') eq 'y') {
     # restrict to own screens only
     $parametersets_own_screens_only_sql = qq(and (project_id in (select u2p_project_id
                                                                  from   users2projects
                                                                  where  u2p_user_id = $user_id
                                                                 )
                                                   or
                                                   parameterset_project_id = 0
                                                   )
                                            );
     $matings_own_screens_only_sql = qq(and project_id in (select u2p_project_id
                                                           from   users2projects
                                                           where  u2p_user_id = $user_id
                                                          )
                                     );
  }
  else {
     $parametersets_own_screens_only_sql = '';
     $matings_own_screens_only_sql       = '';
  }


  # user_name, real name, ...
  $sql = qq(select user_name, contact_first_name, contact_last_name
            from   users
                   left join contacts on user_contact = contact_id
            where  user_id = ?
           );

  @sql_parameters = ($user_id);

  ($user_name, $first_name, $last_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $page = h2("Welcome $first_name $last_name")
          . hr();

  #####################################################################################################
  # get all non-weaned litters from user projects
  $sql = qq(select litter_id, litter_mating_id, litter_in_mating, strain_name, line_name, litter_born_datetime, project_shortname,
                   litter_alive_male, litter_alive_female, litter_comment
            from   litters
                   join matings          on      mating_id = litter_mating_id
                   left join mouse_lines on    mating_line = line_id
                   left join mouse_strains on    mating_strain = strain_id
                   join projects         on mating_project = project_id
            where  litter_weaning_datetime IS NULL
                   $matings_own_screens_only_sql
            order  by litter_born_datetime asc
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows > 0) {     # there are litters to be weaned

     $page .= h3("Litters to be weaned from your screen(s)")
              . start_table({-border=>1})
              . Tr(
                  th('litter ID'),
                  th('project'),
                  th('strain'),
                  th('line'),
                  th('born'),
                  th('age'),
                  th('cage'),
                  th('# mothers'),
                  th('males'),
                  th('females'),
                  th('comment')
                );

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         # mark litters older than 2 weeks
         $age = get_age($row->{'litter_born_datetime'});
         ($weeks, undef) = split(/w/, $age);

         $page .= Tr({-class=>(($age > 21)?'red':'nonred')},
                    td(a({-href=>"$url?choice=litter_view&litter_id=" . $row->{'litter_id'}}, $row->{'litter_in_mating'} . '. litter from mating ' . $row->{'litter_mating_id'})),
                    td({-align=>'center'}, $row->{'project_shortname'}),
                    td({-align=>'center'}, $row->{'strain_name'}),
                    td({-align=>'center'}, $row->{'line_name'}),
                    td(format_datetime2simpledate($row->{'litter_born_datetime'})),
                    td($age),
                    td(get_mother_cage_for_weaning($global_var_href, $row->{'litter_id'})),
                    td({-align=>'right'}, scalar @{get_mothers_of_litter($global_var_href, $row->{'litter_id'})}),
                    td({-align=>'right'}, $row->{'litter_alive_male'}),
                    td({-align=>'right'}, $row->{'litter_alive_female'}),
                    td($row->{'litter_comment'})
                  );
     }

     $page .= end_table();
  }
  else {      # no litters to be weaned
     $page .= h3("Currently, no litters to be weaned from your screen(s) ");
  }
  #####################################################################################################

  $page .= hr();

  #####################################################################################################
  # get all orderlists
  $sql = qq(select orderlist_id, orderlist_name, orderlist_date_scheduled, orderlist_parameterset,
                   orderlist_status, parameterset_name, day_week_in_year, day_year
            from   orderlists
                   join parametersets on  orderlist_parameterset = parameterset_id
                   left join projects on parameterset_project_id = project_id
                   join days                         on day_date = orderlist_date_scheduled
            where  1
                   $parametersets_own_screens_only_sql
                   and orderlist_status = ?
            order  by orderlist_date_scheduled desc, orderlist_name
           );

  @sql_parameters = ('ordered');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows > 0) {     # there are orderlists

     $page .= h3("Order lists for " . a({-href=>"$url?choice=home&own_screens_only=y"}, "[your screen(s)]") . '&nbsp;&nbsp;'
                                   . a({-href=>"$url?choice=home&own_screens_only=n"}, "[all screens]")
              )
              . start_table({-border=>1})
              . Tr(
                  th('order list name'),
                  th('parameterset'),
                  th('status'),
                  th('mice')
                );

     for ($i=0; $i<$rows; $i++) {
         if ($i > 300) { last; }                # limit orderlist preview to 200

         $row = $result->[$i];

         # add separator line if week changes
         if ($row->{'orderlist_date_scheduled'} ne $old_date) {
            $page .= Tr( {-bgcolor=>'lightblue'},
                       td({-colspan=>"4"},
                         b("Scheduled to  week " . $row->{'day_week_in_year'} . '/' . $row->{'day_year'}) . " (Monday: " . format_sql_date2display_date($row->{'orderlist_date_scheduled'}) . ")"
                       )
                     );
         }

         # count mice on this orderlist
         $sql = qq(select count(m2o_mouse_id) as mice_on_orderlist
                   from   mice2orderlists
                   where  m2o_orderlist_id = ?
                );

         @sql_parameters = ($row->{'orderlist_id'});

         ($mice_on_orderlist) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

         $page .= Tr(
                    td(a({-href=>"$url?choice=orderlist_view&orderlist_id=" . $row->{'orderlist_id'}}, $row->{'orderlist_name'})),
                    td($row->{'parameterset_name'}),
                    td($row->{'orderlist_status'}),
                    td({-align=>'right'}, $mice_on_orderlist)
                  );

         $old_date = $row->{'orderlist_date_scheduled'};
     }

     $page .= end_table();
  }
  else {      # no orderlists
     $page .= h3("Currently, no order lists from your screen(s) " . a({-href=>"$url?choice=home&own_screens_only=n"}, "[all screens]")
              );
  }
  #####################################################################################################

  return $page;
}
# end of start_page()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE024 user_overview():                             user overview
sub user_overview {                                      my $sr_name = 'SR_VIE024';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($log_id, $log_datetime, $type, $remote_IP);
  my @sql_parameters;

  $page = h2("User overview ")
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select user_id, user_name, user_contact, user_status, user_comment, contact_title, contact_type, contact_function, contact_first_name, contact_last_name
            from   users
                   join contacts on user_contact = contact_id
            order  by user_name asc
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  unless ($rows > 0) {
    $page .= p("No users found.");
    return $page;
  }

  # else: first generate table header ...
  $page .= h3("Users")
           . start_table( {-border=>"1", -summary=>"user_overview"})
           . Tr( {-align=>'center'},
               th("user id"),
               th("user name"),
               th("real name"),
               th("status"),
               th("login/logout"),
               th("time"),
               th("from IP address")
             );

  # ... then loop over all users
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      ($log_id, $log_datetime, $type, $remote_IP) = ();


      # get last login or logout from this user
      $sql = qq(select max(log_id) as max_id
                from   log_access
                where  log_user_id = ?
             );

      @sql_parameters = ($row->{'user_id'});

      ($log_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      if (defined($log_id)) {
         # get last login or logout from this user
         $sql = qq(select log_datetime, log_choice, log_remote_IP
                   from   log_access
                   where  log_id = ?
                );

         @sql_parameters = ($log_id);

         ($log_datetime, $type, $remote_IP) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};
      }

      # generate the current row
      $page .= Tr(
                 td({-align=>'right'}, $row->{'user_id'}),
                 td(a({-href=>"$url?choice=user_details&user_id=" . $row->{'user_id'}}, $row->{'user_name'})),
                 td($row->{'contact_first_name'} . ' ' . $row->{'contact_last_name'}),
                 td($row->{'user_status'}),
                 td(defined($type)?$type:''),
                 td(format_sql_datetime2display_datetime($log_datetime)),
                 td(defined($remote_IP)?$remote_IP:'')
                );
  }

  $page .= end_table();

  return $page;
}
# end of user_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE025 show_ancestors():                            show_ancestors
sub show_ancestors {                                     my $sr_name = 'SR_VIE025';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $mouse_id          = param('mouse_id');
  my $url               = url();
  my $generation        = 1;
  my $max_generation    = 5;
  my ($page, $sql, $result, $rows, $row, $i, $sex);

  # check input: is mouse id given? is it a number?
  if (!param('mouse_id') || param('mouse_id') !~ /^[0-9]{8}$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid mouse id"));
     return $page;
  }

  $sex = get_sex($global_var_href, $mouse_id);

  $page = h2("Ancestors of mouse $mouse_id")
          . hr()
          . print_parent_table($global_var_href, $mouse_id, (($sex eq 'm')?'male:':'female:'), $generation++, $max_generation);

  return $page;
}
# end of show_ancestors()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE026 show_admin_message():                        show admin message(s) ****CURRENTLY NOT USED****
sub show_admin_message {                                 my $sr_name = 'SR_VIE026';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # check for system messages
  $sql = qq(select setting_value_text as message
            from   settings
            where  setting_category = ?
                   and setting_item = ?
            order  by setting_key asc
           );

  @sql_parameters = ('admin','message' );

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  $page = h2("Important message from your MausDB administrators")
          . hr();

  unless ($rows > 0) {
    $page .= p("Currently, there are no messages from your MausDB administrators.");
    return $page;
  }

  # else: display messages
  $page .= h3("There is/are $rows message(s)")
           . '<UL>';

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= li(p($row->{'message'}));
  }

  $page .= '</UL>';

  return $page;
}
# end of show_admin_message()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE027 embryo_transfer_view                         embryo transfer view
sub embryo_transfer_view {                               my $sr_name = 'SR_VIE027';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $transfer_id       = param('transfer_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # check input: is transfer id given? is it a number?
  if (!defined($transfer_id) || $transfer_id !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: invalid transfer id"));
     return $page;
  }

  # first table
  $page .= h2("Embryo transfer details");

  $sql = qq(select transfer_id, transfer_mating_id, transfer_embryo_id, transfer_embryo_id_context, transfer_embryo_production,
                   transfer_sperm_preservation, transfer_IVF_assistance, transfer_embryo_preservation, transfer_transgenic_manipulation,
                   transfer_background_donor_cells, transfer_background_ES_cells, transfer_name_of_construct, transfer_comment
            from   embryo_transfers
            where  transfer_id = ?
           );

  @sql_parameters = ($transfer_id);
  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no such mating found: tell and quit
  unless ($rows > 0) {
     $page .= p("No details on embryo transfer $transfer_id");
     return $page;
  }

  # else continue: get result handle and display table
  $row = $result->[0];

  $page .= hr()
           . h3(qq(Details for embryo transfer ) . a({-href=>"$url?choice=transfer_view&transfer_id=" . $transfer_id}, 'transfer ' . $transfer_id))
           . start_form(-action=>url(), -name=>"myform1")
           . table( {-border=>1, -summary=>"table", -bgcolor=>'#DDFFFF'},
               Tr(
                 th("embryo transfer"),
                 td({-colspan=>3}, $transfer_id)
               ),
               Tr(
                 th("mating id"),
                 td({-colspan=>3}, a({-href=>"$url?choice=mating_view&mating_id=" . $row->{'transfer_mating_id'}}, 'mating ' . $row->{'transfer_mating_id'}))
               ),
               Tr(
                 th("embryo id"),
                 td($row->{'transfer_embryo_id'}),
                 th("embryo origin"),
                 td($row->{'transfer_embryo_id_context'})
               ),
               Tr(
                 th("embryo production"),
                 td($row->{'transfer_embryo_production'}),
                 th("IVF assistance"),
                 td($row->{'transfer_IVF_assistance'})
               ),
               Tr(
                 th("embryo preservation"),
                 td($row->{'transfer_embryo_preservation'}),
                 th("sperm preservation"),
                 td($row->{'transfer_sperm_preservation'})
               ),
               Tr(
                 th("transgenic manipulation"),
                 td($row->{'transfer_transgenic_manipulation'}),
                 th("construct used"),
                 td($row->{'transfer_name_of_construct'})
               ),
               Tr(
                 th("background of donor cells"),
                 td($row->{'transfer_background_donor_cells'}),
                 th("background of ES cell line"),
                 td($row->{'transfer_background_ES_cells'})
               ),
               Tr(
                 th("embryo transfer comment"),
                 td({-colspan=>3}, $row->{'transfer_comment'})
               )
             )
           . end_form()
           . hr({-align=>'left', -width=>'50%'});

  return $page;
}
# end of embryo_transfer_view
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE028 download_file                                download info
sub download_file {                                      my $sr_name = 'SR_VIE028';
  my ($global_var_href) = @_;                                  # get reference to global vars hash
  my $blob_database     = $global_var_href->{'blob_database'}; # name of the blob_database
  my $blob_id           = param('file');
  my $session           = $global_var_href->{'session'};           # get session handle
  my $user_id           = $session->param('user_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($blob_name, $blob_content_type, $blob_mime_type, $the_blob, $blob_upload_datetime, $blob_upload_user, $blob_is_public);
  my @sql_parameters;
  my @user_projects;
  my @blob_projects;

  # check input: is blob id given? is it a number?
  if (!defined($blob_id) || $blob_id !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: invalid file id"));
     return $page;
  }

  # first table
  $page .= h2("File download");

  $sql = qq(select blob_name, blob_content_type, blob_mime_type, UNCOMPRESS(blob_itself), blob_upload_datetime, blob_upload_user, blob_is_public
            from   $blob_database.blob_data
            where  blob_id = ?
         );

  @sql_parameters = ($blob_id);

  ($blob_name, $blob_content_type, $blob_mime_type, $the_blob, $blob_upload_datetime, $blob_upload_user, $blob_is_public) = @{&do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, __LINE__)};

  # get a list of all projects assigned to the current user
  @user_projects = get_user_projects($global_var_href, $user_id);

  # get a list of all projects assigned to the user who uploaded the blob
  @blob_projects = get_user_projects($global_var_href, $blob_upload_user);

  # only allow download if:
  # 1) blob is public
  if ($blob_is_public eq 'y' || current_user_is_admin($global_var_href) eq 'y') {
     # print the html header with correct MIME-type, so that client browser knows what to do with this content (and hopefully offers to open with Excel)
     print header(-Content_disposition => "attachment; filename=$blob_name", -type => "$blob_mime_type");

     # write file in binary mode to STDOUT
     binmode STDOUT;

     print $the_blob;

     exit(0);
  }

  # or
  # 2) blob upload user and current user share at least one project
  elsif (scalar in_both_lists(\@user_projects, \@blob_projects) > 0) {
     # print the html header with correct MIME-type, so that client browser knows what to do with this content (and hopefully offers to open with Excel)
     print header(-Content_disposition => "attachment; filename=$blob_name", -type => "$blob_mime_type");

     # write file in binary mode to STDOUT
     binmode STDOUT;

     print $the_blob;

     exit(0);
  }
  else {
     $page .= hr()
              . h3({-class=>'red'}, "Sorry, you are not allowed to download this file");

     return $page;
  }
}
# end of download_file
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE029 view_mice_of_mr                              show mice (with role) assigned to a given medical record
sub view_mice_of_mr {                                    my $sr_name = 'SR_VIE029';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $mr_id             = param('mr_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($measure_mice_string, $control_mice_string);
  my @sql_parameters;
  my @measure_mice;
  my @control_mice;

  # check input: is mr id given? is it a number?
  if (!defined($mr_id) || $mr_id !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: invalid phenotype record id"));
     return $page;
  }

  $page .= h2("Mouse/mice assigned to phenotype record")
           . hr();

  ########################################################
  # get measured mice
  $sql = qq(select m2mr_mouse_id
            from   mice2medical_records
            where  m2mr_mr_id = ?
                   and m2mr_mouse_role = ?
         );

  @sql_parameters = ($mr_id, 'role');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@measure_mice, $row->{'m2mr_mouse_id'});
  }

  $measure_mice_string = mouse_list2link_list(\@measure_mice);

  ########################################################
  # get control mice
  $sql = qq(select m2mr_mouse_id
            from   mice2medical_records
            where  m2mr_mr_id = ?
                   and m2mr_mouse_role = ?
         );

  @sql_parameters = ($mr_id, 'control');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@control_mice, $row->{'m2mr_mouse_id'});
  }

  $control_mice_string = mouse_list2link_list(\@control_mice);
  ########################################################

  $page .= table( {-border=>1},
             Tr( th({-align=>'right'}, 'Measured'),
                 td($measure_mice_string)
             ),
             Tr( th({-align=>'right'}, 'Control'),
                 td($control_mice_string)
             )
           );

  return $page;
}
# end of view_mice_of_mr
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_VIE030 view_blob_info                               show blob info together with linked mice
sub view_blob_info {                                     my $sr_name = 'SR_VIE030';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $blob_id           = param('file_id');
  my $blob_name         = param('file_name');
  my $file_comment      = param('file_comment');
  my $blob_database     = $global_var_href->{'blob_database'};     # name of the blob_database
  my $session           = $global_var_href->{'session'};           # get session handle
  my $dbh               = $global_var_href->{'dbh'};
  my $user_id           = $session->param('user_id');
  my $datetime_now      = get_current_datetime_for_sql();
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i, $blob_comment_sql);
  my ($blob_content_type, $blob_mime_type, $file_size, $blob_upload_datetime);
  my ($blob_link, $blob_upload_user, $blob_comment, $blob_is_public);
  my @sql_parameters;
  my @user_projects;
  my @blob_projects;

  # check input: is blob id given? is it a number?
  if (!defined($blob_id) || $blob_id !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: invalid file"));
     return $page;
  }

  #############################################
  # update comment if requested
  if (defined(param('job')) && param('job') eq "update file comment") {

     $blob_comment_sql = $file_comment;
     $blob_comment_sql =~ s/'|;|-{2}//g;                  # remove dangerous content

     # update file comment
     $dbh->do("update  $blob_database.blob_data
               set     blob_comment = ?
               where   blob_id = ?
              ", undef, $blob_comment_sql, $blob_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update file comment)", $sr_name . "-" . __LINE__);

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdate_file_comment\t$blob_id\tnew:$blob_comment_sql");
  }
  #############################################

  $page .= h2("Details for file")
           . hr();

  #############################################
  # get file info
  $sql = qq(select blob_name, blob_content_type, blob_mime_type, length(UNCOMPRESS(blob_itself)) as file_size, blob_upload_datetime,
                   blob_upload_user, blob_comment, blob_is_public
            from   $blob_database.blob_data
            where  blob_id = ?
         );

  @sql_parameters = ($blob_id);

  ($blob_name, $blob_content_type, $blob_mime_type, $file_size, $blob_upload_datetime, $blob_upload_user, $blob_comment, $blob_is_public) =  @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # get a list of all projects assigned to the current user
  @user_projects = get_user_projects($global_var_href, $user_id);

  # get a list of all projects assigned to the user who uploaded the blob
  @blob_projects = get_user_projects($global_var_href, $blob_upload_user);

  # only display blob link if:
  # 1) blob is public
  if ($blob_is_public eq 'y') {
      $blob_link = a({-href=>"$url?choice=download_file&file=" . $blob_id}, $blob_name) . ' [file is public]';
  }

  # or
  # 2) blob upload user and current user share at least one project
  elsif (scalar in_both_lists(\@user_projects, \@blob_projects) > 0) {
      $blob_link = a({-href=>"$url?choice=download_file&file=" . $blob_id}, $blob_name) . ' [file is public to users who share projects with you]';
  }

  # or
  # 3) user has admin rights
  elsif (current_user_is_admin($global_var_href) eq 'y') {
      $blob_link = a({-href=>"$url?choice=download_file&file=" . $blob_id}, $blob_name) . ' [file is open for you only because you have admin rights]';
  }

  # otherwise do not display
  else {
     $blob_link  = $blob_name . span({-class=>'red'}, ' [file is not public]');
  }

  $page .= h3("File Info")
           . start_form(-action=>url(), -name=>"myform")
           . table( {-border=>1},
               Tr( th('file name'),
                   td({-align=>'center'}, $blob_link)
               ) .
               Tr( th('file type'),
                   td({-align=>'center'}, $blob_content_type)
               ) .
               Tr( th('file size'),
                   td({-align=>'center'}, round_number($file_size / 1024, 0) . ' Kb')
               ) .
               Tr( th('file uploaded by'),
                   td({-align=>'center'}, get_user_name_by_id($global_var_href, $blob_upload_user))
               ) .
               Tr( th('file upload at'),
                   td({-align=>'center'}, format_sql_datetime2display_date($blob_upload_datetime))
               ) .
               # allow admins and users that share projects with upload user to update comment
               ((current_user_is_admin($global_var_href) eq 'y'
                 ||
                (scalar in_both_lists(\@user_projects, \@blob_projects) > 0)
                )
                ?Tr( th('file comment'),
                     td({-align=>'left'},  textarea(-name=>"file_comment", -columns=>"40", -rows=>"5",
                                                    -value=>($blob_comment ne '')?$blob_comment:'no comments for this file'
                                           )
                                           . br()
                                           . submit(-name => "job", -value=>"update file comment")
                     )
                 )
                :Tr( th('file comment'),
                     td({-align=>'left'},   pre($blob_comment))
                 )
               )
             )
           . hr();


  #############################################
  # get info about linked mice
  $sql = qq(select mouse_id, m2b_mouse_role
            from   mice2blob_data
                   join mice on m2b_mouse_id = mouse_id
            where  m2b_blob_id = ?
           );

  @sql_parameters = ($blob_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  $page .= h3("Mice linked to this file");

  # if there are no files for this mouse, notify
  if ($rows == 0) {
     $page .= p("no mice linked to this file");
  }
  else {
     # (else continue)
     $page .= start_table( {-border=>1, -summary=>"table"})
              . Tr(
                  th("mouse_id"),
                  th("role")
                );

     # loop over all results from previous select
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];                # fetch next row

         # add table row for current file
         $page .= Tr({-align=>'center'},
                     td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $row->{'mouse_id'}}, $row->{'mouse_id'})),
                     td($row->{'m2b_mouse_role'})
                  );
     }

     $page .= end_table();
  }

  $page .=   hidden('choice')
           . hidden('file_id')
           . hidden('file_name')

           . end_form()
           . p();

  #############################################
  # get info about linked lines
  $sql = qq(select line_id, line_name, line_long_name
            from   line2blob_data
                   join mouse_lines on l2b_line_id = line_id
            where  l2b_blob_id = ?
           );

  @sql_parameters = ($blob_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  $page .= hr({-width=>"50%", -align=>"left"})
           . h3("Mouse lines linked to this file");

  # if there are no files for this mouse line, notify
  if ($rows == 0) {
     $page .= p("no mouse line linked to this file");
  }
  else {
     # (else continue)
     $page .= start_table( {-border=>1, -summary=>"table"})
              . Tr(
                  th("line name"),
                  th("line long name")
                );

     # loop over all results from previous select
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];                # fetch next row

         # add table row for current file
         $page .= Tr({-align=>'center'},
                     td(a({-href=>"$url?choice=line_view&line_id=" . $row->{'line_id'}}, $row->{'line_name'})),
                     td($row->{'line_long_name'})
                  );
     }

     $page .= end_table();
  }

  return $page;
}
# end of view_blob_info
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE031 strain_view                                  strain view
sub strain_view {                                        my $sr_name = 'SR_VIE031';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $strain_id         = param('strain_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($living_males, $living_females);
  my @sql_parameters;

  # check input: is strain id given? is it a number?
  if (!param('strain_id') || param('strain_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid strain id"));
     return $page;
  }

  # first table
  $page .= h2("Mouse strain information " . ' (' . a({-href=>"$url?choice=strain_overview"}, 'all strains') . ')')
           . hr();

  $sql = qq(select strain_id, strain_name, strain_order, strain_show, strain_description
            from   mouse_strains
            where  strain_id = ?
           );

  @sql_parameters = ($strain_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("No details on this mouse strain");
     return $page;
  }

  # get number of living male animals from this strain
  $sql = qq(select count(mouse_id) as living_males
            from   mice
            where  mouse_strain = ?
                   and mouse_sex = ?
                   and mouse_deathorexport_datetime IS NULL
           );

  @sql_parameters = ($strain_id, 'm');

  ($living_males) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # get number of living female animals from this strain
  $sql = qq(select count(mouse_id) as living_females
            from   mice
            where  mouse_strain = ?
                   and mouse_sex = ?
                   and mouse_deathorexport_datetime IS NULL
           );


  @sql_parameters = ($strain_id, 'f');

  ($living_females) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # else continue: get result handle to generate details table
  $row = $result->[0];

  $page .= h3("Mouse strain " . qq("$row->{'strain_name'}" ))
           . table( {-border=>1, -summary=>"table"},
               Tr(
                 th("Name of mouse strain"),
                 td($row->{'strain_name'})
               ),
               Tr(
                 th("Mouse strain description"),
                 td(pre("$row->{'strain_description'}"))
               ),
               Tr(
                 th("Currently living"),
                 td( table({-border=>0},
                        Tr( td({-align=>'right'}, $living_males),
                            td('males')
                        ),
                        Tr( td({-align=>'right'}, $living_females),
                            td('females')
                        )
                     )
                 )
               )
             );

  return $page;
}
# end of strain_view
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE032 strain_overview():                           strain overview
sub strain_overview {                                    my $sr_name = 'SR_VIE032';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $show_rows         = $global_var_href->{'show_rows'};
  my $url               = url();
  my $start_row         = param('start_row');
  my ($page, $sql, $result, $rows, $row, $i);
  my ($males_from_this_strain, $females_from_this_strain, $total_total);
  my @sql_parameters;

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  $page = h2("Mouse strains overview ")
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select strain_id, strain_name, strain_order, strain_show, strain_description
            from   mouse_strains
            where  strain_name not in (?, ?)
            order  by strain_name asc
           );

  @sql_parameters = ('new strain', 'choose strain');

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no mouse strains found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No mouse strain found.");
    return $page;
  }

  # else: first generate table header ...
  $page .= h3("$rows mouse strains found")
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=strain_overview" . '&start_row=1'}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=strain_overview" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=strain_overview" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=strain_overview" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
              )
              :''
             )
           . start_table( {-border=>"1", -summary=>"strain_overview"})
           . Tr( {-align=>'center'},
               th({-rowspan=>2, -valign=>'bottom'}, "#"),
               th({-rowspan=>2, -valign=>'bottom'}, "strain name"),
               td({-colspan=>3}, b("alive"))
             )
           . Tr( {-align=>'center'},
               th("males"),
               th("females"),
               th("total")
             );

  # ... then loop over all strains
  for ($i=0; $i<$rows; $i++) {
      if ($i+1 < $start_row )              { next; }               # skip all rows with (row index < $start_row)
      if ($i+1 >= $start_row + $show_rows) { last; }               # skip all rows with (row index > $start_row+$show_rows): exit loop

      $row = $result->[$i];

      # count males from this strain
      $sql = qq(select count(mouse_id) as males_from_this_strain
                from   mice
                where  mouse_strain = ?
                       and mouse_sex = ?
                       and mouse_deathorexport_datetime IS NULL
             );

      @sql_parameters = ($row->{'strain_id'}, 'm');

      ($males_from_this_strain) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      # count females from this strain
      $sql = qq(select count(mouse_id) as females_from_this_strain
                from   mice
                where  mouse_strain = ?
                       and mouse_sex = ?
                       and mouse_deathorexport_datetime IS NULL
             );

      @sql_parameters = ($row->{'strain_id'}, 'f');

      ($females_from_this_strain) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      $total_total += $females_from_this_strain + $males_from_this_strain;

      # generate the current mouse strain row
      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td(a({-href=>"$url?choice=strain_view&strain_id=$row->{'strain_id'}", -title=>"click for strain details"}, "$row->{'strain_name'}") ),
                 td({-align=>'right'}, $males_from_this_strain),
                 td({-align=>'right'}, $females_from_this_strain),
                 td({-align=>'right'}, $females_from_this_strain + $males_from_this_strain)
               );
  }

  if ($start_row + $show_rows > $rows) {
      # count all living males
      $sql = qq(select count(mouse_id) as males_from_this_strain
                from   mice
                where  mouse_sex = ?
                       and mouse_deathorexport_datetime IS NULL
             );

      @sql_parameters = ('m');

      ($males_from_this_strain) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      # count all living females
      $sql = qq(select count(mouse_id) as females_from_this_strain
                from   mice
                where  mouse_sex = ?
                       and mouse_deathorexport_datetime IS NULL
             );

      @sql_parameters = ('f');

      ($females_from_this_strain) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      $total_total += $females_from_this_strain + $males_from_this_strain;

      $page .=   Tr(
                   td({-colspan=>'6'}, '')
                 )
               . Tr({-align=>'center'},
                   td({-colspan=>'2'}, b('total living mice (all strains)')),
                   td({-align=>'right'}, $males_from_this_strain),
                   td({-align=>'right'}, $females_from_this_strain),
                   td({-align=>'right'}, $females_from_this_strain + $males_from_this_strain)
                 );
  }

  $page .= end_table();

  return $page;
}
# end of strain_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE033 user_details                                 show user details
sub user_details {                                       my $sr_name = 'SR_VIE033';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};               # DBI database handle
  my $session           = $global_var_href->{'session'};           # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $query_user_id     = param('user_id');
  my $url               = url();
  my $password_message  = '';
  my $datetime_now      = get_current_datetime_for_sql();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($password_md5, $password_checksum);
  my @sql_parameters;

  # check input: is user id given? is it a number?
  if (!param('user_id') || param('user_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid user id"));
     return $page;
  }

  ###############################################################
  # password update requested
  if (current_user_is_admin($global_var_href) && defined(param('job')) && param('job') eq 'update password') {

     # calculate MD5 checksum of password
     $password_md5 = Digest::MD5->reset();
     $password_md5->add(param('password'));
     $password_checksum = $password_md5->hexdigest();

     # update password
     $dbh->do("update  users
               set     user_password = ?
               where   user_id = ?
              ", undef, $password_checksum, param('user_id')
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update user password)", $sr_name . "-" . __LINE__);

     $password_message = hr()
                         . p({-class=>'red'}, "Password updated");

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdate_user_password\t" . param('user_id'));
  }
  ###############################################################


  ###############################################################
  # request: deactivate user account
  if (current_user_is_admin($global_var_href) && defined(param('job')) && param('job') eq 'deactivate account') {

     # deactivate user account
     $dbh->do("update  users
               set     user_status = ?
               where   user_id = ?
              ", undef, 'inactive', param('user_id')
             ) or &error_message_and_exit($global_var_href, "SQL error (could not set user acount inactive)", $sr_name . "-" . __LINE__);

     $password_message = hr()
                         . p({-class=>'red'}, "Set user account inactive");

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tinactivate_user_account\t" . param('user_id'));
  }
  ###############################################################


  ###############################################################
  # request: activate user account
  if (current_user_is_admin($global_var_href) && defined(param('job')) && param('job') eq 'activate account') {

     # activate user account
     $dbh->do("update  users
               set     user_status = ?
               where   user_id = ?
              ", undef, 'active', param('user_id')
             ) or &error_message_and_exit($global_var_href, "SQL error (could not set user acount active)", $sr_name . "-" . __LINE__);

     $password_message = hr()
                         . p({-class=>'red'}, "Set user account active");

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tactivate_user_account\t" . param('user_id'));
  }
  ###############################################################

  # first table
  $page .= h2("User details "
              . a({-href=>"$url?choice=user_details&user_id=" . $query_user_id, -title=>"reload page"},
                  img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
                )
           )
           . $password_message
           . hr();

  $sql = qq(select *
            from   users
                   join contacts on user_contact = contact_id
            where  user_id = ?
           );

  @sql_parameters = ($query_user_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no such contact found, tell
  unless ($rows > 0) {
     $page .= p("No details on this user");
     return $page;
  }

  # otherwise continue: get result handle
  $row = $result->[0];

  $page .= h3("User details ")

           . start_form({-action => url()})
           . table( {-border=>1, -summary=>"table"},
               Tr(
                 th("username"),
                 td({-colspan=>2}, b($row->{'user_name'}))
               ),
               Tr(
                 th("user status"),
                 td({-colspan=>2}, b($row->{'user_status'}))
               ),
               # only for admin users
               ((current_user_is_admin($global_var_href) eq 'y')
                ?Tr(
                   th("set new password"),
                   td(textfield(-name => "password", -size=>"20", -maxlength=>"20", -override=>1)
                      . hidden(-name=>'user_id', -value=>$row->{'user_id'})
                      . hidden('choice')
                   ),
                   td(submit(-name => "job", -value => "update password"))
                 ) .
                 Tr(
                   th("activate/deactivate account"),
                   td({-colspan=>2}, submit(-name => "job", -value => "activate account")   . '&nbsp;&nbsp;&nbsp;'
                                   . submit(-name => "job", -value => "deactivate account")
                   )
                 )
                 :''
               )
             )
           . end_form()

           . h3(qq(Contact details))

           . table( {-border=>1, -summary=>"table"},
               Tr(
                 th("Name"),
                 td(a({-href=>"$url?choice=contact_view&contact_id=" . $row->{'contact_id'}},
                      $row->{'contact_title'} . ' ' . $row->{'contact_first_name'} . ' ' . $row->{'contact_last_name'}
                    )
                 )
               ),
               Tr(
                 th("is internal"),
                 td($row->{'contact_is_internal'})
               ),
               Tr(
                 th("Function"),
                 td($row->{'contact_function'})
               ),
               Tr(
                 th("Email"),
                 td(join(br(), split(/,/, $row->{'contact_emails'})))
               ),
               Tr(
                 th("Comment"),
                 td($row->{'contact_comment'})
               )
             );

  ###############################################################

  $page .= p()
           . hr({-align=>'left', -width=>'50%'});

  ###############################################################
  # third table: all projects a user belongs to
  $sql = qq(select project_id, project_name
            from   users2projects
                   join projects on u2p_project_id = project_id
                   join users    on    u2p_user_id = user_id
            where  user_id = ?
           );

  @sql_parameters = ($query_user_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no addresses found, tell
  unless ($rows > 0) {
     $page .= p("No projects defined for this user");
     return $page;
  }

  # else continue ...
  $page .= h3("Projects of this user")
           . start_table( {-border=>1, -summary=>"table"})
           . Tr(
               th(' '),
               th('Project')
             );

  # loop over all projects
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     $page .= Tr({-align=>'center'},
                td($i+1),
                td(a({-href=>"$url?choice=project_view&project_id=" . $row->{'project_id'}}, $row->{'project_name'}))
              );
  }

  $page .= end_table()
           . p();

  return $page;
}
# end of user_details
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE034 cost_centres_overview():                     cost centres overview
sub cost_centres_overview {                              my $sr_name = 'SR_VIE034';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($description);
  my @sql_parameters;

  $page = h2("Cost centres overview ")
          . hr();

  $sql = qq(select cost_account_id, cost_account_name, cost_account_number, cost_account_comment
            from   cost_accounts
            order  by cost_account_name
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no cost accounts found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No cost centres in the database");
     return $page;
  }

  # else continue: display imports table
  $page .= start_table( {-border=>"1", -summary=>"cost_centres_overview"})
          . Tr( {-align=>'center'},
              td({-align=>'left'}, b("Cost centre")),
              th("Description"),
              ((current_user_is_admin($global_var_href) eq 'y')
               ?th("account number")
               :''
              )
            );

  # ... loop over all imports
  for ($i=0; $i<$rows; $i++) {               # $rows is the number of racks returned from the above query
      $row = $result->[$i];                  # get a reference on the current result row

      $description = $row->{'cost_account_comment'};
      $description =~ s/\//\<br\>/g;

      $page .= Tr({-align=>'center'},
                 td({-align=>'left'}, b($row->{'cost_account_name'})),
                 td({-align=>'left'}, $description),
                 ((current_user_is_admin($global_var_href) eq 'y')
                  ?td($row->{'cost_account_number'})
                  :''
                 )
               );
  }

  $page .= end_table();

  return $page;
}
# end of cost_centres_overview()
#------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE035 blob_overview():                             blob overview
sub blob_overview {                                      my $sr_name = 'SR_VIE035';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $show_rows         = $global_var_href->{'show_rows'};
  my $blob_database     = $global_var_href->{'blob_database'}; # name of the blob_database
  my $url               = url();
  my $start_row         = param('start_row');
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  $page = h2("Stored files overview ")
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select blob_id, blob_name, blob_content_type, blob_upload_datetime, blob_is_public,
                   user_name
            from   $blob_database.blob_data
                   join users on blob_upload_user = user_id
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no mouse strains found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No stored files found.");
    return $page;
  }

  # else: first generate table header ...
  $page .= h3("$rows stored files found")
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=stored_files_overview" . '&start_row=1'}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=stored_files_overview" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=stored_files_overview" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=stored_files_overview" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
              )
              :''
             )
           . start_table( {-border=>"1", -summary=>"blob_overview"})
           . Tr( {-align=>'left'},
               td(b('#')),
               td(b('file name')),
               td(b('file type')),
               td(b('uploaded at')),
               td(b('uploaded by')),
               td(b('is public'))
             );

  # ... then loop over all blobs
  for ($i=0; $i<$rows; $i++) {
      if ($i+1 < $start_row )              { next; }               # skip all rows with (row index < $start_row)
      if ($i+1 >= $start_row + $show_rows) { last; }               # skip all rows with (row index > $start_row+$show_rows): exit loop

      $row = $result->[$i];

      # generate the current row
      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td({-align=>'left'}, a({-href=>"$url?choice=view_file_info&file_id=$row->{'blob_id'}&file_name=$row->{'blob_name'}", -title=>"click for file details"}, $row->{'blob_name'}) ),
                 td($row->{'blob_content_type'}),
                 td(format_sql_datetime2display_datetime($row->{'blob_upload_datetime'})),
                 td($row->{'user_name'}),
                 td(($row->{'blob_is_public'} eq 'y')?'yes':'no')
               );
  }

  $page .= end_table();

  return $page;
}
# end of blob_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE036 projects_overview():                         projects overview
sub projects_overview {                                  my $sr_name = 'SR_VIE036';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  unless (current_user_is_admin($global_var_href) eq 'y') {
     $page = h2("Projects overview ")
             . hr()
             . p("Sorry, you are not authorised to view this page. Please contact an administrator.");

     return $page;
  }

  $page = h2("Projects overview " )
          . hr();

  $sql = qq(select project_id, project_name, project_shortname, project_description, project_parent_project, project_owner
            from   projects
            order  by project_name
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no cost accounts found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No projects defined");
     return $page;
  }

  # else continue: display imports table
  $page .= start_table( {-border=>"1", -summary=>"projects_overview"})
          . Tr( {-align=>'center'},
              th("project"),
              th("description")
            );

  # ... loop over all imports
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= Tr({-align=>'center'},
                 td(a({-href=>"$url?choice=project_view&project_id=" . $row->{'project_id'}}, $row->{'project_name'})),
                 td($row->{'project_description'})
               );
  }

  $page .= end_table();

  return $page;
}
# end of projects_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE037 project_view():                              project view
sub project_view {                                       my $sr_name = 'SR_VIE037';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $project_id        = param('project_id');
  my ($page, $sql, $result, $rows, $row, $i);
  my ($project_name, $project_shortname, $project_description);
  my @sql_parameters;

  unless (current_user_is_admin($global_var_href) eq 'y') {
     $page = h2("Project view ")
             . hr()
             . p("Sorry, you are not authorised to view this page. Please contact an administrator.");

     return $page;
  }

  # check input: is project id given? is it a number?
  if (!param('project_id') || param('project_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid project id"));
     return $page;
  }

  $page .= h2("Project view ")
           . hr();

  #############################
  # project info
  $sql = qq(select project_name, project_shortname, project_description
            from   projects
            where  project_id = ?
           );

  @sql_parameters = ($project_id);

  ($project_name, $project_shortname, $project_description) =  @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $page .= h3("Details for project \"$project_name\" &nbsp;&nbsp; [" . a({-href=>"$url?choice=projects_overview"}, "back to projects overview") . "]")
           . hr({-align=>"left", -width=>"50%"});

  $page .= table( {-border=>1},
             Tr(th("project short name"),
                td($project_shortname)
             ) .
             Tr(th("project description"),
                td($project_description)
             )
           )
           . hr({-align=>"left", -width=>"50%"});

  #############################
  # list all users attached to this project
  $page .= h3("Users assigned to this project");

  $sql = qq(select u2p_user_id, u2p_project_id, user_name
            from   users2projects
                   left join users on user_id = u2p_user_id
            where  u2p_project_id = ?
           );

  @sql_parameters = ($project_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no cost accounts found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("no users assigned to this project");
     return $page;
  }

  # else continue: display imports table
  $page .= start_table( {-border=>"1", -summary=>"projects_overview"})
          . Tr( {-align=>'center'},
              th('#'),
              th("user")
            );

  # ... loop over all imports
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td(a({-href=>"$url?choice=user_details&user_id=" . $row->{'u2p_user_id'}}, $row->{'user_name'}))
               );
  }

  $page .= end_table()
           . hr({-align=>"left", -width=>"50%"});
  #############################

  #############################
  # list all parametersets attached to this project
  $page .= h3("Parametersets assigned to this project");

  $sql = qq(select parameterset_id, parameterset_name, parameterset_description, parameterset_class, parameterset_is_active
            from   parametersets
            where  parameterset_project_id = ?
            order  by parameterset_class asc, parameterset_name asc
           );

  @sql_parameters = ($project_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no parametersets found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("no parametersets assigned to this project");
     return $page;
  }

  # else continue: display imports table
  $page .= start_table( {-border=>"1", -summary=>"parametersets_overview"})
          . Tr( {-align=>'center'},
              th('#'),
              th("parameterset"),
              th("description"),
              th("class"),
              th("is active")
            );

  # ... loop over all imports
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td(a({-href=>"$url?choice=parameterset_view&parameterset_id=" . $row->{'parameterset_id'}}, $row->{'parameterset_name'})),
                 td($row->{'parameterset_description'}),
                 td($row->{'parameterset_class'}),
                 td($row->{'parameterset_is_active'})
               );
  }

  $page .= end_table();
  #############################

  return $page;
}
# end of project_view()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE037 log_view():                                  log_view
sub log_view {                                           my $sr_name = 'SR_VIE037';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $log_filename      = $global_var_href->{'log_file_name'}; # read name of today's log file from global hash
  my ($page, $log_file);

  # only admin users are authorized to view this
  unless (current_user_is_admin($global_var_href) eq 'y') {
     $page = h2("Log view (today's activity log)")
             . hr()
             . p("Sorry, you are not authorised to view this page. Please contact an administrator.");

     return $page;
  }

  $page = h2("Log view (today's activity log)" )
          . hr();

  # read in today's log file
  open(LOGFILE, "< ./logs/$log_filename");

  # read log file line by line ...
  while (<LOGFILE>) {
    $log_file .= $_;
  }

  close(LOGFILE);

  # convert newlines to HTML (\n -> <br>)
  $log_file =~ s/\n/<br>/g;

  # display as preformatted text
  $page .= pre($log_file);

  return $page;
}
# end of log_view()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE038 genotypes_overview():                        genotypes overview
sub genotypes_overview {                                 my $sr_name = 'SR_VIE038';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  unless (current_user_is_admin($global_var_href) eq 'y') {
     $page = h2("Genotypes overview ")
             . hr()
             . p("Sorry, you are not authorised to view this page. Please contact an administrator.");

     return $page;
  }

  $page = h2("Genotypes overview " )
          . hr();

  $sql = qq(select setting_value_text
            from   settings
            where  setting_item = ?
           );

  @sql_parameters = ('genotypes_for_popup');

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no cost accounts found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No genotypes defined");
     return $page;
  }

  # else continue: display imports table
  $page .= start_table( {-border=>"1", -summary=>"genotypes_overview"})
          . Tr( {-align=>'center'},
              th('#'),
              th("genotype")
            );

  # ... loop over all imports
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td($row->{'setting_value_text'})
               );
  }

  $page .= end_table();

  return $page;
}
# end of genotypes_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE039 show_sanitary_status():                      sanitary status view
sub show_sanitary_status {                               my $sr_name = 'SR_VIE039';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $location_id       = param('rack_id');
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # check input: is rack id given? is it a number?
  if (!param('rack_id') || param('rack_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid rack id"));
     return $page;
  }

  # fetch some rack details
  $sql = qq(select location_id, location_rack, location_building, location_subbuilding, location_room, location_subrack,
                   healthreport_id, healthreport_date, healthreport_valid_from_date, healthreport_valid_to_date,
                   healthreport_status, healthreport_number_of_mice, healthreport_mice
            from   locations
                   left join locations2healthreports on location_id     = l2h_location_id
                   left join healthreports           on healthreport_id = l2h_healthreport_id
                   where  location_id = ?
           );

  @sql_parameters = ($location_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no rack info found: tell and quit
  unless ($rows > 0) {
     $page .= p("Rack not defined");
     return $page;
  }

  # else continue
  $row = $result->[0];

  $page = h2("Sanitary status and history of rack $row->{'location_rack'} in room " . $row->{'location_building'} . "-" . $row->{'location_subbuilding'}
             . "-" .  $row->{'location_room'}
             . (defined($row->{'location_subrack'})?' (' . $row->{'location_subrack'} . ')':'')
             . "&nbsp;&nbsp;["
             . a({-href=>"$url?choice=add_sanitary_data&rack_id=$location_id"}, "add sanitary data")
             . ']'
          )
          . hr();

  # now fetch all health reports with details
  $sql = qq(select location_id, healthreport_id, healthreport_date, healthreport_valid_from_date, healthreport_valid_to_date,
                   healthreport_status, healthreport_number_of_mice, healthreport_mice, healthreport_comment
            from   locations
                   join locations2healthreports on location_id     = l2h_location_id
                   join healthreports           on healthreport_id = l2h_healthreport_id
            where  location_id = ?
            order  by healthreport_valid_from_date asc
           );

  @sql_parameters = ($location_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no sanitary info found: tell and quit
  unless ($rows > 0) {
     $page .= p("No sanitary status information found for this rack");
     return $page;
  }

  # else continue: display imports table
  $page .= start_table( {-border=>"1", -summary=>"sanitary_status"})
          . Tr( {-align=>'center'},
              th({-rowspan=>2}, '#'),
              th({-rowspan=>2}, "report date"),
              th({-colspan=>2}, "report period"),
              th({-rowspan=>2}, "bacteria"),
              th({-rowspan=>2}, "viruses"),
              th({-rowspan=>2}, "parasites"),
              th({-rowspan=>2}, "others"),
              th({-rowspan=>2}, "mice examined"),
              th({-rowspan=>2}, "examined mice"),
              th({-rowspan=>2}, "duplicate to")
            )
          . Tr( {-align=>'center'},
              th("from"),
              th("to")
            );

  # ... loop over all imports
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= Tr({-align=>'center'},
                 td(a({-href=>"$url?choice=view_sanitary_report&report_id=" . $row->{'healthreport_id'}, -title=>"click to view details", -target=>'_blank'}, $i+1)),
                 td(format_sql_datetime2display_date($row->{'healthreport_date'})
                    . br()
                    . small(' (KW ' . format_sql_datetime2calendar_week_year($global_var_href, $row->{'healthreport_date'}) . ')')
                 ),
                 td(format_sql_datetime2display_date($row->{'healthreport_valid_from_date'})
                    . br()
                    . small(' (KW ' . format_sql_datetime2calendar_week_year($global_var_href, $row->{'healthreport_valid_from_date'}) . ')')
                 ),
                 td(format_sql_datetime2display_date($row->{'healthreport_valid_to_date'})
                    . br()
                    . small(' (KW ' . format_sql_datetime2calendar_week_year($global_var_href, $row->{'healthreport_valid_to_date'}) . ')')
                 ),
                 td(get_rack_sanitary_info($global_var_href, $row->{'healthreport_id'}, 'bacterium', $row->{'healthreport_number_of_mice'})),
                 td(get_rack_sanitary_info($global_var_href, $row->{'healthreport_id'}, 'virus',     $row->{'healthreport_number_of_mice'})),
                 td(get_rack_sanitary_info($global_var_href, $row->{'healthreport_id'}, 'parasite',  $row->{'healthreport_number_of_mice'})),
                 td($row->{'healthreport_comment'}),
                 td($row->{'healthreport_number_of_mice'}),
                 td($row->{'healthreport_mice'}),
                 td("duplicate report to rack (choose)"
                    . start_form(-action => url())
                    . hidden('rack_id')
                    . hidden(-name=>"report_id", -value=>$row->{'healthreport_id'})
                    . get_locations_popup_menu($global_var_href)
                    . submit(-name => 'choice', -value => 'duplicate report')
                    . end_form()
                 )
               );
  }

  $page .= end_table();

  return $page;
}
# end of show_sanitary_status()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE040 view_sanitary_report():                      view detailed sanitary report
sub view_sanitary_report {                               my $sr_name = 'SR_VIE040';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $report_id         = param('report_id');
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # check input: is report id given? is it a number?
  if (!param('report_id') || param('report_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid health report id"));
     return $page;
  }

  # fetch some rack details
  $sql = qq(select location_id, location_rack, location_building, location_subbuilding, location_room, location_subrack,
                   healthreport_id, healthreport_date, healthreport_valid_from_date, healthreport_valid_to_date,
                   healthreport_status, healthreport_number_of_mice, healthreport_mice, healthreport_comment
            from   locations
                   left join locations2healthreports on location_id     = l2h_location_id
                   left join healthreports           on healthreport_id = l2h_healthreport_id
                   where  healthreport_id = ?
           );

  @sql_parameters = ($report_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no rack info found: tell and quit
  unless ($rows > 0) {
     $page .= p("Rack or health report not defined");
     return $page;
  }

  # else continue
  $row = $result->[0];

  $page = header()
          . start_html(-title=>"(MausDB)", -style=>{-src=>$global_var_href->{'URL_htdoc_basedir'} . '/css/print.css', -media=>"screen, print"})
          . style({-type=>"text/css"},
                   '@page' . ' { size:20.0cm 29.7cm; margin:0.1cm; marks:cross; }' . "\n"
                   . '@media print{ a { display: none; } }'                        . "\n"
            )
          . "\n\n"

          . start_div({-id=>"print_card", -style=>"position: absolute; top: 0mm; left: 1mm; width: 130mm; height: 105mm; border: 0px solid;"})

          . start_table( {-border=>"1", -summary=>"sanitary_status"})
          . Tr(
              td(b('Health report')),
              td({-colspan=>2}, b('Room ') . br() . span({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 22px; font-weight: bold; "}, $row->{'location_building'} . "-" . $row->{'location_subbuilding'} . "-" .  $row->{'location_room'})),
              td({-colspan=>1}, b('Rack ') . br() . span({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 22px; font-weight: bold; "}, $row->{'location_rack'}))
            )
          . Tr(
              td(br().b('Report date ') . p()),
              td({-colspan=>3},
                 format_sql_datetime2display_date($row->{'healthreport_date'})
                    . ' (KW ' . format_sql_datetime2calendar_week_year($global_var_href, $row->{'healthreport_date'}) . ')'
              )
            )
          . Tr(
              td({-rowspan=>2}, b('report period')),
              td(b('From')),
              td({-colspan=>2},
                 format_sql_datetime2display_date($row->{'healthreport_valid_from_date'})
                    . ' (KW ' . format_sql_datetime2calendar_week_year($global_var_href, $row->{'healthreport_valid_from_date'}) . ')'
              )
            )
          . Tr(
              td(b('To')),
              td({-colspan=>2},
                 format_sql_datetime2display_date($row->{'healthreport_valid_to_date'})
                    . ' (KW ' . format_sql_datetime2calendar_week_year($global_var_href, $row->{'healthreport_valid_to_date'}) . ')'
              )
            )
          . Tr(
              td(b('No. mice examined')),
              td({-align=>'center'}, $row->{'healthreport_number_of_mice'}),
              td(b('IDs (examined mice)')),
              td({-align=>'center'}, (($row->{'healthreport_mice'} ne '')?$row->{'healthreport_mice'}:'n/d'))
            )
          . Tr(
              td(b('Bacteria')),
              td({-colspan=>3}, get_rack_sanitary_info($global_var_href, $row->{'healthreport_id'}, 'bacterium', $row->{'healthreport_number_of_mice'}))
            )
          . Tr(
              td(b('Viruses')),
              td({-colspan=>3}, get_rack_sanitary_info($global_var_href, $row->{'healthreport_id'}, 'virus',     $row->{'healthreport_number_of_mice'}))
            )
          . Tr(
              td(b('Parasites')),
              td({-colspan=>3}, get_rack_sanitary_info($global_var_href, $row->{'healthreport_id'}, 'parasite',  $row->{'healthreport_number_of_mice'}))
            )
          . Tr(
              td(b('Other/Comment')),
              td({-colspan=>3}, $row->{'healthreport_comment'})
            )
          . end_table()

          . p('&nbsp;') . p('&nbsp;') . p('&nbsp;') . p('&nbsp;') . a({-href=>"javascript:window.print()"}, "Print this cage card")
          . p()
          . a({-href=>"javascript:window.close()"}, "close this window")
          . end_div()
          . end_html();

  # rather than returning the page to MAIN, we print $page directly to STDOUT, because
  # don't need the usual page header and tail, but a pure cage card
  print $page;

  # exit without error
  exit(0);
}
# end of view_sanitary_report()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE041 view_global_metadata():                      view global metadata
sub view_global_metadata {                               my $sr_name = 'SR_VIE041';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $show_rows         = $global_var_href->{'show_rows'};
  my $url               = url();
  my $filter            = param('filter');
  my $filter_sql        = 'and 1';
  my $start_row         = param('start_row');
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  # check input: is filter given? is it a number?
  if (param('filter') && param('filter') =~ /^[0-9]+$/) {
     $filter_sql = "and mdd_id = $filter";
  }

  $page = h2("Global metadata "
             . a({-href=>"$url?choice=global_metadata_view", -title=>'reload page'},
                 img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
               )
          )
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select metadata_id, metadata_value, mdd_name, mdd_id, mdd_shortname, mdd_unit, mdd_default, metadata_valid_datetime_from, metadata_valid_datetime_to
            from   metadata
                   join   metadata_definitions  on mdd_id = metadata_mdd_id
            where  mdd_global_yn = ?
                   $filter_sql
            order  by mdd_shortname asc, metadata_valid_datetime_from asc
           );

  @sql_parameters = ('y');

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no global metadata found, tell and quit
  unless ($rows > 0) {
    $page .= p("No global metadata found. [" . a({-href=>"$url?choice=insert_global_metadata"}, 'insert new global metadata') . "]");
    return $page;
  }

  # else: first generate table header ...
  $page .= h3("Global metadata: $rows data points found. [" . a({-href=>"$url?choice=insert_global_metadata"}, 'insert new global metadata') . "]")
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=view_global_metadata" . '&start_row=1'}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=view_global_metadata" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=view_global_metadata" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=view_global_metadata" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
              )
              :''
             )
           . start_table( {-border=>"1", -summary=>"blob_overview"})
           . Tr( {-align=>'left'},
               td(b('#')),
               td(b('Filter')),
               td(b('Name')),
               td(b('Value')),
               td(b('Unit')),
               td(b('Date (from)')),
               td(b('Date (to)'))
             );

  # ... then loop over all result sets
  for ($i=0; $i<$rows; $i++) {
      if ($i+1 < $start_row )              { next; }               # skip all rows with (row index < $start_row)
      if ($i+1 >= $start_row + $show_rows) { last; }               # skip all rows with (row index > $start_row+$show_rows): exit loop

      $row = $result->[$i];

      # generate the current row
      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td(a({-href=>"$url?choice=global_metadata_view&filter=" . $row->{'mdd_id'}, -title=>'Filter for category ' . $row->{'mdd_shortname'}}, 'Filter')),
                 td({-align=>'left'}, "$row->{'mdd_shortname'} ($row->{'mdd_name'})"),
                 td($row->{'metadata_value'}),
                 td($row->{'mdd_unit'}),
                 td(format_sql_datetime2display_datetime($row->{'metadata_valid_datetime_from'})),
                 td(format_sql_datetime2display_datetime($row->{'metadata_valid_datetime_to'}))
               );
  }

  $page .= end_table();

  return $page;
}
# end of view_global_metadata()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE042 cohort_view                                  cohort view
sub cohort_view {                                        my $sr_name = 'SR_VIE042';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $session           = $global_var_href->{'session'};            # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $cohort_id         = param('cohort_id');
  my $mouse_id          = param('mouse_id');
  my $mouse_ids         = param('mouse_ids');
  my $url               = url();
  my $datetime_now      = get_current_datetime_for_sql();
  my ($page, $sql, $result, $rows, $row, $i, $rc, $message, $is_on_list, $potential_id);
  my @sql_parameters;
  my @id_list;
  my @mice_to_add;

  # check input: is cohort id given? is it a number?
  if (!param('cohort_id') || param('cohort_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid cohort id"));
     return $page;
  }

  ################################################################
  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href);
  }
  ################################################################

  ################################################################
  # remove mouse from cohort if requested
  if (defined(param('job')) && param('job') eq "remove_from_cohort") {

     if (param('mouse_id') && param('mouse_id') =~ /[0-9]+$/) {

        # begin transaction
        $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start remove from cohort transaction)", $sr_name . "-" . __LINE__);

        # delete entry in mice2cohorts
        $dbh->do("delete
                  from   mice2cohorts
                  where      m2co_mouse_id   = ?
                         and m2co_cohort_id  = ?
                 ", undef, $mouse_id, $cohort_id
                ) or &error_message_and_exit($global_var_href, "SQL error (could not remove from cohort)", $sr_name . "-" . __LINE__);

        $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

        &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tremove_from_cohort\tmouse:$mouse_id\tcohort:$cohort_id");

        $message = p({-class=>"red"}, "Removed mouse $mouse_id from cohort.");
     }
  }
  ################################################################

  ################################################################
  # add mouse to cohort if requested
  if (defined(param('job')) && param('job') eq "add to cohort") {

     if (param('mouse_ids') && param('mouse_ids') ne '') {

        # split the string that contains the mouse ids. Use any non-digit character as separator
        @id_list = split(/[^0-9]/, $mouse_ids);

        # check every element of the resulting list of potential mouse ids
        foreach $potential_id (@id_list) {
           # ... if it is an 8 digit number:
           if ($potential_id =~ /^[0-9]{8}$/) {
               # check if mouse with this id exists at all
               if (!defined(mouse_exists($global_var_href, $mouse_id)) || mouse_exists($global_var_href, $mouse_id) != $mouse_id) {
                  # if so, add it to the list
                  push(@mice_to_add, $potential_id);
               }
           }
        }

        # loop over valid and existing mouse_ids, add them to cohort
        foreach $mouse_id (@mice_to_add) {
           # now check if mouse is already on list
           $sql = qq(select m2co_mouse_id
                     from   mice2cohorts
                     where       m2co_mouse_id = ?
                            and m2co_cohort_id = ?
                  );

           @sql_parameters = ($mouse_id, $cohort_id);

           ($is_on_list) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

           # yes, mouse is on list already
           if (defined($is_on_list) && $is_on_list == $mouse_id) {
              next;
           }
           # no, not on list yet: add it
           else {
              ###########################################################################################
              # insert into mice2cohorts
              $dbh->do("insert
                        into   mice2cohorts (m2co_mouse_id, m2co_cohort_id)
                        values (?, ?)
                       ", undef,
                       $mouse_id, $cohort_id
                      );

              &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tadd_mouse_to_cohort\t$cohort_id\t$mouse_id");
              ##########################################################################################

              $message .= p({-class=>"red"}, "Added mouse $mouse_id to cohort.");
           }
        }
     }

     # no valid mouse_id given
     else {
        $message = p({-class=>"red"}, "no mouse IDs given (expected mouse id list )!.");
     }
  }
  ################################################################

  # first table
  $page .= h2("Cohort information "
                . a({-href=>"$url?choice=view_cohort&cohort_id=$cohort_id", -title=>'reload page'},
                    img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
                  )
                . "&nbsp;&nbsp; ["
                . a({-href=>"$url?choice=cohorts_overview"}, "all cohorts") . "]"
             )
           . hr()

           . start_form(-action => url(), -name=>"myform")
           . hidden('cohort_id')
           . hidden('choice');

  $sql = qq(select c1.cohort_id as c1_id, c1.cohort_name as c1_name, c1.cohort_pipeline, c1.cohort_purpose, c1.cohort_type,
                   c1.cohort_reference_cohort, c1.cohort_description,
                   c2.cohort_name as c2_name
            from   cohorts c1
                   left join cohorts c2 on c1.cohort_reference_cohort = c2.cohort_id
            where  c1.cohort_id = ?
           );

  @sql_parameters = ($cohort_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("No details on this cohort");
     return $page;
  }

  # else continue: get result handle to generate details table
  $row = $result->[0];

  $page .= h3("Cohort " . qq("$row->{'c1_name'}" ))
           . table( {-border=>1, -summary=>"table"},
               Tr(
                 th("Cohort name"),
                 td($row->{'c1_name'})
               ),
               Tr(
                 th("Cohort ID"),
                 td($row->{'c1_id'})
               ),
               Tr(
                 th("Cohort purpose"),
                 td($row->{'cohort_purpose'})
               ),
               Tr(
                 th("Cohort Eumodic pipeline"),
                 td($row->{'cohort_pipeline'})
               ),
               Tr(
                 th("Cohort type"),
                 td($row->{'cohort_type'})
               ),
               Tr(
                 th("Cohort description"),
                 td($row->{'cohort_description'})
               ),
               Tr(
                 th("Reference cohort"),
                 td(defined($row->{'cohort_reference_cohort'})
                    ?a({-href=>"$url?choice=view_cohort&cohort_id=$row->{'cohort_reference_cohort'}", -title=>"click for cohort details"}, $row->{'c2_name'})
                    :i('[none]')
                 )
               )
             )

           . hr()

           . h3("Mice in this cohort")
           . $message;

  $sql = qq(select m2co_mouse_id
            from   mice2cohorts
            where  m2co_cohort_id = ?
            order  by m2co_mouse_id asc
           );

  @sql_parameters = ($cohort_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mice found in this cohort: tell and quit
  if ($rows == 0) {
     $page .= p({-class=>"red"}, "No mice in this cohort")
              . hr({-align=>"left", -width=>"50%"});
  }

  # mice found: display
  else {
     $page .= start_table( {-border=>1, -summary=>"table"} )
              . Tr(
                  th(span({-title=>"this is just the table row number"}, "#")),
                  th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
                  th("mouse id"),
                  th("delete")
                );

     # loop over all results from previous select
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];                # fetch next row

         # add table row for current cohort
         $page .= Tr({-align=>'center'},
                    td($i+1),
                    td(checkbox('mouse_select', '0', $row->{'m2co_mouse_id'}, '')),
                    td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $row->{'m2co_mouse_id'}}, $row->{'m2co_mouse_id'})),
                    td(a({-href=>"$url?choice=view_cohort&cohort_id=$cohort_id&job=remove_from_cohort&mouse_id=" . $row->{'m2co_mouse_id'}}, 'remove from this cohort'))
                  );
     }

     $page .= end_table()

              . submit(-name => "job", -value=>"Add selected mice to cart")
              . p();

  }

  # offer to add more mice to cohort
  $page .= p("You may add mice to the cohort by entering their IDs: ")
#               . textfield(-name => "mouse_id", -size=>"9", -maxlength=>"8", -title=>"enter an 8 digit mouse id")
              . textarea(-name => "mouse_ids", -columns=>"20", -rows=>"2", -override=>"1", -title=>"example: 30000001,30000033, 30010043")
              . '&nbsp;&nbsp;&nbsp;'
              . submit(-name=>"job", -value=>"add to cohort")
              . end_form();

  return $page;
}
# end of cohort_view
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE043 line_parameterset_matrix():                  medical record summary (line vs. parameterset matrix)
# sub line_parameterset_matrix {                           my $sr_name = 'SR_VIE043';
#   my ($global_var_href) = @_;                            # get reference to global vars hash
#   my $url               = url();
#   my ($page, $sql, $result, $rows, $row, $i);
#   my ($mouse_line, $parameterset, $background_color, $number_of_orderlists, $columns);
#   my %mouse_lines;
#   my %medical_records_by_line_and_parameterset;
#   my %parameterset_id_by_name;
#   my %mouse_line_id_by_name;
#   my %parametersets;
#   my @sql_parameters;
#
#   $page .= h2("Medical records: summary (line vs. parameterset) ")
#            . hr();
#
#   #############################
#   # get numbers
#   $sql = qq(select mouse_line, line_name, parameterset_id, parameterset_name, count(mr_id) as no_mrs
#             from   medical_records
#                    join mice2medical_records on           mr_id = m2mr_mr_id
#                    join mice                 on        mouse_id = m2mr_mouse_id
#                    join parametersets        on parameterset_id = mr_parameterset_id
#                    join mouse_lines          on      mouse_line = line_id
#             group  by mouse_line, parameterset_id
#            );
#
#   @sql_parameters = ();
#
#   # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
#   ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );
#
#   # if nothing found: tell and quit
#   unless ($rows > 0) {
#      $page .= p("no medical records found");
#      return $page;
#   }
#
#   # else continue: build hash (1. key: mouse_line; 2. key: parameterset; value: number of medical records)
#   for ($i=0; $i<$rows; $i++) {
#       $row = $result->[$i];
#
#       $medical_records_by_line_and_parameterset{$row->{'line_name'}}{$row->{'parameterset_name'}} = $row->{'no_mrs'};
#       $parameterset_id_by_name{$row->{'parameterset_name'}} = $row->{'parameterset_id'};
#       $mouse_line_id_by_name{$row->{'line_name'}} = $row->{'mouse_line'};
#       $mouse_lines{$row->{'line_name'}}++;
#       $parametersets{$row->{'parameterset_name'}}++;
#   }
#   #############################
#
#   $page .= table({-border=>0},
#               Tr(td({-bgcolor=>"lightblue"}, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"),
#                  td("there is at least one orderlist")
#               )
#            )
#            . br();
#
#   #############################
#
#   # numbers and hash generated, now build table
#
#   # build header columns
#   foreach $parameterset (sort keys %parametersets) {
#      $columns .= th($parameterset);
#   }
#
#   $columns = th('') . $columns;
#
#   $page .= start_table({-border=>1})
#            . Tr($columns);
#
#   $columns = '';
#
#   foreach $mouse_line (sort keys %mouse_lines) {
#      $columns = '';
#
#      foreach $parameterset (sort keys %parametersets) {
#
#          $number_of_orderlists = get_orderlist_number_by_line_parameterset($global_var_href, $mouse_line_id_by_name{$mouse_line}, $parameterset_id_by_name{$parameterset});
#
#          if ($number_of_orderlists > 0) {
#             $background_color = 'lightblue';
#             $columns .= td({-align=>"right", -bgcolor=>$background_color},
#                            a({-href=>"$url?choice=show_line_orderlists_for_parameterset&line=$mouse_line_id_by_name{$mouse_line}&parameterset=$parameterset_id_by_name{$parameterset}",
#                               -title=>"$number_of_orderlists orderlists"},
#                              $medical_records_by_line_and_parameterset{$mouse_line}{$parameterset}
#                            )
#                         );
#          }
#          else {
#             $background_color = 'white';
#             $columns .= td({-align=>"right", -bgcolor=>$background_color}, $medical_records_by_line_and_parameterset{$mouse_line}{$parameterset});
#          }
#      }
#
#      $columns = th(a({-href=>"$url?choice=data_overview_for_line&line=$mouse_line_id_by_name{$mouse_line}"}, $mouse_line)) . $columns;
#
#      $page .= Tr($columns);
#   }
#
#   $page .= end_table();
#
#   return $page;
# }
# end of line_parameterset_matrix()
#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
# SR_VIE043 line_parameterset_matrix():                  medical record summary (line vs. parameterset matrix)
sub line_parameterset_matrix {                           my $sr_name = 'SR_VIE043';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($mouse_line, $parameterset, $background_color, $number_of_orderlists, $columns, $number_of_mice);
  my %mouse_lines;
  my %medical_records_by_line_and_parameterset;
  my %parameterset_id_by_name;
  my %mouse_line_id_by_name;
  my %parametersets;
  my @sql_parameters;

  $page .= h2("Medical records: summary (line vs. parameterset) ")
           . hr();

  #############################
  # get numbers
  $sql = qq(select mouse_line, line_name, parameterset_id, parameterset_name, count(mr_id) as no_mrs
            from   medical_records
                   join mice2medical_records on           mr_id = m2mr_mr_id
                   join mice                 on        mouse_id = m2mr_mouse_id
                   join parametersets        on parameterset_id = mr_parameterset_id
                   join mouse_lines          on      mouse_line = line_id
            group  by mouse_line, parameterset_id
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("no medical records found");
     return $page;
  }

  # else continue: build hash (1. key: mouse_line; 2. key: parameterset; value: number of medical records)
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $medical_records_by_line_and_parameterset{$row->{'line_name'}}{$row->{'parameterset_name'}} = $row->{'no_mrs'};
      $parameterset_id_by_name{$row->{'parameterset_name'}} = $row->{'parameterset_id'};
      $mouse_line_id_by_name{$row->{'line_name'}} = $row->{'mouse_line'};
      $mouse_lines{$row->{'line_name'}}++;
      $parametersets{$row->{'parameterset_name'}}++;
  }
  #############################

  $page .= table({-border=>0},
              Tr(td({-bgcolor=>"lightblue"}, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"),
                 td("there is at least one orderlist")
              )
           )
           . br();

  #############################

  # numbers and hash generated, now build table

  # build header columns
  foreach $parameterset (sort keys %parametersets) {
     $columns .= th($parameterset);
  }

  $columns = th('') . $columns;

  $page .= start_table({-border=>1})
           . Tr($columns);

  $columns = '';

  foreach $mouse_line (sort keys %mouse_lines) {
     $columns = '';

     foreach $parameterset (sort keys %parametersets) {

         ($number_of_mice, $number_of_orderlists) = get_orderlist_number_by_line_parameterset($global_var_href, $mouse_line_id_by_name{$mouse_line}, $parameterset_id_by_name{$parameterset});

         if ($number_of_orderlists > 0) {
            $background_color = 'lightblue';
            $columns .= td({-align=>"right", -bgcolor=>$background_color},
                           a({-href=>"$url?choice=show_line_orderlists_for_parameterset&line=$mouse_line_id_by_name{$mouse_line}&parameterset=$parameterset_id_by_name{$parameterset}",
                              -title=>"$number_of_orderlists orderlists, $number_of_mice mice"},
                             $medical_records_by_line_and_parameterset{$mouse_line}{$parameterset}
                           )
                        );
         }
         else {
            $background_color = 'white';
            $columns .= td({-align=>"right", -bgcolor=>$background_color}, $medical_records_by_line_and_parameterset{$mouse_line}{$parameterset});
         }
     }

     $columns = th(a({-href=>"$url?choice=data_overview_for_line&line=$mouse_line_id_by_name{$mouse_line}"}, $mouse_line)) . $columns;

     $page .= Tr($columns);
  }

  $page .= end_table();

  return $page;
}
# end of line_parameterset_matrix()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE044 line_orderlists_for_parameterset():          show all orderlists for a given line and parameterset
sub line_orderlists_for_parameterset {                   my $sr_name = 'SR_VIE044';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $mouse_line        = param('line');
  my $parameterset      = param('parameterset');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  $page = h2("Existing orderlists for line \"" .  get_line_name_by_id($global_var_href, $mouse_line)
             . "\" and parameterset \"" . get_parameterset_name_by_id($global_var_href, $parameterset). "\""
          )
          . hr();

  $sql = qq(select distinct orderlist_id, orderlist_status, orderlist_name, orderlist_date_created, orderlist_comment
            from   orderlists
                   join mice2orderlists on    orderlist_id = m2o_orderlist_id
                   join mice            on        mouse_id = m2o_mouse_id
                   join mouse_lines     on      mouse_line = line_id
                   join parametersets   on parameterset_id = orderlist_parameterset
            where  parameterset_id = ?
                   and     line_id = ?
           );

  @sql_parameters = ($parameterset, $mouse_line);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no orderlists found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No orderlists found");
     return $page;
  }

  # else continue
  $page .= start_table( {-border=>"1", -summary=>"orderlists"})
          . Tr( {-align=>'center'},
              th("orderlist name"),
              th("created at"),
              th("status")
            );

  # ... loop over all imports
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= Tr({-align=>'center'},
                 td(a({-href=>"$url?choice=orderlist_view&orderlist_id=" . $row->{'orderlist_id'}}, $row->{'orderlist_name'})),
                 td(format_sql_datetime2display_date($row->{'orderlist_date_created'})),
                 td($row->{'orderlist_status'})
               );
  }

  $page .= end_table();

  return $page;
}
# end of line_orderlists_for_parameterset()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE045 data_overview_for_line():                    medical record summary for a line
sub data_overview_for_line {                             my $sr_name = 'SR_VIE045';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $mouse_line        = param('line');
  my ($page, $sql, $result, $rows, $row, $i);
  my ($old_parameterset, $number_medical_records, $background_color);
  my @sql_parameters;

  $page .= h2("Medical records: summary for line \"". get_line_name_by_id($global_var_href, $mouse_line) ."\"")
           . hr();

  #############################

  $page .= table({-border=>0},
              Tr(td({-bgcolor=>"lightblue"}, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"),
                 td("medical records available")
              ) .
              Tr(td({-bgcolor=>"yellow"}, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"),
                 td("orderlist done, no medical records available")
              ) .
              Tr(td({-bgcolor=>"red"}, "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"),
                 td("medical records missing")
              )
           )
           . br();

  #############################
  # get parametersets with at least one orderlist for this mouseline
  $sql = qq(select distinct parameterset_id, parameterset_name, orderlist_name, orderlist_id, orderlist_status
            from   parametersets
                   left join orderlists      on orderlist_parameterset = parameterset_id
                   left join mice2orderlists on       m2o_orderlist_id = orderlist_id
                   left join mice            on           m2o_mouse_id = mouse_id
            where  mouse_line = ?
            order  by parameterset_name asc
           );

  @sql_parameters = ($mouse_line);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("no medical records found");
     return $page;
  }

  #############################

  $page .= start_table({-border=>1})
           . Tr(th('parameterset_name'),
                th('orderlist'),
                th('orderlist status'),
                th('# medical records')
             );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $number_medical_records = get_number_medical_records_of_orderlist($global_var_href, $row->{'orderlist_id'});

      if ($number_medical_records > 0) {
         $background_color = 'lightblue';
      }
      elsif ($row->{'orderlist_status'} eq 'done' && $number_medical_records == 0) {
         $background_color = 'yellow';
      }
      elsif ($row->{'orderlist_status'} eq 'ordered' && $number_medical_records == 0) {
         $background_color = 'red';
      }
      else {
         $background_color = 'white';
      }

      $page .= Tr({-bgcolor=>$background_color},
                  td(($row->{parameterset_name} ne $old_parameterset)
                     ?b($row->{parameterset_name})
                     :''
                  ),
                  td(a({-href=>"$url?choice=orderlist_view&orderlist_id=" . $row->{'orderlist_id'}}, $row->{'orderlist_name'})),
                  td($row->{'orderlist_status'}),
                  td({-align=>'right'}, $number_medical_records)
               );

      $old_parameterset = $row->{parameterset_name};
  }

  $page .= end_table();

  return $page;
}
# end of data_overview_for_line()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE046 treatment_procedures_overview()              treatment procedures overview
sub treatment_procedures_overview {                      my $sr_name = 'SR_VIE046';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  $page = h2("Treatment protocols overview " )
          . hr();

  $sql = qq(select *
            from   treatment_procedures
                   left join projects on project_id = tp_treatment_project
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no treatment procedures found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No treatment protocols defined");
     return $page;
  }

  # else continue: display treatment procedures table
  $page .= start_table( {-border=>"1", -summary=>"treatment_procedures_overview"})
          . Tr( {-align=>'center', -bgcolor=>'lightblue'},
              th({-rowspan=>2}, '#'),
              th({-colspan=>6}, "treatment"),
              th({-colspan=>6}, "[applied substance]"),
            )
          . Tr( {-align=>'center', -bgcolor=>'lightblue'},
              th("name"),
              th("description"),
              th("type"),
              th("purpose"),
              th("project"),
              th("deprecated"),
              th("name"),
              th("application"),
              th("amount"),
              th("concentration"),
              th("volume"),
              th("solvent")
            );

  # ... loop over all treatment procedures
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td(a({-href=>"$url?choice=treatment_procedure_view&treatment_procedure_id=$row->{'tp_id'}"}, $row->{'tp_treatment_name'})),
                 td($row->{'tp_treatment_description'}),
                 td($row->{'tp_treatment_type'}),
                 td($row->{'tp_application_purpose'}),
                 td($row->{'project_name'}),
                 td(format_sql_date2display_date($row->{'tp_treatment_deprecated_since'})),
                 td($row->{'tp_applied_substance'}),
                 td($row->{'tp_application_type'}),
                 td($row->{'tp_applied_substance_amount'} . ' ' . $row->{'tp_applied_substance_amount_unit'}),
                 td($row->{'tp_applied_substance_concentration'} . ' ' . $row->{'tp_applied_substance_concentration_unit'}),
                 td($row->{'tp_applied_substance_volume'} . ' ' . $row->{'tp_applied_substance_volume_unit'}),
                 td($row->{'tp_application_medium'})
               );
  }

  $page .= end_table();

  return $page;
}
# end of treatment_procedures_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE047 treatment_procedure_view                     treatment procedure details view
sub treatment_procedure_view {                           my $sr_name = 'SR_VIE047';
  my ($global_var_href)      = @_;                            # get reference to global vars hash
  my $treatment_procedure_id = param('treatment_procedure_id');
  my $url                    = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($treatment_procedure_name);
  my @sql_parameters;

  # check input: is treatment procedure id given? is it a number?
  if (!param('treatment_procedure_id') || param('treatment_procedure_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid treatment protocol id"));
     return $page;
  }

  # get treatment procedure name by id
  $sql = qq(select tp_treatment_name
            from   treatment_procedures
            where  tp_id = ?
           );

  @sql_parameters = ($treatment_procedure_id);

  ($treatment_procedure_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $page .= h2("Details about treatment protocol \"$treatment_procedure_name\" " . ' (' . a({-href=>"$url?choice=treatment_procedures_overview"}, 'all treatment protocols') . ')')
           . hr();

  $sql = qq(select *
            from   treatment_procedures
                   left join projects on project_id = tp_treatment_project
            where  tp_id = ?
           );

  @sql_parameters = ($treatment_procedure_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("No details on this treatment protocol");
     return $page;
  }

  # else continue: get result handle to generate details table
  $row = $result->[0];

  $page .= h3("Treatment protocol " . qq("$row->{'tp_treatment_name'}" ))
           . table( {-border=>1, -summary=>"table"},
               Tr(
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "Treatment protocol name "),
                 td($row->{'tp_treatment_name'})
               ) .
               Tr(
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "Treatment description"),
                 td($row->{'tp_treatment_description'})
               ) .
               Tr(
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "Treatment type"),
                 td($row->{'tp_treatment_type'})
               ) .
               Tr(
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "Treatment purpose"),
                 td($row->{'tp_application_purpose'})
               ) .
               Tr(
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "Project"),
                 td($row->{'project_name'})
               ) .
               Tr(
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "deprecated since"),
                 td(format_sql_date2display_date($row->{'tp_treatment_deprecated_since'}))
               ) .
               Tr(
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "Full protocol"),
                 td($row->{'tp_treatment_full_protocol'})
               ) .
               Tr(
                 th({-rowspan=>6, -bgcolor=>'lightblue'}, "[applied substance]"),
                 th({-bgcolor=>'lightblue'}, "name"),
                 td($row->{'tp_applied_substance'})
               ) .
               Tr(
                 th({-bgcolor=>'lightblue'}, "application"),
                 td($row->{'tp_application_type'})
               ) .
               Tr(
                 th({-bgcolor=>'lightblue'}, "amount"),
                 td($row->{'tp_applied_substance_amount'} . ' ' . $row->{'tp_applied_substance_amount_unit'})
               ) .
               Tr(
                 th({-bgcolor=>'lightblue'}, "concentration"),
                 td($row->{'tp_applied_substance_concentration'} . ' ' . $row->{'tp_applied_substance_concentration_unit'})
               ) .
               Tr(
                 th({-bgcolor=>'lightblue'}, "total applied volume"),
                 td($row->{'tp_applied_substance_volume'} . ' ' . $row->{'tp_applied_substance_volume_unit'})
               ) .
               Tr(
                 th({-bgcolor=>'lightblue'}, "solvent"),
                 td($row->{'tp_application_medium'})
               )
             );

  return $page;
}
# end of treatment_procedure_view
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE048 mouse_treatment_view                         mouse treatment details view
sub mouse_treatment_view {                               my $sr_name = 'SR_VIE048';
  my ($global_var_href)  = @_;                            # get reference to global vars hash
  my $mouse_treatment_id = param('mouse_treatment_id');
  my $mouse_id           = param('mouse_id');
  my $url                = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($treatment_procedure_name);
  my @sql_parameters;

  # check input: is mouse treatment id given? is it a number?
  if (!param('mouse_treatment_id') || param('mouse_treatment_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid mouse treatment id"));
     return $page;
  }

  if (!param('mouse_id') || param('mouse_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid mouse id"));
     return $page;
  }

  $page .= h2("Details about treatment on mouse $mouse_id")
           . hr();

  $sql = qq(select *
            from   mice2treatment_procedures
                        join treatment_procedures on tp_id   = m2tp_treatment_procedure_id
                   left join users                on user_id = m2tp_treatment_user_id
            where  m2tp_id = ?
           );

  @sql_parameters = ($mouse_treatment_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("No details on this mouse treatment");
     return $page;
  }

  # else continue: get result handle to generate details table
  $row = $result->[0];

  $page .= h3("Mouse treatment $mouse_treatment_id")
           . table( {-border=>1, -summary=>"table"},
               Tr(
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "treated mouse"),
                 td(a({-href=>"$url?choice=mouse_details&mouse_id=$row->{'m2tp_mouse_id'}"}, $row->{'m2tp_mouse_id'}))
               ) .

               Tr(
                 th({-colspan=>3}, " ")
               ) .

               Tr(
                 th({-colspan=>2, -bgcolor=>'lightblue'},
                    a({-href=>"javascript:show('treatment_table','12')", -style=>"text-decoration: none; display: inline; ", -name=>"toggle", -id=>"treatment_table" . "-show"}, "(expand) ") .
                    a({-href=>"javascript:hide('treatment_table','12')", -style=>"text-decoration: none; display: none;",    -name=>"toggle", -id=>"treatment_table" . "-hide"}, "(collapse) ") .
                    "Treatment protocol name "
                 ),
                 td($row->{'tp_treatment_name'})
               ) .
               Tr({-name=>"cage_row", -id=>"treatment_table" . "-" . '1', -style=>"display: none;"},
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "Treatment description"),
                 td($row->{'tp_treatment_description'})
               ) .
               Tr({-name=>"cage_row", -id=>"treatment_table" . "-" . '2', -style=>"display: none;"},
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "Treatment type"),
                 td($row->{'tp_treatment_type'})
               ) .
               Tr({-name=>"cage_row", -id=>"treatment_table" . "-" . '3', -style=>"display: none;"},
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "Treatment purpose"),
                 td($row->{'tp_application_purpose'})
               ) .
               Tr({-name=>"cage_row", -id=>"treatment_table" . "-" . '4', -style=>"display: none;"},
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "Project"),
                 td($row->{'project_name'})
               ) .
               Tr({-name=>"cage_row", -id=>"treatment_table" . "-" . '5', -style=>"display: none;"},
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "deprecated since"),
                 td(format_sql_date2display_date($row->{'tp_treatment_deprecated_since'}))
               ) .
               Tr({-name=>"cage_row", -id=>"treatment_table" . "-" . '6', -style=>"display: none;"},
                 th({-colspan=>2, -bgcolor=>'lightblue'}, "Full protocol"),
                 td($row->{'tp_treatment_full_protocol'})
               ) .
               Tr({-name=>"cage_row", -id=>"treatment_table" . "-" . '7', -style=>"display: none;"},
                 th({-rowspan=>6, -bgcolor=>'lightblue'}, "[applied substance]"),
                 th({-bgcolor=>'lightblue'}, "name"),
                 td($row->{'tp_applied_substance'})
               ) .
               Tr({-name=>"cage_row", -id=>"treatment_table" . "-" . '8', -style=>"display: none;"},
                 th({-bgcolor=>'lightblue'}, "application"),
                 td($row->{'tp_application_type'})
               ) .
               Tr({-name=>"cage_row", -id=>"treatment_table" . "-" . '9', -style=>"display: none;"},
                 th({-bgcolor=>'lightblue'}, "amount"),
                 td($row->{'tp_applied_substance_amount'} . ' ' . $row->{'tp_applied_substance_amount_unit'})
               ) .
               Tr({-name=>"cage_row", -id=>"treatment_table" . "-" . '10', -style=>"display: none;"},
                 th({-bgcolor=>'lightblue'}, "concentration"),
                 td($row->{'tp_applied_substance_concentration'} . ' ' . $row->{'tp_applied_substance_concentration_unit'})
               ) .
               Tr({-name=>"cage_row", -id=>"treatment_table" . "-" . '11', -style=>"display: none;"},
                 th({-bgcolor=>'lightblue'}, "total applied volume"),
                 td($row->{'tp_applied_substance_volume'} . ' ' . $row->{'tp_applied_substance_volume_unit'})
               ) .
               Tr({-name=>"cage_row", -id=>"treatment_table" . "-" . '12', -style=>"display: none;"},
                 th({-bgcolor=>'lightblue'}, "solvent"),
                 td($row->{'tp_application_medium'})
               ) .

               Tr(
                 th({-colspan=>3}, " ")
               ) .

               Tr(
                 th({-colspan=>2, -bgcolor=>'#DCDCDC'}, "treatment date " . br() . "(for single treatment)"),
                 td(format_sql_date2display_date($row->{'m2tp_treatment_datetime'}))
               ) .
               Tr(
                 th({-rowspan=>2, -bgcolor=>'#DCDCDC'}, "treatment period " . br() . "(for multiple treatments)"),
                 th({-bgcolor=>'#DCDCDC'}, "from"),
                 td(format_sql_datetime2display_datetime($row->{'m2tp_application_start_datetime'}))
               ) .
               Tr(
                 th({-bgcolor=>'#DCDCDC'}, "to"),
                 td(format_sql_datetime2display_datetime($row->{'m2tp_application_end_datetime'}))
               ) .
               Tr(
                 th({-colspan=>2, -bgcolor=>'#DCDCDC'}, "[applied amount]"),
                 td({-align=>'center'}, $row->{'m2tp_applied_amount'} . ' ' . $row->{'m2tp_applied_amount_unit'})
               ) .
               Tr(
                 th({-colspan=>2, -bgcolor=>'#DCDCDC'}, "treatment success "),
                 td({-align=>'center'}, $row->{'m2tp_treatment_success'})
               ) .
               Tr(
                 th({-colspan=>2, -bgcolor=>'#DCDCDC'}, "reason for failure"),
                 td({-align=>'center'}, $row->{'m2tp_application_terminated_why'})
               ) .
               Tr(
                 th({-colspan=>2, -bgcolor=>'#DCDCDC'}, "treatment by"),
                 td({-align=>'center'}, $row->{'user_name'})
               ) .
               Tr(
                 th({-colspan=>2, -bgcolor=>'#DCDCDC'}, "treatment comment"),
                 td({-align=>'center'}, $row->{'m2tp_application_comment'})
               )
             );

  return $page;
}
# end of mouse_treatment_view
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE049 cohorts_overview():                          cohorts overview
sub cohorts_overview {                                   my $sr_name = 'SR_VIE049';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $show_rows         = $global_var_href->{'show_rows'};
  my $dbh               = $global_var_href->{'dbh'};
  my $session           = $global_var_href->{'session'};
  my $user_id           = $session->param(-name=>'user_id');
  my $url               = url();
  my $start_row         = param('start_row');
  my $cohort_id         = param('cohort_id');
  my $datetime_now      = get_current_datetime_for_sql();
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my @sql_parameters;

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  ################################################################
  # delete cohort if requested
  if (param('choice') eq "delete_cohort") {

     if (param('cohort_id') && param('cohort_id') =~ /[0-9]+$/) {

        # begin transaction
        $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start delete cohort transaction)", $sr_name . "-" . __LINE__);

        # delete entries in mice2cohorts for this cohort
        $dbh->do("delete
                  from   mice2cohorts
                  where  m2co_cohort_id  = ?
                 ", undef, $cohort_id
                ) or &error_message_and_exit($global_var_href, "SQL error (could not delete mice to cohort assignment)", $sr_name . "-" . __LINE__);

        # delete cohort
        $dbh->do("delete
                  from   cohorts
                  where  cohort_id  = ?
                 ", undef, $cohort_id
                ) or &error_message_and_exit($global_var_href, "SQL error (could not delete mice to cohort assignment)", $sr_name . "-" . __LINE__);

        $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

        &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tdelete_cohort\tcohort:$cohort_id");
     }
  }
  ################################################################
  $page = h2("Cohorts overview "
             . a({-href=>"$url?choice=cohorts_overview", -title=>'reload page'},
                 img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
               )
          )
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select count(m2co_mouse_id) as number_of_mice, c1.cohort_id as c_id, c1.cohort_name as c_name, c1.cohort_purpose as c_purpose,
                   c1.cohort_pipeline as c_pipeline, c1.cohort_description as c_description, c1.cohort_status as c_status,
                   c1.cohort_datetime as c_datetime, c1.cohort_type as c_type, c1.cohort_reference_cohort as c_ref,
                   c2.cohort_name as c2_name, c2.cohort_type as c2_type
            from   cohorts c1
                   left join mice2cohorts on             m2co_cohort_id = c1.cohort_id
                   left join cohorts c2   on c1.cohort_reference_cohort = c2.cohort_id
            group  by c1.cohort_id
            order  by c_name asc
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no cohorts found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No cohorts found.");
    return $page;
  }

  # else: first generate table header ...
  $page .= h3("$rows cohorts found")
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=cohorts_overview" . '&start_row=1'}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=cohorts_overview" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=cohorts_overview" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=cohorts_overview" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
              )
              :''
             )
           . start_table( {-border=>"1", -summary=>"cohorts_overview"})
           . Tr( {-align=>'left'},
               td(b('#')),
               td(b('name')),
               td(b('ID')),
               td(b('purpose')),
               td(b('Eumodic pipeline')),
               td(b('description')),
               td(b('type')),
               td(b('reference cohort')),
               td(b('# mice')),
               td(b('generated')),
               td(b('delete cohort'))
             );

  # ... then loop over all blobs
  for ($i=0; $i<$rows; $i++) {
      if ($i+1 < $start_row )              { next; }               # skip all rows with (row index < $start_row)
      if ($i+1 >= $start_row + $show_rows) { last; }               # skip all rows with (row index > $start_row+$show_rows): exit loop

      $row = $result->[$i];

      # generate the current row
      $page .= Tr({-align=>'center'},
                 td($i+1),
                 td({-align=>'left'}, a({-href=>"$url?choice=view_cohort&cohort_id=$row->{'c_id'}", -title=>"click for cohort details"}, $row->{'c_name'}) ),
                 td($row->{'c_id'}),
                 td($row->{'c_purpose'}),
                 td($row->{'c_pipeline'}),
                 td($row->{'c_description'}),
                 td($row->{'c_type'}),
                 td(defined($row->{'c_ref'})
                    ?a({-href=>"$url?choice=view_cohort&cohort_id=$row->{'c_ref'}", -title=>"click for cohort details"}, $row->{'c2_name'})
                    :i('[none]')
                 ),
                 td($row->{'number_of_mice'}),
                 td(format_sql_datetime2display_datetime($row->{'c_datetime'})),
                 td(a({-href=>"$url?choice=delete_cohort&cohort_id=$row->{'c_id'}", -title=>"caution: will delete cohort without further warning!"}, "delete this cohort"))
               );
  }

  $page .= end_table();

  return $page;
}
# end of cohorts_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE050 status_codes_overview():                     status codes overview
sub status_codes_overview {                              my $sr_name = 'SR_VIE050';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  $page = h2("Status codes overview " )
          . hr()
          . p("When uploading phenotyping data using Excel files, a status code has to be provided for missing values, explaining why a value is missing. ");

  $sql = qq(select setting_value_text, setting_description
            from   settings
            where  setting_item = ?
            order  by setting_description
           );

  @sql_parameters = ('mr_status_codes');

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no status codes found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No status code definitons defined");
     return $page;
  }

  # else continue: display imports table
  $page .= start_table( {-border=>"1", -summary=>"status_codes_overview"})
          . Tr( {-align=>'center'},
              th('status code' . br() . '[to be used instead of value]'),
              th('status code description')
            );

  # ... loop over all imports
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= Tr(
                 td({-align=>'center'}, $row->{'setting_value_text'}),
                 td({-align=>'left'},   $row->{'setting_description'})
               );
  }

  $page .= end_table();

  return $page;
}
# end of status_codes_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE051 sterile_matings_overview():                  sterile matings overview
sub sterile_matings_overview {                           my $sr_name = 'SR_VIE051';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $sterile_period    = param('sterile_period');
  my $session           = $global_var_href->{'session'};   # session handle
  my $user_id           = $session->param('user_id');
  my @user_projects     = get_user_projects($global_var_href, $user_id);
  my $user_projects_sql = join(',', @user_projects);
  my ($page, $sql, $result, $rows, $row, $i);
  my ($project);
  my @sql_parameters;
  my @project_strings;

  if (!param('sterile_period') || param('sterile_period') !~ /^[0-9]+$/) {
     $sterile_period = 30;
  }

  #############################################################
  # build projects string for current user
  foreach $project (@user_projects) {
     push(@project_strings, get_project_name_by_id($global_var_href, $project));
  }
  #############################################################

  $page = start_form(-action => url())
          . h2("Sterile matings overview "
               . a({-href=>"$url?choice=sterile_matings_overview&sterile_period=$sterile_period", -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'}))
               . "&nbsp;&nbsp;&nbsp;or set another sterile period "
               . popup_menu(-name => 'sterile_period', -values  => [1..300], -default=>30)
               . submit(-name => "choice", -value=>"Sterile matings overview")
            )
          . end_form()
          . hr();

  $sql = qq(select mating_id, date(mating_matingstart_datetime), datediff(curdate(), date(mating_matingstart_datetime)) as no_litter_since,
                   mating_name, mating_comment,
                   project_name, count(litter_id) as number_of_litters,
                   line_name, strain_name
            from   matings
                   join      projects      on   mating_project = project_id
                   left join litters       on litter_mating_id = mating_id
                   join      mouse_lines   on      mating_line = line_id
                   join      mouse_strains on    mating_strain = strain_id
            where  project_id in ($user_projects_sql)
                   and mating_matingend_datetime IS NULL
            group  by mating_id
            having   number_of_litters = ?
                   and no_litter_since > ?
            order  by no_litter_since desc
           );

  @sql_parameters = (0, $sterile_period);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no status codes found at all: tell and quit
  unless ($rows > 0) {
     $page .= p("No matings without litters for your projects found");
     return $page;
  }

  # else continue: display imports table
  $page .= h3("Matings with no litter for more than $sterile_period days in your projects: " . join(', ', @project_strings))
           . start_table( {-border=>"1", -summary=>"sterile_matings_overview"})
           . Tr( {-align=>'center'},
               th('mating'),
               th('no litter since' . br() . '[days]'),
               th('mating name'),
               th('mating strain'),
               th('mating line'),
               th('mother(s)' . br() . 'racks/cages'),
               th('mating comment'),
               th('project')
             );

  # ... loop over all imports
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= Tr(
                 td({-align=>'right'},  a({-href=>"$url?choice=mating_view&mating_id=$row->{'mating_id'}"}, $row->{'mating_id'})),
                 td({-align=>'right'},  $row->{'no_litter_since'}),
                 td({-align=>'center'}, $row->{'mating_name'}),
                 td({-align=>'center'}, $row->{'strain_name'}),
                 td({-align=>'center'}, $row->{'line_name'}),
                 td({-align=>'center'}, get_mothers_cages_for_mating($global_var_href, $row->{'mating_id'})),
                 td({-align=>'center'}, $row->{'mating_comment'}),
                 td({-align=>'center'}, $row->{'project_name'})
               );
  }

  $page .= end_table();

  return $page;
}
# end of sterile_matings_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE052 workflows_overview():                        workflows overview
sub workflows_overview {                                 my $sr_name = 'SR_VIE052';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  $page = h2("Workflows overview ")
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select workflow_id, workflow_name, workflow_description, workflow_is_active
            from   workflows
            order  by workflow_name asc
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no workflows found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No workflows found.");
    return $page;
  }

  # else: first generate table header ...
  $page .= h3("$rows workflows found")
           . start_table( {-border=>"1", -summary=>"workflows_overview"})
           . Tr( {-align=>'left'},
               td(b('workflow name')),
               td(b('workflow description')),
               td(b('workflow active'))
             );

  # ... then loop over all blobs
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      # generate the current row
      $page .= Tr({-align=>'center'},
                 td({-align=>'left'}, a({-href=>"$url?choice=workflow_details&workflow_id=$row->{'workflow_id'}", -title=>"click for workflow details"}, $row->{'workflow_name'}) ),
                 td({-align=>'left'}, $row->{'workflow_description'}),
                 td($row->{'workflow_is_active'})
               );
  }

  $page .= end_table();

  return $page;
}
# end of workflows_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE053 workflow_details                             workflow details view
sub workflow_details {                                   my $sr_name = 'SR_VIE053';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $session           = $global_var_href->{'session'};            # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $workflow_id       = param('workflow_id');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my @sql_parameters;

  # check input: is workflow id given? is it a number?
  if (!param('workflow_id') || param('workflow_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid workflow id"));
     return $page;
  }

  # first table
  $page .= h2("Worflow details")
           . hr();

  $sql = qq(select workflow_id, workflow_name, workflow_description, workflow_is_active
            from   workflows
            where  workflow_id = ?
           );

  @sql_parameters = ($workflow_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("No details on this workflow");
     return $page;
  }

  # else continue: get result handle to generate details table
  $row = $result->[0];

  $page .= h3("Workflow " . qq("$row->{'workflow_name'}" ))
           . table( {-border=>1, -summary=>"table"},
               Tr(
                 th("Workflow name"),
                 td($row->{'workflow_name'})
               ),
               Tr(
                 th("Workflow description"),
                 td($row->{'workflow_description'})
               ),
               Tr(
                 th("Active?"),
                 td($row->{'workflow_is_active'})
               )
             )

           . hr();

  # second table
  $page .= h3("Parametersets assigned to this workflow");

  $sql = qq(select workflow_id, workflow_name, parameterset_id, parameterset_name, project_name, w2p_days_from_ref_date
            from   workflows
                   join workflows2parametersets on     workflow_id = w2p_workflow_id
                   join parametersets           on parameterset_id = w2p_parameterset_id
                   left join projects           on      project_id = parameterset_project_id
            where  workflow_id = ?
            order  by w2p_days_from_ref_date asc
           );

  @sql_parameters = ($workflow_id);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  if ($rows == 0) {
     $page .= p("No parametersets assigned to this workflow");
  }
  else {
     $page .= start_table( {-border=>1, -summary=>"table"})
             . Tr(
                 th("Parameterset"),
                 th("Project"),
                 th("due " . br() . "[days from workflow start]")
               );

     # loop over all results from previous select
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];                # fetch next row

         # add table row for current cohort
         $page .= Tr({-align=>'center'},
                    td(a({-href=>"$url?choice=parameterset_view&parameterset_id=" . $row->{'parameterset_id'}}, $row->{'parameterset_name'})),
                    td($row->{'project_name'}),
                    td($row->{'w2p_days_from_ref_date'})
                  );
     }

     $page .= end_table()
  }

  return $page;
}
# end of workflow_details
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE054 find_orderlists_with_multiple_uploads:       find line by keyword
sub find_orderlists_with_multiple_uploads {              my $sr_name = 'SR_VIE054';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($orderlist_name, $orderlist_date_scheduled, $orderlist_parameterset, $orderlist_status, $parameterset_name, $project_name);
  my @sql_parameters;

  $page = h2("Orderlists with multiple uploads ")
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select distinct mr_orderlist_id, count(distinct mr_parent_mr_group) as upload_sets
            from   mice2medical_records
                   join medical_records on m2mr_mr_id = mr_id
            where  mr_orderlist_id > 0
            group  by m2mr_mouse_id, mr_orderlist_id
            having upload_sets > 1
            order  by mr_orderlist_id asc
          );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no such orderlists found at all: tell and quit
  unless ($rows > 0) {
    $page .= h2("Orderlists with multiple uploads ")
            . hr()
            . p("No orderlists with multiple uploads found!");

    return $page;
  }

  # ... otherwise continue with result table

  # first generate table header ...
  $page .= h3("Found $rows orderlist(s) with multiple medical records uploads: " )
           . start_table( {-border=>"1", -summary=>"orderlists"})
           . Tr(
               th("orderlist name"),
               th("parameterset"),
               th("project"),
               th("scheduled date"),
               th("# uploads")
             );

  # ... then loop over all lines
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $sql = qq(select orderlist_name, orderlist_date_scheduled, orderlist_parameterset, orderlist_status, parameterset_name, project_name
                from   orderlists
                       join parametersets on  orderlist_parameterset = parameterset_id
                          join projects      on parameterset_project_id = project_id
                   where  orderlist_id = ?
             );

      @sql_parameters = ($row->{'mr_orderlist_id'});

     ($orderlist_name, $orderlist_date_scheduled, $orderlist_parameterset,
      $orderlist_status, $parameterset_name, $project_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      # generate the current row
      $page .= Tr(
                 td({-align=>'left'},   a({-href=>"$url?choice=orderlist_view&orderlist_id=$row->{'mr_orderlist_id'}", -title=>"click to view line details"}, $orderlist_name)),
                 td($parameterset_name),
                 td($project_name),
                 td(format_sql_date2display_date($orderlist_date_scheduled)),
                 td({-align=>'center'}, $row->{'upload_sets'}),
               );
  }

  $page .= end_table();

  return $page;
}
# end of find_orderlists_with_multiple_uploads()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE055 line_breeding_stats                          breeding statistics for a line
sub line_breeding_stats {                                my $sr_name = 'SR_VIE055';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $line              = param('line');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i, $rc, $old_mating, $number_mothers);
  my ($litter_weaned_male, $litter_weaned_female, $litter_weaned_total);
  my ($sum_mothers, $sum_litters);
  my ($sum_reported_alive_male, $sum_reported_alive_female, $sum_reported_alive_total);
  my ($sum_reported_dead_male, $sum_reported_dead_female, $sum_reported_dead_total, $sum_reduced);
  my ($sum_weaned_male, $sum_weaned_female, $sum_weaned_total, $sum_non_zero_litters);
  my @sql_parameters;

  # check input: is line id given? is it a number?
  if (!param('line') || param('line') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid line id"));
     return $page;
  }

  # first table
  $page .= h2("Breeding statistics for line " . get_line_name_by_id($global_var_href, $line))
           . hr();

  $sql = qq(select line_id, mating_id, mating_scheme, mating_purpose, mating_matingstart_datetime, mating_matingend_datetime,
                   litter_id, litter_in_mating, litter_born_datetime,
                   litter_alive_total, litter_alive_male, litter_alive_female,
                   litter_dead_total, litter_dead_male, litter_dead_female,
                   litter_reduced, litter_reduced_reason, litter_weaning_datetime, litter_comment
            from   matings
                        join mouse_lines on mating_line = line_id
                   left join litters     on   mating_id = litter_mating_id
            where  mating_line = ?
            order  by mating_id asc, litter_in_mating asc
           );

  @sql_parameters = ($line);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("No breeding statistics for this line available (no matings found)");
     return $page;
  }

  $page .= start_table( {-border=>1, -summary=>"table"})
           . Tr(
               th({-rowspan=>2}, "#"),
               th({-colspan=>6}, "mating"),
               th({-colspan=>4}, "litter"),
               th({-colspan=>3}, "reported alive"),
               th({-colspan=>3}, "reported dead"),
               th({-rowspan=>2}, "reduced"),
               th({-colspan=>3}, "weaned")
             )
           . Tr(
               th("mating"),
               th("mother"),
               th("father"),
               th("mothers"),
               th("start"),
               th("end"),
               th("#"),
               th("litter"),
               th("born"),
               th("weaned"),
               th("male"),
               th("female"),
               th("total"),
               th("male"),
               th("female"),
               th("total"),
               th("male"),
               th("female"),
               th("total")
             );

  # loop over all results from previous select
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      # reset 
      ($litter_weaned_male, $litter_weaned_female, $litter_weaned_total) = (0,0,0);

      # litter found
      if (defined($row->{'litter_id'})) {
         $number_mothers = scalar @{get_mothers_of_litter($global_var_href, $row->{'litter_id'})};

         ($litter_weaned_male, $litter_weaned_female, $litter_weaned_total) = get_litter_stats($global_var_href, $row->{'litter_id'});

         $sum_non_zero_litters++;
      }
      # no litter
      else {
         $number_mothers = get_mothers_of_mating($global_var_href, $row->{'mating_id'});
      }

      # add table row for current cohort
      $page .= Tr({-align=>'center', -bgcolor=>((defined($row->{'litter_id'}))?'lightblue':'white')},
                  td(($i+1)),
                  td(a({-href=>"$url?choice=mating_view&mating_id=" . $row->{'mating_id'}}, $row->{'mating_id'})),
                  td(get_mating_mother_first_genotype($global_var_href, $row->{'mating_id'})),
                  td(get_mating_father_first_genotype($global_var_href, $row->{'mating_id'})),
                  td($number_mothers),
                  td(format_sql_datetime2display_date($row->{'mating_matingstart_datetime'})),
                  td(format_sql_datetime2display_date($row->{'mating_matingend_datetime'})),
                  td($row->{'litter_in_mating'}),
                  td(a({-href=>"$url?choice=litter_view&litter_id=" . $row->{'litter_id'}}, $row->{'litter_id'})),
                  td(format_sql_datetime2display_date($row->{'litter_born_datetime'})),
                  td(format_sql_datetime2display_date($row->{'litter_weaning_datetime'})),
                  td($row->{'litter_alive_male'}),
                  td($row->{'litter_alive_female'}),
                  td($row->{'litter_alive_total'}),
                  td($row->{'litter_dead_male'}),
                  td($row->{'litter_dead_female'}),
                  td($row->{'litter_dead_total'}),,
                  td($row->{'litter_reduced'}),
                  td($litter_weaned_male),
                  td($litter_weaned_female),
                  td($litter_weaned_total)
               );

      $sum_mothers               += $number_mothers;
      $sum_reported_alive_male   += $row->{'litter_alive_male'};
      $sum_reported_alive_female += $row->{'litter_alive_female'};
      $sum_reported_alive_total  += $row->{'litter_alive_total'};
      $sum_reported_dead_male    += $row->{'litter_dead_male'};
      $sum_reported_dead_female  += $row->{'litter_dead_female'};
      $sum_reported_dead_total   += $row->{'litter_dead_total'};
      $sum_reduced               += $row->{'litter_reduced'};
      $sum_weaned_male           += $litter_weaned_male;
      $sum_weaned_female         += $litter_weaned_female;
      $sum_weaned_total          += $litter_weaned_total;

  }

  $sum_litters = $i;

  $page .= Tr(
             th({-rowspan=>2, -colspan=>4}, ""),
             th({-rowspan=>2}, "mothers"),
             th({-colspan=>3, -rowspan=>2}, ""),
             th({-colspan=>2}, "litters"),
             th({-rowspan=>3}, ""),
             th({-colspan=>3}, "reported alive"),
             th({-colspan=>3}, "reported dead"),
             th({-rowspan=>2}, "reduced"),
             th({-colspan=>3}, "weaned")
           ) .
           Tr(
             th({-colspan=>1}, "(all)"),
             th({-colspan=>1}, "(reported)"),
             th({-colspan=>1}, "males"),
             th({-rowspan=>1}, "females"),
             th({-colspan=>1}, "total"),
             th({-colspan=>1}, "males"),
             th({-rowspan=>1}, "females"),
             th({-colspan=>1}, "total"),
             th({-colspan=>1}, "males"),
             th({-rowspan=>1}, "females"),
             th({-colspan=>1}, "total")
           ) .
           Tr(
             th({-colspan=>4}, "sums"),
             th({-colspan=>1}, $sum_mothers),
             th({-colspan=>3}, ""),
             th({-colspan=>1}, $sum_litters),
             th({-colspan=>1}, $sum_non_zero_litters),
             th({-colspan=>1}, $sum_reported_alive_male),
             th({-rowspan=>1}, $sum_reported_alive_female),
             th({-colspan=>1}, $sum_reported_alive_total),
             th({-colspan=>1}, $sum_reported_dead_male),
             th({-rowspan=>1}, $sum_reported_dead_female),
             th({-colspan=>1}, $sum_reported_dead_total),
             th({-colspan=>1}, $sum_reduced),
             th({-colspan=>1}, $sum_weaned_male),
             th({-colspan=>1}, $sum_weaned_female),
             th({-colspan=>1}, $sum_weaned_total)
           )
           . end_table();


  $page .= h2("Calculated from above numbers");

  $page .= start_table( {-border=>1, -summary=>"table"})
           . Tr(
               th("% males"),
               th("weaned males / weaned total"),
               td($sum_weaned_male . "/" . $sum_weaned_total . "*100"),
               td((($sum_weaned_total == 0 || !defined($sum_weaned_total))
                   ?'n/a'
                   :round_number($sum_weaned_male/$sum_weaned_total*100, 1) . " %"
                  )
               )
             )
           . Tr(
               th("weaned (total) / mothers"),
               th("weaned total / mothers"),
               td($sum_weaned_total . "/" . $sum_mothers),
               td((($sum_mothers == 0 || !defined($sum_mothers))
                   ?'n/a'
                   :round_number($sum_weaned_total/$sum_mothers, 2)
                  )
               )
             )
           . Tr(
               th("preweaning mortality"),
               th("reported dead total / (weaned total + reduced + reported dead total)"),
               td($sum_reported_dead_total . "/ (" . $sum_weaned_total . "+" . $sum_reduced . "+" . $sum_reported_dead_total . ")"),
               td((($sum_weaned_total+$sum_reduced+$sum_reported_dead_total == 0)
                   ?'n/a'
                   :round_number($sum_reported_dead_total/($sum_weaned_total+$sum_reduced+$sum_reported_dead_total)*100, 1) . " %"
                  )
               )
             )
           . Tr(
               th("average litter size (weaned)" . br() . "(from reported litters)"),
               th("weaned total / litters reported"),
               td($sum_weaned_total . "/ " . $sum_non_zero_litters),
               td((($sum_non_zero_litters == 0 || !defined($sum_non_zero_litters))
                   ?'n/a'
                   :round_number($sum_weaned_total/$sum_non_zero_litters, 1)
                  )
               )
             )
           . Tr(
               th("average litter size (reported)" . br() . "(from reported litters)"),
               th("reported alive total / litters reported"),
               td($sum_reported_alive_total . "/ " . $sum_non_zero_litters),
               td((($sum_non_zero_litters == 0 || !defined($sum_non_zero_litters))
                   ?'n/a'
                   :round_number($sum_reported_alive_total/$sum_non_zero_litters, 1)
                  )
               )
             )
           . end_table();

  return $page;
}
# end of line_breeding_stats
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE056 line_breeding_genotype_stats                 breeding genotype statistics for a line
sub line_breeding_genotype_stats {                       my $sr_name = 'SR_VIE056';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $line              = param('line');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my ($litter, $mating, $old_parent_genotype);
  my @sql_parameters;
  my @litters;
  my @litter_links;
  my @matings;
  my @mating_links;
  my %pubs_by_parent_genotype;

  # check input: is line id given? is it a number?
  if (!param('line') || param('line') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid line id"));
     return $page;
  }

  # first table
  $page .= h2("Breeding genotype statistics for line " . get_line_name_by_id($global_var_href, $line))
           . hr();

  # 1. get total number of pups born from current line matings, grouped by combination of father and mother genotype
  $sql = qq(select count(distinct mouse_id)                               as pups_number,
                   ifnull(mice_genotypes(l2p_father.l2p_parent_id), "ND") as father_genotype,
                   ifnull(mice_genotypes(l2p_mother.l2p_parent_id), "ND") as mother_genotype
            from   matings
                   join litters                    on litter_mating_id = mating_id
                   join mice                       on  mouse_litter_id = litter_id
                   join litters2parents l2p_father on (l2p_father.l2p_litter_id = litter_id and l2p_father.l2p_parent_type = "father")
                   join litters2parents l2p_mother on (l2p_mother.l2p_litter_id = litter_id and l2p_mother.l2p_parent_type = "mother")
            where  mating_line = ?
            group  by father_genotype, mother_genotype
            order  by father_genotype, mother_genotype
         );

  @sql_parameters = ($line);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("No matings for this line available (no matings found)");
     return $page;
  }

  # store total number of pups per combination of father and mother genotype
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $pubs_by_parent_genotype{$row->{'father_genotype'} . $row->{'mother_genotype'}} = $row->{'pups_number'};
  }

  ##########################################################
  # 2. get number of pups born from current line matings, grouped by combination of father and mother genotype AND by pup genotype
  $sql = qq(select count(distinct mouse_id)                               as pups_number,
                   ifnull(mice_genotypes(mouse_id), "ND")                 as child_genotype,
                   count(distinct litter_id)                              as litter_number,
                   group_concat(distinct litter_id)                       as litters,
                   count(distinct litter_mating_id)                       as mating_number,
                   group_concat(distinct litter_mating_id)                as matings,
                   ifnull(mice_genotypes(l2p_father.l2p_parent_id), "ND") as father_genotype,
                   ifnull(mice_genotypes(l2p_mother.l2p_parent_id), "ND") as mother_genotype
            from   matings
                   join litters                    on litter_mating_id = mating_id
                   join mice                       on  mouse_litter_id = litter_id
                   join litters2parents l2p_father on (l2p_father.l2p_litter_id = litter_id and l2p_father.l2p_parent_type = "father")
                   join litters2parents l2p_mother on (l2p_mother.l2p_litter_id = litter_id and l2p_mother.l2p_parent_type = "mother")
            where  mating_line = ?
            group  by father_genotype, mother_genotype, child_genotype
            order  by father_genotype, mother_genotype, child_genotype
           );

  @sql_parameters = ($line);

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: tell and quit
  unless ($rows > 0) {
     $page .= p("No matings for this line available (no matings found)");
     return $page;
  }

  $page .= h3(qq(Number of pups grouped by their own genotype and their parent's genotype));

  # else show result table
  $page .= start_table( {-border=>1, -summary=>"table"})
           . Tr(
               th({-align=>'center'}, "genotype father"),
               th({-align=>'center'}, "genotype mother"),
               th({-align=>'center'}, "genotype pups"),
               th({-align=>'center'}, "# pups"),
               th({-align=>'center'}, "% of total"),
               th({-align=>'center'}, "# matings"),
               th({-align=>'center'}, "# litters"),
               th({-align=>'center'}, "matings"),
               th({-align=>'center'}, "litters")
             );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      # litter and mating ids come as group_concat, so split it
      @litters = split(",", $row->{'litters'});
      @matings = split(",", $row->{'matings'});

      # reset
      @litter_links = ();
      @mating_links = ();

      # concat litter ids as links to litter details page
      foreach $litter (sort @litters) {
         push(@litter_links, a({-href=>"$url?choice=litter_view&litter_id=" . $litter}, $litter));
      }

      # concat mating ids as links to mating details page
      foreach $mating (sort @matings) {
         push(@mating_links, a({-href=>"$url?choice=mating_view&mating_id=" . $mating}, $mating));
      }

      # show separator line if next parents genotype combination occurs
      if ($old_parent_genotype ne ($row->{'father_genotype'} . $row->{'mother_genotype'})) {
      $page .= Tr({-align=>'left', -bgcolor=>"lightblue"},
                 td({-colspan=>3}, b("mating type: " . $row->{'father_genotype'} . " x " . $row->{'mother_genotype'}
                                   )
                 ),
                 td({-colspan=>6}, b($pubs_by_parent_genotype{$row->{'father_genotype'} . $row->{'mother_genotype'}} . " total"
                                   )
                 )
               );
      }

      # add table row for current cohort
      $page .= Tr({-align=>'center'},
                  td($row->{'father_genotype'}),
                  td($row->{'mother_genotype'}),
                  td($row->{'child_genotype'}),
                  td({-align=>'right'}, $row->{'pups_number'}),
                  td({-align=>'right'}, round_number($row->{'pups_number'}/ $pubs_by_parent_genotype{$row->{'father_genotype'} . $row->{'mother_genotype'}}*100, 1) . " %"),
                  td({-align=>'right'}, $row->{'mating_number'}),
                  td({-align=>'right'}, $row->{'litter_number'}),
                  td(join(", ", @mating_links)),
                  td(join(", ", @litter_links))
               );

      $old_parent_genotype = $row->{'father_genotype'} . $row->{'mother_genotype'};
  }

  $page .= end_table()
           . p("ND: no genotype information available");

  return $page;
}
# end of line_breeding_genotype_stats
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_VIE057 display_images                               display_images available for a mouse
sub display_images {                                     my $sr_name = 'SR_VIE057';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $mouse_id          = param('mouse_id');
  my $url               = url();
  my ($page);

  # check input: is mouse id given? is it a number?
  if (!param('mouse_id') || param('mouse_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please provide a valid mouse id"));
     return $page;
  }

  # first table
  $page .= h2("Available images for mouse " . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id"}, $mouse_id))
           . hr()
           . get_olympus_images($global_var_href, $mouse_id);

  return $page;
}
# end of display_images
#--------------------------------------------------------------------------------------

# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;

