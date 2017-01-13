use strict;
package Web::Authenticate::Authenticator::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::Authenticator object should contain.

=method authenticate

Authenticates a user based on some criteria. Returns true (1) or false (undef).

    my $authenticated = $authenticator->authenticate($user);

=cut

requires 'authenticate';

=method name

Returns the name of this authenticator.

=cut

requires 'name';

=method error_msg

Returns the error message if this authenticator fails.

=cut

requires 'error_msg';



1;
