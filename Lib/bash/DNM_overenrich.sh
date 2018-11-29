#!/bin/bash
module load bedtools
module load R
bed=$1 #genome regions for overenrichment, the 4th column is the region ID
#/project2/xinhe/zhongshan1/data/annotation/transcriptome_coding/RBPbinding/experiment/CLIPdb
baseline=$2 #base line DNM rate in .bw format, dir/
#/project2/xinhe/zhongshan1/data/DNM_rate/Jedidiah_work/genome_MR/  #AT_CG.bw.wig.norm_108.bw
dnm=$3 #DNM lists, like: chr1	897349	897349	G	A 14505.pM	ASD	 Iossifov_Nature2014
#/project2/xinhe/zhongshan1/data/DNM_lists/WES/comb
ss=$4 #sample sizes for the DNM data, like: Iossifov_Nature2014 ASD 2508
#/project2/xinhe/zhongshan1/data/DNM_lists/WES/comb.samplesizes
scales=$5 #scale of baseline DNM, just 1 number in 1 file
#/project2/xinhe/zhongshan1/data/DNM_rate/Jedidiah_work/genome_MR/scale_factor

awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4}' $bed > $bed.1

#1, sum up base line mutation rate for each region
cat /dev/null > $bed.bwbed.sum
for bw in `ls $baseline | grep ".bw$"`
do
echo "/project2/xinhe/zhongshan1/tools/bw_bed_sum.sh $bw $bed.1"
/project2/xinhe/zhongshan1/tools/bw_bed_sum.sh $baseline/$bw $bed.1 #get $bed.1.bwbed
cat $bed.1.bwbed >> $bed.bwbed.sum
done

cat /dev/null > $bed.bwbed.sum.1
for id in `cut -f 1 $bed.bwbed.sum | sort|uniq`
do
awk -v id=$id 'BEGIN{FS="\t";OFS="\t"}$1==id{sum += $2}END{print id,sum}' $bed.bwbed.sum >> $bed.bwbed.sum.1
done
mv $bed.bwbed.sum.1 $bed.bwbed.sum
echo "get $bed.bwbed.sum"

#2, sum up DNM for each bed regions
intersectBed -wo -a $bed.1 -b $dnm > $bed.2
awk 'BEGIN{FS="\t";OFS="\t"}{print $4,$5,$6,$7,$8,$9,$11,$12}' $bed.2 | sort|uniq  > $bed.3

#perl -e 'my %rec;while(<>){chomp;my @x=split/\t/;my $dnm=join("\t",@x[5..9]);my $reg=$x[3];my $study=join("_",@x[12,9]);$rec{$reg}{$study}{$dnm}=1};for my $reg(keys%rec){for my $st(keys%{$rec{$reg}}){print join("\t",$reg,$st,scalar(keys%{$rec{$reg}{$st}})),"\n"}}}' $bed.2 > $bed.dnm
perl -e 'my %rec;while(<>){chomp;my @x=split/\t/;my $dnm=join("\t",@x[1..5]);my $reg=$x[0];my $study=join("\t",@x[7,6]);$rec{$reg}{$study}{$dnm}=1};for my $reg(keys%rec){for my $st(keys%{$rec{$reg}}){print join("\t",$reg,$st,scalar(keys%{$rec{$reg}{$st}})),"\n"}}' $bed.3 > $bed.dnm
rm $bed.1 $bed.2 $bed.3
echo "get $bed.dnm"

#3, DNM overenrichment analysis
#3.1 combine DNM counts, baseline mutation rate, sample sizes and calibration factor
/project2/xinhe/zhongshan1/tools/overlap.pl $bed.bwbed.sum $bed.dnm 0 0 | awk 'BEGIN{FS="\t";OFS="\t"}$3!="NULL"{print $1,$2,$4,$5,$6}' \
                                                                                        > ./tt1

scale=`cat $scales`
/project2/xinhe/zhongshan1/tools/overlap.pl ./tt1 $ss 2,3 0,1 | awk -v sc=$scale 'BEGIN{FS="\t";OFS="\t"}$6!="NULL"{print $1,$2,$3,$4,$5,$8,sc}' \
                                                                                        >> $bed.mr.dnm #reg MR Study Phenotype DNM Samplesizes Calibration
rm ./tt1

#3.2 statistics analysis and presentation using R
Rscript /project2/xinhe/zhongshan1/tools/DNM_overenrich_baselineMR1.r $bed.mr.dnm #get $bed.mr.dnm.enrich
#rm $bed.1 $bed.2 $bed.3 ./tt1 $bed.mr.dnm $bed.2.bwbed $bed.1

echo "result: $bed.mr.dnm.enrich"
#


