package pf::web::custom;

=head1 NAME

pf::web::custom - custom code to override pf::web's behavior

=cut

=head1 DESCRIPTION

pf::web::custom allows you to redefine subs in pf::web. 
It will never be overwritten when upgrading PacketFence.

=cut

use strict;
use warnings;
use Date::Parse;
use File::Basename;
use POSIX;
use JSON;
use Template;
use Locale::gettext;
use Log::Log4perl;
use Readonly;

use pf::config;
use pf::util;
use pf::iplog qw(ip2mac);
use pf::node qw(node_attributes node_view node_modify);
use pf::useragent;
use pf::web;

=head1 WARNING

What we are doing here is a little bit tricky: We are redefining subs in pf::web. 

To do so, we are messing with typeglobs installing anonymous subs in the pf::web namespace
replacing earlier implementations.

=cut
{
no warnings 'redefine';
package pf::web;

# sample constant
#Readonly::Scalar our $GUEST_SESSION_DURATION => 60 * 60 * 24 * 7; # read 7 days

=head1 SUBROUTINES

=over

=item categorization sample

WARNING: The technique described below is for demonstration purposes only. 
Node categorization is better performed by the authentication modules under 
conf/authentication now. See L<pf::web::auth> for more information.

Here if a particular session variable was set, we categorize the node as a guest
and we set it's expiration to now + $GUEST_SESSION_DURATION. 
Then the normal registration code is called.

To set the particular session variable use the following:
 $session->param("usercategory", "guest");

=cut
#*pf::web::web_node_register = sub {
#    my ( $portalSession, $pid, %info ) = @_;
#    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
#
#    # First blast of portalSession object consumption
#    my $cgi = $portalSession->getCgi();
#    my $session = $portalSession->getSession();
#    my $mac = $portalSession->getClientMac();
#
#    if ( is_max_reg_nodes_reached($mac, $pid, $info{'category'}) ) {
#        pf::web::generate_error_page(
#            $portalSession, 
#            i18n("You have reached the maximum number of devices you are able to register with this username.")
#        );  
#        exit(0);
#    }  
#
#    if ($session->param('usercategory') eq 'guest') {
#        $logger->info("registering a guest with mac: $mac");
#        $info{'unregdate'} = POSIX::strftime("%Y-%m-%d 00:00:01", localtime(time + $GUEST_SESSION_DURATION)); 
#        $info{'category'} = "guest";
#    }
#
#    # we are good, push the registration
#    return _sanitize_and_register($session, $mac, $pid, %info);
#};


=item inject variables for templates

Here's an example to make variables accessible to the templates globally.

Also remember that you can always use the $portalSession->stash to add
variables from every location in the code (CGI's, pf::web, etc.). It's
probably the best approach if what you want to inject depend on some state
or user input.

=cut
#*pf::web::stash_template_vars = sub {
#    my ($portalSession, $template) = @_;
#    return { 'helpdesk_phone' => '514-555-1337' };
#};


# If you want to redefine pf::web::guest methods, remember to place yourself in that package with:
#package pf::web::guest;
# and also to redefine in pf::web::guest::... not pf::web::...

# end of no warnings 'redefine' block

=item redefine generate_login_page

Use to bypass authentication (like direct provisioning)
 
=cut
sub generate_login_page {
    my ( $portalSession, $err ) = @_;

    my $nodeattributes = node_attributes($portalSession->getClientMac);
    if (pf::web::supports_windowsconfig_provisioning($portalSession)) {
        my $cgi = $portalSession->getCgi();
        $cgi->param("do_not_deauth", $TRUE);
        $nodeattributes->{'status'} = 'reg';
        pf::web::util::set_memcached($portalSession->getClientMac(), $nodeattributes, undef, pf::web::util::get_memcached_conf());
    }

    pf::web::end_portal_session($portalSession);
}
}

=back

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
