#!/usr/bin/perl
use strict;
use warnings;
my %rec;
open FI,$ARGV[0] || die "sorry$!\n";

while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my ($id,$gp,$dataset,$mr)=@x[3..6];
$rec{$dataset}{"ID"}{$id}+=$mr;
$rec{$dataset}{"GP"}{$gp}+=$mr;
}
close FI;

open FI,$ARGV[0] || die "sorry$!\n";

while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my ($id,$gp,$dataset,$mr)=@x[3..6];
print join("\t",@x[0..5],$rec{$dataset}{"ID"}{$id},$rec{$dataset}{"GP"}{$gp}),"\n";
}
close FI;

