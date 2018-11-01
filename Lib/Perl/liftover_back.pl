#!/usr/bin/perl
use strict;
use warnings;

my %lifted;
open FI,$ARGV[0]; #lifted file
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
$lifted{$x[3]}=join("\t",@x[0..2]);
}
close FI;

open FI,$ARGV[1]; #original file
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my $id=join(":",@x[0..2]);
if(defined $lifted{$id})
{
print join("\t",$lifted{$id},@x[3..$#x]),"\n";
}
}
close FI;


