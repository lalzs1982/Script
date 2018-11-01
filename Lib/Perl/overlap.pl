#!/usr/bin/perl
use strict;
use warnings;

#overlap two files using specified columns, note the first file should be larger, and all of its columns printed

my $col1=$ARGV[2]; #comma seperated list of columns for first file
my $col2=$ARGV[3]; #comma seperated list of columns for second file

my @cols1=split /,/,$col1;
my @cols2=split /,/,$col2;

my %rec;
open FI,$ARGV[1]; #small file
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my $key=join("\t",@x[@cols2]);
$rec{$key}=$_;
}
close FI;

open FI,$ARGV[0]; #large file
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my $key=join("\t",@x[@cols1]);
my $app=defined $rec{$key}?$rec{$key}:"NULL";
print join("\t",$_,$app),"\n" 
}
close FI;
