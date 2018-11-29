#!/bin/bash
module load bedtools
module load R
bed=$1 #genome regions for overenrichment, start from 0, the 4th column is the region ID, and 5th, 6th column are ref alt
#/project2/xinhe/zhongshan1/data/annotation/transcriptome_coding/RBPbinding/experiment/CLIPdb
#/project2/xinhe/zhongshan1/data/allmutations_exons/gencode.v19.annotation.coding.lgt.gtf.allmut.anno.syn
baseline=$2 #base line DNM rate in .bw format, dir/
#/project2/xinhe/zhongshan1/data/DNM_rate/Jedidiah_work/genome_MR/  #AT_CG.bw.wig.norm_108.bw
dnm=$3 #DNM lists, like: chr1 897349 897349 G A 14505.pM ASD Iossifov_Nature2014
#/project2/xinhe/zhongshan1/data/DNM_lists/WES/comb
ss=$4 #sample sizes for the DNM data, like: Iossifov_Nature2014 ASD 2508
#/project2/xinhe/zhongshan1/data/DNM_lists/WES/comb.samplesizes
scales=$5 #scale of baseline DNM, just 1 number in 1 file
#/project2/xinhe/zhongshan1/data/DNM_rate/Jedidiah_work/genome_MR/scale_factor

awk 'BEGIN{FS="\t";OFS="\t"}NR>1{if($2==$3) print $1,$2-1,$3,$4,$5,$6; else print $1,$2,$3,$4,$5,$6;}' $bed > $bed.1
/project2/xinhe/zhongshan1/tools/mut_type.pl $bed.1 4 > $bed.2; mv $bed.2 $bed.1 

#1, sum up base line mutation rate for each region
cat /dev/null > $bed.bwbed.sum
for mut in AT_GC AT_CG AT_TA GC_AT GC_CG GC_TA
do
echo "$mut ..."
awk -v mut=$mut 'BEGIN{FS="\t";OFS="\t"}{if ($7~mut){print $0}}' $bed.1 > $bed.2
/project2/xinhe/zhongshan1/tools/bw_bed_sum.sh $baseline/$mut.bw $bed.2 #get $bed.2.bwbed
cat $bed.2.bwbed >> $bed.bwbed.sum
done

for id in `cut -f 1 $bed.bwbed.sum | sort|uniq`
do
awk -v id=$id 'BEGIN{FS="\t";OFS="\t"}$1==id{sum += $2}END{print id,sum}' $bed.bwbed.sum >> $bed.bwbed.sum.1
done
mv $bed.bwbed.sum.1 $bed.bwbed.sum

#2, sum up DNM for each bed regions
intersectBed -wo -f 1 -a $bed.1 -b $dnm > $bed.2
awk 'BEGIN{FS="\t";OFS="\t"}$3==$10 && $6==$12{print $4,$8,$9,$10,$11,$12,$14,$15}' $bed.2 | sort|uniq  > $bed.3
#awk 'BEGIN{FS="\t";OFS="\t"}$3==$10 && $6==$12{print $0}' $bed.2 | sort|uniq  > $bed.3

#perl -e 'my %rec;while(<>){chomp;my @x=split/\t/;my $dnm=join("\t",@x[5..9]);my $reg=$x[3];my $study=join("_",@x[12,9]);$rec{$reg}{$study}{$dnm}=1};for my $reg(keys%rec){for my $st(keys%{$rec{$reg}}){print join("\t",$reg,$st,scalar(keys%{$rec{$reg}{$st}})),"\n"}}}' $bed.2 > $bed.dnm
perl -e 'my %rec;while(<>){chomp;my @x=split/\t/;my $dnm=join("\t",@x[1..5]);my $reg=$x[0];my $study=join("\t",@x[7,6]);$rec{$reg}{$study}{$dnm}=1};for my $reg(keys%rec){for my $st(keys%{$rec{$reg}}){print join("\t",$reg,$st,scalar(keys%{$rec{$reg}{$st}})),"\n"}}' \
                         $bed.3 > $bed.dnm

#3, DNM overenrichment analysis
#3.1 combine DNM counts, baseline mutation rate, sample sizes and calibration factor
/project2/xinhe/zhongshan1/tools/overlap.pl $bed.dnm $bed.bwbed.sum 0 0 > $bed.tt
#| \ awk 'BEGIN{FS="\t";OFS="\t"}$3!="NULL"{print $1,$2,$4,$5,$6}' 

scale=`cat $scales`
/project2/xinhe/zhongshan1/tools/overlap.pl $bed.tt $ss 1,2 0,1 | \
awk -v sc=$scale 'BEGIN{FS="\t";OFS="\t"}$7!="NULL"{print $1,$6,$2,$3,$4,$9,sc}' > $bed.mr.dnm
#reg MR Study Phenotype DNM Samplesizes Calibration

#3.2 statistics analysis and presentation using R
Rscript /project2/xinhe/zhongshan1/tools/DNM_overenrich_baselineMR1.r $bed.mr.dnm #get $bed.mr.dnm.enrich

rm $bed.1 $bed.2 $bed.3 ./$bed.tt $bed.mr.dnm $bed.2.bwbed $bed.1

echo "final result: $bed.mr.dnm.enrich"
#

