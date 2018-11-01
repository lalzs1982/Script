#!/usr/bin/perl
use strict;
use warnings;

#my %rec;
my $offset=1;
my $prevtransc='NULL';

open FI,$ARGV[0] || die "sorry$!\n"; #ordered bed file
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    #$_=~/(N[MR]_\d+)/;
    my($chr,$start,$end,$str,$transc)=(@x[0,1,2,5,3]);
    #last if $.>100;
    if($transc ne $prevtransc){#print STDERR "reset now ..., $.: $prevtransc $transc \n";
                               $prevtransc=$transc;$offset=1;}
    if($str eq '+')
    {
    map {
        print join("\t",$transc,$offset-1,$offset,$chr,$_-1,$_,$str),"\n";
        $offset++;
        } ($start..$end);
    }else{
        map {
            print join("\t",$transc,$offset-1,$offset,$chr,$_-1,$_,$str),"\n";
            $offset++;
            } reverse($start..$end);
        }
}
close FI;
