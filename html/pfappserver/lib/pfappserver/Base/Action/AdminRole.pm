package pfappserver::Base::Action::AdminRole;

=head1 NAME

/usr/local/pf/html/pfappserver/lib/pfappserver/Base/Action add documentation

=head1 DESCRIPTION

AdminRole

=cut

use strict;
use warnings;
use HTTP::Status qw(:constants);
use Moose::Role;
use namespace::autoclean;

use pf::admin_roles;

=head1 METHODS

=head2 before execute

Verify that the user has the rights to execute the controller's action.

=cut

before execute => sub {
    my ( $self, $controller, $c, %args ) = @_;

    my $action = $self->attributes->{AdminRole}[0];
    my $roles = [];
    $roles = [$c->user->roles] if $c->user_exists;

    unless(admin_can($roles, $action)) {
        if($c->user_exists) {
            $c->log->debug(sprintf('Access to action %s was refused to user %s with admin roles %s',
                                   $action, $c->user->id, join(',', @$roles)));
        }
        $c->response->status(HTTP_UNAUTHORIZED);
        $c->stash->{status_msg} = "You don't have the rights to perform this action.";
        $c->stash->{current_view} = 'JSON';
        $c->detach();
    }
};


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

