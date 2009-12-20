package MouseX::Getopt::Dashes;
use Mouse::Role;

with 'MouseX::Getopt';

around _get_cmd_flags_for_attr => sub {
    my $next = shift;
    my ( $class, $attr, @rest ) = @_;

    my ( $flag, @aliases ) = $class->$next($attr, @rest);
    $flag =~ tr/_/-/
        unless $attr->does('MouseX::Getopt::Meta::Attribute::Trait')
            && $attr->has_cmd_flag;

    return ( $flag, @aliases );
};

1;

__END__

=pod

=head1 NAME

MouseX::Getopt::Dashes - convert underscores in attribute names to dashes

=head1 SYNOPSIS

  package My::App;
  use Mouse;
  with 'MouseX::Getopt::Dashes';

  # use as MouseX::Getopt

=head1 DESCRIPTION

This is a version of C<MouseX::Getopt> which converts underscores in
attribute names to dashes when generating command line flags.

=head1 METHODS

=over 4

=item meta

=back

=head1 SEE ALSO

L<MouseX::Getopt>

=cut
