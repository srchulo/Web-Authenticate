use strict;
package Web::Authenticate::Session::Storage::Handler::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::Session::Storage::Handler object should contain.

=method create_session

Creates a session for user in storage. Returns a L<Web::Authenticate::Session::Role> upon success, undef
upon failure.

    my $session = $session_storage_handler->create_session($user, $session_id, $expires);

=cut

requires 'store_session';

=method get_session

Gets the session with the session id $session_id, as long as it has not expired.

    my $session = $session_storage_handler->get_session($session_id);

=cut

requires 'load_session';

=method update_expires

Updates the time a session expires.

    $session_storage_handler->update_expires($session_id, $expires);

=cut

=method delete_session

Deletes a session from storage.

    $session_storage_handler->delete_session($session_id);

=cut

requires 'delete_session';

requires 'update_expires';

=method invalidate_user_sessions

Updates the time a session expires.

    $session_storage_handler->invalidate_user_sessions($user);

=cut

requires 'invalidate_user_sessions';

1;
