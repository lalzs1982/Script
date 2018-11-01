#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000
module load bedtools

file1=$1
file2=$2

sort -k1,1 -k2,2n $file1 > $file1.1 
bedtools intersect -sorted -wo -a $file1.1 -b $file2 | awk 'BEGIN{FS="\t";OFS="\t"}$3==$14{print $1,$2,$3,$4,$5}' | sort -k1,1 -k2,2n |uniq > $file1.sb

echo "rm -f $file1"
rm -f $file1
#rm -f $file2

