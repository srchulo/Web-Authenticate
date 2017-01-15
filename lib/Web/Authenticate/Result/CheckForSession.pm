use strict;
package Web::Authenticate::Result::CheckForSession;
use Mouse;
#ABSTRACT: The result of calling Web::Authenticate::check_for_session.

=method success

Returns 1 if the call to L<Web::Authenticate/check_for_session> was successful in finding a valid session, undef otherwise.

=cut

has success => (
    isa => 'Bool',
    is => 'ro',
    required => 1,
    default => undef,
);

=method user

Returns the user that has a valid session.

=cut

has user => (
    does => 'Web::Authenticate::User::Role',
    is => 'ro',
);

=method auth_redir

Returns the L<Web::Authenticate::Authenticator::Redirect::Role> object that check_for_session used to redirect.

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
