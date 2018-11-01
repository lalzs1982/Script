#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=10
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000

module load python

#creat genome index file
genome='/project2/xinhe/zhongshan/data/hg19.fa'
bam='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006/Aligned.sortedByCoord.out.bam'
#bam='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006/Aligned.sortedByCoord.out.bam'
out='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006/editing/'
#out='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006/editing/'
known='/project2/xinhe/zhongshan/data/DARNED_hg19.1'
mkdir $out
echo "/home/zhongshan/software/bin/REDItoolKnown.py -i $bam -f $genome -l $known -t 10 -o $out"
/home/zhongshan/software/bin/REDItoolKnown.py -i $bam -f $genome -l $known -t 10 -o $out

echo "finished";

