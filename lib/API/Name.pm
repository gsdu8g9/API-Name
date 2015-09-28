# ABSTRACT: Name.com API Client
package API::Name;

use namespace::autoclean -except => 'has';

use Data::Object::Class;
use Data::Object::Class::Syntax;
use Data::Object::Signatures;

use Data::Object qw(load);
use Data::Object::Library qw(Str);

extends 'API::Client';

# VERSION

our $DEFAULT_URL = "https://www.name.com";

# ATTRIBUTES

has user  => rw;
has token => rw;

# CONSTRAINTS

req user  => Str;
req token => Str;

# DEFAULTS

def identifier => 'API::Name (Perl)';
def url        => method { load('Mojo::URL')->new($DEFAULT_URL) };
def version    => 1;

# CONSTRUCTION

after BUILD => method {
    my $identifier = $self->identifier;
    my $version    = $self->version;
    my $agent      = $self->user_agent;
    my $url        = $self->url;

    $agent->transactor->name($identifier);

    # $url->path("/api/$version");
    $url->path("/api");

    return $self;
};

# METHODS

method PREPARE ($ua, $tx, %args) {
    my $headers = $tx->req->headers;
    my $url     = $tx->req->url;

    my $user  = $self->user;
    my $token = $self->token;

    # default headers
    $headers->header('Content-Type' => 'application/json');
    $headers->header('Api-Username' => $user);
    $headers->header('Api-Token'    => $token);
}

method resource (@segments) {
    # build new resource instance
    my $instance = __PACKAGE__->new(
        debug      => $self->debug,
        fatal      => $self->fatal,
        retries    => $self->retries,
        timeout    => $self->timeout,
        user_agent => $self->user_agent,
        identifier => $self->identifier,
        token      => $self->token,
        user       => $self->user,
        version    => $self->version,
    );

    # resource locator
    my $url = $instance->url;

    # modify resource locator if possible
    $url->path(join '/', $self->url->path, @segments);

    # return resource instance
    return $instance;
}

1;

=encoding utf8

=head1 SYNOPSIS

    use API::Name;

    my $name = API::Name->new(
        user       => 'USER',
        token      => 'TOKEN',
        identifier => 'APPLICATION NAME',
    );

    $name->debug(1);
    $name->fatal(1);

    my $domain = $name->domains(get => 'example.com');
    my $results = $domain->fetch;

    # after some introspection

    $domain->update( ... );

=head1 DESCRIPTION

This distribution provides an object-oriented thin-client library for
interacting with the Name (L<https://www.name.com>) API. For usage and
documentation information visit L<https://www.name.com/reseller/API-documentation>.
API::Name is derived from L<API::Client> and inherits all of it's
functionality. Please read the documentation for API::Client for more usage
information.

=cut

=attr token

    $name->token;
    $name->token('TOKEN');

The token attribute should be set to the API token assigned to the account
holder.

=cut

=attr user

    $name->user;
    $name->user('USER');

The user attribute should be set to the API user assgined to the account
holder.

=cut

=attr identifier

    $name->identifier;
    $name->identifier('IDENTIFIER');

The identifier attribute should be set to a string that identifies your
application.

=cut

=attr debug

    $name->debug;
    $name->debug(1);

The debug attribute if true prints HTTP requests and responses to standard out.

=cut

=attr fatal

    $name->fatal;
    $name->fatal(1);

The fatal attribute if true promotes 4xx and 5xx server response codes to
exceptions, a L<API::Name::Exception> object.

=cut

=attr retries

    $name->retries;
    $name->retries(10);

The retries attribute determines how many times an HTTP request should be
retried if a 4xx or 5xx response is received. This attribute defaults to 0.

=cut

=attr timeout

    $name->timeout;
    $name->timeout(5);

The timeout attribute determines how long an HTTP connection should be kept
alive. This attribute defaults to 10.

=cut

=attr url

    $name->url;
    $name->url(Mojo::URL->new('https://www.name.com'));

The url attribute set the base/pre-configured URL object that will be used in
all HTTP requests. This attribute expects a L<Mojo::URL> object.

=cut

=attr user_agent

    $name->user_agent;
    $name->user_agent(Mojo::UserAgent->new);

The user_agent attribute set the pre-configured UserAgent object that will be
used in all HTTP requests. This attribute expects a L<Mojo::UserAgent> object.

=cut

=method action

    my $result = $name->action($verb, %args);

    # e.g.

    $name->action('head', %args);    # HEAD request
    $name->action('options', %args); # OPTIONS request
    $name->action('patch', %args);   # PATCH request


The action method issues a request to the API resource represented by the
object. The first parameter will be used as the HTTP request method. The
arguments, expected to be a list of key/value pairs, will be included in the
request if the key is either C<data> or C<query>.

=cut

=method create

    my $results = $name->create(%args);

    # or

    $name->POST(%args);

The create method issues a C<POST> request to the API resource represented by
the object. The arguments, expected to be a list of key/value pairs, will be
included in the request if the key is either C<data> or C<query>.

=cut

=method delete

    my $results = $name->delete(%args);

    # or

    $name->DELETE(%args);

The delete method issues a C<DELETE> request to the API resource represented by
the object. The arguments, expected to be a list of key/value pairs, will be
included in the request if the key is either C<data> or C<query>.

=cut

=method fetch

    my $results = $name->fetch(%args);

    # or

    $name->GET(%args);

The fetch method issues a C<GET> request to the API resource represented by the
object. The arguments, expected to be a list of key/value pairs, will be
included in the request if the key is either C<data> or C<query>.

=cut

=method update

    my $results = $name->update(%args);

    # or

    $name->PUT(%args);

The update method issues a C<PUT> request to the API resource represented by
the object. The arguments, expected to be a list of key/value pairs, will be
included in the request if the key is either C<data> or C<query>.

=cut

=resource account

    $name->account;

The account method returns a new instance representative of the API
I<account> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://www.name.com/reseller/API-documentation>.

=cut

=resource dns

    $name->dns;

The dns method returns a new instance representative of the API
I<dns> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://www.name.com/reseller/API-documentation>.

=cut

=resource domain

    $name->domain;

The domain method returns a new instance representative of the API
I<domain> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://www.name.com/reseller/API-documentation>.

=cut

=resource host

    $name->host;

The host method returns a new instance representative of the API
I<host> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://www.name.com/reseller/API-documentation>.

=cut

=resource login

    $name->login;

The login method returns a new instance representative of the API
I<login> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://www.name.com/reseller/API-documentation>.

=cut

=resource logout

    $name->logout;

The logout method returns a new instance representative of the API
I<logout> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://www.name.com/reseller/API-documentation>.

=cut

=resource order

    $name->order;

The order method returns a new instance representative of the API
I<order> resource requested. This method accepts a list of path
segments which will be used in the HTTP request. The following documentation
can be used to find more information. L<https://www.name.com/reseller/API-documentation>.

=cut

