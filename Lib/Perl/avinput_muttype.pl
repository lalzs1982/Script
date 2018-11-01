#!/usr/bin/perl
use strict;
use warnings;
#append nonstranded mutation type
my %muttype=("AT"=>"AT_TA","AC"=>"AT_CG","AG"=>"AT_GC",
"TA"=>"AT_TA","TG"=>"AT_CG","TC"=>"AT_GC",
"GC"=>"GC_CG","GA"=>"GC_AT","GT"=>"GC_TA",
"CG"=>"GC_CG","CT"=>"GC_AT","CA"=>"GC_TA");

open FI,$ARGV[0];
while(<FI>)
{
chomp;
my @x=split/\t/;
my $mut=uc($x[3]).uc($x[4]);
my $muttype=defined $muttype{$mut}?$muttype{$mut}:"NA";
if($muttype ne "NA")
{
print join("\t",@x[0..4],$muttype),"\n";
}
}
close FI;

