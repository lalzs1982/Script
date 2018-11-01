#!/usr/bin/perl
use strict;
use warnings;
my %compl=('A'=>'U','U'=>'A','G'=>'C','C'=>'G');

my $id;
#my $transc=$ARGV[0]; #transcript ID
my ($chr,$start,$end,$str);
open FI,$ARGV[0] || die "sorry$!\n";
while(<FI>)
{
    chomp;
    if($_=~/>(.*)/)
    {
        my @x=split/:/,$1;
        ($chr,$start,$end,$str)=@x;
       #print STDERR "this is $1, $str\n";

        next;
    }
    
    
    my @x=split/\s+/,$_;
    next if(scalar(@x) !=10);
    next if $x[1]!~/\d+/;
    
    #print STDERR "$_, $str\n";
    
    $x[0]=~/([AUGC])(\d+)([AUGC])/;
    my($ref,$pos,$alt)=($1,$2,$3);
    $ref=$str eq '+'?$ref:($compl{$ref});
    $alt=$str eq '+'?$alt:($compl{$alt});
    
    $ref=$ref=~/U/i?'T':uc($ref);
    $alt=$alt=~/U/i?'T':uc($alt);


    my @intervals=(split/\-/,$x[4]);
    my $left=$str eq '+'?($pos-$intervals[0]):($intervals[1]-$pos);
    my $right=$str eq '+'?($intervals[1]-$pos):($pos-$intervals[0]);
    $left=$start-$left;
    $right=$start+$right;
    
    #$x[11]=~/(.*?)\.rnasnp/;
    #my $transc=$1;
    my($dmax,$p)=@x[5,6];
    
    #my $r_min=$x[8];
    #my $p=$x[6]>$x[9]?$x[9]:$x[6];
    #my $p=$x[9];
    
    print join("\t",$chr,$start,$end, $ref,$alt,$left,$right,$dmax,$p),"\n";
}
close FI;
