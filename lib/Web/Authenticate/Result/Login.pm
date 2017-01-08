use strict;
package Web::Authenticate::Result::Login;
use Mouse;
#ABSTRACT: The result of calling Web::Authenticate::login.

=method success

Returns 1 if the call to login was successful, undef otherwise.

=cut

has success => (
    isa => 'Bool',
    is => 'ro',
    required => 1,
);

=method user

Returns the user that was logged in.

=cut

has user => (
    does => 'Web::Authenticate::User::Role',
    is => 'ro',
);

=method failed_authenticator

Returns the authenticator that caused the login to fail, if there was one.

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
