use inc::Module::Install 0.75;

name 'MooseX-Getopt';
license 'perl';

all_from 'lib/MooseX/Getopt.pm';

requires 'Moose'        => '0.56';
requires 'Getopt::Long' => '2.37';

# optional
requires 'Getopt::Long::Descriptive' => 0;

test_requires 'Test::Moose';
build_requires 'Test::More'       => '0.62';
build_requires 'Test::Exception'  => '0.21';

tests_recursive();
auto_manifest();

WriteAll;
