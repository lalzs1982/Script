#!/usr/bin/perl
#used for pre-miRNA overlap

my $col1=$ARGV[2];
my $col2=$ARGV[3];

my %rec;
open FI,$ARGV[0];
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my $mir=$x[$col1];
my @y=split/\-/,$mir;
my $premir="$y[0]-$y[1]";
$rec{$premir}=$_;
}
close FI;

open FI,$ARGV[1];
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my @y=split/\-/,$x[$col2];
my $premir="$y[0]-$y[1]";

if(defined $rec{$premir}){print join("\t",$rec{$premir},$_),"\n"}
#my @y=split/;/,$x[6];
#my $k=0;
#map {if(defined $rec{$_}){$k=1}} @y;
#if($k==1){print $_,"\n"}
}
close FI;


