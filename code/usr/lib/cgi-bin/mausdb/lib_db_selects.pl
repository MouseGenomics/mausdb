# lib_db_selects.pl - a MausDB subroutine library file                                                                                #
#                                                                                                                                     #
# Subroutines in this file provide database query functions                                                                           #
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
#                                                                                                                                     #
#-------------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                                 #
#-------------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                     #
# SR_DB_001 do_multi_result_sql_query():                 generalized SQL query handler for queries with more than one result          #
# SR_DB_002 do_single_result_sql_query():                generalized SQL query handler for simple queries with only one result (      #
# SR_DB_003 db_stats():                                  returns some statistical numbers of the database                             #
# SR_DB_004 get_lines_popup_menu():                      returns a HTML popup menu of all mouse lines as string                       #
# SR_DB_005 get_projects_popup_menu():                   returns a HTML popup menu of all projects as string                          #
# SR_DB_006 get_father():                                returns father of a given mouse                                              #
# SR_DB_007 get_mother():                                returns mother(s) of a given mouse                                           #
# SR_DB_008 get_mice_in_location():                      returns number of mice in a given location                                   #
# SR_DB_009 get_mice_in_cage():                          returns number of mice in a given cage plus some more details                #
# SR_DB_011 get_strain():                                returns strain id of a given mouse                                           #
# SR_DB_012 get_line():                                  returns line id of a given mouse                                             #
# SR_DB_014 get_gvo_status():                            returns gvo status of a given mouse                                          #
# SR_DB_015 get_location_details_by_id():                returns details on a given location                                          #
# SR_DB_016 get_project_info():                          returns for a given mouse the project the mouse belongs to as string         #
# SR_DB_017 get_gene_info_print():                       returns a HTML genotype table for a given mouse as string                    #
# SR_DB_018 get_strain_name_by_id():                     returns strain name for a given strain id                                    #
# SR_DB_019 get_line_name_by_id():                       returns line name for a given line id                                        #
# SR_DB_020 get_strain_line_info():                      returns strain name and line name for a given mouse                          #
# SR_DB_021 get_gene_info():                             returns a HTML genotype table for a given mouse as a string                  #
# SR_DB_022 get_lines_popup_menu_for_query_builder():    returns a HTML popup menu for mouse lines as string                          #
# SR_DB_023 get_strains_popup_menu():                    returns a HTML popup menu for mouse strains as string                        #
# SR_DB_024 get_locations_popup_menu():                  returns a HTML popup menu for locations as string                            #
# SR_DB_025 write_upload_log():                          write upload log                                                             #
# SR_DB_026 write_log():                                 write access log                                                             #
# SR_DB_027 get_details_for_graph():                     returns HTML string with details for a given mouse for use in graph          #
# SR_DB_028 db_is_in_mating():                           returns if a given mouse is currently in a mating                            #
# SR_DB_029 get_genotypes_popup_menu():                  returns a HTML popup menu of all genotypes as string                         #
# SR_DB_030 get_properties_table():                      returns a HTML properties table for a given mouse as a string                #
# SR_DB_031 get_death_reasons_popup_menus():             returns two HTML popup menus for death reasons (how/why) as string           #
# SR_DB_032 externalID2mouse_id ()                       returns a negative 8 digit MausDB mouse is for a given external ID           #
# SR_DB_033 mouse_id2externalID ()                       returns an external ID on a given negative 8 digit MausDB mouse ID           #
# SR_DB_034 get_breeding_info ()                         returns a HTML breeding table for a given mouse as a string                  #
# SR_DB_035 get_date_of_death ():                        returns date of death of a given mouse                                       #
# SR_DB_036 get_sex ():                                  returns sex of a given mouse                                                 #
# SR_DB_037 get_cages_in_location():                     returns number of occupied cages in a given location                         #
# SR_DB_038 get_location ():                             returns location (rack) of a given mouse                                     #
# SR_DB_039 get_user_projects ():                        returns list of projects for a given user id                                 #
# SR_DB_040 get_cage_location ():                        returns location (rack) of a given cage                                      #
# SR_DB_041 get_cage ():                                 returns cage id for a given mouse                                            #
# SR_DB_042 get_cage_mates():                            returns a list of cagemates for a certain cage at a certain time range       #
# SR_DB_043 get_cage_racks():                            returns a list of racks in which a certain cage at a certain time range was  #
# SR_DB_044 get_locations_popup_menu_for_weaning():      returns a HTML popup menu for locations as string (for weaning)              #
# SR_DB_045 get_colors_popup_menu():                     returns a HTML popup menu of all coat colors as string                       #
# SR_DB_046 get_color_name_by_id:                        returns color name for a given color id                                      #
# SR_DB_047 get_genetic_markers_popup_menu():            returns a HTML popup menu of all genetic markers as string                   #
# SR_DB_048 get_earmark ():                              returns earmark for a given mouse                                            #
# SR_DB_049 get_gene_name_by_id:                         returns gene name for a given gene id                                        #
# SR_DB_050 get_users_popup_menu():                      returns a HTML popup menu for users as string                                #
# SR_DB_051 get_gene_info_small():                       returns a small HTML genotype table for a given mouse as a string            #
# SR_DB_052 datetime_of_last_move():                     returns datetime string of last move of a mouse ("18.04.2005 13:33:44")      #
# SR_DB_053 was_there_a_place_for_this_mouse_between_datetime_of_move_and_now():   does what it says, returns 'yes' or 'no'           #
# SR_DB_054 count_mice_in_experiment:                    returns number of mice used in an experiment                                 #
# SR_DB_055 get_experimental_status:                     returns details about experimental status                                    #
# SR_DB_056 is_in_experiment:                            returns if a mouse is in an experiment                                       #
# SR_DB_057 get_experiments_popup_menu():                returns a HTML popup menu for experiments as string                                #
# SR_DB_058 get_workflows_popup_menu():                  returns a HTML popup menu of all workflows                                   #
# SR_DB_059 get_calendar_week_popup_menu():              returns a HTML popup menu of all calendar weeks                              #
# SR_DB_060 get_current_epoch_week():                    returns the current epoch week                                               #
# SR_DB_061 get_monday_of_current_week():                returns date of monday of current week                                       #
# SR_DB_062 get_calendar_week_popup_menu_2():            returns a HTML popup menu of calendar weeks                                  #
# SR_DB_063 get_phenotyping_status:                      returns details about phenotyping status                                     #
# SR_DB_064 get_medical_records:                         returns details about medical_records                                        #
# SR_DB_065 get_calendar_week_popup_menu_3():            returns a HTML popup menu of all calendar weeks                              #
# SR_DB_066 add_to_date():                               adds a number of days to a given date and returns result date                #
# SR_DB_067 db_is_in_matings ()                          returns a list of all matings a mouse is currently in                        #
# SR_DB_068 get_all_genotypes_in_one_line():             returns a string containing all genotypes in one line                        #
# SR_DB_069 write_textlog():                             write action log                                                             #
# SR_DB_070 print_parent_table():                        print parent_table                                                           #
# SR_DB_071 get_mother_cage_for_weaning ()               returns a rack/cage link for mother of a weaning                             #
# SR_DB_072 get_gene_info_for_ancestor_table():          returns a HTML genotype table for a given mouse as string                    #
# SR_DB_073 datetime_of_last_cage_move():                returns datetime string of last move of a cage ("18.04.2005 13:33:44")       #
# SR_DB_074 get_semaphore_lock:                          tries to get a lock via semaphore                                            #
# SR_DB_075 release_semaphore_lock:                      release a semaphore lock                                                     #
# SR_DB_076 give_me_a_cage:                              returns a cage id that was not in use since a given datetime                 #
# SR_DB_077 double_earmarks_in_cage ():                  returns yes if double earmarks in a given cage                               #
# SR_DB_078 get_first_genotype ():                       returns first genotype of a mouse                                            #
# SR_DB_079 records_for_this_mouse ():                   returns link to records for this mouse                                       #
# SR_DB_080 get_epoch_week():                            returns epoch week for a given date                                          #
# SR_DB_081 get_cage_color_popup_menu                    returns a HTML popup menu of all cage card bar colors                        #
# SR_DB_082 get_cage_color_by_id():                      returns color code by id                                                     #
# SR_DB_083 get_user_projects_colleagues ():             returns list of users that share projects with a given user                  #
# SR_DB_084 get_parametersets_popup_menu                 returns a HTML popup menu of all parametersets                               #
# SR_DB_085 get_pathoID ():                              returns patho id for a given mouse                                           #
# SR_DB_086 get_genotypes_as_hash():                     returns a genotype hash                                                      #
# SR_DB_087 get_origin():                                returns origin of a mouse as string for cage card                            #
# SR_DB_088 get_candidate_orderlists_table():            returns a HTML table of candidate orderlists for given mice and parameterset #
# SR_DB_089 get_project_name_by_id:                      returns project name for a given project id                                  #
# SR_DB_090 get_user_name_by_id:                         returns user name by given user id                                           #
# SR_DB_091 get_orderlist_details():                     returns some details for an orderlist by id                                  #
# SR_DB_092 get_cost_account_status:                     returns details about cost_account status                                    #
# SR_DB_093 get_cost_centre_popup_menu():                returns a HTML popup menu for cost centres as string                         #
# SR_DB_094 is_assigned_to_cost_centre:                  returns if a mouse is assigned to a cost centre                              #
# SR_DB_095 get_area_popup_menu():                       returns a HTML popup menu for areas as string                                #
# SR_DB_096 get_transfer_id ():                          returns transfer id for given mating (or NULL)                               #
# SR_DB_097 get_column_in_upload_file():                 returns the column in a parameterset-specific file containing a specific value
# SR_DB_098 get_blob_by_mr_id():                         returns blob id for a given medical record id                                #
# SR_DB_099 get_mice_of_medical_record:                  returns mice assigned to a medical record                                    #
# SR_DB_100 get_mice_of_blob:                            returns number of mice assigned to a blob                                    #
# SR_DB_101 get_blob_table():                            returns a HTML file/blob table for a given mouse as a string                 #
# SR_DB_102 current_user_is_admin:                       returns 'y' if current user has the admin flag                               #
# SR_DB_103 get_projects_checkbox_list():                returns a HTML checkbox list for projects as string                          #
# SR_DB_104 get_transfer_info ():                        returns embryo transfer info for given mating (or empty string)              #
# SR_DB_105 get_blob_table_for_line():                   returns a HTML file/blob table for a given mouse as a string                 #
# SR_DB_106 get_rack_sanitary_info():                    returns a HTML table for sanitary data of a rack                             #
# SR_DB_107 get_health_agents_checkbox_list():           returns a HTML checkbox list for health agents as string                     #
# SR_DB_108 get_origin_type ():                          returns origin type of a given mouse                                         #
# SR_DB_109 get_number_of_mice_from_line():              returns number of mice for a given line                                      #
# SR_DB_110 get_date_when_last_mouse_of_this_line_died:  returns death date for last mouse of a given line                            #
# SR_DB_111 get_cohort_table():                          returns a HTML cohort table for a given mouse as a string                    #
# SR_DB_112 get_mr_status_codes_list():                  returns an array of medical records status codes                             #
# SR_DB_113 get_rooms_popup_menu():                      returns a HTML popup menu for mouse lines as string                          #
# SR_DB_114 get_orderlist_number_by_line_parameterset(): returns number of orderlists for given line and parameterset                 #
# SR_DB_115 get_parameterset_name_by_id:                 returns parameterset name for a given parameterset id                        #
# SR_DB_116 get_number_medical_records_of_orderlist():   returns number of medical records for given orderlist                        #
# SR_DB_117 get_cohort_purposes_popup_menu():            returns a popup menu for cohort purposes                                     #
# SR_DB_118 get_treatments_table:                        returns details about treatments                                             #
# SR_DB_119 get_treatments_popup_menu():                 returns a HTML popup menu of all treatments as string                        #
# SR_DB_120 get_mating_strain_default():                 returns default mating strain for given parent strains                       #
# SR_DB_121 get_carts_table():                           returns a HTML cart table for a given mouse as a string                      #
# SR_DB_122 sterile_mating_warning:                      returns sterile mating_warning, if no litter for more than specified days    #
# SR_DB_123 get_genetic_markers_popup_menu_for_line():   returns a HTML popup menu of all genetic markers assigned to a line          #
# SR_DB_124 get_genotype_qualifiers_for_line():          returns a list of genotype qualifiers for all genes assigned to a line       #
# SR_DB_125 get_mothers_cages_for_mating ()              returns rack/cage links for mothers of a mating                              #
# SR_DB_126 get_number_medical_records_of_parameter():   returns number of medical records for parameter                              #
# SR_DB_127 get_number_medical_records_of_parameter_and_parameterset(): returns number of medical records for parameter and -set      #
# SR_DB_128 get_parameter_name_by_id:                    returns parameter name for a given parameter id                              #
# SR_DB_129 get_cryo_samples():                          returns a HTML cryo samples table for a given mouse as a string              #
# SR_DB_130 get_current_cage_mates():                    returns a list of current cagemates for a given cage                         #
# SR_DB_131 is_value_within_bounds():                    checks if a phenotype value is within predefined bounds                      #
# SR_DB_132 get_media_path_for_parameterset():           returns media file storage path for parameterset                             #
# SR_DB_133 get_media_parameter_for_parameterset():      returns media file storage path for parameterset                             #
# SR_DB_134 get_cohort_types_popup_menu():               returns a popup menu for cohort types                                        #
# SR_DB_135 get_cohorts_popup_menu():                    returns a HTML popup menu for cohorts as string                              #
# SR_DB_135 mouse_exists():                              returns mouse_id if it exists                                                #
# SR_DB_136 get_R_scripts():                             returns a HTML popup menu for R scripts as string                            #
# SR_DB_137 get_procedure_status_codes_popup_menu():     returns an ESLIM procedure status codes menu                                 #
# SR_DB_138 get_mothers_of_litter ():                    returns mother(s) of a given litter                                          #
# SR_DB_139 get_mothers_of_mating ():                    returns mother(s) of a given mating                                          #
# SR_DB_140 get_litter_stats ():                         returns stats for a given litter                                             #
# SR_DB_141 get_mating_father_first_genotype ():         returns first genotype of mating father                                      #
# SR_DB_142 get_mating_mother_first_genotype ():         returns first genotype of first mating mother                                #
# SR_DB_143 get_parameter_3_numbers ():                  returns overall min, mean, max of parameter in parameterset                  #
# SR_DB_144 get_parameter_type ():                       returns type of parameter                                                    #
# SR_DB_145 get_contactid_by_userid                      returns contact id given by user id                                          #
# SR_DB_146 get_contacts_popup_menu                      returns a HTML popup menu for contacts as string                             #
# SR_DB_147 current_app_is_mausnet:                      returns 'y' if current application is mausnet                                #
# SR_DB_148 is_date_younger:                             returns if a given exp date is younger than an exp start date in DB          #
# SR_DB_149 is_mouse_dead_atdate:                        returns if the given date is younger than date of mouse death                #
# SR_DB_150 get_olympus_images():                        returns a HTML image table for a given mouse as a string                     #
# SR_DB_151 check_orderlist_data                         returns error or '1' if orderlist is complete with required and valid data   #
# SR_DB_152 get_olympus_images_link():                   returns a HTML link to images available for a mouse                          #
#######################################################################################################################################

use strict;

#--------------------------------------------------------------------------------------o
# SR_DB_001 do_multi_result_sql_query2():                 generalized SQL query handler for queries with more than one result
sub do_multi_result_sql_query2 {                          my $sr_name = 'SR_DB_001';
  my $global_var_href    = $_[0];           # get reference to global vars hash
  my $sql_statement      = $_[1];           # actual SQL statement
  my $sql_parameters_ref = $_[2];           # reference to SQL argument list
  my $error_code         = $_[3];           # error code
  my $dbh = $global_var_href->{'dbh'};     # DBI database handle
  my $sth;                                 # DBI statement handle
  my $result;                              # reference on the results (explained some lines below)
  my $rows;                                # number of results (lines)

  # prepare the SQL statement (or generate error page if that fails)
  $sth = $dbh->prepare($sql_statement) or &error_message_and_exit($global_var_href, "SQL error", $error_code . "-PR");

  # execute the SQL query (or generate error page if that fails)
  $sth->execute(@{$sql_parameters_ref}) or &error_message_and_exit($global_var_href, "SQL error", $error_code . "-EX");

  # read query results using the fetchall_arrayref() method
  $result = $sth->fetchall_arrayref({}) or &error_message_and_exit($global_var_href, "SQL error", $error_code . "-FE");

  # finish the query (or generate error page if that fails)
  $sth->finish() or &error_message_and_exit($global_var_href, "SQL error", $error_code . "-FI");

  # how many result sets are returned?
  $rows = scalar @{$result};       # scalar is an operator that returns the number of elements of an array

  # return the reference on the results and the number of results
  return ($result, $rows);

  # some words about the "$result = $sth->fetchall_arrayref({})" method:
  # fetchall_arrayref() is a DBI method that returns a reference on an array of hash references containing the results.
  # in other words: every result line is given as an anonymous hash who's column name is the hash key by which
  # the column value can be accessed
  #
  # $result -> reference on array of hash references (hashref1, hashref2, hashref3, ..., )
  #                                                      |
  #                                        reference on anonymous hash1 %{ "mouse_id"  => "12345678",
  #                                                                        "mouse_sex" => "f"        }
  # to access the values:
  # loop over the array:    1a. foreach $row (@{$result})   or
  #                         1b. for ($i=0;$i<$rows;$i++;) { $row = $result->[$i]; }
  # access values:          2.  $sex = $row->{'mouse_sex'};
}
# end of do_multi_result_sql_query()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_002 do_single_result_sql_query():                generalized SQL query handler for simple queries with only one result (count only, limit 1, ...)
sub do_single_result_sql_query {                         my $sr_name = 'SR_DB_002';
  my $global_var_href    = $_[0];               # get reference to global vars hash
  my $sql_statement      = $_[1];               # actual SQL statement
  my $sql_parameters_ref = $_[2];               # reference to SQL argument list
  my $error_code         = $_[3];               # error code
  my $dbh = $global_var_href->{'dbh'};         # DBI database handle
  my $sth;                                     # DBI statement handle
  my @results;                                 # result array

  # prepare the SQL statement (or generate error page if that fails)
  $sth = $dbh->prepare($sql_statement) or &error_message_and_exit($global_var_href, "SQL error", $error_code . "-PR");

  # execute the SQL query (or generate error page if that fails)
  $sth->execute(@{$sql_parameters_ref}) or &error_message_and_exit($global_var_href, "SQL error", $error_code . "-EX");

  # just get one line of results (hopefully it is the only one) and read it to an array
  @results = $sth->fetchrow_array();

  # finish the query (or generate error page if that fails)
  $sth->finish() or &error_message_and_exit($global_var_href, "SQL error", $error_code . "-FI");

  # return array reference
  return (\@results);
}
# end of do_single_result_sql_query()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_003 db_stats():                                  returns some statistical numbers of the database
sub db_stats {                                           my $sr_name = 'SR_DB_003';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my ($sql, $living_mice, $total_mice, $max_mouse_id, $total_lines, $alive_lines, $free_cages, $total_cage_capacity);
  my ($distinct_mr_mice, $number_medical_records);
  my @sql_parameters;

  #############################################################
  # get total number of mice in database
  $sql = qq(select count(mouse_id)
            from   mice
           );

  @sql_parameters = ();

  ($total_mice) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  #############################################################
  # get number of currently living mice (those having no datetime for death or export)
  $sql = qq(select count(mouse_id)
            from   mice
            where  ISNULL(mouse_deathorexport_datetime)
                   and mouse_origin_type in (?, ?, ?, ?)
           );

  @sql_parameters = ('import', 'weaning', 'import_external', 'weaning_external');

  ($living_mice) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  #############################################################
  # get highest mouse_id
  $sql = qq(select max(mouse_id)
            from   mice
           );

  @sql_parameters = ();

  ($max_mouse_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  #############################################################
  # get number of lines
  $sql = qq(select count(line_id)
            from   mouse_lines
           );

  @sql_parameters = ();

  ($total_lines) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};
  $total_lines--;        # we don't count the "new line" entry

  #############################################################
  # get number of lines with living mice
  $sql = qq(select count(distinct mouse_line) as living_lines
            from   mice
            where  mouse_deathorexport_datetime IS NULL
           );

  @sql_parameters = ();

  ($alive_lines) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  #############################################################
  # get number of lines with living mice
  $sql = qq(select count(*) as number_free_cages
            from   cages
            where  cage_occupied = ?
           );

  @sql_parameters = ('n');

  ($free_cages) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};
  $free_cages--;        # we don't count the reanimation cage

  #############################################################
  # get number of lines with living mice
  $sql = qq(select sum(location_capacity)
            from   locations
            where  location_id between ? and ?
           );

  @sql_parameters = (1, 10000);

  ($total_cage_capacity) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  #############################################################
  # get number of medical records
  $sql = qq(select count(*) as number_medical_records
            from   mice2medical_records
           );

  @sql_parameters = ();

  ($number_medical_records) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  #############################################################
  # get number of distinct mice linked to medical records
  $sql = qq(select count(distinct m2mr_mouse_id) as number_distinct_mr_mice
            from   mice2medical_records
           );

  @sql_parameters = ();

  ($distinct_mr_mice) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  #############################################################


  return ($total_mice, $living_mice, $max_mouse_id, $total_lines, $alive_lines, $free_cages, $total_cage_capacity, $number_medical_records, $distinct_mr_mice);
}
# end of db_stats()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_004 get_lines_popup_menu():                      returns a HTML popup menu of all mouse lines as string
sub get_lines_popup_menu {                               my $sr_name = 'SR_DB_004';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $default_line    = $_[1];                           # (optional: the default line)
  my $menu_name       = $_[2];                           # (optional: menu name)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # is a default (pre-chosen in menu) line given? if not, take line 1
  unless ($default_line)        { $default_line = 1;      }
  unless (defined($menu_name))  { $menu_name    = 'line'; }

#   # query all lines with 'show' flag and not 'new line'
#   $sql = qq(select line_id, line_name, line_long_name
#             from   mouse_lines
#             where      line_show =  ?
#                    and line_name <> ?
#             order  by line_name asc
#            );
#
#   @sql_parameters = ('y', 'new line');

  # query all lines with 'show' flag
  $sql = qq(select line_id, line_name, line_long_name
            from   mouse_lines
            where  line_show =  ?
            order  by line_name asc
           );

  @sql_parameters = ('y');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__);

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'line_id'}} = $row->{'line_name'};        # create look-up hash table: line_id->line_name
  }

  # create a list of line ids which is alphabetically ordered by the line name
  @values = sort {lc($labels{$a}) cmp lc($labels{$b})} keys %labels;

#   # query the 'new line' entry
#   $sql = qq(select line_id, line_name, line_long_name
#             from   mouse_lines
#             where      line_show = ?
#                    and line_name = ?
#            );
#
#   @sql_parameters = ('y', 'new line');
#
#   ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__);
#
#   $row = $result->[0];
#
#   $labels{$row->{'line_id'}} = $row->{'line_name'};        # create look-up hash table: line_id->line_name
#
#   # add the 'new line' entry to the top of the popup menu
#   unshift(@values, $row->{'line_id'});

  unshift(@values, 'please choose');
  $labels{'please choose'} = 'please choose';

  # build popup menu using CGI method
  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_line
          );

  return ($menu);
}
# end of get_lines_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_005 get_projects_popup_menu():                   returns a HTML popup menu for projects as string
sub get_projects_popup_menu {                            my $sr_name = 'SR_DB_005';
  my $global_var_href    = $_[0];                        # get reference to global vars hash
  my $default_project    = $_[1];                        # (optional: the default project)
  my $user_projects_only = $_[2];                        # (optional: switch to only display projects user belongs to)
  my ($sql, $result, $rows, $row, $i);
  my %labels;
  my @values;
  my ($menu, $user_id, $session);
  my $selector = 'all_projects';
  my @sql_parameters;

  # is a default (pre-chosen in menu) project given? if not, take project 1
  unless ($default_project) { $default_project = 1; }

  # 1. case: only projects to which user is assigned
  if (defined($user_projects_only) && ($user_projects_only eq 'user_projects_only')) {
     $selector = 'user_projects';
     $session  = $global_var_href->{'session'};
     $user_id  = $session->param(-name=>'user_id');

     # only projects user is part of
     $sql = qq(select project_id, project_name
               from   projects
                      join users2projects on project_id = u2p_project_id
               where  u2p_user_id = ?
            );

     @sql_parameters = ($user_id);

  }

  # 2. case: all projects
  else {
     $sql = qq(select project_id, project_name
               from   projects
              );

     @sql_parameters = ();
  }

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'project_id'}} = $row->{'project_name'};        # create look-up hash table: project_id->project_name
  }

  # create a list of project ids which is alphabetically ordered by the project name
  @values = sort {$labels{$a} cmp $labels{$b}} keys %labels;

  # build popup menu using CGI method
  $menu = popup_menu( -name    => "$selector",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_project
                    );

  return ($menu);
}
# end of get_projects_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_006 get_father ():                               returns father of a given mouse
sub get_father {                                         my $sr_name = 'SR_DB_006';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # the mouse for which we search the father
  my ($sql, $result, $rows, $row, $i);
  my @father_ids;
  my @sql_parameters;

  $sql = qq(select l2p_parent_id as father_id
            from   mice
                   join litters2parents on mouse_litter_id = l2p_litter_id
            where  mouse_id             = ?
                   and l2p_parent_type  = ?
           );

  @sql_parameters = ($mouse_id, 'father');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@father_ids, $row->{'father_id'});
  }

  return \@father_ids;
}
# end of get_father()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_007 get_mother ():                               returns mother(s) of a given mouse
sub get_mother {                                         my $sr_name = 'SR_DB_007';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # the mouse for which we search the mother(s)
  my ($sql, $result, $rows, $row, $i);
  my @mother_ids;
  my @sql_parameters;

  $sql = qq(select l2p_parent_id as mother_id
            from   mice
                   join litters2parents on mouse_litter_id = l2p_litter_id
            where  mouse_id            = ?
                   and l2p_parent_type = ?
           );

  @sql_parameters = ($mouse_id, 'mother');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@mother_ids, $row->{'mother_id'});
  }

  return \@mother_ids;
}
# end of get_mother()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_008 get_mice_in_location():                      returns number of mice in a given location
sub get_mice_in_location {                               my $sr_name = 'SR_DB_008';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $location_id     = $_[1];                           # which location to look up
  my ($mice_in_rack, $sql);
  my @sql_parameters;

  $sql = qq(select count(*) as mice_in_rack
            from   mice2cages
                   left join cages2locations on c2l_cage_id = m2c_cage_id
            where  c2l_location_id = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
           );

  @sql_parameters = ($location_id);

  ($mice_in_rack) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($mice_in_rack);
}
# end of get_mice_in_location()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_009 get_mice_in_cage:                            returns number of mice in a given cage plus some more details
sub get_mice_in_cage {                                   my $sr_name = 'SR_DB_009';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $cage_id         = $_[1];                           # which cage to look up
  my $point_in_time   = $_[2];                           # point in time (datetime)
  my ($mice_in_cage, $cage_capacity, $males_in_cage, $females_in_cage, $sex_mixed, $strain_count, $strain_in_cage, $line_count, $line_in_cage, $sql);
  my @sql_parameters;

  # if third parameter (= point in time) not given, set it to current time)
  if (!defined($point_in_time)) {
     $point_in_time = get_current_datetime_for_sql();
  }

  #############################################################
  # query cage capacity (max. number of mice allowed in cage)
  $sql = qq(select cage_capacity
            from   cages
            where  cage_id = ?
           );

  @sql_parameters = ($cage_id);

  ($cage_capacity) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  #############################################################
  # query number of mice in cage
  $sql = qq(select count(m2c_mouse_id) as mouse_number
            from   mice2cages
            where  m2c_cage_id = ?
                   and m2c_datetime_from <= ?
                   and (   m2c_datetime_to IS NULL
                        or m2c_datetime_to > ?)
           );

  @sql_parameters = ($cage_id, $point_in_time, $point_in_time);

  ($mice_in_cage) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  #############################################################
  # query number of males in cage
  $sql = qq(select count(m2c_mouse_id) as mouse_number
            from   mice2cages
                   left join mice on m2c_mouse_id=mouse_id
            where  mouse_sex = ?
                   and m2c_cage_id = ?
                   and m2c_datetime_from <= ?
                   and (   m2c_datetime_to IS NULL
                        or m2c_datetime_to > ?)
           );

  @sql_parameters = ('m', $cage_id, $point_in_time, $point_in_time);

  ($males_in_cage) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  #############################################################
  # query number of females in cage
  $sql = qq(select count(m2c_mouse_id) as mouse_number
            from   mice2cages
                   left join mice on m2c_mouse_id=mouse_id
            where  mouse_sex = ?
                   and m2c_cage_id = ?
                   and m2c_datetime_from <= ?
                   and (   m2c_datetime_to IS NULL
                        or m2c_datetime_to > ?)
           );

  @sql_parameters = ('f', $cage_id, $point_in_time, $point_in_time);

  ($females_in_cage) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # is it a sex mixed cage?
  if ($males_in_cage != 0 && $females_in_cage != 0) { $sex_mixed = "true";  }
  else                                              { $sex_mixed = "false"; }

  #############################################################
  # query strain names and number of distict strains in cage
  $sql = qq(select count(strain_name) as strain_count, strain_name
            from   mice2cages
                   left join mice          on m2c_mouse_id = mouse_id
                   left join mouse_strains on mouse_strain = strain_id
            where  m2c_cage_id = ?
                   and m2c_datetime_from <= ?
                   and (   m2c_datetime_to IS NULL
                        or m2c_datetime_to > ?)
            group  by strain_name
            limit  1
           );

  @sql_parameters = ($cage_id, $point_in_time, $point_in_time);

  ($strain_count, $strain_in_cage) =  @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # is it a strain mixed cage?
  if    ( defined($strain_count) &&  $strain_count < $mice_in_cage) { $strain_in_cage = "mixed strains"; }
  elsif (!defined($strain_count))                                   { $strain_in_cage = "";              }

  #############################################################
  # query line names and numbe of distict lines in cage
  $sql = qq(select count(line_name) as line_count, line_name
            from   mice2cages
                   left join mice        on m2c_mouse_id = mouse_id
                   left join mouse_lines on   mouse_line = line_id
            where  m2c_cage_id = ?
                   and m2c_datetime_from <= ?
                   and (   m2c_datetime_to IS NULL
                        or m2c_datetime_to > ?)
            group  by line_name
            limit  1
           );

  @sql_parameters = ($cage_id, $point_in_time, $point_in_time);

  ($line_count, $line_in_cage) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # is it a line mixed cage?
  if    ( defined($line_count) &&  $line_count < $mice_in_cage) { $line_in_cage = "mixed lines"; }
  elsif (!defined($line_count))                                 { $line_in_cage = "";            }

  #############################################################
  return ($mice_in_cage, $males_in_cage, $females_in_cage, $sex_mixed, $strain_in_cage, $line_in_cage, $cage_capacity);
}
# get_mice_in_cage
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_011 get_strain ():                               returns strain id of a given mouse
sub get_strain {                                         my $sr_name = 'SR_DB_011';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up strain id?
  my ($strain_id, $sql);
  my @sql_parameters;

  $sql = qq(select mouse_strain
            from   mice
            where  mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($strain_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $strain_id;
}
# end of get_strain()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_012 get_line ():                                 returns line id of a given mouse
sub get_line {                                           my $sr_name = 'SR_DB_012';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up line id?
  my ($line_id, $sql);
  my @sql_parameters;

  $sql = qq(select mouse_line
            from   mice
            where  mouse_id = ?
         );

  @sql_parameters = ($mouse_id);

  ($line_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $line_id;
}
# end of get_line()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_014 get_gvo_status ():                           returns gvo status of a given mouse
sub get_gvo_status {                                     my $sr_name = 'SR_DB_014';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up gvo status?
  my ($is_gvo, $sql);
  my @sql_parameters;

  $sql = qq(select mouse_is_gvo
            from   mice
            where  mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($is_gvo) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $is_gvo;
}
# end of get_gvo_status()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_015 get_location_details_by_id ():               returns details on a given location
sub get_location_details_by_id {                         my $sr_name = 'SR_DB_015';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $location_id     = $_[1];                           # for which rack do we want to look up details?
  my ($location_building, $location_subbuilding, $location_room, $location_rack, $sql);
  my @sql_parameters;

  $sql = qq(select location_building, location_subbuilding, location_room, location_rack
            from   locations
            where  location_id = ?
           );

  @sql_parameters = ($location_id);

  ($location_building, $location_subbuilding, $location_room, $location_rack) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($location_building, $location_subbuilding, $location_room, $location_rack);
}
# end of get_location_details_by_id()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_016 get_project_info():                          returns for a given mouse the project the mouse belongs to as string
sub get_project_info {                                   my $sr_name = 'SR_DB_016';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which rack do we want to look up project_info?
  my ($result, $rows, $i, $row, $project_info, $sql);
  my @sql_parameters;

  $sql = qq(select project_id, project_name, m2p_date_from, m2p_date_to
            from   projects, mice, mice2projects
            where  m2p_mouse_id       = mouse_id
                   and m2p_project_id = project_id
                   and mouse_id       = ?
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if there are projects for this mouse, show them
  if ($rows > 0) {
     for ($i=0; $i<$rows; $i++) {      # loop over all projects
         $row = $result->[$i];

         $project_info .= ' ' . $row->{'project_name'};
     }
  }
  # else: no projects linked to this mouse
  else {
     $project_info = 'none';
  }

  return $project_info;
}
# end of get_project_info()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_017 get_gene_info_print():                       returns a HTML genotype table for a given mouse as string
sub get_gene_info_print {                                my $sr_name = 'SR_DB_017';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up gene info?
  my ($result, $rows, $i, $row, $gene_info, $gene_short, $sql);
  my @sql_parameters;

  $sql = qq(select gene_name, gene_shortname, m2g_genotype
            from   mice
                   left join mice2genes on m2g_mouse_id = mouse_id
                   left join genes      on m2g_gene_id  = gene_id
            where  mouse_id = ?
            order  by m2g_gene_order asc
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  $gene_info = "&nbsp;";

  # if there is at least one genotype, create genotype subtable
  if ($rows > 0) {

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         next if (!defined($row->{'gene_shortname'}));

         $gene_info .=  $row->{'m2g_genotype'} . "&nbsp; (" . ($row->{'gene_shortname'}) . "); ";
     }
  }
  else {
     $gene_info = "none";
  }

  return $gene_info;
}
# end of get_gene_info_print()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_018 get_strain_name_by_id:                       returns strain name for a given strain id
sub get_strain_name_by_id {                              my $sr_name = 'SR_DB_018';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $strain_id       = $_[1];                           # for which strain id do we want to look up strain name?
  my ($strain_name, $sql);
  my @sql_parameters;

  $sql = qq(select strain_name
            from   mouse_strains
            where  strain_id = ?
           );

  @sql_parameters = ($strain_id);

  ($strain_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $strain_name;
}
# end of get_strain_name_by_id()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_019 get_line_name_by_id:                         returns line name for a given line id
sub get_line_name_by_id {                                my $sr_name = 'SR_DB_019';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $line_id         = $_[1];                           # for which line id do we want to look up line name?
  my ($line_name, $sql);
  my @sql_parameters;

  $sql = qq(select line_name
            from   mouse_lines
            where  line_id = ?
           );

  @sql_parameters = ($line_id);

  ($line_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $line_name;
}
# end of get_line_name_by_id()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_020 get_strain_line_info():                      returns strain name and line name for a given mouse
sub get_strain_line_info {                               my $sr_name = 'SR_DB_020';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up strain/line info?
  my ($strain_name, $line_name, $sql);
  my @sql_parameters;

  $sql = qq(select strain_name, line_name
            from   mice
                   left join mouse_lines   on   mouse_line = line_id
                   left join mouse_strains on mouse_strain = strain_id
            where  mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($strain_name, $line_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($strain_name, $line_name);
}
# end of get_strain_line_info()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_021 get_gene_info():                             returns a HTML genotype table for a given mouse as a string
sub get_gene_info {                                      my $sr_name = 'SR_DB_021';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up gene info?
  my $url             = url();
  my @sql_parameters;
  my ($result, $rows, $i, $row, $gene_info, $sql);

  # genotype information
  $sql = qq(select gene_id, gene_name, m2g_genotype_date, m2g_genotype, m2g_genotype_method
            from   mice2genes
                   join genes on m2g_gene_id = gene_id
            where  m2g_mouse_id = ?
            order  by m2g_gene_order asc
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if there are no genotypes for this mouse, notify
  if ($rows == 0) {
     $gene_info .= p("No genotype information for this mouse");
     return $gene_info;
  }

  # else continue creating genotype table
  $gene_info = start_table( {-border=>1, -summary=>"table"})
               . Tr(
                   th("gene"              ),
                   th("genotype"          ),
                   th("genotyping date"   ),
                   th("genotyping method" ),
                   th("delete"            )
                 );

  # loop over all results from previous select
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      # add table row for current line
      $gene_info .= Tr({-align=>'center'},
                      td(a({-href=>"$url?choice=gene_details&gene_id=" . $row->{'gene_id'} }, $row->{'gene_name'})),
                      td(($row->{'m2g_genotype'} =~ /^'(.*)'$/)?$1:$row->{'m2g_genotype'}),
                      td(format_datetime2simpledate($row->{'m2g_genotype_date'})),
                      td(($row->{'m2g_genotype_method'} =~ /^'(.*)'$/)?$1:$row->{'m2g_genotype_method'}),
                      td(a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id&job=delete_genotype&gene_id=" . $row->{'gene_id'}}, 'delete this genotype'))
                    );
  }

  $gene_info .= end_table()
                . p();

  return $gene_info;
}
# end of get_gene_info()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_022 get_lines_popup_menu_for_query_builder():    returns a HTML popup menu for mouse lines as string
sub get_lines_popup_menu_for_query_builder {             my $sr_name = 'SR_DB_022';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $default_line    = $_[1];                           # (optional: default line)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # is a default (pre-chosen in menu) line given? if not, take line 1
  unless ($default_line) { $default_line = 1; }

  $sql = qq(select line_id, line_name, line_long_name
            from   mouse_lines
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'line_id'}} = $row->{'line_name'};        # create look-up hash table: line_id->line_name
  }

  @values = sort keys %labels;

  $menu = popup_menu( -name    => "constraint.mice.mouse_line",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_line
                    );

  return ($menu);
}
# end of get_lines_popup_menu_for_query_builder()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_023 get_strains_popup_menu():                    returns a HTML popup menu for mouse strains as string
sub get_strains_popup_menu {                             my $sr_name = 'SR_DB_023';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $default_strain  = $_[1];                           # (optional: default strain)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # is a default (pre-chosen in menu) strain given? if not, take strain 6
  unless ($default_strain) { $default_strain = 6; }

#   # query all strains with 'show' flag and not 'new strain'
#   $sql = qq(select strain_id, strain_name, strain_description
#             from   mouse_strains
#             where  strain_show = ?
#                    and strain_name <> ?
#             order  by strain_order asc
#            );

  # query all strains with 'show' flag
  $sql = qq(select strain_id, strain_name, strain_description
            from   mouse_strains
            where  strain_show = ?
            order  by strain_order asc
           );

  @sql_parameters = ('y');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'strain_id'}} = $row->{'strain_name'};        # create look-up hash table: strain_id->strain_name
  }

  @values = sort {lc($labels{$a}) cmp lc($labels{$b})} keys %labels;

#   # query the 'new strain' entry
#   $sql = qq(select strain_id, strain_name, strain_description
#             from   mouse_strains
#             where  strain_show = ?
#                    and strain_name = ?
#            );
#
#   @sql_parameters = ('y', 'new strain');
#
#   ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );
#
#   $row = $result->[0];
#
#   $labels{$row->{'strain_id'}} = $row->{'strain_name'};        # create look-up hash table: strain_id->strain_name
#
#   # add the 'new strain' entry to the top of the popup menu
#   unshift(@values, $row->{'strain_id'});

  unshift(@values, 'please choose');
  $labels{'please choose'} = 'please choose';

  $menu = popup_menu( -name    => "strain",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_strain
                    );

  return ($menu);
}
# end of get_strains_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_024 get_locations_popup_menu():                  returns a HTML popup menu for locations as string
sub get_locations_popup_menu {                           my $sr_name = 'SR_DB_024';
  my $global_var_href   = $_[0];                         # get reference to global vars hash
  my $default_location  = $_[1];                         # (optional: default location)
  my $with_cage_count   = $_[2];                         # (optional: switch for cage_count)
  my $screen_racks_only = $_[3];                         # (optional: switch to only display racks assigned to screens from user)
  my ($sql, $result, $rows, $row, $i);
  my ($menu, $user_id, $session, $cages_in_rack);
  my %labels;
  my @values;
  my $screen_only_sql = '';
  my $target_location = 'all_racks';
  my @user_screens;
  my @sql_parameters;

  # is a default (pre-chosen in menu) rack given? if not, take rack 1
  unless ($default_location) { $default_location = 1; }

  if (defined($screen_racks_only)) {
     $session         = $global_var_href->{'session'};
     $user_id         = $session->param(-name=>'user_id');
     @user_screens    = get_user_projects($global_var_href, $user_id);
     $screen_only_sql = "and location_project in (\'" . join("\',\'", @user_screens) . "\')";
     $target_location = 'screen_racks';
  }

  $sql = qq(select location_id, location_room, location_rack, project_name, location_capacity
            from   locations
                   left join projects on location_project = project_id
            where  location_is_internal   = ?
                   and location_is_active = ?
                   and location_id       >= ?
                   $screen_only_sql
            group  by location_id
           );

  @sql_parameters = ('y', 'y', 0);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      # how many cages in this rack?
      $sql = qq(select count(c2l_cage_id) as cages_in_rack
                from   cages2locations
                where  c2l_location_id = ?
                       and c2l_datetime_to IS NULL
             );

      @sql_parameters = ($row->{'location_id'});

      ($cages_in_rack) =  @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      # either display free slots along with room/rack and project name ...
      if (defined($with_cage_count) && $with_cage_count eq 'cage_count') {
         $labels{$row->{'location_id'}} = $row->{'location_room'} . "-" . $row->{'location_rack'} . ' (' . $row->{'project_name'} . ', ' . ($row->{'location_capacity'} - $cages_in_rack) . ' free slots) ';
      }
      # ... or not
      else {
         $labels{$row->{'location_id'}} = $row->{'location_room'} . "-" . $row->{'location_rack'}. ' (' . $row->{'project_name'} . ') ';
      }
  }

  @values = sort {$labels{$a} cmp $labels{$b}} keys %labels;

  $menu = popup_menu( -name    => "$target_location",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_location
                    );

  return ($menu);
}
# end of get_locations_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_025 write_upload_log():                          write upload log
sub write_upload_log {                                   my $sr_name = 'SR_DB_025';
  my ($dbh, $user_id, $user_name, $upload_filename, $local_filename) = @_;

  $dbh->do("insert
            into    log_uploads (log_id, log_user_id, log_user_name, log_datetime, log_upload_filename, log_local_filename, log_remote_IP)
            values  (NULL, ?, ?, NULL, ?, ?, ?)",
            undef, $user_id, $user_name, $upload_filename, $local_filename, $ENV{'REMOTE_ADDR'}
          );

  # ignore logging errors. Script execution has priority over logging
}
# end of write_upload_log():
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_026 write_log():                                 write access log
sub write_log {                                          my $sr_name = 'SR_DB_026';
  my ($dbh, $user_id, $user_name, $choice) = @_;         # also log user id and name
  my @parameters;                                        # list of all parameters submitted via GET or POST
  my $parameter;                                         # one parameter of the above list
  my $parameterlist = " ";                               # string that contains a serialized list of above parameters and values

  # get all parameters
  @parameters = param();

  foreach $parameter (@parameters) {
     unless ($parameter eq "choice") {
        $parameterlist .= "," . $parameter . "=" . param("$parameter");
     }
  }

  # remove leading " ,"
  $parameterlist =~ s/^\s,//g;

  $dbh->do("insert
            into    log_access (log_id, log_user_id, log_user_name, log_datetime, log_remote_host, log_remote_IP, log_choice, log_parameters)
            values  (NULL, ?, ?, NULL, ?, ?, ?, ?)",
            undef, $user_id, $user_name, $ENV{'HTTP_HOST'}, $ENV{'REMOTE_ADDR'}, $choice, $parameterlist
          );

  # ignore logging errors. Script execution has priority over logging
}
# end of write_log():
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_027 get_details_for_graph                        returns HTML string with details for a given mouse for use in graph
# CURRENTLY NOT USED
sub get_details_for_graph {                              my $sr_name = 'SR_DB_027';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to have details?
  my ($sql, $result, $rows, $row, $i, $gene_info, $output);
  my ($earmark, $sex, $strain, $line, $death_reason, $datetime_of_death, $datetime_of_birth);
  my @sql_parameters;

  # collect some details about this mouse
  $sql = qq(select mouse_id, mouse_earmark, mouse_sex, strain_name, line_name, death_reason_name,
                   mouse_deathorexport_datetime, mouse_birth_datetime
            from   mice
                   left join death_reasons on death_reason_id = mouse_deathorexport_reason
                   left join mouse_strains on       strain_id = mouse_strain
                   left join mouse_lines   on         line_id = mouse_line
            where  mouse_id = ?
           );

   @sql_parameters = ($mouse_id);

   ($mouse_id, $earmark, $sex, $strain, $line, $death_reason, $datetime_of_death, $datetime_of_birth) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

   # collect genotype information of this mouse
   $sql = qq(select gene_name, m2g_genotype
             from   mice
                    left join mice2genes on m2g_mouse_id = mouse_id
                    left join genes      on  m2g_gene_id = gene_id
             where  mouse_id = ?
            );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  if ($rows > 0) {
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $gene_info .=  $row->{'gene_name'} . " " .$row->{'m2g_genotype'} . " ";
     }
  }
  else {
     $gene_info .= 'n/a';
  }

   $output =   "born " . &format_datetime2simpledate($datetime_of_birth) . ", " . $death_reason . " " . &format_datetime2simpledate($datetime_of_death) . "\n"
             . "strain: " . $strain . " line: " . $line  . "\n"
             . "genotype: "  . $gene_info ;

   return $output;
}
# end of get_details_for_graph()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_028 db_is_in_mating ()                           returns if a given mouse is currently in a mating
sub db_is_in_mating {                                    my $sr_name = 'SR_DB_028';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to get mating status?
  my ($mating_id, $sql);
  my @sql_parameters;

  $sql = qq(select p2m_mating_id
            from   parents2matings
            where  p2m_parent_id = ?
            and    p2m_parent_end_date IS NULL
           );

  @sql_parameters = ($mouse_id);

  ($mating_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $mating_id;
}
# end of db_is_in_mating()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_029 get_genotypes_popup_menu():                  returns a HTML popup menu of all genotypes as string
sub get_genotypes_popup_menu {                           my $sr_name = 'SR_DB_029';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $menu_name       = $_[1];                           # (optional: menu name)
  my $with_any_option = $_[2];                           # (optional: switch to add 'any genotype' option to popup menu)
  my $default         = $_[3];                           # default
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  unless (defined($menu_name))    { $menu_name = 'gtype'; }
  unless (defined($default))      { $default = '';        }

  $sql = qq(select setting_key, setting_value_text
            from   settings
            where  setting_category = ?
                   and setting_item = ?
           );

  @sql_parameters = ('menu', 'genotypes_for_popup');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'setting_key'}} = $row->{'setting_value_text'};        # create look-up hash table: key->value
  }

#   # add 'any genotype' option to popup menu
#   if (defined($with_any_option) && ($with_any_option eq 'any')) {
#      $labels{'any'} = $row->{'any'};
#   }

  @values = sort {$labels{$a} cmp $labels{$b}} keys %labels;

  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [(21, @values)],
                      -labels  => \%labels,
                      -default => $default
          );

  return ($menu);
}
# end of get_genotypes_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_030 get_properties_table():                      returns a HTML properties table for a given mouse as a string
sub get_properties_table {                               my $sr_name = 'SR_DB_030';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to get properties?
  my $url             = url();
  my ($result, $rows, $i, $row, $property_info, $sql);
  my $property_string;
  my $property_output;
  my $property_date;
  my @sql_parameters;

  # genotype information
  $sql = qq(select property_key, property_type, property_value_integer
  			, property_value_bool, property_value_float, property_value_text
  			, m2pr_datetime as property_datetime
            from   mice2properties
                   join properties on m2pr_property_id = property_id
            where  m2pr_mouse_id = ?
            order by property_datetime desc
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # if there are no properties for this mouse, notify
  if ($rows == 0) {
     $property_info = p("no properties/attributes for this mouse");
     return $property_info;
  }

  # (else continue)
  $property_info = start_table( {-border=>1, -summary=>"table"})
                   . Tr(
                       th("name of property/attribute"),
                       th("property/attribute"),
                       th("date of property/attribute")
                     );

  # loop over all results from previous select
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      $property_string =   (defined($row->{'property_value_integer'})?$row->{'property_value_integer'}:'')
                         . (defined($row->{'property_value_float'})?$row->{'property_value_float'}:'')
                         . (defined($row->{'property_value_bool'})?$row->{'property_value_bool'}:'')
                         . (defined($row->{'property_value_text'})?$row->{'property_value_text'}:'');

      # if property is "father" or "mother" ...
      if ($row->{'property_key'} =~ /father|mother/) {
         # ... check if external father or mother has a MausDB id as external mouse
        # if (externalID2mouse_id($global_var_href, $property_string) =~ /^[0-9]{8}$/) {
        #    $property_output = a({-href=>"$url?choice=mouse_details&mouse_id=" . externalID2mouse_id($global_var_href, $property_string)}, qq(external mouse "$property_string"));
        # }
        # else {
            $property_output = qq($property_string);
        # }
      }
      else {
         $property_output = qq($property_string);
      }

	  #build property datetime
	  $property_date = defined($row->{'property_datetime'})?$row->{'property_datetime'}:'';
	  $property_date = format_datetime2simpledate($property_date);

      # add table row for current line
      $property_info .= Tr({-align=>'center'},
                          td($row->{'property_key'}),
                          td($property_output),
                          td($property_date)
                        );
  }

  $property_info .= end_table()
                    . p();

  return $property_info;
}
# end of get_properties_table()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_031 get_death_reasons_popup_menus():             returns two HTML popup menus for death reasons (how/why) as string
sub get_death_reasons_popup_menus {                      my $sr_name = 'SR_DB_031';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $default_how     = $_[1];                           # (optional: default reason how a mouse was killed)
  my $default_why     = $_[2];                           # (optional: default reason why a mouse was killed)
  my ($sql, $result, $rows, $row, $i);
  my ($how_menu, $why_menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # do the "how" reasons
  $sql = qq(select death_reason_id, death_reason_name
            from   death_reasons
            where  death_reason_category =  ?
                   and death_reason_name <> ?
           );

  @sql_parameters = ('how', 'alive');                    # exclude death_reason 'alive'

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'death_reason_id'}} = $row->{'death_reason_name'};         # create look-up hash table: death_reason_id->death_reason_name
  }

  @values = sort keys %labels;

  $how_menu = popup_menu( -name    => "killed_how",
                          -values  => [@values],
                          -labels  => \%labels,
                          -default => $default_how
              );

  # reset %labels hash table
  %labels = ();

  # now the same for the "why" reasons
  $sql = qq(select death_reason_id, death_reason_name
            from   death_reasons
            where  death_reason_category =  ?
                   and death_reason_name <> ?
           );

  @sql_parameters = ('why', 'alive');                    # exclude death_reason 'alive'

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'death_reason_id'}} = $row->{'death_reason_name'};         # create look-up hash table: death_reason_id->death_reason_name
  }

  @values = sort keys %labels;

  $why_menu = popup_menu( -name    => "killed_why",
                          -values  => [@values],
                          -labels  => \%labels,
                          -default => $default_why
              );

  return ($how_menu, $why_menu);
}
# end of get_death_reasons_popup_menus()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_032 externalID2mouse_id ()                       returns a negative 8 digit MausDB mouse is for a given external ID
sub externalID2mouse_id {                                my $sr_name = 'SR_DB_032';
  my $global_var_href   = $_[0];                         # get reference to global vars hash
  my $external_mouse_id = $_[1];                         # for which external mouse ID do we want to have the MausDB ID?
  my ($mouse_id, $sql);
  my @sql_parameters;

  # check $external_mouse_id (prevent SQL injection)
  if (!defined($external_mouse_id) || $external_mouse_id =~ /select|drop|;|delete|grant|update|'|""|\s/) {
      return 'invalid ID';
  }

  $sql = qq(select m2pr_mouse_id
            from   mice2properties
                   join properties on m2pr_property_id = property_id
            where  property_category       = ?
                   and property_key        = ?
                   and property_value_text = ?
           );

  @sql_parameters = ('mouse', 'foreignID', $external_mouse_id);

  ($mouse_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # there might be no MausDB ID attached to an external mouse
  if (!defined($mouse_id)) {
      return 'no ID';
  }

  return ($mouse_id);
}
# end of externalID2mouse_id()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_033 mouse_id2externalID ()                       returns an external ID on a given negative 8 digit MausDB mouse ID
sub mouse_id2externalID {                                my $sr_name = 'SR_DB_033';
  my $global_var_href   = $_[0];                         # get reference to global vars hash
  my $mouse_id          = $_[1];                         # for which mouse do we want to have the external ID?
  my ($external_mouse_id, $sql);
  my @sql_parameters;

  # check $external_mouse_id
  if (!defined($mouse_id)) {
      return 'invalid ID';
  }

  $sql = qq(select property_value_text
            from   properties
                   join mice2properties on m2pr_property_id = property_id
            where  property_category = ?
                   and property_key  = ?
                   and m2pr_mouse_id = ?
           );

  @sql_parameters = ('mouse', 'foreignID', $mouse_id);

  ($external_mouse_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # there might be no external ID attached to this mouse
  if (!defined($external_mouse_id)) {
      return 'no ID';
  }

  return ($external_mouse_id);
}
# end of mouse_id2externalID()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_034 get_breeding_info ()                         returns a HTML breeding table for a given mouse as a string
sub get_breeding_info {                                  my $sr_name = 'SR_DB_034';
  my $global_var_href   = $_[0];                         # get reference to global vars hash
  my $mouse_id          = $_[1];                         # for which mouse to we want to have breeding info?
  my $url               = url();
  my ($sql, $result, $rows, $row, $i);
  my ($table_page, $litter_number, $total_offspring);
  my @sql_parameters;

  # collect info about matings where given mouse was/is parent
  $sql = qq(select mating_id, mating_name, mating_matingstart_datetime, mating_matingend_datetime, mating_scheme, mating_purpose,
                   mating_generation, mating_comment, project_name
            from   matings
                   join parents2matings on  p2m_mating_id = mating_id
                   join projects        on mating_project = project_id
            where  p2m_parent_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # no results => stop here, just tell that nothing found
  unless ($rows > 0) {
    $table_page .= p("No breeding record for this mouse");
    return $table_page;
  }

  # (... otherwise continue with result table)

  # first generate table header ...
  $table_page .= start_table( {-border=>"1", -summary=>"breeding_record"})
                 . Tr( {-align=>'center'},
                     th("mating id"),
                     th("mating name"),
                     th("mating start"),
                     th("mating end"),
                     th("mating scheme"),
                     th("mating purpose"),
                     th("generation"),
                     th("project"),
                     th("litter number"),
                     th("comment")
                   );

  # ... then loop over all found matings
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      # count litters from current mating
      $sql = qq(select count(litter_id) as litter_number
                from   litters
                       join matings on litter_mating_id = mating_id
                where  mating_id = ?
               );

      @sql_parameters = ($row->{'mating_id'});

      ($litter_number) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      # generate the current mating summary row
      $table_page .= Tr({-align=>'center'},
                       td(a({-href=>"$url?choice=mating_view&mating_id=$row->{'mating_id'}", -title=>"click for mating details"}, "mating $row->{'mating_id'}")
                       ),
                       td((defined($row->{'mating_name'}) && $row->{'mating_name'} ne qq(''))?qq($row->{'mating_name'}):'-'),
                       td(format_datetime2simpledate($row->{'mating_matingstart_datetime'})),
                       td(format_datetime2simpledate($row->{'mating_matingend_datetime'})),
                       td((defined($row->{'mating_scheme'}) && $row->{'mating_scheme'} ne qq(''))?$row->{'mating_scheme'}:'-'),
                       td((defined($row->{'mating_purpose'}) && $row->{'mating_purpose'} ne qq(''))?$row->{'mating_purpose'}:'-'),
                       td((defined($row->{'mating_generation'}) && $row->{'mating_generation'} ne qq(''))?$row->{'mating_generation'}:'-'),
                       td(defined($row->{'project_name'})?$row->{'project_name'}:'-'),
                       td($litter_number),
                       td((defined($row->{'mating_comment'}) && $row->{'mating_comment'} ne qq(''))?$row->{'mating_comment'}:'-')
                     );
  }

  # count total offspring
  $sql = qq(select count(mouse_id) as total_offspring
            from   mice
            where  mouse_litter_id in (select l2p_litter_id
                                       from   litters2parents
                                       where  l2p_parent_id = ?
                                      )
           );

  @sql_parameters = ($mouse_id);

  ($total_offspring) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (!defined($total_offspring)) { $total_offspring = 0; }

  $table_page .= p(b("Total progeny: " . a({-href=>"$url?choice=find_children_of_mouse&mouse_id=$mouse_id"}, $total_offspring)))
                 . end_table();

  return $table_page;
}
# end of get_breeding_info()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_035 get_date_of_death ():                        returns date of death of a given mouse
sub get_date_of_death {                                  my $sr_name = 'SR_DB_035';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse to we want to find date of death?
  my ($date_of_death, $sql);
  my @sql_parameters;

  $sql = qq(select mouse_deathorexport_datetime
            from   mice
            where  mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($date_of_death) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $date_of_death;
}
# end of get_date_of_death()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_036 get_sex ():                                  returns sex of a given mouse
sub get_sex {                                            my $sr_name = 'SR_DB_036';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse to we want to get sex?
  my ($sex, $sql);
  my @sql_parameters;

  $sql = qq(select mouse_sex
            from   mice
            where  mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($sex) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $sex;
}
# end of get_sex()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_037 get_cages_in_location():                     returns number of occupied cages in a given location
sub get_cages_in_location {                              my $sr_name = 'SR_DB_037';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $location_id     = $_[1];                           # for which rack to we want to find out number of occupied cages?
  my ($cages_in_rack, $sql);
  my @sql_parameters;

  $sql = qq(select count(c2l_cage_id) as occupied
            from   locations
                   left join  cages2locations on location_id = c2l_location_id
            where  location_is_internal   = ?
                   and location_is_active = ?
                   and location_id        = ?
                   and c2l_datetime_to    IS NULL;
           );

  @sql_parameters = ('y','y', $location_id);

  ($cages_in_rack) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($cages_in_rack);
}
# end of get_cages_in_location()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_038 get_location ():                             returns location (rack) of a given mouse
sub get_location {                                       my $sr_name = 'SR_DB_038';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to find out current rack?
  my ($location, $sql);
  my @sql_parameters;

  $sql = qq(select c2l_location_id
            from   cages2locations
                   join mice2cages on m2c_cage_id = c2l_cage_id
            where  m2c_mouse_id = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
           );

  @sql_parameters = ($mouse_id);

  ($location) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $location;
}
# end of get_location ()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_039 get_user_projects ():                        returns list of projects for a given user id
sub get_user_projects {                                  my $sr_name = 'SR_DB_039';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $user_id         = $_[1];                           # for which user do we want to get projects?
  my ($sql, $result, $rows, $row, $i);
  my @projects = ();
  my @sql_parameters;

  $sql = qq(select u2p_project_id
            from   users2projects
            where  u2p_user_id = ?
           );

  @sql_parameters = ($user_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # loop over results and collect project ids in @projects
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      push(@projects, $row->{'u2p_project_id'});
  }

  return @projects;
}
# end of get_user_projects ()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_040 get_cage_location ():                        returns location (rack) of a given cage
sub get_cage_location {                                  my $sr_name = 'SR_DB_040';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $cage_id         = $_[1];                           # for which cage do we want to find out where it is currently placed?
  my ($location, $sql);
  my @sql_parameters;

  $sql = qq(select c2l_location_id
            from   cages2locations
            where  c2l_cage_id = ?
                   and c2l_datetime_to IS NULL
           );

  @sql_parameters = ($cage_id);

  ($location) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $location;
}
# end of get_cage_location ()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_041 get_cage ():                                 returns cage id for a given mouse
sub get_cage {                                           my $sr_name = 'SR_DB_041';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to find out current cage?
  my ($cage, $sql);
  my @sql_parameters;

  $sql = qq(select m2c_cage_id
            from   mice2cages
            where  m2c_mouse_id = ?
                   and m2c_datetime_to IS NULL
           );

  @sql_parameters = ($mouse_id);

  ($cage) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $cage;
}
# end of get_cage ()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_042 get_cage_mates():                            returns a list of cagemates for a certain cage at a certain time range
sub get_cage_mates {                                     my $sr_name = 'SR_DB_042';
  my $global_var_href    = $_[0];                        # get reference to global vars hash
  my $cage_id            = $_[1];                        # for which cage do we want to query cagemates?
  my $from               = $_[2];                        # start of time frame we want to use for query
  my $to                 = $_[3];                        # end of time frame we want to use for query
  my $my_mouse           = $_[4];                        # which mouse to exclude from result (because this mouse is not a cagemate of itself)
  my @cagemates          = ();
  my @cagemate_links     = ();
  my $url                = url();
  my ($sql, $result, $rows, $row, $i, $mouse);
  my %in_cage_from;
  my %in_cage_to;
  my @sql_parameters;

  # for the final cage (id = -1), don't return cagemates (as there are too many)
  if ($cage_id == -1) {
     return ('-');
  }

  # if end datetime is not given, define a timepoint far in the future, so it is not undefined
  # This is not a problem of the database, but perl will complain about concatenating the $sql string with something that is undefined
  if (!defined($to)) {
     $to = '2100-12-31 23:59:59';
  }

  $sql = qq(select m2c_mouse_id, m2c_datetime_from, m2c_datetime_to
            from   mice2cages
            where  m2c_cage_id = ?
                   and ( ( (m2c_datetime_from <= ?) and (m2c_datetime_to  >= ?  )                             ) or
                         ( (m2c_datetime_from >= ?) and (m2c_datetime_to  <= ?  )                             ) or
                         ( (m2c_datetime_from <= ?) and (m2c_datetime_to  <= ?  ) and (m2c_datetime_to > ?  ) ) or
                         ( (m2c_datetime_from >= ?) and (m2c_datetime_from < ?  ) and (m2c_datetime_to >= ? ) ) or
                         ( (m2c_datetime_from <= ?) and (m2c_datetime_to IS NULL)                             ) or
                         ( (m2c_datetime_from >= ?) and (m2c_datetime_to IS NULL) and (m2c_datetime_from < ?) )
                       )
           );

  @sql_parameters = ($cage_id, $from, $to, $from, $to, $from, $to, $from, $from, $to, $to, $from, $from, $to);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # loop over results and collect cagemate ids in @cagemates
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      push(@cagemates, $row->{'m2c_mouse_id'});

      $in_cage_from{$row->{'m2c_mouse_id'}} = format_sql_datetime2display_datetime($row->{'m2c_datetime_from'});
      $in_cage_to{$row->{'m2c_mouse_id'}}   = (defined($row->{'m2c_datetime_to'}))?format_sql_datetime2display_datetime($row->{'m2c_datetime_to'}):'(still there)';
  }

  # remove multiple entries for each mouse
  @cagemates = unique_list(@cagemates);

  # create link list as string (and exclude query mouse from that list)
  foreach $mouse (@cagemates) {
    if ($mouse == $my_mouse) { next; }                # purge my mouse from result list
    push(@cagemate_links, a({-href=>"$url?choice=mouse_details&mouse_id=" . $mouse, -title=>"from: " . $in_cage_from{$mouse} . ", to: " . $in_cage_to{$mouse}}, reformat_number($mouse, 8)));
  }

  return @cagemate_links;
}
# end of get_cage_mates()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_043 get_cage_racks():                            returns a list of racks in which a certain cage at a certain time range was
sub get_cage_racks {                                     my $sr_name = 'SR_DB_043';
  my $global_var_href    = $_[0];                        # get reference to global vars hash
  my $cage_id            = $_[1];                        # for which cage do we want to query racks?
  my $from               = $_[2];                        # start of time frame we want to use for query
  my $to                 = $_[3];                        # end of time frame we want to use for query
  my @cage_racks         = ();
  my $url                = url();
  my ($sql, $result, $rows, $row, $i, $rack);
  my @sql_parameters;

  # if end datetime is not given, define a timepoint far in the future, so it is not undefined
  # This is not a problem of the database, but perl will complain about concate the $sql string with something that is undefined
  if (!defined($to)) {
     $to = '2100-12-31 23:59:59';
  }

  $sql = qq(select location_room, location_rack, c2l_datetime_from, c2l_datetime_to
            from   cages2locations
                   join locations on location_id = c2l_location_id
            where  c2l_cage_id = ?
                   and ( ( (c2l_datetime_from <= ?) and (c2l_datetime_to  >= ?  )                             ) or
                         ( (c2l_datetime_from >= ?) and (c2l_datetime_to  <= ?  )                             ) or
                         ( (c2l_datetime_from <= ?) and (c2l_datetime_to  <= ?  ) and (c2l_datetime_to >  ?)  ) or
                         ( (c2l_datetime_from >= ?) and (c2l_datetime_from < ?  ) and (c2l_datetime_to >= ?)  ) or
                         ( (c2l_datetime_from <= ?) and (c2l_datetime_to IS NULL)                             ) or
                         ( (c2l_datetime_from >= ?) and (c2l_datetime_to IS NULL) and (c2l_datetime_from < ?) )
                       )
            order  by c2l_datetime_from asc
           );

  @sql_parameters = ($cage_id, $from, $to, $from, $to, $from, $to, $from, $from, $to, $to, $from, $from, $to);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and collect rack ids in @cage_racks
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      push(@cage_racks, (($row->{'location_room'} ne "0000")
                         ?b($row->{'location_room'} . '-' . $row->{'location_rack'})
                         :b("final rack")
                        )
                        . ' from: ' . ((format_sql_datetime2display_datetime($row->{'c2l_datetime_from'}) ne '-')
                                       ?format_sql_datetime2display_datetime($row->{'c2l_datetime_from'})
                                       :'(cage still there)'
                                      )
                        . ' to: '   . ((format_sql_datetime2display_datetime($row->{'c2l_datetime_to'}  ) ne '-')
                                       ?format_sql_datetime2display_datetime($row->{'c2l_datetime_to'}  )
                                       :'(cage still there)'
                                      )
      );
  }

  return @cage_racks;
}
# end of get_cage_racks()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_044 get_locations_popup_menu_for_weaning():      returns a HTML popup menu for locations as string (for weaning)
sub get_locations_popup_menu_for_weaning {               my $sr_name = 'SR_DB_044';
  my $global_var_href   = $_[0];                         # get reference to global vars hash
  my $default_location  = $_[1];                         # default rack
  my $name              = $_[2];                         # menu name
  my $id                = $_[3];                         # id
  my $pattern           = $_[4];                         # pattern
  my $is_selector       = $_[5];                         # is group selector
  my ($sql, $result, $rows, $row, $i, $cages_in_rack);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # is a default (pre-chosen in menu) rack given? if not, take rack 1
  unless ($default_location) { $default_location = 1; }

  # default class
  unless ($id) { $id = 'rack_select'; }

  $sql = qq(select location_id, location_room, location_rack, project_name, location_capacity
            from   locations
                   left join projects on location_project = project_id
            where  location_is_internal   = ?
                   and location_is_active = ?
                   and location_id        > ?
            group  by location_id
           );

  @sql_parameters = ('y', 'y', 0);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over racks with free slots
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      # how many cages in this rack?
      $sql = qq(select count(c2l_cage_id) as cages_in_rack
                from   cages2locations
                where  c2l_location_id = ?
                       and c2l_datetime_to IS NULL
             );

      @sql_parameters = ($row->{'location_id'});

      ($cages_in_rack) =  @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      $labels{$row->{'location_id'}} = $row->{'location_room'} . "-" . $row->{'location_rack'} . ' (' . $row->{'project_name'} . ', ' . ($row->{'location_capacity'} - $cages_in_rack) . ' free slots) ';
  }

  @values = sort {$labels{$a} cmp $labels{$b}} keys %labels;

  if (defined($is_selector) && $is_selector eq 'yes') {
     $menu = popup_menu( -name     => "$name",
                         -values   => [@values],
                         -labels   => \%labels,
                         -default  => $default_location,
                         -id       => $id,
                         -onChange => "set_cage($name, \'$pattern\')"
                       );
  }
  else {
     $menu = popup_menu( -name    => "$name",
                         -values  => [@values],
                         -labels  => \%labels,
                         -default => $default_location,
                         -id      => $id
                       );
  }

  return ($menu);
}
# end of get_locations_popup_menu_for_weaning()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_045 get_colors_popup_menu():                     returns a HTML popup menu of all coat colors as string
sub get_colors_popup_menu {                              my $sr_name = 'SR_DB_045';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $default_color   = $_[1];                           # (optional: default color)
  my $menu_name       = $_[2];                           # (optional: menu )
  my $ignore          = $_[3];                           # (optional: if true, 'ignore' will be added to list)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # is a default (pre-chosen in menu) color given? if not, take color 1 (whatever this color is)
  unless ($default_color) { $default_color = 1; }

  $sql = qq(select coat_color_id, coat_color_name
            from   mouse_coat_colors
            order  by coat_color_id asc
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and generate color lookup hash table
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'coat_color_id'}} = $row->{'coat_color_name'};
  }

  if (defined($ignore) && $ignore eq 'yes') {
     push(@values, 'ignore');
     $labels{0}     = 'ignore';
     $default_color = 0;
  }

  @values = sort keys %labels;

  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_color
          );

  return ($menu);
}
# end of get_colors_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_046 get_color_name_by_id:                        returns color name for a given color id
sub get_color_name_by_id {                               my $sr_name = 'SR_DB_046';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $color_id        = $_[1];                           # for which color id do we want to look up name?
  my ($color_name, $sql);
  my @sql_parameters;

  $sql = qq(select coat_color_name
            from   mouse_coat_colors
            where  coat_color_id = ?
           );

  @sql_parameters = ($color_id);

  ($color_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $color_name;
}
# end of get_color_name_by_id()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_047 get_genetic_markers_popup_menu():            returns a HTML popup menu of all genetic markers as string
sub get_genetic_markers_popup_menu {                     my $sr_name = 'SR_DB_047';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $default_gene    = $_[1];                           # (optional: default gene)
  my $menu_name       = $_[2];                           # (optional: default menu name)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # is a default (pre-chosen in menu) gene given? if not, take gene 1
  unless ($default_gene) { $default_gene = 1; }

  # is a menu name given?
  unless ($menu_name) { $menu_name = "genetic_marker"; }

  $sql = qq(select gene_id, gene_name, gene_shortname, gene_description
            from   genes
            order  by gene_name asc
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and generate gene lookup hash table
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'gene_id'}} = $row->{'gene_name'};
  }

  @values = sort {$labels{$a} cmp $labels{$b}} keys %labels;

  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_gene
          );

  return ($menu);
}
# end of get_genetic_markers_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_048 get_earmark ():                              returns earmark for a given mouse
sub get_earmark {                                        my $sr_name = 'SR_DB_048';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up earmark?
  my ($earmark, $sql);
  my @sql_parameters;

  $sql = qq(select mouse_earmark
            from   mice
            where  mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($earmark) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $earmark;
}
# end of get_earmark ()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_049 get_gene_name_by_id:                         returns gene name for a given gene id
sub get_gene_name_by_id {                                my $sr_name = 'SR_DB_049';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $gene_id         = $_[1];                           # for which gene id do we want to look up gene name?
  my ($gene_name, $sql);
  my @sql_parameters;

  $sql = qq(select gene_name
            from   genes
            where  gene_id = ?
           );

  @sql_parameters = ($gene_id);

  ($gene_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $gene_name;
}
# end of get_gene_name_by_id()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_050 get_users_popup_menu():                      returns a HTML popup menu for users as string
sub get_users_popup_menu {                               my $sr_name = 'SR_DB_050';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $default_user    = $_[1];                           # (optional: default user)
  my $menu_name       = $_[2];                           # (optional: menu name)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # if no defaults given, set arbitrarily
  unless (defined($default_user)) { $default_user = 1;      }
  unless (defined($menu_name))    { $menu_name    = 'user'; }

  $sql = qq(select user_id, user_name, contact_first_name, contact_last_name
            from   users
                   left join contacts on user_contact = contact_id
            where  user_status = 'active'
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and generate user lookup hash table
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'user_id'}} = $row->{'user_name'} . " ($row->{'contact_first_name'} $row->{'contact_last_name'})";
  }

  @values = sort {$labels{$a} cmp $labels{$b}} keys %labels;

  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_user
                    );

  return ($menu);
}
# end of get_users_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_051 get_gene_info_small():                       returns a small HTML genotype table for a given mouse as a string
sub get_gene_info_small {                                my $sr_name = 'SR_DB_051';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up gene info?
  my $url             = url();
  my ($result, $rows, $i, $row, $gene_info, $sql);
  my @sql_parameters;

  # genotype information
  $sql = qq(select gene_id, gene_name, m2g_genotype_date, m2g_genotype, m2g_genotype_method
            from   mice2genes
                   join genes on m2g_gene_id = gene_id
            where  m2g_mouse_id = ?
            order  by m2g_gene_order asc
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if there are no genotypes for this mouse, notify
  if ($rows == 0) {
     $gene_info .= p("No genotype information for this mouse");
     return $gene_info;
  }

  # else continue creating genotype table
  $gene_info = start_table( {-border=>0, -summary=>"table"});

  # loop over all results from previous select
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      # add table row for current line
      $gene_info .= Tr(
                      td({-align=>'right'}, a({-href=>"$url?choice=gene_details&gene_id=" . $row->{'gene_id'} }, $row->{'gene_name'})),
                      td({-align=>'left'},  ($row->{'m2g_genotype'} =~ /^'(.*)'$/)?$1:$row->{'m2g_genotype'})
                    );
  }

  $gene_info .= end_table();

  return $gene_info;
}
# end of get_gene_info_small()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_052 datetime_of_last_move():                     returns datetime string of last move of a mouse ("18.04.2005 13:33:44")
sub datetime_of_last_move {                              my $sr_name = 'SR_DB_052';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up gene info?
  my ($result, $rows, $i, $row, $gene_info, $sql, $m2c_datetime_from);
  my @sql_parameters;

  # SQL to get last move
  $sql = qq(select max(m2c_datetime_from)
            from   mice2cages
            where  m2c_mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($m2c_datetime_from) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($m2c_datetime_from)) {
     return format_sql_datetime2display_datetime($m2c_datetime_from);
  }
  else {
     return '-';
  }
}
# end of datetime_of_last_move()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_053 was_there_a_place_for_this_mouse_between_datetime_of_move_and_now():               what it says
sub was_there_a_place_for_this_mouse_between_datetime_of_move_and_now {                        my $sr_name = 'SR_DB_053';
  my $global_var_href  = $_[0];                           # get reference to global vars hash
  my $target_cage      = $_[1];                           # which cage?
  my $from             = $_[2];                           # datetime of move in the past
  my $now              = $_[3];                           # datetime of now
  my ($sql, $result, $rows, $i, $t, $row);
  my ($number_of_mice);
  my @datetimes;
  my @datetimes_purged;
  my ($number_of_time_slots, $datetime_element, $delta);
  my @sql_parameters;

  # we need to find out if there was at least one place left in the given cage at any time during given time range

  # 1) the quick (but not dirty) method: count mice that were placed in that cage during given time range. if this number is less than five,
  #    we already have an answer: return 'yes'

  # count mice as described above
  $sql = qq(select count(m2c_mouse_id) as number_of_mice
            from   mice2cages
            where  m2c_cage_id = ?
                   and ( ( (m2c_datetime_from >= ?) and (m2c_datetime_to <= ? )                               ) or
                         ( (m2c_datetime_from <= ?) and (m2c_datetime_to <= ? )   and (m2c_datetime_to > ?)   ) or
                         ( (m2c_datetime_from <= ?) and (m2c_datetime_to IS NULL)                             ) or
                         ( (m2c_datetime_from >= ?) and (m2c_datetime_to IS NULL) and (m2c_datetime_from < ?) )
                       )
           );

  @sql_parameters = ($target_cage, $from, $now, $from, $now, $from, $from, $from, $now);

  ($number_of_mice) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if ($number_of_mice < 5) {
     return 'yes';
  }

  # 2) if method 1) returns more than 4 mice, this does not necessarily mean there was no space left (as different mice could have been in the cage
  #    in a non-overlapping manner). It becomes only more complicated now.
  #    We need to split the given time range into as many sub-time-ranges as there are different time-points and check for each sub-time-range individually
  #    if the number of concurrent mice exceeds 4
  else {
     $sql = qq(select m2c_datetime_from, m2c_datetime_to
               from   mice2cages
               where  m2c_cage_id = ?
                      and ( ( (m2c_datetime_from >= ?) and (m2c_datetime_to <= ?   )                             ) or
                            ( (m2c_datetime_from <= ?) and (m2c_datetime_to <= ?   ) and (m2c_datetime_to   > ?) ) or
                            ( (m2c_datetime_from <= ?) and (m2c_datetime_to IS NULL)                             ) or
                            ( (m2c_datetime_from >= ?) and (m2c_datetime_to IS NULL) and (m2c_datetime_from < ?) )
                          )
              );

  @sql_parameters = ($target_cage, $from, $now, $from, $now, $from, $from, $from, $now);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

     # loop over all results from previous select
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];                # fetch next row

         if (defined($row->{'m2c_datetime_from'})) { push(@datetimes, $row->{'m2c_datetime_from'}); }
         if (defined($row->{'m2c_datetime_to'}))   { push(@datetimes, $row->{'m2c_datetime_to'}); }
     }

     # add all involved time points to @datetimes
     push(@datetimes, $now);
     push(@datetimes, $from);
     @datetimes = unique_list(@datetimes);

     # create sub-list of time points (remove those before datetime of move)
     foreach $datetime_element (@datetimes) {

        $delta = Delta_ddmmyyyhhmmss(format_sql_datetime2display_datetime($from),
                                     format_sql_datetime2display_datetime($datetime_element)
                                    );

        # only use time points that are past or equal the desired timepoint of move (=$from)
        if ( ($delta eq 'present') || ($delta eq 'future') ) {
           push(@datetimes_purged, $datetime_element);
        }
     }

     $number_of_time_slots = (scalar @datetimes_purged) - 1;

     # trivial case (only one time slot). Since we got here because first if condition (number_of_mice<5) failed, nothing changed: return 'no'
     if ($number_of_time_slots < 2) {
        return 'no';
     }

     # recursively check if there was a place left during desired datetime of move and now
     for ($t=0; $t<=($number_of_time_slots - 1); $t++) {
         if (was_there_a_place_for_this_mouse_between_datetime_of_move_and_now($global_var_href, $target_cage, $datetimes_purged[$t], $datetimes_purged[$t + 1]) eq 'no') {
            return 'no';
         }
     }

  }

  return 'yes';
}
# end of was_there_a_place_for_this_mouse_between_datetime_of_move_and_now()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_054 count_mice_in_experiment:                    returns number of mice used in an experiment
sub count_mice_in_experiment {                           my $sr_name = 'SR_DB_054';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $experiment_id   = $_[1];                           # for which experiment do we count the mice?
  my ($number_of_mice, $sql);
  my @sql_parameters;

  $sql = qq(select count(m2e_mouse_id) as mice_used
            from   mice2experiments
            where  m2e_experiment_id = ?
           );

  @sql_parameters = ($experiment_id);

  ($number_of_mice) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $number_of_mice;
}
# end of count_mice_in_experiment ()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_055 get_experimental_status:                     returns details about experimental status
sub get_experimental_status {                            my $sr_name = 'SR_DB_055';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # which mouse?
  my $url             = url();
  my ($experiment_id, $experiment_name, $from, $to, $experiment_status, $sql);
  my ($result, $rows, $row, $i);
  my @sql_parameters;

  $sql = qq(select experiment_id, experiment_name, m2e_datetime_from, m2e_datetime_to
            from   mice2experiments
                   left join experiments on m2e_experiment_id = experiment_id
            where  m2e_mouse_id = ?
            order  by m2e_datetime_from asc
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows > 0) {
     $experiment_status = b((is_in_experiment($global_var_href, $mouse_id) < 0)?'Currently not in an experiment. Experiment history:':'Experiment history:')
                          . start_table({-border=>1})
                          . Tr(
                              th('Experiment'),
                              th('From'),
                              th('To')
                            );

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         ($experiment_id, $experiment_name, $from, $to) = ($row->{'experiment_id'}, $row->{'experiment_name'}, $row->{'m2e_datetime_from'}, $row->{'m2e_datetime_to'});

         $experiment_status .= Tr(
                                 td(a({-href=>"$url?choice=experiment_view&experiment_id=" . $experiment_id}, $experiment_name)),
                                 td(format_sql_datetime2display_datetime($from)),
                                 td((defined($to)?format_sql_datetime2display_datetime($to):"&lt;still in experiment&gt;"))
                               );
     }

     $experiment_status .= end_table();
  }
  else {
     $experiment_status = 'Not in an experiment.';
  }

  return $experiment_status;
}
# end of get_experimental_status ()
#-------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_056 is_in_experiment:                            returns if a mouse is in an experiment
sub is_in_experiment {                                   my $sr_name = 'SR_DB_056';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # which mouse?
  my $url             = url();
  my ($experiment_id, $sql);
  my @sql_parameters;

  $sql = qq(select m2e_experiment_id
            from   mice2experiments
            where  m2e_mouse_id = ?
                   and m2e_datetime_to IS NULL
           );

  @sql_parameters = ($mouse_id);

  ($experiment_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($experiment_id)) {
     return $experiment_id;
  }
  else {
     return -1;
  }
}
# end of is_in_experiment ()
#-------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_057 get_experiments_popup_menu():                returns a HTML popup menu for users as string
sub get_experiments_popup_menu {                         my $sr_name = 'SR_DB_057';
  my $global_var_href    = $_[0];                        # get reference to global vars hash
  my $default_experiment = $_[1];                        # (optional: default experiment)
  my $menu_name          = $_[2];                        # (optional: menu name)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # if no defaults given, set arbitrarily
  unless (defined($default_experiment)) { $default_experiment = 1;   }
  unless (defined($menu_name))          { $menu_name = 'experiment'; }

  $sql = qq(select experiment_id, experiment_name
            from   experiments
            where  experiment_is_active = 'y'
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and generate user lookup hash table
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'experiment_id'}} = $row->{'experiment_name'};
  }

  @values = sort keys %labels;

  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_experiment
                    );

  return ($menu);
}
# end of get_experiments_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_058 get_workflows_popup_menu():                  returns a HTML popup menu of all workflows
sub get_workflows_popup_menu {                           my $sr_name = 'SR_DB_058';
  my $global_var_href  = $_[0];                          # get reference to global vars hash
  my $default_workflow = $_[1];                          # (optional: the default workflow)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # is a default (pre-chosen in menu) workflow given? if not, take workflow 1
  unless ($default_workflow) { $default_workflow = 1; }

  # query all lines with 'show' flag
  $sql = qq(select workflow_id, workflow_name
            from   workflows
            where  workflow_is_active = ?
           );

  @sql_parameters = ('y');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'workflow_id'}} = $row->{'workflow_name'};        # create look-up hash table: workflow_id->workflow_name
  }

  @values = sort keys %labels;

  # build popup menu using CGI method
  $menu = popup_menu( -name    => "workflow_id",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_workflow
          );

  return ($menu);
}
# end of get_workflows_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_059 get_calendar_week_popup_menu():              returns a HTML popup menu of all calendar weeks
sub get_calendar_week_popup_menu {                       my $sr_name = 'SR_DB_059';
  my $global_var_href  = $_[0];                          # get reference to global vars hash
  my $menu_name        = $_[1];                          # (optional: name of menu)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my $epoch_week = get_current_epoch_week($global_var_href);
  my @sql_parameters;

  # is a menu name given? if not, use default
  unless ($menu_name) { $menu_name = 'first_task_at'; }

  # query weeks starting from today (use monday from every week)
  $sql = qq(select day_number, day_week_and_year, day_date as monday_of_week
            from   days
            where      day_epoch_week > (? - ?)
                   and day_epoch_week < (? + ?)
                   and day_week_day_number = ?
            order  by day_date asc
           );

  @sql_parameters = ($epoch_week, 20, $epoch_week, 20, 1);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'monday_of_week'}} = $row->{'day_week_and_year'};        # create look-up hash table: monday_of_week => calendar week
  }

  @values = sort keys %labels;

  # build popup menu using CGI method
  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => get_monday_of_current_week($global_var_href)
          );

  return ($menu);
}
# end of get_calendar_week_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_060 get_current_epoch_week():                    returns the current epoch week
sub get_current_epoch_week {                             my $sr_name = 'SR_DB_060';
  my $global_var_href  = $_[0];                          # get reference to global vars hash
  my ($sql, $epoch_week, $today);
  my $current_datetime = get_current_datetime_for_sql();
  my @sql_parameters;

  # extract the date part from current datetime
  ($today, undef) = split(/\s/, $current_datetime);

  # query current epoch week
  $sql = qq(select day_epoch_week
            from   days
            where  day_date = ?
           );

  @sql_parameters = ($today);

  ($epoch_week) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $epoch_week;

}
# end of get_current_epoch_week()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_061 get_monday_of_current_week():                returns date of monday of current week
sub get_monday_of_current_week {                         my $sr_name = 'SR_DB_061';
  my $global_var_href  = $_[0];                          # get reference to global vars hash
  my ($sql, $this_weeks_monday, $today);
  my $current_datetime = get_current_datetime_for_sql();
  my @sql_parameters;

  # extract the date part from current datetime
  ($today, undef) = split(/\s/, $current_datetime);

  # query monday of current week
  $sql = qq(select d2.day_date
            from   days d1, days d2
            where                 d1.day_date = ?
                   and      d1.day_epoch_week = d2.day_epoch_week
                   and d2.day_week_day_number = ?
           );

  @sql_parameters = ($today, 1);

  ($this_weeks_monday) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $this_weeks_monday;

}
# end of get_monday_of_current_week()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_062 get_calendar_week_popup_menu_2():           returns a HTML popup menu of calendar weeks
sub get_calendar_week_popup_menu_2 {                    my $sr_name = 'SR_DB_062';
  my $global_var_href = $_[0];                          # get reference to global vars hash
  my $epoch_week      = $_[1];                          # epoch week (to start with)
  my $menu_name       = $_[2];                          # name of popup menu
  my $default         = $_[3];                          # default
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # query next 20 weeks starting from a given reference week (use monday from every week)
  $sql = qq(select day_number, day_week_and_year, day_date as monday_of_week
            from   days
            where      day_epoch_week >= (? - ?)
                   and day_epoch_week <  (? + ?)
                   and day_week_day_number = ?
            order  by day_date asc
           );

  @sql_parameters = ($epoch_week, 20, $epoch_week, 20, 1);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      # create look-up hash table: monday_of_week => calendar week
      $labels{$row->{'monday_of_week'}} = $row->{'day_week_and_year'} . ' (Mo=' . format_sql_datetime2display_date($row->{'monday_of_week'}) . ')';
  }

  @values = sort keys %labels;

  # now add key-value pair: '-'->'never'
  $labels{'never'} = '-' ;
  unshift(@values, 'never');         # on top of the popup menu

  # build popup menu using CGI method
  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default
          );

  return ($menu);
}
# end of get_calendar_week_popup_menu_2()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_063 get_phenotyping_status:                      returns details about phenotyping status
sub get_phenotyping_status {                             my $sr_name = 'SR_DB_063';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # which mouse?
  my $url             = url();
  my ($no_orderlists_for_this_mouse, $done_orderlists_for_this_mouse, $phenotyping_status, $sql);
  my @sql_parameters;

  # how many orderlists contain this mouse?
  $sql = qq(select count(m2o_orderlist_id) as no_orderlists_for_this_mouse
            from   mice2orderlists
            where  m2o_mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($no_orderlists_for_this_mouse) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $sql = qq(select count(m2o_orderlist_id) as no_orderlists_for_this_mouse
            from   mice2orderlists
                   left join orderlists on m2o_orderlist_id = orderlist_id
            where          m2o_mouse_id = ?
                   and orderlist_status = ?
           );

  @sql_parameters = ($mouse_id, 'done');

  ($done_orderlists_for_this_mouse) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};


  if (defined($no_orderlists_for_this_mouse) && ($no_orderlists_for_this_mouse > 0)) {
     $phenotyping_status = table({-border=>0},
                                 Tr(
                                   td({-align=>'right'}, b('Ordered: ')),
                                   td(a({-href=>"$url?choice=show_mouse_orderlists&mouse_id=" . $mouse_id}, $no_orderlists_for_this_mouse)
                                      . " (click to see all orderlists for this mouse)"
                                   )
                                 ),
                                 Tr(
                                   td({-align=>'right'}, b('Done: ')),
                                   td($done_orderlists_for_this_mouse)
                                 )
                           );
  }
  else {
     $phenotyping_status = 'no phenotyping orders for this mouse';
  }

  return $phenotyping_status;
}
# end of get_phenotyping_status ()
#-------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_064 get_medical_records:                         returns details about medical_records
sub get_medical_records {                                my $sr_name = 'SR_DB_064';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # which mouse?
  my $url             = url();
  my ($no_medical_records_for_this_mouse, $medical_record_status, $sql);
  my @sql_parameters;

  $sql = qq(select count(m2mr_mouse_id) as no_medical_records_for_this_mouse
            from   mice2medical_records
            where  m2mr_mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($no_medical_records_for_this_mouse) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($no_medical_records_for_this_mouse) && ($no_medical_records_for_this_mouse > 0)) {
     $medical_record_status = 'currently '
                           . a({-href=>"$url?choice=show_mouse_phenotyping_records_overview&mouse_id=" . $mouse_id}, $no_medical_records_for_this_mouse)
                           . ' phenotyping record(s). ';
  }
  else {
     $medical_record_status = 'no phenotyping records for this mouse';
  }

  return $medical_record_status;
}
# end of get_medical_records ()
#-------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_065 get_calendar_week_popup_menu_3():            returns a HTML popup menu of all calendar weeks
sub get_calendar_week_popup_menu_3 {                     my $sr_name = 'SR_DB_065';
  my $global_var_href  = $_[0];                          # get reference to global vars hash
  my $menu_name        = $_[1];                          # (optional: name of menu)
  my $default          = $_[2];                          # get reference to global vars hash
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my $epoch_week = get_current_epoch_week($global_var_href);
  my @sql_parameters;

  # is a menu name given? if not, use default
  unless ($menu_name) { $menu_name = 'weeks'; }

  # query weeks starting from today (use monday from every week)
  $sql = qq(select day_number, day_week_and_year, day_date as monday_of_week
            from   days
            where  day_week_day_number = ?
            order  by day_date asc
           );

  @sql_parameters = (1);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'monday_of_week'}} = $row->{'day_week_and_year'};        # create look-up hash table: monday_of_week => calendar week
  }

  @values = sort keys %labels;

  # build popup menu using CGI method
  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default
          );

  return ($menu);
}
# end of get_calendar_week_popup_menu_3()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_066 add_to_date():                               adds a number of days to a given date and returns result date
sub add_to_date {                                        my $sr_name = 'SR_DB_066';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $sql_date        = $_[1];                           # a date in sql format ('2005-04-27')
  my $delta_days      = $_[2];                           # number of days to add
  my ($sql, $day_number, $result_date);
  my @sql_parameters;

  if (defined($sql_date)   && $sql_date   =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ &&
      defined($delta_days) && $delta_days =~ /^-{0,1}[0-9]+$/) {

      # find out day number of given date
      $sql = qq(select day_number
                from   days
                where  day_date = ?
               );

      @sql_parameters = ($sql_date);

      ($day_number) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      # add delta_days to day_number
      $day_number = $day_number + $delta_days;

      # find out date for result day number
      $sql = qq(select day_date
                from   days
                where  day_number = ?
               );

      @sql_parameters = ($day_number);

      ($result_date) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      return ($result_date);
  }
  else {
      return undef;
  }
}
# end of add_to_date()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_067 db_is_in_matings ()                          returns a list of all matings a mouse is currently in
sub db_is_in_matings {                                   my $sr_name = 'SR_DB_067';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to get mating status?
  my ($i, $result, $row, $rows, $sql);
  my @mating_ids = ();
  my @sql_parameters;

  $sql = qq(select p2m_mating_id
            from   parents2matings
            where  p2m_parent_id = ?
            and    p2m_parent_end_date IS NULL
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

   # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@mating_ids, $row->{'p2m_mating_id'});
  }

  return @mating_ids;
}
# end of db_is_in_matings()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_068 get_all_genotypes_in_one_line():             returns a string containing all genotypes in one line
sub get_all_genotypes_in_one_line {                      my $sr_name = 'SR_DB_068';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up gene info?
  my ($result, $rows, $i, $row, $gene_info, $gene_short, $sql);
  my @genotypes;
  my @sql_parameters;

  $sql = qq(select gene_name, gene_shortname, m2g_genotype
            from   mice
                   left join mice2genes on m2g_mouse_id = mouse_id
                   left join genes      on  m2g_gene_id = gene_id
            where  mouse_id = ?
            order  by m2g_gene_order asc
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if there is at least one genotype, create genotype subtable
  if ($rows > 0) {
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         next if (!defined($row->{'gene_shortname'}));

         push(@genotypes, qq($row->{'gene_shortname'}));
         push(@genotypes, qq($row->{'m2g_genotype'}));
     }
  }
  else {
     @genotypes = ();
  }

  return @genotypes;
}
# end of get_all_genotypes_in_one_line()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_069 write_textlog():                             write action log
sub write_textlog {                                      my $sr_name = 'SR_DB_069';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $log_row         = $_[1];                           # line to log
  my $log_filename    = $global_var_href->{'log_file_name'};

  open(LOGFILE, ">> ./logs/$log_filename");
    print LOGFILE "$ENV{'REMOTE_ADDR'}\t$log_row\n";
  close(LOGFILE);
}
# end of write_textlog():
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_070 print_parent_table():                        print parent_table
sub print_parent_table {                                 my $sr_name = 'SR_DB_069';
  my $global_var_href  = $_[0];                           # get reference to global vars hash
  my $mouse_id         = $_[1];                           # mouse_id
  my $role             = $_[2];                           # role of mouse_id
  my $generation       = $_[3];                           # current generation (to limit recursion)
  my $max_generations  = $_[4];                           # generation limit
  my $alternative_list = $_[5];
  my $url              = url();
  my ($parent_table, $father_table, $mother_table);
  my ($father, $mother, $alternatives);
  my @fathers;
  my @mothers;

  # increase generation counter (compare with $max_generations to prevent recursion without stop)
  $generation++;

  # get fathers (take first one)
  @fathers = @{get_father($global_var_href, $mouse_id)};
  $father  = $fathers[0];
  if (scalar @fathers > 1) {
     $alternatives = 'alternatives:' . br();
     foreach (@fathers) {
        next if ($_ == $fathers[0]);
        $alternatives .=  a({-href=>"$url?choice=show_ancestors&mouse_id=" . $_}, $_) . br();
     }
  }
  else {
     $alternatives = '';
  }

  if (defined($father) && ($generation <= $max_generations)) {
     $father_table = print_parent_table($global_var_href, $father, "father: ", $generation, $max_generations, $alternatives);
  }
  elsif (defined($father) && ($generation > $max_generations)) {
     $father_table = a({-href=>"$url?choice=show_ancestors&mouse_id=" . $mouse_id}, "(more)");
  }
  else {
     $father_table = table( {-border=>0, -cellspacing=>1, -cellpadding=>2},
                     Tr(
                       td({-rowspan=>2, -valign=>"center", -style=>"font-family: monospace; font-size : 12px; font-weight: normal;"}, 'father: imported')
                     ) .
                     Tr(
                       td(' ')
                     )
                  );
  }

  # reset
  $alternatives = '';

  # get mothers (take first one)
  @mothers = @{get_mother($global_var_href, $mouse_id)};
  $mother  = $mothers[0];
  if (scalar @mothers > 1) {
     $alternatives = 'alternatives:' . br();
     foreach (@mothers) {
        next if ($_ == $mothers[0]);
        $alternatives .=  a({-href=>"$url?choice=show_ancestors&mouse_id=" . $_}, $_) . br();
     }
  }
  else {
     $alternatives = '';
  }

  if (defined($mother) && ($generation <= $max_generations)) {
     $mother_table = print_parent_table($global_var_href, $mother, "mother: ", $generation, $max_generations, $alternatives);
  }
  elsif (defined($mother) && ($generation > $max_generations)) {
     $mother_table = a({-href=>"$url?choice=show_ancestors&mouse_id=" . $mouse_id}, "(more)");
  }
  else {
     $mother_table = table( {-border=>0, -cellspacing=>1, -cellpadding=>2},
                     Tr(
                       td({-rowspan=>2, -valign=>"center", -style=>"font-family: monospace; font-size : 12px; font-weight: normal;"}, 'mother: imported')
                     ) .
                     Tr(
                       td(' ')
                     )
                  );
  }

  $parent_table = table( {-style=>"border: 1px inset gray; border-collapse: collapse; border-spacing: 0px; padding: 0px;"},           # {-border=>0, -cellspacing=>1, -cellpadding=>2},
                     Tr(
                       td({-rowspan=>2, -valign=>"center", -style=>"font-family: monospace; font-size : 12px; font-weight: normal;"},
                          b("$role ")
                          . br()
                          . a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id"}, $mouse_id)
                          . br()
                          . small(get_gene_info_for_ancestor_table($global_var_href, $mouse_id))
                          . br()
                          . small($alternative_list)
                       ),
                       td($father_table)
                     ) .
                     Tr(
                       td($mother_table)
                     )
                  );

  return ($parent_table);
}
# end of print_parent_table():
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_071 get_mother_cage_for_weaning ()               returns a rack/cage link for mother of a weaning
sub get_mother_cage_for_weaning {                        my $sr_name = 'SR_DB_071';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $litter_id       = $_[1];                           # litter
  my $url = url();
  my ($i, $result, $row, $rows, $sql);
  my $cage_link;
  my @sql_parameters;

  $sql = qq(select location_room, location_rack, cage_id
            from   litters2parents
                   join mice            on l2p_parent_id = mouse_id
                   join mice2cages      on      mouse_id = m2c_mouse_id
                   join cages2locations on   m2c_cage_id = c2l_cage_id
                   join locations       on   location_id = c2l_location_id
                   join cages           on       cage_id = c2l_cage_id
            where  l2p_litter_id = ?
                   and l2p_parent_type = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
           );

  @sql_parameters = ($litter_id, 'mother');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # only look at first of mothers
  $row = $result->[0];

  if (defined($row->{'cage_id'}) && ($row->{'cage_id'} >= 0)) {
     $cage_link = a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"},
                    $row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . &reformat_number($row->{'cage_id'}, 4));
  }
  else {
     $cage_link = 'mother dead';
  }

  return $cage_link;
}
# end of get_mother_cage_for_weaning()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_072 get_gene_info_for_ancestor_table():          returns a HTML genotype table for a given mouse as string
sub get_gene_info_for_ancestor_table {                   my $sr_name = 'SR_DB_072';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up gene info?
  my ($result, $rows, $i, $row, $gene_info, $gene_short, $sql);
  my @sql_parameters;

  $sql = qq(select gene_name, gene_shortname, m2g_genotype
            from   mice
                   left join mice2genes on m2g_mouse_id = mouse_id
                   left join genes      on m2g_gene_id  = gene_id
            where  mouse_id = ?
            order  by m2g_gene_order asc
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if there is at least one genotype, create genotype subtable
  if ($rows > 0) {

     $gene_info = start_table( {-border=>"0", -cellspacing=>0, -cellpadding=>0, -summary=>"table"});

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         next if (!defined($row->{'gene_shortname'}));

         $gene_info .=  Tr({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 10px;"},
                          td({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 10px;"},
                             "$row->{'m2g_genotype'}"
                            ),
                          td({-style=>"font-family: Verdana, Helvetica, Arial, sans-serif; font-size: 10px; font-style: italic;"},
                             "&nbsp;($row->{'gene_shortname'})"
                            )
                          );
     }

     $gene_info .= end_table();
  }
  else {
     $gene_info = "none";
  }

  return $gene_info;
}
# end of get_gene_info_for_ancestor_table()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_073 datetime_of_last_cage_move():                returns datetime string of last move of a cage ("18.04.2005 13:33:44")
sub datetime_of_last_cage_move {                         my $sr_name = 'SR_DB_073';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $cage_id         = $_[1];                           # for which cage do we want to check datetime of last move?
  my ($result, $rows, $i, $row, $sql, $c2l_datetime_from);
  my @sql_parameters;

  # SQL to get last move
  $sql = qq(select max(c2l_datetime_from)
            from   cages2locations
            where  c2l_cage_id = ?
           );

  @sql_parameters = ($cage_id);

  ($c2l_datetime_from) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($c2l_datetime_from)) {
     return format_sql_datetime2display_datetime($c2l_datetime_from);
  }
  else {
     return '-';
  }
}
# end of datetime_of_last_cage_move()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_074 get_semaphore_lock:                          tries to get a lock via semaphore
sub get_semaphore_lock {                                 my $sr_name = 'SR_DB_074';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $user_id         = $_[1];
  my $session         = $global_var_href->{'session'};   # get session handle
  my $dbh             = $global_var_href->{'dbh'};       # DBI database handle
  my ($try, $is_locked, $mylock_datetime);

  # use module for datetime comparison. Mktime() calculates epoch seconds from (yyyy, mm, dd, hh, mi, ss) input
  use Date::Calc qw(Mktime);

  # try ten times ...
  for ($try=0; $try<10; $try++) {
      # check if another process is currently importing or weaning (=> mylocks.mylock_value = 'locked')
      ($is_locked, $mylock_datetime) = $dbh->selectrow_array("select mylock_value, mylock_datetime
                                                              from   mylocks
                                                              where  mylock_id = 1
                                                             ");

      # if lock not set by others (or lock is older than 60 seconds) ...
      if ($is_locked eq 'unlocked' || !defined($is_locked) || Delta_seconds(format_sql_datetime2display_datetime($mylock_datetime), get_current_datetime_for_display()) > 120) {
         # ... get the lock quickly!
         $dbh->do("update  mylocks
                   set     mylock_value = ?, mylock_session = ?, mylock_user_id = ?, mylock_datetime = ?
                   where   mylock_id = 1
                  ", undef, "locked", $session->id(), $user_id, get_current_datetime_for_sql()
                  );

         # and leave the loop to start with transaction
         last;
      }
      # else if lock set by others: wait some seconds and continue with loop
      else {
         sleep(1);
      }
  }

  # obviously, we left the loop after ten trials and still did not get a lock
  if ($try > 9) {
     &error_message_and_exit($global_var_href, "ERROR: could not get write lock! This could be due to concurrent users trying to write to the database at the same time. You may go back and try again. ", "");
  }
}
# end of get_semaphore_lock()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_075 release_semaphore_lock:                      release a semaphore lock
sub release_semaphore_lock {                             my $sr_name = 'SR_DB_075';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $user_id         = $_[1];
  my $session         = $global_var_href->{'session'};   # get session handle
  my $dbh             = $global_var_href->{'dbh'};       # DBI database handle

  # reset semaphore (release lock for other processes)
  $dbh->do("update  mylocks
            set     mylock_value = ?, mylock_session = ?, mylock_user_id = ?, mylock_datetime = ?
            where   mylock_id = 1
           ", undef, "unlocked", $session->id(), $user_id, get_current_datetime_for_sql()
          );
}
# end of release_semaphore_lock()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_076 give_me_a_cage:                              returns a cage id that was not in use since a given datetime
sub give_me_a_cage {                                     my $sr_name = 'SR_DB_076';
  my $global_var_href      = $_[0];                      # get reference to global vars hash
  my $datetime_of_move_sql = $_[1];
  my $dbh                  = $global_var_href->{'dbh'};  # DBI database handle
  my @cage_candidates;
  my $cage_candidate;
  my ($how_many_used_after_move, $next_free_cage);
  my ($sql, $result, $rows, $row, $i);
  my $found_cage = 'false';                             # init with 'false' (no cage found that can be used)
  my @sql_parameters;

  # get candidate cages: a good selection to start from is to take all cages that are not in use *now*
  $sql = qq(select cage_id
            from   cages
            where  cage_occupied  = ?
                   and cage_id   <> ?
            order  by cage_id asc
           );

  @sql_parameters = ('n', 99999);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      push(@cage_candidates, $row->{'cage_id'});
  }

  # so far, we have a list of all cage candidates that are not in use *now*. Within those, we need to find a cage that has not been in use since
  # the given datetime of move

  # so loop over all these candidate cages and try to find one that was not occupied in the time between move and now. Take the first one (the one with the lowest id)
  foreach $cage_candidate (@cage_candidates) {
     $next_free_cage = $cage_candidate;

     # how many entries past given datetime of move for this candidate?
     ($how_many_used_after_move) = $dbh->selectrow_array("select count(*) as how_many_used_after_move
                                                          from   mice2cages
                                                          where          m2c_cage_id =   $cage_candidate
                                                                 and m2c_datetime_to >= '$datetime_of_move_sql'
                                                         ");
     # Zero? We found one we can use!
     if ($how_many_used_after_move == 0) {
        $found_cage = 'true';
        last;                                 # leave the loop, skip remaining candidates, we take the first one
     }
  }

  # in case we did not find a suitable cage, return undef
  if ($found_cage eq 'false') {
     undef($next_free_cage);
  }

  return $next_free_cage;
}
# end of give_me_a_cage()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_077 double_earmarks_in_cage ():                  returns yes if double earmarks in a given cage
sub double_earmarks_in_cage {                            my $sr_name = 'SR_DB_077';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $cage_id         = $_[1];                           # for which cage do we want to find out where it is currently placed?
  my ($earmark_max_count, $sql);
  my @sql_parameters;

  # returns the maximum number of identical earmarks in a given cage
  $sql = qq(select max(number) as earmark_max_count
            from ( select count(mouse_id) as number, mouse_earmark
                   from   mice2cages
                          join mice on mouse_id = m2c_mouse_id
                   where  m2c_cage_id = ?
                          and m2c_datetime_to IS NULL
                   group  by mouse_earmark
                 ) earmark_count
           );

  @sql_parameters = ($cage_id);

  ($earmark_max_count) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if ($earmark_max_count > 1) {
     return 'yes';
  }
  else {
     return 'no';
  }
}
# end of double_earmarks_in_cage ()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_078 get_first_genotype ():                       returns first genotype of a mouse
sub get_first_genotype {                                 my $sr_name = 'SR_DB_078';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # which mouse?
  my ($sql, $gene_name, $genotype, $max_gene_order, $gene_number);
  my @sql_parameters;

  # get highest m2g_gene_order
  $sql = qq(select max(m2g_gene_order) as max_gene_order
            from   mice2genes
                   join genes on m2g_gene_id = gene_id
            where  m2g_mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($max_gene_order) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (!defined($max_gene_order)) {
     return (undef, undef);
  }

  # get name and genotype for this gene_order
  $sql = qq(select gene_name, m2g_genotype
            from   mice2genes
                   join genes on m2g_gene_id = gene_id
            where        m2g_mouse_id = ?
                   and m2g_gene_order = ?
           );

  @sql_parameters = ($mouse_id, $max_gene_order);

  ($gene_name, $genotype) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # how many genotypes for this mouse?
  $sql = qq(select count(*)
            from   mice2genes
            where  m2g_mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($gene_number) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # in case of more than one genotype, add a symbol to indicate this
  if ($gene_number > 1) {
     $genotype .= ' [*]';
  }

  return ($gene_name, $genotype);
}
# end of get_first_genotype()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_079 records_for_this_mouse ():                   returns link to records for this mouse
sub records_for_this_mouse {                             my $sr_name = 'SR_DB_079';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up strain id?
  my $parameterset    = $_[2];
  my $orderlist_id    = $_[3];
  my $url             = url();
  my ($sql, $number_of_medical_records);
  my @sql_parameters;

  # get name an genotype for this gene_order
  $sql = qq(select count(*) as number_of_medical_records
            from   mice2medical_records
                   join medical_records on m2mr_mr_id = mr_id
            where            m2mr_mouse_id = ?
                    and mr_orderlist_id = ?
           );

  @sql_parameters = ($mouse_id, $orderlist_id);

  ($number_of_medical_records) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($number_of_medical_records) && $number_of_medical_records > 0) {
     return (a({-href=>"?choice=show_mouse_phenotyping_records&mouse_id=$mouse_id&parameterset_id=$parameterset"}, $number_of_medical_records));
  }
  else {
     return ('none yet');
  }
}
# end of records_for_this_mouse()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_080 get_epoch_week():                            returns epoch week for a given date
sub get_epoch_week {                                     my $sr_name = 'SR_DB_080';
  my $global_var_href  = $_[0];                          # get reference to global vars hash
  my $date             = $_[1];
  my ($sql, $epoch_week, $the_date);
  my @sql_parameters;

  # extract the date part from current datetime
  ($the_date, undef) = split(/\s/, $date);

  # query current epoch week
  $sql = qq(select day_epoch_week
            from   days
            where  day_date = ?
           );

  @sql_parameters = ($the_date);

  ($epoch_week) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $epoch_week;

}
# end of get_current_epoch_week()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_081 get_cage_color_popup_menu                   returns a HTML popup menu of all cage card bar colors
sub get_cage_color_popup_menu {                         my $sr_name = 'SR_DB_081';
  my $global_var_href = $_[0];                          # get reference to global vars hash
  my $default_color   = $_[1];
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  unless (defined($default_color)) { $default_color = 1; }

  $sql = qq(select setting_key, setting_value_text
            from   settings
            where  setting_category = ?
                   and setting_item = ?
            order  by setting_key asc
           );

  @sql_parameters = ('menu', 'cardcolors_for_popup');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and generate gene lookup hash table
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'setting_key'}} = $row->{'setting_value_text'};
  }

  @values = sort keys %labels;

  $menu = popup_menu( -name    => "card_color",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_color
          );

  return ($menu);
}
# end of get_cage_color_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_082 get_cage_color_by_id():                      returns color code by id
sub get_cage_color_by_id {                               my $sr_name = 'SR_DB_082';
  my $global_var_href  = $_[0];                          # get reference to global vars hash
  my $color_id         = $_[1];
  my ($sql, $color_code);
  my @sql_parameters;

  # query current epoch week
  $sql = qq(select setting_value_text
            from   settings
            where  setting_category = ?
                   and setting_key = ?
           );

  @sql_parameters = ('cardcolors_for_popup', $color_id);

  ($color_code) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $color_code;
}
# end of get_cage_color_by_id()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_083 get_user_projects_colleagues ():             returns list of users that share projects with a given user
sub get_user_projects_colleagues {                       my $sr_name = 'SR_DB_083';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $user_id         = $_[1];                           # for which user do we want to get projects?
  my ($sql, $result, $rows, $row, $i);
  my @colleagues = ();
  my @sql_parameters;
  my @user_projects     = get_user_projects($global_var_href, $user_id);
  my $user_projects_sql = join(',', @user_projects);

  $sql = qq(select u2p_user_id
            from   users2projects
            where  u2p_project_id in ($user_projects_sql)
                   and u2p_project_id != 1
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # loop over results and collect project ids in @projects
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      push(@colleagues, $row->{'u2p_user_id'});
  }

  return @colleagues;
}
# end of get_user_projects_colleagues ()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_084 get_parametersets_popup_menu                returns a HTML popup menu of all parametersets
sub get_parametersets_popup_menu {                      my $sr_name = 'SR_DB_084';
  my $global_var_href      = $_[0];                     # get reference to global vars hash
  my $default_parameterset = $_[1];
  my $menu_name            = $_[2];                     # (optional: menu name)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  unless (defined($default_parameterset)) { $default_parameterset = 1;              }
  unless (defined($menu_name))            { $menu_name            = 'parameterset'; }

  $sql = qq(select parameterset_id, parameterset_name
            from   parametersets
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and generate gene lookup hash table
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'parameterset_id'}} = $row->{'parameterset_name'};
  }

  @values = sort {$labels{$a} cmp $labels{$b}} keys %labels;

  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_parameterset
          );

  return ($menu);
}
# end of get_parametersets_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_085 get_pathoID ():                              returns patho id for a given mouse
sub get_pathoID {                                        my $sr_name = 'SR_DB_085';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to look up project id?
  my ($patho_id, $sql);
  my @sql_parameters;

  $sql = qq(select m2pr_mouse_id, property_value_text as patho_id
            from   mice
                   left join mice2properties on    mouse_id = m2pr_mouse_id
                   left join properties      on property_id = m2pr_property_id
            where               mouse_id = ?
                   and property_category = ?
                   and      property_key = ?
           );

  @sql_parameters = ($mouse_id, 'mouse', 'pathoID');

  (undef, $patho_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($patho_id)) {
     return $patho_id;
  }
  else {
     return "";
  }
}
# end of get_pathoID()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_086 get_genotypes_as_hash():                     returns a genotype hash
sub get_genotypes_as_hash {                              my $sr_name = 'SR_DB_086';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my ($sql, $result, $rows, $row, $i);
  my %labels;
  my @sql_parameters;


  $sql = qq(select setting_key, setting_value_text
            from   settings
            where  setting_category = ?
                   and setting_item = ?
           );

  @sql_parameters = ('menu', 'genotypes_for_popup');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'setting_key'}} = $row->{'setting_value_text'};        # create look-up hash table: key->value
  }

  return \%labels;
}
# end of get_genotypes_as_hash()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_087 get_origin():                                returns origin of a mouse as string for cage card
sub get_origin {                                         my $sr_name = 'SR_DB_087';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];
  my ($sql, $result, $rows, $row, $i);
  my ($mouse_origin_type, $mouse_import_id, $mouse_litter_id, $mating_id);
  my @sql_parameters;

  $sql = qq(select mouse_origin_type, mouse_import_id, mouse_litter_id
            from   mice
            where  mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($mouse_origin_type, $mouse_import_id, $mouse_litter_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if ($mouse_origin_type eq 'weaning') {
     if (defined($mouse_litter_id)) {
        # get mating id by litter id
        $sql = qq(select litter_mating_id
                  from   litters
                  where  litter_id = ?
                 );

        @sql_parameters = ($mouse_litter_id);

        ($mating_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

        return "M $mating_id";
     }
     else {
       return 'M ???';
     }
  }
  elsif ($mouse_origin_type eq 'import') {
     return "I $mouse_import_id";
  }
  elsif ($mouse_origin_type eq 'import_external') {
     return "I $mouse_import_id";
  }
  else {
     return 'unknown';
  }

  return 'unknown';
}
# end of get_origin()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_088 get_candidate_orderlists_table():            returns a HTML table of candidate orderlists for given mice and parameterset
sub get_candidate_orderlists_table {                     my $sr_name = 'SR_DB_088';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_list_ref  = $_[1];                           # reference on mouse list
  my $parameterset    = $_[2];
  my $table_bgcolor   = $_[3];
  my ($result, $rows, $i, $row, $orderlist_table, $sql, $mice_on_orderlist, $number_of_medical_records);
  my @mice = @{$mouse_list_ref};
  my @sql_parameters;
  my @orderlist_ids;
  my @radio_buttons;
  my %radio_labels;
  my $url = url();

  # make mouse list SQL-compatible
  my $sql_mouse_list = qq(') . join(qq(','), @mice) . qq(');

  # genotype information
  $sql = qq(select orderlist_id, orderlist_name, orderlist_date_scheduled, orderlist_parameterset,
                   orderlist_status, parameterset_name, day_week_in_year, day_year
            from   orderlists
                   join parametersets on  orderlist_parameterset = parameterset_id
                   join projects      on parameterset_project_id = project_id
                   join days                         on day_date = orderlist_date_scheduled
            where  orderlist_id in ( select m2o_orderlist_id
                                     from   mice2orderlists
                                     where  m2o_mouse_id in ($sql_mouse_list)
                                   )
                   and orderlist_parameterset = ?;
           );

  @sql_parameters = ($parameterset);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # if there are no orderlists for given parameterset and given mouse list, notify
  if ($rows == 0) {
     $orderlist_table = "no_orderlist";

     return $orderlist_table;
  }

  # (else continue)
  $orderlist_table = start_table({-border=>1, -bgcolor=>$table_bgcolor})
              . Tr(
                  th('select'),
                  th('orderlist name'),
                  th('parameterset'),
                  th('status'),
                  th('mice'),
                  th('medical records' . br() . 'in database' . br() . 'from this orderlist'),
                  th('comment')
                );

  # loop over orderlists
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      $orderlist_ids[$i] = $row->{'orderlist_id'};
      $radio_labels{$row->{'orderlist_id'}} = '';
  }

  @radio_buttons = radio_group(-name=>'orderlist_id', -values=>\@orderlist_ids, -labels=>\%radio_labels);

  # loop over all results from previous select
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      # count mice on this orderlist
      $sql = qq(select count(m2o_mouse_id) as mice_on_orderlist
                from   mice2orderlists
                where  m2o_orderlist_id = ?
             );

      @sql_parameters = ($row->{'orderlist_id'});

      ($mice_on_orderlist) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      # count medical records already in database from this orderlist and parameterset
      $sql = qq(select count(mr_id) as number_mrs
                from   medical_records
                where  mr_orderlist_id = ?
             );

      @sql_parameters = ($row->{'orderlist_id'});

      ($number_of_medical_records) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

      # add table row for current line
      $orderlist_table .= Tr(
                            td({-align=>'center'}, $radio_buttons[$i]),
                            td(a({-href=>"$url?choice=orderlist_view&orderlist_id=" . $row->{'orderlist_id'}}, $row->{'orderlist_name'})),
                            td($row->{'parameterset_name'}),
                            td($row->{'orderlist_status'}),
                            td({-align=>'right'}, $mice_on_orderlist),
                            td({-align=>'right'}, $number_of_medical_records),
                            td({-align=>'right'}, ($number_of_medical_records > 0)
                                                  ?span({-class=>'red'}, b('WARNING: data from this orderlist exists'))
                                                  :'')
                          );
  }

  $orderlist_table .= end_table()
                    . p();

  return $orderlist_table;
}
# end of get_candidate_orderlists_table()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_089 get_project_name_by_id:                      returns project name for a given project id
sub get_project_name_by_id {                             my $sr_name = 'SR_DB_089';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $project_id      = $_[1];                           # for which project id do we want to look up project name?
  my ($project_name, $sql);
  my @sql_parameters;

  $sql = qq(select project_name
            from   projects
            where  project_id = ?
           );

  @sql_parameters = ($project_id);

  ($project_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $project_name;
}
# end of get_project_name_by_id()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_090 get_user_name_by_id:                         returns user name by given user id
sub get_user_name_by_id {                                my $sr_name = 'SR_DB_090';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $user_id         = $_[1];                           # for which user id do we want to look up name?
  my ($user_name, $contact_first_name, $contact_last_name, $sql);
  my @sql_parameters;

  $sql = qq(select user_name, contact_first_name, contact_last_name
            from   users
                   join contacts on contact_id = user_contact
            where  user_id = ?
           );

  @sql_parameters = ($user_id);

  ($user_name, $contact_first_name, $contact_last_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return "$user_name ($contact_first_name $contact_last_name)";
}
# end of get_user_name_by_id()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_091 get_orderlist_details():                     returns some details for an orderlist by id
sub get_orderlist_details {                              my $sr_name = 'SR_DB_091';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $orderlist_id    = $_[1];
  my $table_bgcolor   = $_[2];
  my $cell_color      = $_[3];
  my ($sql, $number_of_medical_records);
  my @sql_parameters;
  my $url = url();
  my ($orderlist_name, $orderlist_date_scheduled, $orderlist_parameterset, $orderlist_status, $parameterset_name);
  my ($orderlist_table, $mice_on_orderlist);

  # genotype information
  $sql = qq(select orderlist_id, orderlist_name, orderlist_date_scheduled, orderlist_parameterset,
                   orderlist_status, parameterset_name
            from   orderlists
                   join parametersets on  orderlist_parameterset = parameterset_id
                   join projects      on parameterset_project_id = project_id
            where  orderlist_id = ?
           );

  @sql_parameters = ($orderlist_id);

  ($orderlist_id, $orderlist_name, $orderlist_date_scheduled,
   $orderlist_parameterset, $orderlist_status, $parameterset_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # count mice on this orderlist
  $sql = qq(select count(m2o_mouse_id) as mice_on_orderlist
            from   mice2orderlists
            where  m2o_orderlist_id = ?
         );

  @sql_parameters = ($orderlist_id);

  ($mice_on_orderlist) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # count medical records already in database from this orderlist and parameterset
  $sql = qq(select count(mr_id) as number_mrs
            from   medical_records
            where  mr_orderlist_id = ?
         );

  @sql_parameters = ($orderlist_id);

  ($number_of_medical_records) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # build one-line table
  $orderlist_table = start_table({-border=>1, -bgcolor=>$table_bgcolor})
                     . Tr(
                         th('orderlist name'),
                         th('parameterset'),
                         th('status'),
                         th('mice'),
                         th('medical records' . br() . 'in database' . br() . 'from this orderlist'),
                         th('comment')
                       )
                     . Tr(
                         td({-style=>"color: $cell_color;"}, $orderlist_name),
                         td({-style=>"color: $cell_color;"}, $parameterset_name),
                         td({-style=>"color: $cell_color;"}, $orderlist_status),
                         td({-align=>'right', -style=>"color: $cell_color;"}, $mice_on_orderlist),
                         td({-align=>'right', -style=>"color: $cell_color;"}, $number_of_medical_records),
                         td({-align=>'right', -style=>"color: $cell_color;"}, ($number_of_medical_records > 0)
                                                                              ?span({-class=>'red'}, b('WARNING: data from this orderlist exists'))
                                                                              :'')
                       )
                     . end_table();

  return $orderlist_table;
}
# end of get_orderlist_details()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_092 get_cost_account_status:                     returns details about cost_account status
sub get_cost_account_status {                            my $sr_name = 'SR_DB_092';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # which mouse?
  my $url             = url();
  my ($cost_account_id, $cost_account_name, $from, $to, $cost_account_status, $sql);
  my ($result, $rows, $row, $i);
  my @sql_parameters;

  $sql = qq(select cost_account_id, cost_account_name, m2ca_datetime_from, m2ca_datetime_to
            from   mice2cost_accounts
                   left join cost_accounts on m2ca_cost_account_id = cost_account_id
            where  m2ca_mouse_id = ?
            order  by m2ca_datetime_from asc
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  if ($rows > 0) {
     $cost_account_status = start_table({-border=>1})
                            . Tr(
                                th('Cost centre'),
                                th('From'),
                                th('To')
                              );

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         ($cost_account_id, $cost_account_name, $from, $to) = ($row->{'cost_account_id'}, $row->{'cost_account_name'}, $row->{'m2ca_datetime_from'}, $row->{'m2ca_datetime_to'});

         $cost_account_status .= Tr(
                                 td($cost_account_name),
                                 td(format_sql_datetime2display_datetime($from)),
                                 td((defined($to)?format_sql_datetime2display_datetime($to):"&lt;still assigned&gt;"))
                               );
     }

     $cost_account_status .= end_table();
  }
  else {
     $cost_account_status = 'Not assigned to a cost centre.';
  }

  return $cost_account_status;
}
# end of get_cost_account_status ()
#-------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_093 get_cost_centre_popup_menu():                returns a HTML popup menu for cost centres as string
sub get_cost_centre_popup_menu {                         my $sr_name = 'SR_DB_093';
  my $global_var_href     = $_[0];                        # get reference to global vars hash
  my $default_cost_centre = $_[1];                        # (optional: default cost centre)
  my $menu_name           = $_[2];                        # (optional: menu name)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # if no defaults given, set arbitrarily
  unless (defined($default_cost_centre)) { $default_cost_centre = 1;      }
  unless (defined($menu_name))           { $menu_name = 'cost_centre';    }

  $sql = qq(select cost_account_id, cost_account_name
            from   cost_accounts
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and generate user lookup hash table
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'cost_account_id'}} = $row->{'cost_account_name'};
  }

  @values = sort {$labels{$a} cmp $labels{$b}} keys %labels;

  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_cost_centre
                    );

  return ($menu);
}
# end of get_cost_centre_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_094 is_assigned_to_cost_centre:                  returns if a mouse is assigned to a cost centre
sub is_assigned_to_cost_centre {                         my $sr_name = 'SR_DB_094';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # which mouse?
  my $url             = url();
  my ($cost_centre_id, $sql);
  my @sql_parameters;

  $sql = qq(select m2ca_cost_account_id
            from   mice2cost_accounts
            where  m2ca_mouse_id = ?
                   and m2ca_datetime_to IS NULL
           );

  @sql_parameters = ($mouse_id);

  ($cost_centre_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($cost_centre_id)) {
     return $cost_centre_id;
  }
  else {
     return -1;
  }
}
# end of is_assigned_to_cost_centre ()
#-------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_095 get_area_popup_menu():                       returns a HTML popup menu for areas as string
sub get_area_popup_menu {                                my $sr_name = 'SR_DB_095';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $menu_name       = $_[1];                           # (optional: menu name)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  unless (defined($menu_name))  { $menu_name = 'area'; }

  $sql = qq(select distinct location_subbuilding
            from   locations
            where  location_id >= 0
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and generate user lookup hash table
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      if (defined($row->{'location_subbuilding'})) {
         $labels{$row->{'location_subbuilding'}} = $row->{'location_subbuilding'};
      }
  }

  @values = sort keys %labels;

  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels
                    );

  return ($menu);
}
# end of get_area_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_096 get_transfer_id ():                          returns transfer id for given mating (or NULL)
sub get_transfer_id {                                    my $sr_name = 'SR_DB_096';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mating_id      = $_[1];                            # the mating for which to look for a transfer
  my ($sql, $result, $rows, $row, $i);
  my $transfer_id;
  my @sql_parameters;

  $sql = qq(select transfer_id
            from   embryo_transfers
            where  transfer_mating_id = ?
           );

  @sql_parameters = ($mating_id);

  ($transfer_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $transfer_id;
}
# end of get_transfer_id()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_097 get_column_in_upload_file():                 returns the column in a parameterset-specific file containing a specific value
sub get_column_in_upload_file {                          my $sr_name = 'SR_DB_097';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $column_type     = $_[1];                           # what column?
  my $parameterset    = $_[2];                           # parameterset
  my ($sql, $result, $rows, $row, $i, $column);
  my @sql_parameters;

  $sql = qq(select setting_value_int
            from   settings
            where  setting_category = ?
                   and setting_item = ?
                   and setting_key  = ?
           );

  @sql_parameters = ('upload_column', $column_type, $parameterset);

  ($column) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($column);
}
# end of get_column_in_upload_file()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_098 get_blob_by_mr_id():                         returns blob id for a given medical record id
sub get_blob_by_mr_id         {                          my $sr_name = 'SR_DB_098';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mr_id           = $_[1];                           # which medical record id?
  my ($sql, $blob_id);
  my @sql_parameters;

  $sql = qq(select b.blob_id
            from   medical_records
                   join mausdb_blobs.blob_data b on b.blob_id = mr_blob_id
            where  mr_id = ?
           );

  @sql_parameters = ($mr_id);

  ($blob_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($blob_id);
}
# end of get_blob_by_mr_id()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_099 get_mice_of_medical_record:                  returns number of mice assigned to a medical record
sub get_mice_of_medical_record         {                 my $sr_name = 'SR_DB_099';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mr_id           = $_[1];                           # which medical record id?
  my ($sql, $number_of_mice);
  my @sql_parameters;

  $sql = qq(select count(m2mr_mouse_id)
            from   mice2medical_records
            where  m2mr_mr_id = ?
           );

  @sql_parameters = ($mr_id);

  ($number_of_mice) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($number_of_mice);
}
# end of get_mice_of_medical_record()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_100 get_mice_of_blob:                            returns number of mice assigned to a blob
sub get_mice_of_blob         {                           my $sr_name = 'SR_DB_100';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $blob_id         = $_[1];                           # which blob?
  my ($sql, $number_of_mice);
  my @sql_parameters;

  $sql = qq(select count(m2b_mouse_id)
            from   mice2blob_data
            where  m2b_blob_id = ?
           );

  @sql_parameters = ($blob_id);

  ($number_of_mice) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($number_of_mice);
}
# end of get_mice_of_blob()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_101 get_blob_table():                            returns a HTML file/blob table for a given mouse as a string
sub get_blob_table {                                     my $sr_name = 'SR_DB_101';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to get files/blobs?
  my $url             = url();
  my $blob_database   = $global_var_href->{'blob_database'}; # name of the blob_database
  my ($result, $rows, $i, $row, $blob_info, $sql, $file_size);
  my @sql_parameters;

  # get information
  $sql = qq(select blob_id, blob_name, blob_content_type, blob_mime_type, length(UNCOMPRESS(blob_itself)) as file_size,
                   blob_upload_datetime, blob_upload_user, blob_comment
            from   mice2blob_data
                   join $blob_database.blob_data on m2b_blob_id = blob_id
            where  m2b_mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # if there are no files for this mouse, notify
  if ($rows == 0) {
     $blob_info = p("no files stored for this mouse");
     return $blob_info;
  }

  # (else continue)
  $blob_info = start_table( {-border=>1, -summary=>"table"})
                   . Tr(
                       th("file name"),
                       th("file type"),
                       th("file size (Kb)"),
                       th("file uploaded at"),
                       th("file uploaded by"),
                       th("delete")
                     );

  # loop over all results from previous select
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      $file_size = round_number($row->{'file_size'} / 1024, 0);

      # add table row for current file
      $blob_info .= Tr({-align=>'center'},
                          td(a({-href=>"$url?choice=view_file_info&file_id=" . $row->{'blob_id'} . "&file_name=" . $row->{'blob_name'}}, $row->{'blob_name'})),
                          td($row->{'blob_content_type'}),
                          td($file_size),
                          td(format_sql_datetime2display_date($row->{'blob_upload_datetime'})),
                          td(get_user_name_by_id($global_var_href, $row->{'blob_upload_user'})),
                          td(a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id&job=delete_file&file_id=" . $row->{'blob_id'}}, 'delete this file'))
                        );
  }

  $blob_info .= end_table()
                    . p();

  return $blob_info;
}
# end of get_blob_table()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_102 current_user_is_admin:                       returns 'y' if current user has the admin flag
sub current_user_is_admin         {                      my $sr_name = 'SR_DB_102';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $session         = $global_var_href->{'session'};
  my $user_id         = $session->param(-name=>'user_id');
  my ($sql, $is_admin, $query_result);
  my @sql_parameters;

  $sql = qq(select user_id
            from   users
            where  user_id = ?
                   and user_roles like '%a%'
           );

  @sql_parameters = ($user_id);

  ($query_result) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($query_result) && $query_result == $user_id) {
     return 'y';
  }
  else {
     return 'n';
  }
}
# end of current_user_is_admin()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_103 get_projects_checkbox_list():                returns a HTML checkbox list for projects as string
sub get_projects_checkbox_list {                         my $sr_name = 'SR_DB_103';
  my $global_var_href    = $_[0];                        # get reference to global vars hash
  my ($sql, $result, $rows, $row, $i);
  my @values;
  my ($checkbox_list);
  my @sql_parameters;

  $sql = qq(select project_id, project_name
            from   projects
            order  by project_name asc
         );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $checkbox_list .= checkbox(-name=>'user_project_' . $row->{'project_id'}, -label=>$row->{'project_name'}) . br();
  }

  return ($checkbox_list);
}
# end of get_projects_checkbox_list()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_104 get_transfer_info ():                        returns embryo transfer info for given mating (or empty string)
sub get_transfer_info {                                  my $sr_name = 'SR_DB_104';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mating_id       = $_[1];                           # the mating for which to look for a transfer
  my ($sql, $result, $rows, $row, $i);
  my ($transfer_id, $line_name, $strain_name);
  my @sql_parameters;

  $sql = qq(select transfer_id, line_name, strain_name
            from   embryo_transfers
                   left join matings       on     mating_id = transfer_mating_id
                   left join mouse_lines   on   mating_line = line_id
                   left join mouse_strains on mating_strain = strain_id
            where  transfer_mating_id = ?
           );

  @sql_parameters = ($mating_id);

  ($transfer_id, $line_name, $strain_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($transfer_id)) {
     return ' ET #' . $transfer_id . ', ' . $strain_name . ', ' . $line_name;
  }
  else {
     return '';
  }
}
# end of get_transfer_info()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_105 get_blob_table_for_line():                   returns a HTML file/blob table for a given mouse as a string
sub get_blob_table_for_line {                            my $sr_name = 'SR_DB_105';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $line_id        = $_[1];                            # for which line do we want to get files/blobs?
  my $url             = url();
  my $blob_database   = $global_var_href->{'blob_database'}; # name of the blob_database
  my ($result, $rows, $i, $row, $blob_info, $sql, $file_size);
  my @sql_parameters;

  # get information
  $sql = qq(select blob_id, blob_name, blob_content_type, blob_mime_type, length(UNCOMPRESS(blob_itself)) as file_size,
                   blob_upload_datetime, blob_upload_user, blob_comment
            from   line2blob_data
                   join $blob_database.blob_data on l2b_blob_id = blob_id
            where  l2b_line_id = ?
           );

  @sql_parameters = ($line_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # if there are no files for this mouse, notify
  if ($rows == 0) {
     $blob_info = p("no files attached to this line");
     return $blob_info;
  }

  # (else continue)
  $blob_info = start_table( {-border=>1, -summary=>"table"})
                   . Tr(
                       th("file name"),
                       th("file type"),
                       th("file size (Kb)"),
                       th("file uploaded at"),
                       th("file uploaded by")
                     );

  # loop over all results from previous select
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      $file_size = round_number($row->{'file_size'} / 1024, 0);

      # add table row for current file
      $blob_info .= Tr({-align=>'center'},
                          td(a({-href=>"$url?choice=view_file_info&file_id=" . $row->{'blob_id'} . "&file_name=" . $row->{'blob_name'}}, $row->{'blob_name'})),
                          td($row->{'blob_content_type'}),
                          td($file_size),
                          td(format_sql_datetime2display_date($row->{'blob_upload_datetime'})),
                          td(get_user_name_by_id($global_var_href, $row->{'blob_upload_user'}))
                        );
  }

  $blob_info .= end_table()
                . p();

  return $blob_info;
}
# end of get_blob_table_for_line()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_106 get_rack_sanitary_info():                    returns a HTML table for sanitary data of a rack
sub get_rack_sanitary_info {                             my $sr_name = 'SR_DB_106';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $healthreport_id = $_[1];                           # for which healthreport do we want to get details?
  my $type            = $_[2];                           # determine subtype (viruses, bacteria, parasites, ...)
  my $number_mice     = $_[3];                           # how many mice examined?
  my $url             = url();
  my ($result, $rows, $i, $row, $sanitary_info, $sql);
  my @sql_parameters;

  # fetch info
  $sql = qq(select agent_id, agent_type, agent_name,  agent_shortname, hr2ha_number_of_positive_animals
            from   healthreports
                   join healthreports2healthreport_agents on      hr2ha_health_report_id = healthreport_id
                   join healthreport_agents               on hr2ha_healthreport_agent_id = agent_id
            where  healthreport_id = ?
                   and    agent_type = ?
            order  by agent_display_order asc
           );

  @sql_parameters = ($healthreport_id, $type);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # if there are no sanitary data, notify
  if ($rows == 0) {
     $sanitary_info = table({-border=>0}, Tr(td("negative")));
     return $sanitary_info;
  }

  # (else continue)
  $sanitary_info = start_table( {-border=>0, -summary=>"table"});

  # loop over all results from previous select
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      $sanitary_info .= Tr({-align=>'center'},
                          td((($row->{'agent_type'} ne 'virus')?i($row->{'agent_name'}):$row->{'agent_name'})),
                          td("($row->{'hr2ha_number_of_positive_animals'}/$number_mice)")
                        );
  }

  $sanitary_info .= end_table();

  return $sanitary_info;
}
# end of get_rack_sanitary_info()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_107 get_health_agents_checkbox_list():           returns a HTML checkbox list for health agents as string
sub get_health_agents_checkbox_list {                    my $sr_name = 'SR_DB_107';
  my $global_var_href    = $_[0];                        # get reference to global vars hash
  my ($sql, $result, $rows, $row, $i);
  my @values;
  my ($checkbox_list);
  my @sql_parameters;

  $sql = qq(select agent_id, agent_type, agent_name, agent_shortname, agent_comment
            from   healthreport_agents
            order  by agent_display_order asc
         );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  $checkbox_list .= start_table({-border=>0})
                    . Tr(
                        th('type'),
                        th('name'),
                        th('no. of positive mice')
                      );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $checkbox_list .= Tr(
                          td($row->{'agent_type'} . '&nbsp;'),
                          td((($row->{'agent_type'} ne 'virus')?i($row->{'agent_name'}):$row->{'agent_name'}) . '&nbsp;'),
                          td(radio_group(-name=>'agent_' . $row->{'agent_id'}, -label=>'1', -values=>['0'..'3'], -default=>'0'))
                        );
  }

  $checkbox_list .= end_table();

  return ($checkbox_list);
}
# end of get_health_agents_checkbox_list()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_108 get_origin_type ():                          returns origin type of a given mouse
sub get_origin_type {                                    my $sr_name = 'SR_DB_108';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # the mouse for which we search the father
  my ($origin, $sql, $result, $rows, $row, $i);
  my @sql_parameters;

  # check if mouse comes from an import (NOT NULL entry in mouse_import_id)
  $sql = qq(select mouse_import_id as origin
            from   mice
            where  mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($origin) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # it's an import!
  if (defined($origin) && $origin ne '0') {
     return 'import';
  }
  # no import, so check if it's an embryo transfer
  else {
     $sql = qq(select transfer_id as origin
               from   embryo_transfers
                      join matings on transfer_mating_id = mating_id
                      join litters on   litter_mating_id = mating_id
                      join mice    on    mouse_litter_id = litter_id
               where  mouse_id = ?
            );

     @sql_parameters = ($mouse_id);

     ($origin) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

     # it's an embryo transfer!
     if (defined($origin) && $origin ne '0') {
        return 'IVF';
     }

     # no embryo transfer, so it must be a simple mating!
     else {
        return 'mating';
     }
  }

}
# end of get_origin_type()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_109 get_number_of_mice_from_line():              returns number of mice for a given line
sub get_number_of_mice_from_line {                       my $sr_name = 'SR_DB_109';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $line_id         = $_[1];                           # the mouse line
  my $sex             = $_[2];                           # sex
  my $alive           = $_[3];                           # alive? [y/n]
  my $sex_sql         = '';
  my $alive_sql       = '';
  my ($sql, $result, $rows, $row, $i);
  my ($number);
  my @sql_parameters;

  # count males only
  if (defined($sex) && $sex eq 'm') {
     $sex_sql = qq(and mouse_sex = 'm');
  }
  # count females only
  elsif (defined($sex) && $sex eq 'f') {
     $sex_sql = qq(and mouse_sex = 'f');
  }
  # count males and females
  else {
  }

  # count living mice only
  if (defined($alive) && $alive eq 'alive') {
     $alive_sql = qq(and mouse_deathorexport_datetime IS NULL);
  }
  # count dead mice only
  if (defined($alive) && $alive eq 'dead') {
     $alive_sql = qq(and mouse_deathorexport_datetime IS NOT NULL);
  }
  # count living and dead mice
  else {
  }

  $sql = qq(select count(mouse_id) as mice_from_this_line
            from   mice
            where  mouse_line = ?
                   $sex_sql
                   $alive_sql
           );

  @sql_parameters = ($line_id);

  ($number) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($number)) {
     return $number;
  }
  else {
     return 0;
  }
}
# end of get_number_of_mice_from_line()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_110 get_date_when_last_mouse_of_this_line_died:  returns death date for last mouse of a given line
sub get_date_when_last_mouse_of_this_line_died {         my $sr_name = 'SR_DB_110';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $line_id         = $_[1];                           # the mouse line
  my ($sql, $result, $rows, $row, $i);
  my $date;
  my @sql_parameters;

  $sql = qq(select date(max(mouse_deathorexport_datetime))
            from   mice
            where  mouse_line = ?
           );

  @sql_parameters = ($line_id);

  ($date) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($date)) {
     return (format_sql_date2display_date($date), format_sql_datetime2calendar_week_year($global_var_href, $date));
  }
  else {
     return ('', '');
  }
}
# end of get_date_when_last_mouse_of_this_line_died()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_111 get_cohort_table():                          returns a HTML cohort table for a given mouse as a string
sub get_cohort_table {                                   my $sr_name = 'SR_DB_111';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to get cohorts?
  my $url             = url();
  my ($page, $result, $rows, $i, $row, $sql);
  my @sql_parameters;

  # get information
  $sql = qq(select cohort_id, cohort_name, cohort_pipeline
            from   cohorts
                   join mice2cohorts on m2co_cohort_id = cohort_id
            where  m2co_mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # if mouse is not in a cohort, notify
  if ($rows == 0) {
     return 'not in a cohort';
  }

  # (else continue)
  $page = start_table( {-border=>1, -summary=>"table"})
                   . Tr(
                       th("cohort id"),
                       th("cohort name"),
                       th("EUMODIC pipeline"),
                       th("delete")
                     );

  # loop over all results from previous select
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      # add table row for current cohort
      $page .= Tr({-align=>'center'},
                 td(a({-href=>"$url?choice=view_cohort&cohort_id=" . $row->{'cohort_id'}}, $row->{'cohort_id'})),
                 td($row->{'cohort_name'}),
                 td($row->{'cohort_pipeline'}),
                 td(a({-href=>"$url?choice=mouse_details&mouse_id=$mouse_id&job=remove_from_cohort&cohort_id=" . $row->{'cohort_id'}}, 'remove from this cohort'))
               );
  }

  $page .= end_table()
           . p();

  return $page;
}
# end of get_cohort_table()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_112 get_mr_status_codes_list():                  returns an array of medical records status codes
sub get_mr_status_codes_list {                           my $sr_name = 'SR_DB_112';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my ($sql, $result, $rows, $row, $i);
  my @status_codes;
  my @sql_parameters;

  $sql = qq(select setting_key, setting_value_text
            from   settings
            where  setting_category = ?
                   and setting_item = ?
           );

  @sql_parameters = ('menu', 'mr_status_codes');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@status_codes, $row->{'setting_value_text'});
  }

  @status_codes = sort @status_codes;

  return @status_codes;
}
# end of get_mr_status_codes_list()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_113 get_rooms_popup_menu():                      returns a HTML popup menu for mouse lines as string
sub get_rooms_popup_menu {                               my $sr_name = 'SR_DB_113';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my @values;
  my @sql_parameters;

  $sql = qq(select distinct location_room
            from   locations
            where  location_id > 0
                   and location_id < 9999
            order  by length(location_room) asc, location_room asc
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@values, $row->{'location_room'});
  }

  $menu = popup_menu( -name    => "room",
                      -values  => [@values]
                    );

  return ($menu);
}
# end of get_rooms_popup_menu()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_DB_114 get_orderlist_number_by_line_parameterset(): returns number of orderlists for given line and parameterset
sub get_orderlist_number_by_line_parameterset {          my $sr_name = 'SR_DB_114';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_line      = $_[1];
  my $parameterset    = $_[2];
  my ($sql, $result, $rows, $row, $i);
  my @sql_parameters;
  my ($number_of_orderlists, $number_mice);

  $sql = qq(select count(distinct m2o_mouse_id) as no_mice, count(distinct orderlist_id) as no_orderlists
            from   orderlists
                   join mice2orderlists on    orderlist_id = m2o_orderlist_id
                   join mice            on        mouse_id = m2o_mouse_id
                   join mouse_lines     on      mouse_line = line_id
                   join parametersets   on parameterset_id = orderlist_parameterset
            where  parameterset_id = ?
                   and     line_id = ?
           );

  @sql_parameters = ($parameterset, $mouse_line);

  ($number_mice, $number_of_orderlists) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($number_mice, $number_of_orderlists);
}
# end of get_orderlist_number_by_line_parameterset()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_DB_115 get_parameterset_name_by_id:                 returns parameterset name for a given parameterset id
sub get_parameterset_name_by_id {                        my $sr_name = 'SR_DB_115';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $parameterset_id = $_[1];
  my ($parameterset_name, $sql);
  my @sql_parameters;

  $sql = qq(select parameterset_name
            from   parametersets
            where  parameterset_id = ?
           );

  @sql_parameters = ($parameterset_id);

  ($parameterset_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $parameterset_name;
}
# end of get_parameterset_name_by_id()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_116 get_number_medical_records_of_orderlist():   returns number of medical records for given orderlist
sub get_number_medical_records_of_orderlist {            my $sr_name = 'SR_DB_116';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $orderlist       = $_[1];
  my ($sql, $result, $rows, $row, $i);
  my @sql_parameters;
  my $number_of_medical_records;

  $sql = qq(select count(mr_id) as number_of_mrs
            from   medical_records
            where  mr_orderlist_id = ?
           );

  @sql_parameters = ($orderlist);

  ($number_of_medical_records) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($number_of_medical_records);
}
# end of get_number_medical_records_of_orderlist()
#--------------------------------------------------------------------------------------



#--------------------------------------------------------------------------------------o
# SR_DB_117 get_cohort_purposes_popup_menu():            returns a popup menu for cohort purposes
sub get_cohort_purposes_popup_menu {                     my $sr_name = 'SR_DB_117';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my ($sql, $result, $rows, $row, $i);
  my @cohort_purposes;
  my $menu;
  my @sql_parameters;

  $sql = qq(select setting_key, setting_value_text
            from   settings
            where  setting_category = ?
                   and setting_item = ?
           );

  @sql_parameters = ('menu', 'cohort_purpose');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@cohort_purposes, $row->{'setting_value_text'});
  }

  # build popup menu using CGI method
  $menu = popup_menu( -name    => "cohort_purpose",
                      -values  => [@cohort_purposes],
                      -default => 'eumodic'
          );

  return ($menu);
}
# end of get_cohort_purposes_popup_menu()
#-------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_118 get_treatments_table:                        returns details about treatments
sub get_treatments_table {                               my $sr_name = 'SR_DB_118';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # which mouse?
  my $url             = url();
  my ($treatment_table);
  my ($result, $rows, $row, $i, $sql);
  my @sql_parameters;

  $sql = qq(select *
            from   mice2treatment_procedures
                   join treatment_procedures on tp_id = m2tp_treatment_procedure_id
            where  m2tp_mouse_id = ?
            order  by m2tp_treatment_datetime  asc
           );

  @sql_parameters = ($mouse_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # yes, treatments for this mouse
  if ($rows > 0) {
     $treatment_table = start_table({-border=>1})
                        . Tr(
                            th('treatment protocol' . br() . small("(click for details)")),
                            th('date'),
                            th('from - to'),
                            th('success')
                          );

     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $treatment_table .= Tr(
                               td(a({-href=>"$url?choice=mouse_treatment_view&mouse_treatment_id=$row->{'m2tp_id'}&mouse_id=$mouse_id"}, $row->{'tp_treatment_name'})),
                               td(format_sql_date2display_date($row->{'m2tp_treatment_datetime'})),
                               td(format_sql_datetime2display_datetime($row->{'m2tp_application_start_datetime'}) . ' - ' . format_sql_datetime2display_datetime($row->{'m2tp_application_end_datetime'})),
                               td({-align=>'center'}, $row->{'m2tp_treatment_success'})
                             );
     }

     $treatment_table .= end_table();
  }
  # no treatments for this mouse
  else {
     $treatment_table = 'No treatments';
  }

  return $treatment_table;
}
# end of get_treatments_table ()
#-------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_119 get_treatments_popup_menu():                 returns a HTML popup menu of all treatments as string
sub get_treatments_popup_menu {                          my $sr_name = 'SR_DB_119';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # query all treatment protocols
  $sql = qq(select tp_id, tp_treatment_name
            from   treatment_procedures
            order  by tp_treatment_name asc
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__);

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'tp_id'}} = $row->{'tp_treatment_name'};        # create look-up hash table
  }

  # create a list of treatment procedure ids which is alphabetically ordered by the treatment protocol name
  @values = sort {$labels{$a} cmp $labels{$b}} keys %labels;

  # build popup menu using CGI method
  $menu = popup_menu( -name    => "treatment_protocol",
                      -values  => [@values],
                      -labels  => \%labels
          );

  return ($menu);
}
# end of get_treatments_popup_menu()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_120 get_mating_strain_default():                 returns default mating strain for given parent mice
sub get_mating_strain_default {                          my $sr_name = 'SR_DB_120';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_list_href = $_[1];                           # get reference to parent mice list
  my ($sql, $result, $rows, $row, $i);
  my ($parent, $mother_strain, $father_strain, $mating_strain);
  my @values;
  my @sql_parameters;
  my @parents = @{$mouse_list_href};

  # get strains of parents
  foreach $parent (@parents) {
     if (get_sex($global_var_href, $parent) eq 'f') {
        $mother_strain = get_strain($global_var_href, $parent);
     }
     elsif (get_sex($global_var_href, $parent) eq 'm') {
        $father_strain = get_strain($global_var_href, $parent);
     }
  }

  # look up mating strain
  $sql = qq(select ps2ls_litter_strain
            from   parent_strains2litter_strain
            where      ps2ls_mother_strain = ?
                   and ps2ls_father_strain = ?
           );

  @sql_parameters = ($mother_strain, $father_strain);

  ($mating_strain) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (!defined($mating_strain)) {
     $mating_strain = 'please choose';
  }

  return ($mating_strain);
}
# end of get_mating_strain_default()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_121 get_carts_table():                           returns a HTML cart table for a given mouse as a string
sub get_carts_table {                                    my $sr_name = 'SR_DB_121';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to get cohorts?
  my $url             = url();
  my ($page, $result, $rows, $i, $row, $sql, $mice_in_cart);
  my @sql_parameters;
  my @mice;

  # get information
  $sql = qq(select cart_id, cart_name, cart_creation_datetime, cart_content, cart_end_datetime, cart_user, cart_is_public, user_name
            from   carts
                   left join users on user_id = cart_user
            where  cart_content like '%$mouse_id%'
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # if mouse is not in a cohort, notify
  if ($rows == 0) {
     return 'not in a cart';
  }

  # (else continue)
  $page = start_table( {-border=>1, -summary=>"table"})
                   . Tr(
                       th("cart id"),
                       th("cart name"),
                       th("mice in cart"),
                       th("created by"),
                       th("created at")
                     );

  # loop over all results from previous select
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];                # fetch next row

      # regenerate mouse list from comma-separated cart content string
      @mice = split(/,/, $row->{'cart_content'});
      $mice_in_cart = scalar @mice;                 # how many mice in cart

      # add table row for current cohort
      $page .= Tr({-align=>'center'},
                 td(a({-href=>"$url?choice=restore_cart&cart_id=" . $row->{'cart_id'}}, $row->{'cart_id'})),
                 td($row->{'cart_name'}),
                 td($mice_in_cart),
                 td($row->{'user_name'}),
                 td(format_sql_datetime2display_datetime($row->{'cart_creation_datetime'}))
               );
  }

  $page .= end_table()
           . p();

  return $page;
}
# end of get_carts_table()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_122 sterile_mating_warning:                      returns sterile mating_warning, if no litter for more than specified days
sub sterile_mating_warning {                             my $sr_name = 'SR_DB_122';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mating_id       = $_[1];
  my $no_litter_days  = $_[2];
  my ($sql, $no_litter_since);
  my @sql_parameters;

  $sql = qq(select mating_id, datediff(curdate(), date(mating_matingstart_datetime)) as no_litter_since
            from   matings
                   left join litters  on litter_mating_id = mating_id
            where  mating_id = ?
                   and mating_matingend_datetime IS NULL
           );

  @sql_parameters = ($mating_id);

  (undef, $no_litter_since) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if ($no_litter_since > $no_litter_days) {
     return span({-class=>"red"}, b("No litter since $no_litter_since days!"));
  }
  else {
     return "no litter since $no_litter_since days";
  }
}
# end of sterile_mating_warning()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_123 get_genetic_markers_popup_menu_for_line():   returns a HTML popup menu of all genetic markers assigned to a line
sub get_genetic_markers_popup_menu_for_line {            my $sr_name = 'SR_DB_123';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $line            = $_[1];
  my $menu_name       = $_[2];                           # (optional: default menu name)
  my ($sql, $result, $rows, $row, $i);
  my ($menu, $default_gene);
  my %labels;
  my @values;
  my @sql_parameters;

  # is a menu name given?
  unless ($menu_name) { $menu_name = "genetic_marker"; }

  # get only genes that are assigned to given line
  $sql = qq(select gene_id, gene_name
            from   mouse_lines2genes
                   join genes on ml2g_gene_id = gene_id
            where  ml2g_mouse_line_id = ?
            order  by gene_name asc
           );

  @sql_parameters = ($line);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no genes are assigned to given line, get all genes instead!
  unless ($rows > 0) {
     $sql = qq(select gene_id, gene_name
               from   genes
               order  by gene_name asc
           );

     @sql_parameters = ();

     ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );
  }

  # in either case, loop over results and generate gene lookup hash table
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $default_gene = $row->{'gene_id'};

      $labels{$row->{'gene_id'}} = $row->{'gene_name'};
  }

  @values = sort {$labels{$a} cmp $labels{$b}} keys %labels;

  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_gene
          );

  return ($menu);
}
# end of get_genetic_markers_popup_menu_for_line()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_124 get_genotype_qualifiers_for_line():          returns a list of genotype qualifiers for all genes assigned to a line
sub get_genotype_qualifiers_for_line {                   my $sr_name = 'SR_DB_124';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $line            = $_[1];
  my ($sql, $result, $rows, $row, $i);
  my @genotype_qualifiers;
  my @sql_parameters;
  my $collect_qualifiers_string;

  # get only genes that are assigned to given line
  $sql = qq(select gene_id, gene_valid_qualifiers
            from   mouse_lines2genes
                   join genes on ml2g_gene_id = gene_id
            where  ml2g_mouse_line_id = ?
            order  by gene_name asc
           );

  @sql_parameters = ($line);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # if no genes are assigned to given line, get all genotype qualifiers instead!
  if ($rows == 0) {
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
         push(@genotype_qualifiers, $row->{'genotype'});
     }
  }
  # else take genotype qualifiers from genes assigne to the line
  else {
     for ($i=0; $i<$rows; $i++) {
         $row = $result->[$i];

         $collect_qualifiers_string .= $row->{'gene_valid_qualifiers'};
     }

     @genotype_qualifiers = split(/;/, $collect_qualifiers_string);
     @genotype_qualifiers = sort unique_list(@genotype_qualifiers);
  }

  return @genotype_qualifiers;
}
# end of get_genotype_qualifiers_for_line()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_125 get_mothers_cages_for_mating ()              returns rack/cage links for mothers of a mating
sub get_mothers_cages_for_mating {                       my $sr_name = 'SR_DB_125';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mating__id      = $_[1];                           # litter
  my $url = url();
  my ($i, $result, $row, $rows, $sql);
  my $cage_link;
  my @sql_parameters;

  $sql = qq(select location_room, location_rack, cage_id
            from   parents2matings
                   join mice            on p2m_parent_id = mouse_id
                   join mice2cages      on      mouse_id = m2c_mouse_id
                   join cages2locations on   m2c_cage_id = c2l_cage_id
                   join locations       on   location_id = c2l_location_id
                   join cages           on       cage_id = c2l_cage_id
            where  p2m_mating_id = ?
                   and p2m_parent_type = ?
                   and m2c_datetime_to IS NULL
                   and c2l_datetime_to IS NULL
           );

  @sql_parameters = ($mating__id, 'mother');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over all mothers
  for ($i=0; $i<$rows; $i++) {
       $row = $result->[$i];

       # show rack/cage of mother (unless mother is dead)
       if ($row->{'cage_id'} >= 0) {
          $cage_link .= a({-href=>"$url?choice=cage_view&cage_id=" . $row->{'cage_id'}, -title=>"click for cage view"},
                          $row->{'location_room'} . '/' . $row->{'location_rack'} . '-' . &reformat_number($row->{'cage_id'}, 4)) . br();
       }
  }

  return $cage_link;
}
# end of get_mothers_cages_for_mating()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_126 get_number_medical_records_of_parameter():   returns number of medical records for parameter
sub get_number_medical_records_of_parameter {            my $sr_name = 'SR_DB_126';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $parameter       = $_[1];
  my ($sql, $result, $rows, $row, $i);
  my @sql_parameters;
  my $number_of_medical_records;

  $sql = qq(select count(mr_id) as number_of_mrs
            from   medical_records
            where  mr_parameter = ?
           );

  @sql_parameters = ($parameter);

  ($number_of_medical_records) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($number_of_medical_records);
}
# end of get_number_medical_records_of_parameter()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_127 get_number_medical_records_of_parameter_and_parameterset(): returns number of medical records for parameter and -set
sub get_number_medical_records_of_parameter_and_parameterset {            my $sr_name = 'SR_DB_127';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $parameter       = $_[1];
  my $parameterset    = $_[2];
  my ($sql, $result, $rows, $row, $i);
  my @sql_parameters;
  my $number_of_medical_records;

  $sql = qq(select count(mr_id) as number_of_mrs
            from   medical_records
            where            mr_parameter = ?
                   and mr_parameterset_id = ?
           );

  @sql_parameters = ($parameter, $parameterset);

  ($number_of_medical_records) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($number_of_medical_records);
}
# end of get_number_medical_records_of_parameter_and_parameterset()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_128 get_parameter_name_by_id:                    returns parameter name for a given parameter id
sub get_parameter_name_by_id {                           my $sr_name = 'SR_DB_128';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $parameter_id    = $_[1];
  my ($parameter_name, $sql);
  my @sql_parameters;

  $sql = qq(select parameter_name
            from   parameters
            where  parameter_id = ?
           );

  @sql_parameters = ($parameter_id);

  ($parameter_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $parameter_name;
}
# end of get_parameter_name_by_id()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_129 get_cryo_samples():                          returns a HTML cryo samples table for a given mouse as a string
sub get_cryo_samples {                                   my $sr_name = 'SR_DB_129';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # for which mouse do we want to get files/blobs?
  my $url             = url();
  my $cryo_database   = $global_var_href->{'cryo_database'};
  my ($result, $rows, $i, $row, $sql, $sth, $cryo_table);

  # check again if cryo database is configured (in config.rc)
  if (defined($cryo_database)) {

     # try to include module cryo_connect which contains cryo database connection parameters (database name and host, db username and password)
     unless (eval "require cryo_connect") {
         return span({-class=>"red"}, "Could not connect to cryo samples database! Please contact the administrator!");
     }

     # open connection to database, get database handle
     my ($cryo_dbh, undef, undef) = cryo_connect::connect();

     # connection ok? Do we have a database handle?
     if (defined($cryo_dbh)) {

        $sql = qq(select type_name as sample_type, count(smp_id) as number_of_samples
                  from   sample2mice
                         left join mice         on  s2m_mouse_id = mouse_id
                         left join sample       on s2m_sample_id = smp_id
                         left join sample_types on      smp_type = type_id
                  where          mouse_db_url = ?
                         and mouse_foreign_id = ?
                  group  by type_id
               );

        # prepare the SQL statement (or generate error page if that fails)
        $sth = $cryo_dbh->prepare($sql)       or &error_message_and_exit($global_var_href, "SQL error", 'cryo database query' . "-PR");

        # execute the SQL query (or generate error page if that fails)
        $sth->execute('mausdb', $mouse_id)    or &error_message_and_exit($global_var_href, "SQL error", 'cryo database query' . "-EX");

        # read query results using the fetchall_arrayref() method
        $result = $sth->fetchall_arrayref({}) or &error_message_and_exit($global_var_href, "SQL error", 'cryo database query' . "-FE");

        # finish the query (or generate error page if that fails)
        $sth->finish()                        or &error_message_and_exit($global_var_href, "SQL error", 'cryo database query' . "-FI");

        # how many result sets are returned?
        $rows = scalar @{$result};

        if ($rows == 0) {
           return "no cryo samples available for this mouse";
        }

        else {
           $cryo_table = start_table( {-border=>1, -summary=>"table"})
                         . Tr(
                              th("sample type"),
                              th("# samples")
                           );

           # loop over all results from previous select
           for ($i=0; $i<$rows; $i++) {
               $row = $result->[$i];                # fetch next row

               $cryo_table .= Tr({-align=>'center'},
                 td($row->{'sample_type'}),
                 td($row->{'number_of_samples'}),
               );
           }

           $cryo_table .= end_table();

           return $cryo_table;
        }

        # disconnect from cryo database
        $cryo_dbh->disconnect();
     }
     # connection failed, we have no database handle
     else {
        return span({-class=>"red"}, "Cryo database connection failed!");
     }
  }
  # cryo database is not configured in config.rc
  else {
     return span({-class=>"red"}, "Cryo database not configured!");
  }

}
# end of get_cryo_samples()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_130 get_current_cage_mates():                    returns a list of current cagemates for a given cage
sub get_current_cage_mates {                             my $sr_name = 'SR_DB_130';
  my $global_var_href    = $_[0];                        # get reference to global vars hash
  my $cage_id            = $_[1];                        # for which cage do we want to query cagemates?
  my @cagemates          = ();
  my $url                = url();
  my ($sql, $result, $rows, $row, $i, $mouse);
  my @sql_parameters;

  # for the final cage (id = -1), don't return cagemates (as there are too many)
  if ($cage_id == -1) {
     return ('-');
  }


  $sql = qq(select m2c_mouse_id
            from   mice2cages
            where  m2c_cage_id = ?
                   and m2c_datetime_to IS NULL
           );

  @sql_parameters = ($cage_id);

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # loop over results and collect cagemate ids in @cagemates
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      push(@cagemates, $row->{'m2c_mouse_id'});
  }

  # remove multiple entries for each mouse
  @cagemates = unique_list(@cagemates);

  return @cagemates;
}
# end of get_current_cage_mates()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_131 is_value_within_bounds():                    checks if a phenotype value is within predefined bounds
sub is_value_within_bounds {                             my $sr_name = 'SR_DB_131';
  my $global_var_href    = $_[0];                        # get reference to global vars hash
  my $value              = $_[1];
  my $parameter_id       = $_[2];
  my $url                = url();
  my ($sql, $result, $rows, $row, $i, $mouse);
  my @sql_parameters;

  return 'y';
}
# end of is_value_within_bounds()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_132 get_media_path_for_parameterset():           returns media file storage path for parameterset
sub get_media_path_for_parameterset {                    my $sr_name = 'SR_DB_132';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $parameterset_id = $_[1];
  my ($sql, $media_path);
  my @sql_parameters;

  $sql = qq(select setting_value_text
            from   settings
            where  setting_category = ?
                   and setting_item = ?
                   and setting_key  = ?
           );

  @sql_parameters = ('media_path', 'parameterset', $parameterset_id);

  ($media_path) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $media_path;
}
# end of get_media_path_for_parameterset()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_133 get_media_parameter_for_parameterset():      returns media file storage path for parameterset
sub get_media_parameter_for_parameterset {               my $sr_name = 'SR_DB_133';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $parameterset_id = $_[1];
  my ($sql, $media_parameter);
  my @sql_parameters;

  $sql = qq(select setting_value_int
            from   settings
            where  setting_category = ?
                   and setting_item = ?
                   and setting_key  = ?
           );

  @sql_parameters = ('media_parameter', 'parameterset', $parameterset_id);

  ($media_parameter) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $media_parameter;
}
# end of get_media_parameter_for_parameterset()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_134 get_cohort_types_popup_menu():               returns a popup menu for cohort types
sub get_cohort_types_popup_menu {                         my $sr_name = 'SR_DB_134';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my ($sql, $result, $rows, $row, $i);
  my @cohort_types;
  my $menu;
  my @sql_parameters;

  $sql = qq(select setting_key, setting_value_text
            from   settings
            where  setting_category = ?
                   and setting_item = ?
           );

  @sql_parameters = ('menu', 'cohort_type');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@cohort_types, $row->{'setting_value_text'});
  }

  # build popup menu using CGI method
  $menu = popup_menu( -name    => "cohort_type",
                      -values  => [@cohort_types]
          );

  return ($menu);
}
# end of get_cohort_types_popup_menu()
#-------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_135 get_cohorts_popup_menu():                    returns a HTML popup menu for cohorts as string
sub get_cohorts_popup_menu {                             my $sr_name = 'SR_DB_135';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $default_cohort  = $_[1];
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # query all cohorts
  $sql = qq(select cohort_id, cohort_name, cohort_type, cohort_pipeline
            from   cohorts
            order  by cohort_name asc
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'cohort_id'}} = $row->{'cohort_name'} . '_(P' . $row->{'cohort_pipeline'} . '-' .$row->{'cohort_type'}. ')_(ID:' . $row->{'cohort_id'} . ')';
  }

  @values = sort {lc($labels{$a}) cmp lc($labels{$b})} keys %labels;

  # add "undefined"
  unshift(@values, 'none');

  $menu = popup_menu( -name    => "reference_cohort",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_cohort
                    );

  return ($menu);
}
# end of get_cohorts_popup_menu()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_135 mouse_exists():                              returns mouse_id if it exists
sub mouse_exists {                                       my $sr_name = 'SR_DB_135';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];
  my ($sql, $media_parameter);
  my @sql_parameters;
  my $exists_id;

  $sql = qq(select mouse_id
            from   mice
            where  mouse_id = ?
           );

  @sql_parameters = ($mouse_id);

  ($exists_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $exists_id;
}
# end of mouse_exists()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_136 get_R_scripts():                             returns a HTML popup menu for R scripts as string
sub get_R_scripts {                                      my $sr_name = 'SR_DB_136';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my @values;
  my @sql_parameters;

  $sql = qq(select setting_value_text
            from   settings
            where  setting_item = ?
           );

  @sql_parameters = ('r_scripts');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@values, $row->{'setting_value_text'});
  }

  $menu = popup_menu( -name    => "R_script",
                      -values  => [sort @values]
                    );
  return ($menu);
}
# end of get_R_scripts()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_137 get_procedure_status_codes_popup_menu():     returns an ESLIM procedure status codes menu
sub get_procedure_status_codes_popup_menu {              my $sr_name = 'SR_DB_137';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];
  my $m2o_status      = $_[2];
  my ($sql, $result, $rows, $row, $i, $menu);
  my @status_codes;
  my @sql_parameters;
  my %labels;

  # ESLIM procedure status codes are those looking like "ESLIM_PSC_001"
  $sql = qq(select setting_value_text, setting_description
            from   settings
            where  setting_item = ?
                   and setting_description like '%PSC%'
           );

  @sql_parameters = ('mr_status_codes');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__  );

  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $labels{$row->{'setting_value_text'}} = $row->{'setting_value_text'};
  }

  @status_codes = sort {lc($labels{$a}) cmp lc($labels{$b})} keys %labels;

  # add "ok"
  unshift(@status_codes, '');
  $labels{''} = "undefined";

  $menu = popup_menu( -name    => "status_code__" . $mouse_id,
                      -values  => [@status_codes],
                      -labels  => \%labels,
                      -default => 'undefined'
                    );

  return $menu;
}
# end of get_procedure_status_codes_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_138 get_mothers_of_litter ():                    returns mother(s) of a given litter
sub get_mothers_of_litter {                              my $sr_name = 'SR_DB_138';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $litter_id       = $_[1];                           # the litter for which we search the mother(s)
  my ($sql, $result, $rows, $row, $i);
  my @mother_ids;
  my @sql_parameters;

  $sql = qq(select l2p_parent_id as mother_id
            from   litters2parents
            where  l2p_litter_id       = ?
                   and l2p_parent_type = ?
           );

  @sql_parameters = ($litter_id, 'mother');

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      push(@mother_ids, $row->{'mother_id'});
  }

  return \@mother_ids;
}
# end of get_mothers_of_litter()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_139 get_mothers_of_mating ():                    returns mother(s) of a given mating
sub get_mothers_of_mating {                              my $sr_name = 'SR_DB_139';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mating_id       = $_[1];                           # the mating for which we search the mother(s)
  my ($sql, $result, $rows, $row, $i, $mothers);
  my @sql_parameters;

  $sql = qq(select count(p2m_parent_id) as mothers
            from   parents2matings
            where  p2m_mating_id       = ?
                   and p2m_parent_type like "%mother%"
           );

  @sql_parameters = ($mating_id);

  ($mothers) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return $mothers;
}
# end of get_mothers_of_mating()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_140 get_litter_stats ():                         returns stats for a given litter
sub get_litter_stats {                                   my $sr_name = 'SR_DB_140';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $litter_id       = $_[1];                           # the litter for which we search the mother(s)
  my ($sql, $result, $rows, $row, $i);
  my ($litter_weaned_male, $litter_weaned_female, $litter_weaned_total);
  my @sql_parameters;

  # litter weaned male
  $sql = qq(select count(mouse_id)
            from   mice
            where  mouse_litter_id = ?
                   and mouse_sex = ?
           );

  @sql_parameters = ($litter_id, "m");

  ($litter_weaned_male) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  # litter weaned female
  @sql_parameters = ($litter_id, "f");

  ($litter_weaned_female) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $litter_weaned_total = $litter_weaned_male + $litter_weaned_female;

  return ($litter_weaned_male, $litter_weaned_female, $litter_weaned_total);
}
# end of get_litter_stats()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_DB_141 get_mating_father_first_genotype ():         returns first genotype of mating father
sub get_mating_father_first_genotype {                   my $sr_name = 'SR_DB_141';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mating_id       = $_[1];
  my ($sql, $result, $rows, $row, $i);
  my ($father, $father_genotype);
  my @sql_parameters;

  # father
  $sql = qq(select p2m_parent_id as father
            from   parents2matings
            where  p2m_mating_id = ?
                   and p2m_parent_type like "%father%"
           );

  @sql_parameters = ($mating_id);

  ($father) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $father_genotype = get_first_genotype($global_var_href, $father);

  return ($father_genotype);
}
# end of get_mating_father_first_genotype()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_142 get_mating_mother_first_genotype ():         returns first genotype of first mating mother
sub get_mating_mother_first_genotype {                   my $sr_name = 'SR_DB_142';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mating_id       = $_[1];
  my ($sql, $result, $rows, $row, $i);
  my ($mother, $mother_genotype);
  my @sql_parameters;

  # mother
  $sql = qq(select p2m_parent_id as mother
            from   parents2matings
            where  p2m_mating_id = ?
                   and p2m_parent_type like "%mother%"
           );

  @sql_parameters = ($mating_id);

  ($mother) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  $mother_genotype = get_first_genotype($global_var_href, $mother);

  return ($mother_genotype);
}
# end of get_mating_mother_first_genotype()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_143 get_parameter_3_numbers ():                  returns overall min, mean, max of parameter in parameterset
sub get_parameter_3_numbers {                            my $sr_name = 'SR_DB_143';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $parameterset    = $_[1];
  my $parameter       = $_[2];
  my $parameter_type  = $_[3];
  my $orderlist_id    = $_[4];                           # optional: restrict to orderlist_id
  my ($sql, $result, $rows, $row, $i);
  my ($min, $mean, $max);
  my @sql_parameters;
  my $orderlist_sql_term = '';

  # if orderlist_id given, use orderlist filter
  if (defined($orderlist_id) && $orderlist_id =~ /^[0-9]+$/) {
     $orderlist_sql_term = "and mr_orderlist_id = $orderlist_id";
  }

  # makes no sense for text and bool parameters
  if ($parameter_type eq "c" || $parameter_type eq "b" ) {
     return (i("nd"), i("nd"), i("nd")),
  }

  if ($parameter_type eq "f") {
     $sql = qq(select round(min(mr_float), 2) as minimum,
                      round(avg(mr_float), 2) as mean,
                      round(max(mr_float), 2) as maximum
               from   medical_records
               where  mr_parameterset_id = ?
                      and mr_parameter   = ?
                      $orderlist_sql_term
            );
  }
  else {
     $sql = qq(select round(min(mr_integer), 2) as minimum,
                      round(avg(mr_integer), 2) as mean,
                      round(max(mr_integer), 2) as maximum
               from   medical_records
               where  mr_parameterset_id = ?
                      and mr_parameter   = ?
                      $orderlist_sql_term
            );
  }

  @sql_parameters = ($parameterset, $parameter);

  ($min, $mean, $max) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (!defined($min))  { $min  = i("na");}
  if (!defined($mean)) { $mean = i("na");}
  if (!defined($max))  { $max  = i("na");}

  return ($min, $mean, $max);
}
# end of get_parameter_3_numbers()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_144 get_parameter_type ():                       returns type of parameter
sub get_parameter_type {                                 my $sr_name = 'SR_DB_144';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $parameter_id    = $_[1];                           # optional: restrict to orderlist_id
  my ($sql, $result, $rows, $row, $i, $parameter_type);
  my @sql_parameters;

  $sql = qq(select parameter_type
            from   parameters
            where  parameter_id = ?
         );

  @sql_parameters = ($parameter_id);

  ($parameter_type) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($parameter_type);
}
# end of get_parameter_type()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_145 get_contactid_by_userid:                     returns contact id by given user id
sub get_contactid_by_userid {                            my $sr_name = 'SR_DB_145';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $user_id         = $_[1];                           # for which user id do we want to look up name?
  my ($user_name, $contact_first_name, $contact_last_name, $contact_id, $sql);
  my @sql_parameters;

  $sql = qq(select user_name, contact_first_name, contact_last_name, contact_id
            from   users
                   join contacts on contact_id = user_contact
            where  user_id = ?
           );

  @sql_parameters = ($user_id);

  ($user_name, $contact_first_name, $contact_last_name, $contact_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  return ($contact_id);
}
# end of get_contactid_by_userid()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_146 get_contacts_popup_menu():                   returns a HTML popup menu for users as string
sub get_contacts_popup_menu {                            my $sr_name = 'SR_DB_146';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $default_contact = $_[1];                           # (optional: default contact)
  my $menu_name       = $_[2];                           # (optional: menu name)
  my ($sql, $result, $rows, $row, $i);
  my ($menu);
  my %labels;
  my @values;
  my @sql_parameters;

  # if no defaults given, set arbitrarily
  unless (defined($default_contact)) { $default_contact = 1;      }
  unless (defined($menu_name))    { $menu_name    = 'contact'; }

  $sql = qq(select contact_id, contact_first_name, contact_last_name
            from   contacts
           );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over results and generate user lookup hash table
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      
      unless (length($row->{'contact_last_name'}) < 3) {
      	$labels{$row->{'contact_id'}} = "$row->{'contact_first_name'} $row->{'contact_last_name'}";
  	  }
  }

  @values = sort {$labels{$a} cmp $labels{$b}} keys %labels;

  $menu = popup_menu( -name    => "$menu_name",
                      -values  => [@values],
                      -labels  => \%labels,
                      -default => $default_contact
                    );

  return ($menu);
}
# end of get_contacts_popup_menu()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_147 current_app_is_mousenet:                     returns 'y' if current application is mousenet
sub current_app_is_mousenet         {                    my $sr_name = 'SR_DB_147';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $session         = $global_var_href->{'session'};
  my $app			  = $global_var_href->{'application'};

  if (defined($app) && ($app eq 'mousenet')) {
     return 'y';
  }
  else {
     return 'n';
  }
}
# end of current_app_is_mousenet()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_148 is_date_younger:                            returns if a given exp date is younger than an exp start date in DB
sub is_date_younger {                                   my $sr_name = 'SR_DB_148';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # which mouse?
  my $exp_date		  = $_[2];							 # experiment start date
  my $url             = url();
  my ($experiment_id, $sql);
  my @sql_parameters;

  $sql = qq(select m2e_experiment_id
  			from    mice2experiments
			where   m2e_mouse_id = ?
			and m2e_datetime_from > ?
           );

  @sql_parameters = ($mouse_id, $exp_date);

  ($experiment_id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($experiment_id)) {
     return $experiment_id;
  }
  else {
     return -1;
  }
}
# end of is_date_younger ()
#-------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_149 is_mouse_dead_atdate:                        returns if the given date is younger than date of mouse death
sub is_mouse_dead_atdate {                               my $sr_name = 'SR_DB_149';
  my $global_var_href = $_[0];                           # get reference to global vars hash
  my $mouse_id        = $_[1];                           # which mouse?
  my $start_date		  = $_[2];						 # given start date
  my $url             = url();
  my ($id, $sql);
  my @sql_parameters;

  $sql = qq(select mouse_id
				from    mice
				where   mouse_id   						= ?
				and 	mouse_deathorexport_datetime 	< ?
           );

  @sql_parameters = ($mouse_id, $start_date);

  ($id) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

  if (defined($id)) {
     return $id;
  }
  else {
     return -1;
  }
}
# end of is_mouse_dead_atdate ()
#-------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_150 get_olympus_images():                        returns a HTML image table for a given mouse as a string
sub get_olympus_images {                                 my $sr_name = 'SR_DB_150';
  my $global_var_href  = $_[0];                           # get reference to global vars hash
  my $mouse_id         = $_[1];                           # for which mouse do we want to get files/blobs?
  my $olympus_database = $global_var_href->{'olympus_database'};
  my $url              = url();
  my ($result, $rows, $i, $row, $sql, $sth, $cryo_table, $icon_filename, $icon);

  # check again if cryo database is configured (in config.rc)
  if (defined($olympus_database)) {

     # try to include module olympus_connect which contains olympus database connection parameters (database name and host, db username and password)
     unless (eval "require olympus_connect") {
         return span({-class=>"red"}, "Could not connect to olympus image database! Please contact the administrator!");
     }

     # open connection to database, get database handle
     my ($olympus_dbh, undef, undef) = olympus_connect::oconnect();

     # connection ok? Do we have a database handle?
     if (defined($olympus_dbh)) {

        # get info and thumbnail data for all images available for current mouse
        $sql = qq(select att1.attRecName                   as Name,
                         att10.attThumbData                as icon,
                         'http://' + left(attRecComputerName, 7)
                         + '/WebDatabaseClient/dbWebViewer.aspx?NISServerName=' + ServerName
                         + '&DBGUID=' + DbGUID
                         + '&DBNAME=Patho_test1&ImageGUID=' + GUID
                         + '&ImageName=' + attRecName      as URL
                  from   dbo.tb_AttributeTable_16      att16
                         join dbo.tb_DocumentIOType_5  docu  on att16.attRecID = docu.attRecID
                         join dbo.tb_AttributeTable_1  att1  on att16.attRecID = att1.attRecID
                         join dbo.tb_NetImgServers     serv  on serv.id_Server = docu.id_NetImgServer
                         join dbo.tb_AttributeTable_10 att10 on att16.attRecID = att10.attRecID) .
                '  where  att16.F83kzm6N$oEKZEJQiwCxaQA__ = ' . qq("$mouse_id");

        # prepare the SQL statement (or generate error page if that fails)
        $sth = $olympus_dbh->prepare($sql)    or &error_message_and_exit($global_var_href, "SQL error", 'olympus database query' . "-PR");

        # execute the SQL query (or generate error page if that fails)
        $sth->execute()                       or &error_message_and_exit($global_var_href, "SQL error", 'olympus database query' . "-EX");

        # read query results using the fetchall_arrayref() method
        $result = $sth->fetchall_arrayref({}) or &error_message_and_exit($global_var_href, "SQL error", 'olympus database query' . "-FE");

        # finish the query (or generate error page if that fails)
        $sth->finish()                        or &error_message_and_exit($global_var_href, "SQL error", 'olympus database query' . "-FI");

        # how many result sets are returned?
        $rows = scalar @{$result};

        if ($rows == 0) {
           return "no images available for this mouse";
        }

        # there are images, so display them
        else {
           $cryo_table = start_table( {-border=>1, -summary=>"table"})
                         . Tr(
                              th("URL")
                           );

           # loop over all results from previous select
           for ($i=0; $i<$rows; $i++) {
               $row = $result->[$i];

               # get binary thumbnail data from blob field and do some strange replacement
               $icon = $row->{'icon'};
               $icon =~ s/^0x//;

               # write thumbnail data as jpg file to server
               $icon_filename = $global_var_href->{'local_htdoc_basedir'} . '/maustmp/image_' . $row->{'Name'} . '.jpg';
               open(OUTFILE, "> $icon_filename");
               binmode(OUTFILE);
               # pack converts pseudo binary data from Sybase blob field ("FF" as string) into real binary (FF)
               print OUTFILE pack("H*", $icon);
               close(OUTFILE);

               $cryo_table .= Tr({-align=>'center'},
                                 td({-align=>"right"}, a({href=>$row->{'URL'}, -target=>"_blank"},
                                    $row->{'Name'} . img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/maustmp/image_' . $row->{'Name'} . '.jpg', -border=>0, -alt=>'[thumbnail]'})
                                    )
                                 )
                              );
           }

           $cryo_table .= end_table();

           return $cryo_table;
        }

        # disconnect from cryo database
        $olympus_dbh->disconnect();
     }
     # connection failed, we have no database handle
     else {
        return span({-class=>"red"}, "Image database connection failed!");
     }
  }
  # cryo database is not configured in config.rc
  else {
     return span({-class=>"red"}, "Image database not configured!");
  }

}
# end of get_olympus_images()
#--------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------
## SR_DB_151 check_orderlist_data						 returns error or '1' if orderlist is complete with required and valid data  
sub check_orderlist_data {								  my $sr_name = 'SR_DB_151';
	my $global_var_href = $_[0];                           # get reference to global vars hash
	my $orderlist_id    = $_[1];                           # orderlist ID
	my $parameterset_id = $_[2];						   #parameter set ID

	my $dbh = $global_var_href->{'dbh'};  				   # DBI database handle

	my ($metadata_given, $metadata_saved, $metadata_count_required, $metadata_count_given, $metadata_value_empty); 
	my ($param_count_required, $param_count_given, $param_empty_values);
	
	my $sql;
	my @sql_parameters;
	my ($row, $rows, $result);
	
	my ($mouse_id, $mouse_status);
	
	my $error = 1;
	
	#check if metadata is needed for this parameterset
	 ($metadata_given) = $dbh->selectrow_array("select mdd_id
													from metadata_definitions
													where mdd_parameterset_id = $parameterset_id
													and mdd_active_yn = 'y'
                                                    ");
     
     #check if necessary metadata is saved for this orderlist
     if (defined($metadata_given)){
     	
     	($metadata_saved) = $dbh->selectrow_array("select metadata_id
														from   metadata
														where  metadata_orderlist_id = $orderlist_id");
														
		if (defined($metadata_saved)) {
			#check if metadata is complete: required data; count data (metadata definitions); valid data (date/datetime)
			($metadata_count_required) = $dbh->selectrow_array("select count(mdd_id)
																	from   orderlists
																	join metadata_definitions  on orderlist_parameterset = mdd_parameterset_id
																	where  orderlist_id = $orderlist_id
																	and mdd_required = 'y' 
																	and mdd_active_yn = 'y' "
											);
			#there are required values available
			if ($metadata_count_required > 0) {
				($metadata_count_given) = $dbh->selectrow_array("select count(mdd_id)
																	from   orderlists
																	join metadata_definitions  on orderlist_parameterset = mdd_parameterset_id
																	where  orderlist_id = $orderlist_id
																	and mdd_required = 'y'
																	and mdd_active_yn = 'y'
																	and mdd_id in (
    																	select metadata_mdd_id
    																	from   metadata
    																	where  metadata_orderlist_id = $orderlist_id)");	
				unless ($metadata_count_given == $metadata_count_required) {
					#return "Error: required metadata is missing!";
					$error .= "Error: required metadata is missing!<br/>";
				}
			}

			#check for null values or empty values in metadata_value (for required values only)
			($metadata_value_empty) = $dbh->selectrow_array("select metadata_id
																	from orderlists
																	join metadata on orderlist_id = metadata_orderlist_id
																	where orderlist_id = $orderlist_id
																	and mdd_required = 'y'
																	and (metadata_value IS NULL
																	or metadata_value = '')");
			if ($metadata_value_empty > 0) {
				#return "Error: required metadata has empty values!";
				$error .= "Error: required metadata has empty values!<br/>";
			}
			
			#check for invalid values for date/datetime
			
			#get metadata with mdd_type = 'd' (date) or 't' (datetime)
			$sql = qq(select metadata_id, metadata_value, mdd_type
						from orderlists
						join metadata on orderlist_id = metadata_orderlist_id
						join metadata_definitions on mdd_id = metadata_mdd_id
						where (mdd_type = 'd' or mdd_type = 't') 
							and orderlist_id = ?
           );

  			@sql_parameters = ($orderlist_id);
			
			(my $result, my $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

			  for (my $i=0; $i<$rows; $i++) {
			  	
			      $row = $result->[$i];
			      
			      #check date
					if ($row->{'mdd_type'} eq 'd') {
						unless(check_date_ddmmyyyy($row->{'metadata_value'})) {
							#return "Error: check format of metadata date values!";
							$error .= "Error: check format of metadata date values!<br/>";
						}
					}
					
					#check datetime
					if ($row->{'mdd_type'} eq 't') {
						unless (check_datetime_ddmmyyyy_hhmmss($row->{'metadata_value'})) {
							#return "Error: check format of metadata datetime values!";
							$error .= "Error: check format of metadata datetime values!<br/>";
						}
					}
			  }
			
			
		}
		else {
			#return "Error: no metadata saved for this orderlist!";
			$error = "Error: no metadata saved for this orderlist!<br/>";
		}
     }
     
     #check medical records and mice status

	 #for all mice: count required parameters
	($param_count_required) = $dbh->selectrow_array("select count(p2p_parameter_id)
															from orderlists
															join parametersets2parameters on orderlist_parameterset = p2p_parameterset_id
															where p2p_parameter_required = 'y'
															and orderlist_id = $orderlist_id");
															
	#for each mouse: check count required data in medical records
	if ($param_count_required > 0) {
		
		#get all mice from orderlist
		$sql = qq(select m2o_mouse_id 
					from mice2orderlists 
					where m2o_orderlist_id = ?
           );

  		@sql_parameters = ($orderlist_id);
			
		(my $result, my $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

		for (my $i=0; $i<$rows; $i++) {
			
			$row = $result->[$i];
			
			$mouse_id = $row->{'m2o_mouse_id'};
		
			($param_count_given) = $dbh->selectrow_array("select count(p2p_parameter_id)
															from orderlists
															join parametersets2parameters on orderlist_parameterset = p2p_parameterset_id
															where p2p_parameter_required = 'y'
															and orderlist_id = $orderlist_id
															and p2p_parameter_id in 
    															(select mr_parameter
        															from   mice2medical_records
        															join medical_records on m2mr_mr_id = mr_id
        															join parametersets2parameters on (p2p_parameterset_id = mr_parameterset_id and p2p_parameter_id = mr_parameter)
        															where m2mr_mouse_id = $mouse_id
        															and mr_orderlist_id = $orderlist_id
        															and p2p_parameter_required = 'y')");
        	
			#check mouse status
			($mouse_status) = $dbh->selectrow_array("select m2o_status from mice2orderlists
															where m2o_mouse_id = $mouse_id
															and m2o_orderlist_id = $orderlist_id
															and (m2o_status is not null and m2o_status <> '' and m2o_status <> 'ordered')");
        	
        	#check if all required parameters are given
        	unless ($param_count_required == $param_count_given) {
        		
        		unless (defined($mouse_status)) {
        			#return "Error: required medical records are missing for mouse $mouse_id!";
        			$error .= "Error: required medical records are missing for mouse $mouse_id!<br/>";
        		}
        		
        	}
        	
        	#check null values for required values
        	($param_empty_values) = $dbh->selectrow_array("select m2mr_mouse_id
											from   mice2medical_records
											join medical_records on m2mr_mr_id = mr_id
											join parametersets2parameters on (p2p_parameterset_id = mr_parameterset_id and p2p_parameter_id = mr_parameter)
											where           m2mr_mouse_id 			= $mouse_id
											and 			mr_orderlist_id 		= $orderlist_id
											and 			p2p_parameter_required 	= 'y'
											and 			(mr_integer is null and  mr_float is null 
															and mr_bool is null and mr_text is null
															and mr_comment is null)");
											
			if ($param_empty_values > 0) {
				unless (defined($mouse_status)) {
        			#return "Error: required values are empty for mouse $mouse_id!";
        			$error .= "Error: required values are empty for mouse $mouse_id!<br/>";
        		}
			}
											
        	
		} #for each mouse
	}

	return $error;
	
}
#-------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------o
# SR_DB_152 get_olympus_images_link():                   returns a HTML link to images available for a mouse
sub get_olympus_images_link {                             my $sr_name = 'SR_DB_152';
  my $global_var_href  = $_[0];                           # get reference to global vars hash
  my $mouse_id         = $_[1];                           # for which mouse do we want to get files/blobs?
  my $olympus_database = $global_var_href->{'olympus_database'};
  my $url              = url();
  my ($result, $rows, $i, $row, $sql, $sth, $cryo_table, $icon_filename, $icon);

  # check again if cryo database is configured (in config.rc)
  if (defined($olympus_database)) {

     # try to include module olympus_connect which contains olympus database connection parameters (database name and host, db username and password)
     unless (eval "require olympus_connect") {
         return span({-class=>"red"}, "Could not connect to olympus image database! Please contact the administrator!");
     }

     # open connection to database, get database handle
     my ($olympus_dbh, undef, undef) = olympus_connect::oconnect();

     # connection ok? Do we have a database handle?
     if (defined($olympus_dbh)) {

        # get info and thumbnail data for all images available for current mouse
        $sql = qq(select att1.attRecName                   as Name,
                         att10.attThumbData                as icon,
                         'http://' + left(attRecComputerName, 7)
                         + '/WebDatabaseClient/dbWebViewer.aspx?NISServerName=' + ServerName
                         + '&DBGUID=' + DbGUID
                         + '&DBNAME=Patho_test1&ImageGUID=' + GUID
                         + '&ImageName=' + attRecName      as URL
                  from   dbo.tb_AttributeTable_16      att16
                         join dbo.tb_DocumentIOType_5  docu  on att16.attRecID = docu.attRecID
                         join dbo.tb_AttributeTable_1  att1  on att16.attRecID = att1.attRecID
                         join dbo.tb_NetImgServers     serv  on serv.id_Server = docu.id_NetImgServer
                         join dbo.tb_AttributeTable_10 att10 on att16.attRecID = att10.attRecID) .
                '  where  att16.F83kzm6N$oEKZEJQiwCxaQA__ = ' . qq("$mouse_id");

        # prepare the SQL statement (or generate error page if that fails)
        $sth = $olympus_dbh->prepare($sql)    or &error_message_and_exit($global_var_href, "SQL error", 'olympus database query' . "-PR");

        # execute the SQL query (or generate error page if that fails)
        $sth->execute()                       or &error_message_and_exit($global_var_href, "SQL error", 'olympus database query' . "-EX");

        # read query results using the fetchall_arrayref() method
        $result = $sth->fetchall_arrayref({}) or &error_message_and_exit($global_var_href, "SQL error", 'olympus database query' . "-FE");

        # finish the query (or generate error page if that fails)
        $sth->finish()                        or &error_message_and_exit($global_var_href, "SQL error", 'olympus database query' . "-FI");

        # how many result sets are returned?
        $rows = scalar @{$result};

        if ($rows == 0) {
           return "no images available for this mouse";
        }

        # there are images, so display them
        else {
           return "$rows image(s) for this mouse available. Click "
                  . a({-href=>"$url?choice=display_images&mouse_id=$mouse_id", -target=>"_blank"}, "here")
                  . " to view them in a separate window.";
        }

        # disconnect from cryo database
        $olympus_dbh->disconnect();
     }
     # connection failed, we have no database handle
     else {
        return span({-class=>"red"}, "Image database connection failed!");
     }
  }
  # cryo database is not configured in config.rc
  else {
     return span({-class=>"red"}, "Image database not configured!");
  }

}
# end of get_olympus_images_link()
#--------------------------------------------------------------------------------------





# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;