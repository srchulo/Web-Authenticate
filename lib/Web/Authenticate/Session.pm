use strict;
package Web::Authenticate::Session;
use Mouse;
use Session::Token;
#ABSTRACT: The default implementation of Web::Authenticate::Session::Role.

=method id

Returns the session id.

=cut

has id => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

=method expires

Returns the expiration time of this session.

=cut

has expires => (
    is => 'ro',
    required => 1,
);

=method user

Returns the user for this session

=cut

has user => (
    does => 'Web::Authenticate::User::Role',
    is => 'ro',
    required => 1,
);

# here so that above methods exist
with 'Web::Authenticate::Session::Role';

=method row

Has the user row as a hashref with columns as keys.

=cut

has row => (
    isa => 'HashRef',
    is => 'ro',
    required => 1,
);

1;
