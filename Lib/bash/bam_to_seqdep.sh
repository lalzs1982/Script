#!/bin/bash
module load samtools
module load bcftools
module load java

bed=$1
bam=$2
genome='/project2/xinhe/zhongshan/data/hg19.fa'
samtools mpileup -l $bed -f $genome $bam | cut -f 1,2,3,4 > $bam.dep
echo "$bam.dep obtained"

