use strict;
package Web::Authenticate::Session::Storage::Handler::SQL;
use Mouse;
use Carp;
use DateTime;
use DBIx::Raw;
use Web::Authenticate::Session;
use Web::Authenticate::User::Storage::Handler::SQL;
#ABSTRACT: Implementation of Web::Authenticate::Session::Storage::Handler::Role that can be used with MySQL or SQLite.

with 'Web::Authenticate::Session::Storage::Handler::Role';

=head1 DESCRIPTION

This L<Web::Authenticate::Session::Storage::Handler::Role> is meant to be used with a very specific table structure:

    CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTO_INCREMENT,
        user_id INTEGER NOT NULL UNIQUE,
        session_id VARCHAR(255) NOT NULL UNIQUE,
        expires INTEGER NOT NULL
    );

Other columns can exists, and the names of the table and column can change. But at least these columns must exist
in order for this storage handler to work properly. Also, the primary key does not have to be an integer, and could
even be the session_id. Also, the user_id does not need to be unique if you want to allow multiple sessions for a
user by setting L</allow_multiple_session_per_user> to true.

=cut

=method user_storage_handler

Sets the L<Web::Authenticate::User::Storage::Handler::Role> to be used. This is required. Default is
L<Web::Authenticate::User::Storage::Handler::SQL> created with L</dbix_raw>.

=cut

has user_storage_handler => (
    does => 'Web::Authenticate::User::Storage::Handler::Role',
    is => 'ro',
    required => 1,
    lazy => 1,
    default => sub {
        my ($self) = @_;
        Web::Authenticate::User::Storage::Handler::SQL->new(dbix_raw => $self->dbix_raw);
    },
);

=method sessions_table

Sets the name of the sessions table that will be used when querying the database. Default is 'sessions'.

=cut

has sessions_table => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => 'sessions',
);

=method session_id_field

Sets the name of the session id field that will be used when querying the database. Default is 'session_id'.

=cut

has session_id_field => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => 'session_id',
);

=method user_id_field

Sets the name of the user_id field that will be used when querying the database. Default is 'user_id'.

=cut

has user_id_field => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => 'user_id',
);

=method expires_field

Sets the name of the expires time field that will be used when querying the database. Default is 'expires'.

=cut

has expires_field => (
    isa => 'Str',
    is => 'ro',
    required => 1,
    default => 'expires',
);

=method allow_multiple_session_per_user

A bool (1 or undef) whether or not to allow multiple sessions per user. If set to true, when L</invalidate_user_sessions> is
called nothing will happen. Default is false.

=cut

has allow_multiple_session_per_user => (
    isa => 'Bool',
    is => 'ro',
    required => 1,
    default => undef,
);

=method dbix_raw

Sets the L<DBIx::Raw> object that will be used to query the database. This is required with no default.

=cut

has dbix_raw => (
    isa => 'DBIx::Raw',
    is => 'ro',
    required => 1,
);

=method columns

The columns to select. At a minimum, L</session_id_field>, L</user_id_field>, and L</expires_field> will always be selected.

    $storage_handler->columns([qw/session_data/]);

Default is an empty array ref.

=cut

has columns => (
    isa => 'ArrayRef',
    is => 'ro',
    required => 1,
    default => sub { [] },
);

=method store_session

Takes in user, session_id, expires, and any additional values for columns in a hash and a session with those values is created.
Returns a L<Web::Authenticate::Session> with any values from L</columns> stored in L<Web::Authenticate::Session/row>.

    my $session_values => {
        session_data => $session_data,
    };
    my $session = $session_storage_handler->store_session($user, $session_id, $expires, $session_values);

    # if you need no extra user values in the row
    my $session = $storage_handler->store_session($user, $session_id, $expires);

=cut

sub store_session {
    my ($self, $user, $session_id, $expires, $session_values) = @_;
    croak "must provide user" unless $user;
    croak "must provide session_id" unless $session_id;
    croak "must provide valid expires" unless $expires or $expires < 1;

    my $sessions_table = $self->sessions_table;
    my $user_id_field = $self->user_id_field;
    my $session_id_field = $self->session_id_field;
    my $expires_field = $self->expires_field;

    $session_values //= {};
    $session_values->{$user_id_field} = $user->id;
    $session_values->{$session_id_field} = $session_id;
    $session_values->{$expires_field} = $expires;

    $self->dbix_raw->insert(href => $session_values, table => $sessions_table);

    my $selection = $self->_get_selection($user_id_field, $session_id_field, $expires_field);
    my $session = $self->dbix_raw->raw("SELECT $selection FROM $sessions_table WHERE $session_id_field = ?", $session_id);

    unless ($session) {
        carp "failed to insert session to database";
        return;
    }

    return Web::Authenticate::Session->new(id => $session->{$session_id_field}, expires => $session->{$expires_field}, user => $user, row => $session);
}

=method load_session

Loads a L<Web::Authenticate::Session> by session_id. If the session exists, the session is returned.
Otherwise, undef is returned. Any additional L</columns> will be stored in L<Web::Authenticate::Session/row>. 

    my $session = $session_storage_handler->load_session($session_id);

=cut

sub load_session {
    my ($self, $session_id) = @_;
    croak "must provide session_id" unless $session_id;

    my $sessions_table = $self->sessions_table;
    my $user_id_field = $self->user_id_field;
    my $session_id_field = $self->session_id_field;
    my $expires_field = $self->expires_field;

    my $now = DateTime->now->epoch;
    my $selection = $self->_get_selection($user_id_field, $session_id_field, $expires_field);
    my $session = $self->dbix_raw->raw("SELECT $selection FROM $sessions_table WHERE $session_id_field = ? AND $expires_field >= $now", $session_id);

    unless ($session) {
        return;
    }

    my $user = $self->user_storage_handler->load_user_by_id($session->{$user_id_field});

    unless ($user) {
        carp "failed to load user from database";
        return;
    }

    return Web::Authenticate::Session->new(id => $session->{$session_id_field}, expires => $session->{$expires_field}, user => $user, row => $session);
}

=method delete_session

Deletes a session from storage.

    $session_storage_handler->delete_session($session_id);

=cut

sub delete_session {
    my ($self, $session_id) = @_;
    croak "must provide session_id" unless $session_id;

    my $sessions_table = $self->sessions_table;
    my $session_id_field = $self->session_id_field;
    $self->dbix_raw->raw("DELETE FROM $sessions_table WHERE $session_id_field = ?", $session_id);
}

=method invalidate_user_sessions

Invalidates (deletes) any user sessions for user unless L</allow_multiple_session_per_user> is set to true.

    $session_storage_handler->invalidate_user_sessions($user);

=cut

sub invalidate_user_sessions {
    my ($self, $user) = @_;
    croak "must provide user" unless $user;
    return if $self->allow_multiple_session_per_user;

    my $sessions_table = $self->sessions_table;
    my $user_id_field = $self->user_id_field;
    $self->dbix_raw->raw("DELETE FROM $sessions_table WHERE $user_id_field = ?", $user->id);
}

=method update_expires

Updates the expires time for the session with the session id session_id.

    $session_storage_handler->update_expires($session_id, $expires);

=cut

sub update_expires {
    my ($self, $session_id, $expires) = @_;
    croak "must provide session_id" unless $session_id;
    croak "must provide expires" unless $expires;

    my $sessions_table = $self->sessions_table;
    my $session_id_field = $self->session_id_field;
    my $expires_field = $self->expires_field;
    $self->dbix_raw->raw("UPDATE $sessions_table SET $expires_field = ? WHERE $session_id_field = ?", $expires, $session_id);
}

sub _get_selection {
    my ($self, @columns) = @_;

    die "columns required" unless @columns;

    my $selection = join ',', @columns;

    if (@{$self->columns}) {
        $selection .= ',' . join ',', @{$self->columns}; 
    }

    return $selection;
}

1;
