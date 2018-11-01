#!/usr/bin/perl
use strict;
use warnings;

my %rec;
open FI,$ARGV[0] || die "$!"; 
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    $rec{'4th'}{$x[3]}{$x[0]}{$x[1]}{$x[2]}=1;
    $rec{'5th'}{$x[4]}{$x[0]}{$x[1]}{$x[2]}=1;
    $rec{'all'}{'all'}{$x[0]}{$x[1]}{$x[2]}=1;
    
}
close FI;

my %rec1;
for my $col(keys%rec)
{
    for my $id(keys%{$rec{$col}})
    {
        my $len_chrs=0;
        for my $chr(keys%{$rec{$col}{$id}})
        {
        my @starts=sort {$a<=>$b} keys%{$rec{$col}{$id}{$chr}};
        my $len=0;
        my $end=0;
        
        map {
            my $start1=$_;
            map {
            my $end1=$_;
            
            if($start1>$end){$len+=($end1-$start1+1);$end=$end1}elsif($end1>$end){
                $len+=($end1-$end+1);$end=$end1;
            }} keys%{$rec{$col}{$id}{$chr}{$_}}
            
            } @starts;
        $len_chrs+=$len;
        }
        $rec1{$col}{$id}=$len_chrs;
    }
}

open FI,$ARGV[0] || die "$!"; 
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    print join("\t",@x[0..4],$rec1{'4th'}{$x[3]},$rec1{'5th'}{$x[4]},$rec1{'all'}{'all'}),"\n";
}
close FI;
