#!/usr/bin/perl
use strict;
use warnings;

my %rec;
open FI,$ARGV[0] || die "sorry,$!\n";
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
next if(length($x[3])>1 || length($x[4])>1 || $x[3] eq '-' || $x[4] eq '-'); #only SNPs lef
$rec{join("\t",@x[0..4])}{$x[5]}=$_;
}
close FI;

for my $id(keys%rec)
{
if(defined $rec{$id}{'eQTL'}){print $rec{$id}{'eQTL'},"\n"}else{print $rec{$id}{'Common'},"\n"}
}
