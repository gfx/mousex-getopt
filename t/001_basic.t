#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 47;

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

    has 'cow' => (
        metaclass   => 'MooseX::Getopt::Meta::Attribute',        
        is          => 'ro',
        isa         => 'Str',
        default     => 'moo',
        cmd_aliases => [qw/ moocow m c /],
    );

    has 'horse' => (
        metaclass   => 'MooseX::Getopt::Meta::Attribute',        
        is          => 'ro',
        isa         => 'Str',
        default     => 'bray',
        cmd_flag    => 'horsey',
        cmd_aliases => 'x',
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

# Test cmd_alias without cmd_flag
{
    local @ARGV = ('--cow', '42');
    my $app = App->new_with_options;
    isa_ok($app, 'App');
    is($app->cow, 42, 'cmd_alias, but not using it');
}
{
    local @ARGV = ('--moocow', '88');
    my $app = App->new_with_options;
    isa_ok($app, 'App');
    is($app->cow, 88, 'cmd_alias, using long one');
}
{
    local @ARGV = ('-c', '99');
    my $app = App->new_with_options;
    isa_ok($app, 'App');
    is($app->cow, 99, 'cmd_alias, using short one');
}

# Test cmd_alias + cmd_flag
{
    local @ARGV = ('--horsey', '123');
    my $app = App->new_with_options;
    isa_ok($app, 'App');
    is($app->horse, 123, 'cmd_alias+cmd_flag, using flag');
}
{
    local @ARGV = ('-x', '321');
    my $app = App->new_with_options;
    isa_ok($app, 'App');
    is($app->horse, 321, 'cmd_alias+cmd_flag, using alias');
}
