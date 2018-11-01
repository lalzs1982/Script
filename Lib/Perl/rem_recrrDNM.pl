#!/usr/bin/perl
use strict;
use warnings; 
#remove recerrent DNMs that occur on the same site

my %rec;
open FI,$ARGV[0]; # bed or avinput format
while(<FI>)
{
chomp;
my @x=split/\t/;
my $coor="$x[0]\t$x[1]";
if(defined $rec{$coor}){$rec{$coor}=0}else{$rec{$coor}=1}
}
close FI;

open FI,$ARGV[0]; # bed or avinput format
while(<FI>)
{
chomp;
my @x=split/\t/;
my $coor="$x[0]\t$x[1]";
if($rec{$coor}==1){print $_,"\n"}
}
close FI;


