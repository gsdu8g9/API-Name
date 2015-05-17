package API::Name::Type;

use Type::Tiny;

use Type::Utils -all;
use Type::Library -base;
use Types::Standard -types;

# VERSION

our @EXPORT = qw(
    ARRAY
    CODE
    HASH
    INTEGER
    NUMBER
    OBJECT
    STRING
    UNDEF
    USERAGENT
    URL
);

declare "ARRAY",
    as Types::Standard::ArrayRef;

declare "CODE",
    as Types::Standard::CodeRef;

declare "HASH",
    as Types::Standard::HashRef;

declare "INTEGER",
    as Types::Standard::Int;

declare "NUMBER",
    as Types::Standard::Num;

declare "OBJECT",
    as Types::Standard::Object;

declare "STRING",
    as Types::Standard::Str;

declare "UNDEF",
    as Types::Standard::Undef;

sub iface_type {
    my ($name, %opts) = @_;

    if (defined $name) {
        $opts{name} = $name unless exists $opts{name};
        $opts{name} =~ s/:://g;
    }

    my @cans = ref($opts{can})  eq 'ARRAY' ? @{$opts{can}}  : $opts{can}  // ();
    my @isas = ref($opts{isa})  eq 'ARRAY' ? @{$opts{isa}}  : $opts{isa}  // ();
    my @does = ref($opts{does}) eq 'ARRAY' ? @{$opts{does}} : $opts{does} // ();

    my $code = $opts{constraint} // sub { 1 };

    $opts{constraint} = sub {
        my @args = @_;
        return if @isas and grep(not($args[0]->isa($_)),  @isas);
        return if @cans and grep(not($args[0]->can($_)),  @cans);
        return if @does and grep(not($args[0]->does($_)), @does);
        return if not $code->(@args);
        return 1;
    };

    $opts{bless}  = "Type::Tiny";
    $opts{parent} = "OBJECT" unless $opts{parent};

    { no warnings "numeric"; $opts{_caller_level}++ }

    return declare(%opts);
}

iface_type "URL",
    isa => 'Mojo::URL',
    can => [qw(scheme userinfo host port path query fragment)];

iface_type "USERAGENT",
    isa => 'Mojo::UserAgent',
    can => [qw(delete get head options patch post put)];

1;
