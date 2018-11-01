#!/usr/bin/perl
use strict;
use warnings;

my @scorenames;
my %rec;
open FI,$ARGV[0] || die "sorry,$!\n";

while(<FI>)
{
    chomp;
    my @x=split/\t/;
    if($.==1){@scorenames=@x[14..($#x-1)];print join ("\t","Reg","Group","pos",@scorenames),"\n";next}
    my ($reg_id,$reg_gp,$reg_source)=@x[3..5];
    my $reg_id1=join(":","Lev3",$reg_source,$reg_id);
    my $reg_gp1=join(":","Lev2",$reg_source,$reg_gp);
    my $reg_source1=join(":","Lev1",$reg_source);
    my $pos=join(":",@x[6..8]);
    my $casecontrol=$x[11];
    my @scores=@x[14..($#x-1)];
    #print join ("\t",$reg_source1,$reg_gp1,$reg_id1,$casecontrol,$pos,@scores),"\n";
    for my $reg ($reg_source1, $reg_gp1,$reg_id1)
    {
    $rec{$reg}{$pos}=join ("\t",$reg,$casecontrol,$pos,@scores);
    }
    
    #map {$rec{$reg_id1}{$casecontrol}{$scorenames[$_]}{$pos}=$scores[$_]} 0..$#scores;
    #map {$rec{$reg_gp1}{$casecontrol}{$scorenames[$_]}{$pos}=$scores[$_]} 0..$#scores;
    #map {$rec{$reg_source1}{$casecontrol}{$scorenames[$_]}{$pos}=$scores[$_]} 0..$#scores;
}
close FI;

for my $reg(keys%rec)
{
    for my $pos (keys%{$rec{$reg}})
    {
        print $rec{$reg}{$pos},"\n";
    }
}
#print join("\t","Reg","Group",@scorenames),"\n";
#
#for my $reg(keys%rec)
#{
#    for my $case(keys%{$rec{$reg}})
#    {
#        my @scores;
#        for my $sn(@scorenames)
#        {
#            my @scores1=defined $rec{$reg}{$case}{$sn}? (values%{$rec{$reg}{$case}{$sn}}):"NA";
#            my $score=join(",",@scores1);
#            push(@scores,$score);
#        }
#        
#        print join("\t",$reg,$case,@scores),"\n";
#        
#    }
#}

