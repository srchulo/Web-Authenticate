use strict;
package Web::Authenticate::IpAddressProvider::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::IpAddressProvider object should contain.

=method get_ip_address

Returns the ip address for the user.

=cut

requires 'get_ip_address';

1;
