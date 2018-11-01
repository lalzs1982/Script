#!/bin/bash
input=$1
#input='/project2/xinhe/zhongshan/UTR3/ExAC/ExAC.r1.sites.vephg19_common.3UTR.vcf'
#~/software/annovar/convert2annovar.pl -format vcf4old $input > $input.avinput
~/software/annovar/table_annovar.pl --outfile $input $input /scratch/midway2/zhongshan/humandb_annovar/ -otherinfo -buildver hg19 -protocol gwava,gerp++,fathmm,dann,cadd,eigen -operation f,f,f,f,f,f -nastring NA
#~/software/annovar/table_annovar.pl --outfile $input $input /project2/xinhe/zhongshan/data/humandb_annovar/ -otherinfo -buildver hg19 -protocol refGene,spidex -operation g,f -nastring NA

