# ABSTRACT: Perl 5 API wrapper for Name
package API::Name;

use API::Name::Class;

extends 'API::Name::Client';

use Carp ();
use Scalar::Util ();

# VERSION

has identifier => (
    is       => 'rw',
    isa      => STRING,
    default  => 'API::Name (Perl)',
);

has apiuser => (
    is       => 'rw',
    isa      => STRING,
    required => 1,
);

has apitoken => (
    is       => 'rw',
    isa      => STRING,
    required => 1,
);

has version => (
    is       => 'rw',
    isa      => INTEGER,
    default  => 1,
);

method AUTOLOAD () {
    my ($package, $method) = our $AUTOLOAD =~ /^(.+)::(.+)$/;
    Carp::croak "Undefined subroutine &${package}::$method called"
        unless Scalar::Util::blessed $self && $self->isa(__PACKAGE__);

    # return new resource instance dynamically
    return $self->resource($method, @_);
}

method BUILD () {
    my $identifier = $self->identifier;
    my $version    = $self->version;
    my $agent      = $self->user_agent;
    my $url        = $self->url;

    $agent->transactor->name($identifier);

    # $url->path("/api/$version");
    $url->path("/api");

    return $self;
}

method PREPARE ($ua, $tx, %args) {
    my $headers = $tx->req->headers;
    my $url     = $tx->req->url;

    my $apiuser  = $self->apiuser;
    my $apitoken = $self->apitoken;

    # default headers
    $headers->header('Content-Type' => 'application/json');
    $headers->header('Api-Username' => $apiuser);
    $headers->header('Api-Token'    => $apitoken);
}

method action ($method, %args) {
    $method = uc($method || 'get');

    # execute transaction and return response
    return $self->$method(%args);
}

method create (%args) {
    # execute transaction and return response
    return $self->POST(%args);
}

method delete (%args) {
    # execute transaction and return response
    return $self->DELETE(%args);
}

method fetch (%args) {
    # execute transaction and return response
    return $self->GET(%args);
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
        apiuser    => $self->apiuser,
        apitoken      => $self->apitoken,
        version    => $self->version,
    );

    # resource locator
    my $url = $instance->url;

    # modify resource locator if possible
    $url->path(join '/', $self->url->path, @segments);

    # return resource instance
    return $instance;
}

method update (%args) {
    # execute transaction and return response
    return $self->PUT(%args);
}

1;

=encoding utf8

=head1 SYNOPSIS

    use API::Name;

    my $name = API::Name->new(
        apiuser    => 'USER',
        apitoken   => 'TOKEN',
        identifier => 'APPLICATION (yourname@example.com)',
    );

    my $domain = $name->domain(get => 'example.com');
    my $results = $domain->fetch;

=head1 DESCRIPTION

This distribution provides an object-oriented thin-client library for
interacting with the Name (L<https://www.name.com>) API. For usage and
documentation information visit L<https://www.name.com/reseller/API-documentation>.

=cut

=head1 THIN CLIENT

A thin-client library is advantageous as it has complete coverage and can
easily adapt to changes in the API with minimal effort. As a thin-client
library, this module does not map specific HTTP requests to specific routines
nor does it provide parameter validation, pagination, or other conventions
found in typical API client implementations, instead, it simply provides a
simple and consistent mechanism for dynamically generating HTTP requests.
Additionally, this module has support for debugging and retrying API calls as
well as throwing exceptions when 4xx and 5xx server response codes are
received.

=cut

=head2 Building

    my $example = $name->domain(get => 'example.com');
    my $result  = $example->fetch;

    $example->action; # GET /domain/get/example.com
    $example->action('head'); # HEAD /domain/get/example.com

Building up an HTTP request object is extremely easy, simply call method names
which correspond to the API's path segments in the resource you wish to execute
a request against. This module uses autoloading and returns a new instance with
each method call. The following is the equivalent:

    my $domain = $name->resource(domain => 'get');
    my $example = $domain->resource('example.com');

    # or

    my $example = $name->resource('domains', 'get', 'example.com');

    # then

    $example->action('post', %args); # POST /domains/get/example.com

Because each call returns a new API instance configured with a resource locator
based on the supplied parameters, reuse and request isolation are made simple,
i.e., you will only need to configure the client once in your application.

=head2 Fetching

    my $login = $name->login('get');

    $login->fetch(
        query => {
            # query-string parameters
        },
    );

    # equivalent to

    $name->resource('login')->action(
        get => ( query => { ... } )
    );

This example illustrates how you might fetch an API resource.

=head2 Creating

    my $login = $name->login;

    $login->create(
        data => {
            # content-body parameters
        },
        query => {
            # query-string parameters
        },
    );

    # or

    my $login = $name->login->create(...);

    # equivalent to

    $name->resource('login')->action(
        post => ( query => { ... }, data => { ... } )
    );

This example illustrates how you might create a new API resource.

=head2 Updating

    my $login = $name->login;
    my $login  = $login->resource('get');

    $login->update(
        data => {
            # content-body parameters
        },
        query => {
            # query-string parameters
        },
    );

    # or

    my $login = $name->login('get');

    $login->update(...);

    # equivalent to

    $name->resource('login')->action(
        put => ( query => { ... }, data => { ... } )
    );

This example illustrates how you might update an new API resource.

=head2 Deleting

    my $login = $name->login;
    my $login  = $login->resource('get');

    $login->delete(
        data => {
            # content-body parameters
        },
        query => {
            # query-string parameters
        },
    );

    # or

    my $login = $name->login('get');

    $login->delete(...);

    # equivalent to

    $name->resource('login')->action(
        delete => ( query => { ... }, data => { ... } )
    );

This example illustrates how you might delete an API resource.

=cut

=head2 Transacting

    my $login = $name->resource('login', 'get');

    my ($results, $transaction) = $login->fetch(...);

This example illustrates how you can access the transaction object used to
submit the HTTP request.

=cut

=param apitoken

    $name->apitoken;
    $name->apitoken('TOKEN');

The apitoken parameter should be set to the API token assigned to the account
holder.

=cut

=param apiuser

    $name->apiuser;
    $name->apiuser('APIUSER');

The apiuser parameter should be set to the API apiuser assgined to the account holder.

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
retried if a 4xx or 5xx response is received. This attribute defaults to 1.

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

    $name->action('head', %args);   # HEAD request
    $name->action('optons', %args); # OPTIONS request
    $name->action('patch', %args);  # PATCH request


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
resource requested. This method accepts a list of path segments which will be
used in the HTTP request. The following documentation can be used to find more
information. L<https://www.name.com/reseller/API-documentation>.

=cut

=resource dns

    $name->dns;

The dns method returns a new instance representative of the API
resource requested. This method accepts a list of path segments which will be
used in the HTTP request. The following documentation can be used to find more
information. L<https://www.name.com/reseller/API-documentation>.

=cut

=resource domain

    $name->domain;

The domain method returns a new instance representative of the API
resource requested. This method accepts a list of path segments which will be
used in the HTTP request. The following documentation can be used to find more
information. L<https://www.name.com/reseller/API-documentation>.

=cut

=resource host

    $name->host;

The host method returns a new instance representative of the API
resource requested. This method accepts a list of path segments which will be
used in the HTTP request. The following documentation can be used to find more
information. L<https://www.name.com/reseller/API-documentation>.

=cut

=resource login

    $name->login;

The login method returns a new instance representative of the API
resource requested. This method accepts a list of path segments which will be
used in the HTTP request. The following documentation can be used to find more
information. L<https://www.name.com/reseller/API-documentation>.

=cut

=resource logout

    $name->logout;

The logout method returns a new instance representative of the API
resource requested. This method accepts a list of path segments which will be
used in the HTTP request. The following documentation can be used to find more
information. L<https://www.name.com/reseller/API-documentation>.

=cut

=resource order

    $name->order;

The order method returns a new instance representative of the API
resource requested. This method accepts a list of path segments which will be
used in the HTTP request. The following documentation can be used to find more
information. L<https://www.name.com/reseller/API-documentation>.

=cut

