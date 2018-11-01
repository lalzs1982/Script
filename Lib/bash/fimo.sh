#!/bin/bash
#this code accept fasta and .meme file to screen for motif match on the references

database=$1 #/project2/xinhe/zhongshan/data/Gencode/hg19/gencode.v19.annotation.coding.lgt.gtf.transc.fa
motif=$2

if ![ -f $database.background.forfimo ];then
~/software/bin/fasta-get-markov -rna -norc $database $database.background.forfimo # just once
fi

temp='/project2/xinhe/zhongshan/temp/fimo/'
mkdir $temp/; rm -rf $temp/*
split -l 500 $database $temp/
files=`ls $temp/* `

for file in $files
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

cat $temp/*.fimo > $database.fimo; awk 'NR==1{print $0}' $database.fimo > ./tt.f; grep -v "motif_id" $database.fimo >> ./tt.f; mv ./tt.f $database.fimo
echo "result: $database.fimo"

rm -rf $temp/
