#!/bin/bash

cd /project2/xinhe/zhongshan/DNM/DNM_byZSL/ASD/WGS
awk 'BEGIN{FS="\t";OFS="\t"}{print $6,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21}' comb1.avinput.hg19_multianno.txt > comb1.avinput.hg19_multianno.txt.1
module load R
Rscript ~/code/DNM/dnm_plot.r ./comb1.avinput.hg19_multianno.txt.1

#now we have SNP annotation data:
#/project2/xinhe/zhongshan/DNM/DNM_byZSL/ASD/WGS/comb1.forDB.snp.hg19_multianno.txt
# and known ASD genes:/project2/xinhe/zhongshan/data/ASD_genes/comb
~/code/overlap.pl /project2/xinhe/zhongshan/data/ASD_genes/comb /project2/xinhe/zhongshan/DNM/DNM_byZSL/ASD/WGS/comb1.forDB.snp.hg19_multianno.txt > /project2/xinhe/zhongshan/DNM/DNM_byZSL/ASD/WGS/comb1.forDB.snp.hg19_multianno.txt.knownASDgenes

  