#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN {
    eval 'use Getopt::Long::Descriptive;';
    plan skip_all => "Getopt::Long::Descriptive required for this test" if $@;
    plan tests => 5;    
    use_ok('MouseX::Getopt');
}

{
    package Engine::Foo;
    use Mouse;
    
    with 'MouseX::Getopt';
    
    has 'nproc' => (
        metaclass   => 'Getopt',
        is          => 'ro',
        isa         => 'Int',
        default     => sub { 1 },
        cmd_aliases => 'n',
    );
}

@ARGV = ();

{
    my $foo = Engine::Foo->new_with_options(nproc => 10);
    isa_ok($foo, 'Engine::Foo');

    is($foo->nproc, 10, '... got the right value (10), not the default (1)');
}

{
    my $foo = Engine::Foo->new_with_options();
    isa_ok($foo, 'Engine::Foo');

    is($foo->nproc, 1, '... got the right value (1), without GLD needing to handle defaults');
}



