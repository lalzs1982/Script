#!/usr/bin/perl
use strict;
use warnings;

my $id;
open FI,$ARGV[0] || die "sorry,$!\n"; # RNALfold results
while(<FI>)
{
    chomp;
    my @x=split/\s+/,$_;
    if($_=~/>(.*)/){
        $id=$1;
        next
        };
    next if $_!~/\(\(/;
                  
    my $start1=$x[-3];
my $z=$x[-1];
next if $z > -2;

#    $x[-3]=~/\(?(.*)\)/;
#    my $score=$1;
#	my $len=length($x[0]);
#next if($len<50 || $score > -2);    

    map {
my $lab=$_ eq '.'?'L':'S';
print join("\t",$id,$start1,$start1,$lab),"\n";
$start1++;        
} (split//,$x[0]);
}
close FI;

