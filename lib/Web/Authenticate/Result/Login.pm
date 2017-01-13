use strict;
package Web::Authenticate::Result::Login;
use Mouse;
#ABSTRACT: The result of calling Web::Authenticate::login.

=method success

Returns 1 if the call to L<Web::Authenticate/login> was successful, undef otherwise.

=cut

has success => (
    isa => 'Bool',
    is => 'ro',
    required => 1,
);

=method invalid_username_or_password

Returns 1 if the username and/or password were invalid. Undef otherwise. This is the same as checking if
L</user> is undef.

=cut

has invalid_username_or_password => (
    isa => 'Bool',
    is => 'ro',
    lazy => 1,
    default => sub { not shift->user },
);

=method user

Returns the user that was logged in. Checking if this is undef is the same as calling L</invalid_username_or_password>.

=cut

has user => (
    does => 'Web::Authenticate::User::Role',
    is => 'ro',
);

=method failed_authenticator

Returns the authenticator that caused the L<Web::Authenticate/login> to fail, if there was one.

=cut

has failed_authenticator => (
    does => 'Web::Authenticate::Authenticator::Role',
    is => 'ro',
);

=method auth_redir

Returns the L<Web::Authenticate::Authenticator::Redirect::Role> object that login used to redirect.

=cut

has auth_redir => (
    does => 'Web::Authenticate::Authenticator::Redirect::Role',
    is => 'ro',
);

1;
