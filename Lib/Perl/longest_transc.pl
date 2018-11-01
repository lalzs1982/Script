#!/usr/bin/perl
use strict;
use warnings;

open FI,$ARGV[0] || "$!\n"; #gtf
my %trans;
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    $_=~/gene_id\s\"(.*?)\"/; my $gi=$1;
    $_=~/transcript_id\s\"(.*?)\"/; my $ti=$1;
    my $exonlen=$x[4]-$x[3]+1;
    $trans{$gi}{$ti}+=$exonlen;
}
close FI;

my %trans1;
for my $gi(keys%trans)
{
    for my $ti(keys%{$trans{$gi}})
    {
        if(!defined $trans1{$gi}{'longest'} || ($trans{$gi}{$trans1{$gi}{'longest'}} < $trans{$gi}{$ti}) )
        {$trans1{$gi}{'longest'}=$ti}
    }
}

open FI,$ARGV[0] || "$!\n"; #gtf

while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    $_=~/gene_id\s\"(.*?)\"/; my $gi=$1;
    $_=~/transcript_id\s\"(.*?)\"/; my $ti=$1;
    if($trans1{$gi}{'longest'} eq $ti){print $_,"\n"}
}
close FI;

