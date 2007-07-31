
package MooseX::Getopt::Meta::NoGetopt;
use Moose;
use Moose::Util::TypeConstraints;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'Moose::Meta::Attribute'; # << Moose extending Moose :)

no Moose;

# register this as a metaclass alias ...
package Moose::Meta::Attribute::Custom::NoGetopt;
sub register_implementation { 'MooseX::Getopt::Meta::NoGetopt' }

1;