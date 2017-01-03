use strict;
package Web::Authenticate::Storage::Handler::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::Storage::Handler object should contain.

=method load_user

Accepts the parameters passed to L<Web::Authenticate/"login"> and validates the login and returns the user matching the passed data. 
Returns a L<Web::Authenticate::User> upon success, undef otherwise.

=cut

requires 'load_user';

=method store_user

Accepts the parameters passed to L<Web::Authenticate/"login"> and creates a user with those credentials.
Returns a L<Web::Authenticate::User> upon success, undef otherwise.

=cut

requires 'store_user';

1;
