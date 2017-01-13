use strict;
package Web::Authenticate::Session::Handler::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::Session::Handler object should contain.

=method create_session

Creates a session for user. Returns an object that does L<Web::Authenticate::Session::Role>.

    my $session = $session_handler->create_session($user);

=cut

requires 'create_session';

=method delete_session

Deletes the current session.

    $session_handler->delete_session;

=cut

requires 'delete_session';

=method update_expires

Updates the expires time for session. Returns an object that does L<Web::Authenticate::Session::Role>.

    my $updated_session = $session_handler->update_expires($session);

=cut

requires 'update_expires';

=method invalidate_current_session

Invalidates the current session if the user has one.

    $session_handler->invalidate_current_session;

=cut

requires 'invalidate_current_session';

=method invalidate_user_sessions

Invalidates all sessions for a user.

    $session_handler->invalidate_user_sessions($user);

=cut

requires 'invalidate_user_sessions';

=method get_session

Returns the session for the current user. Returns undef if there is no session.

    my $session = $session_handler->get_session;

=cut

requires 'get_session';

1;
