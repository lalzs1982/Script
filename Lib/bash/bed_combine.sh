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

cat `ls $input/*| egrep ".narrowPeak|.bed" | grep -v combined` >  $input/combined.bed
sort -k1,1 -k2,2n -k3,3n $input/combined.bed | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3}' |uniq > $input/combined1.bed
mv $input/combined1.bed $input/combined.bed

#for real data:
#get merged bed
bedtools merge -i $input/combined.bed > $input/combined_merge.bed
#calculate coverage for this merged bed
bedtools coverage -hist -sorted -g $genomefile -a $input/combined_merge.bed -b $input/combined.bed > $input/combined_merge.hist

#for simulation data
bedtools shuffle -i $input/combined.bed -g $genomefile >$input/combined_shuf.bed
sort -k1,1 -k2,2n -k3,3n $input/combined_shuf.bed > $input/combined_shuf1.bed
mv $input/combined_shuf1.bed $input/combined_shuf.bed

#get merged bed
bedtools merge -i $input/combined_shuf.bed > $input/combined_shuf_merge.bed
#calculate coverage for this merged bed
bedtools coverage -hist -sorted -g $genomefile -a $input/combined_shuf_merge.bed -b $input/combined_shuf.bed > $input/combined_shuf_merge.hist


#compare coverage distribution of real and shuffled data to decide cutoff
grep 'all' $input/combined_merge.hist | awk '{OFS="\t"}{print "Real",$0}' >$input/coverage_comp
grep 'all' $input/combined_shuf_merge.hist | awk '{OFS="\t"}{print "Sim",$0}' >>$input/coverage_comp

#decide cutoff
cutoff=`~/code/psychencode/coverage_cufoff.pl $input/coverage_comp | tee /dev/tty`

#select regions above certain coverage cufoff
#awk 'BEGIN{FS="\t";OFS="\t"}$4>=cutoff{print $0}' cutoff="$cutoff" $input/combined_merge.hist | grep -v "all" > $input/combined_merge_picked.hist # this is what we want
bedtools coverage -d -sorted -g $genomefile -a $input/combined_merge.bed -b $input/combined.bed |awk '$5>1{print $0}' > $input/combined_merge.depth
~/code/psychencode/region_extr_basedondepth.pl $input/combined_merge.depth $cutoff > $input/combined_merge_picked
fi

echo "all things done"

