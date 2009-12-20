use strict;
use warnings;
use inc::Module::Install 0.91;

if ($Module::Install::AUTHOR) {
    require Module::Install::AuthorRequires;
    require Module::Install::AuthorTests;
    require Module::Install::Repository;
}

all_from 'lib/MouseX/Getopt.pm';

requires 'Mouse'        => '0.45';
requires 'Getopt::Long' => '2.37';

# optional
test_requires 'Getopt::Long::Descriptive' => '0.077';

build_requires 'Test::Mouse';
build_requires 'Test::More'       => '0.62';
build_requires 'Test::Exception'  => '0.21';

author_requires 'Test::Pod' => 1.14;
author_requires 'Test::Pod::Coverage' => '1.04';
author_tests('t/author');

auto_set_repository();

auto_manifest();

WriteAll(check_nmake => 0);
