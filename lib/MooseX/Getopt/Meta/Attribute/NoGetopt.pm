package MooseX::Getopt::Meta::Attribute::NoGetopt;
# ABSTRACT: Optional meta attribute for ignoring params

use Moose;

extends 'Moose::Meta::Attribute'; # << Moose extending Moose :)
   with 'MooseX::Getopt::Meta::Attribute::Trait::NoGetopt';

no Moose;

# register this as a metaclass alias ...
package # stop confusing PAUSE
    Moose::Meta::Attribute::Custom::NoGetopt;
sub register_implementation { 'MooseX::Getopt::Meta::Attribute::NoGetopt' }

1;

=head1 SYNOPSIS

  package App;
  use Moose;

  with 'MooseX::Getopt';

  has 'data' => (
      metaclass => 'NoGetopt',  # do not attempt to capture this param
      is        => 'ro',
      isa       => 'Str',
      default   => 'file.dat',
  );

=head1 DESCRIPTION

This is a custom attribute metaclass which can be used to specify
that a specific attribute should B<not> be processed by
C<MooseX::Getopt>. All you need to do is specify the C<NoGetopt>
metaclass.

  has 'foo' => (metaclass => 'NoGetopt', ... );

=cut
