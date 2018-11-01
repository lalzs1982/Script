#!/bin/bash
module load bedtools
bw=$1 #base line DNM rate in bw format, dir/
#/project2/xinhe/zhongshan1/data/DNM_rate/Jedidiah_work/genome_MR/ #AT_CG.bw
av=$2 #mutation lists in annovar input format

/project2/xinhe/zhongshan1/tools/avinput_muttype.pl $av > $av.1
echo "mutation type annotation finished"

cat /dev/null > $av.dnmrate
for mut in `cut -f 6 $av.1 | sort|uniq`
do
    for chr in `cat /project2/xinhe/zhongshan1/data/chrName.txt`
    do
    awk -v mut=$mut -v chr=$chr 'BEGIN{FS="\t";OFS="\t"}$6==mut && $1==chr{print $0}' $av.1 > $av.0
    awk -v mut=$mut -v chr=$chr 'BEGIN{FS="\t";OFS="\t"}$6==mut && $1==chr{print $1,$2-1,$3,NR}' $av.1 > $av.2
    wl=`wc -l $av.2 | awk '{print $1}'`
    
    if [ $wl -gt 0 ];then
    echo "it is $mut, $chr ..."
    /project2/xinhe/zhongshan/tools/bigWigAverageOverBed $bw/$mut.bw $av.2 ./tt.$mut 
    /project2/xinhe/zhongshan1/tools/overlap.pl $av.2 ./tt.$mut 3 0 | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$8}' > $av.3
    intersectBed -wo -a $av.0 -b $av.3 | awk 'BEGIN{FS="\t";OFS="\t"}$3==$9{print $1,$2,$3,$4,$5,$10}' >> $av.dnmrate
    rm $av.0 $av.2 $av.3
fi
    
done
done

echo "final: $av.dnmrate"
