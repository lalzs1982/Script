#!/bin/bash
module load bedtools

motif=$1 #meme format, PFM
mutations=$2 #avinput 
ref=$3 
fl=20 #flanking bases length, changeable

~/code/mutation_annotation/genome_seq_extr.sh $ref $mutations $fl # obtain $mutations.fa
awk -v fl="$fl" 'BEGIN{FS="\t";OFS="\t"}{print $1":"$2":"$3":"$4":"$5":"$6,fl,fl,$4,$5,$6}' $mutations > $mutations.2
~/code/mutation_annotation/mutation_introduce1.pl $mutations.2 $mutations.fa > $mutations.mutated.fa #based on avinput and fasta file to introduce mutations, and ignore strand

#run fimo on ref: $mutations.fa and mutation: $mutations.mutated.fa
#1.1 creat background
#
#motif="/project2/xinhe/zhongshan/UTR3/RBPDB_database/motif_withnames.meme"
database="$mutations.fa"
~/software/bin/fasta-get-markov -rna -norc $database $database.background.forfimo # could be just once runing
~/software/bin/fimo --bgfile $database.background.forfimo --skip-matched-sequence --text --thresh 1 --no-qvalue --norc --max-stored-scores 1000000 $motif $database > $database.fimo # --oc $toutput.withmut

database="$mutations.mutated.fa"
~/software/bin/fasta-get-markov -rna -norc $database $database.background.forfimo # could be just once runing
~/software/bin/fimo --bgfile $database.background.forfimo --skip-matched-sequence --text --thresh 1 --no-qvalue --norc --max-stored-scores 1000000 $motif $database > $database.fimo # --oc $toutput.withmut

echo "now calculate fimo diff\n" 
~/code/FIMO/fimoscore_mutrefcomp.pl $fl $mutations.fa.fimo $mutations.mutated.fa.fimo | sort -k1,1 -k2,2n > $mutations.fimodiff

#
#
#
#
#######
##now we have one genome sequences, transcripts coordinates, one binding motif file in meme format and a mutations list, we want to
##scan for motif matches on sequence databases and estimate mutation effects on binding using the fimo software
##what we do is retrive small regions flanking mutations , one is ref and another introduce mutations, fimo, then calculate 
##data
#utrcoor='/project2/xinhe/zhongshan/UTR3/UTRs/UTR3_coor_hg19_longestUTR_coding' # this was used to infer meaningful strand for mutations
#genome='/home/zhongshan/data/hg19.fa' #this was used to retrive sequences
#motif=$1 #meme format, PFM
#mutations=$2 #avinput 
#fl=20 #flanking bases length, changeable
#
##retrive sequences with or without mutations 
#bedtools intersect -wo -a $mutations -b $utrcoor | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$13}' > $mutations.1 #mainly to decide strand information for each mutation
#~/code/mutation_annotation/genome_seq_extr.sh $genome $mutations.1 $fl # obtain $mutations.1.fa
#awk -v fl="$fl" 'BEGIN{FS="\t";OFS="\t"}{print $1":"$2":"$3":"$4":"$5":"$6,fl,fl,$4,$5,$6}' $mutations.1 > $mutations.2
#~/code/mutation_annotation/mutation_introduce1.pl $mutations.2 $mutations.1.fa > $mutations.mutated.fa #based on avinput and fasta file to introduce mutations, and ignore strand
#
##run fimo on ref: $mutations.1.fa and mutation: $mutations.mutated.fa
##1.1 creat background
##
##motif="/project2/xinhe/zhongshan/UTR3/RBPDB_database/motif_withnames.meme"
#database="$mutations.1.fa"
#~/software/bin/fasta-get-markov -rna -norc $database $database.background.forfimo # could be just once runing
#~/software/bin/fimo --bgfile $database.background.forfimo --skip-matched-sequence --text --thresh 1 --no-qvalue --norc --max-stored-scores 1000000 $motif $database > $database.fimo # --oc $toutput.withmut
#
#database="$mutations.mutated.fa"
#~/software/bin/fasta-get-markov -rna -norc $database $database.background.forfimo # could be just once runing
#~/software/bin/fimo --bgfile $database.background.forfimo --skip-matched-sequence --text --thresh 1 --no-qvalue --norc --max-stored-scores 1000000 $motif $database > $database.fimo # --oc $toutput.withmut
#
#echo "now calculate fimo diff\n" 
#~/code/FIMO/fimoscore_mutrefcomp.pl $fl $mutations.1.fa.fimo $mutations.mutated.fa.fimo | sort -k1,1 -k2,2n > $mutations.fimodiff
#
