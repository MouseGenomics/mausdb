# lib_searching.pl - a MausDB subroutine library file                                                                            #
#                                                                                                                                #
# Subroutines in this file provide searching and finding functions                                                               #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_SEA001 find_mice_page():                            generates the initial search form                                       #
# SR_SEA002 find_mouse_by_line_and_sex                   find mice based on their line, sex and age                              #
# SR_SEA003 find_mice_by_id                              find mice by id                                                         #
# SR_SEA004 find_mice_by_patho_id                        find mice by patho id                                                   #
# SR_SEA005 find_mice_by_foreign_id                      find mice by foreign id                                                 #
# SR_SEA006 find_mice_by_cage                            find mice by cage id(s)                                                 #
# SR_SEA007 find_mouse_by_genotypes                      find mice based on their (multiple) genotypes                           #
# SR_SEA008 find_mice_by_comment                         find mice by comment                                                    #
# SR_SEA009 find_mice_by_mating_name:                    find_mice_by_mating_name                                                #
# SR_SEA010 find_mice_by_experiment:                     find mice by experiment                                                 #
# SR_SEA011 find_mice_by_date_of_death                   find mice by date of death                                              #
# SR_SEA012 find_orderlists_by_parameterset              find orderlists by parameterset                                         #
# SR_SEA013 find_cart_by_cart_name:                      find cart by cart name                                                  #
# SR_SEA014 find_mice_by_date_of_birth                   find mice by date of birth                                              #
# SR_SEA015 find_blob_by_keyword:                        find blobs by keyword                                                   #
# SR_VIE016 find_matings_by_project():                   find matings by project                                                 #
# SR_VIE017 find_matings_by_line():                      find matings by line                                                    #
# SR_SEA018 find_mice_by_strain:                         find mice by strain                                                     #
# SR_SEA019 find_line_by_keyword:                        find line by keyword                                                    #
# SR_SEA020 find_mice_by_room                            find mice by room                                                       #
# SR_SEA021 find_mice_by_area                            find mice by area                                                       #
# SR_SEA022 find_children_of_mouse                       find children of a given mouse                                          #
# SR_SEA023 find_mice_by_line_and_area                   find mice by line and area                                              #
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
# SR_SEA001 find_mice_page():                            generates the initial search form
sub find_mice_page {                                     my $sr_name = 'SR_SEA001';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url = url();
  my ($page);

  $page = h2("Search & find")

          . hr()

          . start_form({-action => url()})

          . h3("Browse ... ")

          . p(  a({-href=>"$url?choice=mating_overview",    -title=>"click here to get an overview over current (and past) matings"},    "browse matings")
              . " | "
              . a({-href=>"$url?choice=import_overview",    -title=>"click here to get an overview over imports"                   },    "browse imports")
              . " | "
              . a({-href=>"$url?choice=cohorts_overview",   -title=>"click here to get an overview over cohorts"                   },    "browse cohorts")
            )

          . hr({-width=>'50%', align=>'left'})

          . h3("Find mice ... " . "&nbsp;&nbsp; [Optional: " . checkbox('restrict_to_cart', '0', '1', '') . " restrict search to cart ]")

            . start_table({-border=>"0", -summary=>"table"})
            . Tr( {-valign=>'top'},
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... by mouse ID(s)")
                   . br()
                   . textarea(-name => "mouse_ids", -columns=>"20", -rows=>"2", -override=>"1", -title=>"example: 30000001,30000033, 30010043")
                   . br()
                   . submit(-name => "choice", -value=>"Search by mouse IDs")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... by cage ID(s)")
                   . br()
                   . textarea(-name => "cage_ids", -columns=>"20", -rows=>"2", -override=>"1", -title=>"example: 5, 13, 1231")
                   . br()
                   . submit(-name => "choice", -value=>"Search cage(s)")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... by date of birth")
                   . br()
                   . table( {-border=>0},
                        Tr(td({-align=>'right'}, 'Birth after: '),
                           td(textfield(-name => "birth_after", -size=>"11", -maxlength=>"11",  -value=>'01.01.2006', -title=>"example: 23.04.2005"))
                        ) .
                        Tr(td({-align=>'right'}, 'Birth before: '),
                           td(textfield(-name => "birth_before", -size=>"11", -maxlength=>"11", -value=>'01.02.2006',  -title=>"example: 23.04.2005"))
                        )
                     )
                   . br()
                   . submit(-name => "choice", -value=>"Search by date of birth")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... by date of death")
                   . br()
                   . table( {-border=>0},
                        Tr(td({-align=>'right'}, 'Death after: '),
                           td(textfield(-name => "death_after", -size=>"11", -maxlength=>"11",  -value=>'01.01.2006', -title=>"example: 23.04.2005"))
                        ) .
                        Tr(td({-align=>'right'}, 'Death before: '),
                           td(textfield(-name => "death_before", -size=>"11", -maxlength=>"11", -value=>'01.02.2006',  -title=>"example: 23.04.2005"))
                        )
                     )
                   . br()
                   . submit(-name => "choice", -value=>"Search by date of death")
                )
              )

              . Tr(td("&nbsp;&nbsp;"))

              . Tr(
                  td({-valign=>'top', -colspan=>3},
                      b({-style=>'background-color: silver; padding: 3px;'}, "... by line, sex, age and genotype")
                      . br()
                      . table( {-border=>0, -summary=>"table"},
                           Tr( th({-align=>"right"}, b('from line: ')),
                               td(get_lines_popup_menu($global_var_href, 1))
                           ),
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
                                             -default => "0",
                                             -labels => {"0"  => "no min age", "3" =>  "3 weeks",  "4" => "4 weeks",   "5" =>  "5 weeks",
                                                         "6"  =>  "6 weeks",   "7" =>  "7 weeks",  "8" => "8 weeks",   "9" =>  "9 weeks", "10" => "10 weeks",
                                                         "11" => "11 weeks",  "12" => "12 weeks", "13" => "13 weeks", "14" => "14 weeks", "15" => "15 weeks",
                                                         "16" => "16 weeks",  "20" => "20 weeks", "24" => "24 weeks", "28" => "28 weeks", "32" => "32 weeks",
                                                         "36" => "36 weeks",  "40" => "40 weeks", "44" => "44 weeks", "48" => "48 weeks", "56" => "56 weeks",
                                                         "64" => "64 weeks",  "72" => "72 weeks", "80" => "80 weeks", "88" => "88 weeks", "96" => "96 weeks"
                                                        }
                                            )
                                  . b(' to: ')
                                  . popup_menu(-name   => "max_age",
                                             -values => ["0", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16",
                                                         "20", "24", "28", "32", "36", "40", "44", "48", "56", "64", "72", "80", "88", "96"],
                                             -default => "1",
                                             -labels => {"0"=> "no max age", "3" =>  "3 weeks",  "4" => "4 weeks",   "5" =>  "5 weeks",
                                                         "6"  =>  "6 weeks",   "7" =>  "7 weeks",  "8" => "8 weeks",   "9" =>  "9 weeks", "10" => "10 weeks",
                                                         "11" => "11 weeks",  "12" => "12 weeks", "13" => "13 weeks", "14" => "14 weeks", "15" => "15 weeks",
                                                         "16" => "16 weeks",  "20" => "20 weeks", "24" => "24 weeks", "28" => "28 weeks", "32" => "32 weeks",
                                                         "36" => "36 weeks",  "40" => "40 weeks", "44" => "44 weeks", "48" => "48 weeks", "56" => "56 weeks",
                                                         "64" => "64 weeks",  "72" => "72 weeks", "80" => "80 weeks", "88" => "88 weeks", "96" => "96 weeks"
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
                      ),
                      td("&nbsp;&nbsp;"),
                      td({-valign=>'top', -colspan=>4},
                         b({-style=>'background-color: silver; padding: 3px;'}, "... by genotype ")
                         . br()
                         . table( {-border=>0, -summary=>"table"},
                             Tr(
                               td({-align=>"right"}, b('1. genotype: ')
                                 ),
                               td(checkbox('1_gene_select', '0', '1', '') . get_genetic_markers_popup_menu($global_var_href, undef, '1_gene_locus')
                                 ),
                               td(get_genotypes_popup_menu($global_var_href, '1_gene_genotype', 'any', 'any')
                                 )
                               ),
                             Tr(
                               td({-align=>"right"}, b('2. genotype: ')
                                 ),
                               td(checkbox('2_gene_select', '0', '1', '') . get_genetic_markers_popup_menu($global_var_href, undef, '2_gene_locus')
                                 ),
                               td(get_genotypes_popup_menu($global_var_href, '2_gene_genotype', 'any', 'any')
                                 )
                               ),
                             Tr(
                               td({-align=>"right"}, b('3. genotype: ')
                                 ),
                               td(checkbox('3_gene_select', '0', '1', '') . get_genetic_markers_popup_menu($global_var_href, undef, '3_gene_locus')
                                 ),
                               td(get_genotypes_popup_menu($global_var_href, '3_gene_genotype', 'any', 'any')
                                 )
                               )
                             # copy and paste last Tr() element from above and adapt number to 4,5,... in order to add additional search genotypes
                           )
                         . submit(-name => "choice", -value => "Search by genotype")
                      )
                )

            . Tr(td("&nbsp;&nbsp;"))

            . Tr( {-valign=>'top'},
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... by mouse comment")
                   . br()
                   . textfield(-name => "comment_fragment", -size=>"20", -maxlength=>"30", -title=>"example: my mouse")
                   . br()
                   . submit(-name => "choice", -value=>"Search by comment")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... by experiment")
                   . br()
                   . get_experiments_popup_menu($global_var_href, undef, 'experiment_id')
                   . br()
                   . submit(-name => "choice", -value=>"Search by experiment")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... by patho ID(s)")
                   . br()
                   . textarea(-name => "patho_id", -columns=>"20", -rows=>"2", -override=>"1", -title=>"example: 05/12")
                   . br()
                   . submit(-name => "choice", -value=>"Search by patho ID")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... by foreign ID")
                   . br()
                   . textfield(-name => "foreign_id", -size=>"20", -maxlength=>"20", -title=>"example: DLL1/12-0250")
                   . br()
                   . submit(-name => "choice", -value=>"Search by foreign ID")
                )
              )

            . Tr(td("&nbsp;&nbsp;"))

            . Tr( {-valign=>'top'},
                td({-colspan=>3},
                   b({-style=>'background-color: silver; padding: 3px;'}, "... by strain")
                   . br()
                   . table( {-border=>0, -summary=>"table"},
                           Tr( th({-align=>"right"}, b('strain: ')),
                               td(get_strains_popup_menu($global_var_href, 1))
                           ) .
                           Tr( td({-align=>"left"}, b('include dead: ')),
                               td({-align=>"left"}, checkbox('include_dead_strain', '0', '1', ''))
                           )
                        )
                   . submit(-name => "choice", -value=>"Search by strain")
                ),
                td("&nbsp;&nbsp;"),
                td({-colspan=>3},
                   b({-style=>'background-color: silver; padding: 3px;'}, "... by phenotyping values")
                   . br()
                   . get_parametersets_popup_menu($global_var_href, undef, "parameterset_id") . "&nbsp;" . "1. step: select parameterset"
                   . br()
                   . submit(-name => "choice", -value=>"Search by value")
                )
              )

            . Tr(td("&nbsp;&nbsp;"))

            . Tr( {-valign=>'top'},
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... by room")
                   . br()
                   . get_rooms_popup_menu($global_var_href)
                   . br()
                   . submit(-name => "choice", -value=>"Search by room")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... by area")
                   . br()
                   . get_area_popup_menu($global_var_href)
                   . br()
                   . submit(-name => "choice", -value=>"Search by area")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... by line+area")
                   . br()
                   . get_lines_popup_menu($global_var_href, 1, 'line_for_area')
                   . br()
                   . get_area_popup_menu($global_var_href, 'area_for_line')
                   . br()
                   . submit(-name => "choice", -value=>"Search by line and area")
                ),
                td("&nbsp;&nbsp;"),
              )

            . end_table()

            . p()

            . hr({-width=>'50%', align=>'left'})

            . h3("Find ...")

            . start_table({-border => "0", -summary=>"table"})

            . Tr( {-valign=>'top'},
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... mating by ID")
                   . br()
                   . textfield(-name => "mating_id", -size=>"9", -maxlength=>"8", -title=>"example: 123")
                   . br()
                   . submit(-name => "choice", -value=>"Search by mating ID")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... mating(s) by name")
                   . br()
                   . textfield(-name => "mating_name", -size=>"20", -maxlength=>"30", -title=>"enter (part of) mating name or comment")
                   . br()
                   . submit(-name => "choice", -value=>"Search by mating name")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... mating(s) by project")
                   . br()
                   . get_projects_popup_menu($global_var_href)
                   . br()
                   . submit(-name => "choice", -value=>"Search by mating project")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... matings by line")
                   . br()
                   . get_lines_popup_menu($global_var_href, 1, 'mating_line')
                   . br()
                   . submit(-name => "choice", -value=>"Search by mating line")
                )
              )

            . Tr(td("&nbsp;&nbsp;"))

            . Tr( {-valign=>'top'},
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... litter by ID")
                   . br()
                   . textfield(-name => "litter_id", -size=>"9", -maxlength=>"8", -title=>"example: 123")
                   . br()
                   . submit(-name => "choice", -value=>"Search by litter ID")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... import by ID")
                   . br()
                   . textfield(-name => "import_id", -size=>"9", -maxlength=>"8", -title=>"example: 123")
                   . br()
                   . submit(-name => "choice", -value=>"Search by import ID")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... embryo transfer by ID")
                   . br()
                   . textfield(-name => "transfer_id", -size=>"9", -maxlength=>"8", -title=>"example: 123")
                   . br()
                   . submit(-name => "choice", -value=>"Search by transfer ID")
                ),
                td("&nbsp;&nbsp;"),
                td("&nbsp;&nbsp;")
              )

            . Tr(td("&nbsp;&nbsp;"))

            . Tr( {-valign=>'top'},
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... orderlist by ID")
                   . br()
                   . textfield(-name => "orderlist_id", -size=>"8", -maxlength=>"20", -title=>"4352")
                   . br()
                   . submit(-name => "choice", -value=>"Search by orderlist ID")
                ),
                td("&nbsp;&nbsp;"),
                td({-colspan=>3},
                   b({-style=>'background-color: silver; padding: 3px;'}, "... orderlists by parameterset")
                   . br()
                   . get_parametersets_popup_menu($global_var_href) . '&nbsp;&nbsp;'
                   . popup_menu(-name    => "status",
                                -values  => ["done", "ordered", "cancelled"],
                                -labels  => {"done"       => "done",
                                             "ordered"    => "ordered",
                                             "cancelled"  => "cancelled"},
                                -default => "done"
                     )
                   . br()
                   . submit(-name => "choice", -value=>"Search orderlists by parameterset")
                ),
                td("&nbsp;&nbsp;"),
                td("&nbsp;&nbsp;")
              )

            . Tr(td("&nbsp;&nbsp;"))

            . Tr( {-valign=>'top'},
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... cart by cart name")
                   . br()
                   . textfield(-name => "cart_name", -size=>"20", -maxlength=>"20", -title=>"substring of cart name")
                   . br()
                   . submit(-name => "choice", -value=>"Search by cart name")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... file(s) by keyword")
                   . br()
                   . textfield(-name => "blob_keyword", -size=>"20", -maxlength=>"20", -title=>"keyword/substring of file comment or file name")
                   . br()
                   . submit(-name => "choice", -value=>"Search files by keyword")
                ),
                td("&nbsp;&nbsp;"),
                td(b({-style=>'background-color: silver; padding: 3px;'}, "... line(s) by keyword")
                   . br()
                   . textfield(-name => "line_keyword", -size=>"20", -maxlength=>"20", -title=>"keyword/substring of line name, comment or description")
                   . br()
                   . submit(-name => "choice", -value=>"Search lines by keyword")
                )
              )

            . Tr(td())

            . end_table()

          . end_form();

  return $page;
}
# end of find_mice_page()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA002 find_mouse_by_line_and_sex                   find mice based on their line, sex and age
sub find_mouse_by_line_and_sex {                         my $sr_name = 'SR_SEA002';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my ($page, $sql, $result, $rows, $row, $i);
  my ($line_name, $max_age_sql, $min_age_sql, $genotype_sql, $genotype_sql2, $include_dead_sql);
  my $line_id      = param('line');
  my $sex          = param('sex');
  my $gtype        = param('gtype');
  my $sort_column  = param('sort_by');
  my $sort_order   = param('sort_order');
  my $start_row    = param('start_row');
  my $min_age      = param('min_age');
  my $max_age      = param('max_age');
  my $include_dead = param('include_dead');
  my $only_dead    = param('only_dead');
  my $show_rows    = $global_var_href->{'show_rows'};
  my $url          = url();
  my $rev_order    = {'asc' => 'desc', 'desc' => 'asc'};     # toggle table
  my $sex_color    = {'m' => $global_var_href->{'bg_color_male'},
                      'f' => $global_var_href->{'bg_color_female'}};
  my @parameters   = param();                                # read all CGI parameter keys
  my $parameter;
  my ($current_mating, $short_comment);
  my ($first_gene_name, $first_genotype);
  my ($cart_mice, $cart_mouse);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';

  # hide real database column names from user (security issue): use translation hash table
  # left (key): identifier used in HTML form; right (value): database column name
  my $columns  = {'id'  => 'mouse_id', 'earmark' => 'mouse_earmark', 'dob' => 'mouse_birth_datetime', 'genotype' => 'm2g_genotype',
                  'sex' => 'mouse_sex', 'strain' => 'strain_name',  'line' => 'line_name',            'location' => 'cage_name',
                  'dod' => 'mouse_deathorexport_datetime',          'cage' => 'cage_id',              'rack'     => 'concat(location_room,location_rack)'};
  my %sexes    = ("1" => "male or female", "2" => "male", "3" => "female");
  my %sex_sql  = ("1" => "and mouse_sex in ('m','f')", "2" => "and mouse_sex = 'm' ", "3" => "and mouse_sex = 'f' " );
  my $genotype = get_genotypes_as_hash($global_var_href);

  my @sql_parameters;

  # check if line id given
  if (!param('line') || param('line') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: Please choose a valid line."));
     return $page;
  }

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  # make sure a sort column is defined
  if (!param('sort_by')) {
     $sort_column = 'id';
  }
  # raise error if invalid sort column given
  elsif (!defined($columns->{$sort_column})) {
     $page = p({-class=>"red"}, b("Error: invalid sort column: \"$sort_column\""));
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

  # if min_age is given and it is a number: generate SQL condition
  if (param('min_age') && param('min_age') =~ /^[0-9]+$/) {
     $min_age_sql = qq(and mouse_birth_datetime <= ') . get_sql_time_by_given_current_age($min_age * 7) . qq(' );   # min_age is in weeks, so multiply by 7
  }
  else {          # otherwise skip age condition from SQL
     $min_age_sql = '';
  }

  # if max_age is given and it is a number: generate SQL condition
  if (param('max_age') && param('max_age') =~ /^[0-9]+$/) {
     $max_age_sql = qq(and mouse_birth_datetime >= ') . get_sql_time_by_given_current_age($max_age * 7) . qq(' );   # max_age is in weeks, so multiply by 7
  }
  else {          # otherwise skip age condition from SQL
     $max_age_sql = '';
  }

  # check if genotype is given
  if (!param('gtype')) {
     $genotype_sql = '';
  }
  elsif (!defined($genotype->{$gtype})) {
     $page = p({-class=>"red"}, b("Error: invalid sort column: $sort_column"));
     return $page;
  }
  elsif ($genotype->{param('gtype')} eq 'any') {
     $genotype_sql  = '';
     $genotype_sql2 = qq(left join mice2genes on mouse_id = m2g_mouse_id);
  }
  else {
     $genotype_sql  = qq(and m2g_genotype = '$genotype->{$gtype}' );
     $genotype_sql2 = qq(left join mice2genes on mouse_id = m2g_mouse_id);
  }

  # if "include dead" box checked: generate SQL condition
  if (param('include_dead') && param('include_dead') == 1) {
     $include_dead_sql = '';
  }
  else {
     $include_dead = 0;
     $include_dead_sql = qq(and mouse_deathorexport_datetime IS NULL);
  }

  # if "only dead" box checked: generate SQL condition
  if (param('only_dead') && param('only_dead') == 1) {
     $include_dead_sql = qq(and mouse_deathorexport_datetime IS NOT NULL);
  }

  # just get the line name by line id for display (users can't handle line_id)
  $sql = qq(select line_name
            from   mouse_lines
            where  line_id = ?
           );

  @sql_parameters = ($line_id);

  ($line_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  $page .= h3(qq(Your search by line: "$line_name", sex: "$sexes{$sex}", minimum age: "$min_age week(s)", maximum age: "$max_age week(s)"
                 and genotype: "$genotype->{$gtype}" ) . (($include_dead == 0)?'(living only)':'(include dead)')
             )
           . hr();

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href)
              . hr();
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add all mice to cart") {
     $page .= add_all_to_cart($global_var_href)
              . hr();
  }

  # delete the all_mice fields
  Delete('all_mice');

  # in order to sort by genotype, we need to join the mice2genes table (within $genotype_sql2)
  # doing so results in multiple lines for mice that have multiple genotypes. As the genotype itself is
  # not part of the select, distinct can be used
  $sql = qq(select distinct
                   mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
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
                   $genotype_sql2
            where  mouse_line = ?
                   $sex_sql{$sex}
                   $min_age_sql
                   $max_age_sql
                   $genotype_sql
                   $include_dead_sql
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
                   and mouse_origin_type in ('import', 'weaning', 'import_external', 'weaning_external')
                   $restrict_to_cart_sql
            order  by $columns->{$sort_column} $sort_order
           );

  @sql_parameters = ($line_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sql . br() . $sr_name . "-" . __LINE__ );

  # exit if no results for search
  unless ($rows > 0) {
     $page .= p("Nothing found for the above search criteria $restrict_to_cart_notice.");
     return $page;
  }

  $page .= p(b("Found $rows $sexes{$sex} " . (($rows == 1)?'mouse':'mice' ). " for line $line_name $restrict_to_cart_notice"))
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . '&start_row=1' . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[first]'):'[first]')
                 . "&nbsp;"
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . '&start_row=' . ($start_row - $show_rows) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[previous]'):'[previous]')
                 . "&nbsp;"
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . '&start_row=' . ($start_row + $show_rows) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[next]'):'[next]')
                 . "&nbsp; "
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . '&start_row=' . ($rows - $show_rows + 1) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[last]'):'[last]')
                )
              :''
             )
           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th(a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . "&sort_order=$rev_order->{$sort_order}&sort_by=id&restrict_to_cart=" . param('restrict_to_cart'),       -title=>"click to sort by mouse id, click again to change sort order"},       "mouse ID")      ),
               th(a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . "&sort_order=$rev_order->{$sort_order}&sort_by=earmark&restrict_to_cart=" . param('restrict_to_cart'),  -title=>"click to sort by earmark, click again to change sort order"},        "ear")           ),
               th(a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . "&sort_order=$rev_order->{$sort_order}&sort_by=sex&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by sex, click again to change sort order"},            "sex")           ),
               th(a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . "&sort_order=$rev_order->{$sort_order}&sort_by=dob&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by date of birth, click again to change sort order"},  "born")          ),
               th(span({-title=>"living mice: current age; dead mice: age at day of death"}, "age")),
               th(a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . "&sort_order=$rev_order->{$sort_order}&sort_by=dod&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by date of death, click again to change sort order"},  "death")         ),
               th(a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . "&sort_order=$rev_order->{$sort_order}&sort_by=genotype&restrict_to_cart=" . param('restrict_to_cart'), -title=>"click to sort by genotype, click again to change sort order"},       "genotype")      ),
               th(a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . "&sort_order=$rev_order->{$sort_order}&sort_by=strain&restrict_to_cart=" . param('restrict_to_cart'),   -title=>"click to sort by strain, click again to change sort order"},         "strain")        ),
               th(a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . "&sort_order=$rev_order->{$sort_order}&sort_by=line&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by line, click again to change sort order"},           "line")          ),
               th(a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . "&sort_order=$rev_order->{$sort_order}&sort_by=rack&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by rack, click again to change sort order"},           "room/rack")
                . ' / '
                . a({-href=>"$url?choice=search%20by%20line%20and%20sex&line=" . $line_id . "&include_dead=" . $include_dead . "&only_dead=" . $only_dead . "&gtype=" . $gtype . "&sex=" . $sex . "&min_age=" . $min_age . "&max_age=" . $max_age . "&sort_order=$rev_order->{$sort_order}&sort_by=cage&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by cage, click again to change sort order"},           "cage")
               ),
               th("comment (shortened)")
             );

  # loop over all mice that match the search criteria
  for ($i=0; $i<$rows; $i++) {

     $row = $result->[$i];                # fetch next row

     # we store every mouse (even those we don't display): put all into cart
     $page .= hidden(-name=>'all_mice', -value=>$row->{'mouse_id'});

     # skip all rows with (row index < $start_row)
     if ($i+1 < $start_row )               { next; }

     # skip all rows with (row index > $start_row+$show_rows): exit loop
     if ($i+1 >= $start_row + $show_rows)  { next; }

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     # shorten comment to fit on page
     if ($row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
     }
     else {
        $short_comment = $row->{'mouse_comment'};
     }

     $short_comment =~ s/^'(.*)'$/$1/g;

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current mouse
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
                ),
                td({-align=>'left'},
                   ((defined($current_mating))
                    ?"(in mating $current_mating) "
                    :''
                   )
                   . $short_comment
                )
              );
  }

  $page .= end_table()
           . p();

  # store CGI parameters in hidden fields. Yes, I know, there are better ways to do this, but input from hidden fields will be checked before use
  foreach $parameter (@parameters) {
     unless ($parameter eq 'mouse_select' || $parameter eq 'job') {
        $page .= hidden(-name=>$parameter, -value=>param("$parameter")) . "\n";
     }
  }

  $page .= submit(-name => "job", -value=>"Add selected mice to cart") . '&nbsp;&nbsp;&nbsp;' . submit(-name => "job", -value=>"Add all mice to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")                . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")       . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mouse_by_line_and_sex
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA003 find_mice_by_id                              find mice by id
sub find_mice_by_id {                                    my $sr_name = 'SR_SEA003';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my ($page, $sql, $result, $rows, $row, $i);
  my ($line_name, $id);
  my $mouse_ids   = param('mouse_ids');
  my $sort_column = param('sort_by');
  my $sort_order  = param('sort_order');
  my $start_row   = param('start_row');
  my $show_rows   = $global_var_href->{'show_rows'};
  my $url         = url();
  my $rev_order   = {'asc' => 'desc', 'desc' => 'asc'};                  # toggle table
  my $sex_color   = {'m' => $global_var_href->{'bg_color_male'},
                     'f' => $global_var_href->{'bg_color_female'}};
  my @id_list;
  my @sql_id_list;
  my @parameters = param();                                 # read all CGI parameter keys
  my $parameter;
  my ($current_mating, $short_comment);
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;
  my ($cart_mice, $cart_mouse);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';

  # hide real database column names from user (security issue): use translation hash table
  # left (key): identifier used in HTML form; right (value): database column name
  my $columns  = {'id'  => 'mouse_id', 'earmark' => 'mouse_earmark', 'dob' => 'mouse_birth_datetime', 'genotype' => 'm2g_genotype',
                  'sex' => 'mouse_sex', 'strain' => 'strain_name',  'line' => 'line_name',            'location' => 'cage_name',
                  'dod' => 'mouse_deathorexport_datetime',          'cage' => 'cage_id',              'rack'     => 'concat(location_room,location_rack)'};

  # check if list of mouse ids given
  if (!param('mouse_ids')) {
     $page = p({-class=>"red"}, b("Error: Please give a list of mouse ids."));
     return $page;
  }

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
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

  # split the string that contains the mouse ids. Use any non-digit character as separator
  @id_list = split(/[^0-9]/, $mouse_ids);

  # check every element of the resulting list of potential mouse ids
  foreach $id (@id_list) {
     # ... if it is an 8 digit number:
     if ($id =~ /^[0-9]{8}$/) {
        # ... add it to the SQL search list
        push(@sql_id_list, $id);
     }
  }

  # regenerate a "clean" version of the mouse id list
  $mouse_ids = join(',', @sql_id_list);

  # generate the SQL search set string
  $sql_mouse_list = qq(') . join(qq(','), @sql_id_list) . qq(');

  $page .= h3(qq(Your search by mouse id list))
           . hr();

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href)
              . hr();
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add all mice to cart") {
     $page .= add_all_to_cart($global_var_href)
              . hr();
  }

  # delete the all_mice fields
  Delete('all_mice');

  $sql = qq(select distinct mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
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
                   $restrict_to_cart_sql
            order  by $columns->{$sort_column} $sort_order
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mice found having ids from the list
  unless ($rows > 0) {
     $page .= p("No mice found having matching ids from your list $restrict_to_cart_notice.");
     return $page;
  }

  $page .= p(b("Found $rows " . (($rows == 1)?'mouse':'mice' ). " from your list $restrict_to_cart_notice"))
           . p(join(',', @sql_id_list))
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . '&start_row=1' . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . '&start_row=' . ($start_row - $show_rows) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . '&start_row=' . ($start_row + $show_rows) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . '&start_row=' . ($rows - $show_rows + 1) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[last]'):'[last]')
              )
              :''
             )
           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th(a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=id&restrict_to_cart=" . param('restrict_to_cart'),       -title=>"click to sort by mouse id, click again to change sort order"},       "mouse ID")      ),
               th(a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=earmark&restrict_to_cart=" . param('restrict_to_cart'),  -title=>"click to sort by earmark, click again to change sort order"},        "ear")           ),
               th(a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=sex&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by sex, click again to change sort order"},            "sex")           ),
               th(a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=dob&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by date of birth, click again to change sort order"},  "born")          ),
               th(span({-title=>"living mice: current age; dead mice: age at day of death"}, "age")),
               th(a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=dod&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by date of death, click again to change sort order"},  "death")         ),
               th(a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=genotype&restrict_to_cart=" . param('restrict_to_cart'), -title=>"click to sort by genotype, click again to change sort order"},       "genotype")      ),
               th(a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=strain&restrict_to_cart=" . param('restrict_to_cart'),   -title=>"click to sort by strain, click again to change sort order"},         "strain")        ),
               th(a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=line&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by line, click again to change sort order"},           "line")          ),
               th(a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=rack&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by rack, click again to change sort order"},           "room/rack")
                . a({-href=>"$url?choice=search%20by%20mouse%20ids&mouse_ids=" . $mouse_ids . "&sort_order=$rev_order->{$sort_order}&sort_by=cage&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by cage, click again to change sort order"},           "cage")
               ),
               th("comment (shortened)")
             );

  # loop over all mice that match to the id list
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # we store every mouse (even those we don't display): put all into cart
     $page .= hidden(-name=>'all_mice', -value=>$row->{'mouse_id'});

     # skip all rows with (row index < $start_row)
     if ($i+1 < $start_row )              { next; }

     # skip all rows with (row index > $start_row+$show_rows): exit loop
     if ($i+1 >= $start_row + $show_rows) { next; }

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     # shorten comment to fit on page
     if ($row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
     }
     else {
        $short_comment = $row->{'mouse_comment'};
     }

     $short_comment =~ s/^'(.*)'$/$1/g;

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current mouse
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
                ),
                td({-align=>'left'},
                   ((defined($current_mating))
                    ?"(in mating $current_mating) "
                    :''
                   )
                   . $short_comment
                )
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

  $page .= submit(-name => "job", -value=>"Add selected mice to cart") . '&nbsp;&nbsp;&nbsp;' . submit(-name => "job", -value=>"Add all mice to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")                . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")       . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mice_by_id
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA004 find_mice_by_patho_id                        find mice by patho id
sub find_mice_by_patho_id {                              my $sr_name = 'SR_SEA004';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my ($page, $sql, $result, $rows, $row, $i);
  my ($line_name, $id);
  my $patho_id    = param('patho_id');
  my $url         = url();
  my $sex_color   = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my @parameters  = param();                               # read all CGI parameter keys
  my $parameter;
  my ($first_gene_name, $first_genotype, $sql_pathoID_list);
  my @sql_parameters;
  my @id_list;
  my @sql_id_list;
  my ($cart_mice, $cart_mouse);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';

  # check if patho id given
  if (!param('patho_id') || param('patho_id') eq '') {
     $page = p({-class=>"red"}, b(qq(Error: Please give at least one valid patho ID (something like "05/126"))));
     return $page;
  }

  # split the string that contains the patho ids. Use any non-digit character as separator
  @id_list = split(/[^0-9\/]/, $patho_id);

  # check every element of the resulting list of potential mouse ids
  foreach $id (@id_list) {
     # ... if it is a patho ID:
     if ($id =~ /^[0-9]{2}\/[0-9]{1,5}$/) {
        # ... add it to the SQL search list
        push(@sql_id_list, $id);
     }
  }

  if (scalar @sql_id_list < 1) {
     $page = p({-class=>"red"}, b(qq(Error: Please give at least one valid patho ID (something like "05/126"))));
     return $page;
  }

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  # generate the SQL search set string
  $sql_pathoID_list = qq(') . join(qq(','), @sql_id_list) . qq(');


  $page .= h3(qq(Your search by patho IDs: ) . join(',', @sql_id_list))
           . hr();

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href)
              . hr();
  }

  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime,
                   property_value_text as patho_id, dr1.death_reason_name as how, dr2.death_reason_name as why
            from   mice
                   join mouse_strains      on             mouse_strain = strain_id
                   join mouse_lines        on               mouse_line = line_id
                   left join mice2properties    on                 mouse_id = m2pr_mouse_id
                   left join properties         on              property_id = m2pr_property_id
                   join death_reasons dr1  on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2  on  mouse_deathorexport_why = dr2.death_reason_id
            where  property_value_text   in ($sql_pathoID_list)
                   and property_category = ?
                   and property_key      = ?
                   $restrict_to_cart_sql
           );

  @sql_parameters = ('mouse', 'pathoID');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mouse found having this patho id
  unless ($rows > 0) {
     $page .= p(qq(No mice found having one of the given patho IDs: ) . join(',', @sql_id_list) . " $restrict_to_cart_notice");
     return $page;
  }

  $page .= p(b("Found $rows " . (($rows == 1)?'mouse':'mice' ). " with matching patho ID $restrict_to_cart_notice"))

           . start_form(-action=>url())
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th("select"        ),
               th("patho ID"      ),
               th("mouse ID"      ),
               th("ear"           ),
               th("sex"           ),
               th("born"          ),
               th("age"           ),
               th("death"         ),
               th("genotype"      ),
               th("strain"        ),
               th("line"          )
             );

  # loop over all mice with matching patho id (should normally only be one)
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current line
     $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                td($i+1),
                td(checkbox('mouse_select', '0', $row->{'mouse_id'}, '')),
                td($row->{'patho_id'}),
                td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                td($row->{'mouse_earmark'}),
                td($row->{'mouse_sex'}),
                td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                td({-title=>"$row->{'how'}, $row->{'why'}"}, format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
                td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
                td($row->{'strain_name'}),
                td('&nbsp;' . $row->{'line_name'} . '&nbsp;')
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
           . submit(-name => "job", -value=>"genotype")               . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre") . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")      . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mice_by_patho_id
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA005 find_mice_by_foreign_id                      find mice by foreign id
sub find_mice_by_foreign_id {                            my $sr_name = 'SR_SEA005';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my ($page, $sql, $result, $rows, $row, $i);
  my ($line_name, $id);
  my $foreign_id  = param('foreign_id');
  my $url         = url();
  my $sex_color   = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;
  my ($cart_mice, $cart_mouse);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';

  # check if foreign id provided: exit if not or if some "dangerous" words in foreign id
  if (!param('foreign_id') || param('foreign_id') =~ /select|drop|;|delete|grant|update|'|""|\s/ ) {
     $page = p({-class=>"red"}, b(qq(Error: Please give a valid foreign ID)));
     return $page;
  }

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  $page .= h3(qq(Your search by foreign ID "$foreign_id" ))
           . hr();

  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime,
                   property_value_text as patho_id, dr1.death_reason_name as how, dr2.death_reason_name as why
            from   mice
                   join mouse_strains     on            mouse_strain = strain_id
                   join mouse_lines       on              mouse_line = line_id
                   join mice2properties   on                mouse_id = m2pr_mouse_id
                   join properties        on             property_id = m2pr_property_id
                   join death_reasons dr1 on mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2 on mouse_deathorexport_why = dr2.death_reason_id
            where  property_value_text    = ?
                   and property_category  = ?
                   and property_key       = ?
                   $restrict_to_cart_sql
           );

  @sql_parameters = ($foreign_id, 'mouse', 'foreignID');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # nothing found: exit
  unless ($rows > 0) {
     $page .= p(qq(No mice found having foreign ID "$foreign_id" $restrict_to_cart_notice));
     return $page;
  }

  $page .= p(b("Found $rows " . (($rows == 1)?'mouse':'mice' ). " with matching foreign ID $restrict_to_cart_notice"))

           . start_form(-action=>url())
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th("foreign ID"    ),
               th("sex"           ),
               th("genotype"      ),
               th("strain"        ),
               th("line"          )
             );

  # loop over all mouse with this foreign id (could theoretically be more than one)
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current line
     $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                td($i+1),
                td(a({-href=>"$url?choice=mouse_details&mouse_id=" . $row->{'mouse_id'}, -title=>"click for mouse details"}, mouse_id2externalID($global_var_href, $row->{'mouse_id'}))),
                td($row->{'mouse_sex'}),
                td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
                td($row->{'strain_name'}),
                td('&nbsp;' . $row->{'line_name'} . '&nbsp;')
              );
  }

  $page .= end_table()
           . end_form();

  return $page;
}
# end of find_mice_by_foreign_id
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA006 find_mice_by_cage                            find mice by cage id(s)
sub find_mice_by_cage {                                  my $sr_name = 'SR_SEA006';
  my ($global_var_href)       = @_;                            # get reference to global vars hash
  my $session                 = $global_var_href->{'session'}; # get session handle
  my $url                     = url();
  my $cage_ids                = param('cage_ids');
  my @parameters              = param();                       # read all CGI parameter keys
  my $sex_color               = {'m' => $global_var_href->{'bg_color_male'},
                                 'f' => $global_var_href->{'bg_color_female'}};
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';
  my $old_cage                = 0;
  my @cage_id_list            = ();
  my @sql_cage_id_list        = ();
  my ($page, $sql, $result, $rows, $row, $i, $parameter);
  my ($cart_mice, $cart_mouse, $cage_id, $sql_cage_list, $sql_mouse_list);
  my ($current_mating, $short_comment, $gene_info, $project_info);
  my ($first_gene_name, $first_genotype);
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my @sql_parameters;

  # check if list of cage ids given
  if (!param('cage_ids')) {
     $page = p({-class=>"red"}, b("Error: Please give a list of cage ids."));
     return $page;
  }

  # split the string that contains the cage ids. Use any non-digit character as separator
  @cage_id_list = split(/[^0-9]/, $cage_ids);

  # check every element of the resulting list
  foreach $cage_id (@cage_id_list) {
     # ... if it is a 1-4 digit number ...
     if ($cage_id =~ /^[0-9]{1,4}$/) {
        # ... add it to the SQL search list
        push(@sql_cage_id_list, $cage_id);
     }
  }

  # generate the SQL search set string
  $sql_cage_list = qq(') . join(qq(','), @sql_cage_id_list) . qq(');

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  $page = start_form(-action => url())
          . h2("Cage view " . a({-href=>"$url?choice=search%20by%20cage&cage_ids=$cage_ids", -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'}))
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

  $sql = qq(select c2l_cage_id, cage_capacity,
                   mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_is_gvo, mouse_comment, location_id, location_room, location_rack, cage_id,
                   mouse_birth_datetime, mouse_deathorexport_datetime, project_shortname
            from   cages2locations
                   join locations       on  c2l_location_id = location_id
                   join cages           on          cage_id = c2l_cage_id
                   join mice2cages      on      m2c_cage_id = cage_id
                   join mice            on     m2c_mouse_id = mouse_id
                   join mouse_strains   on     mouse_strain = strain_id
                   join mouse_lines     on       mouse_line = line_id
                   left join projects   on location_project = project_id
            where  m2c_cage_id in ($sql_cage_list)
                   and c2l_datetime_to IS NULL
                   and m2c_datetime_to IS NULL
                   and mouse_deathorexport_datetime IS NULL
                   $restrict_to_cart_sql
            order  by c2l_cage_id asc
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mice found in specified cages
  unless ($rows > 0) {
     $page .= p("No mice found for given list of cages $restrict_to_cart_notice");
     return $page;
  }

  # ok, there were results, so continue ...
  $page .= h3("Found the following mice for cages " . join(",", @sql_cage_id_list) . $restrict_to_cart_notice)

           . start_form(-action=>url(), -name=>"myform")
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
               th("comment (shortened)"),
               th("move mouse")
             );

  # loop over all mice
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # add separator line if cage changes
     if ($row->{'cage_id'} != $old_cage) {
        $page .= Tr(
                   td({-colspan=>"13"},
                      b("Cage ") . b(a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"},     # yes: print cage link
                                       $row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'}
                                      )
                                    )
                      . " (" . a({-href=>"$url?choice=print_card&cage_id=" . $row->{'cage_id'}, -target=>"_blank"}, "print cage card" ) . ") "
                   )
                 );
     }

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     # shorten comment to fit on page
     if ($row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
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
                td(checkbox('mouse_select', '0', $row->{'mouse_id'}, '')),
                td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                td($row->{'mouse_earmark'}),
                td($row->{'mouse_sex'}),
                td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                td(format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
                td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
                td($row->{'strain_name'}),
                td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                td({-align=>'left'},
                   ((defined($current_mating))
                    ?"(in mating " . a({-href=>"$url?choice=mating_view&mating_id=$current_mating"}, $current_mating) . ") "
                    :''
                   )
                   . $short_comment
                ),
                td({-bgcolor=>"#EEEEEE"}, a({-href=>"$url?choice=move_mouse&mouse_id=" . $row->{'mouse_id'}, -title=>"click to move mouse"}, "move mouse"))
              );

     $old_cage = $row->{'cage_id'};
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
           . submit(-name => "job", -value=>"order phenotyping")      . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mice_by_cage
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA007 find_mouse_by_genotypes                      find mice based on their (multiple) genotypes
sub find_mouse_by_genotypes {                            my $sr_name = 'SR_SEA007';
  my ($global_var_href)       = @_;                            # get reference to global vars hash
  my $session                 = $global_var_href->{'session'}; # get session handle
  my $url                     = url();
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';
  my $sex_color               = {'m' => $global_var_href->{'bg_color_male'},
                                 'f' => $global_var_href->{'bg_color_female'}};
  my @parameters              = param();                            # read all CGI parameter keys
  my %genotype_labels         = ();
  my %match_count             = ();
  my @mice                    = ();
  my @final_list              = ();
  my ($page, $sql, $result, $rows, $row, $i, $j);
  my ($gene_locus, $gene_genotype, $gene_select, $gene_locus_id, $gene_genotype_id, $genotype, $mouse);
  my ($cart_mice, $cart_mouse, $sql_mouse_list, $parameter, $genotype_sql, $number_of_genotypes, $sql_final_mouse_list);
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my @sql_parameters;

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  # create look-up table for genotypes
  $sql = qq(select setting_key, setting_value_text
            from   settings
            where  setting_category = ?
                   and setting_item = ?
           );

  @sql_parameters = ('menu', 'genotypes_for_popup');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($j=0; $j<$rows; $j++) {
      $row = $result->[$j];

      $genotype_labels{$row->{'setting_key'}} = $row->{'setting_value_text'};        # create look-up hash table: "1"->"+/-"
  }

  # now collect mice that fulfill all genotype criteria
  for ($j=1; $j<=10; $j++) {                                             # be prepared for up to 10 genotypes
      $gene_locus       = $j . '_gene_locus';                            # create numbered parameters
      $gene_genotype    = $j . '_gene_genotype';                         # create numbered parameters
      $gene_select      = $j . '_gene_select';                           # create numbered parameters

      # only if all current loop parameter are given (for example "1_gene_locus", "1_gene_genotype" and "1_gene_select"=1) and valid
      if (   defined(param($gene_locus))    &&  param($gene_locus)    =~ /^[0-9]+$/
          && defined(param($gene_genotype)) && (param($gene_genotype) =~ /^[0-9]+$/ || $genotype_labels{param($gene_genotype)} eq 'any')
          && defined(param($gene_select))   &&  param($gene_select)   == 1) {
         $gene_locus_id    = param($gene_locus);                         # read value (id of gene locus)
         $gene_genotype_id = param($gene_genotype);                      # read value (id of genotype)

         # we either look for a certain genotype ...
         if (param($gene_genotype) =~ /^[0-9]+$/) {
            $genotype = $genotype_labels{$gene_genotype_id};        # convert genotype id to genotype ("1" -> "+/-")
            $genotype_sql = "and m2g_genotype = '$genotype'";
         }

         # .. or we look for any genotype for that locus
         if ($genotype_labels{$gene_genotype_id} eq 'any') {
            $genotype_sql = "";
         }

         # increment number of genotypes to be used in search
         $number_of_genotypes++;

         # build SQL select statement to get all mice that have genotype "$genotype" for gene with id "$gene_locus_id"
         $sql = qq(select m2g_mouse_id
                   from   mice2genes
                   where  m2g_gene_id = ?
                          $genotype_sql
                  );

         @sql_parameters = ($gene_locus_id);

         ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

         # add a count for all mice that match genotype
         for ($i=0; $i<$rows; $i++) {
             $row = $result->[$i];

             $match_count{$row->{'m2g_mouse_id'}}++;
         }
      }
  }

  # loop over all mice that matched any genotype
  foreach $mouse (keys %match_count) {
     # add those to final result list which matched in every search
     if ($match_count{$mouse} == $number_of_genotypes) {
        push(@final_list, $mouse);
     }
  }

  # generate the SQL search set string
  $sql_final_mouse_list = qq(') . join(qq(','), @final_list) . qq(');

  $page .= h3(qq(Your search by genotypes))
           . hr();

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href)
              . hr();
  }

  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
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
            where  mouse_id in ($sql_final_mouse_list)
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
                   and mouse_origin_type <> ?
                   $restrict_to_cart_sql
            order  by mouse_id asc
           );

  @sql_parameters = ('external');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # exit if no results for search
  unless ($rows > 0) {
     $page .= p("Nothing found for the above search criteria $restrict_to_cart_notice.");
     return $page;
  }

  $page .= p(b("Found $rows " . (($rows == 1)?'mouse':'mice') . $restrict_to_cart_notice))
           . start_form(-action=>url(), -name=>"myform")
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
               th("room/rack-cage")
             );

  # loop over all mice that match the search criteria
  for ($i=0; $i<$rows; $i++) {

     $row = $result->[$i];                # fetch next row

     # add table row for current mouse
     $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                td($i+1),
                td(checkbox('mouse_select', '0', $row->{'mouse_id'}, '')),
                td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                td($row->{'mouse_earmark'}),
                td($row->{'mouse_sex'}),
                td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                td({-title=>"$row->{'how'}, $row->{'why'}"}, format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
                td({-align=>'left'}, get_gene_info_small($global_var_href, $row->{'mouse_id'})),
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
           . p();

  # store CGI parameters in hidden fields. Yes, I know, there are better ways to do this, but input from hidden fields will be checked before use
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
           . submit(-name => "job", -value=>"order phenotyping")      . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mouse_by_genotypes
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA008 find_mice_by_comment                         find mice by comment
sub find_mice_by_comment {                               my $sr_name = 'SR_SEA008';
  my ($global_var_href) = @_;                           # get reference to global vars hash
  my $session           = $global_var_href->{'session'};# get session handle
  my $comment_fragment  = param('comment_fragment');
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my $sex_color   = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my @parameters  = param();                                # read all CGI parameter keys
  my $parameter;
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;
  my @sub_keywords;
  my ($comment_like, $sub_keyword);
  my ($cart_mice, $cart_mouse);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';

  # check if comment given
  if (!param('comment_fragment')) {
     $page = p({-class=>"red"}, b("Error: Please enter a part of a comment to search for."));
     return $page;
  }

  # split search term into pieces ...
  @sub_keywords = split(/\W/, $comment_fragment);

  # ... and build concat the pieces by AND on SQL level
  foreach $sub_keyword (@sub_keywords) {
     $comment_like .= qq(and mouse_comment like '%$sub_keyword%' );
  }

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  $page = h2("Find mice by comment")
          . hr();

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href);
  }

  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
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
            where  ( 1 $comment_like)
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
                   $restrict_to_cart_sql
            order  by mouse_id
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mice found in specified cages
  unless ($rows > 0) {
     $page .= p("No mice found having \"$comment_fragment\" as part of their comment $restrict_to_cart_notice");
     return $page;
  }

  # ok, there were results, so continue ...
  $page .= h3("Found the following mice with \"$comment_fragment\" as part of their comment $restrict_to_cart_notice")

           . start_form(-action=>url(), -name=>"myform")
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
               th("comment"),
               th("move mouse")
             );

  # loop over all mice
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

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
                td(format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
                td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
                td($row->{'strain_name'}),
                td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                td($row->{'mouse_comment'}),
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
           . submit(-name => "job", -value=>"order phenotyping")      . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mice_by_comment
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA009 find_mice_by_mating_name:                    find_mice_by_mating_name
sub find_mice_by_mating_name {                           my $sr_name = 'SR_SEA009';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my $show_rows   = $global_var_href->{'show_rows'};
  my $start_row   = param('start_row');
  my $mating_name = param('mating_name');
  my @sql_parameters;
  my @sub_keywords;
  my ($mating_name_like, $mating_comment_like, $sub_keyword);

  @sub_keywords = split(/\W/, $mating_name);

  foreach $sub_keyword (@sub_keywords) {
     $mating_name_like    .= qq(and mating_name    like '%$sub_keyword%' );
     $mating_comment_like .= qq(and mating_comment like '%$sub_keyword%' );
  }

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  $page = start_form(-action => url())
          . h2("Matings by name: "
               . "&nbsp;&nbsp;&nbsp;&nbsp;["
               . small("Search mating by name: ")
               . textfield(-name => "mating_name", -size=>"20", -maxlength=>"30", -title=>"enter (part of) mating name or comment")
               . submit(-name => "choice", -value=>"Search by mating name")
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
            where  (1 $mating_name_like)
                   OR
                   (1 $mating_comment_like)
            group  by mating_id
            order  by mating_id desc
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no matings found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No matings found that match your search term \"$mating_name\".");
    return $page;
  }

  # ... otherwise continue with matings table

  # first generate table header ...
  $page .= h3("Found $rows mating(s) containing \"$mating_name\" in mating name or comment. " )
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
                 . (($start_row > 1)?a({-href=>"$url?choice=mating_overview&mating_name=$mating_name" . '&start_row=1'}, '[first]'):'[first]')
                 . "&nbsp;"
                 . (($start_row > 1)?a({-href=>"$url?choice=mating_overview&mating_name=$mating_name" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
                 . "&nbsp;"
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=mating_overview&mating_name=$mating_name" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
                 . "&nbsp; "
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=mating_overview&mating_name=$mating_name" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
                )
              :''
             )
           . start_table( {-border=>"1", -summary=>"mating_by_name"})
           . Tr( {-align=>'center'},
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
                 td(a({-href=>"$url?choice=mating_view&mating_id=$row->{'mating_id'}", -title=>"click for mating details"}, "mating $row->{'mating_id'}")
                 ),
                 td(($row->{'mating_name'} ne qq(''))?qq("$row->{'mating_name'}"):'-'),
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
# end of find_mice_by_mating_name()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA010 find_mice_by_experiment:                     find mice by experiment
sub find_mice_by_experiment {                            my $sr_name = 'SR_SEA010';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my $show_rows     = $global_var_href->{'show_rows'};
  my $start_row     = param('start_row');
  my $experiment_id = param('experiment_id');
  my $sex_color    = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my @parameters   = param();                                # read all CGI parameter keys
  my ($parameter, $experiment_name);
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;
  my ($cart_mice, $cart_mouse);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';

  # check input: is experiment id given? is it a number?
  if (!param('experiment_id') || param('experiment_id') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: Please give a valid experiment id."));
     return $page;
  }

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href)
              . hr();
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add all mice to cart") {
     $page .= add_all_to_cart($global_var_href)
              . hr();
  }

  # delete the all_mice fields
  Delete('all_mice');

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  $page = h2("Find mice by experiment id")
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select experiment_id, experiment_name, m2e_datetime_from, m2e_datetime_to, mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_is_gvo,
                   mouse_comment, location_id, location_room, location_rack, cage_id,
                   mouse_birth_datetime, mouse_deathorexport_datetime
            from   mice2experiments
                   join mice            on      m2e_mouse_id = mouse_id
                   join  experiments    on m2e_experiment_id = experiment_id
                   join mice2cages      on      m2c_mouse_id = mouse_id
                   join cages           on       m2c_cage_id = cage_id
                   join cages2locations on       c2l_cage_id = m2c_cage_id
                   join locations       on   c2l_location_id = location_id
                   join mouse_strains   on      mouse_strain = strain_id
                   join mouse_lines     on        mouse_line = line_id
            where  m2e_experiment_id = ?
                   and c2l_datetime_to IS NULL
                   and m2c_datetime_to IS NULL
                   $restrict_to_cart_sql
           );

  @sql_parameters = ($experiment_id);
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no matings found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No mice found for given experiment $restrict_to_cart_notice.");
    return $page;
  }

  # ... otherwise continue with result table

  # get experiment name
  $experiment_name = $result->[0]->{'experiment_name'};

  $page .= h3("Found $rows " . (($rows == 1)?'mouse':'mice' ) . " in experiment \"$experiment_name\"  $restrict_to_cart_notice")

           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20experiment&experiment_id=$experiment_id&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=1'}, '[first]'):'[first]')
                 . "&nbsp;"
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20experiment&experiment_id=$experiment_id&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
                 . "&nbsp;"
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20experiment&experiment_id=$experiment_id&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
                 . "&nbsp; "
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20experiment&experiment_id=$experiment_id&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
                )
              :''
             )

           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th("experiment" . br() . "start"),
               th("experiment" . br() . "end"),
               th("mouse ID"),
               th("ear"),
               th("sex"),
               th("born"),
               th("age"),
               th("death"),
               th("genotype"),
               th("strain"),
               th("line"),
               th("comment")
             );

  # loop over all mice
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # we store every mouse (even those we don't display): put all into cart
     $page .= hidden(-name=>'all_mice', -value=>$row->{'mouse_id'});

     # skip all rows with (row index < $start_row)
     if ($i+1 < $start_row )              { next; }

     # skip all rows with (row index > $start_row+$show_rows): exit loop
     if ($i+1 >= $start_row + $show_rows) { next; }

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current line
     $page .= Tr({-align=>'center', -bgcolor=>"$sex_color->{$row->{'mouse_sex'}}"},
                td($i+1),
                td(checkbox('mouse_select', '0', $row->{'mouse_id'}, '')),
                td(format_datetime2simpledate($row->{'m2e_datetime_from'})),
                td(format_datetime2simpledate($row->{'m2e_datetime_to'})),
                td(a({-href=>"$url?choice=mouse_details&mouse_id=" . &reformat_number($row->{'mouse_id'}, 8), -title=>"click for mouse details"}, &reformat_number($row->{'mouse_id'}, 8))),
                td($row->{'mouse_earmark'}),
                td($row->{'mouse_sex'}),
                td(format_datetime2simpledate($row->{'mouse_birth_datetime'})),
                td({-style=>"width: 15mm; white-space: nowrap; overflow: hidden;"}, get_age($row->{'mouse_birth_datetime'}, $row->{'mouse_deathorexport_datetime'})),
                td(format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
                td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
                td($row->{'strain_name'}),
                td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                td($row->{'mouse_comment'})
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

  $page .= submit(-name => "job", -value=>"Add selected mice to cart") . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"Add all mice to cart", -title=>"add complete multi-page result set to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")                . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")       . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mice_by_experiment()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA011 find_mice_by_date_of_death                   find mice by date of death
sub find_mice_by_date_of_death {                         my $sr_name = 'SR_SEA011';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my ($page, $sql, $result, $rows, $row, $i);
  my ($line_name, $id, $ld, $ud);
  my $death_after  = param('death_after');
  my $death_before = param('death_before');
  my $start_row    = param('start_row');
  my $show_rows    = $global_var_href->{'show_rows'};
  my $url          = url();
  my $sex_color    = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my @id_list;
  my @sql_id_list;
  my @parameters = param();                                 # read all CGI parameter keys
  my $parameter;
  my ($current_mating, $short_comment);
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;
  my ($cart_mice, $cart_mouse);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  # check death date (lower limit)
  if (!param('death_after') || check_datetime_ddmmyyyy_hhmmss(param('death_after') . ' 00:00:00') != 1) {
     $page .= p({-class=>"red"}, b("Error: lower limit for date of death not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check death date (upper limit)
  if (!param('death_before') || check_datetime_ddmmyyyy_hhmmss(param('death_before') . ' 00:00:00') != 1) {
     $page .= p({-class=>"red"}, b("Error: upper limit for date of death not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  $page .= h3(qq(Your search by date of death ))
           . hr();

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href)
              . hr();
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add all mice to cart") {
     $page .= add_all_to_cart($global_var_href)
              . hr();
  }

  # delete the all_mice fields
  Delete('all_mice');

  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
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
            where  NOT(mouse_deathorexport_datetime IS NULL)
                   and date(mouse_deathorexport_datetime) >= ?
                   and date(mouse_deathorexport_datetime) <  ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
                   $restrict_to_cart_sql
            order  by mouse_deathorexport_datetime asc
           );

  $ld = format_display_date2sql_date($death_after);
  $ud = format_display_date2sql_date($death_before);

  @sql_parameters = ($ld, $ud);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mice found having ids from the list
  unless ($rows > 0) {
     $page .= p("No mice found having date of death in given time period ($death_after - $death_before) $restrict_to_cart_notice. ");
     return $page;
  }

  $page .= p(b("Found $rows " . (($rows == 1)?'mouse':'mice' ). " that died between $death_after and $death_before $restrict_to_cart_notice"))
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20date%20of%20death&death_before=$death_before&death_after=$death_after&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=1'}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20date%20of%20death&death_before=$death_before&death_after=$death_after&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20date%20of%20death&death_before=$death_before&death_after=$death_after&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20date%20of%20death&death_before=$death_before&death_after=$death_after&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
              )
              :''
             )
           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th("mouse ID"      ),
               th("ear"           ),
               th("sex"           ),
               th("born"          ),
               th(span({-title=>"living mice: current age; dead mice: age at day of death"},  "age")),
               th("death"         ),
               th("genotype"      ),
               th("strain"        ),
               th("line"          ),
               th("room/rack-cage"      ),
               th("comment (shortened)" )
             );

  # loop over all mice that match to the id list
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # we store every mouse (even those we don't display): put all into cart
     $page .= hidden(-name=>'all_mice', -value=>$row->{'mouse_id'});

     # skip all rows with (row index < $start_row)
     if ($i+1 < $start_row )              { next; }

     # skip all rows with (row index > $start_row+$show_rows): exit loop
     if ($i+1 >= $start_row + $show_rows) { next; }

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     # shorten comment to fit on page
     if ($row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
     }
     else {
        $short_comment = $row->{'mouse_comment'};
     }

     $short_comment =~ s/^'(.*)'$/$1/g;

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current mouse
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
                ),
                td({-align=>'left'},
                   ((defined($current_mating))
                    ?"(in mating $current_mating) "
                    :''
                   )
                   . $short_comment
                )
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

  $page .= submit(-name => "job", -value=>"Add selected mice to cart") . '&nbsp;&nbsp;&nbsp;' . submit(-name => "job", -value=>"Add all mice to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")                . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")       . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mice_by_date_of_death
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA012 find_orderlists_by_parameterset              find orderlists by parameterset
sub find_orderlists_by_parameterset {                    my $sr_name = 'SR_SEA012';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my $show_rows    = $global_var_href->{'show_rows'};
  my $start_row    = param('start_row');
  my $parameterset = param('parameterset');
  my $status       = param('status');
  my @sql_parameters;
  my ($mice_on_orderlist, $parameterset_name);
  my $old_date = 0;

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  # check input: is parameterset id given? is it a number?
  if (!param('parameterset') || param('parameterset') !~ /^[0-9]+$/) {
     &error_message_and_exit($global_var_href, "invalid parameterset id (must be a number)", $sr_name . "-" . __LINE__);
  }

  # check input: is parameterset id given? is it a number?
  if (!param('status') || param('status') !~ /^(done|ordered|cancelled)$/) {
     &error_message_and_exit($global_var_href, "invalid status (must be \'done\', \'ordered\' or \'cancelled\')", $sr_name . "-" . __LINE__);
  }

  # get parameterset name
  $sql = qq(select parameterset_name
            from   parametersets
            where  parameterset_id = ?
           );

  @sql_parameters = ($parameterset);

  ($parameterset_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};


  $page = h2("Orderlists for parameterset \'$parameterset_name\': ")
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select orderlist_id, orderlist_name, orderlist_date_scheduled, orderlist_parameterset,
                   orderlist_status, parameterset_name, day_week_in_year, day_year
            from   orderlists
                   join parametersets on  orderlist_parameterset = parameterset_id
                   left join projects      on parameterset_project_id = project_id
                   join days                         on day_date = orderlist_date_scheduled
            where            orderlist_status = ?
                   and orderlist_parameterset = ?
            order  by orderlist_date_scheduled desc
           );

  @sql_parameters = ($status, $parameterset);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no such orderlists found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No \'$status\' orderlists found for chosen parameterset \'$parameterset_name\'");
    return $page;
  }

  # ... otherwise continue with table

  # first generate table header ...
  $page .= h3("Found $rows \'$status\' orderlists for chosen parameterset \'$parameterset_name\'" )
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20orderlists%20by%20parameterset&parameterset=$parameterset&status=$status" . '&start_row=1'}, '[first]'):'[first]')
                 . "&nbsp;"
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20orderlists%20by%20parameterset&parameterset=$parameterset&status=$status" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
                 . "&nbsp;"
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20orderlists%20by%20parameterset&parameterset=$parameterset&status=$status" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
                 . "&nbsp; "
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20orderlists%20by%20parameterset&parameterset=$parameterset&status=$status" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
                )
              :''
             )
           . start_table( {-border=>"1", -summary=>"mating_by_name"})
           . Tr( {-align=>'center'},
               th('orderlist name'),
               th('parameterset'),
               th('status'),
               th('mice')
             );

  # ... then loop over all orderlists
  for ($i=0; $i<$rows; $i++) {
      if ($i+1 < $start_row )              { next; }               # skip all rows with (row index < $start_row)
      if ($i+1 >= $start_row + $show_rows) { last; }               # skip all rows with (row index > $start_row+$show_rows): exit loop

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

      # generate the current orderlist row
      $page .= Tr({-align=>'center'},
                 td(a({-href=>"$url?choice=orderlist_view&orderlist_id=" . $row->{'orderlist_id'}}, $row->{'orderlist_name'})),
                 td($row->{'parameterset_name'}),
                 td($row->{'orderlist_status'}),
                 td({-align=>'right'}, $mice_on_orderlist)
               );

      $old_date = $row->{'orderlist_date_scheduled'};
  }

  $page .= end_table();

  return $page;
}
# end of find_orderlists_by_parameterset()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA013 find_cart_by_cart_name:                      find cart by cart name
sub find_cart_by_cart_name {                             my $sr_name = 'SR_SEA013';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my $show_rows   = $global_var_href->{'show_rows'};
  my $start_row   = param('start_row');
  my $cart_name   = param('cart_name');
  my $session     = $global_var_href->{'session'};            # get session handle
  my $user_id     = $session->param(-name=>'user_id');
  my ($mice_in_cart, $unquoted_cart_name);
  my @sql_parameters;
  my @mice;
  my @sub_keywords;
  my ($cart_name_like, $sub_keyword);

  @sub_keywords = split(/\W/, $cart_name);

  foreach $sub_keyword (@sub_keywords) {
     $cart_name_like .= qq(and cart_name like '%$sub_keyword%' );
  }

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  $page = start_form(-action => url())
          . h2("carts by name: "
               . "&nbsp;&nbsp;&nbsp;&nbsp;["
               . small("Search cart by name: ")
               . textfield(-name => "cart_name", -size=>"20", -maxlength=>"30", -title=>"enter (part of) cart name")
               . submit(-name => "choice", -value=>"Search by cart name")
               . "]"
            )
          . end_form()
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select cart_id, cart_name, cart_content, cart_creation_datetime, cart_end_datetime, cart_user,
                   cart_is_public, user_name, contact_first_name, contact_last_name
            from   carts
                   left join users    on      user_id = cart_user
                   left join contacts on user_contact = contact_id
            where  (1 $cart_name_like)
            order  by cart_user, cart_creation_datetime desc, cart_id
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no matings found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No cart(s) found that match your search term \"$cart_name\".");
    return $page;
  }

  # ... otherwise continue with matings table

  # first generate table header ...
  $page .= h3("Found $rows cart(s) containing \"$cart_name\" in mating name or comment. " )
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20cart%20name&cart_name=$cart_name" . '&start_row=1'}, '[first]'):'[first]')
                 . "&nbsp;"
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20cart%20name&cart_name=$cart_name" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
                 . "&nbsp;"
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20cart%20name&cart_name=$cart_name" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
                 . "&nbsp; "
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20cart%20name&cart_name=$cart_name" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
                )
              :''
             )
           . start_table( {-border=>"1", -summary=>"cart_by_name"})
           . Tr(
               th({-align=>'right'}, "cart id"),
               th({-align=>'left'},  "cart name"),
               th("public"),
               th("mice in cart"),
               th("cart stored"),
               th("stored by"),
               th("load cart"),
               th("delete cart")
             );

  # ... then loop over all matings
  for ($i=0; $i<$rows; $i++) {
      if ($i+1 < $start_row )              { next; }               # skip all rows with (row index < $start_row)
      if ($i+1 >= $start_row + $show_rows) { last; }               # skip all rows with (row index > $start_row+$show_rows): exit loop

      $row = $result->[$i];

      # regenerate mouse list from comma-separated cart content string
      @mice = split(/,/, $row->{'cart_content'});
      $mice_in_cart = scalar @mice;                 # how many mice in cart

      # remove quoting marks
      $unquoted_cart_name = $row->{'cart_name'};
      $unquoted_cart_name =~ s/'//g;

      # generate the current mating row
      $page .= Tr( {-bgcolor=>($row->{'cart_user'} == $user_id)?'#AAFFFF':'white'},
                 td({-align=>'right'}, $row->{'cart_id'}),
                 td({-align=>'left'}, $unquoted_cart_name),
                 td({-align=>'center'}, ($row->{'cart_is_public'} eq 'y')?'y':''),
                 td({-align=>'center'}, $mice_in_cart),
                 td(format_datetime2simpledate($row->{'cart_creation_datetime'})),
                 td($row->{'contact_first_name'} . ' ' . $row->{'contact_last_name'}),
                 td(a({-href=>"$url?choice=restore_cart&cart_id=" . $row->{'cart_id'}}, "load cart")),
                 td(a({-href=>"$url?choice=delete_cart&&own_carts_only=n&cart_id="  . $row->{'cart_id'}}, "delete cart"))
               );
  }

  $page .= end_table();

  return $page;
}
# end of find_cart_by_cart_name()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA014 find_mice_by_date_of_birth                   find mice by date of birth
sub find_mice_by_date_of_birth {                         my $sr_name = 'SR_SEA014';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my ($page, $sql, $result, $rows, $row, $i);
  my ($line_name, $id, $ld, $ud);
  my $birth_after  = param('birth_after');
  my $birth_before = param('birth_before');
  my $start_row    = param('start_row');
  my $show_rows    = $global_var_href->{'show_rows'};
  my $url          = url();
  my $sex_color    = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my @id_list;
  my @sql_id_list;
  my @parameters = param();                                 # read all CGI parameter keys
  my $parameter;
  my ($current_mating, $short_comment);
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;
  my ($cart_mice, $cart_mouse);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  # check birth date (lower limit)
  if (!param('birth_after') || check_datetime_ddmmyyyy_hhmmss(param('birth_after') . ' 00:00:00') != 1) {
     $page .= p({-class=>"red"}, b("Error: lower limit for date of birth not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check birth date (upper limit)
  if (!param('birth_before') || check_datetime_ddmmyyyy_hhmmss(param('birth_before') . ' 00:00:00') != 1) {
     $page .= p({-class=>"red"}, b("Error: upper limit for date of birth not given or has invalid format"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  $page .= h3(qq(Your search by date of birth ))
           . hr();

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href)
              . hr();
  }  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add all mice to cart") {
     $page .= add_all_to_cart($global_var_href)
              . hr();
  }

  # delete the all_mice fields
  Delete('all_mice');

  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
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
            where      date(mouse_birth_datetime) >= ?
                   and date(mouse_birth_datetime) <  ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
                   $restrict_to_cart_sql
            order  by mouse_birth_datetime asc
           );

  $ld = format_display_date2sql_date($birth_after);
  $ud = format_display_date2sql_date($birth_before);

  @sql_parameters = ($ld, $ud);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mice found having ids from the list
  unless ($rows > 0) {
     $page .= p("No mice found having date of birth in given time period ($birth_after - $birth_before) $restrict_to_cart_notice. ");
     return $page;
  }

  $page .= p(b("Found $rows " . (($rows == 1)?'mouse':'mice' ). " that were born between $birth_after and $birth_before $restrict_to_cart_notice"))
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20date%20of%20birth&birth_before=$birth_before&birth_after=$birth_after&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=1'}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20date%20of%20birth&birth_before=$birth_before&birth_after=$birth_after&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20date%20of%20birth&birth_before=$birth_before&birth_after=$birth_after&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20date%20of%20birth&birth_before=$birth_before&birth_after=$birth_after&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
              )
              :''
             )
           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th("mouse ID"      ),
               th("ear"           ),
               th("sex"           ),
               th("born"          ),
               th(span({-title=>"living mice: current age; dead mice: age at day of death"},  "age")),
               th("death"         ),
               th("genotype"      ),
               th("strain"        ),
               th("line"          ),
               th("room/rack-cage"      ),
               th("comment (shortened)" )
             );

  # loop over all mice that match to the id list
  for ($i=0; $i<$rows; $i++) {

     $row = $result->[$i];                # fetch next row

     # we store every mouse (even those we don't display): put all into cart
     $page .= hidden(-name=>'all_mice', -value=>$row->{'mouse_id'});

     # skip all rows with (row index < $start_row)
     if ($i+1 < $start_row )              { next; }

     # skip all rows with (row index > $start_row+$show_rows): exit loop
     if ($i+1 >= $start_row + $show_rows) { next; }

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     # shorten comment to fit on page
     if ($row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
     }
     else {
        $short_comment = $row->{'mouse_comment'};
     }

     $short_comment =~ s/^'(.*)'$/$1/g;

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current mouse
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
                    ?a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"},              # yes: print cage link
                       $row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . $row->{'cage_id'})
                    :'-'                                                                                                          # no: don't print cage link
                ),
                td({-align=>'left'},
                   ((defined($current_mating))
                    ?"(in mating $current_mating) "
                    :''
                   )
                   . $short_comment
                )
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

  $page .= submit(-name => "job", -value=>"Add selected mice to cart") . '&nbsp;&nbsp;&nbsp;' . submit(-name => "job", -value=>"Add all mice to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")                . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")       . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mice_by_date_of_birth
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA015 find_blob_by_keyword:                        find blobs by keyword
sub find_blob_by_keyword {                               my $sr_name = 'SR_SEA015';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $blob_database     = $global_var_href->{'blob_database'};    # name of the blob_database
  my ($page, $sql, $result, $rows, $row, $i);
  my $show_rows   = $global_var_href->{'show_rows'};
  my $start_row   = param('start_row');
  my $keyword     = param('blob_keyword');
  my $session     = $global_var_href->{'session'};            # get session handle
  my $user_id     = $session->param(-name=>'user_id');
  my ($mice_in_cart, $unquoted_keyword);
  my @sql_parameters;
  my @mice;
  my @sub_keywords;
  my ($blob_name_like, $blob_comment_like, $sub_keyword);

  @sub_keywords = split(/\W/, $keyword);

  foreach $sub_keyword (@sub_keywords) {
     $blob_name_like    .= qq(and blob_name    like '%$sub_keyword%' );
     $blob_comment_like .= qq(and blob_comment like '%$sub_keyword%' );
  }

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  $page = start_form(-action => url())
          . h2("Files by keywords "
               . "&nbsp;&nbsp;&nbsp;&nbsp;["
               . small("Search files by keyword: ")
               . textfield(-name => "blob_keyword", -size=>"20", -maxlength=>"30", -title=>"enter keyword")
               . submit(-name => "choice", -value=>"Search files by keyword")
               . "]"
            )
          . end_form()
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select blob_id, blob_name, blob_content_type, blob_mime_type, length(UNCOMPRESS(blob_itself)) as file_size, blob_upload_datetime, blob_upload_user, blob_comment
            from   $blob_database.blob_data
            where  (1 $blob_name_like)
                   or
                   (1 $blob_comment_like)
            order  by blob_name
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no matings found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No file(s) found that match your keyword \"$keyword\".");
    return $page;
  }

  # ... otherwise continue with matings table

  # first generate table header ...
  $page .= h3("Found $rows file(s) containing \"$keyword\" in file name or file comment. " )
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20files%20by%20keyword&keyword=$keyword" . '&start_row=1'}, '[first]'):'[first]')
                 . "&nbsp;"
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20files%20by%20keyword&keyword=$keyword" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
                 . "&nbsp;"
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20files%20by%20keyword&keyword=$keyword" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
                 . "&nbsp; "
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20files%20by%20keyword&keyword=$keyword" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
                )
              :''
             )
           . start_table( {-border=>"1", -summary=>"files_by_keyword"})
           . Tr(
               th({-align=>'left'},  "file name"),
               th("file type"),
               th("file size"),
               th("file uploaded by"),
               th("file uploaded at"),
               th("file comment")
             );

  # ... then loop over all matings
  for ($i=0; $i<$rows; $i++) {
      if ($i+1 < $start_row )              { next; }               # skip all rows with (row index < $start_row)
      if ($i+1 >= $start_row + $show_rows) { last; }               # skip all rows with (row index > $start_row+$show_rows): exit loop

      $row = $result->[$i];

      # generate the current mating row
      $page .= Tr(
                 td({-align=>'left'},   a({-href=>"$url?choice=view_file_info&file_id=$row->{'blob_id'}"}, $row->{'blob_name'})),
                 td({-align=>'center'}, $row->{'blob_content_type'}),
                 td({-align=>'center'}, round_number($row->{'file_size'} / 1024, 0) . ' Kb'),
                 td({-align=>'center'}, get_user_name_by_id($global_var_href, $row->{'blob_upload_user'})),
                 td({-align=>'center'}, format_datetime2simpledate($row->{'blob_upload_datetime'})),
                 td({-align=>'left'},   pre($row->{'blob_comment'}))
               );
  }

  $page .= end_table();

  return $page;
}
# end of find_blob_by_keyword()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE016 find_matings_by_project():                   find matings by project
sub find_matings_by_project {                            my $sr_name = 'SR_VIE016';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($active_only_sql, $active_only);
  my $project   = param('all_projects');                 # the project id
  my $show_rows = $global_var_href->{'show_rows'};
  my $start_row = param('start_row');
  my @sql_parameters;

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  # check input: is project id given? is it a number?
  if (!param('all_projects') || param('all_projects') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please choose a project"));
     return $page;
  }

  # user wants to see active matings only: generate SQL condition
  if (param('active_only') && param('active_only') eq 'y') {
     $active_only = 'y';

     # restrict to matings whose mating_matingend_datetime is at least 21 days before current date
     $active_only_sql = "and ( (mating_matingend_datetime IS NULL)
                               OR
                               (mating_matingend_datetime >= \'" . get_sql_time_by_given_current_age('21') . "')
                              )";
  }
  else {          # otherwise skip age condition from SQL
     $active_only     = 'n';
     $active_only_sql = '';
  }

  $page = start_form(-action => url())
          . h2("Mating overview filtered by project \"" . get_project_name_by_id($global_var_href, $project) . "\" " . a({-href=>"$url?choice=search%20by%20mating%20project&active_only=$active_only&all_projects=$project" , -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'}))
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
            where  project_id = ?
            $active_only_sql
            group  by mating_id
            order  by mating_id desc
           );

  @sql_parameters = ($project);

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no matings found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No matings found for project \"" . get_project_name_by_id($global_var_href, $project) . "\" ");
    return $page;
  }

  # ... otherwise continue with matings table

  # first generate table header ...
  $page .= h3("Found $rows " . (($active_only eq 'y')?"active ":"") . "matings. [Select: " . a({-href=>"$url?choice=search%20by%20mating%20project&active_only=n&all_projects=$project"}, "all matings") . "&nbsp;or&nbsp;" . a({-href=>"$url?choice=search%20by%20mating%20project&active_only=y&all_projects=$project"}, "only active matings"). "]")
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20mating%20project&active_only=$active_only&all_projects=$project" . '&start_row=1'}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20mating%20project&active_only=$active_only&all_projects=$project" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20mating%20project&active_only=$active_only&all_projects=$project" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20mating%20project&active_only=$active_only&all_projects=$project" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
              )
              :''
             )
           . start_table( {-border=>"1", -summary=>"mating_overview"})
           . Tr( {-align=>'center'},
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
                 td(a({-href=>"$url?choice=mating_view&mating_id=$row->{'mating_id'}", -title=>"click for mating details"}, "mating $row->{'mating_id'}")
                 ),
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
# end of find_matings_by_project()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_VIE017 find_matings_by_line():                      find matings by line
sub find_matings_by_line {                               my $sr_name = 'SR_VIE017';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my ($active_only_sql, $active_only);
  my $line      = param('mating_line');
  my $show_rows = $global_var_href->{'show_rows'};
  my $start_row = param('start_row');
  my @sql_parameters;

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  # check input: is line id given? is it a number?
  if (!param('mating_line') || param('mating_line') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: please choose a line"));
     return $page;
  }

  # user wants to see active matings only: generate SQL condition
  if (param('active_only') && param('active_only') eq 'y') {
     $active_only = 'y';

     # restrict to matings whose mating_matingend_datetime is at least 21 days before current date
     $active_only_sql = "and ( (mating_matingend_datetime IS NULL)
                               OR
                               (mating_matingend_datetime >= \'" . get_sql_time_by_given_current_age('21') . "')
                              )";
  }
  else {          # otherwise skip age condition from SQL
     $active_only     = 'n';
     $active_only_sql = '';
  }

  $page = start_form(-action => url())
          . h2("Mating overview filtered by line \"" . get_line_name_by_id($global_var_href, $line) . "\" " . a({-href=>"$url?choice=search%20by%20mating%20line&active_only=$active_only&mating_line=$line" , -title=>"reload page"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'}))
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
            where  mating_line = ?
            $active_only_sql
            group  by mating_id
            order  by mating_id desc
           );

  @sql_parameters = ($line);

  # do the actual SQL query: $result is a reference on the result set (see do_multi_result_sql_query {} definition), $rows is the number of results.
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no matings found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No matings found for line \"" . get_line_name_by_id($global_var_href, $line) . "\" ");
    return $page;
  }

  # ... otherwise continue with matings table

  # first generate table header ...
  $page .= h3("Found $rows " . (($active_only eq 'y')?"active ":"") . "matings. [Select: " . a({-href=>"$url?choice=search%20by%20mating%20line&active_only=n&mating_line=$line"}, "all matings") . "&nbsp;or&nbsp;" . a({-href=>"$url?choice=search%20by%20mating%20line&active_only=y&mating_line=$line"}, "only active matings"). "]")
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20mating%20line&active_only=$active_only&mating_line=$line" . '&start_row=1'}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20mating%20line&active_only=$active_only&mating_line=$line" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20mating%20line&active_only=$active_only&mating_line=$line" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20mating%20line&active_only=$active_only&mating_line=$line" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
              )
              :''
             )
           . start_table( {-border=>"1", -summary=>"mating_overview"})
           . Tr( {-align=>'center'},
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
                 td(a({-href=>"$url?choice=mating_view&mating_id=$row->{'mating_id'}", -title=>"click for mating details"}, "mating $row->{'mating_id'}")
                 ),
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
# end of find_matings_by_line()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA018 find_mice_by_strain:                         find mice by strain
sub find_mice_by_strain {                                my $sr_name = 'SR_SEA018';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my $show_rows    = $global_var_href->{'show_rows'};
  my $start_row    = param('start_row');
  my $strain_id    = param('strain');
  my $include_dead = param('include_dead_strain');
  my $sex_color    = {'m' => $global_var_href->{'bg_color_male'}, 'f' => $global_var_href->{'bg_color_female'}};
  my @parameters   = param();                            # read all CGI parameter keys
  my ($parameter, $strain_name, $include_dead_sql);
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;
  my ($cart_mice, $cart_mouse);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';

  # check input: is strain id given? is it a number?
  if (!param('strain') || param('strain') !~ /^[0-9]+$/) {
     $page = p({-class=>"red"}, b("Error: Please give a valid strain."));
     return $page;
  }

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href)
              . hr();
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add all mice to cart") {
     $page .= add_all_to_cart($global_var_href)
              . hr();
  }

  # delete the all_mice fields
  Delete('all_mice');

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  # if "include dead" box checked: generate SQL condition
  if (param('include_dead_strain') && param('include_dead_strain') == 1) {
     $include_dead_sql = '';
  }
  else {
     $include_dead = 0;
     $include_dead_sql = qq(and mouse_deathorexport_datetime IS NULL);
  }

  # get experiment name
  $strain_name = get_strain_name_by_id($global_var_href, $strain_id);

  $page = h2("Find mice by strain")
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_is_gvo,
                   mouse_comment, location_id, location_room, location_rack, cage_id,
                   mouse_birth_datetime, mouse_deathorexport_datetime
            from   mice
                   join mice2cages      on      m2c_mouse_id = mouse_id
                   join cages           on       m2c_cage_id = cage_id
                   join cages2locations on       c2l_cage_id = m2c_cage_id
                   join locations       on   c2l_location_id = location_id
                   join mouse_strains   on      mouse_strain = strain_id
                   join mouse_lines     on        mouse_line = line_id
            where  mouse_strain = ?
                   and c2l_datetime_to IS NULL
                   and m2c_datetime_to IS NULL
                   $include_dead_sql
                   $restrict_to_cart_sql
           );

  @sql_parameters = ($strain_id);
  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no matings found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No mice found for given strain \"$strain_name\" $restrict_to_cart_notice.");
    return $page;
  }

  # ... otherwise continue with result table

  $page .= h3("Found $rows " . (($rows == 1)?'mouse':'mice' ) . " in experiment \"$strain_name\"  $restrict_to_cart_notice")

           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20strain&strain=$strain_id&include_dead_strain=$include_dead" . "&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=1'}, '[first]'):'[first]')
                 . "&nbsp;"
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20strain&strain=$strain_id&include_dead_strain=$include_dead" . "&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
                 . "&nbsp;"
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20strain&strain=$strain_id&include_dead_strain=$include_dead" . "&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
                 . "&nbsp; "
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20strain&strain=$strain_id&include_dead_strain=$include_dead" . "&restrict_to_cart=" . param('restrict_to_cart') . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
                )
              :''
             )

           . start_form(-action=>url(), -name=>"myform")
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
               th("comment")
             );

  # loop over all mice
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # we store every mouse (even those we don't display): put all into cart
     $page .= hidden(-name=>'all_mice', -value=>$row->{'mouse_id'});

     # skip all rows with (row index < $start_row)
     if ($i+1 < $start_row )              { next; }

     # skip all rows with (row index > $start_row+$show_rows): exit loop
     if ($i+1 >= $start_row + $show_rows) { next; }

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
                td(format_datetime2simpledate($row->{'mouse_deathorexport_datetime'})),
                td({-title=>$first_gene_name}, defined($first_gene_name)?$first_genotype:''),
                td($row->{'strain_name'}),
                td('&nbsp;' . $row->{'line_name'} . '&nbsp;'),
                td($row->{'mouse_comment'})
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

  $page .= submit(-name => "job", -value=>"Add selected mice to cart") . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"Add all mice to cart", -title=>"add complete multi-page result set to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")                . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")       . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mice_by_strain()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_SEA019 find_line_by_keyword:                        find line by keyword
sub find_line_by_keyword {                               my $sr_name = 'SR_SEA019';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my ($page, $sql, $result, $rows, $row, $i);
  my $show_rows   = $global_var_href->{'show_rows'};
  my $start_row   = param('start_row');
  my $keyword     = param('line_keyword');
  my $session     = $global_var_href->{'session'};            # get session handle
  my $user_id     = $session->param(-name=>'user_id');
  my @sql_parameters;
  my @mice;
  my @sub_keywords;
  my ($line_name_like, $line_long_name_like, $line_comment_like, $sub_keyword, $unquoted_keyword);

  @sub_keywords = split(/\W/, $keyword);

  foreach $sub_keyword (@sub_keywords) {
     $line_name_like      .= qq(and line_name      like '%$sub_keyword%' );
     $line_comment_like   .= qq(and line_comment   like '%$sub_keyword%' );
     $line_long_name_like .= qq(and line_long_name like '%$sub_keyword%' );
  }

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
  }

  $page = start_form(-action => url())
          . h2("Lines by keywords "
               . "&nbsp;&nbsp;&nbsp;&nbsp;["
               . small("Search lines by keyword: ")
               . textfield(-name => "line_keyword", -size=>"20", -maxlength=>"30", -title=>"enter keyword")
               . submit(-name => "choice", -value=>"Search lines by keyword")
               . "]"
            )
          . end_form()
          . hr();

  # the actual SQL statement is stored to a string for better isolation, debugging or whatever purpose ...
  $sql = qq(select line_id, line_name, line_long_name, line_comment
            from   mouse_lines
            where  (1 $line_name_like)
                   or
                   (1 $line_comment_like)
                   or
                   (1 $line_long_name_like)
            order  by line_name asc
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no matings found at all: tell and quit
  unless ($rows > 0) {
    $page .= p("No line(s) found that match your keyword(s) \"$keyword\".");
    return $page;
  }

  # ... otherwise continue with result table

  # first generate table header ...
  $page .= h3("Found $rows line(s) containing \"$keyword\" in line name or line comment. " )
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20lines%20by%20keyword&line_keyword=$keyword" . '&start_row=1'}, '[first]'):'[first]')
                 . "&nbsp;"
                 . (($start_row > 1)?a({-href=>"$url?choice=search%20lines%20by%20keyword&line_keyword=$keyword" . '&start_row=' . ($start_row - $show_rows)}, '[previous]'):'[previous]')
                 . "&nbsp;"
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20lines%20by%20keyword&line_keyword=$keyword" . '&start_row=' . ($start_row + $show_rows)}, '[next]'):'[next]')
                 . "&nbsp; "
                 . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20lines%20by%20keyword&line_keyword=$keyword" . '&start_row=' . ($rows - $show_rows + 1)}, '[last]'):'[last]')
                )
              :''
             )
           . start_table( {-border=>"1", -summary=>"lines_by_keyword"})
           . Tr(
               th("line name"),
               th("line long name"),
               th("line comment")
             );

  # ... then loop over all lines
  for ($i=0; $i<$rows; $i++) {
      if ($i+1 < $start_row )              { next; }               # skip all rows with (row index < $start_row)
      if ($i+1 >= $start_row + $show_rows) { last; }               # skip all rows with (row index > $start_row+$show_rows): exit loop

      $row = $result->[$i];

      # generate the current row
      $page .= Tr(
                 td({-align=>'left'},   a({-href=>"$url?choice=line_view&line_id=$row->{'line_id'}", -title=>"click to view line details"}, $row->{'line_name'})),
                 td({-align=>'center'}, $row->{'line_long_name'}),
                 td({-align=>'center'}, $row->{'line_comment'}),
               );
  }

  $page .= end_table();

  return $page;
}
# end of find_line_by_keyword()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA020 find_mice_by_room                            find mice by room
sub find_mice_by_room {                                    my $sr_name = 'SR_SEA020';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my ($page, $sql, $result, $rows, $row, $i);
  my ($id);
  my $room        = param('room');
  my $sort_column = param('sort_by');
  my $sort_order  = param('sort_order');
  my $start_row   = param('start_row');
  my $show_rows   = $global_var_href->{'show_rows'};
  my $url         = url();
  my $rev_order   = {'asc' => 'desc', 'desc' => 'asc'};                  # toggle table
  my $sex_color   = {'m' => $global_var_href->{'bg_color_male'},
                     'f' => $global_var_href->{'bg_color_female'}};
  my @id_list;
  my @sql_id_list;
  my @parameters = param();                                 # read all CGI parameter keys
  my $parameter;
  my ($current_mating, $short_comment);
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;
  my ($cart_mice, $cart_mouse);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';

  # hide real database column names from user (security issue): use translation hash table
  # left (key): identifier used in HTML form; right (value): database column name
  my $columns  = {'id'  => 'mouse_id', 'earmark' => 'mouse_earmark', 'dob' => 'mouse_birth_datetime', 'genotype' => 'm2g_genotype',
                  'sex' => 'mouse_sex', 'strain' => 'strain_name',  'line' => 'line_name',            'location' => 'cage_name',
                  'dod' => 'mouse_deathorexport_datetime',          'cage' => 'cage_id',              'rack'     => 'concat(location_room,location_rack)'};

  # check if list of mouse ids given
  if (!param('room')) {
     $page = p({-class=>"red"}, b("Error: Please select a room."));
     return $page;
  }

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
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

  $page .= h3(qq(Your search by room))
           . hr();

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href)
              . hr();
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add all mice to cart") {
     $page .= add_all_to_cart($global_var_href)
              . hr();
  }

  # delete the all_mice fields
  Delete('all_mice');

  $sql = qq(select distinct mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
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
            where  location_room = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
                   $restrict_to_cart_sql
            order  by $columns->{$sort_column} $sort_order
           );

  @sql_parameters = ($room);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mice found having ids from the list
  unless ($rows > 0) {
     $page .= p("No mice found in room \"$room\" $restrict_to_cart_notice.");
     return $page;
  }

  $page .= p(b("Found $rows " . (($rows == 1)?'mouse':'mice' ). " in room \"$room\""))
           . p(join(',', @sql_id_list))
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20room&room=" . $room . '&start_row=1' . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20room&room=" . $room . '&start_row=' . ($start_row - $show_rows) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20room&room=" . $room . '&start_row=' . ($start_row + $show_rows) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20room&room=" . $room . '&start_row=' . ($rows - $show_rows + 1) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[last]'):'[last]')
              )
              :''
             )
           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th(a({-href=>"$url?choice=search%20by%20room&room=" . $room . "&sort_order=$rev_order->{$sort_order}&sort_by=id&restrict_to_cart=" . param('restrict_to_cart'),       -title=>"click to sort by mouse id, click again to change sort order"},       "mouse ID")      ),
               th(a({-href=>"$url?choice=search%20by%20room&room=" . $room . "&sort_order=$rev_order->{$sort_order}&sort_by=earmark&restrict_to_cart=" . param('restrict_to_cart'),  -title=>"click to sort by earmark, click again to change sort order"},        "ear")           ),
               th(a({-href=>"$url?choice=search%20by%20room&room=" . $room . "&sort_order=$rev_order->{$sort_order}&sort_by=sex&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by sex, click again to change sort order"},            "sex")           ),
               th(a({-href=>"$url?choice=search%20by%20room&room=" . $room . "&sort_order=$rev_order->{$sort_order}&sort_by=dob&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by date of birth, click again to change sort order"},  "born")          ),
               th(span({-title=>"living mice: current age; dead mice: age at day of death"}, "age")),
               th(a({-href=>"$url?choice=search%20by%20room&room=" . $room . "&sort_order=$rev_order->{$sort_order}&sort_by=dod&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by date of death, click again to change sort order"},  "death")         ),
               th(a({-href=>"$url?choice=search%20by%20room&room=" . $room . "&sort_order=$rev_order->{$sort_order}&sort_by=genotype&restrict_to_cart=" . param('restrict_to_cart'), -title=>"click to sort by genotype, click again to change sort order"},       "genotype")      ),
               th(a({-href=>"$url?choice=search%20by%20room&room=" . $room . "&sort_order=$rev_order->{$sort_order}&sort_by=strain&restrict_to_cart=" . param('restrict_to_cart'),   -title=>"click to sort by strain, click again to change sort order"},         "strain")        ),
               th(a({-href=>"$url?choice=search%20by%20room&room=" . $room . "&sort_order=$rev_order->{$sort_order}&sort_by=line&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by line, click again to change sort order"},           "line")          ),
               th(a({-href=>"$url?choice=search%20by%20room&room=" . $room . "&sort_order=$rev_order->{$sort_order}&sort_by=rack&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by rack, click again to change sort order"},           "room/rack")
                . a({-href=>"$url?choice=search%20by%20room&room=" . $room . "&sort_order=$rev_order->{$sort_order}&sort_by=cage&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by cage, click again to change sort order"},           "cage")
               ),
               th("comment (shortened)")
             );

  # loop over all mice that match to the id list
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # we store every mouse (even those we don't display): put all into cart
     $page .= hidden(-name=>'all_mice', -value=>$row->{'mouse_id'});

     # skip all rows with (row index < $start_row)
     if ($i+1 < $start_row )              { next; }

     # skip all rows with (row index > $start_row+$show_rows): exit loop
     if ($i+1 >= $start_row + $show_rows) { next; }

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     # shorten comment to fit on page
     if ($row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
     }
     else {
        $short_comment = $row->{'mouse_comment'};
     }

     $short_comment =~ s/^'(.*)'$/$1/g;

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current mouse
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
                ),
                td({-align=>'left'},
                   ((defined($current_mating))
                    ?"(in mating $current_mating) "
                    :''
                   )
                   . $short_comment
                )
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

  $page .= submit(-name => "job", -value=>"Add selected mice to cart") . '&nbsp;&nbsp;&nbsp;' . submit(-name => "job", -value=>"Add all mice to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")                . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")       . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mice_by_room
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_SEA021 find_mice_by_area                            find mice by area
sub find_mice_by_area {                                  my $sr_name = 'SR_SEA021';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my ($page, $sql, $result, $rows, $row, $i);
  my ($id);
  my $area        = param('area');
  my $sort_column = param('sort_by');
  my $sort_order  = param('sort_order');
  my $start_row   = param('start_row');
  my $show_rows   = $global_var_href->{'show_rows'};
  my $url         = url();
  my $rev_order   = {'asc' => 'desc', 'desc' => 'asc'};                  # toggle table
  my $sex_color   = {'m' => $global_var_href->{'bg_color_male'},
                     'f' => $global_var_href->{'bg_color_female'}};
  my @id_list;
  my @sql_id_list;
  my @parameters = param();                                 # read all CGI parameter keys
  my $parameter;
  my ($current_mating, $short_comment);
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;
  my ($cart_mice, $cart_mouse);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';

  # hide real database column names from user (security issue): use translation hash table
  # left (key): identifier used in HTML form; right (value): database column name
  my $columns  = {'id'  => 'mouse_id', 'earmark' => 'mouse_earmark', 'dob' => 'mouse_birth_datetime', 'genotype' => 'm2g_genotype',
                  'sex' => 'mouse_sex', 'strain' => 'strain_name',  'line' => 'line_name',            'location' => 'cage_name',
                  'dod' => 'mouse_deathorexport_datetime',          'cage' => 'cage_id',              'rack'     => 'concat(location_room,location_rack)'};

  # check if area given
  if (!param('area')) {
     $page = p({-class=>"red"}, b("Error: Please select an area."));
     return $page;
  }

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
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

  $page .= h3(qq(Your search by area))
           . hr();

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href)
              . hr();
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add all mice to cart") {
     $page .= add_all_to_cart($global_var_href)
              . hr();
  }

  # delete the all_mice fields
  Delete('all_mice');

  $sql = qq(select distinct mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
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
            where  location_subbuilding = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
                   $restrict_to_cart_sql
            order  by $columns->{$sort_column} $sort_order
           );

  @sql_parameters = ($area);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mice found having ids from the list
  unless ($rows > 0) {
     $page .= p("No mice found in area \"$area\" $restrict_to_cart_notice.");
     return $page;
  }

  $page .= p(b("Found $rows " . (($rows == 1)?'mouse':'mice' ). " in area \"$area\""))
           . p(join(',', @sql_id_list))
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20area&area=" . $area . '&start_row=1' . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20area&area=" . $area . '&start_row=' . ($start_row - $show_rows) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20area&area=" . $area . '&start_row=' . ($start_row + $show_rows) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20area&area=" . $area . '&start_row=' . ($rows - $show_rows + 1) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[last]'):'[last]')
              )
              :''
             )
           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th(a({-href=>"$url?choice=search%20by%20area&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=id&restrict_to_cart=" . param('restrict_to_cart'),       -title=>"click to sort by mouse id, click again to change sort order"},       "mouse ID")      ),
               th(a({-href=>"$url?choice=search%20by%20area&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=earmark&restrict_to_cart=" . param('restrict_to_cart'),  -title=>"click to sort by earmark, click again to change sort order"},        "ear")           ),
               th(a({-href=>"$url?choice=search%20by%20area&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=sex&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by sex, click again to change sort order"},            "sex")           ),
               th(a({-href=>"$url?choice=search%20by%20area&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=dob&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by date of birth, click again to change sort order"},  "born")          ),
               th(span({-title=>"living mice: current age; dead mice: age at day of death"}, "age")),
               th(a({-href=>"$url?choice=search%20by%20area&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=dod&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by date of death, click again to change sort order"},  "death")         ),
               th(a({-href=>"$url?choice=search%20by%20area&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=genotype&restrict_to_cart=" . param('restrict_to_cart'), -title=>"click to sort by genotype, click again to change sort order"},       "genotype")      ),
               th(a({-href=>"$url?choice=search%20by%20area&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=strain&restrict_to_cart=" . param('restrict_to_cart'),   -title=>"click to sort by strain, click again to change sort order"},         "strain")        ),
               th(a({-href=>"$url?choice=search%20by%20area&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=line&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by line, click again to change sort order"},           "line")          ),
               th(a({-href=>"$url?choice=search%20by%20area&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=rack&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by rack, click again to change sort order"},           "room/rack")
                . a({-href=>"$url?choice=search%20by%20area&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=cage&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by cage, click again to change sort order"},           "cage")
               ),
               th("comment (shortened)")
             );

  # loop over all mice that match to the id list
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # we store every mouse (even those we don't display): put all into cart
     $page .= hidden(-name=>'all_mice', -value=>$row->{'mouse_id'});

     # skip all rows with (row index < $start_row)
     if ($i+1 < $start_row )              { next; }

     # skip all rows with (row index > $start_row+$show_rows): exit loop
     if ($i+1 >= $start_row + $show_rows) { next; }

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     # shorten comment to fit on page
     if ($row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
     }
     else {
        $short_comment = $row->{'mouse_comment'};
     }

     $short_comment =~ s/^'(.*)'$/$1/g;

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current mouse
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
                ),
                td({-align=>'left'},
                   ((defined($current_mating))
                    ?"(in mating $current_mating) "
                    :''
                   )
                   . $short_comment
                )
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

  $page .= submit(-name => "job", -value=>"Add selected mice to cart") . '&nbsp;&nbsp;&nbsp;' . submit(-name => "job", -value=>"Add all mice to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")                . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")       . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mice_by_area
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_SEA022 find_children_of_mouse                       find children of a given mouse
sub find_children_of_mouse {                             my $sr_name = 'SR_SEA022';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my ($page, $sql, $result, $rows, $row, $i);
  my ($line_name, $id);
  my $mouse_id    = param('mouse_id');
  my $url         = url();
  my $sex_color   = {'m' => $global_var_href->{'bg_color_male'},
                     'f' => $global_var_href->{'bg_color_female'}};
  my @parameters = param();                                 # read all CGI parameter keys
  my $parameter;
  my ($current_mating, $short_comment, $old_litter_id);
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;

  # check input first: a mouse id must be provided and it has to be an 8 digit number: exit on failure
  if (!param('mouse_id') || param('mouse_id') !~ /^[0-9]{8}$/) {
     &error_message_and_exit($global_var_href, "invalid mouse id (must be an 8 digit number).", $sr_name . "-" . __LINE__);
  }

  $page .= h3(qq(All children of mouse "$mouse_id"))
           . hr();

  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
                   dr1.death_reason_name as how, dr2.death_reason_name as why, litter_id, litter_in_mating, litter_born_datetime
            from   mice
                   join litters            on          mouse_litter_id = litter_id
                   join mouse_strains      on             mouse_strain = strain_id
                   join mouse_lines        on               mouse_line = line_id
                   join mice2cages         on                 mouse_id = m2c_mouse_id
                   join cages2locations    on              m2c_cage_id = c2l_cage_id
                   join locations          on              location_id = c2l_location_id
                   join cages              on                  cage_id = c2l_cage_id
                   join death_reasons dr1  on  mouse_deathorexport_how = dr1.death_reason_id
                   join death_reasons dr2  on  mouse_deathorexport_why = dr2.death_reason_id
                   left join mice2genes    on                 mouse_id = m2g_mouse_id
            where  mouse_litter_id in (select l2p_litter_id
                                       from   litters2parents
                                       where  l2p_parent_id = ?
                                      )
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
            order  by litter_born_datetime asc
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mice found having ids from the list
  unless ($rows > 0) {
     $page .= p("No children found for mouse $mouse_id");
     return $page;
  }

  $page .= p(b("Found $rows " . (($rows == 1)?'child':'children' ). " of mouse $mouse_id"))
           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th(a({-href=>"$url?choice=find_children_of_mouse&mouse_id=" . $mouse_id},     "mouse ID")      ),
               th(a({-href=>"$url?choice=find_children_of_mouse&mouse_id=" . $mouse_id},     "ear")           ),
               th(a({-href=>"$url?choice=find_children_of_mouse&mouse_id=" . $mouse_id},     "sex")           ),
               th(a({-href=>"$url?choice=find_children_of_mouse&mouse_id=" . $mouse_id},     "born")          ),
               th(span({-title=>"living mice: current age; dead mice: age at day of death"}, "age")           ),
               th(a({-href=>"$url?choice=find_children_of_mouse&mouse_id=" . $mouse_id},     "death")         ),
               th(a({-href=>"$url?choice=find_children_of_mouse&mouse_id=" . $mouse_id},     "genotype")      ),
               th(a({-href=>"$url?choice=find_children_of_mouse&mouse_id=" . $mouse_id},     "strain")        ),
               th(a({-href=>"$url?choice=find_children_of_mouse&mouse_id=" . $mouse_id},     "line")          ),
               th(a({-href=>"$url?choice=find_children_of_mouse&mouse_id=" . $mouse_id},     "room/rack")
                . a({-href=>"$url?choice=find_children_of_mouse&mouse_id=" . $mouse_id},     "cage")
               ),
               th("comment (shortened)")
             );

  # loop over all mice that match to the id list
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     if ($old_litter_id != $row->{'litter_id'}) {
        $page .= Tr(
                   td({-colspan=>13}, b("litter " . a({-href=>"$url?choice=litter_view&litter_id=$row->{'litter_id'}", -title=>"click for litter details"}, $row->{'litter_id'})))
                 );
     }

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     # shorten comment to fit on page
     if ($row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
     }
     else {
        $short_comment = $row->{'mouse_comment'};
     }

     $short_comment =~ s/^'(.*)'$/$1/g;

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current mouse
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
                ),
                td({-align=>'left'},
                   ((defined($current_mating))
                    ?"(in mating $current_mating) "
                    :''
                   )
                   . $short_comment
                )
              );

     $old_litter_id = $row->{'litter_id'};
  }

  $page .= end_table()
           . p();

  # store CGI parameters in hidden fields. Yes, I know, there are better ways to do this, but input from hidden fields will be checked
  foreach $parameter (@parameters) {
     unless ($parameter eq 'mouse_select' || $parameter eq 'job') {
        $page .= hidden(-name=>$parameter, -value=>param("$parameter")) . "\n";
     }
  }

  $page .= submit(-name => "job", -value=>"Add selected mice to cart") . '&nbsp;&nbsp;&nbsp;' . submit(-name => "job", -value=>"Add all mice to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")                . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")       . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_children_of_mouse
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_SEA023 find_mice_by_line_and_area                   find mice by line and area
sub find_mice_by_line_and_area {                         my $sr_name = 'SR_SEA023';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'}; # get session handle
  my ($page, $sql, $result, $rows, $row, $i);
  my ($id);
  my $area        = param('area_for_line');
  my $line        = param('line_for_area');
  my $sort_column = param('sort_by');
  my $sort_order  = param('sort_order');
  my $start_row   = param('start_row');
  my $show_rows   = $global_var_href->{'show_rows'};
  my $url         = url();
  my $rev_order   = {'asc' => 'desc', 'desc' => 'asc'};                  # toggle table
  my $sex_color   = {'m' => $global_var_href->{'bg_color_male'},
                     'f' => $global_var_href->{'bg_color_female'}};
  my @id_list;
  my @sql_id_list;
  my @parameters = param();                                 # read all CGI parameter keys
  my $parameter;
  my ($current_mating, $short_comment);
  my ($first_gene_name, $first_genotype);
  my @sql_parameters;
  my ($cart_mice, $cart_mouse);
  my $sql_mouse_list;
  my @cart_mouse_list;
  my @purged_cart_mouse_list;
  my $restrict_to_cart_notice = '';
  my $restrict_to_cart_sql    = '';

  # hide real database column names from user (security issue): use translation hash table
  # left (key): identifier used in HTML form; right (value): database column name
  my $columns  = {'id'  => 'mouse_id', 'earmark' => 'mouse_earmark', 'dob' => 'mouse_birth_datetime', 'genotype' => 'm2g_genotype',
                  'sex' => 'mouse_sex', 'strain' => 'strain_name',  'line' => 'line_name',            'location' => 'cage_name',
                  'dod' => 'mouse_deathorexport_datetime',          'cage' => 'cage_id',              'rack'     => 'concat(location_room,location_rack)'};

  # check if area given
  if (!param('area_for_line')) {
     $page = p({-class=>"red"}, b("Error: Please select an area."));
     return $page;
  }

  # check if area given
  if (!param('line_for_area')) {
     $page = p({-class=>"red"}, b("Error: Please select a mouse line"));
     return $page;
  }

  # check input: is search restricted to cart?
  if (defined(param('restrict_to_cart')) && param('restrict_to_cart') == 1) {
     $restrict_to_cart_notice = ' (restricted to mice in cart)';

     # read current cart content from session ...
     $cart_mice = $session->param('cart');

     # if there are mice in session, check cart content for being mouse ids ...
     if (defined($cart_mice) and $cart_mice ne '') {
        @cart_mouse_list = split(/\W/, $cart_mice);
        foreach $cart_mouse (@cart_mouse_list) {
          if ($cart_mouse =~ /^[0-9]{8}$/) {
             push(@purged_cart_mouse_list, $cart_mouse);
          }
        }
     }

     # make the list non-redundant
     @purged_cart_mouse_list = unique_list(@purged_cart_mouse_list);

     $sql_mouse_list = qq(') . join(qq(','), @purged_cart_mouse_list) . qq(');

     $restrict_to_cart_sql = qq( and  mouse_id in ($sql_mouse_list));
  }

  # check input: is start row given? is it a number?
  if (!param('start_row') || param('start_row') !~ /^[0-9]+$/) {
     $start_row = 1;
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

  $page .= h3(qq(Your search for mice by line and area))
           . hr();

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add selected mice to cart") {
     $page .= add_to_cart($global_var_href)
              . hr();
  }

  # add selected mice to cart if requested
  if (defined(param('job')) && param('job') eq "Add all mice to cart") {
     $page .= add_all_to_cart($global_var_href)
              . hr();
  }

  # delete the all_mice fields
  Delete('all_mice');

  $sql = qq(select distinct mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, mouse_comment,
                   mouse_birth_datetime, mouse_deathorexport_datetime, location_room, location_rack, cage_id,
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
            where  location_subbuilding = ?
                   and mouse_line       = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
                   $restrict_to_cart_sql
            order  by $columns->{$sort_column} $sort_order
           );

  @sql_parameters = ($area, $line);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # no mice found having ids from the list
  unless ($rows > 0) {
     $page .= p("No " . get_line_name_by_id($global_var_href, $line) . " mice found in area \"$area\" $restrict_to_cart_notice.");
     return $page;
  }

  $page .= p(b("Found $rows " . get_line_name_by_id($global_var_href, $line) . " " . (($rows == 1)?'mouse':'mice' ). " in area \"$area\""))
           . p(join(',', @sql_id_list))
           . (($rows > $show_rows)
              ?p(b("Browse pages: ")
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20line%20and%20area&line_for_area=$line&area_for_line=" . $area . '&start_row=1' . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[first]'):'[first]')
               . "&nbsp;"
               . (($start_row > 1)?a({-href=>"$url?choice=search%20by%20line%20and%20area&line_for_area=$line&area_for_line=" . $area . '&start_row=' . ($start_row - $show_rows) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[previous]'):'[previous]')
               . "&nbsp;"
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20line%20and%20area&line_for_area=$line&area_for_line=" . $area . '&start_row=' . ($start_row + $show_rows) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[next]'):'[next]')
               . "&nbsp; "
               . (($start_row + $show_rows <= $rows)?a({-href=>"$url?choice=search%20by%20line%20and%20area&line_for_area=$line&area_for_line=" . $area . '&start_row=' . ($rows - $show_rows + 1) . "&sort_order=$sort_order&sort_by=$sort_column&restrict_to_cart=" . param('restrict_to_cart')}, '[last]'):'[last]')
              )
              :''
             )
           . start_form(-action=>url(), -name=>"myform")
           . start_table( {-border=>1, -summary=>"table"})

           . Tr(
               th(span({-title=>"this is just the table row number"}, "#")),
               th(checkbox(-name=>"checkall", -label=>"", -onClick=>"checkAll(document.myform)", -title=>"select/unselect all")),
               th(a({-href=>"$url?choice=search%20by%20area&line_for_area=$line&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=id&restrict_to_cart=" . param('restrict_to_cart'),       -title=>"click to sort by mouse id, click again to change sort order"},       "mouse ID")      ),
               th(a({-href=>"$url?choice=search%20by%20area&line_for_area=$line&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=earmark&restrict_to_cart=" . param('restrict_to_cart'),  -title=>"click to sort by earmark, click again to change sort order"},        "ear")           ),
               th(a({-href=>"$url?choice=search%20by%20area&line_for_area=$line&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=sex&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by sex, click again to change sort order"},            "sex")           ),
               th(a({-href=>"$url?choice=search%20by%20area&line_for_area=$line&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=dob&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by date of birth, click again to change sort order"},  "born")          ),
               th(span({-title=>"living mice: current age; dead mice: age at day of death"}, "age")),
               th(a({-href=>"$url?choice=search%20by%20area&line_for_area=$line&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=dod&restrict_to_cart=" . param('restrict_to_cart'),      -title=>"click to sort by date of death, click again to change sort order"},  "death")         ),
               th(a({-href=>"$url?choice=search%20by%20area&line_for_area=$line&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=genotype&restrict_to_cart=" . param('restrict_to_cart'), -title=>"click to sort by genotype, click again to change sort order"},       "genotype")      ),
               th(a({-href=>"$url?choice=search%20by%20area&line_for_area=$line&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=strain&restrict_to_cart=" . param('restrict_to_cart'),   -title=>"click to sort by strain, click again to change sort order"},         "strain")        ),
               th(a({-href=>"$url?choice=search%20by%20area&line_for_area=$line&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=line&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by line, click again to change sort order"},           "line")          ),
               th(a({-href=>"$url?choice=search%20by%20area&line_for_area=$line&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=rack&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by rack, click again to change sort order"},           "room/rack")
                . a({-href=>"$url?choice=search%20by%20area&line_for_area=$line&area=" . $area . "&sort_order=$rev_order->{$sort_order}&sort_by=cage&restrict_to_cart=" . param('restrict_to_cart'),     -title=>"click to sort by cage, click again to change sort order"},           "cage")
               ),
               th("comment (shortened)")
             );

  # loop over all mice that match to the id list
  for ($i=0; $i<$rows; $i++) {
     $row = $result->[$i];                # fetch next row

     # we store every mouse (even those we don't display): put all into cart
     $page .= hidden(-name=>'all_mice', -value=>$row->{'mouse_id'});

     # skip all rows with (row index < $start_row)
     if ($i+1 < $start_row )              { next; }

     # skip all rows with (row index > $start_row+$show_rows): exit loop
     if ($i+1 >= $start_row + $show_rows) { next; }

     # check if mouse is currently in mating
     $current_mating = db_is_in_mating($global_var_href, $row->{'mouse_id'});

     # shorten comment to fit on page
     if ($row->{'mouse_comment'} =~ /(^.{20})/) {
        $short_comment = $1 . ' ...';
     }
     else {
        $short_comment = $row->{'mouse_comment'};
     }

     $short_comment =~ s/^'(.*)'$/$1/g;

     # get first genotype
     ($first_gene_name, $first_genotype) = get_first_genotype($global_var_href, $row->{'mouse_id'});

     # add table row for current mouse
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
                ),
                td({-align=>'left'},
                   ((defined($current_mating))
                    ?"(in mating $current_mating) "
                    :''
                   )
                   . $short_comment
                )
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

  $page .= submit(-name => "job", -value=>"Add selected mice to cart") . '&nbsp;&nbsp;&nbsp;' . submit(-name => "job", -value=>"Add all mice to cart")
           . hr()
           . h3("What do you want to do with mice selected above?")
           . submit(-name => "job", -value=>"kill")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"mate")                    . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"genotype")                . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change experiment")   . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"add/change cost centre")  . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"order phenotyping")       . '&nbsp;&nbsp;&nbsp;'
           . submit(-name => "job", -value=>"view phenotyping data")
           . end_form();

  return $page;
}
# end of find_mice_by_line_and_area
#--------------------------------------------------------------------------------------


# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;