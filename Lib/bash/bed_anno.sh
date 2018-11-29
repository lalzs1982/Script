#!/bin/bash
module load bedtools
bed=$1 #.bed for points
anno=$2 # .bed with the 4th column as ID, possible 5th column as score

bed_col=`awk 'BEGIN{FS="\t"}{print NF; exit}' $bed`
anno_col=`awk 'BEGIN{FS="\t"}{print NF; exit}' $anno`

temp=/project2/xinhe/zhongshan1/temp/
head -n 1 $bed > $temp/bed.anno
intersectBed -sorted -wao -f 1 -a $bed -b $anno >> $temp/bed.anno
/project2/xinhe/zhongshan1/code/perl/bed_anno.pl $temp/bed.anno $bed_col $anno_col | sort|uniq > $temp/bed.anno.1
grep Start $temp/bed.anno.1 > $temp/bed.anno.2; grep -v "Start" $temp/bed.anno.1 >> $temp/bed.anno.2;
#rm $temp/bed.anno.1 $temp/bed.anno
echo "result: $temp/bed.anno.2"
