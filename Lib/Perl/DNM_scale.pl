#!/usr/bin/perl
use strict;
use warnings;

my $file=$ARGV[0]; #mutations with DNM rate file: chr start end ref alt ... rate ...
my $ratecol=$ARGV[1]; #mutation rate column
my $ave=$ARGV[2]; #average mutation rate like 1.67*10-8 for exome and 1.2*10-8 for genome

my %rec;
#my $ref=1.2*0.00000001;
my $presite="NA";
open FI,$file || die "sorry$!\n";
    while(<FI>)
    {
        chomp;
        next if $.==1;
        my @x=split/\t/;
        my $site=join("\t",@x[0..4]);
        if($site ne $presite)
        {
            $rec{'sites'}++;
            $rec{'sum'}+=$x[$ratecol];
        }
        $presite=$site;
    }
    close FI;

my $sf=($rec{'sites'}*$ave)/($rec{'sum'}*3);

open FI,$file || die "sorry$!\n";
while(<FI>)
{
    chomp;
    if ($.==1){print $_,"\n";next};
    my @x=split/\t/;
    $x[$ratecol]=$x[$ratecol]*$sf;
    print join("\t",@x),"\n";
}
close FI;
