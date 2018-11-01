#!/usr/bin/perl
use strict;
use warnings;

open FI,$ARGV[0] || die "sorry,$!\n"; # result file overlap of bed and vcf
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my@y=split/:/,$x[15];
$y[6]=~/(.*)%/;
print join("\t",@x[0..5],$1),"\n"; # get coordinates and proportion file
}
close FI;

