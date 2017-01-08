use strict;
package Web::Authenticate::RequestUrlProvider::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::RequestUrlProvider::Role object should contain.

=method url

Returns the url for the request, with the proper port, protocol, and query parameters.

    my $url = $request_url_provider->url;

=cut

1;
