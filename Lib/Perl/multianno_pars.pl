#!/usr/bin/perl
use strict;
use warnings;
#use Math::BigFloat;
#use List::Util qw(first);

#my @keys_out=qw(Chr Start End Ref Alt Gene Mutation_type Transcripts Exons Base_change Aa_change cytoBand CLNACC dbSNP gwasCatalog 1000G ESP6500 ExAC phastConsElements46way SIFT_pred Polyphen2_HDIV_pred Polyphen2_HVAR_pred LRT_pred MutationTaster_pred MutationAssessor_pred FATHMM_pred RadialSVM_pred LR_pred MetaSVM_score CADD_raw GERP++_RS phyloP100way_vertebrate SiPhy_29way_logOdds);

my @keys_out=qw(Chr Start End Ref Alt Gene Mutation_type Transcripts Exons Base_change Aa_change cytoBand CLNACC dbSNP gwasCatalog 1000G ESP6500 ExAC phastConsElements46way SIFT_pred Polyphen2_HDIV_pred Polyphen2_HVAR_pred LRT_pred MutationTaster_pred MutationAssessor_pred FATHMM_pred RadialSVM_pred LR_pred CADD_raw GERP++_RS phyloP100way_vertebrate SiPhy_29way_logOdds);

#push(@keys_out,$ARGV[1]); #add ExAC subpopulation

print join("\t",@keys_out),"\n";

my %rec;
my @colnames;
open(FI,$ARGV[0]) || die "sorry,$!\n";
while (<FI>)
{
    chomp;
    my @x=split/\t/,$_;
    #next if $x[9] eq '-' || $x[9] eq 'UNKNOWN';
    
    if ($.==1)
    {
        @colnames=@x;
        map {
        if ($colnames[$_] eq 'ExonicFunc.refGene') {$colnames[$_]='Mutation_type'}
        if ($colnames[$_] eq 'Gene.refGene') {$colnames[$_]='Gene'}
        if ($colnames[$_]=~/snp/) {$colnames[$_]='dbSNP'}
        if ($colnames[$_]=~/1000g/) {$colnames[$_]='1000G'}
        if ($colnames[$_]=~/esp6500/) {$colnames[$_]='ESP6500'}
        if ($colnames[$_] eq $ARGV[1]) {$colnames[$_]='ExAC'}
        } 0..$#colnames;
        
        next
    };
    
    map {$rec{$colnames[$_]}=$x[$_]} 0..$#colnames;
    
    my @trans;
    my @exons;
    my @y=split/,/,$rec{'AAChange.refGene'};
    #print $rec{'AAChange.refGene'};
    
    map {
        my @z=split/:/,$_;
        push(@trans,$z[1]);
        push(@exons,$z[2]);
        $rec{'Base_change'}=$z[3];
        $rec{'Aa_change'}=$z[4];
        } @y;
    
    $rec{'Transcripts'}=join(';',@trans);
    $rec{'Exons'}=join(';',@exons);
    
    if ($rec{'gwasCatalog'} ne '-') {$rec{'gwasCatalog'}=~/Name=(.+)/;$rec{'gwasCatalog'}=$1}
    
    if ($rec{'phastConsElements46way'} ne '-')
    {
        $rec{'phastConsElements46way'}=~/Score=(.*);Name/;
        $rec{'phastConsElements46way'}=$1;
    }
    
    print join("\t",@rec{@keys_out}),"\n";
}
