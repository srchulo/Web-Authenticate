use strict;
package Web::Authenticate::Authenticator::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::Authenticator object should contain.

=method authenticate

Authenticates a user based on some criteria. Returns true (1) or false (undef).

    my $authenticated = $authenticator->authenticate($user);

=cut

requires 'authenticate';

1;
