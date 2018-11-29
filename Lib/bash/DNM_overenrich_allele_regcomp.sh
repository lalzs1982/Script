#!/bin/bash
module load bedtools
module load R
#this script compare DNM occurences in potential functional vs negative control
total_regs=$1 #the total possible mutations analyzed, bed or bed+alleles with mutation rate
#Note: exclude those with 0
#/project2/xinhe/zhongshan1/data/gencode.v29lift37.basic.annotation.cds.gtf.bed.allmut.mr
#/project2/xinhe/zhongshan1/data/allmutations_exons/gencode.v19.annotation.coding.lgt.gtf.allmut.anno.syn_nonsyn_nonsplicing
target=$2 #genome regions for overenrichment analysis, bed or bed+alleles, start from 0, the 4th column is the region ID,
#and 5th, 6th column are ref alt if any
#Note: only accept 4 (for regions) or 6 column (include alleles) bed files
#/project2/xinhe/zhongshan1/data/annotation/transcriptome_coding/RBPbinding/experiment/CLIPdb
#/project2/xinhe/zhongshan1/data/allmutations_exons/gencode.v19.annotation.coding.lgt.gtf.allmut.anno.syn
#baseline=$3 #base line DNM rate in .bw format, dir/
#/project2/xinhe/zhongshan1/data/DNM_rate/Jedidiah_work/genome_MR/  #AT_CG.bw.wig.norm_108.bw
dnm=$3 #DNM lists, like: chr1 897349 897349 G A 14505.pM ASD Iossifov_Nature2014
#/project2/xinhe/zhongshan1/data/DNM_lists/WES/comb

rand=`awk 'BEGIN{srand(); print int(1000*rand())}'` #random number for temporary files
echo "random number is $rand"
#all bed should be sorted by sort -k1,1 -k2,2n
echo "retrieve target regions and DNMs within total_regs for analysis"
intersectBed -sorted -u -a $target -b $total_regs > $target.$rand.1;    
intersectBed -sorted -u -a $dnm -b $total_regs > $dnm.$rand.1;    

echo "produce mutation rate sum for each region"
target_col=`awk 'BEGIN{FS="\t"}{print NF; exit}' $target`

cat /dev/null > $target.mrsum
for reg in `cut -f 4 $target.$rand.1 | sort|uniq`
do
echo $reg
awk -v reg=$reg '$4==reg{print $0}' $target.$rand.1 > $target.$rand.2
if [ $target_col -eq 6 ];then
intersectBed -sorted -wo -a $total_regs -b $target.$rand.2 | \
awk -v reg=$reg 'BEGIN{FS="\t";OFS="\t";sum=0}$3==$9 && $5==$12{sum+=$6}END{print reg, sum}' >>  $target.mrsum
else
intersectBed -u -sorted -a $total_regs -b $target.$rand.2 | \
awk -v reg=$reg 'BEGIN{FS="\t";OFS="\t";sum=0}{sum+=$6}END{print reg, sum}' >>  $target.mrsum
fi
done
#then add total mutation rate sum:
awk -v reg="Total" 'BEGIN{FS="\t";OFS="\t";sum=0}{sum+=$6}END{print reg, sum}' $total_regs >>  $target.mrsum
echo "mutation rate for each regions produced: $target.mrsum"
#rm $target.$rand.2
###
#
#if [ ! -f $target.bwbed.sum ];then
#cat /dev/null > $target.bwbed.sum
#/project2/xinhe/zhongshan1/tools/bash/bw_bed_sum_over.sh $baseline/ $target.$rand.1 #get $target.$rand.1.bwbed.sum 
#fi
#
#if [ ! -f $total_regs.bwbed.sum ];then
#cat /dev/null > $total_regs.bwbed.sum
#/project2/xinhe/zhongshan1/tools/bash/bw_bed_sum_over.sh $baseline/ $total_regs #get $total_regs.$rand.1.bwbed.sum
#fi
#cat $total_regs.bwbed.sum >> $target.$rand.1.bwbed.sum;
#


#2, sum up DNM for each bed regions
echo "sum up DNMs for each regions"
intersectBed -wo -a $target.$rand.1 -b $dnm.$rand.1 > $target.$rand.2
perl -e 'my %rec;while(<>){chomp;my @x=split/\t/;if($x[2]==$x[8] && $x[5]==$x[10]){my $dnm=join("\t",@x[6..10]);my $reg=$x[3];my $study=join("\t",@x[13,12]);$rec{$reg}{$study}{$dnm}=1}};for my $reg(keys%rec){for my $st(keys%{$rec{$reg}}){print join("\t",$reg,$st,scalar(keys%{$rec{$reg}{$st}})),"\n"}}' \
                         $target.$rand.2 > $target.dnm
#and for total regions:
intersectBed -wo -a $total_regs -b $dnm.$rand.1 > $target.$rand.2

perl -e 'my %rec;while(<>){chomp;my @x=split/\t/;if($x[2]==$x[8] && $x[4]==$x[10]){my $dnm=join("\t",@x[6..10]);my $reg="Total";my $study=join("\t",@x[13,12]);$rec{$reg}{$study}{$dnm}=1}};for my $reg(keys%rec){for my $st(keys%{$rec{$reg}}){print join("\t",$reg,$st,scalar(keys%{$rec{$reg}{$st}})),"\n"}}' \
                         $target.$rand.2 >> $target.dnm

#3, DNM overenrichment analysis
#3.$rand.1 combine DNM counts, baseline mutation rate:
/project2/xinhe/zhongshan1/tools/overlap.pl $target.dnm $target.mrsum 0 0 | grep -v NULL | sort|uniq > $target.tt

#3.$rand.2, compare Neg groups with all other groups as for mutation enrichment
total=`echo $total_regs | awk 'BEGIN{FS="/"}{print $NF}'`
Rscript /project2/xinhe/zhongshan1/tools/DNM_overenrich_regcomp.r $target.tt #get $target.tt.dnm.enrich and $target.tt.dnm.enrich.pdf
mv $target.tt.dnm.enrich $target.$total.dnm.enrich; mv $target.tt.dnm.enrich.pdf $target.$total.dnm.enrich.pdf
echo "final result: $target.$total.dnm.enrich and $target.$total.dnm.enrich.pdf and random number: $target"
#rm $target.tt* $target.$rand* $dnm.$rand*


#sort -k1,1 -k2,2n $total_regs > ./$rand.tt; mv ./$rand.tt $total_regs; sort -k1,1 -k2,2n $target > ./$rand.tt; mv ./$rand.tt $target
##run this  if not sorted
#
#echo "retrieve mutations for different groups"
#total_col=`awk 'BEGIN{FS="\t"}{print NF; exit}' $total_regs`
#target_col=`awk 'BEGIN{FS="\t"}{print NF; exit}' $target`
#
#if [ $target_col -lt 6 ];then #just regions
#intersectBed -sorted -wo -f 1 -a $total_regs -b $target | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$10,$5,$6}' > $target.$rand.1
#else #position with mutation alleles
#intersectBed -sorted -wo -f 1 -a $total_regs -b $target | awk 'BEGIN{FS="\t";OFS="\t"}{if($3==$9 && $6==$12) print $1,$2,$3,$10,$5,$6}' > $target.$rand.1
#fi
#intersectBed -v -sorted -a $total_regs -b $target | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,"Neg",$5,$6}' >> $target.$rand.1 #add negative controls
