#!/usr/bin/perl
use strict;
use warnings;
#this code could convert genomic coordinates to transcript coordinates (distance from the TSS on forward direction)
my %rec;
open FI,$ARGV[0] || die "$!"; #postion and exon(gtf) overlap file
while(<FI>)
{
    chomp;
    my @x=split /\t/,$_;
    my $pos=join("\t",@x[0..2]); # chr5	96231000	96231000
    $_=~/transcript_id\s\"(.*?)\"/; my $trid=$1;
    my $exon=join("\t",@x[3..7]); #chr5	HAVANA	exon	96230950	96231063
    $rec{$trid}{$exon}{$pos}=1 #ref alt
}
close FI;

my %rec1;
open FI,$ARGV[1] || die "$!"; # exon(gtf) file
while(<FI>)
{
    chomp;
    my @x=split /\t/;
    next if $x[2] ne "exon";
    $_=~/transcript_id\s\"(.*?)\"/; my $trid=$1;
    if(!defined $rec1{$trid}{'length'}){$rec1{$trid}{'length'}=0};
    if(defined $rec{$trid})
    {
        $rec1{$trid}{'str'}=$x[6];
        my $exon=join("\t",@x[0..4]);
        if(defined $rec{$trid}{$exon})
        {
            map {
                my @pos=split/\t/,$_;
                my $rel_pos=$rec1{$trid}{'length'}+$pos[2]-$x[3]+1;
                $rec1{$trid}{$_}=$rel_pos;
                } keys%{$rec{$trid}{$exon}};
        }
        $rec1{$trid}{'length'}+=$x[4]-$x[3]+1;
    }
}
close FI;

for my $trid(keys%rec1)
{
    for my $pos(keys%{$rec1{$trid}})
    {
        next if($pos eq "length" || $pos eq "str");
        my $rel_pos=$rec1{$trid}{'str'} eq '+'?$rec1{$trid}{$pos}:($rec1{$trid}{'length'}-$rec1{$trid}{$pos});
        #print join("\t",$pos,$rel_pos,$trid,$rec1{$trid}{'length'},$rec1{$trid}{$pos},$rec1{$trid}{'str'}),"\n";
        print join("\t",$pos,$trid,$rel_pos,$rec1{$trid}{'str'}),"\n";
    }
}

