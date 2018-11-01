#!/bin/bash
module load bedtools
#convert relative position on transcripts (.bed) to absolute position on genome based on gtf
transpos=$1 #bed: transcript ID, start, end
str=$2 #gtf

/project2/xinhe/zhongshan/code/transc_relbd.pl $str > $str.relbd #obtain relative exon boundary on transcripts
intersectBed -wo -a $transpos -b $str.relbd > $transpos.rl
/project2/xinhe/zhongshan1/tools/transpos2genomepos.pl $transpos.rl > $transpos.abspos
echo "result: $transpos.abspos"
#rm $transpos.rl
