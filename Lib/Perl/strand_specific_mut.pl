#!/usr/bin/perl
use strict;
use warnings;

my %compl=(A=>"T",G=>"C",T=>"A",C=>"G"); 
open FI,$ARGV[0] || die "$!";
while(<FI>)
{
chomp; 
my @x=split/\t/;
next if(length($x[2])>1 || length($x[3])>1 || $_=~/\.\/\./);
my @lab=split/:/,$x[4];
my @nums=split/:/,$x[5];
my($ref_c,$alt_c); 
map {if($lab[$_] eq "AD"){$nums[$_]=~/(\d+)\,(\d+)/;($ref_c,$alt_c)=($1,$2)};} 0..$#nums; 
my $str=$x[6]; my($ref,$alt)=@x[2,3]; if($str eq '-'){$ref=$compl{$x[2]};$alt=$compl{$x[3]}}; 
print join("\t",$x[0],$x[1]-1,$x[1],$ref,$alt,$ref_c,$alt_c),"\n";
}
close FI;




