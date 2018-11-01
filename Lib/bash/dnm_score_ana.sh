#!/bin/bash
mutation_anno=$1 #chr,start,end,ref,alt,case/control,individual,study,and scores  example: /project2/xinhe/zhongshan/DNM/DNM_byZSL/ASD/WGS/raw/comb_snps1.anno or /project2/xinhe/zhongshan/DNM/DNM_byZSL/ASD/WGS/raw/constriant_effect_anno/comb , 
regions=$2 # chr,start,end,ID,gp,source. example: /project2/xinhe/zhongshan/data/anno.bed  
temp="/project2/xinhe/zhongshan/temp/"
module load bedtools

awk 'NR>1{print $0}' $mutation_anno > $temp/mut
awk 'BEGIN{FS="\t";OFS="\t"}NR==1{print "chr","start","end","reg_ID","reg_gp","reg_source",$0,"overlap"}' $mutation_anno > $temp/reg_mut

intersectBed -wo -a $regions -b $temp/mut >> $temp/reg_mut
~/code/DNM/dnm_score_ana.pl $temp/reg_mut > $temp/reg_mut.sum
Rscript ~/code/DNM/dnm_score_ana.r $temp/reg_mut.sum # obtain $temp/reg_mut.sum.pdf

