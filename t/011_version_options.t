use strict;
use warnings;
use Capture::Tiny 'capture';
use File::Spec::Functions 'catfile';
use Test::More;

my $HAVE_SIMPLECONFIG = eval {
    require MooseX::SimpleConfig;
    return 1;
};

# none of the options should be known
for my $opt (qw(-v --version -V)) {
    my $script = catfile('t', 'version_no_options.pl');
    my (undef, $stderr) = capture { system $^X, $script, $opt };
    like($stderr, qr/^Unknown option/, "Option $opt is unknown");
}

# only -V should be unknown, the other two should return our custom string
for my $test (qw(version_with_options.pl version_with_simpleconfig.pl)) {
    my $script = catfile('t', $test);

    SKIP: {
        if ($test eq 'version_with_simpleconfig.pl' && !$HAVE_SIMPLECONFIG) {
            skip('MooseX::SimpleConfig unavailable', 3);
        }

        my ($v, undef) = capture { system $^X, $script, '-v' };
        like($v, qr/^SUCCESS/, "Option -v is correct");

        my ($version, undef) = capture { system $^X, $script, '--version' };
        like($version, qr/^SUCCESS/, "Option --version is correct");

        my (undef, $V) = capture { system $^X, $script, '-V' };
        like($V, qr/^Unknown option/, "Option -V is unknown");
    }
}

done_testing();
