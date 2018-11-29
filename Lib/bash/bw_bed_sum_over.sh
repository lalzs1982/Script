#!/bin/bash
baseline=$1 ##base line DNM rate in .bw format, dir/
bed=$2 #bed regions, 4 or 6 columns with or without ref/alt alleles

rand=`awk 'BEGIN{srand(); print int(1000*rand())}'` #random number for temporary files
bed_col=`awk 'BEGIN{FS="\t"}{print NF; exit}' $bed`

if [ $bed_col -eq 6 ];then
/project2/xinhe/zhongshan1/code/perl/mut_type.pl $bed 4 > $bed.$rand.1 #add mutation types
fi

echo "produce mutation rate sum for each region"
#1, sum up base line mutation rate for each region
cat /dev/null > $bed.bwbed.sum
for mut in AT_GC AT_CG AT_TA GC_AT GC_CG GC_TA
do
echo "$mut ..."

if [ $bed_col -eq 6 ];then
awk -v mut=$mut 'BEGIN{FS="\t";OFS="\t"}{if ($7~mut){print $0}}' $bed.$rand.1 > $bed.$rand.2
else
cp $bed $bed.$rand.2
fi

/project2/xinhe/zhongshan1/code/bash/bw_bed_sum.sh $baseline/$mut.bw $bed.$rand.2 #get $bed.$rand.2.bwbed
cat $bed.$rand.2.bwbed >> $bed.bwbed.sum
done

cat /dev/null > $bed.bwbed.sum.$rand.1
for id in `cut -f 1 $bed.bwbed.sum | sort|uniq`
do
awk -v id=$id 'BEGIN{FS="\t";OFS="\t"}$1==id{sum += $2}END{print id,sum}' $bed.bwbed.sum >> $bed.bwbed.sum.$rand.1
done

mv $bed.bwbed.sum.$rand.1 $bed.bwbed.sum # $bed.bwbed.sum
rm $bed.$rand*
echo "$bed.bwbed.sum produced"

