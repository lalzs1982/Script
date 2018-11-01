#!/usr/bin/perl
use strict;
use warnings;

my %chrlen;
open FI,$ARGV[0] || die "sorry,$!\n"; #chromosome length file
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
$chrlen{$x[0]}=$x[1];
}
close FI;

my $blocksize=$ARGV[1]; #size of block
my $start=1;
for my $chr(keys%chrlen)
{
 while(1)
{
print join("\t",$chr,$start,$start+$blocksize-1),"\n";
$start+=$blocksize;
last if $start>$chrlen{$chr};
}
$start=1;
}

