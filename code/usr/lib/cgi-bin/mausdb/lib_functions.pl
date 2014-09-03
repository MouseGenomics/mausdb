# lib_functions.pl - a MausDB subroutine library file                                                                            #
#                                                                                                                                #
# Subroutines in this file provide some general functions                                                                        #
#                                                                                                                                #
#--------------------------------------------------------------------------------------------------------------------------------#
# SUBROUTINE OVERVIEW                                                                                                            #
#--------------------------------------------------------------------------------------------------------------------------------#
#                                                                                                                                #
# SR_FUN001 is_in_list()                       returns 1 if given element is in given list, else 0                               #
# SR_FUN002 max_of()                           returns higher of two given numbers                                               #
# SR_FUN003 min_of()                           returns lower of two given numbers                                                #
# SR_FUN004 diff_list():                       returns elements of @a that are not in @b for given references to @a and @b       #
# SR_FUN005 unique_list():                     returns a list where doublettes have been removed from the given list             #
# SR_FUN006 isect_list():                      returns elements of @a that also occur in @b for given references to @a and @b    #
# SR_FUN007 in_both_lists():                   returns elements of @a that also occur in @b for given references to @a and @b    #
# SR_FUN008 remove_from_list()                 returns a list: one element purged from given list                                #
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
# SR_FUN001 is_in_list()                       returns 1 if given element is in given list, else 0
sub is_in_list {
  my ($element, $listref) = @_;
  my $list_element;
  my %count;

  foreach $list_element ( @{$listref} ) {
     $count{$list_element}++;
  }

  if ( defined($count{$element}) && $count{$element} > 0 ) { return 1; }
  else                                                     { return 0; }
}
# end of is_in_list ()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_FUN002 max_of()                           returns higher of two given numbers
sub max_of {
  my ($first, $second) = @_;
  my $max = $first;

  if ($first < $second) {
     $max = $second;
  }

  return $max;
}
# end of max_of()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_FUN003 min_of()                           returns lower of two given numbers
sub min_of {
  my ($first, $second) = @_;
  my $min = $first;

  if ($first > $second) {
     $min = $second;
  }

  return $min;
}
# end of min_of()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_FUN004 diff_list():                       returns elements of @a that are not in @b for given references to @a and @b
sub diff_list {
  my ($a_ref, $b_ref) = @_;
  my @diff_list;
  my %seen;
  my $element;

  @seen{@{$b_ref}} = ();

  foreach $element (@{$a_ref}) {
     push(@diff_list, $element) unless exists $seen{$element};
  }

  return \@diff_list;
}
# end of diff_list()
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# SR_FUN005 unique_list():                     returns a list where doublettes have been removed from the given list
sub unique_list{
  my @list = @_;
  my $element;
  my %uniq;

  foreach $element (@list) {
     $uniq{$element}++;
  }

  @list = sort keys %uniq;

  return @list;
}
# unique_list
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# SR_FUN006 isect_list():                     returns elements of @a that also occur in @b for given references to @a and @b
sub isect_list {
  my ($a_ref, $b_ref) = @_;
  my %isect;
  my @isect_list;
  my $element;

  foreach $element (@{$a_ref}, @{$b_ref}) { $isect{$element}++; }

  @isect_list = sort keys %isect;

  return @isect_list;
}
# end of diff_list()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# SR_FUN007 in_both_lists():                   returns elements of @a that also occur in @b for given references to @a and @b
sub in_both_lists {
  my ($a_ref, $b_ref) = @_;
  my %seen;
  my %isect;
  my @isect_list;
  my $element;

  # register every element of @a in a hash
  foreach $element (@{$a_ref}) {
      $seen{$element}++;
  }

  # if element of @b in hash, push it to result list
  foreach $element (@{$b_ref}) {
      if (defined($seen{$element})) {
         $isect{$element}++;
      }
  }

  @isect_list = sort keys %isect;

  return @isect_list;
}
# end of in_both_lists()
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# SR_FUN008 remove_from_list()                  returns a list: one element purged from given list
sub remove_from_list {
  my ($element, $listref) = @_;
  my $list_element;
  my @purged_list;

  foreach $list_element ( @{$listref} ) {
     unless ($list_element eq $element) {
        push(@purged_list, $list_element);
     }
  }

  return @purged_list;
}
# end of is_in_list ()
#-------------------------------------------------------------------------------


# last statement in include files must be a true statement. "1;" is a very simple and very true statement
1;
