#!/bin/bash
file=$1; #file containing coordinates for transcript
dir=$2; # directory with bed file contain scores, with chr seperated
temp='/home/zhongshan/temp/'
mkdir $temp
rm -rf $temp/*
cat /dev/null > $file.withscore

for chr in `cut -f 1 $file |sort|uniq`
do
grep "^$chr" $file > $temp/$chr
scorefile=`ls $dir/$chr.*`

if [ -f $temp/$chr ];then
echo "bedtools intersect -wo -b $temp/$chr -a $scorefile | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$3,$3,$4}'|sort -k1,1 -k2,2n |uniq >> $file.withscore ..."
bedtools intersect -wo -b $temp/$chr -a $scorefile | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$3,$3,$4}'|sort -k1,1 -k2,2n |uniq >> $file.withscore 
fi

done

