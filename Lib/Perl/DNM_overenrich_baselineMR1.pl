#!/usr/bin/perl
use strict;
use warnings;
#file1: DNM for different studies: chr1	897349	897349	G	A	ASD	14505.pM	2508	Iossifov_Nature2014
#file2: nucleotide level annotations including base line mutation rate: chr     start   end     ref     alt     gene    mutationrate    mut_type        spidex  targetscan      RBP_Clip        FIMO
#file3: sample sizes for different studies: study sample_sizes
#produce summary file: Group, reg, nt length, expected DNMs, Observed DNMs,

open FI,$ARGV[0]; #DNM lists
my %dnm;
my %studies;
while(<FI>)
{
    chomp;
    my @x=split/\t/;
    next if $#x<8;
    my $nt=join("\t",@x[0..4]);
    my $st=join("_",@x[8,5]);
    $dnm{$nt}{$st}=1;
    $studies{$st}=1;
}
close FI;

#my @studies;
my $presite="NA";
my %rec;
my @groups;
open FI,$ARGV[1]; #all mutation annotatons 
while(<FI>) 
{
    chomp;
    my @x=split/\t/;
    if($.==1){@groups=@x[7..$#x];next}
    
    my $nt=join("\t",@x[0..4]);
    my $rate=$x[6];
    my @regs=@x[7..$#x];

    my $i=0; #recorde which region
    #print STDERR "\nthis is $.\n ";
    map {
    my $reg=$_;
    
    #print STDERR "this is $gp ";

    #if($gp eq 'GP:RNAsnpM3'){print STDERR "this is $nt and $presite , skipped ... \n"}

    if (!($reg eq '.' || $reg eq '-' || $reg eq 'NA' || $reg eq 'NULL'))
    {
    my $gp="GP:$groups[$i]";
    $rec{$gp}{$reg}{'rate_sum'}+=$rate;
    $rec{$gp}{$reg}{'nt_sum'}+=1;
    if($nt ne $presite){$rec{$gp}{'total'}{'rate_sum'}+=$rate; $rec{$gp}{'total'}{'nt_sum'}+=1;
                        }
    if(defined $dnm{$nt})
    {
    map {
    if(defined $dnm{$nt}{$_}){
    $rec{$gp}{$reg}{$_}+=1;
    if($nt ne $presite){$rec{$gp}{'total'}{$_}+=1;}}} keys%studies;
    }
    }
    
    $i++;
    } @regs;
    
    $presite=$nt;
}
close FI;

open FI,$ARGV[2]; #sample sizes
my %ss;
while(<FI>)
{
    chomp;
    my @x=split/\t/;
    $ss{$x[0]}=$x[1]
}
close FI;

print join("\t",qw(Group Reg Study length Baseline_MR Sample_sizes DNMs)),"\n";
for my $gp(keys%rec)
{

for my $reg(keys%{$rec{$gp}})
{
for my $st(keys%studies)
{
    my $nt_sum=defined $rec{$gp}{$reg}{'nt_sum'}?$rec{$gp}{$reg}{'nt_sum'}:0;
    my $rate_sum=defined $rec{$gp}{$reg}{'rate_sum'}?$rec{$gp}{$reg}{'rate_sum'}:0;
    my $nt_st=defined $rec{$gp}{$reg}{$st}?$rec{$gp}{$reg}{$st}:0;
    
    print join("\t",$gp,$reg,$st,
               $nt_sum,
               $rate_sum,
               $ss{$st},
               $nt_st),"\n";
}
}
}
