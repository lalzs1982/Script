#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000

module load samtools
module load bcftools
module load vcftools
genome='/project2/xinhe/zhongshan/data/hg19.fa'
#file='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/KD_ATAGCG_S127_L006/Aligned.sortedByCoord.out.bam'
file='/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006/Aligned.sortedByCoord.out.bam'

samtools mpileup -uf $genome $file | bcftools view - > $file.raw.bcf 
bcftools view $file.raw.bcf | vcfutils.pl varFilter -D100 > $file.flt.vcf  

