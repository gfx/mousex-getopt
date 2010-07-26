package MouseX::Getopt::GLD;
# ABSTRACT: A Mouse role for processing command line options with Getopt::Long::Descriptive

use Mouse::Role;

use Getopt::Long::Descriptive 0.081;

with 'MouseX::Getopt::Basic';

has usage => (
    is => 'rw', isa => 'Getopt::Long::Descriptive::Usage',
    traits => ['NoGetopt'],
);

# captures the options: --help --usage --?
has help_flag => (
    is => 'ro', isa => 'Bool',
    traits => ['Getopt'],
    cmd_flag => 'help',
    cmd_aliases => [ qw(usage ?) ],
    documentation => 'Prints this usage information.',
);

around _getopt_spec => sub {
    shift;
    shift->_gld_spec(@_);
};

around _getopt_get_options => sub {
    shift;
    my ($class, $params, $opt_spec) = @_;
    return Getopt::Long::Descriptive::describe_options($class->_usage_format(%$params), @$opt_spec);
};

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
                # since Mouse will handle the defaults just
                # fine anyway.
                # - SL
                #( exists $opt->{default}  ? (default  => $opt->{default})  : () ),
            },
        ];

        my $identifier = lc($opt->{name});
        $identifier =~ s/\W/_/g; # Getopt::Long does this to all option names

        $name_to_init_arg{$identifier} = $opt->{init_arg};
    }

    return ( \@options, \%name_to_init_arg );
}

no Mouse::Role;

1;

=head1 SYNOPSIS

  ## In your class
  package My::App;
  use Mouse;

  with 'MouseX::Getopt::GLD';

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

=cut
