#!/usr/bin/perl
use strict;
use warnings;

my %rec;
open FI,$ARGV[0] || die "sorry,$!\n"; #bed file
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    my $start=$x[1];
    my $end=$x[2];
    my $lab=$x[3];
    map {print join("\t",$x[0],$_,$_,$lab),"\n"} ($start..$end)
}
close FI;

