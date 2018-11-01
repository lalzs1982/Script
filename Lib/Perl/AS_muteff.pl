#!/usr/bin/perl
use strict;
use warnings;
my %compl=(A=>'T',G=>'C',U=>'A',C=>'G');

open FI,$ARGV[0];
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    my($chr,$str,$pos)=@x[7..9];
    my($ref,$alt)=@x[3..4];
    my($p1,$p2)=@x[5..6];
    next if ($p1>0.05 || $p2>0.05);
    
    if($str eq '+'){
        if($ref eq 'U'){$ref='T'};
        if($alt eq 'U'){$alt='T'};
    }
    
    $ref=$str eq '+'?$ref:$compl{$ref};
    $alt=$str eq '+'?$alt:$compl{$alt};
    
    my @acgt;
    map {if($alt eq $_){push(@acgt,1)}else{push(@acgt,0)}}  qw(A C G T);
    print join("\t",$chr,$pos,$pos,$ref,@acgt),"\n";
}
close FI;
