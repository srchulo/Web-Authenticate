use strict;
package Web::Authenticate::User;
use Mouse;
#ABSTRACT: The default implementation of Web::Authentication::User::Role.

=method id

Returns the user's id. Read only.

=cut

has id => (
    isa => 'Int',
    is => 'ro',
    required => 1,
);

# here so that 'id' sub exists
with 'Web::Authenticate::User::Role';

=method row

Has the user row as a hashref with columns as keys.

=cut

has row => (
    isa => 'HashRef',
    is => 'ro',
    required => 1,
);

1;
