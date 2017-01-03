use strict;
package Web::Authenticate::User;
use Mouse;
#ABSTRACT: The default implementation of Web::Authentication::User::Role.

with 'Web::Authenticate::User::Role';

=method id

Returns the user's id. Read only.

=cut

has id => (
    isa => 'Int',
    is => 'ro',
    required => 1,
);

1;
