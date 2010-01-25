package NoOptions;
use Moose;

with 'MooseX::Getopt';

package main;
NoOptions->new_with_options;
