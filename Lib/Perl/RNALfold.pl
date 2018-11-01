#!/usr/bin/perl
use strict;
use warnings;
my %rec;
open FI,$ARGV[0] || die "sorry,$!\n"; # variants in fasta file regions
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    my $id=">$x[0]:$x[1]-$x[2]";
    my $varpos=$x[5];
    $rec{$id}{$varpos}=1;
}
close FI;

my %out;
my ($id,$str);
my @relpos; #start from 0
my ($chr,$start,$end);
open FI,$ARGV[1] || die "sorry,$!\n"; # RNALfold results
while(<FI>)
{
    chomp;
    my @x=split/\s+/,$_;
    if($_=~/>(chr.*):(\d+)\-(\d+)/){
        $id=$x[0];
        $str=$x[1];
        ($chr,$start,$end)=($1,$2,$3); #(split/[>:-]/,$id)[1,2,3];
        @relpos=();
        if($str eq '+'){map {push(@relpos,$_-$start)} keys%{$rec{$id}}}else{
            map {push(@relpos,$end-$_)} keys%{$rec{$id}}
        }
        next
        };
    next if $_!~/\(\(/;
                  
    my $start1=$x[-1];
    my $len=length($x[0]);
    $x[-2]=~/\(?(.*)\)/;
    my $score=$1;
    
    map {
        if($_>$start1 && $_<$start1+$len)
        {
            my $y=substr($x[0],$_-$start1,1);
            my $lab=$y eq '.'?'L':'S';
            my $abspos=$str eq '+'?($start+$_):($end-$_);
            $out{join("\t",$chr,$abspos,$abspos,$str)}{$score}=join("\t",$len,$_-$start1,$lab); #$start,$end,
        }
        } @relpos;
}
close FI;

print join("\t",'Chr','Start','End','Str','RNAstructureLen','Relpos','StemOrLoop','Energy'),"\n";
for my $k(keys%out)
{
    my @sorted=sort {$a<=>$b} keys%{$out{$k}};
    print join("\t",$k,$out{$k}{$sorted[0]},$sorted[0]),"\n";
}