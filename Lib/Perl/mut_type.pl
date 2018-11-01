#!/usr/bin/perl
use strict;
use warnings;
#decide nonstranded mutation type according to ref alt bases to accomdate Jedidiah_work/ .bw data
my %rec=(A=>"T",G=>"C",C=>"G",T=>"A",);

my $ref_c=$ARGV[1];#assume alt is in the next col
open FI,$ARGV[0]; #bed or avinput file with ref alt bases
while(<FI>)
{
chomp;
my @x=split/\t/;
my($ref,$alt)=@x[$ref_c,$ref_c+1];
my $ref_r=defined $rec{$ref}?$rec{$ref}:"NULL";
my $alt_r=defined $rec{$alt}?$rec{$alt}:"NULL";

my $muttype=$ref.$ref_r."_".$alt.$alt_r."/".$ref_r.$ref."_".$alt_r.$alt;
print join("\t",$_,$muttype),"\n";
}
close FI;


