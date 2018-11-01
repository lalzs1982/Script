#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000

module load samtools;
module load bwa

#mapping to genome
file1='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006_R1_001_val_1.fq'
file2='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006_R2_001_val_2.fq'
output='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006/'
#mkdir $output

#/home/zhongshan/software/sprint prepare -t /home/zhongshan/data/hg19_ensGene.gtf /project2/xinhe/zhongshan/data/hg19.fa /software/bwa-0.7.15-el7-x86_64/bin/bwa
echo "run NC now...";

#/home/zhongshan/software/sprint main -p 5 -1 $file1 -2 $file2 /project2/xinhe/zhongshan/data/hg19.fa $output /software/bwa-0.7.15-el7-x86_64/bin/bwa /software/samtools-1.4.1-el7-x86_64/bin/samtools

genome='/project2/xinhe/zhongshan/data/hg19.fa'
#bam='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006/Aligned.sortedByCoord.out.bam'
bam='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006/Aligned.sortedByCoord.out.bam'
#out='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006/editing/'
out='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006/editing/'
mkdir $out

/home/zhongshan/software/sprint_from_bam $bam $genome $out /software/samtools-1.4.1-el7-x86_64/bin/samtools

 
