#!/usr/bin/perl
use strict;
use warnings;

my %rec;
my %compl=('A'=>'U','G'=>'C','U'=>'A','C'=>'G');
my %uni;
open FI,$ARGV[0] || die "sorry$!\n"; #mutations and coordinates
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my ($id,$pos,$ref,$alt,$str)=@x[0,1,3,4,5];
next if(length($ref)>1 || length($alt)>1 || $ref eq '-' || $alt eq '-');
$ref=uc($ref);$alt=uc($alt);
$ref=$ref eq 'T'?'U':$ref;$alt=$alt eq 'T'?'U':$alt; #T -> U
$rec{$id}{"$pos:$ref:$alt:$str"}=1;
}
close FI;


my @mut;
my $id;
my $mutseq;
open FI, $ARGV[1] || die "sorry$!"; #fasta file
while(<FI>)
{
chomp;
if($_=~/^>(.*)/){
#print STDERR "have it $1\n";

if(defined $rec{$1}){
$id=$1;
@mut=keys%{$rec{$id}};
}else{@mut=()} #print $_,"\n";
}elsif(scalar(@mut)>0){
for my $mut(@mut)
{
my ($pos,$ref,$alt,$str)=(split /:/,$mut);
$mutseq=$_;
my $reff=uc(substr($mutseq,$pos,1)); if($str eq '-'){$reff=$compl{$reff}}
if($ref ne $reff){print STDERR "Error! $id,$mutseq\n";next}
if($str eq '-'){$alt=$compl{$alt}};
substr($mutseq,$pos,1,$alt);
print ">$id\n$mutseq\n";
}
}}
close FI;
