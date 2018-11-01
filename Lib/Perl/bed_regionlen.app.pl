#!/usr/bin/perl

#this code should not be used ,and use ~/code/bed_regionlen.pl, 

use strict;
use warnings;

my %rec;
open FI,$ARGV[0] || die "$!"; #4th column sum
while(<FI>)
{
    chomp;
    my @x=split/\s+/,$_;
    #print STDERR "$x[0] to $x[1]\n";
    $rec{'4th'}{$x[0]}=$x[1];
}
close FI;

open FI,$ARGV[1] || die "$!"; #5th column sum
while(<FI>)
{
    chomp;
    my @x=split/\s+/,$_;
    $rec{'5th'}{$x[0]}=$x[1];
}
close FI;

open FI,$ARGV[2] || die "$!"; #original bed
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    #if(defined $rec{'4th'}{$x[3]}){print STDERR "good!\n"}else{print STDERR "$x[3] and $rec{'4th'}{$x[3]} not match!\n"};
    my $fourth=defined $rec{'4th'}{$x[3]}?($rec{'4th'}{$x[3]}):'NA';
    my $fifth=defined $rec{'5th'}{$x[4]}?($rec{'5th'}{$x[4]}):'NA';
    print join("\t",$_,$fourth,$fifth),"\n";
}
close FI;

