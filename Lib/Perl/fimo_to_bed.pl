#!/usr/bin/perl
use strict;
use warnings;

my %abso_coor;
open FI,$ARGV[0] || die "sorry$!\n"; #UTR coordinates file
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
$abso_coor{$x[3]}=$_;
}
close FI;

open FI,$ARGV[1] || die "sorry$!\n"; #FIMO output file
while(<FI>)
{
next if $.==1;
chomp;
my @x=split/\t/,$_;
my @y=split/,/,$x[2];
my $trid=$y[0];
my ($rel_start,$rel_end)=@x[3..4];
my($chr,$abs_start,$abs_end,$str)=(split/\t/,$abso_coor{$trid})[0,1,2,5];

my($rel_start1,$rel_end1);
if($str eq '+'){$rel_start1=$abs_start+$rel_start-1;$rel_end1=$abs_start+$rel_end-1}
if($str eq '-'){$rel_start1=$abs_end-$rel_end+1;$rel_end1=$abs_end-$rel_start+1}
print join("\t",$chr,$rel_start1,$rel_end1,$x[2],$str,"$x[1]"),"\n";
}
close FI;

