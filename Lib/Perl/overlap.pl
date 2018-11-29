#!/usr/bin/perl
use strict;
use warnings;

#overlap two files using specified columns, note the first file should be larger, and all of its columns printed

my $col1=$ARGV[2]; #comma seperated list of columns for first file
my $col2=$ARGV[3]; #comma seperated list of columns for second file

my @cols1=split /,/,$col1;
my @cols2=split /,/,$col2;

my %rec;
if($ARGV[1]=~/\.gz$/){open FI,"gunzip -c $ARGV[1]|"}else{open FI,$ARGV[1]}; #second file, better small
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my $key=join("\t",@x[@cols2]);
$rec{$key}{$_}=1;
}
close FI;

if($ARGV[0]=~/\.gz$/){open FI,"gunzip -c $ARGV[0]|"}else{open FI,$ARGV[0]}; ##first file, better large
while(<FI>)
{
chomp;
my $info=$_;
my @x=split/\t/,$_;
my $key=join("\t",@x[@cols1]);
if(defined $rec{$key})
{
map {
print join("\t",$info,$_),"\n";
} keys%{$rec{$key}}
}else{print join("\t",$_,"NOOVERLAP"),"\n" }
}
close FI;

