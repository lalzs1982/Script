#!/bin/bash
input=$1
#~/software/annovar/convert2annovar.pl -format vcf4 $input | awk 'BEGIN{FS="\t";OFS="\t"}{print "chr"$1,$2,$3,$4,$5}' > $input.avinput
~/software/annovar/table_annovar.pl --outfile $input.8 $input /project2/xinhe/zhongshan/data/humandb_annovar/ -otherinfo -buildver hg19 -protocol ensGene -operation g -nastring .

#~/software/annovar/table_annovar.pl --outfile $input.8 $input /project2/xinhe/zhongshan/data/humandb_annovar/ -otherinfo -buildver hg19 -protocol ensGene,spidex,phastConsElements46way -operation g,f,r -nastring .
#~/software/annovar/table_annovar.pl --outfile $input.8 $input /project2/xinhe/zhongshan/data/humandb_annovar/ -otherinfo -buildver hg19 -protocol dbnsfp35a -operation f -nastring .
#~/software/annovar/table_annovar.pl --outfile $input.8 $input /project2/xinhe/zhongshan/data/humandb_annovar/ -otherinfo -buildver hg19 -protocol spidex,phastConsElements46way -operation f,r -nastring .
mv $input.8.hg19_multianno.txt $input.annovar.anno
mv $input.8* /project2/xinhe/zhongshan1/temp/
echo "$input.annovar.anno"

