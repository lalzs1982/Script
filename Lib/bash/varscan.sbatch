#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000
module load java
module load samtools

genome='/project2/xinhe/zhongshan/data/hg19.fa'
bam='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006/Aligned.sortedByCoord.out.bam'
#bam='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006/Aligned.sortedByCoord.out.bam'
#out='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006/editing/'
#out='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006/editing/'
#mkdir $out
echo "samtools mpileup -B -f $genome $bam | java -jar VarScan.v2.2.jar mpileup2snp --output-vcf 1 > $bam.vcf"
samtools mpileup -B -f $genome $bam |awk 'BEGIN{FS="\t";OFS="\t"}$4>10{print $0}' > $bam.pileup 
java -jar /home/zhongshan/software/VarScan.v2.3.9.jar mpileup2snp $bam.pileup --output-vcf 1 > $bam.vcf

