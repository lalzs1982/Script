#!/usr/bin/perl
my %trans=(T=>U,t>u);
open FI,$ARGV[0]; #fasta file;
while(<FI>)
{
if($_=~/>/){print}else{
chomp;
$_=~s/t/U/ig;
print $_,"\n";
}
}
close FI;

