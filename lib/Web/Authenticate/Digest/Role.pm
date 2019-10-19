use strict;
package Web::Authenticate::Digest::Role;
use Mouse::Role;
#ABSTRACT: A Mouse::Role that defines what methods a Web::Authenticate::Digest object should contain.

=method generate

All L</Web::Authenticate::Digest> objects should be able to digest text and return a hashed value.

    my $hash = $digest->generate($password);

=cut

requires 'generate';

=method validate

Validates the stored hash for the user against the user entered password.

    if ($digest->validate($hash, $password)) {
        # success
    } else {
        # failure
    }

=cut

requires 'validate';

1;
