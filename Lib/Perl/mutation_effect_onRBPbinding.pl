#!/usr/bin/perl -w
use strict;

my %utrcoors;
open FI,$ARGV[0] || die "sorry,$!\n"; #UTR coordinates
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    $utrcoors{$x[3]}="$x[1]:$x[2]";
}
close FI;

my %rec;
open FI,$ARGV[1] || die "sorry,$!\n"; #RBP binding on mutated seqeunces
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    my($motif,$target,$start,$end,$score,$pvalue)=@x[0,2,3,4,6,7];
    next if $target !~/,/; #whether the target sequence contain a mistach
    my @aa= (split/,/,$target);
    map {my @y=split/:/,$_;
         if($y[0]<=$end && $y[0]>=$start){
        $rec{$aa[0]}{$_}{join(":",$motif,$score,$pvalue)}=1;    
         }
         } @aa[1..$#aa];
}
close FI;

open FI,$ARGV[2] || die "sorry,$!\n"; #RBP binding on original seqeunces
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    my($motif,$target,$start,$end,$score,$pvalue)=@x[0,2,3,4,6,7];
    if(defined $rec{$target})
    {
        my @mutations=keys%{$rec{$target}};
        
    }
    
    my @aa= (split/,/,$target);
    map {my @y=split/:/,$_;
         if($y[0]<=$end && $y[0]>=$start){
        $rec{join(",",$aa[0],$_)}{join(":",$motif,$score,$pvalue)}=1;    
         }
         } @aa[1..$#aa];
}
close FI;


