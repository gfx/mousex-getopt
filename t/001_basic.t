#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;

BEGIN {
    use_ok('MooseX::Getopt');
}

{
    package App;
    use Moose;
    
    with 'MooseX::Getopt';

    has 'data' => (
        metaclass => 'MooseX::Getopt::Meta::Attribute',        
        is        => 'ro',
        isa       => 'Str',
        default   => 'file.dat',
        cmd_flag  => 'f',
    );

    has 'length' => (
        is      => 'ro',
        isa     => 'Int',
        default => 24
    );

    has 'verbose' => (
        is     => 'ro',
        isa    => 'Bool',       
    ); 
  
}

{
    local @ARGV = ();

    my $app = App->new_with_options;
    isa_ok($app, 'App');

    ok(!$app->verbose, '... verbosity is off as expected');
    is($app->length, 24, '... length is 24 as expected');    
    is($app->data, 'file.dat', '... data is file.dat as expected');        
}

{
    local @ARGV = ('-verbose', '-length', 50);

    my $app = App->new_with_options;
    isa_ok($app, 'App');

    ok($app->verbose, '... verbosity is turned on as expected');
    is($app->length, 50, '... length is 50 as expected');    
    is($app->data, 'file.dat', '... data is file.dat as expected');     
}

{
    local @ARGV = ('-verbose', '-f', 'foo.txt');

    my $app = App->new_with_options;
    isa_ok($app, 'App');

    ok($app->verbose, '... verbosity is turned on as expected');
    is($app->length, 24, '... length is 24 as expected');    
    is($app->data, 'foo.txt', '... data is foo.txt as expected');        
}

{
    local @ARGV = ('-noverbose');

    my $app = App->new_with_options;
    isa_ok($app, 'App');

    ok(!$app->verbose, '... verbosity is turned off as expected');
    is($app->length, 24, '... length is 24 as expected');    
    is($app->data, 'file.dat', '... file is file.dat as expected');        
}



