#!/usr/bin/perl
use strict;
use warnings;

open FI,$ARGV[0];
my %rec;
my %gp;
while(<FI>)
{
    chomp;
    my @x=split/\t/;
    #my $mut=join("\t",@x[6..8]);
    my $mut=join("\t",@x[6..7]);
    my $gp=$x[11];
    #my $reg1="$x[5]:$x[3]\t$x[6]";
    #my $reg2="$x[5]:$x[4]\t$x[7]";
    my ($reg1,$reg2,$reg3)=("Lev3:$x[5]:$x[3]","Lev2:$x[5]:$x[4]","Lev1:$x[5]");
    map {$rec{$_}{$gp}{$mut}=1;} ($reg1,$reg2,$reg3);
    #$rec{$reg1}{$gp}{$mut}=1;
    #$rec{$reg2}{$gp}{$mut}=1;
    #$rec{$reg3}{$gp}{$mut}=1;
    
    $gp{$gp}=1;
}
close FI;

open FI,$ARGV[1]; #ALL dnms
my %total;
while(<FI>)
{
    chomp;
    my @x=split/\t/;
    #my $mut=join("\t",@x[0..2]);
    my $mut=join("\t",@x[0..1]);
    my $gp=$x[5];
    $total{$gp}{$mut}=1;
}


for my $reg(keys%rec)
{
my $gp="ASD";
my $asd=defined $rec{$reg}{$gp}?scalar(keys%{$rec{$reg}{$gp}}):0;
$gp="Control";
my $control=defined $rec{$reg}{$gp}?scalar(keys%{$rec{$reg}{$gp}}):0;
my $total_ASD=scalar(keys%{$total{"ASD"}});
my $total_control=scalar(keys%{$total{"Control"}});
my $or=(($asd+1)/($total_ASD-$asd))/(($control+1)/($total_control-$control));
print join("\t",$reg,$asd,$control,$total_ASD,$total_control,$or),"\n";
#
#
#print "$reg";
#for my $gp (qw (ASD Control))#(keys%gp)
#{
#my $ct=defined $rec{$reg}{$gp}?scalar(keys%{$rec{$reg}{$gp}}):0;
#print "\t$ct\t"
#}
#print join("\t",scalar(keys%{$total{"ASD"}}),scalar(keys%{$total{"Control"}}));
#print "\n" ;
}

