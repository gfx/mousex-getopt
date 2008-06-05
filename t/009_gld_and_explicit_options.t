#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 5;
use Test::Exception;

BEGIN { use_ok('MooseX::Getopt') }

{
    package Testing::Foo;
    use Moose;
    
    with 'MooseX::Getopt';
    
    has 'bar' => (
        is       => 'ro',
        isa      => 'Int',   
        required => 1,
    );
    
    has 'baz' => (
        is       => 'ro',
        isa      => 'Int',   
        required => 1,        
    );    
}

@ARGV = qw(--bar 10);

my $foo;
lives_ok {
    $foo = Testing::Foo->new_with_options(baz => 100);
} '... this should work';
isa_ok($foo, 'Testing::Foo');

is($foo->bar, 10, '... got the right values');
is($foo->baz, 100, '... got the right values');





