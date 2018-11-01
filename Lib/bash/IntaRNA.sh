#!/bin/bash
module load bedtools

mutations=$1 #bed mutations on hg19, /project2/xinhe/zhongshan/DNM/DNM_org/DNM_comb.asd.control.wgs
target=$2 #fasta /project2/xinhe/zhongshan/data/Gencode/hg19/gencode.v19.pc_transcripts.fa
regions=$3 #gtf or bed for mutation filtering,  /project2/xinhe/zhongshan/data/Gencode/hg19/gencode.v27.long_noncoding_RNAs.hg19.gtf
genome="/project2/xinhe/zhongshan/data/hg19.fa" #

fl=100 #bases around the mutations
awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$3,$3,$1":"$2"-"$3}' $mutations > ./forIntaRNA.bed
bedtools intersect -wo -a ./forIntaRNA.bed -b $regions | awk -v fl=$fl 'BEGIN{FS="\t";OFS="\t"}$7=="exon"{print $1,$3-fl,$3+fl,$4,"0",$11}' | sort -k1,1 -k2,2n |uniq > ./forIntaRNA1.bed

bedtools getfasta -fi $genome -bed ./forIntaRNA1.bed -s -name -fo ./forIntaRNA.bed.fa
#note, here we use gtf for $coor, sequence is accurate,
#but the left cordinates on resultant fa file name line should add 1 to match that of gtf

#/home/zhongshan/software/IntaRNA-2.1.0-linux-64bit -q ./forIntaRNA.bed.fa -t $target --out /project2/xinhe/zhongshan/IntaRNA
#echo "finshed: /project2/xinhe/zhongshan/IntaRNA"

/home/zhongshan/software/RIblast db -i $target -o $target.RIblast.db
/home/zhongshan/software/RIblast ris -i ./forIntaRNA.bed.fa -o /project2/xinhe/zhongshan/RIblast.re -d $target.RIblast.db
