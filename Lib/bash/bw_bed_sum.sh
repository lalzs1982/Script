#!/bin/bash
module load bedtools
bw=$1 #base line DNM rate in bw format
#/project2/xinhe/zhongshan1/data/DNM_rate/Jedidiah_work/genome_MR/AT_CG.bw.wig.norm_108.bw
bed=$2 #genome regions for overenrichment, the 4th column is the region ID
#/project2/xinhe/zhongshan1/data/allmutations_exons/$rand.anno
rand=`awk 'BEGIN{srand(); print int(1000*rand())}'` #random number for temporary files

#1, sum up base line mutation rate for each region
cat /dev/null > $bed.bwbed
for id in `awk 'BEGIN{FS="\t";OFS="\t"}{print $4}' $bed | sort|uniq`
do
echo "now processing $id ..."
awk -v id="$id" 'BEGIN{FS="\t";OFS="\t"}$4==id{print $1,$2,$3}' $bed |sort -k1,1 -k2,2n -k3,3n |uniq > $bed.$rand
bedtools merge -i $bed.$rand | awk 'BEGIN{FS="\t";OFS="\t"}{print $0,NR}'> $bed.$rand.m; mv $bed.$rand.m $bed.$rand

/project2/xinhe/zhongshan/tools/bigWigAverageOverBed $bw $bed.$rand $bed.$rand.1
awk -v id="$id" 'BEGIN{FS="\t";OFS="\t"}{sum += $4}END{print id,sum}' $bed.$rand.1 >> $bed.bwbed
done

rm $bed.$rand*
echo "re $bed.bwbed"
