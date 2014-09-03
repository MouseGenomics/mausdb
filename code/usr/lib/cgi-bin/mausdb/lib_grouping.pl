# lib_grouping.pl - a MausDB subroutine library file                                                                                  #
#                                                                                                                                     #
# Subroutines in this file provide grouping and "shopping cart" functions                                                             #
#                                                                                                                                     #
#-------------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                                 #
#-------------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                     #
# SR_GRO001 add_to_cart                                   add selected mice to cart (stored in session)                               #
# SR_GRO002 remove_from_cart                              remove selected mice from cart (stored in session)                          #
# SR_GRO003 save_cart                                     save cart in database                                                       #
# SR_GRO004 keep_in_cart                                  keep selected in cart, remove non-selected (stored in session)              #
# SR_GRO005 add_all_to_cart                               add all mice to cart (stored in session)                                    #
# SR_GRO006 build_cohort_1                                make a cohort from selected mice, first step                                #
# SR_GEN007 build_cohort_2                                make a cohort from selected mice, database transaction                      #
# SR_GRO008 remove_males_from_cart                        remove male mice from cart (stored in session)                              #
# SR_GRO009 remove_females_from_cart                      remove female mice from cart (stored in session)                            #
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
# SR_GRO001 add_to_cart                                   add selected mice to cart (stored in session)
sub add_to_cart {                                         my $sr_name = 'SR_GRO001';
  my ($global_var_href) = @_;                                     # get reference to global vars hash
  my $session = $global_var_href->{'session'};                    # get session handle
  my ($selected_mice_string, $number_of_mice, $existing_cart);
  my @total_mice = ();

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # get number of selected mice
  $number_of_mice = scalar @selected_mice;

  # no mice have been selected; do nothing, just notify
  if ($number_of_mice == 0) {
     return p("no mice selected, none added to cart")
            . hr();
  }

  # else continue. Read existing cart from session, if exists
  if (defined($session->param('cart'))) {
     $existing_cart = $session->param('cart');
     @total_mice = split(/,/, $existing_cart);                    # fill @total_mice with those from existing cart
  }

  # now add newly selected to @total_mice
  push(@total_mice, @selected_mice);

  # make the list non-redundant
  @total_mice = unique_list(@total_mice);

  # serialize list
  $selected_mice_string = join(",", @total_mice);

  # ... and store it to session
  $session->param(-name=>'cart', -value=>"$selected_mice_string");

  return p('Added ' . (($number_of_mice == 1)?"1 mouse":"$number_of_mice mice") . ' to cart')
         . hr();
}
# end of add_to_cart
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_GRO002 remove_from_cart                              remove selected mice from cart (stored in session)
sub remove_from_cart {                                    my $sr_name = 'SR_GRO002';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $session = $global_var_href->{'session'};            # get session handle
  my ($selected_mice_string, $number_of_mice, $existing_cart);
  my @total_mice = ();
  my @reduced_list;

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # get number of selected mice
  $number_of_mice = scalar @selected_mice;

  # no mice have been selected, exit
  if ($number_of_mice == 0) {
     return p("no mice selected")
            . hr();
  }

  # else continue. Read existing cart from session, if exists
  if (defined($session->param('cart'))) {
     $existing_cart = $session->param('cart');
     @total_mice = split(/,/, $existing_cart);            #  fill @total_mice with those from existing cart
  }

  # now remove @selected_mice from @total_mic
  @reduced_list = @{diff_list(\@total_mice, \@selected_mice)};         # diff_list(): see lib_functions.pl

  # serialize list
  $selected_mice_string = join(",", @reduced_list);

  # and store to session
  $session->param(-name=>'cart', -value=>"$selected_mice_string");

  # if cart is empty (deleted last mouse): clear cart
  if ($selected_mice_string eq "") {
     $session->clear(["cart"]);
  }

  return p('Removed selected mice from cart')
         . hr();
}
# end of remove_from_cart
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_GRO003 save_cart                                     save cart in database
sub save_cart {                                           my $sr_name = 'SR_GRO003';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $cart_name         = param('cart_name');
  my $cart_is_public    = param('cart_is_public');
  my $datetime_sql      = get_current_datetime_for_sql();
  my $session           = $global_var_href->{'session'};            # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $username          = $session->param(-name=>'username');
  my $dbh               = $global_var_href->{'dbh'};                # DBI database handle
  my ($mouse_ids, $id, $new_cart_id);
  my ($sql, $result, $rows, $row, $i, $rc);
  my @id_list     = ();
  my @sql_id_list = ();
  my %cart_names  = ();
  my @suffices    = ('aa'..'zz');                                   # plenty of suffices for cart name modification (26x26)
  my $suffix;
  my $unquoted_cart_name;
  my @sql_parameters;

  # read current cart content from session ...
  $mouse_ids = $session->param('cart');               # it is a string
  @id_list = split(/\W/, $mouse_ids);                 # split string to get array

  if (defined(param('cart_is_public')) && param('cart_is_public') eq 'y' ) {
     $cart_is_public = 'y';
  }
  else {
     $cart_is_public = 'n';
  }

  # ... check cart content for formally being MausDB ids
  foreach $id (@id_list) {
    if ($id =~ /^[0-9]{8}$/) {
       push(@sql_id_list, $id);
    }
  }

  # no mice have been selected, so do nothing but notify
  if (scalar @sql_id_list == 0) {
     return p("nothing to save")
            . hr();
  }
  # otherwise save cart to database
  else {
     # first get names of all existing carts for this user
     $sql = qq(select cart_name
               from   carts
               where  cart_user = ?
               order  by cart_creation_datetime
              );

     @sql_parameters = ($user_id);

     ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

     for ($i=0; $i<$rows; $i++) {
        $row = $result->[$i];                # fetch next row

        # create a look-up table to check if name exists
        if ($row->{'cart_name'} =~ s/'(.*)'/$1/g) { $unquoted_cart_name = $1; }
        $cart_names{$unquoted_cart_name}++;
     }

     # if no valid cart name was given by user, create one
     unless (defined($cart_name) && $cart_name ne '') {
        $cart_name = 'cart_' . $username . '_' . get_current_date_for_display();
     }

     # if $cart_name already exists, modify name by adding suffix (repeat until cart name is not already in use)
     while (defined($cart_names{$cart_name}) && $cart_names{$cart_name} > 0) {
        $cart_name =~ s/_.{2}$//g;
        $cart_name .= '_' . shift @suffices;
     }

     #################################################
     # now we have a name for the cart, lets save it
     # begin transaction
     $rc  = $dbh->begin_work;

     # get highest cart id
     ($new_cart_id) = $dbh->selectrow_array("select max(cart_id) as new_cart_id
                                             from   carts
                                            ");
     # use next cart id
     $new_cart_id++;

     $dbh->do("insert
               into    carts (cart_id, cart_name, cart_content, cart_creation_datetime, cart_end_datetime, cart_user, cart_is_public)
               values  (?, ?, ?, ?, NULL, ?, ?)
              ", undef, $new_cart_id, $dbh->quote($cart_name), join(",", @sql_id_list), "$datetime_sql", $user_id, $cart_is_public
             );

     $rc  = $dbh->commit()
     # end of transaction
     #################################################
  }

  &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tsave_cart\t$new_cart_id\t$datetime_sql");

  return p("Saved your cart \"$cart_name\"")
         . hr();
}
# end of save_cart
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_GRO004 keep_in_cart                                  keep selected in cart, remove non-selected (stored in session)
sub keep_in_cart {                                        my $sr_name = 'SR_GRO004';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $session = $global_var_href->{'session'};            # get session handle
  my ($selected_mice_string, $number_of_mice);
  my @reduced_list;

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # get number of selected mice
  $number_of_mice = scalar @selected_mice;

  # no mice have been selected, so do nothing but notify
  if ($number_of_mice == 0) {
     return p("no mice selected, cart not modified")
            . hr();
  }

  # else continue. Remove all but @selected_mice from cart
  @reduced_list = @selected_mice;

  # serialize list
  $selected_mice_string = join(",", @reduced_list);

  # and store to session
  $session->param(-name=>'cart', -value=>"$selected_mice_string");

  # if cart is empty (deleted last mouse): clear cart
  if ($selected_mice_string eq "") {
     $session->clear(["cart"]);
  }

  return p('Removed all but selected mice from cart')
         . hr();
}
# end of keep_in_cart
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_GRO005 add_all_to_cart                               add all mice to cart (stored in session)
sub add_all_to_cart {                                     my $sr_name = 'SR_GRO005';
  my ($global_var_href) = @_;                                       # get reference to global vars hash
  my $session           = $global_var_href->{'session'};            # get session handle
  my ($selected_mice_string, $number_of_mice, $existing_cart);
  my @total_mice = ();

  # read list of selected mice from CGI form
  my @selected_mice = param('all_mice');

  # get number of selected mice
  $number_of_mice = scalar @selected_mice;

  # no mice have been selected; do nothing, just notify
  if ($number_of_mice == 0) {
     return p("no mice selected, none added to cart")
            . hr();
  }

  # else continue. Read existing cart from session, if exists
  if (defined($session->param('cart'))) {
     $existing_cart = $session->param('cart');
     @total_mice = split(/,/, $existing_cart);            #  fill @total_mice with those from existing cart
  }

  # now add newly selected to @total_mice
  push(@total_mice, @selected_mice);

  # make the list non-redundant
  @total_mice = unique_list(@total_mice);

  # serialize list
  $selected_mice_string = join(",", @total_mice);

  # ... and store it to session
  $session->param(-name=>'cart', -value=>"$selected_mice_string");

  return p('Added ' . (($number_of_mice == 1)?"1 mouse":"$number_of_mice mice") . ' to cart')
         . hr();
}
# end of add_all_to_cart
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_GRO006 build_cohort_1                                make a cohort from selected mice, first step
sub build_cohort_1 {                                      my $sr_name = 'SR_GRO006';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my ($page, $sql, $result, $rows, $row, $i);
  my $url                  = url();
  my @mice_to_be_cohorted = ();
  my ($mouse);
  my @sql_parameters;

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_cohorted, $mouse);
     }
     # else ignore ...
  }

  # stop if mouse list is empty (no mice selected)
  if (scalar @mice_to_be_cohorted == 0) {
     $page .= h2("Build a cohort")
              . hr()
              . h3("No mice for cohort selected")
              . p(a({-href=>"javascript:back()"}, "please go back and check your selection"));
     return $page;
  }

  # display form
  $page .= h2("Build a cohort")
           . start_form(-action=>url(), -name=>"myform")
           . hr()
           . h3("1) Please specify a custom name for the cohort")
           . p(textfield(-name => "cohort_name", -size=>"30", -maxlength=>"60", -title=>"specify custom cohort name"))
           . p()

           . h3("2) Please specify the cohort purpose")
           . p(get_cohort_purposes_popup_menu($global_var_href))
           . p()

           . h3("3) Please specify the pipeline (relevant only for EUMODIC cohorts)")
           . p("EUMODIC pipeline"
               . radio_group(-name=>'cohort_pipeline', -values=>['1', '2'], -default=>'a')
             )
           . p()

           . h3("4) Please specify the type of cohort with regards to genotype")
           . p(get_cohort_types_popup_menu($global_var_href))
           . p()

           . h3("5) Please assign a control cohort if appropriate")
           . p(get_cohorts_popup_menu($global_var_href, 0))
           . p()

           . h3("6) Optional: add a cohort description")
           . p(textarea(-name => "cohort_description", -columns=>"80", -rows=>"5", -title=>"cohort description"))
           . p()

           . hidden(-name=>'mouse_select')
           . submit(-name => "choice", -value=>"confirm cohort")
           . hr()
           . p(a({-href=>"javascript:back()"}, "cancel build cohort (go to previous page)"))
           . end_form();

  return $page;
}
# end of build_cohort_1
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_GEN007 build_cohort_2                                make a cohort from selected mice, database transaction
sub build_cohort_2 {                                      my $sr_name = 'SR_GEN007';
  my $global_var_href    = $_[0];                           # get reference to global vars hash
  my $dbh                = $global_var_href->{'dbh'};       # DBI database handle
  my $session            = $global_var_href->{'session'};   # session handle
  my $user_id            = $session->param('user_id');
  my $url                = url();
  my $cohort_name        = param('cohort_name');
  my $cohort_pipeline    = param('cohort_pipeline');
  my $cohort_purpose     = param('cohort_purpose');
  my $cohort_type        = param('cohort_type');
  my $cohort_description = param('cohort_description');
  my $reference_cohort   = param('reference_cohort');
  my ($page, $rc, $sql, $result, $rows, $row, $i);
  my @sql_parameters;
  my @mice_to_be_cohorted = ();
  my ($mouse, $check_cohort_name, $cohort_id, $distinct_lines, $distinct_strains, $sql_mouse_list);
  my $datetime_sql = get_current_datetime_for_sql();      # get current system time

  # read list of selected mice from CGI form
  my @selected_mice = param('mouse_select');

  # check list of mouse ids for formally being MausDB IDs
  foreach $mouse (@selected_mice) {
     if ($mouse =~ /^[0-9]{8}$/) {
        push(@mice_to_be_cohorted, $mouse);
     }
     # else ignore ...
  }

  # convert list of mice to SQL
  $sql_mouse_list = qq(') . join(qq(','), @mice_to_be_cohorted) . qq(');

  # check if cohort_name provided
  if (!defined($cohort_name) || $cohort_name eq '' || length($cohort_name) < 3) {
     $page = p({-class=>"red"}, b("Error: please specify a valid cohort name"));
     return $page;
  }

#   if ($cohort_purpose ne 'eumodic') {
#      $cohort_pipeline = 1;
#   }

  # check if cohort_pipeline provided
  if (!defined($cohort_pipeline) || $cohort_pipeline !~ /^[1-2]{1}$/) {
     $page = p({-class=>"red"}, b("Error: please specify a valid EUMODIC pipeline"));
     return $page;
  }


  ############################################
  # check if more than one mouse line in cohort (not allowed for eumodic cohorts)
# NOTE: inactivated this rule due to exceptions
#   ($distinct_lines) = $dbh->selectrow_array("select  count(distinct mouse_line) as number_lines
#                                              from    mice
#                                              where   mouse_id in ($sql_mouse_list)
#                                             ");
# 
#   if ($cohort_purpose eq 'eumodic' && $distinct_lines > 1) {
#      $page = p({-class=>"red"}, b("Error: mice with different mouse lines in cohort! This is not possible for EUMODIC cohorts!"));
#      return $page;
#   }
  ############################################

  ############################################
  # check if more than one mouse strain in cohort (not allowed for eumodic cohorts)
# NOTE: inactivated this rule due to exceptions
#   ($distinct_strains) = $dbh->selectrow_array("select  count(distinct mouse_strain) as number_strains
#                                                from    mice
#                                                where   mouse_id in ($sql_mouse_list)
#                                               ");
# 
#   if ($cohort_purpose eq 'eumodic' && $distinct_strains > 1) {
#      $page = p({-class=>"red"}, b("Error: mice with different mouse strains in cohort! This is not possible for EUMODIC cohorts!"));
#      return $page;
#   }
  ############################################

  $page .= h2("Build a cohort")
           . hr();

  ############################################################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "SQL error (could not start cohort transaction)", $sr_name . "-" . __LINE__);

#   # is there already a cohort with given name?
#   ($check_cohort_name) = $dbh->selectrow_array("select  count(cohort_id) as number_of_cohorts
#                                                 from    cohorts
#                                                 where   cohort_name = '$cohort_name'
#                                                ");

#   # there is no cohort with this name already, so proceed
#   if ($check_cohort_name == 0) {

     ###########################################################
     # create new cohort

     # get a new cohort id
     ($cohort_id) = $dbh->selectrow_array("select (max(cohort_id)+1) as new_cohort_id
                                           from   cohorts
                                          ");

     # ok, this is only neccessary for the very first cohort when (max(cohort_id)+1) = (NULL + 1) is undefined
     if (!defined($cohort_id))   { $cohort_id = 1;            }
     if ($reference_cohort == 0) { $reference_cohort = undef; }

     $dbh->do("insert
               into   cohorts (cohort_id, cohort_name, cohort_purpose, cohort_pipeline, cohort_description, cohort_status, cohort_datetime, cohort_type, cohort_reference_cohort)
               values (?, ?, ?, ?, ?, ?, ?, ?, ?)
              ", undef,
              $cohort_id, $cohort_name, $cohort_purpose, $cohort_pipeline, $cohort_description, 'new', "$datetime_sql", $cohort_type, $reference_cohort
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert cohort)", $sr_name . "-" . __LINE__);

     ###########################################################
     # add mice to this cohort
     foreach $mouse (@mice_to_be_cohorted) {
         $dbh->do("insert
                   into   mice2cohorts (m2co_mouse_id, m2co_cohort_id)
                   values (?, ?)
              ", undef,
              $mouse, $cohort_id
             ) or &error_message_and_exit($global_var_href, "SQL error (could not insert mouse to cohort)", $sr_name . "-" . __LINE__);
     }

     $page .= p("The following mice have been succesfully added to cohort \"" . a({-href=>"$url?choice=view_cohort&cohort_id=$cohort_id"}, $cohort_name) . "\":")
              . p(join(', ', @mice_to_be_cohorted));
#   }
#   # skip
#   else {
#      $page .= p("Cohort already in use. Please choose another one.");
#   }

  $rc = $dbh->commit or &error_message_and_exit($global_var_href, "SQL error (could not commit cohort transaction)", $sr_name . "-" . __LINE__);

  # end of transaction
  ############################################################################################

  &write_textlog($global_var_href, "$datetime_sql\t$user_id\t" . $session->param('username') . "\tnew_cohort\t$cohort_name\t$cohort_id\t$cohort_type\t$reference_cohort\t$datetime_sql");

  return $page;

}
# end of build_cohort_2
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_GRO008 remove_males_from_cart                        remove male mice from cart (stored in session)
sub remove_males_from_cart {                              my $sr_name = 'SR_GRO008';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $session = $global_var_href->{'session'};            # get session handle
  my ($selected_mice_string, $number_of_mice, $existing_cart, $mouse);
  my @total_mice   = ();
  my @reduced_list = ();

  # else continue. Read existing cart from session, if exists
  if (defined($session->param('cart'))) {
     $existing_cart = $session->param('cart');
     @total_mice = split(/,/, $existing_cart);            #  fill @total_mice with those from existing cart
  }

  # loop over mice in cart
  foreach $mouse (@total_mice) {
     # if current mouse is female, add it to reduced list
     if (get_sex($global_var_href, $mouse) eq 'f') {
        push(@reduced_list, $mouse);
     }
  }

  # serialize list
  $selected_mice_string = join(",", @reduced_list);

  # and store to session
  $session->param(-name=>'cart', -value=>"$selected_mice_string");

  # if cart is empty (deleted last mouse): clear cart
  if ($selected_mice_string eq "") {
     $session->clear(["cart"]);
  }

  return p('Removed males from cart')
         . hr();
}
# end of remove_males_from_cart
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_GRO009 remove_females_from_cart                      remove female mice from cart (stored in session)
sub remove_females_from_cart {                            my $sr_name = 'SR_GRO009';
  my ($global_var_href) = @_;                             # get reference to global vars hash
  my $session = $global_var_href->{'session'};            # get session handle
  my ($selected_mice_string, $number_of_mice, $existing_cart, $mouse);
  my @total_mice   = ();
  my @reduced_list = ();

  # else continue. Read existing cart from session, if exists
  if (defined($session->param('cart'))) {
     $existing_cart = $session->param('cart');
     @total_mice = split(/,/, $existing_cart);            #  fill @total_mice with those from existing cart
  }

  # loop over mice in cart
  foreach $mouse (@total_mice) {
     # if current mouse is male, add it to reduced list
     if (get_sex($global_var_href, $mouse) eq 'm') {
        push(@reduced_list, $mouse);
     }
  }

  # serialize list
  $selected_mice_string = join(",", @reduced_list);

  # and store to session
  $session->param(-name=>'cart', -value=>"$selected_mice_string");

  # if cart is empty (deleted last mouse): clear cart
  if ($selected_mice_string eq "") {
     $session->clear(["cart"]);
  }

  return p('Removed females from cart')
         . hr();
}
# end of remove_females_from_cart
#--------------------------------------------------------------------------------------



# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;