#!/bin/bash
file1=$1
file2=$2
module load bedtools
#sort -k1,1 -k2,2n, -k3,3n $file2 > $file2.1 

temp=/project2/xinhe/zhongshan/temp/intersectbed
#mkdir $temp; rm -rf $temp/*; cd $temp/; split --lines $(( $(wc -l < $file2) / 200)) $file2
mkdir -p $temp; rm -rf $temp/*; cd $temp/;

cat /dev/null > $file1.int

for chr in `cat /project2/xinhe/zhongshan1/data/chrName.txt`
do
    awk -v chr=$chr 'BEGIN{FS="\t";OFS="\t"}$1==chr{print $0}' $file1 > $temp/$chr.1
    awk -v chr=$chr 'BEGIN{FS="\t";OFS="\t"}$1==chr{print $0}' $file2 > $temp/$chr.2
    
    echo "bedtools intersect -wao -f 1 -a $temp/$chr.1 -b $temp/$chr.2 >> $file1.int"
    bedtools intersect -wao -f 1 -a $temp/$chr.1 -b $temp/$chr.2 \
    >> $file1.int
    
    #| awk 'BEGIN{FS="\t";OFS="\t"}$3==$13 && $5==$15{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$16}'
done

rm -rf $temp/*
echo "result: $file1.int"

