#!/usr/bin/perl
use strict;
use warnings;

my %rec;
open FI,$ARGV[0] || die "sorry$!\n"; #input file

my @colnames=split/,/,$ARGV[1]; #column names
my %colnames;
map {$colnames{$_}=1} @colnames;

print join("\t",@colnames),"\n";
my @cols;

while(<FI>)
{
chomp;
my @x=split/\t/;
if($.==1){map {if (defined($colnames{$x[$_]})){push(@cols,$_)} } 0..$#x; next;}
print join("\t",@x[@cols]),"\n";
}
close FI;

