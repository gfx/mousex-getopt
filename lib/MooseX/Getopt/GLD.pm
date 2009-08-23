package MooseX::Getopt::GLD;

use Moose::Role;

around '_getopt_spec' => sub {
    my $orig = shift;
    my $self = shift;

    return $self->_gld_spec(@_);
    # Ignore $orig, code for _gld_spec here
};

around '_get_options' => sub {
    my $orig = shift;
    my $class = shift;

    my ($params, $opt_spec) = @_;
    return Getopt::Long::Descriptive::describe_options(
        $class->_usage_format(%$params), @$opt_spec
    );
};


sub _gld_spec {
    my ( $class, %params ) = @_;

    my ( @options, %name_to_init_arg );

    my $constructor_params = $params{params};

    foreach my $opt ( @{ $params{options} } ) {
        push @options, [
            $opt->{opt_string},
            $opt->{doc} || ' ', # FIXME new GLD shouldn't need this hack
            {
                ( ( $opt->{required} && !exists($constructor_params->{$opt->{init_arg}}) ) ? (required => $opt->{required}) : () ),
                # NOTE:
                # remove this 'feature' because it didn't work 
                # all the time, and so is better to not bother
                # since Moose will handle the defaults just 
                # fine anyway.
                # - SL
                #( exists $opt->{default}  ? (default  => $opt->{default})  : () ),
            },
        ];

        my $identifier = $opt->{name};
        $identifier =~ s/\W/_/g; # Getopt::Long does this to all option names

        $name_to_init_arg{$identifier} = $opt->{init_arg};
    }

    return ( \@options, \%name_to_init_arg );
}

1;

__END__

=pod

=head1 NAME

MooseX::Getopt::GLD - role to implement specific functionality for 
L<Getopt::Long::Descriptive>

=head1 SYNOPSIS
    
For internal use.

=head1 DESCRIPTION

This is a role for C<MooseX::Getopt>.

=head1 METHODS

=over 4

=item meta

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Dagfinn Ilmari MannsE<aring>ker E<lt>ilmari@ilmari.orgE<gt>

Stevan Little E<lt>stevan@iinteractive.comE<gt>

Yuval Kogman  C<< <nuffin@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2008 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
=head1 
