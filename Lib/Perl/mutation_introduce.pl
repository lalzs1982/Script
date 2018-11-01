#!/usr/bin/perl
use strict;
use warnings;

my %rec;
my %compl=('A'=>'U','G'=>'C','U'=>'A','C'=>'G');
open FI,$ARGV[0] || die "sorry$!\n"; #mutations and ref sequence coordinates
while(<FI>)
{
chomp;
my @x=split/\t/,$_;
my ($int_start,$int_end,$str,$pos,$ref,$alt)=@x[1,2,3,5,7,8];
next if(length($ref)>1 || length($alt)>1 || $ref eq '-' || $alt eq '-');
$ref=uc($ref);$alt=uc($alt);
$ref=$ref eq 'T'?'U':$ref;$alt=$alt eq 'T'?'U':$alt;
my $ref_alt=$str eq '+'?("$ref>$alt"):(join(">",$compl{$ref},$compl{$alt}));
my $id="$x[0]:$x[1]-$x[2]";
$rec{$id}{"$pos:$ref_alt"}=1;
}
close FI;

my @mut;
my $id;
my $mutseq;
open FI, $ARGV[1] || die "sorry$!"; #fasta file
while(<FI>)
{
chomp;
if($_=~/^>(.*?)\s/){
if(defined $rec{$1}){
print $_,"\t",join (",",keys%{$rec{$1}}),"\n";
@mut=keys%{$rec{$1}};
$id=$_;
}else{@mut=()} #print $_,"\n";
}elsif(scalar(@mut)>0){
$id=~/(\d+)\-(\d+)/;
my ($start,$end)=($1,$2);
my $str=(split/\s+/,$id)[1];
$mutseq=$_;

for my $mut(@mut)
{
my ($pos,$ref,$alt)=(split /[:>]/,$mut);
my $rel_pos=$str eq '+'?($pos-$start):($end-$pos); #the rel position start from 0!
substr($mutseq,$rel_pos,1,$alt)
#my $reff=uc(substr($mutseq,$rel_pos,1));
#if($reff ne $ref){print STDERR "wrong here! $reff != $ref,$id,$start,$end,$pos,$rel_pos\n"}
}

print $mutseq,"\n";
}
}
close FI;
