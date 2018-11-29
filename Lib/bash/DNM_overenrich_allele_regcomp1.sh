#!/bin/bash
#this script was used to calculate enrichment of DNMs in specific genomic regions according to estimated DNM rate
module load R
module load bedtools

dnm=$1 #DNM lists file (annovar input format, with 6-8 columns for individual ID, phenotype and study)
#/project2/xinhe/zhongshan1/data/DNM_lists/WES/comb
DNMrate=$2 #DNM rate for each position (.bw maybe for different mutation types), a directory contain DNM rate for different mutation types
#/project2/xinhe/zhongshan1/data/DNM_rate/Jedidiah_work/genome_MR/
regions=$3 #specific genomic regions for DNM overenrichment analysis (.bed, id on 4th columns), this could also be bed with ref/alt allele in the 5th/6th columns 
#/project2/xinhe/zhongshan1/data/func_reg
#/project2/xinhe/zhongshan1/data/RBPbinding/experiment/CLIPdb.1
total=$4 #total possible regions analyzed (.bed), same format as for regions above, but not ID (4th column). 
#/project2/xinhe/zhongshan1/data/gencode.v29lift37.basic.annotation.cds.gtf.bed.allmut

#0, elementary scripts, scripts used for specific data processing or analysis tasks
rand=`awk 'BEGIN{srand(); print int(1000*rand())}'`
temp=/project2/xinhe/zhongshan1/temp/$rand
mkdir $temp
echo "temp file: $temp"
#1, filter for dnm and region within total regions
echo "filter for regions and DNM"
regions_col=`awk 'BEGIN{FS="\t"}{print NF; exit}' $regions`
if [ $regions_col -gt 4 ];then
echo "regions with allele"
intersectBed -u -a $regions -b $total > $temp/regions #$regions .1;    
else
echo "regions without allele"
intersectBed -wo -a $total -b $regions | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$11,$4,$5}' | sort |uniq \
  > $temp/regions #for regions without allele info, note $total columns    
fi

intersectBed -u -a $dnm -b $total > $temp/dnm #$dnm .1;    

#2, calculate DNM rate for region and total
#2.1, produce mutation rate for each unit of total regions (for repeated usage)
echo "mutation rate:"
if [ ! -f $total.mr ];then
    echo "$total.mr not exist, produce it..."
/project2/xinhe/zhongshan1/code/bash/bw_bed_sum_over.sh $DNMrate $total #re: $total.bwbed.sum, with DNM rate appended at last column, and 0 mr entries removed
mv $total.bwbed.sum $total.mr
fi


echo "obtain mr for regions:"
intersectBed -wo -a $temp/regions -b $total.mr | awk 'BEGIN{FS="\t";OFS="\t"}$3==$9 && $6==$11{print $4,$7,$8,$9,$10,$11,$12}' | sort|uniq \
> $temp/regions.mr 

cat /dev/null > $temp/regions.mr.sum
for reg in `cut -f 1 $temp/regions.mr|sort|uniq`
do
#echo $reg
awk -v reg=$reg '$1==reg{print $0}' $temp/regions.mr | sort|uniq | awk -v reg=$reg 'BEGIN{FS="\t";OFS="\t";sum=0}{sum+=$7}END{print reg,sum}' >> $temp/regions.mr.sum
done

awk -v reg="Total" 'BEGIN{FS="\t";OFS="\t";sum=0}{sum+=$6}END{print reg,sum}' $total.mr >> $temp/regions.mr.sum #add total mutation rate

mv $temp/regions.mr.sum $temp/regions.mr

#3, get DNM counts for region and total and for each study/cohorts specifically
echo "DNMs for regions:"
intersectBed -wo -a $temp/regions -b $temp/dnm | awk 'BEGIN{FS="\t";OFS="\t"}$3==$9 && $6==$11{print $4,$7,$8,$9,$10,$11,$13,$14}' | sort|uniq | \
cut -f 1,7,8 |sort|uniq -c | awk 'BEGIN{OFS="\t"}{print $2,$4,$3,$1}' > $temp/regions.dnm 
cut -f 8,7 $temp/dnm |sort|uniq -c | awk 'BEGIN{OFS="\t"}{print "Total",$3,$2,$1}' >> $temp/regions.dnm 

#4, DNM overenrichment analysis within region based on DNM rate, and result presentation
#4.1, combine DNM counts and DNM rate for each regions (including Total)
/project2/xinhe/zhongshan1/code/perl/overlap.pl $temp/regions.dnm $temp/regions.mr 0 0 | awk 'BEGIN{FS="\t";OFS="\t"}$5!="NULL"{print $1,$2,$3,$4,$6}' > $temp/regions.dnm.mr
#and append Total DNMs and rate to last 2 columns: 
awk '$1=="Total"{print $0}' $temp/regions.dnm.mr > $temp/regions.dnm.mr.total
/project2/xinhe/zhongshan1/code/perl/overlap.pl $temp/regions.dnm.mr $temp/regions.dnm.mr.total 1,2 1,2 |  awk 'BEGIN{FS="\t";OFS="\t"}$6!="NULL"{print $1,$2,$3,$4,$5,$9,$10}' \
> $temp/regions.dnm.mr.1
awk '$1!="Total"{print $0}' $temp/regions.dnm.mr.1 > $temp/regions.dnm.mr #the columns are: reg, study, ph, DNMs, rate, total DNMs and total rate

#4.2, enrichment testing using R
Rscript /project2/xinhe/zhongshan1/code/R/DNM_overenrich_regcomp1.r $temp/regions.dnm.mr #get $temp/regions.dnm.mr.dnm.enrich $temp/regions.dnm.mr.dnm.enrich.pdf
mv $temp/regions.dnm.mr.dnm.enrich $regions.dnm.mr.dnm.enrich
mv $temp/regions.dnm.mr.dnm.enrich.pdf $regions.dnm.mr.dnm.enrich.pdf

#rm -rf $temp/ #delete all temporary files
echo "output: $regions.dnm.mr.dnm.enrich and $regions.dnm.mr.dnm.enrich.pdf"
