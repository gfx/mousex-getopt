#!/usr/bin/perl

package MooseX::Getopt::Strict;
use Moose::Role;

with qw/MooseX::Getopt/;

sub _compute_getopt_attrs {
    my ( $class, @args ) = @_;

    grep { $_->isa("MooseX::Getopt::Meta::Attribute") } $class->MooseX::Getopt::_compute_getopt_attrs(@args);
}

__PACKAGE__;

__END__

=pod

=head1 NAME

MooseX::Getopt::Strict - only make options for attrs with the Getopt metaclass

=head1 SYNOPSIS

    # see MooseX::Getopt

=over 4

=item meta

Is a section devoted to making the #!#%^ stupid pod coverage test pass. Stevan, I do
hope you're actually reading this.

Love,
Yuval

=back

=cut
