use strict;
package Web::Authenticate::User::CredentialVerifier::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::User::CredentialVerifier object should contain.

=method verify

Verifies a user credential. Returns 1 if it verifies, undef otherwise

    if(not $credential_verifier->verify($password)) {
        # invalid password!
    }

=cut

requires 'verify';

=method name

Returns the name of this verifier.

=cut

requires 'name';

=method error_msg

Returns the error message if this verifier fails

=cut

requires 'error_msg';

1;
