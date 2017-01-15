use strict;
package Web::Authenticate::Result::Authenticate;
use Mouse;
#ABSTRACT: The result of calling Web::Authenticate::authenticate.

=method success

Returns 1 if the call to login was successful, undef otherwise.

=cut

has success => (
    isa => 'Bool',
    is => 'ro',
    required => 1,
    default => undef,
);

=method user

Returns the user that was logged in.

=cut

has user => (
    does => 'Web::Authenticate::User::Role',
    is => 'ro',
);

=method failed_authenticator

Returns the authenticator that caused the authenticate to fail, if there was one.

=cut

has failed_authenticator => (
    does => 'Web::Authenticate::Authenticator::Role',
    is => 'ro',
);

=method auth_redir

Returns the L<Web::Authenticate::Authenticator::Redirect::Role> object that was used to redirect.

=cut

has auth_redir => (
    does => 'Web::Authenticate::Authenticator::Redirect::Role',
    is => 'ro',
);

# remove undef arguments before constructed
around 'BUILDARGS' => sub {
  my($orig, $self, @params) = @_;
  my $params;

  if(@params == 1 ) {
    ($params) = @params;
  } else {
    $params = { @params };
  }

  for my $key (keys %$params){
    delete $params->{$key} unless defined $params->{$key};
  }

  $self->$orig($params);
};

1;
