#!/bin/bash
fa=$1; #fasta file of sequences

temp='/project2/xinhe/zhongshan/temp/'
rm -rf $temp/*
split -l 2000 $fa $temp/

for file in `ls $temp/* | grep -v RNALfold`
do
echo "sbatch /home/zhongshan/code/RNALfold.sbatch $file"
sbatch /home/zhongshan/code/RNALfold.sbatch $file #obtain $file.RNALfold
done

tasks=`squeue -u zhongshan | grep -v JOBID| wc -l`
while [ $tasks -gt 0 ]
do
echo "$tasks tasks runing, just wait ..."
sleep 20
tasks=`squeue -u zhongshan | grep -v JOBID| wc -l`
done

echo "RNALfold runing finished!"
cat $temp/*RNALfold > $fa.RNALfold
~/code/RNALfold1.pl $fa.RNALfold > $fa.RNALfold.bed

