#!/bin/bash #this script was used to calculate enrichment of DNMs in specific genomic regions according to estimated DNM rate
module load R bedtools

dnm=$1 #DNM lists file (annovar input format, with 6-8 columns for individual ID, phenotype and study)
#/project2/xinhe/zhongshan1/data/DNM_lists/WES/comb
DNMrate=$2 #DNM rate for each position (.bw maybe for different mutation types), a directory contain DNM rate for different mutation types
#/project2/xinhe/zhongshan1/data/DNM_rate/Jedidiah_work/genome_MR/
regions=$3 #specific genomic regions for DNM overenrichment analysis (.bed, id on 4th columns), this could also be bed with ref/alt allele in the 5th/6th columns 
#/project2/xinhe/zhongshan1/data/func_reg
total=$3 #total possible regions analyzed (.bed), same format as for regions above. 
#/project2/xinhe/zhongshan1/data/gencode.v29lift37.basic.annotation.cds.gtf.bed.allmut

#0, elementary scripts, scripts used for specific data processing or analysis tasks


#1, filter for dnm and region within total regions
intersectBed -sorted -u -a $regions -b $total > $regions.1;    
intersectBed -sorted -u -a $dnm -b $total > $dnm.1;    

#2, calculate DNM rate for region and total
#2.1, produce mutation rate for each unit of total regions (for repeated usage)
if [! -f $total.bwbed.sum ];then
/project2/xinhe/zhongshan1/tools/bash/bw_bed_sum_over.sh $DNMrate $total #re: $total.bwbed.sum, with DNM rate appended at last column
fi

#2.2, retrieve DNM rate for total and also regions from the $total.bwbed.sum
intersectBed -wo -a $regions.1 -b $total.bwbed.sum | awk 'BEGIN{FS="\t";OFS="\t"}$3==$9 && $5==$12{print $11, $14}' > $regions.1.mr 
perl -e 'while(<>)'



#3, get DNM counts for region and total
#3.1, combine DNM counts and DNM rate for each regions and also total
#3.2, enrichment testing

#4, DNM overenrichment analysis within region based on DNM rate, and result presentation

