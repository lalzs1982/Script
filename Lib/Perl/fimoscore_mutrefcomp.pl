#!/usr/bin/perl
use strict;
use warnings;

my $fl=$ARGV[0];
my %rec;
open FI,$ARGV[1] || die "sorry$!\n"; #ref
while(<FI>)
{
    next if $.==1;
    chomp;
    my @x=split/\t/,$_;
    next if($x[3]>$fl || $fl>$x[4]); #remove bindings not related to mutation positions
    my($id,$motif,$score,$p)=@x[2,0,6,7];
    $rec{$id}{$motif}{'ref'}="$score:$p";
}
close FI;

open FI,$ARGV[2] || die "sorry$!\n"; #ref
while(<FI>)
{
    next if $.==1;
    chomp;
    my @x=split/\t/,$_;
    next if($x[3]>$fl || $fl>$x[4]); #remove bindings not related to mutation positions
    my($id,$motif,$score,$p)=@x[2,0,6,7];
    $rec{$id}{$motif}{'mut'}="$score:$p";
}
close FI;

my $i=0;
for my $id(keys%rec)
{
    #my %max_score=();
    for my $motif(keys%{$rec{$id}})
    {
        my $mutp=defined $rec{$id}{$motif}{'mut'}?(split/:/,$rec{$id}{$motif}{'mut'})[1]:'NA';
        my $refp=defined $rec{$id}{$motif}{'ref'}?(split/:/,$rec{$id}{$motif}{'ref'})[1]:'NA';
        #next if (($mutp eq 'NA' || $mutp>0.0001) && ($refp eq 'NA' || $refp>0.0001));
        next if(($mutp eq 'NA' || $mutp>0.001) && ($refp eq 'NA' || $refp>0.001));
        
        my $mutscore=defined $rec{$id}{$motif}{'mut'}?(split/:/,$rec{$id}{$motif}{'mut'})[0]:'NA';
        $mutscore=($mutscore eq 'NA' || $mutscore<0)?0:$mutscore;
        my $refscore=defined $rec{$id}{$motif}{'ref'}?(split/:/,$rec{$id}{$motif}{'ref'})[0]:'NA';
        $refscore=($refscore eq 'NA' || $refscore<0)?0:$refscore;
        my $diffscore=($refscore-$mutscore);
        my @ids=split/:/,$id;
        #if((defined $max_score{$id} && abs($max_score{$id}{score})<abs($diffscore)) || !defined $max_score{$id}){
        #    $max_score{$id}{'score'}=$diffscore;$max_score{$id}{'info'}=join("\t",@ids,$motif,$refscore,$refp,$mutscore,$mutp,$diffscore);
        #}
        #print STDERR "$i\n";$i++;
        print join("\t",@ids,$motif,$refscore,$refp,$mutscore,$mutp,$diffscore),"\n";
    }
    
    #if(defined $max_score{$id}){print $max_score{$id}{'info'},"\n";}
}

