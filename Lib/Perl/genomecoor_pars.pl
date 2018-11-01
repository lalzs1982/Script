#!/usr/bin/perl
use strict;
use warnings;

my %str;
open FI,$ARGV[0] || die "sorry,$!\n"; #fasta file
while(<FI>)
{
    next if $_!~/>/;
    chomp;
    my @x=split/\t/,$_;
    $x[0]=~/>(.*)/;
    my($coor,$str)=($1,$x[1]);
    $str{$coor}=$str;
}
close FI;

open FI,$ARGV[1] || die "sorry,$!\n"; #fimo output
while(<FI>)
{
    chomp;
    next if($.==1);
    my @x=split/\t/,$_;
    $x[2]=~/(chr.*?):(\d+)\-(\d+)/;
    my($start,$end)=@x[3,4];
    my $str=$str{$x[2]};
    my($chr,$int_start,$int_end)=($1,$2,$3);
    my $start1=$str eq '+'?($int_start+$start):($int_end-$end);
    my $end1=$str eq '+'?($int_start+$end):($int_end-$start);
    print join("\t",$chr,$start1,$end1,@x[0,6]),"\n";
}
close FI;

