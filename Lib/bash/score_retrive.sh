#!/bin/bash
module load bedtools
file=$1; #bed file containing coordinates, sorted
dir=$2; # directory with bed file contain scores, with chr seperated,/project2/xinhe/zhongshan/data/phastCons46way_hg19/ for example
temp='/home/zhongshan/temp/'
mkdir $temp
rm -rf $temp/*
cat /dev/null > $file.withscore

for chr in `cut -f 1 $file |sort|uniq`
do
grep "^$chr" $file > $temp/$chr
scorefile=`ls $dir/$chr.*`
if [ -f $scorefile ];then
echo "bedtools intersect -wo -sorted -a $temp/$chr -b $scorefile | awk 'BEGIN{FS="\t";OFS="\t"}$3==$12{print $5,$6,$7,48,$9,$10,$11,$12,$13,$4}' >> $file.withscore"
bedtools intersect -wo -sorted -a $temp/$chr -b $scorefile | awk 'BEGIN{FS="\t";OFS="\t"}$3==$12{print $1,$2,$3,$4,$5,$6,$7,48,$9,$13}' >> $file.withscore 
fi
done

