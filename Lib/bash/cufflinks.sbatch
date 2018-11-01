#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000

module load cufflinks
file=$1
gtf=$2
outputdir=$3
cufflinks -o $outputdir -u -p 4 -G $gtf -m 145 $file
