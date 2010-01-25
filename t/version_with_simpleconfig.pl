package WithOptionsAndSimpleConfig;
use Moose;

with 'MooseX::Getopt';

has print_version => (
    traits        => [qw(Getopt)],
    isa           => 'Bool',
    is            => 'ro',
    cmd_flag      => 'version',
    cmd_aliases   => 'v',
);

has configfile => (
    traits => [qw(NoGetopt)],
    isa    => 'Str',
    coerce => 1,
    is     => 'ro',
);

with 'MooseX::SimpleConfig';

sub run {
    my ($self) = @_;

    if ($self->print_version) {
        print "SUCCESS\n";
        exit;
    }
}

package main;
WithOptionsAndSimpleConfig->new_with_options;
