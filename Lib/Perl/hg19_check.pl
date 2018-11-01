#!/usr/bin/perl
use strict;
use warnings;

my %genome;
my $chr;
open FI,$ARGV[0] || die "$!\n"; #genome fasta file
while(<FI>)
{
chomp;
if($_=~/>(.*)/){$chr=$1;next}else{$genome{$chr}.=$_}
}
close FI;

my $test=0;
open FI,$ARGV[1] || die "$!\n"; #variants file in avinput format
while(<FI>)
{
chomp;

my $rd=rand;
next if($rd>0.1);

my @x=split/\t/,$_;
next if (length($x[3]) !=1 || length($x[4]) !=1 || $x[3] eq '-' || $x[4] eq '-');
my ($chr,$pos,$ref)=@x[0,2,3];
my $ref0=uc(substr($genome{$chr},$pos-1,1));
if($ref ne $ref0){print "Error!, ref should be $ref0 : $_\n"}
$test++;
}
close FI;
print "$test sites tested\n";

