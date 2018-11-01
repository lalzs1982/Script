#!/usr/bin/perl

my $col1=$ARGV[2];
my $col2=$ARGV[3];

my %rec;
open FI,$ARGV[0];
while(<FI>)
{
chomp;
my @x=split/\t/,$_; $x[$col1]=lc $x[$col1];
if($x[$col1]=~/(.*?)\-[53]p/){$rec{$1}=1}else{$rec{$x[$col1]}=1};
}
close FI;

open FI,$ARGV[1];
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my $info=$_;
map {
    if(defined $rec{$_}){print $info,"\n"}
    } (split/,/, $x[$col2]);
}
close FI;


