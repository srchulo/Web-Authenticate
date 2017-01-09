use strict;
package Web::Authenticate::RedirectHandler::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::RedirectHandler object should contain.

=method redirect

Redirects to url.

    $redirect_handler->redirect($url);

=cut

requires 'redirect';

1;
