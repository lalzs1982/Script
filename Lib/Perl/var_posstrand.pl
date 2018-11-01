#!/usr/bin/perl
use strict;
use warnings;

my %rev=(A=>"T",T=>"A",G=>"C",C=>"G");
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
#my $rd=rand; next if($rd>0.1);

my @x=split/\t/,$_;
next if (length($x[3]) !=1 || length($x[4]) !=1 || $x[3] eq '-' || $x[4] eq '-');
my ($chr,$pos,$ref,$alt)=@x[0,2,3,4];
my $ref0=uc(substr($genome{$chr},$pos-1,1));
if($ref0 eq $rev{$ref}){ $x[3]=$ref0; $x[4]=$rev{$alt};print STDERR "Error!, ref should be $ref0 : $_\n"}
print join("\t",@x),"\n";
$test++;
}
close FI;
print STDERR "$test sites tested\n";

