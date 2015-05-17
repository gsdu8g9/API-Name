package API::Name::Class;

use Extorter;

# VERSION

sub import {
    my $class  = shift;
    my $target = caller;

    $class->extort::into($target, '*Data::Object::Class');
    $class->extort::into($target, '*API::Name::Signature');
    $class->extort::into($target, '*API::Name::Type');

    return;
}

1;
