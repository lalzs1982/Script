#!/usr/bin/perl
use strict;
use warnings;

my %exonseq;
open FI,$ARGV[0] || die "sorry,$!\n"; #exon sequences
my($chr,$start,$end,$str);
while(<FI>)
{
    chomp;
    #if($_=~/(chr.*?):(\d+)\-(\d+)\(([-+])\)/)
    if($_=~/>(chr.*?):(\d+):(\d+):([-+])/)
    {
        ($chr,$start,$end,$str)=($1,$2,$3,$4);
        #$start++;
        next;
    }else{
        $_=~s/t/U/ig;
        $exonseq{join("\t",$chr,$start,$end,$str)}=$_}
}
close FI;

#my %transcseq;
my $prev_trans='NULL';
open FI,$ARGV[1] || die "sorry,$!\n"; # bed, with exons ordered
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
	my $transc;
    ($chr,$start,$end,$transc,$str)=@x[0,1,2,3,5];
    if(!defined $exonseq{join("\t",$chr,$start,$end,$str)}){
        #print STDERR "No exon seq for",join("\t",$chr,$start,$end,$str)," !\n";
        next}
    if($transc ne $prev_trans)
    {
        $prev_trans=$transc;
        if($.==1){print ">$transc\n"}else{print "\n>$transc\n"};
    }
    print $exonseq{join("\t",$chr,$start,$end,$str)}
    
    #$transcseq{$transc}.=$exonseq{join("\t",$chr,$start,$end,$str)};
}
close FI;
#
#for my $transc(keys%transcseq)
#{
#    print ">$transc\n$transcseq{$transc}\n";
#}

