#!/usr/bin/perl
use strict;
use warnings;

open FI,$ARGV[0];
my %rec;
while(<FI>)
{
    chomp;
    my @x=split/\t/;
    my $mut=join("\t",@x[0..1]);
    my $gp=$x[12];
    my $id=$x[13];
    my $muttype=$x[8];
    $rec{$gp}{'mut'}{$mut}=1;
    $rec{$gp}{'id'}{$id}=1;
    if ($muttype eq "synonymous SNV"){$rec{$gp}{'type'}{$muttype}+=1}
}
close FI;

for my $gp(keys%rec)
{
    print join(":",$gp, scalar(keys%{$rec{$gp}{'id'}}),scalar(keys%{$rec{$gp}{'mut'}}),$rec{$gp}{'type'}{'synonymous SNV'}),"\t";
}
print "\n";