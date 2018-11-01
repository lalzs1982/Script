#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=16000

module load bedtools
transc=$1 #transcript
file1='/project2/xinhe/zhongshan/data/hg19_refGenes_exons.gtf'
grep $transc $file1.Allmut > $file1.Allmut.$transc
grep $transc $file1.Allmut.withgenomiccoors > $file1.Allmut.withgenomiccoors.$transc
bedtools intersect -sorted -wo -a $file1.Allmut.$transc -b $file1.Allmut.withgenomiccoors.$transc \
| awk 'BEGIN{FS="\t";OFS="\t"}$2==$7{print $1,$2,$3,$4,$5,$9,$10,$11,$12}' > $file1.Allmut.cooroverlap.$transc
rm -f $file1.Allmut.$transc
rm -f $file1.Allmut.withgenomiccoors.$transc

