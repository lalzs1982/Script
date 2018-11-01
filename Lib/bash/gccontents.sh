#!/bin/bash
module load bedtools
bed=$1
flank=$2
ref="/home/zhongshan/data/hg19.fa"
awk -v flank=$flank 'BEGIN{FS="\t";OFS="\t"}{print $1,$2-flank,$2+flank,$1":"$2":"$3}' $bed  > $bed.fl
#awk 'BEGIN{FS="\t";OFS="\t"}NR>1{print $4,$6}' $bed.fl | awk -F ":|\t" '{print $1,$2,$3,$4}' > $bed1.fl
bedtools nuc -fi $ref -bed $bed.fl | awk 'BEGIN{FS="\t";OFS="\t"}NR>1{print $4,$6}' | awk -F ":|\t" 'BEGIN{OFS="\t"}{print $1,$2,$3,$4}' > $bed.gccontent


