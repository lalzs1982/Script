#!/usr/bin/perl
use strict;
use warnings;

my %rec;
open FI,$ARGV[0] || die "sorry,$!\n";
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my @mutsum=split/:/,$x[10];
$rec{join("\t",@x[0..3])}{'M'}+=$mutsum[0];
$rec{join("\t",@x[0..3])}{'S'}+=$mutsum[1];
$rec{join("\t",@x[0..3])}{'I'}+=$mutsum[2];
$rec{join("\t",@x[0..3])}{'D'}+=$mutsum[3];
}
close FI;

for my $block(keys%rec)
{
    my $mut_prop=($rec{$block}{S}+$rec{$block}{I}+$rec{$block}{D})/($rec{$block}{M}+$rec{$block}{S}+$rec{$block}{I}+$rec{$block}{D});
    my $mut_prop_SNP=($rec{$block}{S})/($rec{$block}{M}+$rec{$block}{S});
    
    print join("\t",$block,"$rec{$block}{M}:$rec{$block}{S}:$rec{$block}{I}:$rec{$block}{D}",$mut_prop,$mut_prop_SNP),"\n";
}

