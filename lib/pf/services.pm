package pf::services;

=head1 NAME

pf::services - module to manage the PacketFence services and daemons.

=head1 DESCRIPTION

pf::services contains the functions necessary to control the different
PacketFence services and daemons. It also contains the functions used
to generate or validate some configuration files.

=head1 CONFIGURATION AND ENVIRONMENT

Read the following configuration files: F<dhcpd_vlan.conf>,
F<networks.conf>, F<violations.conf> and F<switches.conf>.

Generate the following configuration files: F<dhcpd.conf>, F<named.conf>,
F<snort.conf>, F<httpd.conf>, F<snmptrapd.conf>.

=cut

use strict;
use warnings;

use pf::config;
use pf::services::manager::memcached;
use pf::services::manager::httpd_admin;
use pf::services::manager::httpd_webservices;
use pf::services::manager::httpd_portal;
use pf::services::manager::httpd_proxy;
use pf::services::manager::pfdns;
use pf::services::manager::dhcpd;
use pf::services::manager::pfdetect;
use pf::services::manager::snort;
use pf::services::manager::suricata;
use pf::services::manager::radiusd;
use pf::services::manager::snmptrapd;
use pf::services::manager::pfsetvlan;
use pf::services::manager::pfdhcplistener;
use pf::services::manager::pfmon;
use Module::Loaded qw(is_loaded);

our @APACHE_SERVICES = (
    'httpd.admin', 'httpd.webservices', 'httpd.portal', 'httpd.proxy'
);

our @ALL_SERVICES = (
    'memcached', @APACHE_SERVICES, 'pfdns', 'dhcpd', 'pfdetect', 'snort', 'suricata', 'radiusd',
    'snmptrapd', 'pfsetvlan', 'pfdhcplistener', 'pfmon'
);

our %ALLOWED_ACTIONS = (
    stop    => undef,
    start   => undef,
    watch   => undef,
    status  => undef,
    restart => undef,
);

=head1 SUBROUTINES

=head2 service_ctl

=cut

sub service_ctl {
    my ($service, $action, $quick) = @_;
    if(exists $ALLOWED_ACTIONS{$action}) {
        my $sm = get_service_manager($service);
        if(defined $sm && ($action ne 'start' || $sm->isManaged )) {
            return $sm->$action($quick);
        }
    }
    return 0;
}

=head2 get_service_manager

Get service manager my service name

=cut

sub get_service_manager {
    my ($service) = @_;
    my $sm;
    my $module = _make_service_manager_module_name($service);
    if(is_loaded($module)) {
        $sm = $module->new;
    }
    return $sm;
}

=head2 read_violations_conf

reload the violation config

=cut

sub read_violations_conf {
    require pf::violation_config;
    pf::violation_config::readViolationConfigFile();
    return 1;
}

=head2 _make_service_manager_module_name

make the service manager module name

=cut

sub _make_service_manager_module_name {
    my ($service) = @_;
    my $module = "pf::services::manager::${service}";
    $module =~ /^(.*)$/;
    $module = $1;
    $module =~ s/\./_/;
    return $module;
}

=head2 service_list

Return the list of services that are allowed to be managed

=cut

sub service_list {
    return grep {
        my $module = _make_service_manager_module_name($_);
        is_loaded($module) && $module->new->isManaged
    } @_;
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

Minor parts of this file may have been contributed. See CREDITS.

=head1 COPYRIGHT

Copyright (C) 2005-2013 Inverse inc.

Copyright (C) 2005 Kevin Amorin

Copyright (C) 2005 David LaPorte

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
