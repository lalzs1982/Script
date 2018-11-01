#!/bin/bash
file1=$1; #gtf file, ordered by increasing for positive str and decreasing for negative str, for example /project2/xinhe/zhongshan/data/hg19_refGenes_exons.gtf.1
file2=$2; #bed file of position on transcripts
~/code/exon_relpos_on_transcr.pl $file1 > $file1.relpos
