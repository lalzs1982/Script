#!/usr/bin/perl

my $col1=$ARGV[2];
my $col2=$ARGV[3];

my %rec;
open FI,$ARGV[0];
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
$rec{$x[$col1]}=1;
}
close FI;

open FI,$ARGV[1];
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
if(defined $rec{$x[$col2]}){print "$_\t1","\n"}else{print "$_\t0","\n"}
#my @y=split/;/,$x[6];
#my $k=0;
#map {if(defined $rec{$_}){$k=1}} @y;
#if($k==1){print $_,"\n"}
}
close FI;


