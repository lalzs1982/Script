#!/bin/bash
module load bedtools
ref=$1 #human genome reference
coor=$2 # bed file
fl=$3 #flank region sizes

#awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2-1,$3,$4" "$7,0,$7}' $coor > $coor.1
awk -v fl="$fl" 'BEGIN{FS="\t";OFS="\t"}$2-fl-1>0{print $1,$2-fl-1,$3+fl,$1":"$2":"$3":"$4":"$5,0,"+"}' $coor > $coor.1
bedtools getfasta -fi $ref -bed $coor.1 -s -name -fo $coor.fa
#~/code/mutation_annotation/T2U.pl $coor.fa > $coor.1.fa
~/code/mutation_annotation/T2U.pl $coor.fa | awk 'BEGIN{FS="::";}{print $1}' > $coor.1.fa

mv $coor.1.fa $coor.fa
rm -f $coor.1

#warnings: the bedtools cut sequence from  1+start(small coor) to the end!, no problem after adjustment
