#!/usr/bin/perl
use strict;
use warnings;
#input genome, gtf for regions, and length of mers

sub reverse_complement_IUPAC 
{
   my $dna = shift;
   my $revcomp = reverse($dna);
   $revcomp =~ tr/ABCDGHMNRSTUVWXYabcdghmnrstuvwxy/TVGHCDKNYSAABWXRtvghcdknysaabwxr/;
   return $revcomp;
}

my %genome;
open FI,$ARGV[0]; #genome fasta file
while(<FI>)
{
chomp;
if($_=~/>(.*)/){$genome{$1}=''}else{$genome{$1}.=$_}
}
close FI;

open FI,"$ARGV[1]"; #bed file, should merged before
my $fl=$ARGV[2]; # #bp flanking each position;
my $len=2*$fl+1;

while(<FI>)
{
chomp;
my @x=split/\t/;
next if !defined $genome{$x[0]};
map {
my $pos=$_;
my $mer=substr($genome{$x[0]},$pos-$fl-1,$len);
$mer=uc($mer);
my $midbase=substr($mer,$fl,1);
if($midbase eq "G" || $midbase eq "T"){$mer=reverse_complement_IUPAC($mer);$midbase=reverse_complement_IUPAC($midbase)};
map {
   if($midbase ne $_){print join("\t",@x,$pos, $mer,$midbase,$_),"\n"}
   } qw(A T G C);

} ($x[1]..$x[2]); 
};
close FI;

