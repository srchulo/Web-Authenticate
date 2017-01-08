use strict;
package Web::Authenticate::RequestUrlProvider::CgiRequestUrlProvider;
use Mouse;
use CGI;
#ABSTRACT: The default implementation of Web::Authentication::RequestUrlProvider.

with 'Web::Authenticate::RequestUrlProvider::Role';

=head1 SYNOPSIS

    my $url = $cgi_request_url_provider->url;

=head1 DESCRIPTION

This RequestUrlProvider uses L<CGI> to get the current url.

=cut

=method url

Returns the current url using the L<url|CGI> method from L<CGI> with full, query, and rewrite set to 1.

=cut

sub url { CGI->new->url(-full => 1, -query=>1, -rewrite => 1) }

1;
