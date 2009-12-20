use strict;
use warnings;
use Test::More 0.88;
use Test::Exception;

{
    package MyScript;
    use Mouse;

    with 'MouseX::Getopt';

    has foo => ( isa => 'Int', is => 'ro', documentation => 'A foo' );
    has help => ( isa => 'Bool', is => 'ro', default => 0, documentation => 'Help');

    our $usage = 0;
    before _getopt_full_usage => sub { $usage++; };
    our @warnings;
    before _getopt_spec_warnings => sub { shift; push(@warnings, @_) };
    our @exception;
    before _getopt_spec_exception => sub { shift; push(@exception, @{ shift() }, shift()) };
}
{
    local $MyScript::usage; local @MyScript::warnings; local @MyScript::exception;
    local @ARGV = ('--foo', '1');
    my $i = MyScript->new_with_options;
    ok $i;
    is $i->foo, 1;
    is $MyScript::usage, undef;
}
{
    local $MyScript::usage; local @MyScript::warnings; local @MyScript::exception;
    local @ARGV = ('--help');
    throws_ok { MyScript->new_with_options } qr/A foo/;
    is $MyScript::usage, 1;
}
{
    local $MyScript::usage; local @MyScript::warnings; local @MyScript::exception;
    local @ARGV = ('-q'); # Does not exist
    throws_ok { MyScript->new_with_options } qr/A foo/;
    is_deeply \@MyScript::warnings, [
          'Unknown option: q
'
    ];
    my $exp = [
         'Unknown option: q
',
         qq{usage: 104_override_usage.t [long options...]
\t--help     Help
\t--foo      A foo
}
     ];

     local $TODO = 'The order is different from MooseX::Getopt';
     is_deeply \@MyScript::exception, $exp;
}

done_testing;

