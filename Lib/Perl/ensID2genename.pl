#!/usr/bin/perl
use strict;
use warnings;

my %id;
open FI,$ARGV[0]; #gtf file including gene ID and name
while(<FI>)
{
$_=~/gene_id=(.*?)\.\d+;/;
my $id=$1;
$_=~/gene_name=(.*?);/;
my $name=$1;

$id{$id}=$name;
}
close FI;

open FI,$ARGV[1]; #tab delimited file
while(<FI>)
{
chomp;
my @x=split/\t/;

map {
my @y=split/;/,$x[$_];
map {
if(defined $id{$y[$_]}){$y[$_]=$id{$y[$_]}}
} 0..$#y;

$x[$_]=join(';',@y);

} 0..$#x;

print join("\t",@x),"\n";
}
close FI;

