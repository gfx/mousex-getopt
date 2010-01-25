package WithOptions;
use Moose;

with 'MooseX::Getopt';

has print_version => (
    traits        => [qw(Getopt)],
    isa           => 'Bool',
    is            => 'ro',
    cmd_flag      => 'version',
    cmd_aliases   => 'v',
);

sub run {
    my ($self) = @_;

    if ($self->print_version) {
        print "SUCCESS\n";
        exit;
    }
}

package main;
WithOptions->new_with_options;
