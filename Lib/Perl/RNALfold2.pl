#!/usr/bin/perl
use strict;
use warnings;

open FI,$ARGV[0] || die "sorry,$!\n"; # evofold results
while(<FI>)
{
next if $.==1;
    chomp;
    my @x=split/\t/,$_;
my($chr,$start,$end,$size,$str)=@x[1..3,7..8];
 map {
my $lab=$_ eq '.'?'L':'S';
print join("\t",$chr,$start,$start,$lab),"\n";
$start++;
} (split//,$str);
}
close FI;

