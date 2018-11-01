#!/usr/bin/perl
use strict;
use warnings;

system ("rm -f $ARGV[0].RNAsnpresult");
open OUT3, ">>$ARGV[0].RNAsnpresult" || die "sorry$!";

#my %compl=('A'=>'U','G'=>'C','U'=>'A','C'=>'G');
my %rec;
open FI,$ARGV[0] || die "sorry$!\n"; # mutations file: chr pos ref alt
while(<FI>)
{
    chomp;
    my @x=split/\t/;
    $rec{$x[0]}{"$x[2]$x[1]$x[3]"}=1;
}
close FI;

my ($id,$seq,$snp);
#my($ref,$alt);
my $lock=0;
open FI,$ARGV[1] || die "sorry$!\n"; # fasta file
while(<FI>)
{
    chomp;
    print STDERR "$.\n";
    #if($_=~/>/){$id=$_;my @y=split/:/,$_; ($ref,$alt)=@y[3..4]; next};
    #if($_=~/>/){my @x=split/\t/,$_;$id=$x[0]; $snp=$x[1];next}
    if($_=~/>(.*)/){if(defined $rec{$1}){$id=$_;$snp=join("\n",keys%{$rec{$1}});$lock=1}else{$lock=0};next}
     next if $lock==0;
     $seq=$_;
    
    #print STDERR "it is dealling with $snp now\n";
    my $ran=int(rand(1000));    
    open OUT1, ">/project2/xinhe/zhongshan/temp/tt.$ran.seq" || die "sorry$!";
    open OUT2, ">/project2/xinhe/zhongshan/temp/tt.$ran.snp" || die "sorry$!";
    print OUT1 "$id\n$seq\n";
    print OUT2 "$snp\n";
    close OUT1; close OUT2;
    
    print OUT3 "$id\n";
    system ("/home/zhongshan/software/bin/RNAsnp -f /project2/xinhe/zhongshan/temp/tt.$ran.seq -s /project2/xinhe/zhongshan/temp/tt.$ran.snp >> $ARGV[0].RNAsnpresult");
    #system("rm -f /project2/xinhe/zhongshan/temp/tt.$ran.seq");
    #system("rm -f /project2/xinhe/zhongshan/temp/tt.$ran.snp");
}

close OUT3;
