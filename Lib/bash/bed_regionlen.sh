#!/bin/bash
#this code should be replaced by ~/code/bed_regionlen.pl, 

input=$1 #bed file first 3 columns as coordinates, 4th, and 5th IDs
temp="/project2/xinhe/zhongshan/temp/"
module load bedtools

cat /dev/null > $input.4thsum
for id in `cut -f 4 $input | sort|uniq`
do
    awk -v id=$id 'BEGIN{FS="\t";OFS="\t"}$4==id{print $1,$2,$3}' $input | sort -k1,1 -k2,2n > $temp/$id
    sum=`bedtools merge -i $temp/$id | awk -F '\t' 'BEGIN{SUM=0}{ SUM+=$3-$2}END{print SUM}'`
    echo "$id   $sum" >> $input.4thsum
done

cat /dev/null > $input.5thsum
for id in `cut -f 5 $input | sort|uniq`
do
    awk -v id=$id 'BEGIN{FS="\t";OFS="\t"}$5==id{print $1,$2,$3}' $input | sort -k1,1 -k2,2n > $temp/$id
    sum=`bedtools merge -i $temp/$id | awk -F '\t' 'BEGIN{SUM=0}{ SUM+=$3-$2}END{print SUM}'`
    echo "$id   $sum" >> $input.5thsum
done

~/code/bed_regionlen.app.pl  $input.4thsum  $input.5thsum  $input >  $input.withlen
echo "the sum length put in $input.withlen"

