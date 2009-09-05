use strict;
use warnings;
use inc::Module::Install 0.75;

if ($Module::Install::AUTHOR) {
    require Module::Install::AuthorRequires;
    require Module::Install::AuthorTests;
}

name 'MooseX-Getopt';
license 'perl';

all_from 'lib/MooseX/Getopt.pm';

requires 'Moose'        => '0.56';
requires 'Getopt::Long' => '2.37';

# optional
requires 'Getopt::Long::Descriptive' => '0.077';

build_requires 'Test::Moose';
build_requires 'Test::More'       => '0.62';
build_requires 'Test::Exception'  => '0.21';

author_requires 'Test::Pod' => 1.14;
author_requires 'Test::Pod::Coverage' => '1.04';
author_tests('t/author');

resources repository => 'git://git.moose.perl.org/MooseX-Getopt.git';

auto_manifest();

WriteAll;
