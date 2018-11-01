#!/usr/bin/perl
use strict;
use warnings;

my %rec;
open FI,$ARGV[0] || die "sorry$!\n"; #ordered gtf file
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    $_=~/(N[MR]_\d+)/;
    push(@{$rec{$1}},$_);
}
close FI;

for my $transc(keys%rec)
{
    my $offset=0;
    my $prevtransc='NULL';

    for my $transc1(@{$rec{$transc}})
    {
    my @x=split/\t/,$transc1;
    $transc1=~/(N[MR]_\d+)/;
    my($chr,$start,$end,$str,$transc)=(@x[0,3,4,6],$1);
    my $len=$end-$start+1;
    if($transc eq $prevtransc){
        print join("\t",$transc,$offset+1,$offset+$len,"$chr:$start:$end:$str"),"\n";
        $offset+=$len
        }else{
        $offset=0;
        $prevtransc=$transc;
        print join("\t",$transc,$offset+1,$offset+$len,"$chr:$start:$end:$str"),"\n";
        $offset+=$len
        }
    }
}