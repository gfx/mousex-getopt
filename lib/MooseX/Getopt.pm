
package MooseX::Getopt;
use Moose::Role;

use MooseX::Getopt::OptionTypeMap;
use MooseX::Getopt::Meta::Attribute;
use MooseX::Getopt::Meta::Attribute::NoGetopt;

use Carp ();

use Getopt::Long (); # GLD uses it anyway, doesn't hurt
use constant HAVE_GLD => not not eval { require Getopt::Long::Descriptive };

our $VERSION   = '0.14';
our $AUTHORITY = 'cpan:STEVAN';

has ARGV       => (is => 'rw', isa => 'ArrayRef', metaclass => "NoGetopt");
has extra_argv => (is => 'rw', isa => 'ArrayRef', metaclass => "NoGetopt");

sub new_with_options {
    my ($class, @params) = @_;

    my $config_from_file;
    if($class->meta->does_role('MooseX::ConfigFromFile')) {
        local @ARGV = @ARGV;

        my $configfile;
        my $opt_parser = Getopt::Long::Parser->new( config => [ qw( pass_through ) ] );
        $opt_parser->getoptions( "configfile=s" => \$configfile );

        if(!defined $configfile) {
            my $cfmeta = $class->meta->find_attribute_by_name('configfile');
            $configfile = $cfmeta->default if $cfmeta->has_default;
        }

        if(defined $configfile) {
            $config_from_file = $class->get_config_from_file($configfile);
        }
    }

    my $constructor_params = ( @params == 1 ? $params[0] : {@params} );
    
    Carp::croak("Single parameters to new_with_options() must be a HASH ref")
        unless ref($constructor_params) eq 'HASH';

    my %processed = $class->_parse_argv(
        options => [
            $class->_attrs_to_options( $config_from_file )
        ],
        params => $constructor_params,
    );

    my $params = $config_from_file ? { %$config_from_file, %{$processed{params}} } : $processed{params};

    $class->new(
        ARGV       => $processed{argv_copy},
        extra_argv => $processed{argv},
        @params, # explicit params to ->new
        %$params, # params from CLI
    );
}

sub _parse_argv {
    my ( $class, %params ) = @_;

    local @ARGV = @{ $params{argv} || \@ARGV };

    my ( $opt_spec, $name_to_init_arg ) = ( HAVE_GLD ? $class->_gld_spec(%params) : $class->_traditional_spec(%params) );

    # Get a clean copy of the original @ARGV
    my $argv_copy = [ @ARGV ];

    my @err;

    my ( $parsed_options, $usage ) = eval {
        local $SIG{__WARN__} = sub { push @err, @_ };

        if ( HAVE_GLD ) {
            return Getopt::Long::Descriptive::describe_options($class->_usage_format(%params), @$opt_spec);
        } else {
            my %options;
            Getopt::Long::GetOptions(\%options, @$opt_spec);
            return ( \%options, undef );
        }
    };

    die join "", grep { defined } @err, $@ if @err or $@;

    # Get a copy of the Getopt::Long-mangled @ARGV
    my $argv_mangled = [ @ARGV ];

    my %constructor_args = (
        map {
            $name_to_init_arg->{$_} => $parsed_options->{$_}
        } keys %$parsed_options,
    );

    return (
        params    => \%constructor_args,
        argv_copy => $argv_copy,
        argv      => $argv_mangled,
        ( defined($usage) ? ( usage => $usage ) : () ),
    );
}

sub _usage_format {
    return "usage: %c %o";
}

sub _traditional_spec {
    my ( $class, %params ) = @_;

    my ( @options, %name_to_init_arg, %options );

    foreach my $opt ( @{ $params{options} } ) {
        push @options, $opt->{opt_string};

        my $identifier = $opt->{name};
        $identifier =~ s/\W/_/g; # Getopt::Long does this to all option names

        $name_to_init_arg{$identifier} = $opt->{init_arg};
    }

    return ( \@options, \%name_to_init_arg );
}

sub _gld_spec {
    my ( $class, %params ) = @_;

    my ( @options, %name_to_init_arg );

    my $constructor_params = $params{params};

    foreach my $opt ( @{ $params{options} } ) {
        push @options, [
            $opt->{opt_string},
            $opt->{doc} || ' ', # FIXME new GLD shouldn't need this hack
            {
                ( ( $opt->{required} && !exists($constructor_params->{$opt->{init_arg}}) ) ? (required => $opt->{required}) : () ),
                # NOTE:
                # remove this 'feature' because it didn't work 
                # all the time, and so is better to not bother
                # since Moose will handle the defaults just 
                # fine anyway.
                # - SL
                #( exists $opt->{default}  ? (default  => $opt->{default})  : () ),
            },
        ];

        my $identifier = $opt->{name};
        $identifier =~ s/\W/_/g; # Getopt::Long does this to all option names

        $name_to_init_arg{$identifier} = $opt->{init_arg};
    }

    return ( \@options, \%name_to_init_arg );
}

sub _compute_getopt_attrs {
    my $class = shift;
    grep {
        $_->does("MooseX::Getopt::Meta::Attribute::Trait")
            or
        $_->name !~ /^_/
    } grep {
        !$_->does('MooseX::Getopt::Meta::Attribute::Trait::NoGetopt')
    } $class->meta->compute_all_applicable_attributes
}

sub _get_cmd_flags_for_attr {
    my ( $class, $attr ) = @_;

    my $flag = $attr->name;

    my @aliases;

    if ($attr->does('MooseX::Getopt::Meta::Attribute::Trait')) {
        $flag = $attr->cmd_flag if $attr->has_cmd_flag;
        @aliases = @{ $attr->cmd_aliases } if $attr->has_cmd_aliases;
    }

    return ( $flag, @aliases );
}

sub _attrs_to_options {
    my $class = shift;
    my $config_from_file = shift || {};

    my @options;

    foreach my $attr ($class->_compute_getopt_attrs) {
        my ( $flag, @aliases ) = $class->_get_cmd_flags_for_attr($attr);

        my $opt_string = join(q{|}, $flag, @aliases);

        if ($attr->has_type_constraint) {
            my $type = $attr->type_constraint;
            if (MooseX::Getopt::OptionTypeMap->has_option_type($type)) {
                $opt_string .= MooseX::Getopt::OptionTypeMap->get_option_type($type)
            }
        }

        push @options, {
            name       => $flag,
            init_arg   => $attr->init_arg,
            opt_string => $opt_string,
            required   => $attr->is_required && !$attr->has_default && !$attr->has_builder && !exists $config_from_file->{$attr->name},
            # NOTE:
            # this "feature" was breaking because 
            # Getopt::Long::Descriptive would return 
            # the default value as if it was a command 
            # line flag, which would then override the
            # one passed into a constructor.
            # See 100_gld_default_bug.t for an example
            # - SL
            #( ( $attr->has_default && ( $attr->is_default_a_coderef xor $attr->is_lazy ) ) ? ( default => $attr->default({}) ) : () ),
            ( $attr->has_documentation ? ( doc => $attr->documentation ) : () ),
        }
    }

    return @options;
}

no Moose::Role; 1;

__END__

=pod

=head1 NAME

MooseX::Getopt - A Moose role for processing command line options

=head1 SYNOPSIS

  ## In your class
  package My::App;
  use Moose;

  with 'MooseX::Getopt';

  has 'out' => (is => 'rw', isa => 'Str', required => 1);
  has 'in'  => (is => 'rw', isa => 'Str', required => 1);

  # ... rest of the class here

  ## in your script
  #!/usr/bin/perl

  use My::App;

  my $app = My::App->new_with_options();
  # ... rest of the script here

  ## on the command line
  % perl my_app_script.pl -in file.input -out file.dump

=head1 DESCRIPTION

This is a role which provides an alternate constructor for creating
objects using parameters passed in from the command line.

This module attempts to DWIM as much as possible with the command line
params by introspecting your class's attributes. It will use the name
of your attribute as the command line option, and if there is a type
constraint defined, it will configure Getopt::Long to handle the option
accordingly.

You can use the trait L<MooseX::Getopt::Meta::Attribute::Trait> or the
attribute metaclass L<MooseX::Getopt::Meta::Attribute> to get non-default
commandline option names and aliases.

You can use the trait L<MooseX::Getopt::Meta::Attribute::Trait::NoGetopt>
or the attribute metaclass L<MooseX::Getopt::Meta::Attribute::NoGetopt>
to have C<MooseX::Getopt> ignore your attribute in the commandline options.

By default, attributes which start with an underscore are not given
commandline argument support, unless the attribute's metaclass is set
to L<MooseX::Getopt::Meta::Attribute>. If you don't want you accessors
to have the leading underscore in thier name, you can do this:

  # for read/write attributes
  has '_foo' => (accessor => 'foo', ...);

  # or for read-only attributes
  has '_bar' => (reader => 'bar', ...);

This will mean that Getopt will not handle a --foo param, but your
code can still call the C<foo> method.

If your class also uses a configfile-loading role based on
L<MooseX::ConfigFromFile>, such as L<MooseX::SimpleConfig>,
L<MooseX::Getopt>'s C<new_with_options> will load the configfile
specified by the C<--configfile> option (or the default you've
given for the configfile attribute) for you.

Options specified in multiple places follow the following
precendence order: commandline overrides configfile, which
overrides explicit new_with_options parameters.

=head2 Supported Type Constraints

=over 4

=item I<Bool>

A I<Bool> type constraint is set up as a boolean option with
Getopt::Long. So that this attribute description:

  has 'verbose' => (is => 'rw', isa => 'Bool');

would translate into C<verbose!> as a Getopt::Long option descriptor,
which would enable the following command line options:

  % my_script.pl --verbose
  % my_script.pl --noverbose

=item I<Int>, I<Float>, I<Str>

These type constraints are set up as properly typed options with
Getopt::Long, using the C<=i>, C<=f> and C<=s> modifiers as appropriate.

=item I<ArrayRef>

An I<ArrayRef> type constraint is set up as a multiple value option
in Getopt::Long. So that this attribute description:

  has 'include' => (
      is      => 'rw',
      isa     => 'ArrayRef',
      default => sub { [] }
  );

would translate into C<includes=s@> as a Getopt::Long option descriptor,
which would enable the following command line options:

  % my_script.pl --include /usr/lib --include /usr/local/lib

=item I<HashRef>

A I<HashRef> type constraint is set up as a hash value option
in Getopt::Long. So that this attribute description:

  has 'define' => (
      is      => 'rw',
      isa     => 'HashRef',
      default => sub { {} }
  );

would translate into C<define=s%> as a Getopt::Long option descriptor,
which would enable the following command line options:

  % my_script.pl --define os=linux --define vendor=debian

=back

=head2 Custom Type Constraints

It is possible to create custom type constraint to option spec
mappings if you need them. The process is fairly simple (but a
little verbose maybe). First you create a custom subtype, like
so:

  subtype 'ArrayOfInts'
      => as 'ArrayRef'
      => where { scalar (grep { looks_like_number($_) } @$_)  };

Then you register the mapping, like so:

  MooseX::Getopt::OptionTypeMap->add_option_type_to_map(
      'ArrayOfInts' => '=i@'
  );

Now any attribute declarations using this type constraint will
get the custom option spec. So that, this:

  has 'nums' => (
      is      => 'ro',
      isa     => 'ArrayOfInts',
      default => sub { [0] }
  );

Will translate to the following on the command line:

  % my_script.pl --nums 5 --nums 88 --nums 199

This example is fairly trivial, but more complex validations are
easily possible with a little creativity. The trick is balancing
the type constraint validations with the Getopt::Long validations.

Better examples are certainly welcome :)

=head2 Inferred Type Constraints

If you define a custom subtype which is a subtype of one of the
standard L</Supported Type Constraints> above, and do not explicitly
provide custom support as in L</Custom Type Constraints> above,
MooseX::Getopt will treat it like the parent type for Getopt
purposes.

For example, if you had the same custom C<ArrayOfInts> subtype
from the examples above, but did not add a new custom option
type for it to the C<OptionTypeMap>, it would be treated just
like a normal C<ArrayRef> type for Getopt purposes (that is,
C<=s@>).

=head1 METHODS

=over 4

=item B<new_with_options (%params)>

This method will take a set of default C<%params> and then collect
params from the command line (possibly overriding those in C<%params>)
and then return a newly constructed object.

If L<Getopt::Long/GetOptions> fails (due to invalid arguments),
C<new_with_options> will throw an exception.

If you have L<Getopt::Long::Descriptive> a the C<usage> param is also passed to
C<new>.

=item B<ARGV>

This accessor contains a reference to a copy of the C<@ARGV> array
as it originally existed at the time of C<new_with_options>.

=item B<extra_argv>

This accessor contains an arrayref of leftover C<@ARGV> elements that
L<Getopt::Long> did not parse.  Note that the real C<@ARGV> is left
un-mangled.

=item B<meta>

This returns the role meta object.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

Brandon L. Black, E<lt>blblack@gmail.comE<gt>

Yuval Kogman, E<lt>nothingmuch@woobling.orgE<gt>

=head1 CONTRIBUTORS

Ryan D Johnson, E<lt>ryan@innerfence.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2008 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
