#!/bin/bash
module load bedtools
#now we have one sequence database(fasta), one binding motif file in meme format and a mutations list, we want to
#scan for motif matches on sequence databases and estimate mutation effects on binding using the fimo software
#data
utrcoor='/project2/xinhe/zhongshan/UTR3/UTRs/UTR3_coor_hg19_longestUTR_coding'
database='/project2/xinhe/zhongshan/UTR3/UTRs/UTR3_coor_hg19_longestUTR_coding.fa'
#motif="/project2/xinhe/zhongshan/UTR3//CisBP-RNA/Human/motif_withname.meme"
#Hu_pfm_CisBP="/project2/xinhe/zhongshan/UTR3/CisBP-RNA/Human/motif_withname.meme"
#motif="/project2/xinhe/zhongshan/UTR3/RBPDB_database/motif_withnames.meme"
motif=$1
mutations=$2
#mutations="/project2/xinhe/zhongshan/UTR3/ExAC/ExAC.r1.sites.vephg19_common.3UTR.vcf.avinput"
#output='/project2/xinhe/zhongshan/UTR3/UTRs/CisBP_fimo/'
toutput='/scratch/midway2/zhongshan/temp/'

#step 1, identify confident binding sites,  plus strand only considering RBP, q value < 0.05, and use background model as suggested
#1.1 creat background
#~/software/bin/fasta-get-markov -rna -norc $database $database.background.forfimo # just once

#1.2 scan for motif matches using fimo
mkdir $toutput.withmut/
~/software/bin/fimo --bgfile $database.background.forfimo --skip-matched-sequence --text --no-qvalue --norc --max-stored-scores 100000 $motif $database > $toutput/fimo.txt # --oc $toutput.withmut
~/code/FIMO/genomecoor_pars.pl $database $toutput/fimo.txt |sort|uniq > $toutput/fimo.bed
#1.3 extract binding sites overlapping with mutations based on fimo results
bedtools intersect -wo -a $mutations -b $toutput/fimo.bed  > $toutput/fimo.bed.withmut
#bedtools intersect -wo -a $output/fimo.bed -b $utrcoor | awk 'BEGIN{FS="\t";OFS="\t"}$8<=0.0001{print $1,$2,$3,$4,$11}' > $output/fimo1.bed ##to define the strand

#2, introduce mutation to the binding site, and do motif matching,
~/code/mutation_annotation/mutation_introduce.sh $database $mutations # obtain $database.withmutat1.fa  #ignore without mutation sequences, also produce another file to present mutation position on each sequence $database.withmut.rec
mkdir $toutput.withmut/
#~/software/bin/fimo --bgfile $database.background.forfimo --skip-matched-sequence --text --thresh 0.0001 --no-qvalue --norc --parse-genomic-coord --max-stored-scores 100000 $motif $database.withmutat1.fa > $toutput.withmut/fimo.txt # --oc $toutput.withmut obtain $output.withmut/fimo.txt
~/software/bin/fimo --bgfile $database.background.forfimo --skip-matched-sequence --text --thresh 1 --no-qvalue --norc --max-stored-scores 100000 $motif $database.withmutat1.fa > $toutput.withmut/fimo.txt # --oc $toutput.withmut
~/code/FIMO/genomecoor_pars.pl $database.withmutat1.fa $toutput.withmut/fimo.txt |sort|uniq > $toutput.withmut/fimo.bed
#awk 'BEGIN{FS="\t";OFS="\t"}NR>1{print $3,$4,$5,$1,$7}' $toutput.withmut/fimo.txt >$toutput.withmut/fimo.bed
bedtools intersect -wo -a $mutations -b $toutput.withmut/fimo.bed  > $toutput.withmut/fimo.bed.withmut

#3,calculate difference of binding for ref or mutated  
~/code/FIMO/fimoscore_mutrefcomp.pl $toutput/fimo.bed.withmut $toutput.withmut/fimo.bed.withmut > $mutations.fimo.diff

