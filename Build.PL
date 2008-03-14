use Module::Build;

use strict;

my $build = Module::Build->new(
    module_name => 'MooseX::Getopt',
    license => 'perl',
    requires => {   
        'Moose'        => '0.39',
        'Getopt::Long' => '2.34',
    },
    optional => {
        'Getopt::Long::Descriptive' => 0,
    },
    build_requires => {
        'Test::More'       => '0.62',
        'Test::Exception'  => '0.21',
    },
    create_makefile_pl => 'traditional',
    recursive_test_files => 1,
    add_to_cleanup => [
        'META.yml', '*.bak', '*.gz', 'Makefile.PL',
    ],
);

$build->create_build_script;

