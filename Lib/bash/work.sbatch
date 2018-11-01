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

#command=$1
#echo "$command"
#$command

#bedtools intersect -wo -F 0.5 -a /scratch/midway2/zhongshan/human_macaque/temp/aadl -b /scratch/midway2/zhongshan/human_macaque/genome_alignment_mutSum.hg19 > /scratch/midway2/zhongshan/human_macaque/temp/aadl.mut; /scratch/midway2/zhongshan/human_macaque/block_mut_sum.pl /scratch/midway2/zhongshan/human_macaque/temp/aadl.mut | sort -k1,1 -k2,2n -k3,3n > /scratch/midway2/zhongshan/human_macaque/temp/aadl.mut.1
