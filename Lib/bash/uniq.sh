#!/bin/bash

file1=$1; #large bed
temp="/project2/xinhe/zhongshan/temp/";
#cut -f 1 $file1 |uniq|sort|uniq > $file1.uninames
#unitran='/project2/xinhe/zhongshan/data/transcript_anno/unitran'
rm -rf $temp/*
echo "split -a 4 -l 1000000 $file1 $temp/"
split -a 4 -l 1000000 $file1 $temp/ 

#for nm in `cat $unitran`
for file in `ls $temp/* | grep -v ".sb$"`
do
echo "sbatch ~/code/uniq.sbatch $file1 $nm "
sbatch ~/code/uniq.sbatch $file # obtain $file.sb

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

cat /dev/null > $file1.sb
#for nm in `cat $unitran`
#do
for file in `ls $temp/* | grep ".sb$"`
do
echo "cat $file >> $file1.sb"
cat $file >> $file1.sb
rm -f $file
done

echo "all finished, please check $file1.sb"


