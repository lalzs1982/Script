#!/bin/bash
module load bedtools

gtf='/project2/xinhe/zhongshan/data/hg19_ensGene.gtf'
gtf1='/project2/xinhe/zhongshan/data/hg19_refGenes_exons.gtf'
vcfdir=$1 #'/project2/xinhe/zhongshan/RNAediting/TC/output/final/'

for file in `ls $vcfdir | grep ".vcf$" | head -n 1`
do
    echo "it is dealing with $vcfdir/$file to obtain $vcfdir/$file.inter ...\n";
bedtools intersect -wo -a $vcfdir/$file -b $gtf1 | cut -f 1,2,4,5,9,10,17 > $vcfdir/$file.inter.0 #the cut columns should be changed for different files 
~/code/RNAediting/strand_specific_mut.pl $vcfdir/$file.inter.0 > $vcfdir/$file.inter; rm -f $vcfdir/$file.inter.0
done
