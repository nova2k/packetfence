package pfappserver::Controller::Configuration::AdminRoles;

=head1 NAME

pfappserver::Controller::Configuration::AdminRoles - Catalyst Controller

=head1 DESCRIPTION

Controller for admin roles management.

=cut

use HTTP::Status qw(:constants is_error is_success);
use Moose;  # automatically turns on strict and warnings
use namespace::autoclean;

use pfappserver::Form::Config::Switch;
use pf::config::cached;

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud::Config';
    with 'pfappserver::Base::Controller::Crud::Config::Clone';
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object action from pfappserver::Base::Controller::Crud
        object => { Chained => '/', PathPart => 'configuration/adminroles', CaptureArgs => 1 },
        # Configure access rights
        view   => { AdminRole => 'ADMIN_ROLES_READ' },
        list   => { AdminRole => 'ADMIN_ROLES_READ' },
        create => { AdminRole => 'ADMIN_ROLES_CREATE' },
        clone  => { AdminRole => 'ADMIN_ROLES_CREATE' },
        update => { AdminRole => 'ADMIN_ROLES_UPDATE' },
        remove => { AdminRole => 'ADMIN_ROLES_DELETE' },
    },
    action_args => {
        # Setting the global model and form for all actions
        '*' => { model => "Config::AdminRoles", form => "Config::AdminRoles" },
    },
);

=head1 METHODS

=head2 after create/clone

Show the 'view' template when creating or cloning an admin role.

=cut

after [qw(create clone)] => sub {
    my ($self, $c) = @_;
    if (!(is_success($c->response->status) && $c->request->method eq 'POST')) {
        $c->stash->{template} = 'configuration/adminroles/view.tt';
    }
};

=head2 after create/clone/update

List admin roles after creating or updating a role.

=cut

after [qw(create clone update)] => sub {
    my ($self, $c) = @_;
    if (is_success($c->response->status) && $c->request->method eq 'POST') {
        $c->stash->{current_view} = 'HTML';
        $c->stash->{template} = 'configuration/adminroles/list.tt';
        $c->forward('list');
    }
};

=head2 after view

Set the action URL to either "create" or "update".

=cut

after view => sub {
    my ($self, $c) = @_;
    if (!$c->stash->{action_uri}) {
        my $id = $c->stash->{id};
        if ($id) {
            $c->stash->{action_uri} = $c->uri_for($self->action_for('update'), [$c->stash->{id}]);
        } else {
            $c->stash->{action_uri} = $c->uri_for($self->action_for('create'));
        }
    }
};

=head2 after _setup_object

Sort the actions of the admin role.

This subroutine is defined in pfappserver::Base::Controller::Crud.

=cut

after _setup_object => sub {
    my ($self, $c) = @_;

    # Sort actions
    if (is_success($c->response->status)) {
        my @actions = sort @{$c->stash->{'item'}->{'actions'}};
        $c->stash->{'item'}->{'actions'} = \@actions;
    }
};

=head2 index

Usage: /configuration/adminroles/

=cut

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    $c->forward('list');
}

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

__PACKAGE__->meta->make_immutable;

1;
