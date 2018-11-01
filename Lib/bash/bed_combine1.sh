#!/bin/bash
module load bedtools;
input=$1; # one file containing many bed files for combinations
genomefile='/home/zhongshan/data/hg19_chrLen'
#sort -k1,1 $genomefile > $genomefile.1
#mv $genomefile.1 $genomefile
#it is important to make sure that the genome assembly are same!
#combine and sort
wl=`ls $input/* | egrep ".narrowPeak|.bed" | grep -v combined| wc -l`

if [ $wl -gt 0 ]
then
#rm -f $input/combined*

#decide cutoff
cutoff=`~/code/psychencode/coverage_cufoff.pl $input/coverage_comp | tee /dev/tty`

#select regions above certain coverage cufoff
#awk 'BEGIN{FS="\t";OFS="\t"}$4>=cutoff{print $0}' cutoff="$cutoff" $input/combined_merge.hist | grep -v "all" > $input/combined_merge_picked.hist # this is what we want

#bedtools coverage -d -sorted -g $genomefile -a $input/combined_merge.bed -b $input/combined.bed |awk '$5>1{print $0}' > $input/combined_merge.depth
~/code/psychencode/region_extr_basedondepth.pl $input/combined_merge.depth $cutoff > $input/combined_merge_picked
fi

echo "all things done"

