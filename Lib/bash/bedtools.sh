#!/bin/bash

file1=$1; #large bed
file2=$2; #large bed

temp="/project2/xinhe/zhongshan/temp/";rm -rf $temp/*;
split -a 4 -l 10000000 $file1 $temp/

for file in `ls $temp/* | grep -v ".sb$"`
do
echo "sbatch ~/code/bedtools.sbatch $file $file2"
sbatch ~/code/bedtools.sbatch $file $file2 # obtain $file.sb

jobs=`squeue -u zhongshan | wc -l`
while [ $jobs -gt 100 ]
do
echo "$jobs runing, hold on ..."
sleep 5
jobs=`squeue -u zhongshan | wc -l`
done
done

jobs=`squeue -u zhongshan | wc -l`
while [ $jobs -gt 1 ]
do
echo "$jobs runing, hold on ..."
sleep 5
jobs=`squeue -u zhongshan | wc -l`
done

cat /dev/null > $file1.sba
for file in `ls $temp/* | grep ".sb$"`
do
echo "cat $file >> $file1.sba"
cat $file >> $file1.sba
done

echo "all finished, please check $file1.sba"

