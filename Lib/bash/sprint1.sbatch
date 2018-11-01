#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example1_sbatch.out
#SBATCH --error=/home/zhongshan/example1_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=10
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=16000

module load samtools;
module load bwa

#mapping to genome

echo "run KD now ...";

file1='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006_R1_001_val_1.fq'
file2='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006_R2_001_val_2.fq'
output='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006_new/'
mkdir $output
/home/zhongshan/software/sprint main -p 10 -1 $file1 -2 $file2 /project2/xinhe/zhongshan/data/hg19.fa $output /software/bwa-0.7.15-el7-x86_64/bin/bwa /software/samtools-1.4.1-el7-x86_64/bin/samtools

echo "finshed!"

 
