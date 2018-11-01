#!/bin/bash
input=$1
#~/software/annovar/convert2annovar.pl -format vcf4 $input | awk 'BEGIN{FS="\t";OFS="\t"}{print "chr"$1,$2,$3,$4,$5}' > $input.avinput
#~/software/annovar/table_annovar.pl --outfile $input $input /project2/xinhe/zhongshan/data/humandb_annovar/ -otherinfo -buildver hg19 -protocol ensGene,spidex,phastConsElements46way,dbnsfp35a -operation g,f,r,f -nastring .
~/software/annovar/table_annovar.pl --outfile $input $input /project2/xinhe/zhongshan/data/humandb_annovar/ -otherinfo -buildver hg19 -protocol spidex,phastConsElements46way,dbnsfp35a -operation f,r,f -nastring .

