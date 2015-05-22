# Name Exception Class
package API::Name::Exception;

use Data::Dumper ();
use Scalar::Util ();

use API::Name::Class;

use overload fallback => 1, '""' => 'to_string';

# VERSION

has 'code',   is => 'ro';
has 'method', is => 'ro';
has 'res',    is => 'ro';
has 'url',    is => 'ro';

method caught ($e) {
    return ! Scalar::Util::blessed($e)
        && UNIVERSAL::isa($e, $self);
}

method dumper {
    local $Data::Dumper::Terse = 1;
    return Data::Dumper::Dumper($self);
}

method rethrow {
    die $self;
}

fun throw ($class, %args) {
    die $class->new(%args,
        subroutine => (caller(1))[3],
        package    => (caller(0))[0],
        file       => (caller(0))[1],
        line       => (caller(0))[2],
    );
}

method to_string {
    return sprintf "%s response received while processing request %s %s\n",
        $self->code, $self->method, $self->url;
}

1;
