use strict;
package Web::Authenticate::Session::Handler;
use Mouse;
use DateTime;
use Session::Token;
use Web::Authenticate::Cookie::Handler;
#ABSTRACT: The default implementation of Web::Authentication::Session::Handler::Role.

=method session_storage_handler

Sets the object that does L<Web::Authenticate::Sesssion::Storage::Handler::Role>. This is required an has no default.

=cut

has session_storage_handler => (
    does => 'Web::Authenticate::Session::Storage::Handler::Role',
    is => 'ro',
    required => 1,
);

=method cookie_handler

Sets the object that does L<Web::Authenticate::Cookie::Handler::Role>. This is required. Default is L<Web::Authenticate::Cookie::Handler>.

=cut

has cookie_handler => (
    does => 'Web::Authenticate::Cookie::Handler::Role',
    is => 'ro',
    required => 1,
    default => sub { Web::Authenticate::Cookie::Handler->new },
);

=method session_expires_in_seconds

Sets the amount of time a session will expire in after last successful page load. Default is 86,400 (one day).

=cut

has session_expires_in_seconds => (
    isa => 'Int',
    is => 'ro',
    required => 1,
    default => 86400,
);

=method session_id_cookie_name

Sets the session_id cookie name. Default is 'session_id'.

=cut

has session_id_cookie_name => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => 'session_id',
);

=method create_session

Creates session for the user and stores the cookie for the session in the user's browser.

=cut

sub create_session {
    my ($self, $user) = @_;

    my $session_id = Session::Token->new(entropy => 256)->get;
    my $session = $self->session_storage_handler->store_session($user, $session_id, $self->_get_expires);

    return unless $session;

    $self->_set_session_cookie($session_id);

    return $session;
}

=method update_expires

Updates the expires time for the logged in user to now + L</session_expires_in_seconds>.

=cut

sub update_expires {
    my ($self) = @_;
    my $session_id = $self->_get_session_id;

    return unless $session_id;

    $self->session_storage_handler->update_expires($session_id, $self->_get_expires);
    $self->_set_session_cookie($session_id);
}

=method invalidate_user_sessions

Deletes all sessions for user.

=cut

sub invalidate_user_sessions {
    my ($self, $user) = @_;
    $self->session_storage_handler->invalidate_user_sessions($user);
}

=method get_session

Returns the session for the logged in user. Returns undef if there is no session.

=cut

sub get_session {
    my ($self) = @_;

    my $session_id = $self->_get_session_id;

    return unless $session_id;

    return $self->session_storage_handler->load_session($session_id);
}

sub _get_session_id {
    my ($self) = @_;
    return $self->cookie_handler->get_cookie($self->session_id_cookie_name);
}

sub _get_expires {
    my ($self) = @_;
    return DateTime->now->add(seconds => $self->session_expires_in_seconds)->epoch;
}

sub _set_session_cookie {
    my ($self, $session_id) = @_;
    $self->cookie_handler->set_cookie($self->session_id_cookie_name, $session_id, $self->session_expires_in_seconds);
}

1;
