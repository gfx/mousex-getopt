
package MooseX::Getopt::OptionTypes;
# this maps option types to Moose types

my %option_types = (
    'Bool'     => '!',
    'Str'      => '=s',
    'Int'      => '=i',
    'Float'    => '=f',
    'ArrayRef' => '=s@',
);

sub has_option_type { exists $option_types{$_[1]} }
sub get_option_type {        $option_types{$_[1]} }

1;

__END__


=pod

=head1 NAME

MooseX::Getopt::OptionTypes - 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<has_option_type>

=item B<get_option_type>

=item B<add_option_type>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut