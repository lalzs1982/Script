#!/usr/bin/perl
use strict;
use warnings;

my %miRNA_asdgene;
my %total;
open FI,$ARGV[0] || die "sorry$!\n";
while(<FI>)
{
    chomp;
    my @x=split/\t/;
    my ($mir,$asd)=@x[3,7];
    $total{$asd}++;
    $miRNA_asdgene{$mir}{$asd}++;
}
close FI;

foreach my $mir(keys%miRNA_asdgene)
{
        my $asd0=defined $miRNA_asdgene{$mir}{0}?$miRNA_asdgene{$mir}{0}:0;
        my $asd1=defined $miRNA_asdgene{$mir}{1}?$miRNA_asdgene{$mir}{1}:0;
        my $or=($asd1/($total{1}-$asd1))/($asd0/($total{0}-$asd0));
        print join("\t",$mir,$asd1,$asd0,$total{1},$total{0},$or),"\n";
}
