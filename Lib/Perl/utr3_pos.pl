#!/usr/bin/perl
use strict;
use warnings;
#given  3'UTR coordinates and variants, obtain the variants distance to 3'UTR 5' end;
# the input should be bedtools result of overlap between 3'UTR coordinates and variants
my %rec;

open FI,$ARGV[0] || die "sorry,$!\n";
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my($chr,$intstart,$intend,$str,$pos)=@x[0..2,6,8];
my $relpos=$str eq '+'?($pos-$intstart):($intend-$pos);
if(!defined $rec{join("\t",$chr,$pos,$pos)} || $rec{join("\t",$chr,$pos,$pos)}>$relpos)
{
$rec{join("\t",$chr,$pos,$pos)}=$relpos;
}
}
close FI;

for my $pos(keys%rec)
{
print join("\t",$pos,$rec{$pos}),"\n";
}

