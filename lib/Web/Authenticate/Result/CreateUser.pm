use strict;
package Web::Authenticate::Result::CreateUser;
use Mouse;
#ABSTRACT: The result of calling Web::Authenticate::create_user.

=method success

Returns 1 if the call to L<Web::Authenticate/create_user> was successful, undef otherwise.

=cut

has success => (
    isa => 'Bool',
    is => 'ro',
    required => 1,
);

=method user

Returns the user that was created.

=cut

has user => (
    does => 'Web::Authenticate::User::Role',
    is => 'ro',
);

=method failed_username_verifiers

Returns the username verifiers that failed if there were any. Default is an empty arrayref.

=cut

has failed_username_verifiers => (
    isa => 'ArrayRef',
    is => 'ro',
    default => sub { [] },
);

=method failed_password_verifiers

Returns the password verifiers that failed if there were any. Default is an empty arrayref.

=cut

has failed_password_verifiers => (
    isa => 'ArrayRef',
    is => 'ro',
    default => sub { [] },
);

1;
