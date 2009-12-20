
package MouseX::Getopt::Strict;
use Mouse::Role;

with 'MouseX::Getopt';

around '_compute_getopt_attrs' => sub {
    my $next = shift;
    my ( $class, @args ) = @_;
    grep { 
        $_->isa("MouseX::Getopt::Meta::Attribute") 
    } $class->$next(@args);
};

1;

__END__

=pod

=head1 NAME

MouseX::Getopt::Strict - only make options for attrs with the Getopt metaclass
    
=head1 DESCRIPTION

This is an stricter version of C<MouseX::Getopt> which only processes the 
attributes if they explicitly set as C<Getopt> attributes. All other attributes
are ignored by the command line handler.
    
=head1 METHODS

=over 4

=item meta

=back

=head1 SEE ALSO

L<MouseX::Getopt>

=cut
