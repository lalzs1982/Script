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
if($ARGV[1]=~/\.gz$/){open FI,"gunzip -c $ARGV[1]|"}else{open FI,$ARGV[1]}; #|| die "$!\n"; #variants file in avinput format
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
next if (length($x[3]) !=1 || length($x[4]) !=1 || $x[3] eq '-' || $x[4] eq '-'); #indels not analyzed
my ($chr,$pos,$ref,$alt)=@x[0,2,3,4];
if (!defined $genome{$chr}){next};
my $ref0=uc(substr($genome{$chr},$pos-1,1));
$ref=uc($ref);
if($ref eq $ref0){
    print $_,"\n";
}else{
    #print STDERR "$ ref0: $ref0 before rev\n";
    $ref=~tr/ABCDGHMNRSTUVWXYabcdghmnrstuvwxy/TVGHCDKNYSAABWXRtvghcdknysaabwxr/;
    $alt=~tr/ABCDGHMNRSTUVWXYabcdghmnrstuvwxy/TVGHCDKNYSAABWXRtvghcdknysaabwxr/;
     #print STDERR "$ ref0: $ref0 after rev\n";
     if($ref eq $ref0){
    print join("\t",@x[0..2],$ref,$alt,@x[5..$#x]),"\n";
    #print STDERR "reversed to match \n";
    }else{print $_,"\n"; print STDERR "Error!, ref should be $ref0 : $_\n"}   
}
$test++;
}
close FI;
print STDERR "$test sites tested\n";

