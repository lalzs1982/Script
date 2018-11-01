#!/usr/bin/perl
use strict;
use warnings;

my $id;
open FI,$ARGV[0] || die "sorry,$!\n"; #fasta file
while(<FI>)
{
    chomp;
    if($_=~/>(.*)/){$id=$1;next}
    my @refbases=split//,uc($_);
    my $relpos=1;
    map {
        for my $alt(qw(A U G C))
        {
            if($_ ne $alt){print join("\t",$id,$relpos-1,$relpos,$_,$alt),"\n"}
        }
        $relpos++;
    } @refbases;
}
close FI;

