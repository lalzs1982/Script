#!/usr/bin/perl
use strict;
use warnings;
my @colnames;
my %cols_sep;
map {$cols_sep{$_}=1} @ARGV[1..$#ARGV];

open(FI,$ARGV[0]) || die "sorry,$!\n";
while (<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    if ($.==1)
    {
        @colnames=@x;
        my @out;
        map {if(defined $cols_sep{$_}){push(@out,$_."_Pos",$_."_Neg")}else{push(@out,$_)}} @colnames;
        print join("\t",@out),"\n";
        next;
    };
    
    my @out;
    map {
        if(defined $cols_sep{$colnames[$_]}){
            my @yy=split/:/,$x[$_];
            if($yy[-1]=~/:?([-+]?[0-9]+\.?[0-9]*)/){
                if($1>0){push(@out,$x[$_],0)}else{push(@out,0,$x[$_])}
                }else{push(@out,$x[$_],$x[$_])}
            }else{push(@out,$x[$_])}
        } 0..$#x;
    print join("\t",@out),"\n";
}

close FI;
