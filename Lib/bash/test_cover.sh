#!/bin/bash
module load bedtools;
input=$1; # one file containing many bed files for combinations
genomefile='/home/zhongshan/data/hg19_chrLen'
#sort -k1,1 $genomefile > $genomefile.1
#mv $genomefile.1 $genomefile
#it is important to make sure that the genome assembly are same!
#combine and sort
cat /dev/null > ~/tt.hist
for file in `ls  $input/| egrep ".narrowPeak|.bed" | grep -v combined`
do
    echo "$file"
    bedtools coverage -hist -sorted -g $genomefile -a ~/tt.bed -b $input/$file | awk -v file="$file" '{print $0,$file}' >> ~/tt.hist
done

echo "all things done"

