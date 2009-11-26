use strict;
use warnings;
use Test::More 0.88;
use Test::Exception;

{
    package MyScript;
    use Moose;

    with 'MooseX::Getopt';

    has foo => ( isa => 'Int', is => 'ro', documentation => 'A foo' );
    has help => ( isa => 'Bool', is => 'ro', default => 0, documentation => 'Help');

    our $usage = 0;
    before _getopt_full_usage => sub { $usage++; };
}
{
    local @ARGV = ('--foo', '1');
    my $i = MyScript->new_with_options;
    ok $i;
    is $i->foo, 1;
    is $MyScript::usage, 0;
}
{
    local @ARGV = ('--help');
    throws_ok { MyScript->new_with_options } qr/A foo/;
    is $MyScript::usage, 1;
}
done_testing;

