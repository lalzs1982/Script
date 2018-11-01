#!/usr/bin/perl
use strict;
use warnings;

my %transcPos;
open FI,$ARGV[0] ||  die "$!\n"; #bed file of mutations on transcripts, point mutation considered only
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    my $transid=$x[0];
    my $pos=$x[2];
    $transcPos{$transid}{$pos}=$_;
}
close FI;

my %rectrans;
my $offset=0;
my $previd='NULL';

open FI,$ARGV[1] ||  die "$!\n"; #gtf file of transcripts annotation, ordered with + increasing and - decreasing;
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    $_=~/transcript_id\s\"(.*?)\"/;
    my $transid=$1;
    my($chr,$start,$end,$str)=@x[0,3,4,6];
    
    if($transid ne $previd){$offset=0}
        
    my $rel_start=$offset+1;
    my $rel_end=$rel_start+$end-$start;
    
    if(defined $transcPos{$transid})
    {
        map {
            if($_>=$rel_start && $_<=$rel_end){
            my $abspos=$str eq '+'?($start+$_-$rel_start):($end-($_-$rel_start));
            print join("\t",$transcPos{$transid}{$_},$chr,$str,$abspos),"\n";
            }
            } keys%{$transcPos{$transid}};
    }
    
    $offset=$rel_end;
    $previd=$transid;
}
close FI;
