use strict;
package Web::Authenticate::Storage::Handler::SQL;
use Mouse;
use Carp;
use DBIx::Raw;
use Web::Authenticate::Digest;
#ABSTRACT: Implementation of Web::Authentication::Storage::Handlerr::Role that can be used with MySQL or SQLite.

with 'Web::Authenticate::Storage::Handler::Role';

=head1 DESCRIPTION

This L<Web::Authenticate::Storage::Handler::Role> is meant to be used with a very specific table structure:

    CREATE TABLE users (
    	id INTEGER PRIMARY KEY AUTO_INCREMENT,
        username VARCHAR(255) NOT NULL UNIQUE,
        password TEXT NOT NULL
    );

Other columns can exists, and the names of the table and column can change. But at least these columns must exist
in order for this storage handler to work properly. Also, the primary key does not have to be an integer, and could
even be the username.

=cut

=method users_table

Sets the name of the users table that will be used when querying the database. Default is 'users'.

=cut

has users_table => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => 'users',
);

=method id_field

Sets the name of the id field that will be used when querying the database. Default is 'id'.

=cut

has id_field => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => 'id',
);

=method username_field

Sets the name of the username field that will be used when querying the database. Default is 'username'.

=cut

has username_field => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => 'username',
);

=method password_field

Sets the name of the password field that will be used when querying the database. Default is 'password'.

=cut

has password_field => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => 'password',
);

=method digest

Sets the L<Web::Authenticate::Digest::Role> that is used. Default is L<Web::Authenticate::Digest>.

=cut

has digest => (
    does => 'Web::Authenticate::Digest::Role',
    is => 'ro',
    required => 1,
    default => sub { Web::Authenticate::Digest->new },
);

=method dbix_raw

Sets the L<DBIx::Raw> object that will be used to query the database. This is required with no default.

=cut

has dbix_raw => (
    isa => 'DBIx::Raw',
    is => 'ro',
    required => 1,
);

=method load_user

Accepts the username and password for a user, and returns a L<Web::Authenticate::User> if the password is correct and the user exists.
Otherwise, undef is returned.

=cut

sub load_user {
    my ($self, $username, $password) = @_;
    croak "must provide username" unless $username;
    croak "must provide password" unless $password;

    my $users_table = $self->users_table;
    my $id_field = $self->id_field;
    my $username_field = $self->username_field;
    my $password_field = $self->password_field;
    my ($id, $password_hash) = $self->dbix_raw->raw("SELECT $id_field, $password_field FROM $users_table WHERE $username_field = ?", $username);

    # TODO select columns. Allow user to decide which colums to select. Pass into generic row hash holder.

    return unless $id and $password_hash and 
        $self->digest->validate($password_hash, $password);

    return Web::Authenticate::User->new(id => $id);
}

=method store_user

Takes in username ad

TODO FINISH

=cut

sub store_user {
    my ($self, $username, $password, $user_values) = @_;
    croak "must provide username" unless $username;
    croak "must provide password" unless $password;

    #$user_values //= {};

    # TODO create insert/encrypt in dbix raw from hash
    #$user_vaules->{

    my $users_table = $self->users_table;
    my $id_field = $self->id_field;;
    my $username_field = $self->username_field;
    my $password_field = $self->password_field;;

    $self->dbix_raw->raw("INSERT INTO $users_table ($username_field, $password_field) VALUES(?, ?)", $username, $self->digest->generate($password));

    # select columns user wants here instead except password_hash. Then pass into extra field
    my $id = $self->dbix_raw->raw("SELECT $id_field FROM $users_table WHERE $username_field = ?", $username);

    return unless $id;

    return Web::Authenticate::User->new(id => $id);
}

1;
