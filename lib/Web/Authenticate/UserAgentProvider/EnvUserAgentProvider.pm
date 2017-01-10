use strict;
package Web::Authenticate::UserAgentProvider::EnvUserAgentProvider;
use Mouse;
#ABSTRACT: Implementation of Web::Authentication::UserAgentProvider::Role that users environment variables.

with 'Web::Authenticate::UserAgentProvider::Role';

=method get_user_agent

Returns the user's user agent using $ENV{HTTP_USER_AGENT}.

=cut

sub get_user_agent { $ENV{HTTP_USER_AGENT} }

1;
