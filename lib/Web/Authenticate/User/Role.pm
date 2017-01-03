use strict;
package Web::Authenticate::User::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::User object should contain.

=method id

All L</Web::Authenticate::User> objects should be able to return the user's id.

=cut

requires 'id';

1;
