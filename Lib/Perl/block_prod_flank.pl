#!/usr/bin/perl
use strict;
use warnings;

my $blocksize=$ARGV[0]; #size of block

open FI,$ARGV[1] || die "sorry,$!\n"; #intervals
while(<FI>)
{
next if $.==1;
chomp;
my @x=split/\t/,$_;
my $mid=int(($x[1]+$x[2])/2);
my $block_left=$mid-$blocksize+1>0?($mid-$blocksize+1):0;
my $block_right=$mid+$blocksize-1;
print join("\t",$x[0],$block_left,$block_right,"$x[0]:$x[1]:$x[2]"),"\n";
}
close FI;


