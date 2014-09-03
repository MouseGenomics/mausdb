# lib_admin.pl - a MausDB subroutine library file                                                                                #
#                                                                                                                                #
# Subroutines in this file provide administrative functions                                                                      #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_ADM001 change_password():                           change password                                                         #
# SR_ADM003 admin_overview():                            generates the admin menu                                                #
# SR_ADM004 create_new_user_1():                         create new user, step 1: input dialog                                   #
# SR_ADM005 create_new_user_2():                         create new user, step 2: database transaction                           #
# SR_ADM006 create_new_line_1():                         create new line, step 1: input dialog                                   #
# SR_ADM007 create_new_line_2():                         create new line, step 2: database transaction                           #
# SR_ADM008 create_new_strain_1():                       create new strain, step 1: input dialog                                 #
# SR_ADM009 create_new_strain_2():                       create new strain, step 2: database transaction                         #
# SR_ADM010 global_locks():                              manage global locks                                                     #
# SR_ADM011 create_new_rack_1():                         create new rack, step 1: input dialog                                   #
# SR_ADM012 create_new_rack_2():                         create new rack, step 2: database transaction                           #
# SR_ADM013 create_new_cages_1():                        create new cages, step 1: input dialog                                  #
# SR_ADM014 create_new_cages_2():                        create new cage, step 2: database transaction                           #
# SR_ADM015 create_new_project_1():                      create new project, step 1: input dialog                                #
# SR_ADM016 create_new_project_2():                      create new project, step 2: database transaction                        #
# SR_ADM017 create_new_cost_account_1():                 create new cost account, step 1: input dialog                           #
# SR_ADM018 create_new_cost_account_2():                 create new cost account, step 2: database transaction                   #
# SR_ADM019 create_new_experiment_1():                   create new experiment, step 1: input dialog                             #
# SR_ADM020 create_new_experiment_2():                   create new experiment, step 2: database transaction                     #
# SR_ADM021 create_new_genotype_1 ():                    create new genotype, step 1: input dialog                               #
# SR_ADM022 create_new_genotype_2():                     create new genotype, step 2: database transaction                       #
# SR_ADM023 direct_select_1 ():                          direct SQL select, step 1: input dialog                                 #
# SR_ADM024 direct_select_2 ():                          direct SQL select, step 2: result view                                  #
# SR_ADM025 create_new_parameterset_1():                 create new parameterset, step 1: input dialog                           #
# SR_ADM026 create_new_parameterset_2():                 create new parameterset, step 2: database transaction                   #
# SR_ADM027 create_new_parameter_1():                    create new parameter, step 1: input dialog                              #
# SR_ADM028 create_new_parameter_2():                    create new parameter, step 2: database transaction                      #
# SR_ADM029 add_parameters_to_parameterset_11():         create new parameter, step 1: input dialog                              #
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
# SR_ADM001 change_password():                           change password
sub change_password {                                    my $sr_name = 'SR_ADM001';
  my ($global_var_href)   = @_;                                   # get reference to global vars hash
  my $session             = $global_var_href->{'session'};
  my $dbh                 = $global_var_href->{'dbh'};
  my $min_password_length = $global_var_href->{'min_password_length'};
  my $user_id             = $session->param(-name=>'user_id');
  my $user_name           = $session->param(-name=>'username');
  my $validated           = "true";
  my $url                 = url();                                        # get URL from which script was called
  my $password_md5        = Digest::MD5->new();                           # create a MD5 digest object
  my ($page, $message, $rc, $update_done, $check_user_name, $sql);
  my ($new_password_checksum, $old_password_checksum);
  my @sql_parameters;                                                     # holds variables for prepared SQL statements
  my $datetime_now        = get_current_datetime_for_sql();

  # perform a series of checks on input parameters to:
  #  1) prevent SQL injection attacks
  #  2) make sure that password update will be correct
  ##################################################################################################

  # check if old password is given at all
  if ( param('choice') eq "change password" && !param('old_password') ) {
     $message  = p({-class=>"red"}, "Please enter your old password");
     $validated = "false";
  }

  # check if password contains illegal characters (prevent SQL injections)
  if (param('old_password') && param('old_password') =~ /[^a-zA-Z0-9]/) {
     $message  .= p({-class=>"red"}, "For security reasons, valid passwords may contain numbers and letters only (a-zA-Z0-9)");
     $validated = "false";
  }

  # check if old password is valid
  if ( param('choice') eq "change password" ) {

     # calculate MD5 checksum of old password
     $password_md5->add(param('old_password'));
     $old_password_checksum = $password_md5->hexdigest();

     # now check if a combination of given username and password exists
     $sql = qq(select user_name
               from   users
               where  user_id       = ?
               and    user_password = ?
               and    user_name     = ?
              );

     @sql_parameters = ($user_id, $old_password_checksum, $user_name);

     ($check_user_name) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

     # raise error if password is not correct
     if ($check_user_name ne $user_name) {
        $validated = "false";
        $message  .= p({-class=>"red"}, "Could not validate your old password (it is not correct). Please try again.");
     }
  }

  # check if new password1 is given at all
  if ( param('choice') eq "change password" && !param('new_password1') ) {
     $validated = "false";
     $message  .= p({-class=>"red"}, "Please enter your new password");
  }

  # check if new password1 contains illegal characters (prevent SQL injections)
  if ( param('choice') eq "change password" && param('new_password1') =~ /[^a-zA-Z0-9]/) {
     $message  .= p({-class=>"red"}, "For security reasons, valid passwords may contain numbers and letters only (a-zA-Z0-9)");
     $validated = "false";
  }

  # check if new password has mininum length
  if ( param('choice') eq "change password" && length(param('new_password1')) < $min_password_length ) {
     $validated = "false";
     $message  .= p({-class=>"red"}, "Minimum password length is $min_password_length");
  }

  # check if new password2 (repeat) is given at all
  if ( param('choice') eq "change password" && !param('new_password2') ) {
     $validated = "false";
     $message  .= p({-class=>"red"}, "Please repeat your new password");
  }
  # check if new password2 contains illegal characters
  if ( param('choice') eq "change password" && param('new_password2') =~ /[^a-zA-Z0-9]/ ) {
     $validated = "false";
     $message  .= p({-class=>"red"}, "Please only use the following characters in your new password: a-zA-Z0-9 (in other words: only letters and numbers)");
  }

  # check if both new passwords are identical
  if ( param('choice') eq "change password" && param('new_password1') ne param('new_password2')) {
     $validated = "false";
     $message  .= p({-class=>"red"}, "There is a mismatch between new passwords.");
  }
  # checks done
  ##################################################################################################

  # password change request submitted and validated? if yes, try to update password
  if (param('choice') eq "change password" && $validated eq "true") {

    # calculate MD5 checksum of old password
    $password_md5 = Digest::MD5->new();
    $password_md5->add(param('old_password'));
    $old_password_checksum = $password_md5->hexdigest();

    # calculate MD5 checksum of new password
    $password_md5 = Digest::MD5->reset();
    $password_md5->add(param('new_password1'));
    $new_password_checksum = $password_md5->hexdigest();

    ########################################################
    # begin transaction
    $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during password update (begin transaction failed)", $sr_name . "-" . __LINE__);

    # update password
    $sql = qq(update users
              set    user_password     = '$new_password_checksum'
              where  user_id           = '$user_id'
                     and user_password = '$old_password_checksum'
                     and user_name     = '$user_name'
             );

    $dbh->do($sql) or &error_message_and_exit($global_var_href, "error during password update (update failed)", $sr_name . "-" . __LINE__);

    # check if password change was successful
    $sql = qq(select count(user_id)
              from   users
              where  user_id           = ?
                     and user_password = ?
                     and user_name     = ?
             );

    @sql_parameters = ($user_id, $new_password_checksum, $user_name);

    ($update_done) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__)};

    # no: -> rollback and exit
    if ($update_done != 1) {
       $rc   = $dbh->rollback() or &error_message_and_exit($global_var_href, "error during password update (rollback failed)", $sr_name . "-" . __LINE__);
       $page = p({-class=>"red"}, "Something went wrong when trying to update password (rollback successful).");
       return $page;
    }

    # update ok, so commit
    $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during password update (commit failed)", $sr_name . "-" . __LINE__);

    # end transaction
    ########################################################

    &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tchanged_password");

    # destroy current session ...
    $session->clear(["_IS_LOGGED_IN"]);
    $session->delete();

    # ... and force user to log in again using new password
    &print_login_form($session, "blue", "Your password has been successfully updated." . br() . "You need to log in again using the new password.");
  }

  # if no change request (update button pressed), only display password change form
  # also display form if something was wrong (missing input, new passwords dont fit,...)
  else {
    if   ( defined($message) && $message ne "" ) { $message .= hr(); }
    else                                         { $message .= '';   }

    $page = h2("Change password")
            . hr()
            . p("Please enter old password and new password (twice)")
            . $message
            . start_form(-action => url())
            . table({-border => 0, -summary=>"table"},
               Tr(
                 td({-align=>"right"}, b("old password")),
                 td(password_field(-name=>'old_password', -value=>'', -size=>"40", -maxlength=>"40", -override=>"1"))
               ),
               Tr(
                 td({-align=>"right"}, b("new password")),
                 td(password_field(-name=>'new_password1', -value=>'', -size=>"40", -maxlength=>"40", -override=>"1"))
               ),
               Tr(
                 td({-align=>"right"}, b("repeat new password")),
                 td(password_field(-name=>'new_password2', -value=>'', -size=>"40", -maxlength=>"40", -override=>"1"))
                 )
             )
           . p({-class=>"red"}, "Warning: pressing the &lt;changing password&gt; button will terminate the current session. You will
                                 have to log in again using your new password. ")
           . submit(-name => "choice", -value => "change password") . "&nbsp; &nbsp;"
           . submit(-name => "choice", -value => "cancel")
           . end_form()
           . p("&nbsp;")
           . p("&nbsp;");
  }

  return $page;
}
# change_password
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_ADM003 admin_overview():                            generates the admin menu
sub admin_overview {                                     my $sr_name = 'SR_ADM003';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $url               = url();
  my $session  = $global_var_href->{'session'};          # get session handle
  my $username = $session->param(-name=>'username');
  my $user_id  = $session->param(-name=>'user_id');
  my ($page, $sql);
  my @sql_parameters;

  $page = h2("Adminstration and Settings")

          . ((current_user_is_admin($global_var_href) eq 'y')                                       # check user for being admin
             ?hr()                                                                                  # display admin content

              . h3("Info/Tools")

              . table( {-border=>1},
                   Tr( td(a({-href=>"$url?choice=user_overview"},                          " users "                    )),
                       td("user overview ")
                   ) .
                   Tr( td(a({-href=>"$url?choice=projects_overview"},                      " projects "                 )),
                       td("projects overview ")
                   ) .
                   Tr( td(a({-href=>"$url?choice=genotypes_overview"},                     " genotypes "                )),
                       td("genotypes overview ")
                   ) .
                   Tr( td(a({-href=>"$url?choice=check_database"},                         " check database"            )),
                       td("do some database checks " . b("(please be patient, this will take a while)"))
                   ) .
                   Tr( td(a({-href=>"$url?choice=find_orderlists_with_multiple_uploads"},  " multiple-upload orderlists")),
                       td("find orderlists with multiple uploads " . b("(please be patient, this will take a while)"))
                   ) .
                   Tr( td(a({-href=>"$url?choice=blob_info"},                              " info about blob database " )),
                       td("info about blob database")
                   ) .
                   Tr( td(a({-href=>"$url?choice=stats"},                                  " statistics "               )),
                       td("some basic database statistics ")
                   ) .
                   Tr( td(a({-href=>"$url?choice=log_view"},                               " today's activity log "     )),
                       td("view current activity log ")
                   ) .
                   Tr( td(a({-href=>"$url?choice=direct_select"},                          " direct SQL selects "       )),
                       td("direct SQL selects ")
                   ) .
                   Tr( td(a({-href=>"$url?choice=global_metadata_view"},                   " view global metadata "     )),
                       td("view global metadata ")
                   )
                )
             :''                                                                                    # display non-admin content
            )

          . hr()

          . h3("Settings")

          . table( {-border=>1},
               Tr( td(a({-href=>"$url?choice=change_password", -title=>"click here to change your password"}, "change password" )),
                   td("change password")
               ) .

               ((current_user_is_admin($global_var_href) eq 'y')                                       # check user for being admin
                ?Tr( td(a({-href=>"$url?choice=new_user"},         " new user ")),                     # display admin content
                     td("create a user account ")
                 ) .
                 Tr( td(a({-href=>"$url?choice=new_project"},      " new project ")),
                     td("create a new project ")
                 ) .
                 Tr( td(a({-href=>"$url?choice=new_cost_centre"},  " new cost centre ")),
                     td("create a new cost centre ")
                 ) .
                 Tr( td(a({-href=>"$url?choice=new_experiment"},   " new experiment ")),
                     td("create a new experiment ")
                 ) .
                 Tr( td(a({-href=>"$url?choice=new_line"},         " new line ")),
                     td("create a new mouse line ")
                 ) .
                 Tr( td(a({-href=>"$url?choice=new_strain"},       " new strain ")),
                     td("create a new mouse strain ")
                 ) .
                 Tr( td(a({-href=>"$url?choice=new_rack"},         " new rack ")),
                     td("define a new rack ")
                 ) .
                 Tr( td(a({-href=>"$url?choice=new_cages"},        " new cages ")),
                     td("define new cages ")
                 ) .
                 Tr( td(a({-href=>"$url?choice=new_genotype"},     " new genotype ")),
                     td("define a new genotype ")
                 ) .
                 Tr( td(a({-href=>"$url?choice=global_locks"}, " set or release global locks ")),
                     td("manage global locks (block access to web interface of MausDB for all users except admins) ")
                 )
                :''                                                                                    # display non-admin content
               )
            );

  return $page;
}
# end of admin_overview()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM004 create_new_user_1():                         create new user, step 1: input dialog
sub create_new_user_1 {                                  my $sr_name = 'SR_ADM004';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();                                       # get URL from which script was called
  my ($page, $sql);                                      # standard variables for prepared HTML and prepared SQL
  my @sql_parameters;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new user account")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new user account")

          . hr()

          . start_form({-action => url()})

          . h3("MausDB account")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("username"),
                  td(textfield(-name => "username", -size=>"20", -maxlength=>"20")),
                  td("Please enter the username for the new account")
              ) .
              Tr( th("password"),
                  td(textfield(-name => "password", -size=>"20", -maxlength=>"20")),
                  td("Please enter the password for the new account")
              ) .
              Tr( th("admin rights?"),
                  td(checkbox('user_is_admin', '0', '1', '')),
                  td("Decide if new account will have admin rights ")
              ) .
              Tr( th("user project(s)"),
                  td(get_projects_checkbox_list($global_var_href)),
                  td("New user is assigned to which project(s)? ")
              ) .
              Tr( th("comment"),
                  td(textarea(-name => "user_comment", -columns=>"40", -rows=>"2", -override=>"1")),
                  td("Please enter a comment for the new account")
              )
            )

          . h3("Contact")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( td(b("title")),
                  td(b("first name")),
                  td(b("last name")),
                  td({-align=>"center"}, b("sex"))
              ) .
              Tr( td(textfield(-name => 'title',      -size=>"10", -maxlength=>"10", -title=>"academic title")),
                  td(textfield(-name => 'first_name', -size=>"30", -maxlength=>"30")),
                  td(textfield(-name => 'last_name',  -size=>"30", -maxlength=>"30")),
                  td(radio_group(-name=>'sex',        -values=>['male', 'female'], -default=>'?'))
              ) .
              Tr(
              ) .
              Tr( td({-colspan=>2}, b("function")),
                  td({-align=>"center"}, b("type")),
                  td({-align=>"center"}, b("external"))
              ) .
              Tr( td({-align=>"center",-colspan=>2}, radio_group(-name=>'function',   -values=>['scientist', 'technician', 'animal care taker'], -default=>'?')),
                  td({-align=>"center", -title=>'natural person or institution?'},   radio_group(-name=>'contact_type', -values=>['person', 'institution'], -default=>'person')),
                  td({-align=>"center", -title=>'external with respect to your mouse facility'}, checkbox('is_external', '0', '1', ''))
              ) .
              Tr( td({-colspan=>4}, b("e-mail address(es)"))
              ) .
              Tr( td({-colspan=>4}, textfield(-name => 'email',  -size=>"80", -maxlength=>"80"))
              ) .
              Tr( td({-colspan=>4}, b("comment"))
              ) .
              Tr( td({-colspan=>4}, textarea(-name => "contact_comment", -columns=>"80", -rows=>"3", -override=>"1"))
              )
            )

          . h3("Address")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( td({-colspan=>5}, b("institution"))
              ) .
              Tr( td({-colspan=>5}, textfield(-name => 'institution',  -size=>"80", -maxlength=>"80"))
              ) .
              Tr( td({-colspan=>3}, b("unit")),
                  td({-colspan=>2}, b("other info"))
              ) .
              Tr( td({-colspan=>3}, textfield(-name => 'unit',           -size=>"50", -maxlength=>"80")),
                  td({-colspan=>2}, textfield(-name => 'address_other',  -size=>"30", -maxlength=>"80"))
              ) .
              Tr( td(b("street")),
                  td(b("postal code")),
                  td(b("town")),
                  td(b("state")),
                  td(b("country"))
              ) .
              Tr( td(textfield(-name => 'street',       -size=>"30",  -maxlength=>"50")),
                  td(textfield(-name => 'PLZ',          -size=>"10",  -maxlength=>"50")),
                  td(textfield(-name => 'town',         -size=>"15",  -maxlength=>"50")),
                  td(textfield(-name => 'state',        -size=>"15",  -maxlength=>"50")),
                  td(textfield(-name => 'country',      -size=>"15",  -maxlength=>"50"))
              ) .
              Tr( td({-colspan=>2}, b("phone")),
                  td({-colspan=>3}, b("fax"))
              ) .
              Tr( td({-colspan=>2}, textfield(-name => 'phone',       -size=>"40",  -maxlength=>"50")),
                  td({-colspan=>3}, textfield(-name => 'fax',         -size=>"40",  -maxlength=>"50"))
              ) .
              Tr( td({-colspan=>5}, b("comment"))
              ) .
              Tr( td({-colspan=>5}, textarea(-name => "address_comment", -columns=>"80", -rows=>"3", -override=>"1"))
              )
            )

          . p()

          . submit(-name => "choice", -value => "create new user") . "&nbsp; &nbsp;"
          . CGI->reset(-name=>"reset form")                        . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel")

          . end_form();

  return $page;
}
# end of create_new_user_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM005 create_new_user_2():                         create new user, step 2: database transaction
sub create_new_user_2 {                                  my $sr_name = 'SR_ADM005';
  my ($global_var_href)   = @_;                                        # get reference to global vars hash
  my $session             = $global_var_href->{'session'};             # get session handle
  my $user_id             = $session->param(-name=>'user_id');
  my $user_name           = $session->param(-name=>'username');
  my $min_password_length = $global_var_href->{'min_password_length'};
  my $dbh                 = $global_var_href->{'dbh'};                 # DBI database handle
  my $datetime_now        = get_current_datetime_for_sql();
  my $url = url();                                                     # get URL from which script was called
  my ($page, $sql, $i, $row, $rows, $result, $rc);                     # standard variables for prepared HTML, prepared SQL and SQL query result handling
  my ($password_md5, $password_checksum);
  my ($username_exists, $user_is_admin_sql, $sex_sql, $contact_type_sql);
  my ($new_contact_id, $new_user_id, $new_address_id, $project);
  my ($contact_is_internal_sql);
  my @sql_parameters;
  my @selected_projects;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new user account")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new user account")
          . hr();

  # check input: is username given? minimum length
  if (!param('username') || param('username') eq "" || length(param('username')) < 5) {
     $page .= p({-class=>"red"}, b("Error: please enter a username (at least 5 characters)"));
     return $page;
  }

  ####################################################
  # check if user name exists
  $sql = qq(select user_id
            from   users
            where  user_name = ?
         );

  @sql_parameters = (param('username'));

  ($username_exists) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . __LINE__)};

  if (defined($username_exists)) {
     $page .= p({-class=>"red"}, "Username \"" . param('username') . "\" already exists! Please choose another one.");
     return $page;
  }

  # check if password is given at all
  if (!param('password')) {
     $page .= p({-class=>"red"}, "Please enter a password");
     return $page;
  }

  # check if password contains illegal characters (prevent SQL injections)
  if (param('password') =~ /[^a-zA-Z0-9]/) {
     $page .= p({-class=>"red"}, "For security reasons, valid passwords may contain numbers and letters only (a-zA-Z0-9)");
     return $page;
  }

  # check if password has mininum length
  if (length(param('password')) < $min_password_length ) {
     $page  .= p({-class=>"red"}, "Minimum password length is $min_password_length");
     return $page;
  }

  # check if "user_is_admin" defined
  if (param('user_is_admin') && param('user_is_admin') == 1) {
     $user_is_admin_sql = 'ua';
  }
  else {
     $user_is_admin_sql = 'u';
  }

  # get selected projects
  $sql = qq(select project_id, project_name
            from   projects
         );

  @sql_parameters = ();

  ($result, $rows) = &do_multi_result_sql_query2($global_var_href, $sql, \@sql_parameters, $sr_name . "-" . __LINE__ );

  # loop over all projects. Add selected ones to a list
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];
      if (defined(param('user_project_' . $row->{'project_id'}))) {
         push(@selected_projects, $row->{'project_id'});
      }
  }

  # check input: is first name given? minimum length
  if (!param('first_name') || param('first_name') eq '' || length(param('first_name')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter the first name of the user (at least 3 characters)"));
     return $page;
  }

  # check input: is last name given? minimum length
  if (!param('last_name')  || param('last_name') eq ''  || length(param('last_name')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter the last name of the user (at least 3 characters)"));
     return $page;
  }

  # sex must be specified and it must be either 'male' or 'female'
  if (param('sex') && param('sex') eq 'male') {
     $sex_sql = 'm';
  }
  elsif (param('sex') && param('sex') eq 'female') {
     $sex_sql = 'f';
  }
  else {
     $page .= p({-class=>"red"}, b("Please choose sex: either male or female"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # function must be specified
  if (!param('function')) {
     $page .= p({-class=>"red"}, b("Please choose function"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # contact type must be specified and it must be either 'natural person' or 'institution'
  if (param('contact_type') && param('contact_type') eq 'person') {
     $contact_type_sql = 'n';
  }
  elsif (param('contact_type') && param('contact_type') eq 'institution') {
     $contact_type_sql = 'i';
  }
  else {
     $page .= p({-class=>"red"}, b("Please choose contact type: (natural) person or institution"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check if "contact_is_internal" defined
  if (param('is_external') && param('is_external') == 1) {
     $contact_is_internal_sql = 'n';
  }
  else {
     $contact_is_internal_sql = 'y';
  }

  # check input: is institution name given? minimum length
  if (!param('institution') || param('institution') eq '' || length(param('institution')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter the name of the institution (at least 3 characters)"));
     return $page;
  }

  # check input: is street name given? minimum length
  if (!param('street') || param('street') eq '' || length(param('street')) < 5) {
     $page .= p({-class=>"red"}, b("Error: please enter the name of the street (at least 5 characters)"));
     return $page;
  }

  # check input: is town given? minimum length
  if (!param('town') || param('town') eq '' || length(param('town')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter the town (at least 5 characters)"));
     return $page;
  }

  # calculate MD5 checksum of password
  $password_md5 = Digest::MD5->reset();
  $password_md5->add(param('password'));
  $password_checksum = $password_md5->hexdigest();

  ########################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during new user insert (begin transaction failed)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new contact id
  ($new_contact_id) = $dbh->selectrow_array("select (max(contact_id)+1) as new_contact_id
                                             from   contacts
                                            ");

  # ok, this is only neccessary for the very first contact when (max(contact_id)+1) = (NULL + 1) is undefined
  if (!defined($new_contact_id)) { $new_contact_id = 1; }

  # insert new contact
  $dbh->do("insert
            into   contacts (contact_id, contact_is_internal, contact_title, contact_type, contact_function,
                             contact_first_name, contact_last_name, contact_sex, contact_emails, contact_comment)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
           ", undef, $new_contact_id, $contact_is_internal_sql, param('title'), param('contact_type'), param('function'),
                     param('first_name'), param('last_name'), $sex_sql, param('email'), param('contact_comment')
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new contact)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new user id
  ($new_user_id) = $dbh->selectrow_array("select (max(user_id)+1) as new_user_id
                                          from   users
                                         ");

  # ok, this is only neccessary for the very first user when (max(user_id)+1) = (NULL + 1) is undefined
  if (!defined($new_user_id)) { $new_user_id = 1; }

  # insert new user
  $dbh->do("insert
            into   users (user_id, user_name, user_contact, user_password, user_status, user_roles, user_comment)
            values (?, ?, ?, ?, ?, ?, ?)
           ", undef, $new_user_id, param('username'), $new_contact_id, $password_checksum, 'active', $user_is_admin_sql, param('contact_comment')
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new user)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new address id
  ($new_address_id) = $dbh->selectrow_array("select (max(address_id)+1) as new_address_id
                                             from   addresses
                                            ");

  # ok, this is only neccessary for the very first address when (max(address_id)+1) = (NULL + 1) is undefined
  if (!defined($new_address_id)) { $new_address_id = 1; }

  # insert new address
  $dbh->do("insert
            into   addresses (address_id, address_institution, address_street, address_postal_code, address_other_info, address_city, address_state,
                              address_country, address_telephone, address_fax, address_unit, address_comment)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
           ", undef, $new_address_id, param('institution'), param('street'), param('PLZ'), param('address_other'), param('town'), param('state'),
                     param('country'), param('phone'), param('fax'), param('unit'), param('address_comment')
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new address)", $sr_name . "-" . __LINE__);

  ##################################
  # link address to contact
  $dbh->do("insert
            into   contacts2addresses
            values (?, ?)
           ", undef, $new_contact_id, $new_address_id
       ) or &error_message_and_exit($global_var_href, "SQL error (could not insert into contacts2addresses)", $sr_name . "-" . __LINE__);

  ##################################
  # link project(s) to user
  foreach $project (@selected_projects) {
     $dbh->do("insert
               into   users2projects (u2p_user_id, u2p_project_id, u2p_rights)
               values (?, ?, ?)
              ", undef, $new_user_id, $project, 'v'
           ) or &error_message_and_exit($global_var_href, "SQL error (could not insert into users2projects)", $sr_name . "-" . __LINE__);
  }

  # everything ok, so commit
  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during new user insert (commit failed)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_contact\t". $new_contact_id . "\t" . param('first_name') . '_' . param('last_name'));
  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_user\t".    $new_user_id    . "\t" . param('username')   . "\tlinked_to_contact\t" . $new_contact_id);
  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_address\t". $new_address_id . "\tlinked_to_contact\t" . $new_contact_id);
  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_user\t".    $new_user_id    . "\tlinked_to_projects\t" . join(',', @selected_projects));


  $page .= h3("New user account \"" . a({-href=>"$url?choice=user_details&user_id=" . $new_user_id}, param('username')) . "\" successfully created");

  return $page;
}
# end of create_new_user_2()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM006 create_new_line_1():                         create new line, step 1: input dialog
sub create_new_line_1 {                                  my $sr_name = 'SR_ADM006';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();                                                # get URL from which script was called
  my ($page, $sql);                                               # standard variables for prepared HTML and prepared SQL
  my @sql_parameters;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new mouse line")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new mouse line")

          . hr()

          . start_form({-action => url()})

          . h3("Line info")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("line name"),
                  td(textfield(-name => "line_name",      -size=>"15", -maxlength=>"50")),
                  td("Please enter the name of the new mouse line")
              ) .
              Tr( th("line long name"),
                  td(textfield(-name => "line_long_name", -size=>"30", -maxlength=>"100")),
                  td("Please enter the long name of the new mouse line")
              ) .
              Tr( th("line comment or description"),
                  td(textarea(-name => "line_comment", -columns=>"40", -rows=>"2", -override=>"1")),
                  td("Please enter a comment on the new mouse line")
              ) .
              Tr( th("is mouse line genetically modified (GVO)?"),
                  td(radio_group(-name=>'line_is_gvo', -values=>['y', 'n'], -default=>'')),
                  td("Please specify if mouse line is genetically modified")
              )
            )

          . h3("Assign a gene / locus")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("Gene / locus name"),
                  td(textfield(-name => "gene_name", -size=>"15", -maxlength=>"15")),
                  td("Please enter the name of the new gene / locus")
              ) .
              Tr( th("Gene / locus description"),
                  td(textarea(-name => "gene_description", -columns=>"40", -rows=>"2", -override=>"1")),
                  td("Please enter a description for the new gene / locus")
              ) .
              Tr( th("Valid genotype qualifiers"),
                  td(textfield(-name => "gene_valid_qualifiers", -size=>"30", -maxlength=>"50")),
                  td("Please enter valid genotype qualifiers for this gene/locus as semicolon-separated list" . br()
                     . i(b("[for example: +/+;+/-;-/-] ") . span({-class=>"red"}, "please do not use whitespaces!"))
                  )
              )
            )

          . p()

          . submit(-name => "choice", -value => "create new line") . "&nbsp; &nbsp;"
          . CGI->reset(-name=>"reset form")                             . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel")

          . end_form();

  return $page;
}
# end of create_new_line_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM007 create_new_line_2():                         create new line, step 2: database transaction
sub create_new_line_2 {                                  my $sr_name = 'SR_ADM007';
  my ($global_var_href)   = @_;                                        # get reference to global vars hash
  my $session             = $global_var_href->{'session'};             # get session handle
  my $user_id             = $session->param(-name=>'user_id');
  my $user_name           = $session->param(-name=>'username');
  my $dbh                 = $global_var_href->{'dbh'};                 # DBI database handle
  my $datetime_now        = get_current_datetime_for_sql();
  my $url = url();                                                     # get URL from which script was called
  my ($page, $sql, $i, $row, $rows, $result, $rc);                     # standard variables for prepared HTML, prepared SQL and SQL query result handling
  my ($line_name_exists, $gene_name_exists, $entry_date_sql);
  my ($new_line_id, $new_gene_id, $line_long_name, $is_gvo);
  my @sql_parameters;
  my $line_name;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new mouse line")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new mouse line")
          . hr();

  # check input: is mouse line given? minimum length
  if (!param('line_name') || param('line_name') eq "" || length(param('line_name')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter a name for the mouse line (at least 3 characters)"));
     return $page;
  }
  else {
  #remove white space at the end of the name
  	$line_name = param('line_name');
	$line_name =~ s/^\s+|\s+$//g;
	}
	
  # check input: is line long name given?
  if (!param('line_long_name')) {
     $line_long_name = '';
  }
  else {
     $line_long_name = param('line_long_name');
  }

  # check input: is mouse line gvo status given?
  if (!param('line_is_gvo') || param('line_is_gvo') !~ /[yn]/) {
     $page .= p({-class=>"red"}, b("Error: please enter gvo status of mouse line [y/n]"));
     return $page;
  }

  # check input: are genotype qualifiers given?
  if (!param('gene_valid_qualifiers') || param('gene_valid_qualifiers') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter valid genotype qualifiers as semicolon-separated list " . i('(e.g. +/+;+/-;-/-)')));
     return $page;
  }

  ####################################################
  # check if line name exists
  $sql = qq(select line_id
            from   mouse_lines
            where  line_name = ?
         );

  @sql_parameters = ($line_name);

  ($line_name_exists) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . __LINE__)};

  if (defined($line_name_exists)) {
     $page .= p({-class=>"red"}, "Line name \"" . $line_name . "\" already exists! Please choose another one.");
     return $page;
  }

  # check input: is gene / locus name given? minimum length
  if (!param('gene_name') || param('gene_name') eq "" || length(param('gene_name')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter a name for the gene / locus (at least 3 characters)"));
     return $page;
  }

  ####################################################
  # check if gene name exists
  $sql = qq(select gene_id
            from   genes
            where  gene_name = ?
         );

  @sql_parameters = (param('gene_name'));

  ($gene_name_exists) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . __LINE__)};

  if (defined($gene_name_exists)) {
     $page .= p({-class=>"red"}, "Gene / locus name \"" . param('gene_name') . "\" already exists! Created additional one for this line. Please tell your administrator.");
     return $page;
  }

  ########################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during new line insert (begin transaction failed)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new line id
  ($new_line_id) = $dbh->selectrow_array("select (max(line_id)+1) as new_line_id
                                          from   mouse_lines
                                         ");

  # ok, this is only neccessary for the very first mouse line when (max(line_id)+1) = (NULL + 1) is undefined
  if (!defined($new_line_id)) { $new_line_id = 1; }

  # insert new mouse line
  $dbh->do("insert
            into   mouse_lines (line_id, line_name, line_long_name, line_order, line_show, line_info_URL, line_comment)
            values (?, ?, ?, NULL, ?, NULL, ?)
           ", undef, $new_line_id, $line_name, $line_long_name, 'y', param('line_comment')
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new mouse line)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new gene id
  ($new_gene_id) = $dbh->selectrow_array("select (max(gene_id)+1) as new_gene_id
                                          from   genes
                                         ");

  # ok, this is only neccessary for the very first gene when (max(gene_id)+1) = (NULL + 1) is undefined
  if (!defined($new_gene_id)) { $new_gene_id = 1; }

  # insert new gene / locus
  $dbh->do("insert
            into   genes (gene_id, gene_name, gene_shortname, gene_description, gene_valid_qualifiers)
            values (?, ?, ?, ?, ?)
           ", undef, $new_gene_id, param('gene_name'), param('gene_name'), param('gene_description'), param('gene_valid_qualifiers')
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new gene)", $sr_name . "-" . __LINE__);

  ##################################
  # link mouse line to gene
  $dbh->do("insert
            into   mouse_lines2genes (ml2g_mouse_line_id, ml2g_gene_id, ml2g_gene_order )
            values (?, ?, ?)
           ", undef, $new_line_id, $new_gene_id, 1
       ) or &error_message_and_exit($global_var_href, "SQL error (could not insert into mouse_lines2genes)", $sr_name . "-" . __LINE__);


  ##################################
  # create entry in GTAS_line_info
  $entry_date_sql = format_display_date2sql_date(format_sql_date2display_date($datetime_now));

  $dbh->do("insert
            into   GTAS_line_info (gli_id, gli_mouse_line_id, gli_mouse_line_is_gvo, gli_Projektnr, gli_Institutscode,
                                     gli_Bemerkungen, gli_Spenderorganismen, gli_Nukleinsaeure_Bezeichnung, gli_Nukleinsaeure_Merkmale,
                                     gli_Vektoren, gli_Empfaengerorganismen, gli_GVO_Merkmale, gli_GVO_ErzeugtAm,
                                     gli_Risikogruppe_Empfaenger, gli_Risikogruppe_GVO, gli_Risikogruppe_Spender,
                                     gli_Lagerung, gli_Sonstiges, gli_TepID, gli_SysID, gli_OrgCode)
              values (?, ?, ?, ?, ?,
                      ?, ?, ?, ?,
                      ?, ?, ?, ?,
                      ?, ?, ?,
                      ?, ?, ?, ?, ?)
           ", undef,
             $new_line_id, $new_line_id, param('line_is_gvo'), '51272', 'AVM',
             '', '', '', '',
             '', 'Maus', '', "$entry_date_sql",
             'S1', '', '',
             '', '', $line_name, 'GMC', 'HMGU'
           ) or &error_message_and_exit($global_var_href, "SQL error (could not insert into GTAS_line_info)", $sr_name . "-" . __LINE__);


  # everything ok, so commit
  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during new line insert (commit failed)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_line\t". $new_line_id . "\t" . $line_name);
  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_gene\t". $new_gene_id . "\t" . param('gene_name'));


  $page .= h3("New mouse line \"" . a({-href=>"$url?choice=line_view&line_id=" . $new_line_id}, $line_name) . "\" successfully created")
           . p("Please follow the link above and enter more detailed information if mouse line is genetically modified (GVO)");

  return $page;
}
# end of create_new_line_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_ADM008 create_new_strain_1():                       create new strain, step 1: input dialog
sub create_new_strain_1 {                                my $sr_name = 'SR_ADM008';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();                                                # get URL from which script was called
  my ($page, $sql);                                               # standard variables for prepared HTML and prepared SQL
  my @sql_parameters;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new mouse strain")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new mouse strain")

          . hr()

          . start_form({-action => url()})

          . h3("Strain info")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("strain name"),
                  td(textfield(-name => "strain_name", -size=>"15", -maxlength=>"100")),
                  td("Please enter the name of the new mouse strain")
              ) .
              Tr( th("strain comment or description"),
                  td(textarea(-name => "strain_comment", -columns=>"40", -rows=>"2", -override=>"1")),
                  td("Please enter a comment on the new mouse strain")
              )
            )

          . p()

          . submit(-name => "choice", -value => "create new strain") . "&nbsp; &nbsp;"
          . CGI->reset(-name=>"reset form")                               . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel")

          . end_form();

  return $page;
}
# end of create_new_strain_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM009 create_new_strain_2():                       create new strain, step 2: database transaction
sub create_new_strain_2 {                                my $sr_name = 'SR_ADM009';
  my ($global_var_href)   = @_;                                        # get reference to global vars hash
  my $session             = $global_var_href->{'session'};             # get session handle
  my $user_id             = $session->param(-name=>'user_id');
  my $user_name           = $session->param(-name=>'username');
  my $dbh                 = $global_var_href->{'dbh'};                 # DBI database handle
  my $datetime_now        = get_current_datetime_for_sql();
  my $url = url();                                                     # get URL from which script was called
  my ($page, $sql, $i, $row, $rows, $result, $rc);                     # standard variables for prepared HTML, prepared SQL and SQL query result handling
  my ($strain_name_exists);
  my ($new_strain_id);
  my @sql_parameters;
  my $strain_name;
  
  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new mouse strain")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new mouse strain")
          . hr();

  # check input: is mouse strain given? minimum length
  if (!param('strain_name') || param('strain_name') eq "" || length(param('strain_name')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter a name for the mouse strain (at least 3 characters)"));
     return $page;
  }
  else {
  #remove white space at the end of the name
  	$strain_name = param('strain_name');
	$strain_name =~ s/^\s+|\s+$//g;
	}

  ####################################################
  # check if strain name exists
  $sql = qq(select strain_id
            from   mouse_strains
            where  strain_name = ?
         );

  @sql_parameters = ($strain_name);

  ($strain_name_exists) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . __LINE__)};

  if (defined($strain_name_exists)) {
     $page .= p({-class=>"red"}, "Strain name \"" . $strain_name . "\" already exists! Please choose another one.");
     return $page;
  }

  ########################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during new strain insert (begin transaction failed)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new strain id
  ($new_strain_id) = $dbh->selectrow_array("select (max(strain_id)+1) as new_strain_id
                                            from   mouse_strains
                                           ");

  # ok, this is only neccessary for the very first mouse strain when (max(strain_id)+1) = (NULL + 1) is undefined
  if (!defined($new_strain_id)) { $new_strain_id = 1; }

  # insert new mouse strain
  $dbh->do("insert
            into   mouse_strains (strain_id, strain_name, strain_order, strain_show, strain_description)
            values (?, ?, NULL, ?, ?)
           ", undef, $new_strain_id, $strain_name, 'y', param('strain_comment')
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new mouse strain)", $sr_name . "-" . __LINE__);


  # everything ok, so commit
  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during new strain insert (commit failed)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_strain\t". $new_strain_id . "\t" . $strain_name);


  $page .= h3("New mouse strain \"" . a({-href=>"$url?choice=strain_view&strain_id=" . $new_strain_id}, $strain_name) . "\" successfully created");

  return $page;
}
# end of create_new_strain_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_ADM010 global_locks():                              manage global locks
sub global_locks {                                       my $sr_name = 'SR_ADM010';
  my ($global_var_href)  = @_;                                     # get reference to global vars hash
  my $session            = $global_var_href->{'session'};          # get session handle
  my $user_id            = $session->param(-name=>'user_id');
  my $url                = url();
  my $message            = '';
  my ($page, $sql, $command_line, $system_message);
  my @sql_parameters;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Set or release global locks")

             . hr()

             . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  # user required to set a global lock
  if (defined(param('choice')) && param('choice') eq 'set global lock') {

     # modify lock entry in the config file
     $command_line = qq(/bin/sed -i -e 's/false/true/' ./config.rc);

     $system_message = system($command_line);

     # successful?
     if ($system_message == 0) {
        $message = p({-class=>'red'}, 'GLOBAL LOCK SET')
                   . hr();

        # update lock status
        $global_var_href->{'global_lock_status'} = 'true';
     }
     # failed...
     else {
        $message = p({-class=>'red'}, 'COULD NOT SET GLOBAL LOCK')
                   . hr();
     }
  }


  # user required to release a global lock
  if (defined(param('choice')) && param('choice') eq 'release global lock') {

     # modify lock entry in the config file
     $command_line = qq(/bin/sed -i -e 's/true/false/' ./config.rc);

     $system_message = system($command_line);

     # successful?
     if ($system_message == 0) {
        $message = p({-class=>'red'}, 'GLOBAL LOCK RELEASED')
                   . hr();

        # update lock status
        $global_var_href->{'global_lock_status'} = 'false';
     }
     # failed...
     else {
        $message = p({-class=>'red'}, 'COULD NOT RELEASE GLOBAL LOCK')
                   . hr();
     }
  }

  $page = h2("Set or release global locks "
             . a({-href=>"$url?choice=global_locks", -title=>"reload page"},
                 img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/reload.gif', -border=>0, -alt=>'[reload button]'})
                )
          )

          . hr()

          . $message

          . p('Setting a global lock will block access to the web interface of MausDB for all users except admin users.')

          . p('Global locks can be used to prevent database access during service times or in emergency situations.')

          . p('Admin users still have access to MausDB during a global lock when they are already logged in (continue existing session).
              Even for admin users, starting a new session is not possible when a global lock is set.')

          . start_form({-action => url()})

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("Current status"),
                  td(($global_var_href->{'global_lock_status'} eq 'true')
                     ?span({-style=>'background-color: red;'},   'GLOBAL LOCK SET')
                     :span({-style=>'background-color: green;'}, 'GLOBAL LOCK RELEASED')
                  )
              ) .
              Tr( th("Set a global lock"),
                  td(submit(-name => "choice", -value => "set global lock"))
              ) .
              Tr( th("release a global lock"),
                  td(submit(-name => "choice", -value => "release global lock"))
              )
            )

          . end_form();

  return $page;
}
# end of global_locks()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_ADM011 create_new_rack_1():                         create new rack, step 1: input dialog
sub create_new_rack_1 {                                  my $sr_name = 'SR_ADM011';
  my ($global_var_href) = @_;                                     # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();
  my ($page, $sql);
  my @sql_parameters;
  my %labels = ("y" => 'yes', "n" => 'no');

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Define a new rack")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Define a new rack")

          . hr()

          . start_form({-action => url()})

          . h3("Please specify details for your new rack")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("rack name"),
                  td(textfield(-name => "rack_name", -size=>"8", -maxlength=>"12", -default=>'') . br()
                     . small("example: \"01\" for rack 01 in room 1234")
                  ),
                  td("Please enter the name of the new rack")
              ) .
              Tr( th("room"),
                  td(textfield(-name => "rack_room", -size=>"8", -maxlength=>"12", -default=>'') . br()
                     . small("example: \"1234\" if rack is placed in room in room 1234")
                  ),
                  td("Please specify the room in which the rack is placed.")
              ) .
              Tr( th("building"),
                  td(textfield(-name => "rack_building", -size=>"8", -maxlength=>"12", -default=>'') . br()
                     . small("example: \"35\" if rack is placed in a room in building 35")
                  ),
                  td("Please specify the building in which the rack is placed.")
              ) .
              Tr( th("subbuilding"),
                  td(textfield(-name => "rack_subbuilding", -size=>"8", -maxlength=>"12", -default=>'') . br()
                     . small("example: \"A\" if rack is placed in a room in subbuilding A of building 35")
                  ),
                  td("Please specify the subbuilding in which the rack is placed.")
              ) .
              Tr( th("capacity"),
                  td(textfield(-name => "rack_capacity", -size=>"2", -maxlength=>"3", -default=>'') . br()
                     . small("example: \"42\" if the rack has a capacity for 42 cages")
                  ),
                  td("Please specify the rack capacity (max. number of cages in this rack).")
              ) .
              Tr( th("is rack active?"),
                  td(radio_group(-name=>'rack_is_active', -values=>['y', 'n'], -default=>3, -labels=>\%labels) . br()
                     . small("example: \"yes\" if you want to use this rack immediately")
                  ),
                  td("Please specify if the rack is active or not. Not active means that the rack is defined, but cannot be used in MausDB.")
              ) .
              Tr( th("project"),
                  td(get_projects_popup_menu($global_var_href, 1, 'all')
                  ),
                  td("Please choose the project to which the rack is assigned.")
              ) .
              Tr( th("is rack internal?"),
                  td(radio_group(-name=>'rack_is_internal', -values=>['y', 'n'], -default=>3, -labels=>\%labels) . br()
                     . small("example: \"yes\"")
                  ),
                  td("Please specify if the rack is internal or not. Internal means that mice in this rack live outside your facility.")
              ) .
              Tr( th("rack code"),
                  td(textfield(-name => "rack_code", -size=>"8", -maxlength=>"12", -default=>'') . br()
                     . small("example: \"1300\" if the code for this animal facility is 1300")
                  ),
                  td("[Optional: Please enter a code for the facility in which the new rack is placed]")
              ) .
              Tr( th("rack comment or description"),
                   td(textfield(-name => "rack_comment", -size=>"30", -maxlength=>"40", -default=>'') . br()
                     . small("example: \"mating rack\"")
                  ),
                  td("[Optional: Please enter a comment for the new rack]")
              )
            )

          . p()

          . submit(-name => "choice", -value => "define new rack") . "&nbsp; &nbsp;"
          . CGI->reset( -name=>"reset form")                            . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel")

          . end_form();

  return $page;
}
# end of create_new_rack_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM012 create_new_rack_2():                         create new rack, step 2: database transaction
sub create_new_rack_2 {                                  my $sr_name = 'SR_ADM012';
  my ($global_var_href)   = @_;                                        # get reference to global vars hash
  my $session             = $global_var_href->{'session'};             # get session handle
  my $user_id             = $session->param(-name=>'user_id');
  my $user_name           = $session->param(-name=>'username');
  my $dbh                 = $global_var_href->{'dbh'};                 # DBI database handle
  my $rack_name           = param('rack_name');
  my $rack_room           = param('rack_room');
  my $rack_building       = param('rack_building');
  my $rack_subbuilding    = param('rack_subbuilding');
  my $rack_capacity       = param('rack_capacity');
  my $rack_is_active      = param('rack_is_active');
  my $rack_project        = param('all_projects');
  my $rack_is_internal    = param('rack_is_internal');
  my $rack_code           = param('rack_code');
  my $rack_comment        = param('rack_comment');
  my $url = url();
  my ($page, $sql, $i, $row, $rows, $result, $rc);
  my ($rack_name_exists);
  my ($new_rack_id);
  my @sql_parameters;
  my $datetime_now        = get_current_datetime_for_sql();

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Define a new rack")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Define a new rack")
          . hr();

  # check input: is rack name given?
  if (!param('rack_name') || param('rack_name') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter a name for the new rack (at least 1 character)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is rack room given?
  if (!param('rack_room') || param('rack_room') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter a room for the new rack (at least 1 character)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is rack building given?
  if (!param('rack_building') || param('rack_building') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter a building for the new rack (at least 1 character)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is rack subbuilding given?
  if (!param('rack_subbuilding') || param('rack_subbuilding') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter a subbuilding for the new rack (at least 1 character)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is rack capacity given? is it a number?
  if (!param('rack_capacity') || param('rack_capacity') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please enter the rack capacity (max. number of cage in this rack)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # rack_is_active must be given and it must be either 'y' or 'n'
  if (!param('rack_is_active') || !(param('rack_is_active') eq 'y' || param('rack_is_active') eq 'n')) {
     $page .= p({-class=>"red"}, b("Error: please enter if rack is active or not"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is project given? is it a number?
  if (!param('all_projects') || param('all_projects') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose project"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # rack_is_internal must be given and it must be either 'y' or 'n'
  if (!param('rack_is_internal') || !(param('rack_is_internal') eq 'y' || param('rack_is_internal') eq 'n')) {
     $page .= p({-class=>"red"}, b("Error: please enter if rack is internal or not"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  ####################################################
  # check if rack name exists
  $sql = qq(select location_id
            from   locations
            where  location_name = ?
         );

  @sql_parameters = (param('rack_room') . param('rack_name'));

  ($rack_name_exists) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . __LINE__)};

  if (defined($rack_name_exists)) {
     $page .= p({-class=>"red"}, "Rack name \"$rack_room-$rack_name\" already exists! Please choose another one.");
     return $page;
  }

  ########################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during new rack insert (begin transaction failed)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new rack id
  ($new_rack_id) = $dbh->selectrow_array("select (max(location_id)+1) as new_rack_id
                                          from   locations
                                          where  location_id > 0 and location_id < 99999
                                         ");

  # ok, this is only neccessary for the very first rack when (max(location_id)+1) = (NULL + 1) is undefined
  if (!defined($new_rack_id)) { $new_rack_id = 1; }

  # insert new rack
  $dbh->do("insert
            into   locations (location_id, location_name, location_code, location_is_internal, location_address, location_building,
                              location_subbuilding, location_room, location_rack, location_subrack, location_capacity, location_is_active,
                              location_project, location_display_order, location_comment)
            values (?, ?, ?, ?, ?, ?,           ?, ?, ?, ?, ?, ?,         ?, ?, ?)
           ", undef, $new_rack_id, $rack_room . $rack_name, $rack_code, $rack_is_internal, 1, $rack_building,
                     $rack_subbuilding, $rack_room, $rack_name, '', $rack_capacity, $rack_is_active,
                     $rack_project, $new_rack_id, $rack_comment
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new rack)", $sr_name . "-" . __LINE__);


  # everything ok, so commit
  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during new rack insert (commit failed)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_rack\t". $new_rack_id . "\t" . $rack_room . $rack_name);


  $page .= h3("New rack \"" . a({-href=>"$url?choice=location_details&location_id=" . $new_rack_id}, $rack_room . $rack_name) . "\" successfully created");

  return $page;
}
# end of create_new_rack_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_ADM013 create_new_cages_1():                        create new cages, step 1: input dialog
sub create_new_cages_1 {                                 my $sr_name = 'SR_ADM013';
  my ($global_var_href) = @_;                                     # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();
  my ($page, $sql);
  my @sql_parameters;
  my %labels = ("y" => 'yes', "n" => 'no');

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Define new cages")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Define new cages")

          . hr()

          . start_form({-action => url()})

          . h3("Please specify:")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("cage number"),
                  td(textfield(-name => "cage_number", -size=>"4", -maxlength=>"4", -default=>'') . br()
                     . small("example: \"100\" if you want to define 100 new cages")
                  ),
                  td("Please enter the number of cages to be defined in the database")
              ) .
              Tr( th("cage capacity"),
                  td(popup_menu(-name => 'cage_capacity', -values => [1..10], -default => '5') . br()
                     . small("example: \"5\" if the cages have a capacity for 5 mice")
                  ),
                  td("Please specify the cage capacity (max. number of mice per cage).")
              ) .
              Tr( th("cages active?"),
                  td(radio_group(-name=>'cages_active', -values=>['y', 'n'], -default=>3, -labels=>\%labels) . br()
                     . small("example: \"yes\" if the cages should be active immediately")
                  ),
                  td("Please specify if the cages should be active or not. Not active means that the cage are defined, but cannot be used in MausDB.")
              )
            )

          . p()

          . submit(-name => "choice", -value => "define new cages") . "&nbsp; &nbsp;"
          . CGI->reset( -name=>"reset form")                             . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel")

          . end_form();

  return $page;
}
# end of create_new_cages_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM014 create_new_cages_2():                        create new cages, step 2: database transaction
sub create_new_cages_2 {                                 my $sr_name = 'SR_ADM014';
  my ($global_var_href) = @_;                                        # get reference to global vars hash
  my $session           = $global_var_href->{'session'};             # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $user_name         = $session->param(-name=>'username');
  my $dbh               = $global_var_href->{'dbh'};                 # DBI database handle
  my $cage_number       = param('cage_number');
  my $cage_capacity     = param('cage_capacity');
  my $cages_active      = param('cages_active');
  my $url = url();
  my ($page, $sql, $i, $row, $rows, $result, $rc);
  my ($cage_id_exists);
  my ($new_cage_id);
  my @sql_parameters;
  my $datetime_now        = get_current_datetime_for_sql();

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Define new cages")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Define new cages")
          . hr();

  # check input: is cage number given? is it a number?
  if (!param('cage_number') || param('cage_number') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please enter the number of cages to be generated."))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is cage capacity given? is it a number?
  if (!param('cage_capacity') || param('cage_capacity') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please enter cage capacity (how many mice per cage)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: cages_active must be given and it must be either 'y' or 'n'
  if (!param('cages_active') || !(param('cages_active') eq 'y' || param('cages_active') eq 'n')) {
     $page .= p({-class=>"red"}, b("Error: please enter if cage are active or not"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  ########################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during new cages insert (begin transaction failed)", $sr_name . "-" . __LINE__);

  for ($i=0; $i<$cage_number; $i++) {

      ##################################
      # get a new cage id
      ($new_cage_id) = $dbh->selectrow_array("select (max(cage_id)+1) as new_cage_id
                                              from   cages
                                              where  cage_id > 0 and cage_id < 99999
                                             ");
      ##################################

      # ok, this is only neccessary for the very first cage when (max(cage_id)+1) = (NULL + 1) is undefined
      if (!defined($new_cage_id)) { $new_cage_id = 1; }

      # don't create too much cages
      if ($new_cage_id > 99998) {
         $rc = $dbh->rollback() or &error_message_and_exit($global_var_href,"SQL error (could not roll back new cage generation)", $sr_name . "-" . __LINE__);
            &release_semaphore_lock($global_var_href, $user_id);
            $page .= p({-class=>"red"}, "Something went wrong when trying to generate new cages (too much cages)");
            return $page;
      }

      # insert new cage
      $dbh->do("insert
                into   cages (cage_id, cage_name, cage_occupied, cage_capacity, cage_active, cage_purpose, cage_cardcolor, cage_user, cage_project)
                values (?, ?, ?, ?, ?, ?, ?, ?, ?)
               ", undef, $new_cage_id,  'Cage ' . $new_cage_id, 'n', $cage_capacity, $cages_active, '', 1, 1, 1
            ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new cage)", $sr_name . "-" . __LINE__);
  }

  # everything ok, so commit
  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during new cages generation (commit failed)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_cages\t". $cage_number . "\t" . (($cages_active eq 'y')?'active':'inactive'));


  $page .= h3("$cage_number " . (($cages_active eq 'y')?'active':'inactive') . " cages successfully created");

  return $page;
}
# end of create_new_cages_2()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM015 create_new_project_1 ():                     create new project, step 1: input dialog
sub create_new_project_1 {                               my $sr_name = 'SR_ADM015';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();
  my ($page, $sql);
  my @sql_parameters;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new project")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new mouse project")

          . hr()

          . start_form({-action => url()})

          . h3("Project info")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("project name"),
                  td(textfield(-name => "project_name", -size=>"15", -maxlength=>"100")),
                  td("Please enter the name of the new mouse strain")
              ) .
              Tr( th("project shortname"),
                  td(textfield(-name => "project_shortname", -size=>"10", -maxlength=>"10")),
                  td("Please enter the short name of the new project")
              ) .
              Tr( th("project description"),
                  td(textarea(-name => "project_description", -columns=>"40", -rows=>"2", -override=>"1")),
                  td("Please enter a description for the new project")
              ) .
              Tr( th("parent project"),
                  td(get_projects_popup_menu($global_var_href, 1, 'all')),
                  td("Please assign a parent project for the new project")
              )
            )

          . p()

          . submit(-name => "choice", -value => "define new project") . "&nbsp; &nbsp;"
          . CGI->reset(-name=>"reset form")                                . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel")

          . end_form();

  return $page;
}
# end of create_new_project_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM016 create_new_project_2():                      create new project, step 2: database transaction
sub create_new_project_2 {                               my $sr_name = 'SR_ADM016';
  my ($global_var_href)   = @_;                                        # get reference to global vars hash
  my $session             = $global_var_href->{'session'};             # get session handle
  my $user_id             = $session->param(-name=>'user_id');
  my $user_name           = $session->param(-name=>'username');
  my $dbh                 = $global_var_href->{'dbh'};                 # DBI database handle
  my $datetime_now        = get_current_datetime_for_sql();
  my $url = url();
  my ($page, $sql, $i, $row, $rows, $result, $rc);
  my ($project_name_exists);
  my ($new_project_id);
  my @sql_parameters;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new project")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new project")
          . hr();

  # check input: is project name given? minimum length
  if (!param('project_name') || param('project_name') eq "" || length(param('project_name')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter a name for the project (at least 3 characters)"));
     return $page;
  }

  # check input: is project short name given? minimum length
  if (!param('project_shortname') || param('project_shortname') eq "" || length(param('project_shortname')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter a short name for the project (at least 2 characters)"));
     return $page;
  }

  # check input: is project given? is it a number?
  if (!param('all_projects') || param('all_projects') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose parent project"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  ####################################################
  # check if project name exists
  $sql = qq(select project_id
            from   projects
            where  project_name = ?
         );

  @sql_parameters = (param('project_name'));

  ($project_name_exists) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . __LINE__)};

  if (defined($project_name_exists)) {
     $page .= p({-class=>"red"}, "Project name \"" . param('project_name') . "\" already exists! Please choose another one.");
	 return $page;
  }

  ########################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during new project insert (begin transaction failed)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new project id
  ($new_project_id) = $dbh->selectrow_array("select (max(project_id)+1) as new_project_id
                                             from   projects
                                            ");

  # ok, this is only neccessary for the very first project when (max(project_id)+1) = (NULL + 1) is undefined
  if (!defined($new_project_id)) { $new_project_id = 1; }

  # insert new project
  $dbh->do("insert
            into   projects (project_id, project_name, project_shortname, project_description, project_parent_project, project_owner)
            values (?, ?, ?, ?, ?, ?)
           ", undef, $new_project_id, param('project_name'), param('project_shortname'), param('project_description'), param('all_projects'), 1
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new project)", $sr_name . "-" . __LINE__);


  # everything ok, so commit
  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during new project insert (commit failed)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_project\t". $new_project_id . "\t" . param('project_name'));

  $page .= h3("New project \"" . a({-href=>"$url?choice=project_view&project_id=" . $new_project_id}, param('project_name')) . "\" successfully created");

  return $page;
}
# end of create_new_project_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_ADM017 create_new_cost_account_1 ():                create new cost account, step 1: input dialog
sub create_new_cost_account_1 {                          my $sr_name = 'SR_ADM017';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();
  my ($page, $sql);
  my @sql_parameters;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new cost centre")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new mouse cost centre")

          . hr()

          . start_form({-action => url()})

          . h3("Cost centre info")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("cost centre name"),
                  td(textfield(-name => "cost_account_name", -size=>"15", -maxlength=>"100")),
                  td("Please enter the name of the new cost centre")
              ) .
              Tr( th("cost centre number"),
                  td(textfield(-name => "cost_account_number", -size=>"10", -maxlength=>"10")),
                  td("Please enter the number of the new cost centre")
              ) .
              Tr( th("cost centre description"),
                  td(textarea(-name => "cost_account_description", -columns=>"40", -rows=>"2", -override=>"1")),
                  td("Please enter a description for the new cost centre")
              )
            )

          . p()

          . submit(-name => "choice", -value => "define new cost centre") . "&nbsp; &nbsp;"
          . CGI->reset(-name=>"reset form")                                    . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel")

          . end_form();

  return $page;
}
# end of create_new_cost_account_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM018 create_new_cost_account_2():                 create new cost account, step 2: database transaction
sub create_new_cost_account_2 {                          my $sr_name = 'SR_ADM018';
  my ($global_var_href)   = @_;                                        # get reference to global vars hash
  my $session             = $global_var_href->{'session'};             # get session handle
  my $user_id             = $session->param(-name=>'user_id');
  my $user_name           = $session->param(-name=>'username');
  my $dbh                 = $global_var_href->{'dbh'};                 # DBI database handle
  my $datetime_now        = get_current_datetime_for_sql();
  my $url = url();
  my ($page, $sql, $i, $row, $rows, $result, $rc);
  my ($cost_account_name_exists);
  my ($new_cost_account_id);
  my @sql_parameters;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new cost centre")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new cost centre")
          . hr();

  # check input: is cost account name given? minimum length
  if (!param('cost_account_name') || param('cost_account_name') eq "" || length(param('cost_account_name')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter a name for the cost centre (at least 3 characters)"));
     return $page;
  }

  # check input: is cost_account number given? minimum length
  if (!param('cost_account_number') || param('cost_account_number') eq "" || length(param('cost_account_number')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter a number for the cost centre (at least 2 characters)"));
     return $page;
  }

  ####################################################
  # check if project name exists
  $sql = qq(select cost_account_id
            from   cost_accounts
            where  cost_account_name = ?
         );

  @sql_parameters = (param('cost_account_name'));

  ($cost_account_name_exists) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . __LINE__)};

  if (defined($cost_account_name_exists)) {
     $page .= p({-class=>"red"}, "Cost centre name \"" . param('cost_account_name') . "\" already exists! Please choose another one.");
	 return $page;
  }

  ########################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during new cost centre insert (begin transaction failed)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new cost account id
  ($new_cost_account_id) = $dbh->selectrow_array("select (max(cost_account_id)+1) as new_cost_account_id
                                                  from   cost_accounts
                                                 ");

  # ok, this is only neccessary for the very first cost account when (max(cost_account_id)+1) = (NULL + 1) is undefined
  if (!defined($new_cost_account_id)) { $new_cost_account_id = 1; }

  # insert new cost account
  $dbh->do("insert
            into   cost_accounts (cost_account_id, cost_account_name, cost_account_number, cost_account_comment)
            values (?, ?, ?, ?)
           ", undef, $new_cost_account_id, param('cost_account_name'), param('cost_account_number'), param('cost_account_description')
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new cost centre)", $sr_name . "-" . __LINE__);


  # everything ok, so commit
  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during new cost centre insert (commit failed)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_cost_account\t". $new_cost_account_id . "\t" . param('cost_account_name'));

  $page .= h3("New cost centre \"" . param('cost_account_name') . "\" successfully created");

  return $page;
}
# end of create_new_cost_account_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_ADM019 create_new_experiment_1 ():                  create new experiment, step 1: input dialog
sub create_new_experiment_1 {                            my $sr_name = 'SR_ADM019';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();
  my ($page, $sql);
  my @sql_parameters;
  my %labels = ("y" => 'yes', "n" => 'no');

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new experiment")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

	#AB: get_contacts_popup_menu benötigt default contact_id des aktuellen users
	my $contact_id = get_contactid_by_userid($global_var_href, $user_id);

  $page = h2("Create a new experiment")

          . hr()

          . start_form({-action => url()})

          . h3("Experiment info")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("experiment name"),
                  td(textfield(-name => "experiment_name", -size=>"15", -maxlength=>"100")),
                  td("Please enter the name of the new experiment")
              ).
              #AB: new input fields
              Tr(th("experiment long name"),
              		td(textfield(-name => "experiment_recordname", -size=>"15", -maxlength=>"250")),
              		td("Please enter the long name of the new experiment")
              ).
              Tr(th("experiment url"),
              		td(textfield(-name => "experiment_url", -size=>"30", -maxlength=>"250")),
              		td("Please enter the url of the new experiment")
              ).
              Tr(
                 th({-bgcolor=>'lightblue'}, "Contact name "),
                 td(get_contacts_popup_menu($global_var_href, $contact_id, 'experiment_granted_to_contact')),
                 td("Please enter the contact name of the new experiment")
               ).
              Tr( th("experiment licence start date"),
                   td(textfield(-name => "experiment_licence_valid_from", -id=>"experiment_licence_valid_from", -size=>"20", -maxlength=>"21", -value=>get_current_datetime_for_display())
                      . "&nbsp;&nbsp;"
                      . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=start_date', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                     ),
                     td("Please enter the start date of the new experiment")
               ).
              Tr( th("experiment licence end date"),
                   td(textfield(-name => "experiment_licence_valid_to", -id=>"experiment_licence_valid_to", -size=>"20", -maxlength=>"21", -value=>get_current_datetime_for_display())
                      . "&nbsp;&nbsp;"
                      . a({-href=>"javascript:openCalenderWindow('/mausdb/static_pages/calendar.html?Field=start_date', 480, 480, 400, 200, 'no')", -title=>"click for calender"}, img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/calendar.png', -border=>0, -alt=>'[calendar]'}))
                     ),
                     td("Please enter the end date of the new experiment")
               ).
              Tr(th("experiment animal number"),
              		td(textfield(-name => "experiment_animalnumber", -size=>"15", -maxlength=>"250")),
              		td("Please enter the animal number of the new experiment")
              ).
              Tr( th("is experiment active?"),
                  td(radio_group(-name=>'experiment_is_active', -values=>['y', 'n'], -default=>'y', -labels=>\%labels) . br()
                     . small("example: \"yes\" if you want to start this experiment")
                  ),
                  td("Please specify if the experiment is active or not.")
              )
            )

          . p()

          . submit(-name => "choice", -value => "define new experiment") . "&nbsp; &nbsp;"
          . CGI->reset(-name=>"reset form")                                   . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel")

          . end_form();

  return $page;
}
# end of create_new_experiment_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM020 create_new_experiment_2():                   create new project, step 2: database transaction
sub create_new_experiment_2 {                            my $sr_name = 'SR_ADM020';
  my ($global_var_href)   = @_;                                        # get reference to global vars hash
  my $session             = $global_var_href->{'session'};             # get session handle
  my $user_id             = $session->param(-name=>'user_id');
  my $user_name           = $session->param(-name=>'username');
  my $dbh                 = $global_var_href->{'dbh'};                 # DBI database handle
  my $datetime_now        = get_current_datetime_for_sql();
  my $url = url();
  my ($page, $sql, $i, $row, $rows, $result, $rc);
  my ($experiment_name_exists);
  my ($new_experiment_id);
  my @sql_parameters;

	my $sqldate_expfrom;
	my $sqldate_expto;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new experiment")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new experiment")
          . hr();

  # check input: is experiment name given? minimum length
  if (!param('experiment_name') || param('experiment_name') eq "" || length(param('experiment_name')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter a name for the experiment (at least 3 characters)"))
     	. p(a({-href=>"javascript:back()"}, "go back and try again"));;
     return $page;
  }

#A input validation

	if (!param('experiment_recordname') || param('experiment_recordname') eq "" || length(param('experiment_recordname')) < 3) {
     $page .= p({-class=>"red"}, b("Error: please enter a name for the experiment (at least 3 characters)"))
     	. p(a({-href=>"javascript:back()"}, "go back and try again"));;
     return $page;
  	}
  	
  	#if (!param('experiment_URL') || param('experiment_URL') eq "" || length(param('experiment_URL')) < 3) {
    # $page .= p({-class=>"red"}, b("Error: please enter a valid URL"));
    # return $page;
  	#}

	# check input: is animal number given? is it a number?
	if (param('experiment_animalnumber')){
	  	if (param('experiment_animalnumber') !~ /^[0-9]+$/) {
	     $page .= p({-class=>"red"}, b("Error: please enter the number of animals to be generated."))
	              . p(a({-href=>"javascript:back()"}, "go back and try again"));
	     return $page;
	  	}
	}

  	# start date not given or invalid
  if (!param('experiment_licence_valid_from') || check_datetime_ddmmyyyy_hhmmss(param('experiment_licence_valid_from')) != 1) {
     $page .= p({-class=>"red"}, b("Error: experiment start date has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # end date not given or invalid
  if (!param('experiment_licence_valid_to') || check_datetime_ddmmyyyy_hhmmss(param('experiment_licence_valid_to')) != 1) {
     $page .= p({-class=>"red"}, b("Error: experiment end date has invalid format "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # make sure end_date is after start_date
  if (Delta_ddmmyyyhhmmss(param('experiment_licence_valid_to'), param('experiment_licence_valid_from')) eq 'future') {
     $page .= p({-class=>"red"}, b("Error: experiment end date should be after experiment start date "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

# convert display datetime to SQL datetime
  $sqldate_expfrom = format_display_datetime2sql_datetime(param('experiment_licence_valid_from'));
  $sqldate_expto   = format_display_datetime2sql_datetime(param('experiment_licence_valid_to'));
  
  # check input: experiment_is_active must be given and it must be either 'y' or 'n'
  if (!param('experiment_is_active') || !(param('experiment_is_active') eq 'y' || param('experiment_is_active') eq 'n')) {
     $page .= p({-class=>"red"}, b("Error: please enter if experiment is active or not"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

	
  ####################################################
  # check if experiment_name exists
  $sql = qq(select experiment_id
            from   experiments
            where  experiment_name = ?
         );

  @sql_parameters = (param('experiment_name'));

  ($experiment_name_exists) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . __LINE__)};

  if (defined($experiment_name_exists)) {
     $page .= p({-class=>"red"}, "Experiment name \"" . param('experiment_name') . "\" already exists! Please choose another one.");
     
     return $page;
  }

  ########################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during new experiment insert (begin transaction failed)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new project id
  ($new_experiment_id) = $dbh->selectrow_array("select (max(experiment_id)+1) as new_experiment_id
                                                from   experiments
                                               ");

  # ok, this is only neccessary for the very first experiment when (max(experiment_id)+1) = (NULL + 1) is undefined
  if (!defined($new_experiment_id)) { $new_experiment_id = 1; }

  # insert new experiments

	$dbh->do("insert
            into   experiments (experiment_id, experiment_name, experiment_recordname
            		, experiment_URL,experiment_granted_to_contact, experiment_licence_valid_from
            		, experiment_licence_valid_to, experiment_animalnumber, experiment_is_active)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ", undef, $new_experiment_id, param('experiment_name'), param('experiment_recordname')
            	,param('experiment_url'), param('experiment_granted_to_contact'), $sqldate_expfrom
            	,$sqldate_expto, param('experiment_animalnumber'), param('experiment_is_active')
            ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new experiment)", $sr_name . "-" . __LINE__);


  # everything ok, so commit
  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during new experiment insert (commit failed)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_experiment\t". $new_experiment_id . "\t" . param('experiment_name'));

  $page .= h3("New experiment \"" . a({-href=>"$url?choice=experiment_view&experiment_id=" . $new_experiment_id}, param('experiment_name')) . "\" successfully created");

  return $page;
}
# end of create_new_experiment_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_ADM021 create_new_genotype_1 ():                    create new genotype, step 1: input dialog
sub create_new_genotype_1 {                              my $sr_name = 'SR_ADM021';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();
  my ($page, $sql);
  my @sql_parameters;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new genotype")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new genotype")

          . hr()

          . start_form({-action => url()})

          . h3("Genotype info")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("genotype"),
                  td(textfield(-name => "genotype_name", -size=>"15", -maxlength=>"100")),
                  td("Please enter the new genotype")
              )
            )

          . p()

          . submit(-name => "choice", -value => "define new genotype") . "&nbsp; &nbsp;"
          . CGI->reset(-name=>"reset form")                                 . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel")

          . end_form();

  return $page;
}
# end of create_new_genotype_1()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_ADM022 create_new_genotype_2():                     create new genotype, step 2: database transaction
sub create_new_genotype_2 {                              my $sr_name = 'SR_ADM022';
  my ($global_var_href)   = @_;                                        # get reference to global vars hash
  my $session             = $global_var_href->{'session'};             # get session handle
  my $user_id             = $session->param(-name=>'user_id');
  my $user_name           = $session->param(-name=>'username');
  my $dbh                 = $global_var_href->{'dbh'};                 # DBI database handle
  my $datetime_now        = get_current_datetime_for_sql();
  my $url = url();
  my ($page, $sql, $i, $row, $rows, $result, $rc);
  my ($genotype_name_exists);
  my ($new_genotype_id);
  my @sql_parameters;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Create a new genotype")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Create a new genotype")
          . hr();

  # check input: is genotype name given? minimum length
  if (!param('genotype_name') || param('genotype_name') eq "" || length(param('genotype_name')) < 2) {
     $page .= p({-class=>"red"}, b("Error: please enter a genotype (at least 1 character)"));
     return $page;
  }

  ####################################################
  # check if genotype exists
  $sql = qq(select setting_value_text
            from   settings
            where  setting_item = ?
                   and setting_value_text = ?
         );

  @sql_parameters = ('genotypes_for_popup', param('genotype_name'));

  ($genotype_name_exists) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . __LINE__)};

  if (defined($genotype_name_exists)) {
     $page .= p({-class=>"red"}, "Genotype \"" . param('genotype_name') . "\" already exists! Please choose another one.");
     return $page;
  }

  ########################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during new genotype insert (begin transaction failed)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new genotype id
  ($new_genotype_id) = $dbh->selectrow_array("select (max(cast(setting_key as signed))+1) as new_genotype_id
                                              from   settings
                                              where  setting_item = 'genotypes_for_popup'
                                             ");

  # ok, this is only neccessary for the very first experiment when (max(experiment_id)+1) = (NULL + 1) is undefined
  if (!defined($new_genotype_id)) { $new_genotype_id = 1; }

  # insert new genotype
  $dbh->do("insert
            into   settings (setting_id, setting_category, setting_item, setting_key ,setting_value_type,
                             setting_value_int, setting_value_text, setting_value_bool, setting_value_float, setting_description)
            values (NULL, ?, ?, ?, ?, NULL, ?, NULL, NULL, NULL)
           ", undef, 'menu', 'genotypes_for_popup', $new_genotype_id, 'text', param('genotype_name')
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new genotype)", $sr_name . "-" . __LINE__);


  # everything ok, so commit
  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during new genotype insert (commit failed)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_genotype\t". $new_genotype_id . "\t" . param('genotype_name'));

  $page .= h3("New genotype \"" . param('genotype_name') . "\" successfully created");

  return $page;
}
# end of create_new_genotype_2()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_ADM023 direct_select_1 ():                          direct SQL select, step 1: input dialog
sub direct_select_1 {                                    my $sr_name = 'SR_ADM023';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();
  my ($page, $sql);
  my @sql_parameters;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("SQL interface for select queries")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("SQL interface for select queries")

          . hr()

          . start_form({-action => url()})

          . h3("Select query")

          . p("Please enter SQL select query (e.g. \"select mouse_id, mouse_sex from mice\")")

          . p(textarea(-name => "SQL_select", -columns=>"80", -rows=>"20", -value=>"select"))

          . p()

          . submit(-name => "choice", -value => "send query") . "&nbsp; &nbsp;"
          . CGI->reset(-name=>"reset form")                   . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel")

          . end_form();

  return $page;
}

# end of direct_select_1()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------o
# SR_ADM024 direct_select_2 ():                          direct SQL select, step 2: result view
sub direct_select_2 {                                    my $sr_name = 'SR_ADM024';
  my ($global_var_href) = @_;                            # get reference to global vars hash
  my $max_rows          = 1000;                          # max number of output rows for HTML table
  my $dbh               = $global_var_href->{'dbh'};     # DBI database handle
  my $sql               = param('SQL_select');
  my $url               = url();
  my ($sth, $page, $result, $rows, $row, $i, $column);
  my $row_line;
  my @headers;

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("SQL interface for select queries")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  ####################################################
  # check for bad content
  if (lc($sql) =~ /(drop|delete|update|create|insert|grant|replace|alter|rename|truncate|handler|load|commit|rollback|lock|purge|set)/) {
     $page = h2("SQL interface for select queries")

          . hr()

          . h3({-class=>'red'}, "Bad content ($1) found in SQL query. Only selects are allowed!");

     return ($page);
  }
  ####################################################


  $sth = $dbh->prepare($sql)              or &error_message_and_exit($global_var_href, 'problem with prepare', $sr_name . "-" . __LINE__);
  $sth->execute()                         or &error_message_and_exit($global_var_href, 'problem with execute', $sr_name . "-" . __LINE__);
  $result = $sth->fetchall_arrayref({})   or &error_message_and_exit($global_var_href, 'problem with fetch',   $sr_name . "-" . __LINE__);
  $rows = scalar @{$result};
  $sth->finish()                          or &error_message_and_exit($global_var_href, 'problem with finish',  $sr_name . "-" . __LINE__);

  $page = h2("SQL interface for select queries")

          . hr()

          . h3("Select statement")

          . p(pre($sql))

          . hr()

          . h3("Results ($rows rows total" . (($rows > $max_rows)?", first $max_rows rows shown":"") . ")");


  $page .= start_table({-border=>1});

  # generate header row
  #####################
  @headers = @{$sth->{NAME_lc} };                             # get column headers in correct order (as given by query)

  $page .= '<Tr>';

  for ($column=0; $column<=$#headers; $column++) {
     $page .= th($headers[$column]);
  }

  $page .= '</Tr>';


  # limit rows if necessary
  #########################
  if ($rows > $max_rows) {
     $rows = $max_rows;
  }

  # generate table body
  #####################
  for ($i=0; $i<$rows; $i++) {
      $row = $result->[$i];

      $page .= '<Tr>';

      for ($column=0; $column<=$#headers; $column++) {
          $page .= td(defined($row->{$headers[$column]})?$row->{$headers[$column]}:"(NULL)");
      }

      $page .= '</Tr>';

  }

  $page .= end_table();

  return $page;
}
# end of direct_select_2()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM025 create_new_parameterset_1():                 create new parameterset, step 1: input dialog
sub create_new_parameterset_1 {                          my $sr_name = 'SR_ADM025';
  my ($global_var_href) = @_;                                     # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();
  my ($page, $sql);
  my @sql_parameters;
  my %labels = ("y" => 'yes', "n" => 'no');
  my @user_projects = get_user_projects($global_var_href, $user_id);

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Define a new parameterset")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Define a new parameterset")

          . hr()

          . start_form({-action => url()})

          . h3("Please specify details for your new parameterset")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("parameterset name"),
                  td(textfield(-name => "parameterset_name", -size=>"30", -maxlength=>"60", -default=>'')
                     . br()
                     . small("example: \"SLIT_LAMP\"")
                  ),
                  td("Please enter the name of the new parameterset")
              ) .
              Tr( th("description"),
                  td(textarea(-name=>"parameterset_description", -columns=>"60", -rows=>"2", -value=>"")
                     . br()
                     . small("example: \"Slit lamp phenotyping assay\"")
                  ),
                  td("Please describe the parameterset.")
              ) .
              Tr( th("project"),
                  td(get_projects_popup_menu($global_var_href, $user_projects[0], 'all')
                  ),
                  td("Please choose the project to which the new parameterset is assigned.")
              ) .
              Tr( th("parameterset class"),
                  td(popup_menu(-name => "parameterset_class",
                                -values => ["1", "2", "3", "4"],
                                -labels => {"1"  => "primary screen",
                                            "2"  => "secondary screen",
                                            "3"  => "tertiary screen",
                                            "4"  => "administrative task"},
                                -default => "1"
                     )
                  ),
                  td("Please specify parameterset class")
              ) .
              Tr( th("Version"),
                  td(textfield(-name => "parameterset_version", -size=>"30", -maxlength=>"60", -default=>'')),
                  td("Please specify the version of the new parameterset.")
              ) .
              Tr( th("is parameterset active?"),
                  td(radio_group(-name=>'parameterset_is_active', -values=>['y', 'n'], -default=>3, -labels=>\%labels)
                     . br()
                     . small("example: \"yes\" if you want to use this parameterset immediately")
                  ),
                  td("Please specify if the parameterset is active or not. Not active means that the parameterset is defined, but cannot be used in MausDB.")
              )
            )

          . p()

          . submit(-name => "choice", -value => "define new parameterset") . "&nbsp; &nbsp;"
          . CGI->reset( -name => "reset form"                                 ) . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel"                 )

          . end_form();

  return $page;
}
# end of create_new_parameterset_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM026 create_new_parameterset_2():                 create new parameterset, step 2: database transaction
sub create_new_parameterset_2 {                          my $sr_name = 'SR_ADM026';
  my ($global_var_href)   = @_;                                        # get reference to global vars hash
  my $session             = $global_var_href->{'session'};             # get session handle
  my $user_id             = $session->param(-name=>'user_id');
  my $user_name           = $session->param(-name=>'username');
  my $dbh                 = $global_var_href->{'dbh'};                 # DBI database handle
  my $parameterset_name   = param('parameterset_name');
  my $url = url();
  my ($page, $sql, $i, $row, $rows, $result, $rc);
  my ($parameterset_name_exists, $new_parameterset_id);
  my @sql_parameters;
  my $datetime_now        = get_current_datetime_for_sql();

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Define a new parameterset")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Define a new parameterset")
          . hr();

  # check input: is parameterset name given?
  if (!param('parameterset_name') || param('parameterset_name') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter a name for the new parameterset (at least 1 character)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is parameterset description given?
  if (!param('parameterset_description') || param('parameterset_description') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter a description for the new parameterset (at least 1 character)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is parameterset project given? is it a number?
  if (!param('all_projects') || param('all_projects') !~ /^[0-9]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose the project to which the new parameterset is assigned to "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is parameterset class given? is it a number?
  if (!param('parameterset_class') || param('parameterset_class') !~ /^[1-4]+$/) {
     $page .= p({-class=>"red"}, b("Error: please choose the parameterset class"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is parameterset version given?
  if (!param('parameterset_version') || param('parameterset_version') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter the version of the new parameterset"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: rack_is_active must be given and it must be either 'y' or 'n'
  if (!param('parameterset_is_active') || !(param('parameterset_is_active') eq 'y' || param('parameterset_is_active') eq 'n')) {
     $page .= p({-class=>"red"}, b("Error: please enter if parameterset is active or not"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  ####################################################
  # check if parameterset name exists
  $sql = qq(select parameterset_id
            from   parametersets
            where  parameterset_name = ?
         );

  @sql_parameters = ($parameterset_name);

  ($parameterset_name_exists) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . __LINE__)};

  if (defined($parameterset_name_exists)) {
     $page .= p({-class=>"red"}, "Parameterset name \"$parameterset_name\" already exists! Please choose another one.")
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  ########################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during new parameterset insert (begin transaction failed)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new parameterset id
  ($new_parameterset_id) = $dbh->selectrow_array("select (max(parameterset_id)+1) as new_parameterset_id
                                                  from   parametersets
                                                 ");

  # ok, this is only neccessary for the very first parameterset when (max(parameterset_id)+1) = (NULL + 1) is undefined
  if (!defined($new_parameterset_id)) { $new_parameterset_id = 1; }

  # insert new parameterset
  $dbh->do("insert
            into   parametersets (parameterset_id, parameterset_name, parameterset_description, parameterset_project_id,
                                  parameterset_class, parameterset_display_order, parameterset_version, parameterset_version_datetime,
                                  parameterset_is_active)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?)
           ", undef,
           $new_parameterset_id,        $parameterset_name,   param('parameterset_description'), param('all_projects'),
           param('parameterset_class'), $new_parameterset_id, param('parameterset_version'),     $datetime_now,         param('parameterset_is_active')
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new parameterset $datetime_now)", $sr_name . "-" . __LINE__);

  # everything ok, so commit
  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during new parameterset insert (commit failed)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_parameterset\t". $parameterset_name);


  $page .= h3("New parameterset \"" . a({-href=>"$url?choice=parameterset_view&parameterset_id=" . $new_parameterset_id}, $parameterset_name) . "\" successfully created");

  return $page;
}
# end of create_new_parameterset_2()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM027 create_new_parameter_1():                    create new parameter, step 1: input dialog
sub create_new_parameter_1 {                             my $sr_name = 'SR_ADM027';
  my ($global_var_href) = @_;                                     # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();
  my ($page, $sql);
  my @sql_parameters;
  my %labels = ("y" => 'yes', "n" => 'no');
  my @user_projects = get_user_projects($global_var_href, $user_id);

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Define a new parameter")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Define a new parameter")

          . hr()

          . start_form({-action => url()})

          . h3("Please specify details for your new parameter")

          . table( {-border=>1, -bgcolor=>'lightblue'},
              Tr( th("parameter name"),
                  td(textfield(-name => "parameter_name", -size=>"30", -maxlength=>"100", -default=>'')
                     . br()
                     . small("example: \"body weight\"")
                  ),
                  td("Please enter the name of the new parameter")
              ) .
              Tr( th("parameter shortname"),
                  td(textfield(-name => "parameter_shortname", -size=>"20", -maxlength=>"20", -default=>'')
                     . br()
                     . small("example: \"bw\"")
                  ),
                  td("Please enter the name of the new parameter")
              ) .
              Tr( th("parameter description"),
                  td(textarea(-name=>"parameter_description", -columns=>"60", -rows=>"2", -value=>"")),
                  td("Please describe the parameter.")
              ) .
              Tr( th("parameter type"),
                  td(popup_menu(-name => "parameter_type",
                                -values => ["c", "f", "i", "b", "d", "t"],
                                -labels => {"c"  => "text",
                                            "f"  => "float",
                                            "i"  => "integer",
                                            "b"  => "boolean",
                                            "d"  => "date",
                                            "t"  => "datetime"},
                                -default => "1"
                     )
                  ),
                  td("Please specify parameter type")
              ) .
              Tr( th("parameter decimals"),
                  td(popup_menu(-name => "parameter_decimals",
                                -values => [0..8],
                                -default => "0"
                     )
                  ),
                  td("Please specify decimals (only for float)")
              ) .
              Tr( th("parameter unit"),
                  td(textfield(-name => "parameter_unit", -size=>"30", -maxlength=>"60", -default=>'-')
                     . br()
                     . small("example: \"g\"")
                  ),
                  td("Please specify the unit of your parameter")
              ) .
              Tr( th("parameter default"),
                  td(textfield(-name => "parameter_default", -size=>"30", -maxlength=>"60", -default=>'')
                     . br()
                     . small("example: \"2\" for parameter \"number of eyes\"")
                  ),
                  td("Please specify a default value for your parameter")
              ) .
              Tr( th("parameter choose list"),
                  td(textfield(-name => "parameter_choose_list", -size=>"50", -maxlength=>"255", -default=>'')
                     . br()
                     . small("example: \"1;2;3;4\" or \"small;medium;large\"")
                  ),
                  td("Please enter a semicolon-separated list of valid values")
              ) .
              Tr( th("parameter bounds"),
                  td(textfield(-name => "parameter_range", -size=>"50", -maxlength=>"255", -default=>'')
                     . br()
                     . small("example: \"10.0;50.0\"")
                  ),
                  td("Please enter minimum and maximum valid value, separated by semicolon")
              ) .
              Tr( th("metadata parameter?"),
                  td(radio_group(-name=>'parameter_is_metadata', -values=>['y', 'n'], -default=>3, -labels=>\%labels)
                     . br()
                     . small("example: \"yes\" if parameter describes measurement conditions, e.g. room temperature")
                  ),
                  td("Please specify if the parameter contains metadata. ")
              )
            )

          . p()

          . submit(-name => "choice", -value => "define new parameter") . "&nbsp; &nbsp;"
          . CGI->reset( -name => "reset form"                              ) . "&nbsp; &nbsp;"
          . submit(-name => "choice", -value => "cancel"              )

          . end_form();

  return $page;
}
# end of create_new_parameter_1()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM028 create_new_parameter_2():                    create new parameter, step 2: database transaction
sub create_new_parameter_2 {                             my $sr_name = 'SR_ADM028';
  my ($global_var_href)   = @_;                                        # get reference to global vars hash
  my $session             = $global_var_href->{'session'};             # get session handle
  my $user_id             = $session->param(-name=>'user_id');
  my $user_name           = $session->param(-name=>'username');
  my $dbh                 = $global_var_href->{'dbh'};                 # DBI database handle
  my $parameter_name      = param('parameter_name');
  my $url = url();
  my ($page, $sql, $i, $row, $rows, $result, $rc);
  my ($parameter_name_exists, $new_parameter_id);
  my @sql_parameters;
  my $datetime_now        = get_current_datetime_for_sql();

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Define a new parameter")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  $page = h2("Define a new parameter")
          . hr();

  # check input: is parameter name given?
  if (!param('parameter_name') || param('parameter_name') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter a name for the new parameter (at least 1 character)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is parameter shortname given?
  if (!param('parameter_shortname') || param('parameter_shortname') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter a shortname for the new parameter (at least 1 character)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is parameter description given?
  if (!param('parameter_description') || param('parameter_description') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter a description for the new parameter (at least 1 character)"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is parameter type given?
  if (!param('parameter_type') || param('parameter_type') !~ /^[cfibdt]$/) {
     $page .= p({-class=>"red"}, b("Error: please choose the data type of your new parameter [text, integer, float, boolean, date, datetime] "))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is parameter decimals given? is it a number? (check only for float parameters)
  if (param('parameter_type') eq 'f') {
     if (!param('parameter_decimals') || param('parameter_decimals') !~ /^[0-8]+$/) {
        $page .= p({-class=>"red"}, b("Error: please choose number of decimals of your new float parameter"))
                 . p(a({-href=>"javascript:back()"}, "go back and try again"));
        return $page;
     }
  }

  # check input: is parameter unit given?
  if (!param('parameter_unit') || param('parameter_unit') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter the unit of your parameter"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: is parameter default given?
  if (!param('parameter_default') || param('parameter_default') eq '') {
     $page .= p({-class=>"red"}, b("Error: please enter the default for your parameter"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  # check input: parameter_is_metadata must be given and it must be either 'y' or 'n'
  if (!param('parameter_is_metadata') || !(param('parameter_is_metadata') eq 'y' || param('parameter_is_metadata') eq 'n')) {
     $page .= p({-class=>"red"}, b("Error: please enter if parameter is metadata or not"))
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  ####################################################
  # check if parameter name exists
  $sql = qq(select parameter_id
            from   parameters
            where          parameter_name = ?
                   or parameter_shortname = ?
                   or      parameter_name = ?
                   or parameter_shortname = ?
         );

  @sql_parameters = ($parameter_name, $parameter_name, param('parameter_shortname'), param('parameter_shortname'));

  ($parameter_name_exists) = @{do_single_result_sql_query($global_var_href, $sql, \@sql_parameters, $sr_name . __LINE__)};

  if (defined($parameter_name_exists)) {
     $page .= p({-class=>"red"}, "Parameter name \"$parameter_name\" or parameter shortname \"" . param('parameter_shortname') . "\" already exists! Please choose another one.")
              . p(a({-href=>"javascript:back()"}, "go back and try again"));
     return $page;
  }

  ########################################################
  # begin transaction
  $rc = $dbh->begin_work or &error_message_and_exit($global_var_href, "error during new parameter insert (begin transaction failed)", $sr_name . "-" . __LINE__);

  ##################################
  # get a new parameterset id
  ($new_parameter_id) = $dbh->selectrow_array("select (max(parameter_id)+1) as new_parameter_id
                                               from   parameters
                                              ");

  # ok, this is only neccessary for the very first parameter when (max(parameter_id)+1) = (NULL + 1) is undefined
  if (!defined($new_parameter_id)) { $new_parameter_id = 1; }

  # insert new parameter
  $dbh->do("insert
            into   parameters (parameter_id, parameter_name, parameter_shortname, parameter_type, parameter_decimals, parameter_unit,
                               parameter_description, parameter_default, parameter_choose_list, parameter_normal_range, parameter_is_metadata)
            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
           ", undef,
           $new_parameter_id, $parameter_name, param('parameter_shortname'), param('parameter_type'), param('parameter_decimals'), param('parameter_unit'),
           param('parameter_description'),     param('parameter_default'),   param('parameter_choose_list'), param('parameter_range'), param('parameter_is_metadata')
        ) or &error_message_and_exit($global_var_href, "SQL error (could not insert new parameter)", $sr_name . "-" . __LINE__);

  # everything ok, so commit
  $rc = $dbh->commit() or &error_message_and_exit($global_var_href, "error during new parameter insert (commit failed)", $sr_name . "-" . __LINE__);

  # end transaction
  ########################################################

  &write_textlog($global_var_href, "$datetime_now\t$user_id\t" . $user_name . "\tnew_parameter\t". $new_parameter_id . "\t" . $parameter_name);

  $page .= h3("New parameter \"" . a({-href=>"$url?choice=parameter_view&parameter_id=" . $new_parameter_id}, $parameter_name) . "\" successfully created")
           . p()
           . p("You may go to the " . a({-href=>"$url?choice=parameters_overview"}, "parameters overview") . " or " . a({-href=>"$url?choice=new_parameter"}, "create another parameter"));

  return $page;
}
# end of create_new_parameter_2()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_ADM029 add_parameters_to_parameterset_11():         create new parameter, step 1: input dialog
sub add_parameters_to_parameterset_1 {                   my $sr_name = 'SR_ADM029';
  my ($global_var_href) = @_;                                     # get reference to global vars hash
  my $session           = $global_var_href->{'session'};          # get session handle
  my $user_id           = $session->param(-name=>'user_id');
  my $url = url();
  my ($page, $sql, $parameter_to_add);
  my @sql_parameters;
  my @parameters_to_add = param('parameter_select');
  my $parameterset_name = get_parameterset_name_by_id($global_var_href, param('parameterset'));

  ####################################################
  # if user does not have an admin role, reject
  if (current_user_is_admin($global_var_href) eq 'n') {
     $page = h2("Add parameters to parameterset \"$parameterset_name\"")

          . hr()

          . h3("Sorry, you don't have admin rights. Please contact the administrator.");

     return ($page);
  }
  ####################################################

  ####################################################
  # check if at least one parameter to add
  if (scalar @parameters_to_add == 0) {
     $page = h2("Add parameters to parameterset \"$parameterset_name\"")
             . hr()
             . p({-class=>"red"}, b("Please select at least one parameter to add to parameterset! "))
             . p(a({-href=>"javascript:back()"}, "go back and try again"));

     return ($page);
  }
  ####################################################

  $page = h2("Add parameters to parameterset \"$parameterset_name\"")

          . hr()

          . start_form({-action => url()})

          . h3("Please complete the form ")

          . start_table({-border=>"1"})

          . Tr(
              th('ID'),
              th('parameter'),
              th('Excel upload column'),
              th('Excel upload column name'),
              th('simple/series'),
              th('increment value'),
              th('increment unit'),
              th('required')
            );

  # loop over all parameters to be added
  foreach $parameter_to_add (@parameters_to_add) {
     if ($parameter_to_add =~ /^[0-9]{1,}$/) {

         $page .= Tr(
                    td($parameter_to_add),
                    td(get_parameter_name_by_id($global_var_href, $parameter_to_add)),
                    td(popup_menu(-name   => "Excel_column_" . $parameter_to_add,
                                  -values => [ '1',  '2',  '3',  '4',  '5',  '6',  '7',  '8',  '9', '10',
                                              '11', '12', '13', '14', '15', '16', '17', '18', '19', '20',
                                              '21', '22', '23', '24', '25', '26', '27', '28', '29', '30',
                                              '31', '32', '33', '34', '35', '36', '37', '38', '39', '40',
                                              '41', '42', '43', '44', '45', '46', '47', '48', '49', '50',
                                              '51', '52'],
                                  -default=> "0",
                                  -labels => {'1' =>  'A',  '2' =>  'B',  '3' =>  'C',  '4' =>  'D',  '5' =>  'E',
                                              '6' =>  'F',  '7' =>  'G',  '8' =>  'H',  '9' =>  'I', '10' =>  'J',
                                              '11' =>  'K', '12' =>  'L', '13' =>  'M', '14' =>  'N', '15' =>  'O',
                                              '16' =>  'P', '17' =>  'Q', '18' =>  'R', '19' =>  'S', '20' =>  'T',
                                              '21' =>  'U', '22' =>  'V', '23' =>  'W', '24' =>  'X', '25' =>  'Y',
                                              '26' =>  'Z', '27' => 'AA', '28' => 'AB', '29' => 'AC', '30' => 'AD',
                                              '31' => 'AE', '32' => 'AF', '33' => 'AG', '34' => 'AH', '35' => 'AI',
                                              '36' => 'AJ', '37' => 'AK', '38' => 'AL', '39' => 'AM', '40' => 'AN',
                                              '41' => 'AO', '42' => 'AP', '43' => 'AQ', '44' => 'AR', '45' => 'AS',
                                              '46' => 'AT', '47' => 'AU', '48' => 'AV', '49' => 'AW', '50' => 'AX',
                                              '51' => 'AY', '52' => 'AZ'
                                             }
                       )
                    ),
                    td(textfield(  -name => 'Excel_column_name_' . $parameter_to_add,
                                   -size => '20', -maxlength => '100',
                                   -title => ''
                       )
                    ),
                    td(radio_group(-name => "parameter_type_" . $parameter_to_add,
                                   -values=>['simple', 'series'],
                                   -default=>''
                       )
                    ),
                    td(textfield(  -name => 'increment_value_'  . $parameter_to_add,
                                   -size => '20', -maxlength => '30',
                                   -title => ''
                       )
                    ),
                    td(textfield(  -name => 'increment_unit_' . $parameter_to_add,
                                   -size => '20', -maxlength => '30',
                                   -title => ''
                      )
                    ),
                    td(radio_group(-name => "parameter_required_" . $parameter_to_add,
                                   -values=>['yes', 'no'],
                                   -default=>''
                       )
                    )
                  );
     }
  }

  $page .= end_table()
           . p()

           . hidden(-name=>'parameterset_id', -value=>param('parameterset'))
           . hidden('parameter_select')

           . submit(-name => "choice", -value => "add parameters to parameterset!") . "&nbsp; &nbsp;"
           . submit(-name => "choice", -value => "cancel")

           . end_form();

  return $page;
}
# end of add_parameters_to_parameterset_1()
#--------------------------------------------------------------------------------------


# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;