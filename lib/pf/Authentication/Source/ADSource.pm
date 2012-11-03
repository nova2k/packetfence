=item

=cut
package pf::Authentication::Source::ADSource;
use pf::Authentication::Source;
use pf::Authentication::Source::LDAPSource;
use Moose;

extends 'pf::Authentication::Source::LDAPSource';

sub available_attributes {
  my $self = shift;
  my $super_attributes = $self->SUPER::available_attributes;
  my $ad_attributes = ["sAMAccountName", "sAMAccountType", "userAccountControl"];
  
  return [@$super_attributes, @$ad_attributes];
}

=back

=head1 COPYRIGHT

Copyright (C) 2012 Inverse inc.

=head1 LICENSE 

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start: