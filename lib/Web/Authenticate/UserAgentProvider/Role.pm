use strict;
package Web::Authenticate::UserAgentProvider::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::UserAgentProvider object should contain.

=method get_user_agent

Returns the user agent for the user's browser.

=cut

requires 'get_user_agent';

1;
