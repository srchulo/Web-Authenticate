use strict;
package Web::Authenticate;
use Mouse;
use Carp;
use Web::Authenticate::Cookie::Handler;
use Web::Authenticate::RedirectHandler;
use Web::Authenticate::Result::Login;
use Web::Authenticate::Result::Authenticate;
use Web::Authenticate::Result::IsAuthenticated;
use Web::Authenticate::RequestUrlProvider::CgiRequestUrlProvider;
use Ref::Util qw/is_arrayref/;
#ABSTRACT: Allows web authentication using cookies and a storage engine. 

=method user_storage_handler

Sets the L<Web::Authenticate::User::Storage::Handler::Role> to be used. This is required with no default.

=cut

has user_storage_handler => (
    does => 'Web::Authenticate::User::Storage::Handler::Role',
    is => 'ro',
    required => 1,
);

=method session_handler

Sets the L<Web::Authenticate::Session::Handler::Role> to be used. This is required with no default.

=cut

has session_handler => (
    does => 'Web::Authenticate::Session::Handler::Role',
    is => 'ro',
    required => 1,
);

=method cookie_handler

Sets the object that does L<Web::Authenticate::Cookie::Handler::Role> to be used. The default is the default L<Web::Authenticate::Cookie::Handler>.

=cut

has cookie_handler => (
    does => 'Web::Authenticate::Cookie::Handler::Role',
    is => 'ro',
    required => 1,
    default => sub { Web::Authenticate::Cookie::Handler->new },
);

=method redirect_handler

Sets the object that does L<Web::Authenticate::RedirectHandler::Role> to be used. The default is the default L<Web::Authenticate::RedirectHandler>.

=cut

has redirect_handler => (
    does => 'Web::Authenticate::RedirectHandler::Role',
    is => 'ro',
    required => 1,
    default => sub { Web::Authenticate::RedirectHandler->new },
);



=method request_url_provider

Sets the object that does L<Web::Authenticate::RequestUrlProvider::Role> to get the url for the current request
(used to store the current url if L</allow_after_login_redirect_override> is set to true and L</authenticate> fails).
Default is L<Web::Authenticate::RequestUrlProvider::CgiRequestUrlProvider>.

=cut

has request_url_provider => (
    does => 'Web::Authenticate::RequestUrlProvider::Role',
    is => 'ro',
    required => 1,
    default => sub { Web::Authenticate::RequestUrlProvider::CgiRequestUrlProvider->new },
);

=method login_url

Sets the login url that a user will be redirected to if they need to login. This is required with no default.

    my $web_auth = Web::Authenticate->new(login_url => "http://www.google.com/login");

OR

    $web_auth->login_url("http://www.google.com/login");

=cut

has login_url => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

=method after_login_url

The url the user will be redirected to after a successful login.

=cut

has after_login_url => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

=method after_logout_url

The url the user will be redirected to after a successful logout. This is required with no default.

=cut

has after_logout_url => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

=method authenticate_fail_url

The url the user will be redirected to if they are logged in, but fail to pass all authenticators in the
authenticators arrayref for L</authenticate>.

=cut

has authenticate_fail_url => (
    isa => 'Str|Undef',
    is => 'rw',
);

=method update_expires_on_authenticate

If set to true (1), updates the expires time for the session upon successful authentication. Default is true.

=cut

has update_expires_on_authenticate => (
    isa => 'Bool',
    is => 'ro',
    required => 1,
    default => 1,
);

=method allow_after_login_redirect_override

If a user requests a page that requires authentication and is redirected to login, if allow_after_login_redirect_override is set to true (1), then
the user will be redirected to that url after a successful login. If set to false, then the user will be redirected to L</after_login_url>.

=cut

has allow_after_login_redirect_override => (
    isa => 'Bool',
    is => 'ro',
    required => 1,
    default => 1,
);

=method allow_after_login_redirect_time_seconds

The url of the page the user tried to load is set to a cookie if they are redirected to login from L</authenticate>. This sets the amount of time (in seconds)
for the cookie to be valid. Default is 5 minutes.

=cut

has allow_after_login_redirect_time_seconds => (
    isa => 'Int',
    is => 'ro',
    required => 1,
    default => 300,
);

has _after_login_redirect_override_cookie_name => (
    isa => 'Str',
    is => 'ro',
    required => '1',
    default => 'after_login_redirect',
);

=method login

=over

=item 

B<login_args (required)> - the arguments that the L<Web::Authenticate::User::Storage::Handler::Role> requires for 
L<Web::Authenticate::User::Storage::Handler::Role/load_user>.

=item 

B<authenticators (optional)> - An arrayref of L<Web::Authenticate::Authenticator::Role>. If any of the authenticators does not
authenticate, then login will fail.

=item 

B<auth_redirects (optional)> - An arrayref of L<Web::Authenticate::Authenticator::Redirect::Role>. If the user logins successfully, the user will
be redirected to the L<Web::Authenticate::Authenticator::Redirect::Role/url> of the first L<Web::Authenticate::Authenticator::Redirect::Role/authenticator>
that authenticates. If none of the auth_redirects authenticate, then the user will be redirected to L</after_login_url>.

=back

Verifies the arguments required by L<Web::Authenticate::User::Storage::Handler::Role> in L</user_storage_handler>. If they are correct, if L</allow_after_login_redirect_override>
is set to 1 and the user has a cookie set for this, the user will be redirected to that url. If not, the user is redirected to the 
first the L<Web::Authenticate::Authenticator::Redirect::Role/url> of the first succesful L<Web::Authenticate::Authenticator::Redirect::Role> in auth_redirects. 
If auth_redirects is empty or none authenticate, then the user is redirected to L</after_login_url>
Returns a L<Web::Authenticate::Result::Login> object. 

    my $login_result = $web_auth->login(login_args => [$username, $password]);

    if ($login_result->success) {
        log("user id is " . $login_result->user->id);
        exit; # already set to redirect to appropriate page
    } else {
        # handle login failure
        if ($login_result->authenticator) {
            # this authenticator caused the failure
        }
    }

=cut

sub login {
    my $self = shift;
    my %params = @_;

    croak "must provide login_args and login_args must be arrayref" unless $params{login_args} and is_arrayref($params{login_args});
    _validate_role_arrayref('authenticators', $params{authenticators}, 'Web::Authenticate::Authenticator::Role');
    _validate_role_arrayref('auth_redirects', $params{auth_redirects}, 'Web::Authenticate::Authenticator::Redirect::Role');

    $params{authenticators} //= [];
    $params{auth_redirects} //= [];

    my $user = $self->user_storage_handler->load_user(@{$params{login_args}});

    return Web::Authenticate::Result::Login->new(success => undef) unless $user;

    for my $authenticator (@{$params{authenticators}}) {
        return Web::Authenticate::Result::Login->new(success => undef, user => $user, failed_authenticator => $authenticator)
            unless $authenticator->authenticate($user);
    }
    
    $self->session_handler->invalidate_user_sessions($user);
    $self->session_handler->create_session($user);

    my $redirect_url = $self->after_login_url;
    my $allow_after_login_redirect_override_url;
    my $result_auth_redirect;
    if ($self->allow_after_login_redirect_override) {
        my $override_cookie_name = $self->_after_login_redirect_override_cookie_name;
        $allow_after_login_redirect_override_url = $self->cookie_handler->get_cookie($override_cookie_name);
        $self->cookie_handler->delete_cookie($override_cookie_name);
    } 
    
    if ($allow_after_login_redirect_override_url) {
        $redirect_url = $allow_after_login_redirect_override_url; 
    } else {
        for my $auth_redirect (@{$params{auth_redirects}}) {
            if ($auth_redirect->authenticator->authenticate($user)) {
                $redirect_url = $auth_redirect->url;
                $result_auth_redirect = $auth_redirect;
                last;
            }
        }
    }

    $self->redirect_handler->redirect($redirect_url);

    return Web::Authenticate::Result::Login->new(success => 1, user => $user, auth_redirect => $result_auth_redirect);
}

=method logout

Logs a user out of their current session by deleting their session cookie and their storage-backed session.

    $web_authenticate->logout;

=cut

sub logout {
    my ($self) = @_;

    $self->session_handler->delete_session;
    $self->redirect_handler->redirect($self->after_logout_url);
}

=method authenticate

=over

=item 

B<authenticators (optional)> - An arrayref of L<Web::Authenticate::Authenticator::Role>. If any of the authenticators does not
authenticate, then the user will be redirected to L</authenticate_fail_url>.

=item 

B<auth_redirects (optional)> - An arrayref of L<Web::Authenticate::Authenticator::Redirect::Role>. The user will
be redirected to the L<Web::Authenticate::Authenticator::Redirect::Role/url> of the first L<Web::Authenticate::Authenticator::Redirect::Role/authenticator>
that fails to authenticates. If none of the auth_redirects fail to authenticate, then the user will not be redirected.

=back

First makes sure that the user authenticates as being logged in with a session. If the user is not, the user is redirected to L</login_url>.
Then, the method tries to authenticate all authenticators. If any authenticator fails, the user is redirected to L</authenticate_fail_url>.
Then, all auth_redirects are checked. If any auth_redirect fails to authenticate, the user will be redirected to the L<Web::Authenticate::Authenticator::Redirect::Role/url>
for that auth_redirect. auth_redirects are processed in order. This method returns a L<Web::Authenticate::Result::Authenticate> object.

    my $authenticate_result = $web_auth->authenticate;

    # OR
    my $authenticate_result = $web_auth->authenticate(authenticators => $authenticators, auth_redirects => $auth_redirects);

    if ($authenticate_result->success) {
        print "User " . $authenticate_result->user->id . " successfully authenticated\n";
    } else {
        # failed to authenticate user.
        if ($authenticate_result->failed_authenticator) {
            # this authenticator caused the failure
        }
    }

=cut

sub authenticate {
    my ($self) = shift;
    my %params = @_;

    _validate_role_arrayref('auth_redirects', $params{auth_redirects}, 'Web::Authenticate::Authenticator::Redirect::Role');

    $params{auth_redirects} //= [];

    my $is_authenticated = $self->is_authenticated(@_, redirect => 1);

    unless ($is_authenticated->success) {
        if ($is_authenticated->user) {
            return Web::Authenticate::Result::Authenticate->new(success => undef, user => $is_authenticated->user, failed_authenticator => $is_authenticated->failed_authenticator);
        } else {
            return Web::Authenticate::Result::Authenticate->new(success => undef);
        }
    }

    # in this function, unlike in login, if redirect role fails then they're directed there.
    my $user = $is_authenticated->user;
    for my $auth_redirect (@{$params{auth_redirects}}) {
        unless ($auth_redirect->authenticator->authenticate($user)) {
            $self->redirect_handler->redirect($auth_redirect->url);
            return Web::Authenticate::Result::Authenticate->new(success => undef, user => $user, auth_redirect => $auth_redirect);
        }
    }

    $self->session_handler->update_expires if $self->update_expires_on_authenticate;

    return Web::Authenticate::Result::Authenticate->new(success => 1, user => $user);
}

=method is_authenticated

=over

=item 

B<authenticators (optional)> - An arrayref of L<Web::Authenticate::Authenticator::Role>. If any of the authenticators does not
authenticate, then the user will be redirected to L</authenticate_fail_url>.

=item

B<redirect (optional)> - If set to true, this method will redirect appropriately if the user does not authenticate.

=back

First makes sure that the user authenticates as being logged in with a session. If the user is not, the user is redirected to L</login_url> if redirect is set to 1.
Then, the method tries to authenticate all authenticators. If any authenticator fails, the user is redirected to L</authenticate_fail_url> if redirect is set to 1.
This method returns a L<Web::Authenticate::Result::IsAuthenticated> object.

    my $is_authenticated_result = $web_auth->is_authenticated;

    # OR
    my $is_authenticated_result = $web_auth->is_authenticated(authenticators => $authenticators);

    if ($is_authenticated_result->success) {
        print "User " . $is_authenticated_result->user->id . " successfully authenticated\n";
    } else {
        # failed to authenticate user.
        if ($is_authenticated_result->failed_authenticator) {
            # this authenticator caused the failure
        }
    }

This method does not update the expires time for the session. It does however respect L</allow_after_login_redirect_override>.

=cut

sub is_authenticated {
    my ($self) = shift;
    my %params = @_;

    _validate_role_arrayref('authenticators', $params{authenticators}, 'Web::Authenticate::Authenticator::Role');

    $params{authenticators} //= [];

    my $session = $self->session_handler->get_session;

    unless ($session) {
        if ($self->allow_after_login_redirect_override) {
            my $url = $self->request_url_provider->url;
            $self->cookie_handler->set_cookie($self->_after_login_redirect_override_cookie_name, $url, $self->allow_after_login_redirect_time_seconds);
        }
        $self->redirect_handler->redirect($self->login_url) if $params{redirect};
        return Web::Authenticate::Result::IsAuthenticated->new(success => undef) unless $session;
    }

    my $user = $session->user;
    unless ($user) {
        $self->redirect_handler->redirect($self->login_url) if $params{redirect};
        return Web::Authenticate::Result::IsAuthenticated->new(success => undef);
    }
    
    for my $authenticator (@{$params{authenticators}}) {
        unless ($authenticator->authenticate($user)) {
            $self->redirect_handler->redirect($self->authenticate_fail_url) if $params{redirect};
            return Web::Authenticate::Result::IsAuthenticated->new(success => undef, user => $user, failed_authenticator => $authenticator);
        }
    }

    return Web::Authenticate::Result::IsAuthenticated->new(success => 1, user => $user);
}

=method create_user

=cut

sub create_user {
    # take in requirements
    # pass requirements
    # username requirements
    # runt tests on both. If they all pass, create user. Return failing ones
}

sub _validate_role_arrayref {
    my ($param_name, $arrayref, $role) = @_;
    croak "$param_name must be an arrayref" if $arrayref and not is_arrayref($arrayref);

    for my $item (@$arrayref) {
        croak "all items in $param_name must do $role" unless $item->does($role);
    }
}

1;
