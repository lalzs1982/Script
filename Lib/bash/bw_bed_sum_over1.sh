#!/bin/bash
#this code is for mutation rate retrieve for point mutations
baseline=$1 ##base line DNM rate in .bw format, dir/
snvs=$2 #all mutations in avinput format

rand=`awk 'BEGIN{srand(); print int(1000*rand())}'` #random number for temporary files
temp=/project2/xinhe/zhongshan1/temp/$rand
mkdir $temp

awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$3-1,$3,NR,$4,$5}' $snvs > $temp/snvs

/project2/xinhe/zhongshan1/code/perl/mut_type.pl $temp/snvs 4 > $temp/bed.muttype #add mutation types

echo "produce mutation rate sum for each region"
#1, sum up base line mutation rate for each region
cat /dev/null > $temp/bed.bwbed.sum
for mut in AT_GC AT_CG AT_TA GC_AT GC_CG GC_TA
do
echo "$mut ..."
awk -v mut=$mut 'BEGIN{FS="\t";OFS="\t"}{if ($7~mut){print $1,$2,$3,$4}}' $temp/bed.muttype > $temp/bed.muttype.1
/project2/xinhe/zhongshan/tools/bigWigAverageOverBed $baseline/$mut.bw $temp/bed.muttype.1 $temp/bed.muttype.1.bwbed
#/project2/xinhe/zhongshan1/code/bash/bw_bed_sum.sh $baseline/$mut.bw $bed.$rand.2 #get $bed.$rand.2.bwbed
cat $temp/bed.muttype.1.bwbed >> $temp/bed.bwbed.sum
done

/project2/xinhe/zhongshan1/code/perl/overlap.pl $temp/snvs $temp/bed.bwbed.sum 3 0 | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$3,$3,$5,$6,$10}' > $snvs.mr

echo "final result: $snv.mr"
#rm -rf $temp
