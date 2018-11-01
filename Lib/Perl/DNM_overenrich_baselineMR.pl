#!/usr/bin/perl
use strict;
use warnings;
#file1: sites (col0), baseline DNM rate(col1), regions (col2) and DNMs for different studies (col3...)
#file2: sample sizes for each study
#produce summary file: reg, nt length, expected DNMs, Observed DNMs,

open FI,$ARGV[0];
my %dnm;
my @studies;
my $presite="NA";

while(<FI>) #all mutation annotaton processed 
{
    chomp;
    my @x=split/\t/;
    if($.==1){@studies=@x[3..$#x];next}
    my ($site,$rate,$reg)=@x[0..2];
    my @dnms=@x[3..$#x];
    
    $dnm{$reg}{'rate_sum'}+=$rate;
    $dnm{$reg}{'nt_sum'}+=1;
    
    my $i=0;
    map {$dnm{$reg}{$studies[$i]}+=$_;$i++} @dnms;
    
    if($site eq $presite){next}else{$presite=$site} #remove repeated lines for total
    $dnm{'total'}{'rate_sum'}+=$rate;
    $dnm{'total'}{'nt_sum'}+=1;
    $i=0;
    map {$dnm{'total'}{$studies[$i]}+=$_;$i++} @dnms;
}
close FI;

open FI,$ARGV[1]; #sample sizes
my %ss;
while(<FI>)
{
    chomp;
    my @x=split/\t/;
    $ss{$x[0]}=$x[1]
}
close FI;

print join("\t",qw(Reg Study length Baseline_MR Sample_sizes DNMs)),"\n";
for my $reg(keys%dnm,'total')
{
for my $st(@studies)
{
    print join("\t",$reg,$st,$dnm{$reg}{'nt_sum'},$dnm{$reg}{'rate_sum'},$ss{$st},$dnm{$reg}{$st}),"\n";
}
}

