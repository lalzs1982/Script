#!/bin/bash
#give list of variants and one fasta file, predict which RNA secondary structure the mutation in
fa=$1; #the header of fasta file should include its genomic coordinates
var=$2; #avinput format

if ! [ -f $fa.RNALfold ]; then
echo "~/software/ViennaRNA/bin/RNALfold -i $fa > $fa.RNALfold;"
~/software/ViennaRNA/bin/RNALfold -i $fa > $fa.RNALfold; #this is time consuming
perl -e 'while(<>){if($_=~/>(chr.*):(\d+)\-(\d+)/){chomp;my @x=split/\s+/,$_; print join("\t",$1,$2,$3,$x[1]),"\n";}}' $fa.RNALfold > $fa.bed
fi

module load bedtools
bedtools intersect -wo -a $fa.bed -b $var > $var.tt1.bed #-f 1
~/code/RNALfold.pl $var.tt1.bed $fa.RNALfold > $var.RNALfold


