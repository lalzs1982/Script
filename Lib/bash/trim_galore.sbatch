#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=16000


module load python
module load java
#1, fastqc and reads triming
file1=$1;
file2=$2;
output=$3;
trim_galore --paired -o $output --fastqc $file1 $file2

