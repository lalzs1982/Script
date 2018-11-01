#!/usr/bin/perl

open FI,$ARGV[0];
my %rec;
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    $rec{$x[0]}{$x[2]}=$x[5];
}

my @realnums= sort {$b<=>$a} keys%{$rec{'Real'}};
my @simnums= sort {$b<=>$a} keys%{$rec{'Sim'}};

my $sum=0;
map {$sum+=$rec{'Real'}{$_};$rec{'Real'}{$_}=$sum} @realnums;
$sum=0;
map {$sum+=$rec{'Sim'}{$_};$rec{'Sim'}{$_}=$sum} @simnums;

my $cutoff=$realnums[0];

for my $i(reverse @realnums)
{
    if (!defined $rec{'Sim'}{$i}){$cutoff=$i-1;last}elsif($rec{'Sim'}{$i}/$rec{'Real'}{$i}<0.05){$cutoff=$i;last}
}
print STDOUT $cutoff;