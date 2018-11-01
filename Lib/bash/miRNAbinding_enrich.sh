#!/bin/bash
module load R
genes=$1 #/project2/xinhe/zhongshan/data/ASD_genes/yuwen_Jul2018_supply
binding=$2 #/project2/xinhe/zhongshan/noncodingRNA/miRNA/targetscan/bed_files/comb.1.top500
temp=/project2/xinhe/zhongshan/temp/

~/code/overlap2.pl $genes $binding 0 4 > $temp/genes_miRNAbinding
 
#run summary :
/home/zhongshan/code/miRNAbinding_enrich.pl $temp/genes_miRNAbinding | sort -k6,6rn > $temp/genes_miRNAbinding.enrich
#and do test using R
Rscript /home/zhongshan/code/miRNAbinding_enrich.r $temp/genes_miRNAbinding.enrich 
echo "final results: $temp/genes_miRNAbinding.enrich.test_p"


