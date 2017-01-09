package Web::Authenticate::User::CredentialVerifier::LengthCredentialVerifier;
use strict;
use Mouse;

use Mouse::Util::TypeConstraints;
 
subtype 'Natural'
    => as 'Int'
    => where { $_ > 0 };
 
no Mouse::Util::TypeConstraints;

=method name

Sets the name of this L<Web::Authenticate::User::CredentialVerifier::Role>. Default is Length.

=cut

has name => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => 'Length',
);

with 'Web::Authenticate::User::CredentialVerifier::Role';

=method min_length

Sets the minimum length for a value. Default is 1.

=cut

has min_length => (
    isa => 'Natural',
    is => 'ro',
    required => 1,
    default => 1,
);

=method max_length

Sets the maximum length for a value. Default is 100.

=cut

has max_length => (
    isa => 'Natural',
    is => 'ro',
    required => 1,
    default => 100,
);

=method verify

Verifies that value is between L</min_length> and L</max_length>.

	my $success = $verifier->verify($value);

=cut

sub verify {
    my ($self, $value) = @_; 
	my $length = length($value);

    return $length >= $self->min_length && $length <= $self->max_length;
}

=method error_msg

Prints message in the form of:

	$name must be between $min_length and $max_length	

=cut

sub error_msg { 
	my ($self) = @_;
	return $self->name . ' must be between ' . $self->min_length . ' and ' . $self->max_length;
}

1;
