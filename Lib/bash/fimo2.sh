#!/bin/bash

database=$1
motif=$2
temp='/project2/xinhe/zhongshan/temp/fimo/'
#~/software/bin/fasta-get-markov -rna -norc $database $database.background.forfimo # just once

mkdir $temp/
rm -rf $temp/*
split -l 4000 $database $temp/

for file in `ls $temp/* | grep -v "fimo$"`
do
echo "sbatch /home/zhongshan/code/FIMO/fimo.sbatch $file $motif "
sbatch /home/zhongshan/code/FIMO/fimo.sbatch $file $motif 
done

tasks=`squeue -u zhongshan | grep -v JOBID| wc -l`
while [ $tasks -gt 0 ]
do
echo "$tasks tasks runing, just wait ..."
sleep 200
tasks=`squeue -u zhongshan | grep -v JOBID| wc -l`
done

echo "FIMO runing finished!"

cat $temp/*.fimo > $database.fimo

