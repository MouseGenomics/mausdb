# lib_update.pl - a MausDB subroutine library file                                                                               #
#                                                                                                                                #
# Subroutines in this file provide update functions                                                                              #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_UPD001 edit_mouse_details():                        allow to edit mouse details                                             #
# SR_UPD002 append_comment():                            append a common comment to a set of mice                                #
# SR_UPD003 db_append_comment():                         database transaction: append a common comment to a set of mice          #
# SR_UPD004 delete_comments():                           delete comments for a set of mice                                       #
# SR_UPD005 db_delete_comments():                        database transaction: delete comments from a set of mice                #
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
# SR_UPD001 edit_mouse_details():                        allow to edit mouse details
sub edit_mouse_details {                                 my $sr_name = 'SR_UPD001';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $url               = url();
  my $mouse_id          = param('mouse_id');
  my $mouse_comment     = param('mouse_comment');
  my $mouse_earmark     = param('mouse_earmark');
  my $mouse_sex         = param('mouse_sex');
  my $mouse_patho_id    = param('mouse_patho_id');
  my $mouse_color       = param('mouse_color');
  my $session           = $global_var_href->{'session'};    # session handle
  my $user_id           = $session->param('user_id');
  my $datetime_now      = get_current_datetime_for_sql();
  my $mouse_comment_sql;
  my ($page, $sql, $result, $rows, $row, $i, $rc);
  my ($gene_info, $project_info);
  my ($current_mating);
  my $sex_color   = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my @parameters = param();                               # read all CGI parameter keys
  my $parameter;
  my $message = '';
  my $patho_message = '';
  my ($new_property_id, $old_patho_id, $old_property_id);
  my ($males_in_cage, $females_in_cage, $current_cage);
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;

  # check input first: a mouse id must be provided and it has to be an 8 digit number: exit on failure
  if (!param('mouse_id') || param('mouse_id') !~ /^[0-9]{8}$/) {
     &error_message_and_exit($global_var_href, "invalid mouse id (must be an 8 digit number).", $sr_name . "-" . __LINE__);
  }

  # check if there already is a pathoID for this mouse
  ($old_patho_id, $old_property_id) = $dbh->selectrow_array("select property_value_text, property_id
                                                             from   properties left
                                                                    join mice2properties on property_id = m2pr_property_id
                                                             where  m2pr_mouse_id = $mouse_id
                                                                    and property_category = 'mouse'
                                                                    and property_key = 'pathoID'
                                                            ");

  $page = h2("Edit mouse details")
          . hr();

  #############################################################################################################
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

     $message = p('mouse comment successfully updated');

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdate_mouse_comment\t$mouse_id\tnew:$mouse_comment_sql");
  }
  #############################################################################################################

  #############################################################################################################
  # update earmark if requested
  if (defined(param('job')) && param('job') eq "update earmark") {

     if ($mouse_earmark =~ /^[0-9]+$/) {       # accept numbers only
        # update mouse earmark
        $dbh->do("update  mice
                  set     mouse_earmark = ?
                  where   mouse_id = ?
                 ", undef, $mouse_earmark, $mouse_id
                ) or &error_message_and_exit($global_var_href, "SQL error (could not update mouse earmark)", $sr_name . "-" . __LINE__);

        $message = p('mouse earmark successfully updated');

        # get current cage
        $current_cage = get_cage($global_var_href, $mouse_id);

        # check if earmark change leads to double earmark in cage
        if ($current_cage > 0 && double_earmarks_in_cage($global_var_href, $current_cage) eq 'yes') {
           $message .= p({-class=>'red'}, 'warning: there are multiple identical earmarks in cage '
                                          . a({-href=>"$url?choice=cage_view&cage_id=$current_cage"}, $current_cage)
                                          . '. Please check.'
                       );
        }

        &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdated_earmark\t$mouse_id\told_earmark=" . param('old_earmark') . "\tnew_earmark=$mouse_earmark");
     }
     else {
        $message = p('could not update earmark (only numbers allowed!)');

        &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdated_earmark\t$mouse_id\told_earmark=" . param('old_earmark') . "\tnew_earmark=" . param('old_earmark'). "\tfailed");
     }
  }
  #############################################################################################################

  #############################################################################################################
  # update color if requested
  if (defined(param('job')) && param('job') eq "update color") {

     # update mouse color
     $dbh->do("update  mice
               set     mouse_coat_color = ?
               where   mouse_id = ?
              ", undef, $mouse_color, $mouse_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not update mouse color)", $sr_name . "-" . __LINE__);

     $message = p('mouse color successfully updated');

     &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdate_mouse_color\t$mouse_id\tnew:$mouse_color");
  }
  #############################################################################################################

  #############################################################################################################
  # update sex if requested
  if (defined(param('job')) && param('job') eq "update sex") {

     if ($mouse_sex eq 'm' || $mouse_sex eq 'f') {
        # update mouse sex
        $dbh->do("update  mice
                  set     mouse_sex = ?
                  where   mouse_id = ?
                 ", undef, $mouse_sex, $mouse_id
                ) or &error_message_and_exit($global_var_href, "SQL error (could not update mouse sex)", $sr_name . "-" . __LINE__);

        $message = p('mouse sex successfully updated');

        # get current cage
        $current_cage = get_cage($global_var_href, $mouse_id);

        if ($current_cage < 0) {   # mouse dead
           # do nothing if mouse is dead (we don't have to be afraid of unintentional matings)
        }
        else {                     # mouse alive
           # place warning in case sex change can cause trouble
           (undef, $males_in_cage, $females_in_cage, undef, undef, undef, undef) = &get_mice_in_cage($global_var_href, $current_cage);

           if ( ($mouse_sex eq 'm' && $females_in_cage > 0) || ($mouse_sex eq 'f' && $males_in_cage > 0) ) {
              $message .= p({-class=>'red'}, 'warning: change of sex may lead to mating situations (mixed cage). Please check cage '
                                             . a({-href=>"$url?choice=cage_view&cage_id=$current_cage"}, $current_cage)
                          );
           }
        }

        &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdated_mouse_sex\t$mouse_id\told_sex=" . param('old_sex') . "\tnew_sex=$mouse_sex");
     }
     else {
        $message = p(qq(could not update sex (only 'm' or 'f' allowed!)));

        &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tupdated_mouse_sex\t$mouse_id\told_sex=" . param('old_sex') . "\tnew_sex=" . param('old_sex') . "\tfailed");
     }
  }
  #############################################################################################################

  #############################################################################################################
  # set pathoID if requested
  if (defined(param('job')) && param('job') eq "insert or update pathoID") {

     # is it a valid patho ID?
     if ($mouse_patho_id =~ /^[0-9]+\/[0-9]+$/) {         # something like 1234/2005

        # try to get a lock
        &get_semaphore_lock($global_var_href, $user_id);

        ############################################################################################
        # begin transaction
        $rc  = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start transaction)", $sr_name . "-" . __LINE__);

        # there already is a pathoID for this mouse: just update
        if (defined($old_patho_id)) {
           # update pathoID
           $sql = qq(update properties
                     set    property_value_text = ?
                     where  property_id = $old_property_id
                  );

           $dbh->do($sql, undef,
                    $mouse_patho_id, $old_property_id
                   ) or &error_message_and_exit($global_var_href, "SQL error (could not update pathoID)", $sr_name . "-" . __LINE__);

           $patho_message = p("updated pathoID (old: $old_patho_id; new: $mouse_patho_id)");
        }
        else {
           # get new property id for insert
           ($new_property_id) = $dbh->selectrow_array("select (max(property_id) + 1) as new_property_id
                                                       from   properties
                                                      ");
           if (!defined($new_property_id)) {
              $new_property_id = 1;
           }

           # insert pathoID into properties
           $sql = qq(insert
                     into   properties (property_id, property_category, property_key, property_type, property_value_text)
                     values (?, ?, ?, ?, ?)
                    );

           $dbh->do($sql, undef,
                    $new_property_id, 'mouse', 'pathoID', 'text', $mouse_patho_id
                   ) or &error_message_and_exit($global_var_href, "SQL error (could not insert pathoID)", $sr_name . "-" . __LINE__);

           # insert pathoID into properties
           $sql = qq(insert
                     into   mice2properties (m2pr_mouse_id, m2pr_property_id, m2pr_datetime, m2pr_user)
                     values (?, ?, ?, ?)
                    );

           $dbh->do($sql, undef,
                    $mouse_id, $new_property_id, $datetime_now, $user_id
                   ) or &error_message_and_exit($global_var_href, "SQL error (could not insert pathoID)", $sr_name . "-" . __LINE__);

           $patho_message = p("inserted pathoID ($mouse_patho_id)");
        }

        # pathoID inserted, so commit
        $rc  = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);

        # end transaction
        ############################################################################################

        # release lock
        &release_semaphore_lock($global_var_href, $user_id);

        $message = $patho_message;

        &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tinsert_or_update_patho_ID\t$mouse_id\tpatho_ID=$mouse_patho_id");
     }
     else {
        $message = p(qq(could not insert pathoID (wrong format)));

        &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tinsert_or_update_patho_ID\t$mouse_id\tpatho_ID=$mouse_patho_id\tfailed(wrong_format)");
     }
  }
  #############################################################################################################

  # query mouse details
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_id, line_name, mouse_comment, mouse_is_gvo,
                   mouse_origin_type, mouse_import_id, mouse_litter_id, coat_color_id, coat_color_name, litter_mating_id,
                   litter_id, litter_in_mating, mouse_birth_datetime, mouse_deathorexport_datetime, location_room,
                   location_rack, cage_id, dr1.death_reason_name as how, dr2.death_reason_name as why
            from   mice
                   join mouse_strains         on             mouse_strain = strain_id
                   join mouse_lines           on               mouse_line = line_id
                   join mouse_coat_colors     on         mouse_coat_color = coat_color_id
                   join mice2cages            on                 mouse_id = m2c_mouse_id
                   join cages2locations       on              m2c_cage_id = c2l_cage_id
                   join locations             on              location_id = c2l_location_id
                   join cages                 on                  cage_id = c2l_cage_id
                   join death_reasons dr1     on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2     on  mouse_deathorexport_why = dr2.death_reason_id
                   left join litters          on          mouse_litter_id = litter_id
            where  mouse_id = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # exit if requested mouse not found in database
  unless ($rows > 0) {
     $page .= p("No mouse found having id $mouse_id.");
     return $page;
  }

  # (else continue...)

  # get first (and only) result line
  $row = $result->[0];

  $page .= h3("Details for mouse "   . a({-href=>"$url?choice=mouse_details&mouse_id="      . $mouse_id}, $mouse_id)
             . "&nbsp;&nbsp;&nbsp;[" . a({-href=>"$url?choice=edit_mouse_details&mouse_id=" . ($mouse_id - 1)}, 'previous')
             . "&nbsp;"              . a({-href=>"$url?choice=edit_mouse_details&mouse_id=" . ($mouse_id + 1)}, 'next')
             . "]"
           )
           . $message
           . start_form(-action=>url(), -name=>"myform")
           . hidden('mouse_id')
           . hidden(-name=>'choice',      -value=>'edit_mouse_details')          # after pressing update button, we want to see form again
           . hidden(-name=>'old_sex',     -value=>$row->{'mouse_sex'},     -override=>1)
           . hidden(-name=>'old_earmark', -value=>$row->{'mouse_earmark'}, -override=>1)
           . start_table( {-border=>1, -summary=>"table", -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"});

  # get first genotype
  ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

  # add table row for current mouse
  $page .= Tr( th("mouse ID"),
               td(b($mouse_id))
           ) .
           Tr( th("ear"            ),
               td(b("current: ") . $row->{'mouse_earmark'} . b(",  new: ") . textfield(-name=>"mouse_earmark", -size=>"3", -value=>$row->{'mouse_earmark'})
               ),
               td(submit(-name => "job", -value=>"update earmark"))
           ) .
           Tr( th("sex"            ),
               td(b("current: ") . $row->{'mouse_sex'} . b(",  new: ") . radio_group(-name=>'mouse_sex', -values=>['m', 'f'], -default=>$row->{'mouse_sex'})
               ),
               td(submit(-name => "job", -value=>"update sex"))
           ) .
           Tr( th("color"            ),
               td(b("current: ") . $row->{'coat_color_name'} . b(",  new: ") . get_colors_popup_menu($global_var_href, $row->{'coat_color_id'}, 'mouse_color')
               ),
               td(submit(-name => "job", -value=>"update color"))
           ) .
           Tr( th("born"           ),
               td(format_datetime2simpledate($row->{'mouse_birth_datetime'}))
           ) .
           Tr( th("age"            ),
               td(get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'}))
           ) .
           Tr( th("death"          ),
               td({-title=>"$row->{'how'}, $row->{'why'}"}, format_datetime2simpledate($row->{'mouse_deathorexport_datetime'}))
           ) .
           Tr( th("genotype"       ),
               td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:'')
           ) .
           Tr( th("strain"         ),
               td($row->{'strain_name'})
           ) .
           Tr( th("line"           ),
               td('&nbsp;' . a({-href=>"$url?choice=line_view&line_id=$row->{'line_id'}", -title=>"click for line details", -target=>'_blank'}, $row->{'line_name'}) . '&nbsp;')
           ) .
           Tr( th("is GVO"         ),
               td('&nbsp;' . $row->{'mouse_is_gvo'} . '&nbsp;')
           ) .
           Tr( th("room/rack-cage" ),
               td((!defined($row->{'mouse_deathorexport_datetime'}))                                                             # check if mouse is alive
                  ?a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"},               # yes: print cage link
                     $row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'})
                  :'-'                                                                                                           # no: don't print cage link
                )
            ) .
            Tr( th(b("comments")),
                td({-colspan=>2},
                   textarea(-name=>"mouse_comment", -columns=>"50", -rows=>"5",
                                             -value=>($row->{'mouse_comment'} ne '')?$row->{'mouse_comment'}:'no comments for this mouse'
                   )
                   . br()
                   . submit(-name => "job", -value=>"update comment")
                )
            ) .
            Tr( th(b("pathoID")),
                td({-colspan=>2},
                   textfield(-name=>"mouse_patho_id", -size=>"10", -value=>(defined($old_patho_id)?$old_patho_id:''))
                   . "&nbsp;&nbsp;"
                   . submit(-name => "job", -value=>"insert or update pathoID")
                   . "&nbsp;&nbsp;"
                   . "(something like 06/123)"
                )
            )
            ;

  $page .= end_table()
           . hr({-align=>'left', -width=>'50%'})

           . p(a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse_id}, "back to mouse details"));

  $page .= end_form();

  return $page;
}
# end of edit_mouse_details()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_UPD002 append_comment():                            append a common comment to a set of mice
sub append_comment {                                     my $sr_name = 'SR_UPD002';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $i, $row);
  my ($mouse_id, $sql_mouse_list, $short_comment, $current_mating);
  my @sql_id_list;
  my @sql_parameters;
  my $sex_color    = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # mice selected at all?
  if (scalar @selected_mice == 0) {
     $page = h2("Append a comment to a set of mice")
            . hr()
            . p('No mice selected, please go back.');

     return $page;
  }

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse_id (@selected_mice) {
     if ($mouse_id =~ /^[0-9]{8}$/) {
        push(@sql_id_list, $mouse_id);
     }
  }

  # make the list non-redundant
  @sql_id_list = unique_list(@sql_id_list);
  $sql_mouse_list = qq(') . join(qq(','), @sql_id_list) . qq(');

  $page = h2("Append a comment to a set of mice")
          . hr()
          . start_form(-action=>url(), -name=>"myform")
          . hidden('mouse_select') ;

  # collect some details about selected mice
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment
            from   mice
                   join mouse_strains on mouse_strain = strain_id
                   join mouse_lines   on   mouse_line = line_id
            where  mouse_id in ($sql_mouse_list)
            order  by mouse_id asc
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sql . $sr_name . "-" . __LINE__ );

  # if selected mice cannot be found in database (should not happen): tell user and exit
  unless ($rows > 0) {
     $page .= p("Selected mice not found in the database. This is a strange situation that should not happen.")
              . p("Please tell an administrator");
     return $page;
  }

  $page .= h3(" $rows " . (($rows == 1)?'mouse':'mice' ) . ' selected')
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th("mouse ID"),
               th("ear"),
               th("sex"),
               th("strain"),
               th("line"),
               th("comment (shortened)")
             );

  # loop over all selected mice
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      # check if mouse is currently in mating
      $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

      # shorten comment to fit on page
      if (defined($row->{'mouse_comment'}) && $row->{'mouse_comment'} =~ /(^.{20})/) {
         $short_comment = $1 . ' [...]';
      }
      elsif (!defined($row->{'mouse_comment'})) {
         $short_comment = '';
      }
      else {
         $short_comment = $row->{'mouse_comment'};
      }

      $short_comment =~ s/^'(.*)'$/$1/g;

      # add table row for current mouse
      $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                  td($i+1),
                  td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                  td($row->{'mouse_earmark'}),
                  td($row->{'mouse_sex'}),
                  td($row->{'strain_name'}),
                  td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                  td({-align=>'left'},
                     ((defined($current_mating))
                      ?"(in mating " . a({-href=>"$url?choice=mating_view&mating_id=$current_mating"}, $current_mating) . ")"
                      :''
                     )
                     . $short_comment
                  )
               );
  }

  $page .= end_table()
           . p();


  $page .= h3('Please enter a comment to be appended at the comment of every mouse above')
           . textarea(-name=>"mouse_comment", -columns=>"50", -rows=>"5", -value=>'')
           . br()
           . p('Prepend instead of append ' . checkbox(-name=>'prepend',-checked=>'0', -label=>''))
           . submit(-name => "choice", -value=>"append comment!")
           . end_form();

  return $page;
}
# end of append_comment()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_UPD003 db_append_comment():                         database transaction: append a common comment to a set of mice
sub db_append_comment {                                  my $sr_name = 'SR_UPD003';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $session           = $global_var_href->{'session'}; # session handle
  my $user_id           = $session->param('user_id');
  my ($page, $sql, $result, $rows, $i, $row, $rc);
  my ($mouse_id, $sql_mouse_list, $short_comment, $current_mating);
  my @sql_id_list;
  my @sql_parameters;
  my $sex_color    = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my $datetime_now = get_current_datetime_for_sql();

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # mice selected at all?
  if (scalar @selected_mice == 0) {
     $page = h2("Append a comment to a set of mice")
            . hr()
            . p('No mice selected, please go back.');

     return $page;
  }

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse_id (@selected_mice) {
     if ($mouse_id =~ /^[0-9]{8}$/) {
        push(@sql_id_list, $mouse_id);
     }
  }

  # make the list non-redundant
  @sql_id_list = unique_list(@sql_id_list);
  $sql_mouse_list = qq(') . join(qq(','), @sql_id_list) . qq(');

  $page = h2("Append a comment to a set of mice")
          . hr();

  ############################################################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start comment append transaction)", $sr_name . "-" . __LINE__);

  # append or prepend common comment to all selected mice
  if (defined(param('prepend')) && param('prepend') eq 'on') {
     $dbh->do("update mice
               set    mouse_comment = concat(?, ?, mouse_comment)
               where  mouse_id in ($sql_mouse_list)
              ", undef, param('mouse_comment'), ''
             ) or &error_message_and_exit($global_var_href, "SQL error (could not append comment)",    $sr_name . "-" . __LINE__);
  }
  else {
     $dbh->do("update mice
               set    mouse_comment = concat(mouse_comment, ?, ?)
               where  mouse_id in ($sql_mouse_list)
              ", undef, '', param('mouse_comment')
             ) or &error_message_and_exit($global_var_href, "SQL error (could not append comment)",    $sr_name . "-" . __LINE__);
  }

  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);
  # end transaction
  ############################################################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tappend_comment\t" . join(',', @sql_id_list));

  $page .= p('Comment successfully added to all selected mice');


  # collect some details about selected mice
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment
            from   mice
                   join mouse_strains on mouse_strain = strain_id
                   join mouse_lines   on   mouse_line = line_id
            where  mouse_id in ($sql_mouse_list)
            order  by mouse_id asc
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sql . $sr_name . "-" . __LINE__ );

  # if selected mice cannot be found in database (should not happen): tell user and exit
  unless ($rows > 0) {
     $page .= p("Selected mice not found in the database. This is a strange situation that should not happen.")
              . p("Please tell an administrator");
     return $page;
  }

  $page .= h3(" $rows " . (($rows == 1)?'mouse':'mice' ) . ' selected')
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th("mouse ID"),
               th("ear"),
               th("sex"),
               th("strain"),
               th("line"),
               th("comment (shortened)")
             );

  # loop over all selected mice
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      # check if mouse is currently in mating
      $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

      # shorten comment to fit on page
      if (defined($row->{'mouse_comment'}) && $row->{'mouse_comment'} =~ /(^.{20})/) {
         $short_comment = $1 . ' [...]';
      }
      elsif (!defined($row->{'mouse_comment'})) {
         $short_comment = '';
      }
      else {
         $short_comment = $row->{'mouse_comment'};
      }

      $short_comment =~ s/^'(.*)'$/$1/g;

      # add table row for current mouse
      $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                  td($i+1),
                  td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                  td($row->{'mouse_earmark'}),
                  td($row->{'mouse_sex'}),
                  td($row->{'strain_name'}),
                  td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                  td({-align=>'left'},
                     ((defined($current_mating))
                      ?"(in mating " . a({-href=>"$url?choice=mating_view&mating_id=$current_mating"}, $current_mating) . ")"
                      :''
                     )
                     . $short_comment
                  )
               );
  }

  $page .= end_table()
           . p();

  return $page;
}
# end of db_append_comment()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_UPD004 delete_comments():                           delete comments for a set of mice
sub delete_comments {                                    my $sr_name = 'SR_UPD004';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $i, $row);
  my ($mouse_id, $sql_mouse_list, $short_comment, $current_mating);
  my @sql_id_list;
  my @sql_parameters;
  my $sex_color    = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # mice selected at all?
  if (scalar @selected_mice == 0) {
     $page = h2("Delete comments from a set of mice")
            . hr()
            . p('No mice selected, please go back.');

     return $page;
  }

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse_id (@selected_mice) {
     if ($mouse_id =~ /^[0-9]{8}$/) {
        push(@sql_id_list, $mouse_id);
     }
  }

  # make the list non-redundant
  @sql_id_list = unique_list(@sql_id_list);
  $sql_mouse_list = qq(') . join(qq(','), @sql_id_list) . qq(');

  $page = h2("Delete comments from a set of mice")
          . hr()
          . start_form(-action=>url(), -name=>"myform")
          . hidden('mouse_select') ;

  # collect some details about selected mice
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment
            from   mice
                   join mouse_strains on mouse_strain = strain_id
                   join mouse_lines   on   mouse_line = line_id
            where  mouse_id in ($sql_mouse_list)
            order  by mouse_id asc
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sql . $sr_name . "-" . __LINE__ );

  # if selected mice cannot be found in database (should not happen): tell user and exit
  unless ($rows > 0) {
     $page .= p("Selected mice not found in the database. This is a strange situation that should not happen.")
              . p("Please tell an administrator");
     return $page;
  }

  $page .= h3(" $rows " . (($rows == 1)?'mouse':'mice' ) . ' selected')
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th("mouse ID"),
               th("ear"),
               th("sex"),
               th("strain"),
               th("line"),
               th("comment")
             );

  # loop over all selected mice
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      # check if mouse is currently in mating
      $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

      if (!defined($row->{'mouse_comment'})) {
         $short_comment = '';
      }
      else {
         $short_comment = $row->{'mouse_comment'};
      }

#       $short_comment =~ s/^'(.*)'$/$1/g;

      # add table row for current mouse
      $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                  td($i+1),
                  td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                  td($row->{'mouse_earmark'}),
                  td($row->{'mouse_sex'}),
                  td($row->{'strain_name'}),
                  td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                  td({-align=>'left'},
                     ((defined($current_mating))
                      ?"(in mating " . a({-href=>"$url?choice=mating_view&mating_id=$current_mating"}, $current_mating) . ")"
                      :''
                     )
                     . $short_comment
                  )
               );
  }

  $page .= end_table()
           . p();


  $page .= h3('Please confirm deletion of comments for these mice')
           . p('Yes, I want to delete all comments for these mice ' . checkbox(-name=>'confirm_delete',-checked=>'0', -label=>''))
           . submit(-name => "choice", -value=>"delete comments!")
           . end_form();

  return $page;
}
# end of delete_comments()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_UPD005 db_delete_comments():                        database transaction: delete comments from a set of mice
sub db_delete_comments {                                 my $sr_name = 'SR_UPD005';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $session           = $global_var_href->{'session'}; # session handle
  my $user_id           = $session->param('user_id');
  my ($page, $sql, $result, $rows, $i, $row, $rc);
  my ($mouse_id, $sql_mouse_list, $short_comment, $current_mating);
  my @sql_id_list;
  my @sql_parameters;
  my $sex_color    = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my $datetime_now = get_current_datetime_for_sql();

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # mice selected at all?
  if (scalar @selected_mice == 0) {
     $page = h2("Delete comments from a set of mice")
            . hr()
            . p('No mice selected, please go back.');

     return $page;
  }

  # append or prepend common comment to all selected mice
  unless (defined(param('confirm_delete')) && param('confirm_delete') eq 'on') {
     $page = h2("Delete comments from a set of mice")
            . hr()
            . p('Please go back and confirm deletion of comments.');

     return $page;
  }

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse_id (@selected_mice) {
     if ($mouse_id =~ /^[0-9]{8}$/) {
        push(@sql_id_list, $mouse_id);
     }
  }

  # make the list non-redundant
  @sql_id_list = unique_list(@sql_id_list);
  $sql_mouse_list = qq(') . join(qq(','), @sql_id_list) . qq(');

  $page = h2("Delete comments from a set of mice")
          . hr();

  ############################################################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start delete comments transaction)", $sr_name . "-" . __LINE__);

  # append or prepend common comment to all selected mice
  $dbh->do("update mice
            set    mouse_comment = ''
            where  mouse_id in ($sql_mouse_list)
           ", undef, param('mouse_comment'), ''
        ) or &error_message_and_exit($global_var_href, "SQL error (could not delete comments)",    $sr_name . "-" . __LINE__);

  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "SQL error (could not commit)", $sr_name . "-" . __LINE__);
  # end transaction
  ############################################################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $session->param('username') . "\tdelete_comments\t" . join(',', @sql_id_list));

  $page .= p('Comments successfully deleted from all selected mice');


  # collect some details about selected mice
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment
            from   mice
                   join mouse_strains on mouse_strain = strain_id
                   join mouse_lines   on   mouse_line = line_id
            where  mouse_id in ($sql_mouse_list)
            order  by mouse_id asc
           );

  @sql_parameters = ();

  # do the actual SQL query: $result is a reference on the result set (see do_query {} definition), $rows is the number of results
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sql . $sr_name . "-" . __LINE__ );

  # if selected mice cannot be found in database (should not happen): tell user and exit
  unless ($rows > 0) {
     $page .= p("Selected mice not found in the database. This is a strange situation that should not happen.")
              . p("Please tell an administrator");
     return $page;
  }

  $page .= h3(" $rows " . (($rows == 1)?'mouse':'mice' ) . ' selected')
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th("mouse ID"),
               th("ear"),
               th("sex"),
               th("strain"),
               th("line"),
               th("comment")
             );

  # loop over all selected mice
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      # check if mouse is currently in mating
      $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

      if (!defined($row->{'mouse_comment'})) {
         $short_comment = '';
      }
      else {
         $short_comment = $row->{'mouse_comment'};
      }

#       $short_comment =~ s/^'(.*)'$/$1/g;

      # add table row for current mouse
      $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                  td($i+1),
                  td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                  td($row->{'mouse_earmark'}),
                  td($row->{'mouse_sex'}),
                  td($row->{'strain_name'}),
                  td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                  td({-align=>'left'},
                     ((defined($current_mating))
                      ?"(in mating " . a({-href=>"$url?choice=mating_view&mating_id=$current_mating"}, $current_mating) . ")"
                      :''
                     )
                     . $short_comment
                  )
               );
  }

  $page .= end_table()
           . p();

  return $page;
}
# end of db_delete_comments()
#--------------------------------------------------------------------------------------


# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;