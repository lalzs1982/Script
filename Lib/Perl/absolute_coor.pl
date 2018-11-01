#!/usr/bin/perl -w
use strict;

my %rec;
open FI, $ARGV[0]; #"./UTR_hg19.fasta" || die "sorry$!\n";
while(<FI>)
{
chomp;
if($_=~/>(.*?UTR)/){
$rec{"hg19_$1"}=$_;
}
}
close FI;

open FI, $ARGV[1]; #"./AURAlight_trans-factors.txt" || die "sorry$!\n";
while(<FI>)
{
next if $.==1;
chomp;
my @x=split/\t/,$_;
if(defined $rec{$x[2]}){
$rec{$x[2]}=~/(chr.*?):(\d+)\-(\d+)/;
my($chr,$start,$end)=($1,$2,$3);

$rec{$x[2]}=~/strand=([+-])/;
my $str=$1;

my($absstart,$absend)=($start+$x[4]-1,$start+$x[5]-1);
if($str eq '-'){($absstart,$absend)=($end-$x[5]+1,$end-$x[4]+1)};
print join("\t",$chr,$absstart,$absend, $str,$_),"\n";
}}#else{print STDERR "$_ no match\n";}}
close FI;


