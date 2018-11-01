#!/bin/bash
module load bedtools
cd /project2/xinhe/zhongshan/enhancer/
enhancer='Noonan_lifted_hg19.bed'
hic=$1 #TSS-binding sites bed from HiC datasets
#hic='nature_hiC/TableS22CP' #I have checked that the coordinates is in hg19

#1, retrive enhancers and its targets:
awk 'BEGIN{FS="\t";OFS="\t"}NR>1{print $1,$4,$5,$2,$3,$6,$7}' $hic > $hic.bed
bedtools intersect -wo -f 0.5 -a $enhancer -b $hic.bed > $hic.bed.containenhancer.bed

cut -f 1,2,3,4,5,6,7,8,9 $hic.bed.containenhancer.bed | uniq | cut -f 1,2,3,4,5,6,7 | uniq -c |sort -k1,1rn > $hic.bed.containenhancer.bed.TSSct
cut -f 1,2,3,4,5,6,7,11 $hic.bed.containenhancer.bed | uniq | cut -f 1,2,3,4,5,6,7 | uniq -c |sort -k1,1rn > $hic.bed.containenhancer.bed.Genect

awk '{print $1}' $hic.bed.containenhancer.bed.TSSct | sort|uniq -c| sort -k2,2n > $hic.bed.containenhancer.bed.TSSct.summ
awk '{print $1}' $hic.bed.containenhancer.bed.Genect | sort|uniq -c| sort -k2,2n > $hic.bed.containenhancer.bed.Genect.summ

~/code/enhancer/add_genename.pl ./Gene_id_name.txt $hic.bed.containenhancer.bed > $hic.bed.containenhancer.bed.withgenenames
#

