#!/usr/bin/perl
use strict;
use warnings;

my %rec;
open FI,$ARGV[0] || die "sorry,$!\n"; #bed overlap file
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    my $start=$x[1]>$x[4]?$x[1]:$x[4];
    my $end=$x[2]>$x[5]?$x[5]:$x[2];
    my $lab=$x[6];
    map {$rec{"$x[0]\t$_\t$_"}{$lab}=1} ($start..$end)
}
close FI;

for my $pos(keys%rec)
{
    my $lab=join(";",keys%{$rec{$pos}});
    print join("\t",$pos,$lab),"\n";
}
