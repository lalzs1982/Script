#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=20
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000

#creat genome index file
genome='/project2/xinhe/zhongshan/data/hg19.fa'
gtf='/project2/xinhe/zhongshan/data/hg19_ensGene.gtf'
#echo "STAR --runThreadN 5 --runMode genomeGenerate --genomeDir /home/zhongshan/data/ --genomeFastaFiles $genome --sjdbGTFfile $gtf --sjdbOverhang 100"
#STAR --runThreadN 5 --runMode genomeGenerate --genomeDir /project2/xinhe/zhongshan/data/ --genomeFastaFiles $genome --sjdbGTFfile $gtf --sjdbOverhang 100

#mapping to genome
file1='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006_R1_001_val_1.fq'
file2='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006_R2_001_val_2.fq'
output='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006/'
mkdir $output
echo "STAR --runThreadN 20 --genomeDir /home/zhongshan/data/ --readFilesIn $file1 $file2 --outFileNamePrefix $output --outSAMattrIHstart 0 --outSAMstrandField intronMotif --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts"

/home/zhongshan/software/bin/STAR --runThreadN 3 --genomeDir /project2/xinhe/zhongshan/data/ --readFilesIn $file1 $file2 --outFileNamePrefix $output --outSAMattrIHstart 0 --outSAMstrandField intronMotif --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts

#
