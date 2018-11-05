#!/bin/bash #this script was used to calculate enrichment of DNMs in specific genomic regions according to estimated DNM rate
module load R bedtools

dnm=$1 #DNM lists file (annovar input format, with 6-8 columns for individual ID, phenotype and study)
#/project2/xinhe/zhongshan1/data/DNM_lists/WES/comb
DNMrate=$2 #DNM rate for each position (.bw maybe for different mutation types), a directory contain DNM rate for different mutation types
#/project2/xinhe/zhongshan1/data/DNM_rate/Jedidiah_work/genome_MR/
regions=$3 #specific genomic regions for DNM overenrichment analysis (.bed, id on 4th columns), this could also be bed with ref/alt allele in the 5th/6th columns 
#/project2/xinhe/zhongshan1/data/func_reg
total=$3 #total possible regions analyzed (.bed), same format as for regions above, but not ID (4th column). 
#/project2/xinhe/zhongshan1/data/gencode.v29lift37.basic.annotation.cds.gtf.bed.allmut

#0, elementary scripts, scripts used for specific data processing or analysis tasks


#1, filter for dnm and region within total regions
intersectBed -sorted -u -a $regions -b $total > $regions.1;    
intersectBed -sorted -u -a $dnm -b $total > $dnm.1;    

#2, calculate DNM rate for region and total
#2.1, produce mutation rate for each unit of total regions (for repeated usage)
if [! -f $total.mr ];then
/project2/xinhe/zhongshan1/tools/bash/bw_bed_sum_over.sh $DNMrate $total #re: $total.bwbed.sum, with DNM rate appended at last column, and 0 mr entries removed
mv $total.bwbed.sum $total.mr
fi

#2.2, retrieve DNM rate for total and also regions from the $total.bwbed.sum
sort -k1,1 -k2,2n $regions.1 > $regions.2; mv $regions.2 $regions.1;
sort -k1,1 -k2,2n $total.mr > $total.mr.1; mv $total.mr.1 $total.mr;
intersectBed -wo -sorted -a $regions.1 -b $total.mr | awk 'BEGIN{FS="\t";OFS="\t"}$3==$9 && $6==$11{print $4,$7,$8,$9,$10,$11,$12}' | sort|uniq \
> $regions.1.mr 
cat /dev/null > $regions.1.mr.sum
for reg in `cut -f 1 $regions.1.mr|sort|uniq`
do
echo $reg
awk -v reg=$reg '$1==reg{print $0}' $regions.1.mr | sort|uniq | awk -v reg=$reg 'BEGIN{FS="\t";OFS="\t";sum=0}{sum+=$7}END{print reg,sum}' >> $regions.1.mr.sum
done
awk -v reg="Total" 'BEGIN{FS="\t";OFS="\t";sum=0}{sum+=$6}END{print reg,sum}' $total.mr >> $regions.1.mr.sum #add total mutation rate
mv $regions.1.mr.sum $regions.1.mr

#3, get DNM counts for region and total and for each study/cohorts specifically
intersectBed -wo -a $regions.1 -b $dnm.1 | awk 'BEGIN{FS="\t";OFS="\t"}$3==$9 && $6==$11{print $4,$7,$8,$9,$10,$11,$13,$14}' | sort|uniq | \
cut -f 1,7,8 |sort|uniq -c | awk 'BEGIN{OFS="\t"}{print $2,$4,$3,$1}' > $regions.1.dnm 
cut -f 8,7 $dnm.1 |sort|uniq -c | awk 'BEGIN{OFS="\t"}{print "Total",$3,$2,$1}' >> $regions.1.dnm 

#4, DNM overenrichment analysis within region based on DNM rate, and result presentation
#4.1, combine DNM counts and DNM rate for each regions (including Total)
/project2/xinhe/zhongshan1/tools/overlap.pl $regions.1.dnm $regions.1.mr 0 0 | awk 'BEGIN{FS="\t";OFS="\t"}$5!="NULL"{print $1,$2,$3,$4,$6}' > $regions.1.dnm.mr
rm $regions.1.dnm $regions.1.mr
#and append Total DNMs and rate to last 2 columns: 
awk '$1=="Total"{print $0}' $regions.1.dnm.mr > $regions.1.dnm.mr.total
/project2/xinhe/zhongshan1/tools/overlap.pl $regions.1.dnm.mr $regions.1.dnm.mr.total 1,2 1,2 |  awk 'BEGIN{FS="\t";OFS="\t"}$6!="NULL"{print $1,$2,$3,$4,$5,$9,$10}' \
> $regions.1.dnm.mr.1
awk '$1!="Total"{print $0}' $regions.1.dnm.mr.1 > $regions.1.dnm.mr #the columns are: reg, study, ph, DNMs, rate, total DNMs and total rate
rm $regions.1.dnm.mr.total

#4.2, enrichment testing using R
Rscript /project2/xinhe/zhongshan1/tools/DNM_overenrich_regcomp1.r $regions.1.dnm.mr #get $regions.1.dnm.mr.dnm.enrich $regions.1.dnm.mr.dnm.enrich.pdf



