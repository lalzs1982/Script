#!/bin/bash

sleep 10800 #wait for a while

inputdir=$1 #fastq files folder
output="$inputdir/output"
#mkdir $output
for file in `ls $inputdir | grep _1.gz` #| head -n 1
do
file1=$file
file2=`echo $file | perl -e 'while(<>){chomp;$_=~s/_1\.gz/_2\.gz/;print $_}'` #modified for different names
file=`echo $file2 | perl -e 'while(<>){@x=split/\//,$_;print $x[-1]}'`
if ! [ -f $output/${file}.vcf ];then
echo "sbatch /home/zhongshan/code/RNAediting/RNA_seq_ana.sbatch $inputdir/$file1 $inputdir/$file2 $output"
sbatch /home/zhongshan/code/RNAediting/RNA_seq_ana.sbatch $inputdir/$file1 $inputdir/$file2 $output
#obtain $output/${file}.bam
#$output/${file}.vcf
#$output/$file.genes.fpkm_tracking
fi
done
