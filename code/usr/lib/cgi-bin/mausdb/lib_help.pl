# lib_help.pl - a MausDB subroutine library file                                                                                 #
#                                                                                                                                #
# Subroutines in this file provide help functions                                                                                #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_HEL001 function help()                               returns a help page on earmarking                                      #
# SR_HLP002 function earmarking_help()                    returns a help page on earmarking                                      #
# SR_HLP003 function version_history()                    returns a page on version_history                                      #
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


#-------------------------------------------------------------------------------
# SR_HLP001 help_overview help()                          help start page
sub help_overview {                                       my $sr_name = 'SR_HLP001';
  my ($global_var_href) = @_;                  # get reference to global vars hash
  my $url               = url();
  my $help_item         = param('help_item');
  my ($page);

  if (defined(param('help_item')) && param('help_item') ne '') {
     if    ($help_item eq 'earmarking_help') { $page = earmarking_help($global_var_href); }
     elsif ($help_item eq 'version_history') { $page = version_history($global_var_href); }
     else                                    { $page = help_overview($global_var_href);   }
  }

  else {
    $page .= h2("Help")
             . hr()
             . h3("About MausDB")

             . p("MausDB, version 1.5, Copyright (C) 2008 Helmholtz Zentrum M&uuml;nchen, German Research Center for Environmental Health (GmbH)"
                 . br()
                 . "MausDB comes with ABSOLUTELY NO WARRANTY; This is free software, and you are welcome to redistribute it under certain conditions. For details, see: "
                 . a({-href=>"http://www.gnu.org/licenses/gpl.html", -target=>"_WINVIEW", -title=>"a new window opens"}, "GNU General Public License")
               );
  }

  return $page;
}
# end of help_overview()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# SR_HLP002 function earmarking_help()                    returns a help page on earmarking
sub earmarking_help {                                     my $sr_name = 'SR_HLP002';
  my ($global_var_href) = @_;                  # get reference to global vars hash
  my $url               = url();
  my ($page);

  $page .= h2("Help - Earmarking")
           . hr()
           . h3("Earmarking")
           . p(img({-src=>$global_var_href->{'URL_htdoc_basedir'} . '/images/earmarking.jpg', -border=>0, -alt=>'[earmarking scheme]'}))
           . p("Drawn by William Ober (2001)"
               . br()
               . br()
               . "From page 86, Figure 31 in Manipulating the Mouse Embryo, A Laboratory Manual, 1986,
                  Cold Spring Harbor Laboratory, Cold Spring Harbor, NY."
             );

  return $page;
}
# end of earmarking_help()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# SR_HLP003 function version_history()                    returns a page on version_history
sub version_history {                                     my $sr_name = 'SR_HLP003';
  my ($global_var_href) = @_;                  # get reference to global vars hash
  my $url               = url();
  my ($page);

  $page .= h2("Help - version history")
           . hr()
           . h3("v1.0");

  return $page;
}
# end of version_history()
#-------------------------------------------------------------------------------


# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;