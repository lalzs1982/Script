#!/usr/bin/perl
use strict;
use warnings;

my %rec=();
open FI,$ARGV[0] || die "sorry,$!\n"; #emf file download from ensembl for genome alignments
while(<FI>)
{
    chomp;
    next if $_=~/^#|DATA|macaca_mulatta/;
    next if $_ eq '' || $_ eq '//';
    if($_=~/^SEQ/ && $_=~/homo_sapiens/)
    {
        if( scalar(keys%rec)>0)
        {
        print join(":",$rec{'M'},$rec{'S'},$rec{'I'},$rec{'D'}),"\n";
        }
        my @xx=split/\s+/,$_;
        my $str=$xx[5]==1?'+':'-';
        print join("\t","chr$xx[2]",@xx[3..4],"chr$xx[2]:$xx[3]-$xx[4]",0,$str),"\t";
        map {$rec{$_}=0} qw(M D I S);
        next;
    }
    
    
    my @aa=split//,$_;
    if(uc($aa[0]) eq uc($aa[1])){$rec{'M'}+=1;next};
    if($aa[0] eq '-'){$rec{'D'}+=1;next};
    if($aa[1] eq '-'){$rec{'I'}+=1;next};
    $rec{'S'}+=1;
}
print join(":",$rec{'M'},$rec{'S'},$rec{'I'},$rec{'D'}),"\n";
close FI;
