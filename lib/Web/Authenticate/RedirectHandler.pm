use strict;
package Web::Authenticate::RedirectHandler;
use Mouse;
use Carp;
#ABSTRACT: The default implementation of Web::Authentication::RedirectHandler::Role.

with 'Web::Authenticate::RedirectHandler::Role';

=method exit_on_redirect

If set to true (1), then when a user is redirected in methods such as L</login> or L</authenticate>, exit will be called instead of returning.
Default is false.

=cut

has exit_on_redirect => (
    isa => 'Bool',
    is => 'ro',
    required => 1,
    default => undef,
);

=method redirect

Redirects to url.

=cut

sub redirect {
    my ($self, $url) = @_;
    croak "must provide url" unless $url;

    print "Location: $url\n\n";
    exit if $self->exit_on_redirect;
}

1;
