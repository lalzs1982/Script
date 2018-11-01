#!/usr/bin/perl
use strict;
use warnings;

my %rec;
my $rows=0;
my @colnames;
my @ids;
open(FI,$ARGV[0]) || die "sorry,$!\n";
while (<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    if ($.==1)
    {
        @colnames=@x;
        next;
    };
    map {
        if(!defined $rec{$colnames[$_]}){$rec{$colnames[$_]}=0};
        if($x[$_] ne 'NA' && $x[$_] ne 'No' && $x[$_] ne '0'){$rec{$colnames[$_]}++}
        } 1..$#x;
    $rows++;
}
close FI;

open(FI,$ARGV[0]) || die "sorry,$!\n";
while (<FI>)
{
    chomp;
    my @out;
    my @x=split/\t/,$_;
    map {
        #print STDERR "it is", $rec{"$colnames[$_]"}, "and $rows \n";
        if(!defined $rec{$colnames[$_]}){print STDERR "$_ : $colnames[$_] : \n";}
        if(defined $rec{$colnames[$_]} && $rec{$colnames[$_]}/$rows>$ARGV[1]){push(@out,$x[$_])}
        } 1..$#x;
    print join("\t",$x[0],@out),"\n";
}
close FI;
