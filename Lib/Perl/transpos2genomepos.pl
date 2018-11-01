#!/usr/bin/perl
use strict;
use warnings;

open FI,$ARGV[0];
while(<FI>)
{
    chomp;
    my @x=split/\t/;
    my $shift_left=$x[1]>=$x[4]?($x[1]-$x[4]):0;
    my $shift_right=$x[2]<=$x[5]?($x[2]-$x[4]):$x[5]-$x[4];
    my $abs_left=$x[9] eq '+'?($x[7]+$shift_left):($x[8]-$shift_right);
    my $abs_right=$x[9] eq '+'?($x[7]+$shift_right):($x[8]-$shift_left);
    print join("\t",@x[0..2],$x[6],$abs_left,$abs_right),"\n";
}