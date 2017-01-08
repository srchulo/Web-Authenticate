use strict;
package Web::Authenticate::Session::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::Session object should contain.

=method id

Returns the id of this session.

    my $session_id = $session->id;

=cut

requires 'id';

=method expires

Returns the date of expiration for this session (format of date dependent upon the implementation).

    my $expires = $session->expires;

=cut

requires 'expires';

=method user

Returns the user for this session.

    my $user = $session->user;

=cut

requires 'user';

1;
