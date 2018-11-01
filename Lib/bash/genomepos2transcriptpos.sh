#!/bin/bash
transcr=$1 #transcriptom annotations in gtf format
gpos=$2 #genome coordinates in chr pos pos  (last pos used, and following columns won't be considered)
module load bedtools
awk 'BEGIN{FS="\t";OFS="\t"}$3=="exon"{print $0}' $transcr > $transcr.exon 
awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5}' $gpos > $gpos.0
bedtools intersect -wo -a $gpos.0 -b $transcr.exon > $gpos.1
~/code/genomepos2transcriptpos.pl $gpos.1 $transcr.exon > $gpos.genomepos
echo "output $gpos.genomepos"