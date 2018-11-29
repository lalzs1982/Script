#!/usr/bin/perl
#this script can be used to analyze big table file, to get values sum for groups from specific columns, like col1 is scores, col2 for different genes, then get sum of scores for each gene, as well as for all genes
#note: the first row should be column names
use strict;
use warnings;

my $table_file=$ARGV[0];
my @cate_cols=split/,/,$ARGV[1]; #columns for groups/categories, index start from 0
my @value_cols=split/,/,$ARGV[2]; #columns for values (maybe also category, then overlap with groups/categories above will be calculated), index start from 0

my %rec; #recorde value for each category
my @colnames; #names
open FI,$table_file || die "sorry$!\n";
while(<FI>)
{
chomp;

my @x=split/\t/;
if($.==1){@colnames=@x;next}

my %cate=(); #record all category IDs
map {
if($x[$_] ne "." && $x[$_] ne "-" && $x[$_] ne "NA" && $x[$_] ne "NULL"){
my $cn=$colnames[$_];
my @y=split/;/,$x[$_];
for my $y(@y){$cate{"$cn:$y"}=1};
$cate{"$cn:total"}=1;
}
} @cate_cols;

my %values; #record all values or category counts from the value columns
map {
if($x[$_] ne "." && $x[$_] ne "-" && $x[$_] ne "NA" && $x[$_] ne "NULL"){
my $cn=$colnames[$_];

#if($x[$_]!~/[A-Z]/i){$values{$cn}{"Value"}=$x[$_]}else{
if($x[$_]=~/^-?(0|([1-9][0-9]*))(\.[0-9]+)?([eE][-+]?[0-9]+)?$/){$values{$cn}{"Value"}=$x[$_]}else{
my @y=split/;/,$x[$_];
map {$values{$cn}{$_}=1} @y;
$values{$cn}{"total"}=1;
}}} @value_cols;

#add up and put all values for each region, category into one hash
for my $cn(keys%values)
{
for my $sub_cn(keys%{$values{$cn}}){
for my $cate(keys%cate){
$rec{$cate}{$cn}{$sub_cn}+=$values{$cn}{$sub_cn};
}}}

}
close FI;

for my $reg(keys%rec)
{
for my $cn(keys%{$rec{$reg}}){
for my $cate(keys%{$rec{$reg}{$cn}}){
print join("\t",$reg,"$cn:$cate",$rec{$reg}{$cn}{$cate}),"\n";
}}}

