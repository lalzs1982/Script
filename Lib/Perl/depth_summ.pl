#!/usr/bin/perl
use strict;
use warnings;

my %rec;
foreach my $input (@ARGV){
my $filename=(split("/",$input))[-1];
open FI,$input;
while(<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    my($depth,$length)=@x[3,4];
    $rec{$filename}{$depth}+=$length;
}
close FI;
}

for my $filename(keys%rec)
{
    for my $depth(keys%{$rec{$filename}})
    {
        print join("\t",$filename,$depth,$rec{$filename}{$depth}),"\n";
    }
}
