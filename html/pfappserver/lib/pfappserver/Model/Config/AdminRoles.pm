package pfappserver::Model::Config::AdminRoles;

=head1 NAME

pfappserver::Model::Config::AdminRoles add documentation

=cut

=head1 DESCRIPTION

pfappserver::Model::Config::AdminRoles

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;
use namespace::autoclean;
use pf::ConfigStore::AdminRoles;

extends 'pfappserver::Base::Model::Config';


sub _buildConfigStore { pf::ConfigStore::AdminRoles->new }

__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT

Copyright (C) 2013 Inverse inc.

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

