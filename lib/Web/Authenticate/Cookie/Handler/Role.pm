use strict;
package Web::Authenticate::Cookie::Handler::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::Cookie::Handler object should contain.

=method set_cookie

Creates a session for user and sets it on the browser. expires must be the number of seconds from now
when the cookie should expire.

    $cookie_handler->set_cookie($name, $value, $expires_in_seconds);

=cut

requires 'set_cookie';

=method get_cookie

Gets the value of the cookie with name. Returns undef if there is no cookie with that name, or it has expired.

    my $cookie_value = $cookie_handler->get_cookie($name);

=cut

requires 'get_cookie';

=method delete_cookie

Deletes cookie with name if it exists.

    $cookie_handler->delete_cookie($name);

=cut

requires 'delete_cookie';

1;
