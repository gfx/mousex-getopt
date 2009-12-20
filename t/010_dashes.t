#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 3;

use Test::Exception;


BEGIN {
	use_ok('MouseX::Getopt');
}

{
	package App;
	use Mouse;

	with 'MouseX::Getopt::Dashes';

	has 'some_thingy' => ( is => 'ro', isa => 'Str', default => 'foo' );
}

{
	local @ARGV = (qw/--some-thingy bar/);
    lives_and { is( App->new_with_options->some_thingy, 'bar') } 'Dash in option name';
}

{
    local @ARGV = (qw/--some_thingy bar/);
    throws_ok { App->new_with_options } qr/Unknown option: some_thingy/;
}
