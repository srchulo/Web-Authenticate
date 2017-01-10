use strict;
package Web::Authenticate::IpAddressProvider::EnvIpAddressProvider;
use Mouse;
#ABSTRACT: Implementation of Web::Authentication::UserAgentProvider::Role that users environment variables.

with 'Web::Authenticate::IpAddressProvider::Role';

=method get_ip_address

Returns the user's ip address first using $ENV{HTTP_X_FORWARDED_FOR} if present, then $ENV{REMOTE_ADDR}.

=cut

sub get_ip_address { $ENV{HTTP_X_FORWARDED_FOR} ? $ENV{HTTP_X_FORWARDED_FOR} : $ENV{REMOTE_ADDR} }

1;
