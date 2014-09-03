package DB_connect;

#######################################################################################
# DB_connect provides a single subroutine: connect() that tries to establish a DBI    #
# database connection using the connection parameters given below.                    #
#                                                                                     #
# connect() returns a DBI database handle in case of success                          #
#           or generates an error page in case it could not connect to the database   #
#                                                                                     #
# Holger Maier, March 2010                                                            #
#######################################################################################

# use standard and CPAN modules
use strict;                   # force strict variable declarations
use DBI;                      # CPAN database abstraction module
use CGI qw(:standard);        # CPAN CGI/HTML module

#######################################################################################
# connect(): try to connect to database server and return database handle             #
# this subroutine is just a wrapper around DBI->connect() that adds error handling    #
# by displaying an error page in case database connect fails for whatever reason      #
#######################################################################################
sub connect{
  # DATABASE CONNECTION PARAMETERS [@ localhost = (database runs on same machine as webserver) ]
  my $host_name   = "localhost";
  my $db_name     = "mausdb";
  my $username    = "<username>";                # insert mysql username (for MausDB program to access database)
  my $password    = "<password>";                # insert mysql password (for MausDB program to access database)

  # MACHINE SPECIFIC SETTINGS
  my $style_sheet = "http://yourserver.yourdomain/mausdb/css/maus.css";  # path to CSS style sheet
  my $image_dir   = "http://yourserver.yourdomain/mausdb/images/";       # path to images

  # OTHER VARIABLES
  my $dbh;                                                       # database handle (this is the return object)
  my $time = localtime();                                        # get current time
  my $url  = CGI::url();                                         # get URL from calling script (to generate a "home" button on the error page)
  my $dsn  = "DBI:mysql:host=$host_name;database=$db_name";      # database connection string. Second parameter defines the DBMS: "mysql", "Pg", ...

  # ALL DEFINED ...

  # ... now try to connect to the database
  $dbh = DBI->connect($dsn, $username, $password, {PrintError => 0});

  # if above connect() fails -> display error message page and stop
  if (DBI->err()) {
     print   CGI::header()
           . CGI::start_html(-title=>"(MausDB) DEMO",
                             -style=>{-src=>"$style_sheet"},
                            )
           . CGI::table( {-border=>"0"},
                         CGI::Tr(
                                CGI::td( {-valign=>"top", align=>"left",   -width=>"15%"},
                                         CGI::a( {-href=>'http://www.helmholtz-muenchen.de'},
                                                 CGI::img({-src=>$image_dir . 'gsf_logo.gif', -border=>0, -alt=>'[HMGU-Home]'})
                                               )
                                       ),
                                CGI::td( {-valign=>"top", align=>"center", -width=>"60%"},
                                         CGI::h1( {-class=>"blue"}, "MausDB DEMO") 
                                         . span({-class=>"blue"}, "the mouse management system of the German Mouse Clinic")
                                       ),
                                CGI::td( {-valign=>"top", align=>"right",  -width=>"25%"}, 
                                         CGI::a( {-href=>'http://www.helmholtz-muenchen.de/ieg/gmc/index.html'}, 
                                                 CGI::img({-src=>$image_dir . 'GMC_logo.gif', -border=>0, -alt=>'[German Mouse Clinic]'})
                                               )
                                       )
                         ),
                         CGI::Tr(
                                CGI::td( {-valign=>"top", align=>"left",   -width=>"20%"}, CGI::a({-href=>"$url"}, "Home")),
                                CGI::td( {-valign=>"top", align=>"center", -width=>"20%"}, ""),
                                CGI::td( {-valign=>"top", align=>"right",  -width=>"25%"}, "")
                         ),
             )
           . CGI::hr()

           . CGI::h2({-class=>'red'}, "Error")
           . CGI::p({-class=>'red'},  "Could not connect to the database.")
           . CGI::p({-class=>'red'},  "Please contact an administrator or try again in a while.")

           . CGI::hr()

           . CGI::small("Page generated on $time")

           . CGI::end_html();

     exit(0);
  }

  # else return db handler and continue
  # (that's what we are really interested in)
  else {
     return ($dbh, $host_name, $db_name);
  }
}
# connect()
#######################################################################################

# last statement in package file must be a true statement. "1;" is a very simple and very true statement
1;



