#!/usr/bin/perl

my $id;
my $cols=0;

open FI,$ARGV[0] || die "$!"; #RNAsnp results
while(<FI>)
{
chomp;
if($_=~/^>(.*)/){$id=$1;next};
if($_=~/^SNP/){if($cols==0){print join("\t","ID",$_),"\n";$cols=1};next}
my @x=split/\s+/;
if($x[0]=~/\d+/){
#print "number before:$x[0] ... $_ \n";
print join("\t",$id,$_),"\n";
}
}
close FI;

