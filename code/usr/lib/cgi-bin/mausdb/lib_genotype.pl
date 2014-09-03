# lib_genotype.pl - a MausDB subroutine library file                                                                                  #
#                                                                                                                                     #
# Subroutines in this file provide some genotyping functions                                                                          #
#                                                                                                                                     #
#-------------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                                 #
#-------------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                     #
# SR_GEN001 genotype_1                                    genotype (step 1: form)                                                     #
# SR_GEN002 genotype_2                                    confirm genotype/phenotype information                                      #
# SR_GEN003 genotype_3                                    do genotyping and display results                                           #
# SR_GEN004 store_genotype_to_database                    do database transaction for this mouse and get result                       #
# SR_GEN005 colortype_1                                   colortype mice (step 1: form)                                               #
# SR_GEN006 colortype_2                                   confirm coat colors                                                         #
# SR_GEN007 colortype_3                                   assign coat colors and display results                                      #
# SR_GEN008 store_colortype_to_database                   do database transaction for this mouse and get result                       #
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

use strict;

#--------------------------------------------------------------------------------------
# SR_GEN001 genotype_1                                    genotype (step 1: form)
sub genotype_1 {                                          my $sr_name = 'SR_GEN001';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $sql, $result, $rows, $row, $i);
  my $url                  = url();
  my @mice_to_be_genotyped = ();
  my @values               = ();
  my ($popup, $mouse, $line);
  my @sql_parameters;

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_genotyped, $mouse);
     }
     # else ignore ...
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_to_be_genotyped == 0) {
     $page .= h2("Enter genotype information")
              . hr()
              . h3("No mice to genotype")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # get the possible values for genotype popup from "settings" table
  $sql = qq(select setting_value_text as genotype
            from   settings
            where  setting_category = ?
                   and setting_item = ?
                   order  by setting_key
           );

  @sql_parameters = ('menu', 'genotypes_for_popup');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # collect genotype values in @values
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      push(@values, $row->{'genotype'});
  }

  # get line of first mouse from list
  $line = get_line($global_var_href, $mice_to_be_genotyped[0]);

  @values = get_genotype_qualifiers_for_line($global_var_href, $line);

  # display genotyping form
  $page .= h2("Enter genotype/phenotype information: 1. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("1) Please choose the genetic marker to which genotype/phenotype information refers")
           . p("(defaults to genetic marker defined by mouse line)")

           # if there is at least one genetic marker assigned to this line, the returned pulldown menu will only contain these.
           # if no markers are assigned to the line, the pulldown menu will contain all markers
           . p("Genetic marker: " . get_genetic_markers_popup_menu_for_line($global_var_href, $line, undef) . " " . span(b("please check genetic marker!")))

           . p() . hr({-align=>"left", -width=>"50%"}) . p()
           . h3("2a) Either choose genotype/phenotype that applies for all mice ... ")
           . p("Genotype or phenotype for all mice "
               . popup_menu( -name    => "genotype_for_all",
                             -values  => ['ignore', @values],
                             -default => 'ignore'
                )
                . "&nbsp;&nbsp;&nbsp;" . "this will be used for all mice unless left on \"ignore\"!"
             )
           . p()
           . h3("2b) " . u("... or") . " enter genotype/phenotype information for mice listed below individually")
           . hidden(-name=>'mouse_select') . "\n"
           . start_table({-border=>1, -summary=>"table"})
           . Tr(
               th("mouse id"),
               th("ear"),
               th("sex"),
               th("cage"),
               th("genotype/phenotype")
             );

  # one table row for each mouse
  foreach $mouse (@mice_to_be_genotyped) {
     $page .= Tr({-align=>"center"},
                td($mouse),
                td(get_earmark($global_var_href, $mouse)),
                td(get_sex($global_var_href, $mouse)),
                td(reformat_number(get_cage($global_var_href, $mouse), 4)),
                td(popup_menu( -name    => "genotype_$mouse",
                               -values  => [@values],
                               -default => 'n/a'
                   )
                )
              );
  }

  $page .= end_table()
           . p()
           . submit(-name => "choice", -value=>"confirm genotypes")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel genotyping (go to previous page)"))
           . end_form();

  return $page;
}
# end of genotype_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_GEN002 genotype_2                                    confirm genotype/phenotype information
sub genotype_2 {                                          my $sr_name = 'SR_GEN002';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $mouse, $genotype);
  my $url                  = url();
  my @mice_to_be_genotyped = ();
  my @values               = ();
  my $genetic_marker       = param('genetic_marker');
  my $genotype_for_all     = param('genotype_for_all');
  my $errors               = 0;

  # check input: is gene id given? is it a number?
  if (!param('genetic_marker') || param('genetic_marker') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please select a valid marker"));
     return $page;
  }

  # TO DO: Behelfsloesung:entfernen, wenn jede Linie einen Locus zugewiesen hat
  if (param('genetic_marker') == 333 ) {
     $page = p({-class=>"red"}, b("Error: please select a genetic marker / locus!"));
     return $page;
  }

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_genotyped, $mouse);
     }
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_to_be_genotyped == 0) {
     $page .= h2("Enter genotype information: 2. step")
              . hr()
              . h3("No mice to genotype")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # display confirmation page
  $page .= h2("Enter genotype/phenotype information: 2. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("Please confirm")
           . hidden(-name=>'genetic_marker')
           . hidden(-name=>'mouse_select')
           . start_table({-border=>1, -summary=>"table"})
           . Tr(
               th("mouse id"),
               th("ear"),
               th("sex"),
               th("cage"),
               th("genetic marker"),
               th("genotype/phenotype")
             );

  # one table row for each mouse
  foreach $mouse (@mice_to_be_genotyped) {
     # select whether to use individual or common genotype/phenotype for this mouse
     if ($genotype_for_all eq 'ignore') {
        if (defined(param('genotype_' . $mouse))) {
           $genotype = param('genotype_' . $mouse);
        }
        else {  # how can this happen?
           $errors++;
           $genotype = span({-class=>"red"}, "error with genotype!");
        }
     }
     else {
        $genotype = $genotype_for_all;
     }

     $page .= Tr({-align=>"center"},
                td($mouse),
                td(get_earmark($global_var_href, $mouse)),
                td(get_sex($global_var_href, $mouse)),
                td(reformat_number(get_cage($global_var_href, $mouse), 4)),
                td(get_gene_name_by_id($global_var_href, $genetic_marker) . hidden(-name=>"genotype_$mouse", -value=>$genotype, -override=>1)),
                td($genotype)
              );
  }

  $page .= end_table()
           . p();

  # stop if there where errors
  if ($errors == 0) {
     $page .= submit(-name => "choice", -value=>"genotype!")
              . hr()
              . p(a({-href=>"javascript:back()"}, "cancel genotyping (go to previous page)"));
  }
  else {
     $page .= p({-class=>"red"}, "There were errors!")
              . hr()
              . p(a({-href=>"javascript:back()"}, "please go back and check input"));
  }

  $page .= end_form();

  return $page;
}
# end of genotype_2
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_GEN003 genotype_3                                    do genotyping and display results
sub genotype_3 {                                          my $sr_name = 'SR_GEN003';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $mouse);
  my $url                  = url();
  my @mice_to_be_genotyped = ();
  my @values               = ();
  my $genetic_marker       = param('genetic_marker');
  my $genotype_for_all     = param('genotype_for_all');
  my $errors               = 0;
  my ($genotype, $genotyping_remark, $error_code);

  # check input: is gene id given? is it a number?
  if (!param('genetic_marker') || param('genetic_marker') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please select a valid marker"));
     return $page;
  }

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_genotyped, $mouse);
     }
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_to_be_genotyped == 0) {
     $page .= h2("Enter genotype information: 3. step")
              . hr()
              . h3("No mice to genotype")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # display results from genotyping
  $page .= h2("Enter genotype/phenotype information: 3. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("Trying to enter/update genotype information")
           . hidden(-name=>'genetic_marker')
           . hidden(-name=>'mouse_select')
           . start_table({-border=>1, -summary=>"table"})
           . Tr(
               th("mouse id"),
               th("ear"),
               th("sex"),
               th("cage"),
               th("genetic marker"),
               th("genotype/phenotype"),
               th("genotyping remark")
             );

  # one table row for each mouse
  foreach $mouse (@mice_to_be_genotyped) {
     $genotype = param('genotype_' . $mouse);

     # do database transaction for this mouse and get result
     ($error_code, $genotyping_remark) = store_genotype_to_database($global_var_href, $mouse, $genetic_marker, $genotype, 'unspecified');

     $page .= Tr({-align=>"center"},
                td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse}, $mouse)),
                td(get_earmark($global_var_href, $mouse)),
                td(get_sex($global_var_href, $mouse)),
                td(reformat_number(get_cage($global_var_href, $mouse), 4)),
                td(get_gene_name_by_id($global_var_href, $genetic_marker)),
                td($genotype),
                td({-align=>"left"}, $genotyping_remark)
              );
  }

  $page .= end_table()
           . end_form()

           . p("Genotyping done. You may view genotyped mice " . a({-href=>"$url?choice=Search%20by%20mouse%20IDs&mouse_ids=" . join(',', @mice_to_be_genotyped)}, "here"));

  return $page;
}
# end of genotype_3
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_GEN004 store_genotype_to_database                    do database transaction for this mouse and get result
sub store_genotype_to_database {                          my $sr_name = 'SR_GEN004';
  my $global_var_href = $_[0];                            # get reference to global vars hash
  my $mouse_id        = $_[1];                            # mouse to genotype  (-> m2g_mouse_id)
  my $genetic_marker  = $_[2];                            # genetic marker     (-> m2g_gene_id )
  my $genotype        = $_[3];                            # genotype/phenotype (-> m2g_genotype)
  my $genotype_method = $_[4];                            # genotype method    (-> m2g_genotype_method)
  my $dbh             = $global_var_href->{'dbh'};        # DBI database handle
  my $session         = $global_var_href->{'session'};    # session handle
  my $user_id         = $session->param('user_id');
  my ($number_of_all_genotypes, $number_of_genotypes, $status);
  my ($rc, $sql);
  my $datetime_sql = get_current_datetime_for_sql();      # get current system time
  my $marker_name;

  # check mouse_id for formally being a MausDB ID
  if (!defined($mouse_id) || $mouse_id !~ /^[0-9]{8}$/) {
     return (1, "ignored (invalid mouse id)");
  }

  ############################################################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start genotyping transaction)", $sr_name . "-" . __LINE__);

  # is there already any genotype defined for current mouse?
  ($number_of_all_genotypes) = $dbh->selectrow_array("select  count(m2g_mouse_id) as number_of_genotypes
                                                      from    mice2genes
                                                      where   m2g_mouse_id = $mouse_id
                                                     ");

  # name of genetic marker (for log)
  ($marker_name) = $dbh->selectrow_array("select  gene_shortname
                                          from    genes
                                          where   gene_id = $genetic_marker
                                         ");

  # there is no genotype defined for this mouse yet
  if ($number_of_all_genotypes == 0) {
     $dbh->do("insert
               into   mice2genes (m2g_mouse_id, m2g_gene_id, m2g_gene_order, m2g_genotype_date, m2g_genotype, m2g_genotype_method)
               values (?, ?, ?, ?, ?, ?)
              ", undef, $mouse_id, $genetic_marker, 1, "$datetime_sql", $genotype, $dbh->quote($genotype_method)
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert genotype)", $sr_name . "-" . __LINE__);

     $status = "inserted genotype/phenotype";
  }
  # there already is at least one genotype specified for this mouse (but we don't know for which gene yet)
  else {
     # now find out: is there already any genotype defined for current mouse for exactly the gene we want to add in this transaction?
    ($number_of_genotypes) = $dbh->selectrow_array("select  count(m2g_mouse_id) as number_of_genotypes
                                                    from    mice2genes
                                                    where      m2g_mouse_id = $mouse_id
                                                            and m2g_gene_id = $genetic_marker
                                                   ");

    # nothing for this gene yet, so insert (use m2g_gene_order increased by 1)
    if ($number_of_genotypes == 0) {
       $dbh->do("insert
                 into   mice2genes (m2g_mouse_id, m2g_gene_id, m2g_gene_order, m2g_genotype_date, m2g_genotype, m2g_genotype_method)
                 values (?, ?, ?, ?, ?, ?)
                ", undef, $mouse_id, $genetic_marker, ($number_of_all_genotypes + 1), "$datetime_sql", $genotype, $dbh->quote($genotype_method)
               ) or &error_message_and_exit($global_var_href, "SQL error (could not insert genotype)", $sr_name . "-" . __LINE__);

       $status = "inserted genotype/phenotype (added to existing ones)";
    }
    # if there was exactly one genotype for this gene already, update information (and leave m2g_gene_order as it is)
    elsif ($number_of_genotypes == 1) {
       $dbh->do("update mice2genes
                 set    m2g_genotype_date = ?, m2g_genotype = ?, m2g_genotype_method = ?
                 where     m2g_mouse_id = ?
                        and m2g_gene_id = ?
                ", undef, "$datetime_sql", $genotype, $dbh->quote($genotype_method), $mouse_id, $genetic_marker
               ) or &error_message_and_exit($global_var_href, "SQL error (could not insert genotype)", $sr_name . "-" . __LINE__);

       $status = "updated genotype/phenotype";
    }
    # if there was more than one genotype for this gene already, do not update (since simultaneous update of two entries will result in primary key conflict)
    else {
       $status = span({-class=>'red'}, "error: cannot update more than one genotype entry. Please contact administrator. ");
    }
  }

  $rc = $dbh->commit or &error_message_and_exit($global_var_href, "SQL error (could not commit genotyping transaction)", $sr_name . "-" . __LINE__);

  # end of transaction
  ############################################################################################

  &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tgenotype_mouse\t$mouse_id\t$datetime_sql\t$marker_name\t$genotype");


  return (0, $status);
}
# end of store_genotype_to_database
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_GEN005 colortype_1                                   colortype mice (step 1: form)
sub colortype_1 {                                         my $sr_name = 'SR_GEN005';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $sql, $result, $rows, $row, $i);
  my $url                  = url();
  my @mice_to_be_colortyped = ();
  my @values               = ();
  my ($popup, $default_color, $mouse);
  my @sql_parameters;

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_colortyped, $mouse);
     }
     # else ignore ...
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_to_be_colortyped == 0) {
     $page .= h2("Assign coat colors")
              . hr()
              . h3("No mice to colortype")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # display colortyping form
  $page .= h2("Assign coat colors: 1. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("a) Either choose coat color for all mice ... ")
           . p("Coat color for all mice "
               . get_colors_popup_menu($global_var_href, 'ignore', 'coat_color_for_all', 'yes')

               . "&nbsp;&nbsp;&nbsp;" . "this will be used for all mice unless left on \"ignore\"!"
             )
           . p()
           . h3("b) " . u("... or") . " enter coat colors for mice listed below individually")
           . hidden(-name=>'mouse_select') . "\n"
           . start_table({-border=>1, -summary=>"table"})
           . Tr(
               th("mouse id"),
               th("ear"),
               th("sex"),
               th("cage"),
               th("coat color")
             );

  # one table row for each mouse
  foreach $mouse (@mice_to_be_colortyped) {
     $page .= Tr({-align=>"center"},
                td($mouse),
                td(get_earmark($global_var_href, $mouse)),
                td(get_sex($global_var_href, $mouse)),
                td(reformat_number(get_cage($global_var_href, $mouse), 4)),
                td(get_colors_popup_menu($global_var_href, 'n/a', "colortype_$mouse", undef))
              );
  }

  $page .= end_table()
           . p()
           . submit(-name => "choice", -value=>"confirm coat colors")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel colortyping (go to previous page)"))
           . end_form();

  return $page;
}
# end of colortype_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_GEN006 colortype_2                                   confirm coat colors
sub colortype_2 {                                         my $sr_name = 'SR_GEN006';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $mouse, $colortype);
  my $url                   = url();
  my @mice_to_be_colortyped = ();
  my @values                = ();
  my $coat_color_for_all    = param('coat_color_for_all');
  my $errors                = 0;

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_colortyped, $mouse);
     }
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_to_be_colortyped == 0) {
     $page .= h2("Assign coat colors: 2. step")
              . hr()
              . h3("No mice to colortype")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # display confirmation page
  $page .= h2("Assign coat colors: 2. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("Please confirm")
           . hidden(-name=>'mouse_select')
           . start_table({-border=>1, -summary=>"table"})
           . Tr(
               th("mouse id"),
               th("ear"),
               th("sex"),
               th("cage"),
               th("coat color")
             );

  # one table row for each mouse
  foreach $mouse (@mice_to_be_colortyped) {
     # select whether to use individual or common coat color for this mouse
     if ($coat_color_for_all == 0) {
        if (defined(param('colortype_' . $mouse))) {
           $colortype = param('colortype_' . $mouse);
        }
        else {  # how can this happen?
           $errors++;
           $colortype = span({-class=>"red"}, "error with coat color!");
        }
     }
     else {
        $colortype = $coat_color_for_all;
     }

     $page .= Tr({-align=>"center"},
                td($mouse),
                td(get_earmark($global_var_href, $mouse)),
                td(get_sex($global_var_href, $mouse)),
                td(reformat_number(get_cage($global_var_href, $mouse), 4)),
                td(get_color_name_by_id($global_var_href, $colortype)
                   . hidden(-name=>"colortype_$mouse", -value=>$colortype, -override=>1)
                )
              );
  }

  $page .= end_table()
           . p();

  # stop if there where errors
  if ($errors == 0) {
     $page .= submit(-name => "choice", -value=>"colortype!")
              . hr()
              . p(a({-href=>"javascript:back()"}, "cancel assigning coat colors (go to previous page)"));
  }
  else {
     $page .= p({-class=>"red"}, "There were errors!")
              . hr()
              . p(a({-href=>"javascript:back()"}, "please go back and check input"));
  }

  $page .= end_form();

  return $page;
}
# end of colortype_2
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_GEN007 colortype_3                                   assign coat colors and display results
sub colortype_3 {                                         my $sr_name = 'SR_GEN007';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $mouse);
  my $url                   = url();
  my @mice_to_be_colortyped = ();
  my @values                = ();
  my $errors               = 0;
  my ($colortype, $colortyping_remark, $error_code);

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_colortyped, $mouse);
     }
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_to_be_colortyped == 0) {
     $page .= h2("Assign coat colors: 3. step")
              . hr()
              . h3("No mice to colortype")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # display results from colortyping
  $page .= h2("Assign coat colors: 3. step")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("Trying to enter/update coat color information")
           . start_table({-border=>1, -summary=>"table"})
           . Tr(
               th("mouse id"),
               th("ear"),
               th("sex"),
               th("cage"),
               th("coat color"),
               th("colortyping remark")
             );

  # one table row for each mouse
  foreach $mouse (@mice_to_be_colortyped) {
     $colortype = param('colortype_' . $mouse);

     # do database transaction for this mouse and get result
     ($error_code, $colortyping_remark) = store_colortype_to_database($global_var_href, $mouse, $colortype);

     $page .= Tr({-align=>"center"},
                td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse}, $mouse)),
                td(get_earmark($global_var_href, $mouse)),
                td(get_sex($global_var_href, $mouse)),
                td(reformat_number(get_cage($global_var_href, $mouse), 4)),
                td($colortype),
                td({-align=>"left"}, $colortyping_remark)
              );
  }

  $page .= end_table()
           . end_form()

           . p("Coat color(s) assigned. You may view colortyped mice " . a({-href=>"$url?choice=Search%20by%20mouse%20IDs&mouse_ids=" . join(',', @mice_to_be_colortyped)}, "here"));

  return $page;
}
# end of colortype_3
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_GEN008 store_colortype_to_database                   do database transaction for this mouse and get result
sub store_colortype_to_database {                         my $sr_name = 'SR_GEN008';
  my $global_var_href = $_[0];                            # get reference to global vars hash
  my $mouse_id        = $_[1];                            # mouse to colortype (-> mice.mouse_id)
  my $colortype       = $_[2];                            # coat color         (-> mice.mouse_coat_color)
  my $dbh             = $global_var_href->{'dbh'};        # DBI database handle
  my $session         = $global_var_href->{'session'};    # session handle
  my $user_id         = $session->param('user_id');
  my ($status);
  my ($rc, $sql);
  my $datetime_sql = get_current_datetime_for_sql();      # get current system time

  # check mouse_id for formally being a MausDB ID
  if (!defined($mouse_id) || $mouse_id !~ /^[0-9]{8}$/) {
     return (1, "ignored (invalid mouse id)");
  }

  ############################################################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start colortyping transaction)", $sr_name . "-" . __LINE__);

  $dbh->do("update mice
            set    mouse_coat_color = ?
            where  mouse_id = ?
           ", undef, $colortype, $mouse_id
        ) or &error_message_and_exit($global_var_href, "SQL error (could not assign color)", $sr_name . "-" . __LINE__);

  $status = "updated coat color";

  $rc = $dbh->commit or &error_message_and_exit($global_var_href, "SQL error (could not commit colortyping transaction)", $sr_name . "-" . __LINE__);

  # end of transaction
  ############################################################################################

  &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tcolortype_mouse\t$mouse_id\t$datetime_sql\t" . get_color_name_by_id($global_var_href, $colortype));

  return (0, $status);
}
# end of store_colortype_to_database
#--------------------------------------------------------------------------------------



# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;