#!/bin/bash
dir='/scratch/midway2/zhongshan/phyloP46way/'
for chr in chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chrX chrY
do
echo "dealling with $dir/$chr.phyloP46way.primate"
~/software/wigToBigWig $dir/$chr.phyloP46way.primate.wigFix.gz ~/data/hg19_chrLen $dir/$chr.phyloP46way.primate.bw
~/software/bigWigToBedGraph $dir/$chr.phyloP46way.primate.bw $dir/$chr.phyloP46way.primate.bed
done
 
