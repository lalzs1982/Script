#!/bin/bash
module load bedtools
seq=$1 #fasta format, with coordinates, strand in ID
mut=$2 #avinput format
/project2/xinhe/zhongshan/UTR3/UTRs/tobed.pl $seq > $seq.bed
bedtools intersect -wo -a $seq.bed -b $mut > $seq.bed.withmut
#~/code/mutation_annotation/mutation_introduce.pl $seq.bed.withmut $seq > $seq.withmutat.fa
~/code/mutation_annotation/mutation_introduce1.pl $seq.bed.withmut $seq > $seq.withmutat1.fa
 