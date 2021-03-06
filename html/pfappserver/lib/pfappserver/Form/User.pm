package pfappserver::Form::User;

=head1 NAME

pfappserver::Form::User - Web form for a user

=head1 DESCRIPTION

Form definition to update a user.

=cut

use pf::config;
use pf::util qw(get_abbr_time);
use HTTP::Status qw(:constants is_success);
use HTML::FormHandler::Moose;

extends 'pfappserver::Base::Form::Authentication::Action';

has '+source_type' => ( default => 'SQL' );

=head1 FIELDS

=head2 pid

=cut

has_field 'pid' =>
  (
   type => 'Uneditable',
   label => 'Username',
  );

=head2 firstname

=cut

has_field 'firstname' =>
  (
   type => 'Text',
   label => 'Firstname',
  );

=head2 lastname

=cut

has_field 'lastname' =>
  (
   type => 'Text',
   label => 'Lastname',
  );

=head2 company

=cut

has_field 'company' =>
  (
   type => 'Text',
   label => 'Company',
  );

=head2 email

=cut

has_field 'email' =>
  (
   type => 'Email',
   label => 'Email',
   required => 1,
  );

=head2 telephone

=cut

has_field 'telephone' =>
  (
   type => 'Text',
   label => 'Telephone',
  );

=head2 sponsor

=cut

has_field 'sponsor' =>
  (
   type => 'Text',
   label => 'Sponsor',
  );

=head2 address

=cut

has_field 'address' =>
  (
   type => 'TextArea',
   label => 'Address',
  );

=head2 notes

=cut

has_field 'notes' =>
  (
   type => 'TextArea',
   label => 'Notes',
  );

=head2 valid_from

=cut

has_field 'valid_from' =>
  (
   type => 'DatePicker',
   messages => { required => 'Please specify the start date of the registration window.' },
  );

=head2 expiration

=cut

has_field 'expiration' =>
  (
   type => 'DatePicker',
   messages => { required => 'Please specify the end date of the registration window.' },
  );

=head2 Blocks

=over

=item user block

  The user block contains the static fields of user

=cut

has_block 'user' =>
  (
   render_list => [qw(pid firstname lastname company telephone email sponsor address notes)],
  );

=item templates block

 The templates block contains the dynamic fields of the rule definition.

 The following fields depend on the selected condition attribute :
  - the condition operators select fields
  - the condition value fields
 The following fields depend on the selected action type :
  - the action value fields

=cut

has_block 'templates' =>
  (
   tag => 'div',
   render_list => [
                   map( { "${_}_action" } @Actions::ACTIONS), # the field are defined in the super class
                  ],
   attr => { id => 'templates' },
   class => [ 'hidden' ],
  );

=back

=head1 METHODS

=head2 update_fields

When editing a local/SQL user, set as required the arrival date.

=cut

sub update_fields {
    my $self = shift;

    if ($self->{init_object} && $self->{init_object}->{password}) {
        $self->field('valid_from')->required(1);
        $self->field('expiration')->required(1);
    }

    # Call the theme implementation of the method
    $self->SUPER::update_fields();
}

=head2 options_access_level

Populate the select field for the 'access level' template action.

=cut

sub options_access_level {
    my $self = shift;

    return
      (
       {
        label => $self->_localize('None'),
        value => $WEB_ADMIN_NONE,
       },
       {
        label => $self->_localize('All'),
        value => $WEB_ADMIN_ALL,
       },
      );
}

=head2 options_roles

Populate the select field for the roles template action.

=cut

sub options_roles {
    my $self = shift;

    my @roles;

    # Build a list of existing roles
    my ($status, $result) = $self->form->ctx->model('Roles')->list();
    if (is_success($status)) {
        @roles = map { $_->{name} => $_->{name} } @$result;
    }

    return @roles;
}

=head2 options_durations

Populate the access duration select field with the available values defined
in the pf.conf configuration file.

=cut

sub options_durations {
    my $self = shift;

    my $durations = pf::web::util::get_translated_time_hash(
        [ split (/\s*,\s*/, $Config{'guests_admin_registration'}{'access_duration_choices'}) ],
        $self->form->ctx->languages()->[0]
    );
    my @options = map { get_abbr_time($_) => $durations->{$_} } sort { $a <=> $b } keys %$durations;

    return \@options;
}

=head1 COPYRIGHT

Copyright (C) 2012-2013 Inverse inc.

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
