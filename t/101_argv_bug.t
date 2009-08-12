#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 7;

BEGIN {
    # TEST
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
        metaclass   => 'Getopt',        
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

    has '_private_stuff' => (
        is      => 'ro',
        isa     => 'Int',
        default => 713
    );

    has '_private_stuff_cmdline' => (
        metaclass => 'MooseX::Getopt::Meta::Attribute',        
        is        => 'ro',
        isa       => 'Int',
        default   => 832,
        cmd_flag  => 'p',
    );
  
}

{
    my $app = App->new_with_options(argv => [ '--verbose', '--length', 50 ]);
    # TEST
    isa_ok($app, 'App');

    # TEST
    ok($app->verbose, '... verbosity is turned on as expected');
    # TEST
    is($app->length, 50, '... length is 50 as expected');    
    # TEST
    is($app->data, 'file.dat', '... data is file.dat as expected'); 
    # TEST
    is_deeply($app->libs, [], '... libs is [] as expected');  
    # TEST
    is_deeply($app->details, {}, '... details is {} as expected');                            
}

