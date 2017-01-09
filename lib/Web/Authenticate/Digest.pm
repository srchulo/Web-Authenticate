use strict;
package Web::Authenticate::Digest;
use Mouse;
use Mouse::Util::TypeConstraints;
use Crypt::PBKDF2;
#ABSTRACT: The default implementation of Web::Authenticate::Digest::Role.

with 'Web::Authenticate::Digest::Role';

=method crypt

Sets the L<Crypt::PBKDF2> object that is used to create and validate digests. Below is the default:

    Crypt::PBKDF2->new(
        hash_class => 'HMACSHA2',
        hash_args => {
            sha_size => 512,
        },
        iterations => 10000,
        salt_len => 10,
    )
    
=cut

has crypt => (
    isa => 'Crypt::PBKDF2',
    is => 'ro',
    required => 1,
    default => sub {
        Crypt::PBKDF2->new(
            hash_class => 'HMACSHA2',
            hash_args => {
                sha_size => 512,
            },
            iterations => 10000,
            salt_len => 10,
        );
    },
);

=method generate

Accepts a password and returns the hex digest of that password using L</crypt>.

    my $password_digest = $digest->generate($password);

=cut

sub generate {
    my ($self, $password) = @_;
    return $self->crypt->generate($password);
}

=method

Uses L<Crypt::PBKDF2/"validate">.

    my $validate_success = $digest->validate($hash, $password);

=cut

sub validate {
    my ($self, $hash, $password) = @_;
    return $self->crypt->validate($hash, $password);
}

1;
