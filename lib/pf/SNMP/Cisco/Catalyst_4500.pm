package pf::SNMP::Cisco::Catalyst_4500;

=head1 NAME

pf::SNMP::Cisco::Catalyst_4500 - Object oriented module to access and configure Cisco Catalyst 4500 switches

=head1 STATUS

This module is currently only a placeholder, see pf::SNMP::Cisco::Catalyst_2960.

We do not know the minimum required firmware version.

=head1 CONFIGURATION AND ENVIRONMENT

F<conf/switches.conf>

=cut

use strict;
use warnings;
use diagnostics;
use Log::Log4perl;
use Net::SNMP;
use Try::Tiny;

use pf::accounting qw(node_accounting_current_sessionid);
use pf::config;
use pf::node qw(node_attributes);
use pf::util::radius qw(perform_coa perform_disconnect);

use base ('pf::SNMP::Cisco::Catalyst_2960');

sub description { 'Cisco Catalyst 4500 Series' }

=head2 getIfIndexByNasPortId

Fetch the ifindex on the switch by NAS-Port-Id radius attribute

=cut


sub getIfIndexByNasPortId {
    my ($this, $ifDesc_param) = @_;

    if ( !$this->connectRead() ) {
        return 0;
    }

    my $OID_ifDesc = '1.3.6.1.2.1.2.2.1.2';
    my $ifDescHashRef;
    my $result = $this->{_sessionRead}->get_table( -baseoid => $OID_ifDesc );
    foreach my $key ( keys %{$result} ) {
        my $ifDesc = $result->{$key};
        if ( $ifDesc =~ /$ifDesc_param$/i ) {
            $key =~ /^$OID_ifDesc\.(\d+)$/;
            return $1;
        }
    }
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2013 Inverse inc.

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

