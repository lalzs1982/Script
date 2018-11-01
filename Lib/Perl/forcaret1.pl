#!/usr/bin/perl
use strict;
use warnings;
#my $multifile=$ARGV[0];
#my %outcols;
#map {$outcols{$_}=1} @ARGV[1..$#ARGV];

my %rec;
my @colnames;
open(FI,$ARGV[0]) || die "sorry,$!\n";
while (<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    
    if ($.==1)
    {
        @colnames=@x;
        print join("\t","Coor",@x[5..$#x]),"\n"; 
	next
    };
    #my @out;
    map {
        if($colnames[$_]=~/ribosnitch|utrciselements|targetScanS/ || $colnames[$_] eq 'RBP'){
            $x[$_]=($x[$_] eq '.' || $x[$_] eq 'NA' )?'No':'Yes'}
        elsif($colnames[$_]=~/CisBP|RBPDB|miRNA|repeat/){
            $x[$_]=($x[$_] eq '.')?'No':'Yes';
            #if($x[$_] eq '.'){
            #    $x[$_]=0;
            #    }else{
            #    #print STDERR "it is $x[$_] now\n";
            #    my @sc;
            #    map {if($_ eq '0'){push(@sc,0)}else{my @xx=split/:/,$_; push(@sc,$xx[1])}} (split/;/,$x[$_]);
            #    my @sc1=sort {abs($a)<=>abs($b)} @sc;
            #    $x[$_]=$sc1[$#sc1];
            #}
        }elsif($colnames[$_]=~/phastcons|phylop/ && $x[$_] eq '.'){$x[$_]='NA'}elsif($colnames[$_]=~/UTRenddist/){
            $x[$_]=($x[$_] eq '.')?'NA':$x[$_];}elsif($colnames[$_]=~/RNALfold/){
            $x[$_]=($x[$_] eq 'S')?'Yes':'No';}
        } 6..$#colnames;
    
	print join("\t","$x[0]:$x[1]:$x[2]:$x[3]:$x[4]",@x[5..$#x]),"\n";
}
close FI;

