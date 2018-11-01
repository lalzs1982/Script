#!/bin/bash
module load bedtools

gtf='/project2/xinhe/zhongshan/data/hg19_ensGene.gtf'
gtf1='/project2/xinhe/zhongshan/data/hg19_refGenes_exons.gtf'
darned='/project2/xinhe/zhongshan/data/DARNED_hg19.bed'
vcfdir=$1 #'/project2/xinhe/zhongshan/RNA/TC/output/' #VCF files produced by GATK and also gene expression by cufflinks

cat /dev/null > $vcfdir/allmut
for file in `ls $vcfdir | grep ".vcf$"`
do
echo "it is dealing with $vcfdir/$file to obtain $vcfdir/$file.inter ...\n";
bedtools intersect -wo -a $vcfdir/$file -b $gtf1 | cut -f 1,2,4,5,9,10,17 > $vcfdir/$file.inter.0 #the cut columns should be changed for different files 
~/code/RNAediting/strand_specific_mut.pl $vcfdir/$file.inter.0 > $vcfdir/$file.inter;
awk -v file=$file 'BEGIN{FS="\t";OFS="\t"}{print $0,file}' $vcfdir/$file.inter >> $vcfdir/allmut
rm -f $vcfdir/$file.inter*
done

#whether DARNED: 0 at last column means no, others means yes
bedtools intersect -c -a $vcfdir/allmut -b $darned > $vcfdir/allmut.0; mv $vcfdir/allmut.0 $vcfdir/allmut

#get ADAR gene expression
cat /dev/null > $vcfdir/adarexpr
for file in `ls $vcfdir | grep "genes.fpkm_tracking$"`
do
awk -v file=$file 'BEGIN{FS="\t";OFS="\t"}{print $1,$10,file}' $vcfdir/$file | grep ADAR >> $vcfdir/adarexpr
done

#make summary and plots by R
mkdir $vcfdir/summplots
#Rscript ~/code/RNAediting/editinglevel_comp.r $vcfdir/allmut $vcfdir/adarexpr $vcfdir/summplots #note this is for thyroid cancer data

#for ADAR knock down data:
Rscript ~/code/RNAediting/editinglevel_comp1.r $vcfdir/allmut $vcfdir/adarexpr $vcfdir/summplots #note this is for thyroid cancer data

#obtain all plots under $vcfdir/summplots
#
#file1=$1; #vcf file or variants
#file2=$2; #known RNA editing sites
#module load bedtools
#echo "bedtools intersect -wo -a $file2 -b $file1 > $file1.editlevel "
#bedtools intersect -wo -a $file2 -b $file1 | awk 'BEGIN{FS="\t";OFS="\t"}$3==$8{print $0}' > $file1.editlevel
#./code/editinglevel_fromVCF.pl $file1.editlevel > $file1.editlevel1

