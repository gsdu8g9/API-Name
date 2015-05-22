requires "Data::Object" => "0.17";
requires "Extorter" => "0.10";
requires "Function::Parameters" => "1.0603";
requires "Mojolicious" => "6.08";
requires "Type::Tiny" => "1.000005";
requires "perl" => "v5.14.2";

on 'test' => sub {
  requires "perl" => "v5.14.2";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};
