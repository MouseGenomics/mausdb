#!/usr/bin/perl -Tw                                                                                                              #
#                                                                                                                                #
##################################################################################################################################
#                                                                                                                                #
# MausDB - a web-based laboratory mouse information and management system (LMIMS)                                                #
# $Id:: mausdb.cgi 117 2010-02-25 13:53:08Z maier                                                                            $   #
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

# parse the config file and fill the configuration hash. The config file is expected to be in the same directory as this file
my %User_Preferences    = read_config_file('./config.rc');

# INSTALLATION SPECIFIC SETTINGS
my $MAUSDB_LOCK         = $User_Preferences{'MAUSDB_LOCK'};           # ['false' or 'true']. Set this on 'true' to lock out users during service periods
my $server              = $User_Preferences{'server'};                # server on which MausDB is running
my $mode                = $User_Preferences{'mode'};                  # just a title suffix (to indicate Development, Demo or Production status in title)
my $log_prefix          = $User_Preferences{'log_prefix'};            # the prefix for the audit log files
my $local_basedir       = $User_Preferences{'local_basedir'};         # webserver base directory in local filesystem
my $local_cgi_basedir   = $User_Preferences{'local_cgi_basedir'};     # webserver cgi base directory in local filesystem
my $local_htdoc_basedir = $User_Preferences{'local_htdoc_basedir'};   # webserver htdocs base directory in local filesystem
my $URL_basedir         = $User_Preferences{'URL_cgi_basedir'};       # URL of webserver base
my $URL_cgi_basedir     = $User_Preferences{'URL_cgi_basedir'};       # URL of cgi base
my $URL_htdoc_basedir   = $User_Preferences{'URL_htdoc_basedir'};     # URL of htdocs base
my $cookie_name         = $User_Preferences{'cookie_name'};           # name of cookie that carries session id
my $connect_path        = $User_Preferences{'connect_path'};          # path to directory where the 'DB_connect.pm'-file with database connection parameters is located
my $blob_database       = $User_Preferences{'blob_database'};         # name of the blob database. It is a separate database due to it's potential size
my $cryo_database       = $User_Preferences{'cryo_database'};         # is cryo database available?
my $olympus_database    = $User_Preferences{'olympus_database'};      # is olympus database available?
my $start_mouse_id      = $User_Preferences{'start_mouse_id'};        # mouse ID to start with if very first mouse in DB
my $application			= $User_Preferences{'application'};			  # flag for application: mausnet or mausdb

# ESSENTIAL SUBROUTINE LIBARIES AND PACKAGES
$ENV{'PATH'} = $local_cgi_basedir;                                    # restrict PATH to script directory (security issue)
push(@INC, '.', $connect_path);                                       # path to modules
require DB_connect;                                                   # database connection module (contains database connection parameters, returns database handle)
require 'lib_functions.pl';                                           # some often used general functions are located in this file
require 'lib_db_selects.pl';                                          # select statements => "views" (may be replaced by database level views in the future)
require 'lib_convert.pl';                                             # formatting and converting functions
require 'lib_grouping.pl';                                            # grouping and "shopping cart" functions

# STANDARD OR CPAN MODULES                                            ... and what they do:
use strict;                                                           # force declaration of variables
use English;                                                          # enable use of some special named variables (e.g. $a)
use locale;                                                           # required for use of lc() and uc()
use CGI qw(:standard escape escapeHTML center
           *table *Tr *div );                                         # handling of input parameters and generation of HTML, forms and tables etc ...
use CGI::Carp qw(fatalsToBrowser);                                    # output errors in browser (UNCOMMENT IN PRODUCTIVE VERSION!!!!!!!!!!!!!)
use CGI::Pretty;                                                      # reformat HTML output to be more readable
use CGI::Session;                                                     # include methods for session management
use Digest::MD5;                                                      # include library to calculate MD5 checksums (for password checking)

# MAIN VARIABLES
my $choice;                                                           # variable that is filled with the primary user instruction (what to do) via CGI
my $job  = '';                                                        # variable that is filled with the alternate user instruction (for reloading pages)
my $page = '';                                                        # page string (the string that holds the complete <body>...</body> part of the final page)
my $global_lock_message = '';                                         # if a global lock is set, place a message for others admins that are not locked out
my $sid;                                                              # session id from cookie (from previous script invocation) that has to be either checked or generated
my $session;                                                          # a CCI::Session object
my ($username, $password, $user_id, $user_status);                    # self-explaining, isn't it?
my $password_md5 = Digest::MD5->new();                                # a Digest::MD5 object (needed to calculate MD5 sum of password)
my ($password_checksum);                                              # self-explaining, isn't it?
my $sql;                                                              # holds a prepared SQL statement
my @sql_parameters;                                                   # holds parameters for prepared SQL statements
my $is_admin;                                                         # check if current user has admin role

# SETTINGS/GLOBAL VARIABLES
$|                  = 1;                                              # STDOUT buffering off. This means that script output (= HTML code) is delivered immediately to the client.
my $url             = url();                                          # base URL of this script (for example: "http://darvas.helmholtz-muenchen.de/cgi-bin/maus/mausdb.cgi")
my $session_timeout = '+24h';                                         # setting session timeout: session ends after this time of inactivity

# OPEN CONNECTION TO DATABASE (connection parameters given in DB_connect.pm)
my ($dbh, $db_server, $db_name) = DB_connect::connect();              # open a database handle using the parameters defined in the DB_connect module

# "global" variables/settings are not really global, but passed as a hash reference to the subroutines
my %global_vars = ( "dbh"                    => $dbh,                 # database handle
                    "db_server"              => $server,              # server on which MausDB is running
                    "db_name"                => $db_name,             # database name
                    "bg_color_male"          => '#99CCFF',            # table background color for males
                    "bg_color_female"        => '#FFAADD',            # table background color for females
                    "bg_color_mixed_sex"     => '#FFFFDD',            # table background color for mixed cages
                    "rack_usage_bar_width"   => 40,                   # a rack will be graphically represented by this number of symbols
                    "max_upload_filesize_kb" => 100,                  # maximum file size for uploads in kilobytes
                    "min_password_length"    => 5,                    # minimum length of a password
                    "show_rows"              => 25,                   # how many lines of results in one table page?
                    "local_cgi_basedir"      => $local_cgi_basedir,
                    "local_htdoc_basedir"    => $local_htdoc_basedir,
                    "URL_cgi_basedir"        => $URL_cgi_basedir,
                    "URL_htdoc_basedir"      => $URL_htdoc_basedir,
                    "log_file_name"          => $log_prefix . get_current_date_for_logs() . '.log',
                    "blob_database"          => $blob_database,
                    "cryo_database"          => $cryo_database,
                    "olympus_database"       => $olympus_database,
                    "global_lock_status"     => $MAUSDB_LOCK,
                    "start_mouse_id"         => $start_mouse_id,
                    "application"            => $application
                  );


#############################################################################################################################
# MAIN                                                                                                                      #
#############################################################################################################################


#############################################################################################################################
# AUTHENTICATION AND SESSION HANDLING

# check if there is a session id by reading session id from a cookie (also possible: read session id from URL => || param('CGISESSID') )
# otherwise leave session id undefined
$sid = cookie($cookie_name) || undef;

# either resume or open new session depending if $sid is defined or not (sessions are currently maintained in the server file system. this could also be done in the database)
$session = CGI::Session->new(undef, $sid, {Directory=>'./sessions'});         # store sessions in ./sessions subdirectory of script path

# in either case, we have a session now. Either a new one or an existing one.
# now let's check if the login authentification is still valid

# check if still logged in and request comes from the same machine on which session was initiated (to prevent session capturing) ...
if (defined($session->param('_IS_LOGGED_IN')) && $session->param('_IS_LOGGED_IN') eq 'yes' && $session->param('remote_from')   eq $ENV{'REMOTE_ADDR'}) {
   # if there is a global lock (prevent any user action during service times)
   if ($MAUSDB_LOCK eq 'true') {
      # if a global lock is set, place a message for others admins that are not locked out
      $global_lock_message = hr()
                             . h3(b({-class=>'red', -style=>'background-color: yellow;'}, '!!!! ATTENTION !!!! GLOBAL LOCK SET FOR ALL USERS EXCEPT ADMINS !!!!'));

      # check if user has admin role
      $sql = qq(select user_id
                from   users
                where  user_id = ?
                       and user_roles like '%a%'
               );

      @sql_parameters = ($session->param('user_id'));

      ($is_admin) = @{do_single_result_sql_query(\%global_vars, $sql, \@sql_parameters, 'Main_' . __LINE__)};

      # admin users may continue, others go the the lock page
      unless (defined($is_admin) && $is_admin == $session->param('user_id')) {
         &print_lock_page($session);
      }
   }
   # else continue with MAIN
}

# if not logged in (session may be either timed out or user wants to start a new session)
else {
   # if there is a global lock (prevent any user action during service times)
   if ($MAUSDB_LOCK eq 'true') {
      &print_lock_page($session);
   }

   # it is a new session and no previous session id is given, so display login form
   if (!defined($sid)) {
      &print_login_form($session);
   }

   # it is a new login, but login form has been submitted, so check login parameters
   elsif (param('login') eq 'login' ) {
      # check login
      $username = param('username');
      $password = param('password');

      # check if username contains illegal characters (prevent SQL injections)
      if (param('username') =~ /[^a-zA-Z0-9]/) {
         &print_login_form($session, "red", "For security reasons, valid usernames may contain numbers and letters only (a-zA-Z0-9). You may know what I mean.");
      }

      # check if password contains illegal characters (prevent SQL injections)
      if (param('password') =~ /[^a-zA-Z0-9]/) {
         &print_login_form($session, "red", "For security reasons, valid passwords may contain numbers and letters only (a-zA-Z0-9). You may know what I mean.");
      }

      # calculate MD5 sum of given password
      $password_md5->add($password);
      $password_checksum = $password_md5->hexdigest();

      $sql = qq(select user_id, user_status
                from   users
                where  user_name     = ?
                and    user_password = ?
               );

      @sql_parameters = ($username, $password_checksum);

      ($user_id, $user_status) = @{do_single_result_sql_query(\%global_vars, $sql, \@sql_parameters, 'Main_' . __LINE__)};

      # if login ok, init a new session
      if (defined($user_status) && $user_status eq "active") {
         $session->param(-name=>'_IS_LOGGED_IN', -value=>'yes');
         $session->expire(_IS_LOGGED_IN => $session_timeout);
         $session->param(-name=>'username',      -value=>"$username");
         $session->param(-name=>'user_id',       -value=>"$user_id" );
         $session->param(-name=>'remote_from',   -value=>"$ENV{'REMOTE_ADDR'}");               # log IP of remote client to prevent session capturing
         $session->expire($session_timeout);                                                   # end session after given inactivity time

         # remove password from CGI namespace before, because ...
         CGI::delete('password', 'login');                                                     # ... we dont want cleartext passwords to be logged
         CGI::param(-name=>'choice',-value=>'login');                                          # set choice on "login"
      }
      elsif (defined($user_status) && $user_status ne "active") {
         &print_login_form($session, "red", "Sorry, your account is currently locked. Please contact the MausDB administrators.");
      }
      else {
         &print_login_form($session, "red", "Login failed. Please try again or contact the MausDB administrators.");
      }
   }

   # there was a session, but it expired or never was validated, so force new login
   elsif (defined($sid)) {
      &print_login_form($session, "red", "Sorry, your session timed out. Please log in again.");
   }

   # else force new login anyway
   else {
      &print_login_form($session);
   }
}

# UPDATE SESSION
$global_vars{'session'} = $session;                     # add session to "global" vars hash

# at this point, we have validated the authentification (or not) and a session has been created or resumed => we may continue ...
# END OF AUTHENTICATION AND SESSION HANDLING
#############################################################################################################################

# What to do or in other words: "what does the user want?"
# read input submitted via URL or via submitted forms into $choice ...
$choice = lc(param("choice"));                          # convert user choice to lower case

if (param('job')) {
   $job = lc(param("job"));                             # convert user choice to lower case
}

# to avoid logging of cleartext passwords ...
if ($choice eq 'login' || $choice eq 'logout') {        # ... dont log password fields
   # in all other cases: write log
   &write_log($dbh, $session->param(-name=>'user_id'), $session->param(-name=>'username'), $choice);
   &write_textlog(\%global_vars, get_current_datetime_for_sql() . "\t". $session->param('user_id') . "\t" . $session->param('username') . "\t$choice");
}
else {
   &write_log($dbh, $session->param(-name=>'user_id'), $session->param(-name=>'username'), $choice);
}

{# DISPATCHER
# generate variable part of final HTML (): decide what to do and let the subfunction in charge generate the desired HTML output
#
#                 "desired action"      ...                         include subroutine file ..... and call subroutine accordingly

if    ($job    eq "kill"                                               ) { require 'lib_kill.pl';             $page .= kill_mouse(\%global_vars);                              }
elsif ($job    eq "reanimate"                                          ) { require 'lib_kill.pl';             $page .= reanimate_mouse(\%global_vars);                         }
elsif ($job    eq "append comment"                                     ) { require 'lib_update.pl';           $page .= append_comment(\%global_vars);                          }
elsif ($job    eq "delete comments"                                    ) { require 'lib_update.pl';           $page .= delete_comments(\%global_vars);                         }
elsif ($job    eq "build a cohort"                                     ) { require 'lib_grouping.pl';         $page .= build_cohort_1(\%global_vars);                          }
elsif ($job    eq "mate"                                               ) { require 'lib_mating.pl';           $page .= new_mating(\%global_vars);                              }
elsif ($job    eq "embryotransfer"                                     ) { require 'lib_mating.pl';           $page .= new_embryotransfer(\%global_vars);                      }
elsif ($job    eq "stop mating"                                        ) { require 'lib_view.pl';             $page .= mating_view(\%global_vars);                             }
elsif ($job    eq "report litter"                                      ) { require 'lib_view.pl';             $page .= mating_view(\%global_vars);                             }
elsif ($job    eq "save cart"                                          ) { require 'lib_view.pl';             $page .= show_cart(\%global_vars);                               }
elsif ($job    eq "load cart"                                          ) { require 'lib_view.pl';             $page .= view_carts(\%global_vars);                              }
elsif ($job    eq "update line comment"                                ) { require 'lib_view.pl';             $page .= line_view(\%global_vars);                               }
elsif ($job    eq "update gtas information"                            ) { require 'lib_view.pl';             $page .= line_view(\%global_vars);                               }
elsif ($job    eq "add to cohort"                                      ) { require 'lib_view.pl';             $page .= cohort_view(\%global_vars);                             }
elsif ($job    eq "genotype"                                           ) { require 'lib_genotype.pl';         $page .= genotype_1(\%global_vars);                              }
elsif ($job    eq "assign coat color"                                  ) { require 'lib_genotype.pl';         $page .= colortype_1(\%global_vars);                             }
elsif ($job    eq "add treatment"                                      ) { require 'lib_treatment.pl';        $page .= add_treatment_1(\%global_vars);                         }
elsif ($job    eq "add/change experiment"                              ) { require 'lib_experiment.pl';       $page .= experiment_1(\%global_vars);                            }
elsif ($job    eq "add/change cost centre"                             ) { require 'lib_accounting.pl';       $page .= cost_centre_1(\%global_vars);                           }
elsif ($job    eq "add gene link"                                      ) { require 'lib_view.pl';             $page .= gene_details(\%global_vars);                            }
elsif ($job    eq "order phenotyping"                                  ) { require 'lib_phenotyping.pl';      $page .= phenotyping_order_1(\%global_vars);                     }
elsif ($job    eq "remove selected from orderlist"                     ) { require 'lib_phenotyping.pl';      $page .= orderlist_view(\%global_vars);                          }
elsif ($job    eq "add to orderlist"                                   ) { require 'lib_phenotyping.pl';      $page .= orderlist_view(\%global_vars);                          }
elsif ($job    eq "view phenotyping data"                              ) { require 'lib_phenotyping.pl';      $page .= view_phenotyping_data_1(\%global_vars);                 }
elsif ($job    eq "print selected orderlist"                           ) { require 'lib_phenotyping.pl';      $page .= print_orderlist(\%global_vars);                         }
elsif ($job    eq "report litter loss"                                 ) { require 'lib_view.pl';             $page .= litter_view(\%global_vars);                             }
elsif ($job    eq "update litter details"                              ) { require 'lib_view.pl';             $page .= litter_view(\%global_vars);                             }
elsif ($job    eq "upload data for mice from this list"                ) { require 'lib_upload_data.pl';      $page .= upload_step_1(\%global_vars);                           }
elsif ($job    eq "upload and link file to selected mice"              ) { require 'lib_upload_data.pl';      $page .= upload_blob_step_1(\%global_vars);                      }
elsif ($job    eq "assign media files"                                 ) { require 'lib_upload_data.pl';      $page .= assign_media_files_step_1(\%global_vars);               }
elsif ($job    eq "move selected cages"                                ) { require 'lib_move.pl';             $page .= move_cages(\%global_vars);                              }
elsif ($job    eq "move selected mice"                                 ) { require 'lib_move.pl';             $page .= move_mice(\%global_vars);                               }
elsif ($job    eq "apply r script"                                     ) { require 'lib_stat.pl';             $page .= select_R_analysis(\%global_vars);                       }
elsif ($choice eq "upload_files_to_mouse"                              ) { require 'lib_upload_data.pl';      $page .= upload_multi_blob_for_mouse_step_1(\%global_vars);      }
elsif ($choice eq "home" || $choice eq "cancel"                        ) { require 'lib_view.pl';             $page .= start_page(\%global_vars);                              }
elsif ($choice eq "location_overview"                                  ) { require 'lib_view.pl';             $page .= location_overview(\%global_vars);                       }
elsif ($choice eq "location_details"                                   ) { require 'lib_view.pl';             $page .= location_details(\%global_vars);                        }
elsif ($choice eq "external_mouse_details"                             ) { require 'lib_view.pl';             $page .= external_mouse_details(\%global_vars);                  }
elsif ($choice eq "search by mouse id"                                 ) { require 'lib_view.pl';             $page .= mouse_details(\%global_vars);                           }
elsif ($choice eq "view mouse/cage"                                    ) { require 'lib_view.pl';             $page .= mouse_details(\%global_vars);                           }
elsif ($choice eq "mouse_details"                                      ) { require 'lib_view.pl';             $page .= mouse_details(\%global_vars);                           }
elsif ($choice eq "print_card"                                         ) { require 'lib_view.pl';             $page .= print_cage_card(\%global_vars);                         }
elsif ($choice eq "restore_cart"                                       ) { require 'lib_view.pl';             $page .= show_cart(\%global_vars);                               }
elsif ($choice eq "show_cart"                                          ) { require 'lib_view.pl';             $page .= show_cart(\%global_vars);                               }
elsif ($choice eq "show_carts"                                         ) { require 'lib_view.pl';             $page .= view_carts(\%global_vars);                              }
elsif ($choice eq "delete_cart"                                        ) { require 'lib_view.pl';             $page .= view_carts(\%global_vars);                              }
elsif ($choice eq "cage_view"                                          ) { require 'lib_view.pl';             $page .= show_cage(\%global_vars);                               }
elsif ($choice eq "view_cohort"                                        ) { require 'lib_view.pl';             $page .= cohort_view(\%global_vars);                             }
elsif ($choice eq "gene_details"                                       ) { require 'lib_view.pl';             $page .= gene_details(\%global_vars);                            }
elsif ($choice eq "import_view"                                        ) { require 'lib_view.pl';             $page .= import_view(\%global_vars);                             }
elsif ($choice eq "user_details"                                       ) { require 'lib_view.pl';             $page .= user_details(\%global_vars);                            }
elsif ($choice eq "contact_view"                                       ) { require 'lib_view.pl';             $page .= contact_view(\%global_vars);                            }
elsif ($choice eq "mating_view"                                        ) { require 'lib_view.pl';             $page .= mating_view(\%global_vars);                             }
elsif ($choice eq "search by mating id"                                ) { require 'lib_view.pl';             $page .= mating_view(\%global_vars);                             }
elsif ($choice eq "search by import id"                                ) { require 'lib_view.pl';             $page .= import_view(\%global_vars);                             }
elsif ($choice eq "litter_view"                                        ) { require 'lib_view.pl';             $page .= litter_view(\%global_vars);                             }
elsif ($choice eq "search by litter id"                                ) { require 'lib_view.pl';             $page .= litter_view(\%global_vars);                             }
elsif ($choice eq "cost_centre_overview"                               ) { require 'lib_view.pl';             $page .= cost_centres_overview(\%global_vars);                   }
elsif ($choice eq "view_line_vs_parameterset_data"                     ) { require 'lib_view.pl';             $page .= line_parameterset_matrix(\%global_vars);                }
elsif ($choice eq "show_line_orderlists_for_parameterset"              ) { require 'lib_view.pl';             $page .= line_orderlists_for_parameterset(\%global_vars);        }
elsif ($choice eq "data_overview_for_line"                             ) { require 'lib_view.pl';             $page .= data_overview_for_line(\%global_vars);                  }
elsif ($choice eq "user_overview"                                      ) { require 'lib_view.pl';             $page .= user_overview(\%global_vars);                           }
elsif ($choice eq "mating_overview"                                    ) { require 'lib_view.pl';             $page .= mating_overview(\%global_vars);                         }
elsif ($choice eq "import_overview"                                    ) { require 'lib_view.pl';             $page .= import_overview(\%global_vars);                         }
elsif ($choice eq "cohorts_overview"                                   ) { require 'lib_view.pl';             $page .= cohorts_overview(\%global_vars);                        }
elsif ($choice eq "delete_cohort"                                      ) { require 'lib_view.pl';             $page .= cohorts_overview(\%global_vars);                        }
elsif ($choice eq "experiment_overview"                                ) { require 'lib_view.pl';             $page .= experiment_overview(\%global_vars);                     }
elsif ($choice eq "experiment_view"                                    ) { require 'lib_view.pl';             $page .= experiment_view(\%global_vars);                         }
elsif ($choice eq "cage_history"                                       ) { require 'lib_view.pl';             $page .= cage_history(\%global_vars);                            }
elsif ($choice eq "healthreport_view"                                  ) { require 'lib_view.pl';             $page .= view_healthreport(\%global_vars);                       }
elsif ($choice eq "history_of_cage"                                    ) { require 'lib_view.pl';             $page .= history_of_cage(\%global_vars);                         }
elsif ($choice eq "transfer_view"                                      ) { require 'lib_view.pl';             $page .= embryo_transfer_view(\%global_vars);                    }
elsif ($choice eq "search by transfer id"                              ) { require 'lib_view.pl';             $page .= embryo_transfer_view(\%global_vars);                    }
elsif ($choice eq "download_file"                                      ) { require 'lib_view.pl';             $page .= download_file(\%global_vars);                           }
elsif ($choice eq "view_mice_of_mr"                                    ) { require 'lib_view.pl';             $page .= view_mice_of_mr(\%global_vars);                         }
elsif ($choice eq "view_file_info"                                     ) { require 'lib_view.pl';             $page .= view_blob_info(\%global_vars);                          }
elsif ($choice eq "stored_files_overview"                              ) { require 'lib_view.pl';             $page .= blob_overview(\%global_vars);                           }
elsif ($choice eq "projects_overview"                                  ) { require 'lib_view.pl';             $page .= projects_overview(\%global_vars);                       }
elsif ($choice eq "project_view"                                       ) { require 'lib_view.pl';             $page .= project_view(\%global_vars);                            }
elsif ($choice eq "genotypes_overview"                                 ) { require 'lib_view.pl';             $page .= genotypes_overview(\%global_vars);                      }
elsif ($choice eq "log_view"                                           ) { require 'lib_view.pl';             $page .= log_view(\%global_vars);                                }
elsif ($choice eq "line_overview"                                      ) { require 'lib_view.pl';             $page .= line_overview(\%global_vars);                           }
elsif ($choice eq "apply mouse line filters"                           ) { require 'lib_view.pl';             $page .= line_overview(\%global_vars);                           }
elsif ($choice eq "line_view"                                          ) { require 'lib_view.pl';             $page .= line_view(\%global_vars);                               }
elsif ($choice eq "strain_overview"                                    ) { require 'lib_view.pl';             $page .= strain_overview(\%global_vars);                         }
elsif ($choice eq "strain_view"                                        ) { require 'lib_view.pl';             $page .= strain_view(\%global_vars);                             }
elsif ($choice eq "show_ancestors"                                     ) { require 'lib_view.pl';             $page .= show_ancestors(\%global_vars);                          }
elsif ($choice eq "show_sanitary_status"                               ) { require 'lib_view.pl';             $page .= show_sanitary_status(\%global_vars);                    }
elsif ($choice eq "view_sanitary_report"                               ) { require 'lib_view.pl';             $page .= view_sanitary_report(\%global_vars);                    }
elsif ($choice eq "global_metadata_view"                               ) { require 'lib_view.pl';             $page .= view_global_metadata(\%global_vars);                    }
elsif ($choice eq "treatment_procedures_overview"                      ) { require 'lib_view.pl';             $page .= treatment_procedures_overview(\%global_vars);           }
elsif ($choice eq "treatment_procedure_view"                           ) { require 'lib_view.pl';             $page .= treatment_procedure_view(\%global_vars);                }
elsif ($choice eq "mouse_treatment_view"                               ) { require 'lib_view.pl';             $page .= mouse_treatment_view(\%global_vars);                    }
elsif ($choice eq "status_codes_overview"                              ) { require 'lib_view.pl';             $page .= status_codes_overview(\%global_vars);                   }
elsif ($choice eq "sterile_matings_overview"                           ) { require 'lib_view.pl';             $page .= sterile_matings_overview(\%global_vars);                }
elsif ($choice eq "sterile matings overview"                           ) { require 'lib_view.pl';             $page .= sterile_matings_overview(\%global_vars);                }
elsif ($choice eq "workflows_overview"                                 ) { require 'lib_view.pl';             $page .= workflows_overview(\%global_vars);                      }
elsif ($choice eq "workflow_details"                                   ) { require 'lib_view.pl';             $page .= workflow_details(\%global_vars);                        }
elsif ($choice eq "find_orderlists_with_multiple_uploads"              ) { require 'lib_view.pl';             $page .= find_orderlists_with_multiple_uploads(\%global_vars);   }
elsif ($choice eq "line_breeding_stats"                                ) { require 'lib_view.pl';             $page .= line_breeding_stats(\%global_vars);                     }
elsif ($choice eq "line_breeding_genotype_stats"                       ) { require 'lib_view.pl';             $page .= line_breeding_genotype_stats(\%global_vars);            }
elsif ($choice eq "display_images"                                     ) { require 'lib_view.pl';             $page .= display_images(\%global_vars);                          }
elsif ($choice eq "show_mouse_phenotyping_records_overview"            ) { require 'lib_phenotyping.pl';      $page .= show_mouse_phenotyping_record_overview(\%global_vars);  }
elsif ($choice eq "show_mouse_phenotyping_records"                     ) { require 'lib_phenotyping.pl';      $page .= show_mouse_phenotyping_records(\%global_vars);          }
elsif ($choice eq "enter_or_edit_mouse_phenotyping_records"            ) { require 'lib_phenotyping.pl';      $page .= enter_or_edit_mouse_phenotyping_records(\%global_vars); }
elsif ($choice eq "update records"                                     ) { require 'lib_phenotyping.pl';      $page .= enter_or_edit_mouse_phenotyping_records(\%global_vars); }
elsif ($choice eq "parametersets_overview"                             ) { require 'lib_phenotyping.pl';      $page .= parametersets_overview(\%global_vars);                  }
elsif ($choice eq "parameterset_view"                                  ) { require 'lib_phenotyping.pl';      $page .= parameterset_view(\%global_vars);                       }
elsif ($choice eq "parameters_overview"                                ) { require 'lib_phenotyping.pl';      $page .= parameters_overview(\%global_vars);                     }
elsif ($choice eq "delete_parameter"                                   ) { require 'lib_phenotyping.pl';      $page .= parameters_overview(\%global_vars);                     }
elsif ($choice eq "parameter_view"                                     ) { require 'lib_phenotyping.pl';      $page .= parameter_view(\%global_vars);                          }
elsif ($choice eq "orderlist_view"                                     ) { require 'lib_phenotyping.pl';      $page .= orderlist_view(\%global_vars);                          }
elsif ($choice eq "search by orderlist id"                             ) { require 'lib_phenotyping.pl';      $page .= orderlist_view(\%global_vars);                          }
elsif ($choice eq "show_mouse_orderlists"                              ) { require 'lib_phenotyping.pl';      $page .= mouse_orderlists_view(\%global_vars);                   }
elsif ($choice eq "insert_global_metadata"                             ) { require 'lib_phenotyping.pl';      $page .= insert_global_metadata_1(\%global_vars);                }
elsif ($choice eq "insert_global_metadata_2"                           ) { require 'lib_phenotyping.pl';      $page .= insert_global_metadata_2(\%global_vars);                }
elsif ($choice eq "store metadata!"                                    ) { require 'lib_phenotyping.pl';      $page .= insert_global_metadata_3(\%global_vars);                }
elsif ($choice eq "parameterset_stats"                                 ) { require 'lib_phenotyping.pl';      $page .= parameterset_stats_view(\%global_vars);                 }
elsif ($choice eq "search by value"                                    ) { require 'lib_phenotyping.pl';      $page .= parameterset_search_by_value_form(\%global_vars);       }
elsif ($choice eq "search mice by value"                               ) { require 'lib_phenotyping.pl';      $page .= search_mice_by_value(\%global_vars);                    }
elsif ($choice eq "find_mice"                                          ) { require 'lib_searching.pl';        $page .= find_mice_page(\%global_vars);                          }
elsif ($choice eq "search by mouse ids"                                ) { require 'lib_searching.pl';        $page .= find_mice_by_id(\%global_vars);                         }
elsif ($choice eq "search by room"                                     ) { require 'lib_searching.pl';        $page .= find_mice_by_room(\%global_vars);                       }
elsif ($choice eq "search by area"                                     ) { require 'lib_searching.pl';        $page .= find_mice_by_area(\%global_vars);                       }
elsif ($choice eq "search by line and area"                            ) { require 'lib_searching.pl';        $page .= find_mice_by_line_and_area(\%global_vars);              }
elsif ($choice eq "search by foreign id"                               ) { require 'lib_searching.pl';        $page .= find_mice_by_foreign_id(\%global_vars);                 }
elsif ($choice eq "search by patho id"                                 ) { require 'lib_searching.pl';        $page .= find_mice_by_patho_id(\%global_vars);                   }
elsif ($choice eq "search by line and sex"                             ) { require 'lib_searching.pl';        $page .= find_mouse_by_line_and_sex(\%global_vars);              }
elsif ($choice eq "search by genotype"                                 ) { require 'lib_searching.pl';        $page .= find_mouse_by_genotypes(\%global_vars);                 }
elsif ($choice eq "search by cage" || $choice eq "search cage(s)"      ) { require 'lib_searching.pl';        $page .= find_mice_by_cage(\%global_vars);                       }
elsif ($choice eq "search by comment"                                  ) { require 'lib_searching.pl';        $page .= find_mice_by_comment(\%global_vars);                    }
elsif ($choice eq "search by mating name"                              ) { require 'lib_searching.pl';        $page .= find_mice_by_mating_name(\%global_vars);                }
elsif ($choice eq "search by cart name"                                ) { require 'lib_searching.pl';        $page .= find_cart_by_cart_name(\%global_vars);                  }
elsif ($choice eq "search_by_mating_name"                              ) { require 'lib_searching.pl';        $page .= find_mice_by_mating_name(\%global_vars);                }
elsif ($choice eq "search by experiment"                               ) { require 'lib_searching.pl';        $page .= find_mice_by_experiment(\%global_vars);                 }
elsif ($choice eq "search by date of death"                            ) { require 'lib_searching.pl';        $page .= find_mice_by_date_of_death(\%global_vars);              }
elsif ($choice eq "search by date of birth"                            ) { require 'lib_searching.pl';        $page .= find_mice_by_date_of_birth(\%global_vars);              }
elsif ($choice eq "search orderlists by parameterset"                  ) { require 'lib_searching.pl';        $page .= find_orderlists_by_parameterset(\%global_vars);         }
elsif ($choice eq "search files by keyword"                            ) { require 'lib_searching.pl';        $page .= find_blob_by_keyword(\%global_vars);                    }
elsif ($choice eq "search by mating project"                           ) { require 'lib_searching.pl';        $page .= find_matings_by_project(\%global_vars);                 }
elsif ($choice eq "search by mating line"                              ) { require 'lib_searching.pl';        $page .= find_matings_by_line(\%global_vars);                    }
elsif ($choice eq "search by strain"                                   ) { require 'lib_searching.pl';        $page .= find_mice_by_strain(\%global_vars);                     }
elsif ($choice eq "search lines by keyword"                            ) { require 'lib_searching.pl';        $page .= find_line_by_keyword(\%global_vars);                    }
elsif ($choice eq "find_children_of_mouse"                             ) { require 'lib_searching.pl';        $page .= find_children_of_mouse(\%global_vars);                  }
elsif ($choice eq "mate!"                                              ) { require 'lib_mating.pl';           $page .= db_set_up_mating(\%global_vars);                        }
elsif ($choice eq "report new litter"                                  ) { require 'lib_mating.pl';           $page .= report_litter(\%global_vars);                           }
elsif ($choice eq "report_litter_loss"                                 ) { require 'lib_mating.pl';           $page .= report_litter_loss(\%global_vars);                      }
elsif ($choice eq "update_litter_details"                              ) { require 'lib_mating.pl';           $page .= update_litter_details(\%global_vars);                   }
elsif ($choice eq "remove_parent_from_mating"                          ) { require 'lib_mating.pl';           $page .= remove_parent_from_mating_1(\%global_vars);             }
elsif ($choice eq "remove parent from mating"                          ) { require 'lib_mating.pl';           $page .= remove_parent_from_mating_1(\%global_vars);             }
elsif ($choice eq "setup transfer!"                                    ) { require 'lib_mating.pl';           $page .= db_set_up_transfer(\%global_vars);                      }
elsif ($choice eq "wean_litter_1"                                      ) { require 'lib_weaning.pl';          $page .= wean_litter_step_1(\%global_vars);                      }
elsif ($choice eq "next step" && param("step") eq "wean_step_1"        ) { require 'lib_weaning.pl';          $page .= wean_litter_step_2(\%global_vars);                      }
elsif ($choice eq "update weaning preview"                             ) { require 'lib_weaning.pl';          $page .= wean_litter_step_2(\%global_vars);                      }
elsif ($choice eq "next step" && param("step") eq "wean_step_2"        ) { require 'lib_weaning.pl';          $page .= wean_litter_step_3(\%global_vars);                      }
elsif ($choice eq "wean!"                                              ) { require 'lib_weaning.pl';          $page .= wean_litter_step_4(\%global_vars);                      }
elsif ($choice eq "import_step_1"                                      ) { require 'lib_import.pl';           $page .= import_step_1(\%global_vars);                           }
elsif ($choice eq "next step" && param("step") eq "import_step_1"
                              && param("import_mode") eq "from_file"   ) { require 'lib_import.pl';           $page .= upload_import_file(\%global_vars);                      }
elsif ($choice eq "next step" && param("step") eq "import_step_1"
                              && param("import_mode") eq "form_based"  ) { require 'lib_import.pl';           $page .= generate_import_mice(\%global_vars);                    }
elsif ($choice eq "next step" && param("step") eq "import_step_2"      ) { require 'lib_import.pl';           $page .= import_step_3(\%global_vars);                           }
elsif ($choice eq "update import preview"                              ) { require 'lib_import.pl';           $page .= import_step_3(\%global_vars);                           }
elsif ($choice eq "next step" && param("step") eq "import_step_3"      ) { require 'lib_import.pl';           $page .= import_step_4(\%global_vars);                           }
elsif ($choice eq "import!"                                            ) { require 'lib_import.pl';           $page .= import_step_5(\%global_vars);                           }
elsif ($choice eq "kill_mouse"                                         ) { require 'lib_kill.pl';             $page .= kill_mouse(\%global_vars);                              }
elsif ($choice eq "confirm kill"                                       ) { require 'lib_kill.pl';             $page .= confirmed_kill_mouse(\%global_vars);                    }
elsif ($choice eq "confirm genotypes"                                  ) { require 'lib_genotype.pl';         $page .= genotype_2(\%global_vars);                              }
elsif ($choice eq "genotype!"                                          ) { require 'lib_genotype.pl';         $page .= genotype_3(\%global_vars);                              }
elsif ($choice eq "confirm coat colors"                                ) { require 'lib_genotype.pl';         $page .= colortype_2(\%global_vars);                             }
elsif ($choice eq "colortype!"                                         ) { require 'lib_genotype.pl';         $page .= colortype_3(\%global_vars);                             }
elsif ($choice eq "confirm adding treatment"                           ) { require 'lib_treatment.pl';        $page .= add_treatment_2(\%global_vars);                         }
elsif ($choice eq "add treatment!"                                     ) { require 'lib_treatment.pl';        $page .= add_treatment_3(\%global_vars);                         }
elsif ($choice eq "confirm cohort"                                     ) { require 'lib_grouping.pl';         $page .= build_cohort_2(\%global_vars);                          }
elsif ($choice eq "confirm experiment"                                 ) { require 'lib_experiment.pl';       $page .= experiment_2(\%global_vars);                            }
elsif ($choice eq "add/change experiment!"                             ) { require 'lib_experiment.pl';       $page .= experiment_3(\%global_vars);                            }
elsif ($choice eq "confirm cost centre"                                ) { require 'lib_accounting.pl';       $page .= cost_centre_2(\%global_vars);                           }
elsif ($choice eq "add/change cost centre!"                            ) { require 'lib_accounting.pl';       $page .= cost_centre_3(\%global_vars);                           }
elsif ($choice eq "phenotyping: next step"                             ) { require 'lib_phenotyping.pl';      $page .= phenotyping_order_2(\%global_vars);                     }
elsif ($choice eq "phenotyping: confirm"                               ) { require 'lib_phenotyping.pl';      $page .= phenotyping_order_3(\%global_vars);                     }
elsif ($choice eq "order phenotyping!"                                 ) { require 'lib_phenotyping.pl';      $page .= phenotyping_order_4(\%global_vars);                     }
elsif ($choice eq "print_orderlist"                                    ) { require 'lib_phenotyping.pl';      $page .= print_orderlist(\%global_vars);                         }
elsif ($choice eq "view phenotyping data: next step"                   ) { require 'lib_phenotyping.pl';      $page .= view_phenotyping_data_2(\%global_vars);                 }
elsif ($choice eq "phenotype_record_details"                           ) { require 'lib_phenotyping.pl';      $page .= show_phenotype_record_details(\%global_vars);           }
elsif ($choice eq "upload_step_1"                                      ) { require 'lib_upload_data.pl';      $page .= upload_step_1(\%global_vars);                           }
elsif ($choice eq "next step" && param("step") eq "upload_step_1"      ) { require 'lib_upload_data.pl';      $page .= upload_step_1a(\%global_vars);                          }
elsif ($choice eq "next step" && param("step") eq "upload_step_1a"     ) { require 'lib_upload_data.pl';      $page .= upload_step_2(\%global_vars);                           }
elsif ($choice eq "upload!"   && param("step") eq "upload_step_2"      ) { require 'lib_upload_data.pl';      $page .= upload_step_3(\%global_vars);                           }
elsif ($choice eq "next step" && param("step") eq "upload_blob_step_1" ) { require 'lib_upload_data.pl';      $page .= upload_blob_step_2(\%global_vars);                      }
elsif ($choice eq "next step" && param("step") eq "upload_blobs_step_1") { require 'lib_upload_data.pl';      $page .= upload_multi_blob_for_mouse_step_2(\%global_vars);      }
elsif ($choice eq "assign media files!"                                ) { require 'lib_upload_data.pl';      $page .= assign_media_files_step_2(\%global_vars);               }
elsif ($choice eq "upload_line_blob"                                   ) { require 'lib_upload_data.pl';      $page .= upload_line_blob_step_1(\%global_vars);                 }
elsif ($choice eq "attach file to line!"                               ) { require 'lib_upload_data.pl';      $page .= upload_line_blob_step_2(\%global_vars);                 }
elsif ($choice eq "move_cage"                                          ) { require 'lib_move.pl';             $page .= move_cage(\%global_vars);                               }
elsif ($choice eq "move cage!"                                         ) { require 'lib_move.pl';             $page .= confirmed_cage_move(\%global_vars);                     }
elsif ($choice eq "move cages!"                                        ) { require 'lib_move.pl';             $page .= confirmed_cages_move(\%global_vars);                    }
elsif ($choice eq "move_mouse"                                         ) { require 'lib_move.pl';             $page .= move_mouse(\%global_vars);                              }
elsif ($choice eq "move mouse!"                                        ) { require 'lib_move.pl';             $page .= confirmed_mouse_move(\%global_vars);                    }
elsif ($choice eq "move mice!"                                         ) { require 'lib_move.pl';             $page .= confirmed_mice_move(\%global_vars);                     }
elsif ($choice eq "change_password"                                    ) { require 'lib_admin.pl';            $page .= change_password(\%global_vars);                         }
elsif ($choice eq "change password"                                    ) { require 'lib_admin.pl';            $page .= change_password(\%global_vars);                         }
elsif ($choice eq "admin_settings"                                     ) { require 'lib_admin.pl';            $page .= admin_overview(\%global_vars);                          }
elsif ($choice eq "admin_settings"                                     ) { require 'lib_admin.pl';            $page .= admin_overview(\%global_vars);                          }
elsif ($choice eq "direct_select"                                      ) { require 'lib_admin.pl';            $page .= direct_select_1(\%global_vars);                         }
elsif ($choice eq "send query"                                         ) { require 'lib_admin.pl';            $page .= direct_select_2(\%global_vars);                         }
elsif ($choice eq "new_user"                                           ) { require 'lib_admin.pl';            $page .= create_new_user_1(\%global_vars);                       }
elsif ($choice eq "create new user"                                    ) { require 'lib_admin.pl';            $page .= create_new_user_2(\%global_vars);                       }
elsif ($choice eq "new_line"                                           ) { require 'lib_admin.pl';            $page .= create_new_line_1(\%global_vars);                       }
elsif ($choice eq "create new line"                                    ) { require 'lib_admin.pl';            $page .= create_new_line_2(\%global_vars);                       }
elsif ($choice eq "new_strain"                                         ) { require 'lib_admin.pl';            $page .= create_new_strain_1(\%global_vars);                     }
elsif ($choice eq "create new strain"                                  ) { require 'lib_admin.pl';            $page .= create_new_strain_2(\%global_vars);                     }
elsif ($choice eq "global_locks"                                       ) { require 'lib_admin.pl';            $page .= global_locks(\%global_vars);                            }
elsif ($choice eq "set global lock"                                    ) { require 'lib_admin.pl';            $page .= global_locks(\%global_vars);                            }
elsif ($choice eq "release global lock"                                ) { require 'lib_admin.pl';            $page .= global_locks(\%global_vars);                            }
elsif ($choice eq "new_rack"                                           ) { require 'lib_admin.pl';            $page .= create_new_rack_1(\%global_vars);                       }
elsif ($choice eq "define new rack"                                    ) { require 'lib_admin.pl';            $page .= create_new_rack_2(\%global_vars);                       }
elsif ($choice eq "new_parameterset"                                   ) { require 'lib_admin.pl';            $page .= create_new_parameterset_1(\%global_vars);               }
elsif ($choice eq "define new parameterset"                            ) { require 'lib_admin.pl';            $page .= create_new_parameterset_2(\%global_vars);               }
elsif ($choice eq "new_parameter"                                      ) { require 'lib_admin.pl';            $page .= create_new_parameter_1(\%global_vars);                  }
elsif ($choice eq "define new parameter"                               ) { require 'lib_admin.pl';            $page .= create_new_parameter_2(\%global_vars);                  }
elsif ($choice eq "add parameters to parameterset"                     ) { require 'lib_admin.pl';            $page .= add_parameters_to_parameterset_1(\%global_vars);        }
elsif ($choice eq "add parameters to parameterset!"                    ) { require 'lib_phenotyping.pl';      $page .= parameterset_view(\%global_vars);                       }
elsif ($choice eq "remove_parameter_from_set"                          ) { require 'lib_phenotyping.pl';      $page .= parameterset_view(\%global_vars);                       }
elsif ($choice eq "update parameterset settings"                       ) { require 'lib_phenotyping.pl';      $page .= parameterset_view(\%global_vars);                       }
elsif ($choice eq "remove_mdd_from_set"                                ) { require 'lib_phenotyping.pl';      $page .= parameterset_view(\%global_vars);                       }
elsif ($choice eq "add metadata definition"                            ) { require 'lib_phenotyping.pl';      $page .= create_new_metadata_definition_1(\%global_vars);        }
elsif ($choice eq "add new metadata definition!"                       ) { require 'lib_phenotyping.pl';      $page .= create_new_metadata_definition_2(\%global_vars);        }
elsif ($choice eq "new_cages"                                          ) { require 'lib_admin.pl';            $page .= create_new_cages_1(\%global_vars);                      }
elsif ($choice eq "define new cages"                                   ) { require 'lib_admin.pl';            $page .= create_new_cages_2(\%global_vars);                      }
elsif ($choice eq "new_project"                                        ) { require 'lib_admin.pl';            $page .= create_new_project_1(\%global_vars);                    }
elsif ($choice eq "define new project"                                 ) { require 'lib_admin.pl';            $page .= create_new_project_2(\%global_vars);                    }
elsif ($choice eq "new_cost_centre"                                    ) { require 'lib_admin.pl';            $page .= create_new_cost_account_1(\%global_vars);               }
elsif ($choice eq "define new cost centre"                             ) { require 'lib_admin.pl';            $page .= create_new_cost_account_2(\%global_vars);               }
elsif ($choice eq "new_experiment"                                     ) { require 'lib_admin.pl';            $page .= create_new_experiment_1(\%global_vars);                 }
elsif ($choice eq "define new experiment"                              ) { require 'lib_admin.pl';            $page .= create_new_experiment_2(\%global_vars);                 }
elsif ($choice eq "new_genotype"                                       ) { require 'lib_admin.pl';            $page .= create_new_genotype_1(\%global_vars);                   }
elsif ($choice eq "define new genotype"                                ) { require 'lib_admin.pl';            $page .= create_new_genotype_2(\%global_vars);                   }
elsif ($choice eq "help"                                               ) { require 'lib_help.pl';             $page .= help_overview(\%global_vars);                           }
elsif ($choice eq "add selected mice to a group"                       ) { require 'lib_grouping.pl';         $page .= add_selection_to_group(\%global_vars);                  }
elsif ($choice eq "add_sanitary_data"                                  ) { require 'lib_health.pl';           $page .= store_rack_sanitary_data_1(\%global_vars);              }
elsif ($choice eq "store sanitary data!"                               ) { require 'lib_health.pl';           $page .= store_rack_sanitary_data_2(\%global_vars);              }
elsif ($choice eq "duplicate report"                                   ) { require 'lib_health.pl';           $page .= duplicate_report(\%global_vars);                        }
elsif ($choice eq "reports"                                            ) { require 'lib_reports.pl';          $page .= report_overview(\%global_vars);                         }
elsif ($choice eq "blob_info"                                          ) { require 'lib_reports.pl';          $page .= blob_info(\%global_vars);                               }
elsif ($choice eq "tep_start"                                          ) { require 'lib_reports.pl';          $page .= tep_1(\%global_vars);                                   }
elsif ($choice eq "generate tep report"                                ) { require 'lib_reports.pl';          $page .= tep_2(\%global_vars);                                   }
elsif ($choice eq "animal_numbers"                                     ) { require 'lib_reports.pl';          $page .= animal_numbers_1(\%global_vars);                        }
elsif ($choice eq "generate animal numbers"                            ) { require 'lib_reports.pl';          $page .= animal_numbers_2(\%global_vars);                        }
elsif ($choice eq "versuchstiermeldung_start"                          ) { require 'lib_reports.pl';          $page .= versuchstiermeldung_1(\%global_vars);                   }
elsif ($choice eq "generate versuchstiermeldung"                       ) { require 'lib_reports.pl';          $page .= versuchstiermeldung_2(\%global_vars);                   }
elsif ($choice eq "report_to_excel"                                    ) { require 'lib_reports.pl';          $page .= report_to_excel(\%global_vars);                         }
elsif ($choice eq "start_gtas_report_to_excel"                         ) { require 'lib_reports.pl';          $page .= start_GTAS_report_to_excel(\%global_vars);              }
elsif ($choice eq "generate gtas report"                               ) { require 'lib_reports.pl';          $page .= GTAS_report_to_excel(\%global_vars);                    }
elsif ($choice eq "check_database"                                     ) { require 'lib_reports.pl';          $page .= check_database(\%global_vars);                          }
elsif ($choice eq "animal_cage_days"                                   ) { require 'lib_reports.pl';          $page .= animal_cage_time_1(\%global_vars);                      }
elsif ($choice eq "generate animal cage occupation"                    ) { require 'lib_reports.pl';          $page .= animal_cage_time_2(\%global_vars);                      }
elsif ($choice eq "generate excel report"                              ) { require 'lib_reports.pl';          $page .= animal_cage_time_excel(\%global_vars);                  }
elsif ($choice eq "stock_taking_list"                                  ) { require 'lib_reports.pl';          $page .= rack_stock_taking_to_excel(\%global_vars);              }
elsif ($choice eq "stats"                                              ) { require 'lib_reports.pl';          $page .= statistics(\%global_vars);                              }
elsif ($choice eq "start_maus_cat_to_excel"                            ) { require 'lib_reports.pl';          $page .= start_maus_cat_to_excel(\%global_vars);                 }
elsif ($choice eq "mouse catalogue"                                    ) { require 'lib_reports.pl';          $page .= maus_cat_to_excel(\%global_vars);                       }
elsif ($choice eq "logout"                                             ) {                                    $page .= logout(\%global_vars);                                  }
elsif ($choice eq "append comment!"                                    ) { require 'lib_update.pl';           $page .= db_append_comment(\%global_vars);                       }
elsif ($choice eq "delete comments!"                                   ) { require 'lib_update.pl';           $page .= db_delete_comments(\%global_vars);                      }
elsif ($choice eq "edit_mouse_details"                                 ) { require 'lib_update.pl';           $page .= edit_mouse_details(\%global_vars);                      }
elsif ($choice eq "apply r script!"                                    ) { require 'lib_stat.pl';             $page .= start_R_analysis(\%global_vars);                        }
else                                                                     { require 'lib_view.pl';             $page .= start_page(\%global_vars);                              }
}
#  END OF DISPATCHER

# ok, add header and tail to the variable part and deliver page to client browser
# (as we use the CGI, everything printed to STDOUT is taken by Apache for delivery to the client)
&print_header($session);       # header part
print  $page;                  # variable part
&print_tail();                 # tail part

# clean up
$dbh->disconnect();            # disconnect from database

# that's it

#############################################################################################################################
# END OF MAIN, everything below are subroutines                                                                             #
#############################################################################################################################


#-----------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                               #
#-----------------------------------------------------------------------------------------------------------------------------------#
# SR_MAI001 print_header():                    prints header of every output page                                                   #
# SR_MAI002 print_tail():                      print page tail with current time                                                    #
# SR_MAI003 print_login_form():                show login form with reduced header                                                  #
# SR_MAI004 logout():                          logout                                                                               #
# SR_MAI005 error_message_and_exit():          display an error message and exit                                                    #
# SR_MAI006 print_lock_page():                 show lock page                                                                       #
# SR_MAI007 just_remarks():                    no code, just remarks, comments, documentation, ...                                  #
# SR_MAI008 read_config_file():                parse the config file and return config hash                                         #
#-----------------------------------------------------------------------------------------------------------------------------------#


#--------------------------------------------------------------------------------------
# SR_MAI001 print_header():                    prints header of every output page
sub print_header {
  my ($session)  = @_;
  my $bg_color   = 'white';
  my $session_id = $session->id();
  my ($navbar, $cookie, $sql);
  my @mice_in_cart;
  my $number_of_mice_in_cart = 0;

  # get number of mice in cart from session cookie
  if (defined($session->param('cart'))) {
     @mice_in_cart = split(/,/, $session->param('cart'));
     $number_of_mice_in_cart = scalar @mice_in_cart;
  }

  # generate session cookie from session id
  $cookie = cookie($cookie_name => $session_id);

  # generate the navigation bar and store it in a string variable
  $navbar = a({-href=>"$url?choice=home",              -title=>"this link will take you to the MausDB start page"             },    "Home"                 )  . " | " .
            a({-href=>"$url?choice=location_overview", -title=>"click here for a quick rack overview"                         },    "racks&cages"          )  . " | " .
            a({-href=>"$url?choice=find_mice",         -title=>"click here if you want to search (and find) mice"             },    "search&find"          )  . " | " .
            a({-href=>"$url?choice=import_step_1",     -title=>"click here to import mice"                                    },    "import"               )  . " | " .
            a({-href=>"$url?choice=reports",           -title=>"click here to generate reports"                               },    "reports"              )  . " | " .
            a({-href=>"$url?choice=admin_settings",    -title=>"click for settings menu"                                      },    "settings"             );

  # directly print header to STDOUT (-> Apache)
  print header( -cookie  => $cookie,
                -charset => 'utf-8')
        . comment('$Id: mausdb.cgi 117 2010-02-25 13:53:08Z maier $')
        . start_html(-title    => "(MausDB) $mode",
                     -bgcolor  => "$bg_color",                                                             # background color
                     -style    => {-src => $URL_htdoc_basedir . '/css/maus.css'},                          # style sheet to be used
                     -script   => {-language => 'JAVASCRIPT',                                              # include javascript functions
                                   -src      => $URL_htdoc_basedir . '/static_pages/mausdb.js'},           #            -"-
                     -encoding => 'utf-8'
          )
        . start_form(-action => url())
        . table( {-border=>"0", -bgcolor=>"$bg_color", -summary=>"table"},
             Tr(
               td( {-valign=>"top", align=>"left",   -width=>"20%"},
                   'Logged in as ' . $session->param(-name=>'username')
                   . ' ('
                   . a({-href=>"$url?choice=logout", -title=>'click here to end current MausDB session and log out'}, 'log out')
                   . ')'
                   . p()
                   . a({-href=>"$url?choice=show_cart", -title=>"click to show cart"},
                       img({-src=>$URL_htdoc_basedir . '/images/cart_' . (($number_of_mice_in_cart == 0)?'empty':'full') . '.png', -border=>0, -alt=>'[cart]'})
                     )
                   . br()
                   . " $number_of_mice_in_cart " . (($number_of_mice_in_cart == 1)?'mouse':'mice') . ' in cart'
                   . br()
                   . (($number_of_mice_in_cart > 0)?'(' . a({-href=>"$url?choice=show_cart&job=Empty%20cart"}, 'empty cart') . ')':'')
                 ),
               td( {-valign=>"top", align=>"center", -width=>"60%"},  h1({-class=>"blue"}, "MausDB $mode") . br() . "$navbar"),
               td( {-valign=>"top", align=>"right",  -width=>"20%"},
                   a({-href=>"$url?choice=help", -title=>"click here for help"}, "Help")              # add an input field for mouse id and button
                   . p()
                   . textfield(-name=>"mouse_id", -size=>"9", -maxlength=>"8", -title=>"enter the 8 digit mouse id or a cage id", -override=>1)
                   . submit(-name => "choice", -value=>"View mouse/cage")
                 )
             )
          )
        . end_form()
        . $global_lock_message                           # if a global lock is set, place a message for others admins that are not locked out
        . hr();
}
# end of print_header()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MAI002 subroutine print_tail():           print page tail with current time
sub print_tail {
# next three lines are just for debugging and display the list of CGI parameters transferred via GET (by URL) or POST (by forms) and the global hash
  #print hr() . hr() . h2("CGI parameters ") . Dump();
  #print hr() . hr() . h2("global vars "); print "<ul>"; foreach (sort keys %global_vars) { print li(strong($_)) . ul(li($global_vars{$_}));  } print "</ul>";
  #print hr() . hr() . h2("ENVIRONMENT "); print "<table border=1>"; foreach (keys %ENV) { print qq(<tr><TD><b>$_</b></TD><TD>$ENV{$_}</TD></tr>); } print "</table>";

  print hr()
        . small("Page generated on " . localtime())
        . end_html();
}
# end of print_tail()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MAI003 print_login_form():                show login form with reduced header
sub print_login_form {
  my ($session, $message_color, $message) = @_;
  my $session_id = $session->id();
  my $bg_color   = 'white';               # TO DO: via CSS!
  my $page;
  my $cookie;

  # generate Session cookie from session id
  $cookie = cookie($cookie_name => $session_id);

  print header( -cookie=>$cookie)
        . start_html(-title    => "(MausDB) $mode" . " Login",
                     -bgcolor  => "$bg_color",
                     -encoding => 'utf-8',
                     -style    => {-src=>$URL_htdoc_basedir . '/css/maus.css'}
          )
        . table( {-border=>"0", -bgcolor=>"$bg_color", -summary=>"table"},
             Tr(
               td( {-valign=>"top", align=>"left",   -width=>"15%"}, a( {-href=>'http://www.helmholtz-muenchen.de'}, img({-src=>$URL_htdoc_basedir . '/images/gsf_logo.gif', -border=>0, -alt=>'[Helmholtz Zentrum Muenchen - Home]'}))),
               td( {-valign=>"top", align=>"center", -width=>"60%"}, h1({-class=>"blue"}, "MausDB $mode")  . span({-class=>"blue"}, "the mouse management system of the German Mouse Clinic")),
               td( {-valign=>"top", align=>"right",  -width=>"25%"}, a( {-href=>'http://www.mouseclinic.de'}, img({-src=>$URL_htdoc_basedir . '/images/GMC_logo.gif', -border=>0, -alt=>'[German Mouse Clinic]'})))
             ),
             Tr(
               td( {-valign=>"top", align=>"left",   -width=>"20%"}, ""),
               td( {-valign=>"top", align=>"center", -width=>"20%"}, ""),
               td( {-valign=>"top", align=>"right",  -width=>"25%"}, "")
             )
          )
        . hr()
        . h2("Welcome to MausDB")
        . hr();

  if (defined($message)) {
     print p({-class=>"$message_color"}, $message)
           . hr();
  }

  print h2("Please log in")
        . start_form(-action => url())
        . table( {-border => 0, -summary=>"table"},
               Tr(
                 td(center(b("user name"))),
                 td(textfield(-name => "username", -size=>"40"))
               ),
               Tr(
                 td(center(b("password"))),
                 td(password_field(-name=>'password', -value=>'', -size=>"40", -maxlength=>"40", -override=>"1"))
                 )
          )
        . p()
        . submit(-name => "login", -value=>"login")
        . end_form()
        . p("&nbsp;"), p("&nbsp;")
        . hr()
        . small("Page generated on " . localtime() )
        . end_html();

  exit(0);
}
# end of print_login_form()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MAI004 logout():                          logout
sub logout {
   my ($global_var_href) = @_;                                   # get reference to global vars hash
   my $session           = $global_var_href->{'session'};

   # clear login state and delete session
   $session->clear(["_IS_LOGGED_IN"]);
   $session->delete();

   &print_login_form($session, "blue", "You have been successfully logged out from MausDB."
                                       . br()
                                       . "You may log in again if you wish."
                    );
}
# end of logout()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_MAI005 error_message_and_exit():          display an error message and exit
sub error_message_and_exit {
  my ($global_var_href, $message, $error_code, $release_lock) = @_;     # get error message
  my $dbh     = $global_var_href->{'dbh'};                              # DBI database handle
  my $session = $global_var_href->{'session'};                          # session handle
  my $warning = '';
  my $rc      = 'rollback';

  ###############################
  # Release the Semaphore lock
  if (defined($release_lock) && $release_lock eq 'release') {
     $dbh->do("update  mylocks
               set     mylock_value = ?, mylock_session = ?, mylock_user_id = ?, mylock_datetime = ?
               where   mylock_id = 1
              ", undef, "unlocked", $session->id(), -1, get_current_datetime_for_sql()
              );
  }
  ###############################

  &print_header($session);

  print h2({-class=>"red"}, "Error")
        . $warning
        . hr()
        . table({-border=>"0", -class=>"red", -summary=>"table"},
               Tr(
                 th("Error message"),
                 td(qq("$message"))
                 ),
               Tr(
                 th("Error code"),
                 td($error_code)
                 )
          )
        . hr()
        . p({-class=>"red"}, "Please try again or contact the administrators (you will be asked for error code and error message)");

  &print_tail();

  exit;
}
# end of error_message_and_exit()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_MAI006 print_lock_page():                show lock page
sub print_lock_page {
  my ($session) = @_;
  my $session_id = $session->id();
  my $bg_color   = 'white';
  my ($page, $cookie);

  # generate Session cookie from session id
  $cookie = cookie($cookie_name => $session_id);

  print header( -cookie=>$cookie )
        . start_html(-title    => "(MausDB) $mode" . " LOCKED ",
                     -bgcolor  => "$bg_color",
                     -encoding => 'utf-8',
                     -style    => {-src=>$URL_htdoc_basedir . '/css/maus.css'}
          )
        . table( {-border=>"0", -bgcolor=>"$bg_color", -summary=>"table"},
             Tr(
               td( {-valign=>"top", align=>"left",   -width=>"15%"}, a( {-href=>'http://www.helmholtz-muenchen.de'}, img({-src=>$URL_htdoc_basedir . '/images/gsf_logo.gif', -border=>0, -alt=>'[Helmholtz Zentrum Muenchen - Home]'}))),
               td( {-valign=>"top", align=>"center", -width=>"60%"}, h1({-class=>"blue"}, "MausDB $mode")  . span({-class=>"blue"}, "the mouse management system of the German Mouse Clinic")),
               td( {-valign=>"top", align=>"right",  -width=>"25%"}, a( {-href=>'http://www.mouseclinic.de'}, img({-src=>$URL_htdoc_basedir . '/images/GMC_logo.gif', -border=>0, -alt=>'[German Mouse Clinic]'})))
             ),
             Tr(
               td( {-valign=>"top", align=>"left",   -width=>"20%"}, ""),
               td( {-valign=>"top", align=>"center", -width=>"20%"}, ""),
               td( {-valign=>"top", align=>"right",  -width=>"25%"}, "")
             )
          )
        . hr()
        . h2("Welcome to MausDB")
        . hr()
        . h2({-class=>'red'}, "GLOBAL LOCK")
        . p("MausDB is currently locked for all users to enable safe system administration and service.")
        . p("The lock will be removed as soon as possible.")
        . p("In case the lock occured within a multi-step operation (import, weaning, move, ...), just keep on trying to press the browser &lt;Reload&gt; button.")
        . hr()
        . small("Page generated on " . localtime() )
        . end_html();

  exit(0);
}
# end of print_lock_page()
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# SR_MAI008 read_config_file():                 parse the config file and return config hash
# expected format of config file:
# key  = value
# MODE = DEV
# path = /usr/lib/
# ...
sub read_config_file {
  my $config_file = $_[0];                          # get path/name of the config file
  my ($key, $value, $checked_key, $checked_value);
  my %User_Preferences;                             # returned config hash

  # open the config file
  open(CONFIG, "< $config_file");

  # read config file line by line ...
  while (<CONFIG>) {
    chomp;               # remove end of line ('\n')
    s/#.*//;             # remove comment lines
    s/^\s+//;            # remove heading whitespaces
    s/\s+$//;            # remove tailing whitespaces

    next unless length;  # ignore empty lines

    # get key-value pair using split for line: key = value
    ($key, $value) = split(/\s*=\s*/, $_, 2);

    # check key due to perl tainted mode (-T switch)
    if ($key =~ /^([a-zA-Z\/_\-:\.]*)$/) {
       $checked_key = $1;
    }

    # check value due to perl tainted mode (-T switch)
    if ($value =~ /^([a-zA-Z0-9\/_\-:\.]*)$/) {
       $checked_value = $1;
    }

    # add key-value pair to config hash
    $User_Preferences{$checked_key} = $checked_value;
  }

  close(CONFIG);

  return %User_Preferences;
}
# end of read_config_file()
#--------------------------------------------------------------------------------------


#--------------------------------------------------------------------------------------
# SR_MAI007 just_remarks():                    no code, just remarks, comments, documentation, ...
sub just_remarks {
#############################################################################################################################
# REMARKS                                                                                                                   #
#  - comments are made next to the code, where possible                                                                     #
#  - more detailed comments or explanation of concepts can be found at the bottom of this file (search for COMMENTS)        #
#    for example: short introduction to some Perl concepts, modules and so on                                               #
#                                                                                                                           #
# How this script works:                                                                                                    #
# ----------------------                                                                                                    #
#                                                                                                                           #
# 0. before starting, create a new session or resume an existing session (read session id from cookie).                     #
#    check if session is expired or authenticated. Force login accordingly or proceed with script if everything ok          #
#                                                                                                                           #
# 1. the script knows what to do from the parameters it receives via GET (URL) or POST (forms) methods                      #
#    for example: http://darvas.gsf.de/cgi-bin/mausdb.cgi?choice=mouse_details&mouse_id=30000023 means:                     #
#                 deliver details on mouse with id 30000023                                                                 #
#                                                                                                                           #
# 2. for each invocation (call) of the script, the first parameter (choice) that defines the required action                #
#    is read into $choice using the CGI::param() method (whether GET or POST doesn't matter).                               #
#    That happens in the line: "my $choice = lc(param("choice"));"                                                          #
#                                                                                                                           #
# 3. login and logout events are written to log_access in the database ()                                                   #
#                                                                                                                           #
# 4. in the big if(), elsif(), ... decision tree (DISPATCHER), a subroutine is called according to the $choice              #
#                                                                                                                           #
# 5. in this subroutine, the complete HTML code for the <body>...</body> part of the final page is generated                #
#    and returned in the string variable $page                                                                              #
#                                                                                                                           #
# 6. the variable part of the final page is printed to STDOUT (that means to Apache) together with a header and a tail.     #
#    this is equivalent to the delivery of the page to the client browser.                                                  #
#                                                                                                                           #
# 7. after delivery of the page, database connections are closed                                                            #
#                                                                                                                           #
#############################################################################################################################
# for introduction, documentations and remarks please check the bottom of this file                                         #
#############################################################################################################################
# COMMENTS                                                                                                                  #
#############################################################################################################################
#
# CGI module: (see http://search.cpan.org/~lds/CGI.pm-3.10/CGI.pm)
#             a module that facilitates the generation of HTML elements, such as <a href>...</a> constructs, tables and so on
#             widely used in this script are:
#             a({-href=>"$url"}, "linktext")                                    a link
#             start_table({-border=>"1", -summary=>"table"}),                   start a table
#             Tr(                                                               table row
#               td(),td()                                                       table columns
#             )
#             end_table()                                                       end a table
#             start_form(-action=>url()), end_form()                            start and end a form
#             submit(-name=>"", -value=>"")                                     submit button
#             $a = param('mouse_id')                                            read parameter mouse_id into variable
#
# DBI module: (see http://search.cpan.org/~timb/DBI-1.48/DBI.pm)
#             a database interface module
#
#             1. open a database connection and bind to database handle $dbh
#                $dbh = DBI->connect ("DBI:mysql:host=$host_name;database=$db_name", "$user", "$password", {PrintError => 0});
#                $dbh->disconnect()                                                       disconnect from database
#
#             2. doing a query
#                $sth = $dbh->prepare("select * from mice where mouse_id=30000023");
#                $sth->execute();
#                - or -
#                $sth = $dbh->prepare("select * from mice where mouse_id=?");             better when looping
#                foreach $mouse_id {
#                   $sth->execute($mouse_id);
#                }
#                in either case:
#                $result = $sth->fetchall_arrayref({});                                   get a handle on a result array
#                $sth->finish();                                                          finish the current query
#
#                $rows = @{$result};                                                      how many result lines?
#
#                for ($i=0; $i<$rows; $i++) {                                             loop over all results
#                    $row = $result->[$i];                                                fetch current result (similar to a cursor)
#
#                    $maus_line = $row->{'mouse_line'};                                   access a value using the column name
#                }
#
#                much simpler: access columns by order, not by name
#                ($col1, $col2, ...) = $sth->fetchrow_array();
#
#             3. for inserts, updates (non repeated non-SELECT statements)
#                $dbh->do("insert into mice values (1,2)")
#
#             4. transactions
#                $rc = $dbh->begin_work
#                $rc = $dbh->commit;
#                $rc = $dbh->rollback;
#
#             5. error checking
#                my $sth = $dbh->prepare(...) or die "Can't prepare statement: $DBI::errstr";
#                my $rc  = $sth->execute()    or die "Can't execute statement: $DBI::errstr";
#
#                check for problems which may have terminated the fetch early
#                die $sth->errstr if $sth->err;
#
#
#
# CGI::Session module (see http://search.cpan.org/~sherzodr/CGI-Session-3.95/Session.pm)
#
#    # Object initialization:
#    use CGI::Session;
#
#    my $session = new CGI::Session("driver:File", undef, {Directory=>'/tmp'});
#
#    # getting the effective session id:
#    my $CGISESSID = $session->id();
#
#    # storing data in the session
#    $session->param('f_name', 'Sherzod');
#    # or
#    $session->param(-name=>'l_name', -value=>'Ruzmetov');
#
#    # retrieving data
#    my $f_name = $session->param('f_name');
#    # or
#    my $l_name = $session->param(-name=>'l_name');
#
#    # clearing a certain session parameter
#    $session->clear(["_IS_LOGGED_IN"]);
#
#    # expire '_IS_LOGGED_IN' flag after 10 idle minutes:
#    $session->expire(_IS_LOGGED_IN => '+10m')
#
#    # expire the session itself after 1 idle hour
#    $session->expire('+1h');
#
#    # delete the session for good
#    $session->delete();
#
#
#
#############################################################################################################################
# END OF COMMENTS                                                                                                           #
#############################################################################################################################
}
# end of just_remarks()
#--------------------------------------------------------------------------------------
