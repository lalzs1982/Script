#!/usr/bin/perl
use strict;
use warnings;

system ("rm -f $ARGV[0].RNAsnpresult");
open OUT3, ">>$ARGV[0].RNAsnpresult" || die "sorry$!";

#my %compl=('A'=>'U','G'=>'C','U'=>'A','C'=>'G');

my $id;
my($ref,$alt);

open FI,$ARGV[0] || die "sorry$!\n"; # fasta file with middle postion mutated, mutation defined on header
while(<FI>)
{
    chomp;
    #if($_=~/>/){$id=$_;my @y=split/:/,$_; ($ref,$alt)=@y[3..4]; next};
    if($_=~/>/){my @y=split/\t/,$_;$id=$x[0]; $x[1]=~/([ACGUT])\d+([ACGUT])/;($ref,$alt)=($1,$2); next};
    #next if ($id!~/([atcg])>([atcg])/i);
    
    my ($seq,$snp);
     $seq=$_;
    
    my($ref,$alt)=(uc($1),uc($2));
    $ref=$ref eq 'T'?'U':$ref;
    $alt=$alt eq 'T'?'U':$alt;
    
    my $length=length($_);
    my $midbase=uc(substr($_,int($length/2),1));
    if($midbase ne $ref && $midbase ne $compl{$ref}){print STDERR "$midbase, $ref no match!\n"}
    $snp=$midbase eq  $ref?(join("",$ref,1+int($length/2),$alt)):(join("",$compl{$ref},int($length/2),$compl{ $alt}));
    #system("rm -f ./tt.seq; rm -f ./tt.snp");
    
    #print STDERR "it is dealling with $snp now\n";
    my $ran=int(rand(1000));    
    open OUT1, ">/project2/xinhe/zhongshan/temp/tt.$ran.seq" || die "sorry$!";
    open OUT2, ">/project2/xinhe/zhongshan/temp/tt.$ran.snp" || die "sorry$!";
    print OUT1 "$id\n$seq\n";
    print OUT2 "$snp\n";
    close OUT1; close OUT2;
    
    print OUT3 "$id\n";
    system ("/home/zhongshan/software/bin/RNAsnp -f /project2/xinhe/zhongshan/temp/tt.$ran.seq -s /project2/xinhe/zhongshan/temp/tt.$ran.snp >> $ARGV[0].RNAsnpresult");
    system("rm -f /project2/xinhe/zhongshan/temp/tt.$ran.seq");
    system("rm -f /project2/xinhe/zhongshan/temp/tt.$ran.snp");
}

close OUT3;
