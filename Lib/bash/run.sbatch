#!/bin/bash
#SBATCH --job-name=ZSL_ali
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=16000
module load bedtools
/scratch/midway2/zhongshan/human_macaque

bedtools intersect -wo -F 0.5 -a ./Example_windowsYW.block -b ./genome_alignment_mutSum.hg19 > ./Example_windowsYW.block.mut
./block_mut_sum.pl ./Example_windowsYW.block.mut | sort -k1,1 -k2,2n -k3,3n > ./Example_windowsYW.block.mut.sum

