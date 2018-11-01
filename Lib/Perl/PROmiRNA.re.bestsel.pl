#!/usr/bin/perl

open FI,$ARGV[0];
my %best;

while(<FI>)
{
chomp;
my @x=split/\t/;
$x[6]=~/prob_prom:(.*)/;
my $p=$1;
my $id=$x[0];
my $pos="chr$x[1]\t$x[2]\t$x[3]";
$best{$id}{$p}{$pos}=1;
}
close FI;

for my $id(keys%best)
{
my @sortedP=sort {$b<=>$a} keys%{$best{$id}};
my @pos=keys%{$best{$id}{$sortedP[0]}};
for my $pos(@pos)
{
print "$pos\t$id\tAll\n";
}
}

