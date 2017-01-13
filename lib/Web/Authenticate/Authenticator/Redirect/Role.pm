use strict;
package Web::Authenticate::Authenticator::Redirect::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::Authenticator::Redirect object should contain.

=method authenticator

Returns the L<Web::Authenticate::Authenticator::Role> associated with this L<Web::Authenticate::Authenticator::Redirect::Role>.

    my $authenticator = $auth_redirect->authenticator;

=cut

requires 'authenticator';

=method url

Returns the url to redirect to if L</authenticator> returns true.

=cut

requires 'url';

1;
