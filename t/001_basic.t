#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 37;

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
    
    has 'libs' => (
        is      => 'ro',
        isa     => 'ArrayRef',
        default => sub { [] },
    ); 
    
    has 'details' => (
        is      => 'ro',
        isa     => 'HashRef',
        default => sub { {} },
    );    
  
}

{
    local @ARGV = ();

    my $app = App->new_with_options;
    isa_ok($app, 'App');

    ok(!$app->verbose, '... verbosity is off as expected');
    is($app->length, 24, '... length is 24 as expected');    
    is($app->data, 'file.dat', '... data is file.dat as expected');        
    is_deeply($app->libs, [], '... libs is [] as expected'); 
    is_deeply($app->details, {}, '... details is {} as expected');           
}

{
    local @ARGV = ('--verbose', '--length', 50);

    my $app = App->new_with_options;
    isa_ok($app, 'App');

    ok($app->verbose, '... verbosity is turned on as expected');
    is($app->length, 50, '... length is 50 as expected');    
    is($app->data, 'file.dat', '... data is file.dat as expected'); 
    is_deeply($app->libs, [], '... libs is [] as expected');  
    is_deeply($app->details, {}, '... details is {} as expected');                            
}

{
    local @ARGV = ('--verbose', '-f', 'foo.txt');

    my $app = App->new_with_options;
    isa_ok($app, 'App');

    ok($app->verbose, '... verbosity is turned on as expected');
    is($app->length, 24, '... length is 24 as expected');    
    is($app->data, 'foo.txt', '... data is foo.txt as expected'); 
    is_deeply($app->libs, [], '... libs is [] as expected');    
    is_deeply($app->details, {}, '... details is {} as expected');                             
}

{
    local @ARGV = ('--verbose', '--libs', 'libs/', '--libs', 'includes/lib');

    my $app = App->new_with_options;
    isa_ok($app, 'App');

    ok($app->verbose, '... verbosity is turned on as expected');
    is($app->length, 24, '... length is 24 as expected');    
    is($app->data, 'file.dat', '... data is foo.txt as expected'); 
    is_deeply($app->libs, 
    ['libs/', 'includes/lib'], 
    '... libs is [libs/, includes/lib] as expected');   
    is_deeply($app->details, {}, '... details is {} as expected');                              
}

{
    local @ARGV = ('--details', 'os=mac', '--details', 'name=foo');

    my $app = App->new_with_options;
    isa_ok($app, 'App');

    ok(!$app->verbose, '... verbosity is turned on as expected');
    is($app->length, 24, '... length is 24 as expected');    
    is($app->data, 'file.dat', '... data is foo.txt as expected'); 
    is_deeply($app->libs, [], '... libs is [] as expected');    
    is_deeply($app->details, 
    { os => 'mac', name => 'foo' }, 
    '... details is { os => mac, name => foo } as expected');                              
}

{
    # Test negation on booleans too ...
    local @ARGV = ('--noverbose');

    my $app = App->new_with_options;
    isa_ok($app, 'App');

    ok(!$app->verbose, '... verbosity is turned off as expected');
    is($app->length, 24, '... length is 24 as expected');    
    is($app->data, 'file.dat', '... file is file.dat as expected');   
    is_deeply($app->libs, [], '... libs is [] as expected');                
    is_deeply($app->details, {}, '... details is {} as expected');               
}



