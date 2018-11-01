#!/usr/bin/perl
use strict;
use warnings;

my %rec;
my $col;
open FI,$ARGV[0] || die "sorry$!\n";
while(<FI>)
{
if ($.==1){print;next};
chomp;
my @x=split/\t/,$_;
my $id=join("\t",@x[0..4]);
map {$rec{$id}{$_}{$x[$_]}=1} 5..$#x;
$col=$#x;
}
close FI;

for my $id(keys%rec)
{
my @out;
map {push(@out,join(";",keys%{$rec{$id}{$_}}))} 5..$col;
print join("\t",$id,@out),"\n";
}


