use strict;
use warnings;
use Test::More;
use Moose ();
use Moose::Meta::Class;

foreach my $role (qw/
    MooseX::Getopt
    MooseX::Getopt::GLD
    MooseX::Getopt::Basic
/) {
    Class::MOP::load_class($role);

    my $meta = Moose::Meta::Class->create_anon_class(
        superclasses => ['Moose::Object'],
    );
    $meta->add_attribute('Debug', traits => ['Getopt'], isa => 'Bool',
        cmd_aliases => ['d'], is => 'ro');
    $role->meta->apply($meta);

    ok($meta->name->new_with_options({ argv => ['-d'] })->Debug,
        "Debug was set for argv -d on $role");
    {
        local @ARGV = ('-d');
        ok($meta->name->new_with_options()->Debug,
            "Debug was set for ARGV on $role");
    }

    ok($meta->name->new_with_options({ argv => ['--Debug'] })->Debug,
        "Debug was set for argv --Debug on $role");

    ok($meta->name->new_with_options({ argv => ['--debug'] })->Debug,
        "Debug was set for argv --debug on $role");
}

done_testing;

