
package MooseX::Getopt;
use Moose::Role;

use Getopt::Long;

use MooseX::Getopt::OptionTypes;
use MooseX::Getopt::Meta::Attribute;

sub new_with_options {
    my ($class, %params) = @_;

    my (%options, %constructor_options);
    foreach my $attr ($class->meta->compute_all_applicable_attributes) {
        my $name = $attr->name;
        
        if ($attr->isa('MooseX::Getopt::Meta::Attribute') && $attr->has_cmd_flag) { 
            $name = $attr->cmd_flag;
        }
        
        my $init_arg = $attr->init_arg;
        
        # create a suitable default value 
        $constructor_options{$init_arg} = '';            
        
        if ($attr->has_type_constraint) {
            my $type_name = $attr->type_constraint->name;
            if (MooseX::Getopt::OptionTypes->has_option_type($type_name)) {                   
                $name .= MooseX::Getopt::OptionTypes->get_option_type($type_name);
            }
        }
        
        $options{$name} = \($constructor_options{$init_arg});
    }

    GetOptions(%options);
    
    # filter out options which 
    # were not passed at all
    %constructor_options = map {
        $constructor_options{$_} ne ''
            ? ($_ => $constructor_options{$_})
            : ()
    } keys %constructor_options;
    
    $class->new(%params, %constructor_options);
}

1;

__END__

=pod

=head1 NAME

MooseX::Getopt - 

=head1 SYNOPSIS

  ## In your class 
  package My::App;
  use Moose;
  
  with 'MooseX::Getopt';
  
  has 'out' => (is => 'rw', isa => 'Str', required => 1);
  has 'in'  => (is => 'rw', isa => 'Str', required => 1);
  
  # ... rest of the class here
  
  ## in your script
  #!/usr/bin/perl
  
  use My::App;
  
  my $app = My::App->new_with_options();
  # ... rest of the script here
  
  ## on the command line
  % perl my_app_script.pl -in file.input -out file.dump

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<new_with_options (%params)>

=item B<meta>

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
