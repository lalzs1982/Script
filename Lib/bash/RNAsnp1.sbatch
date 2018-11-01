#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --mem=2G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
###SBATCH --mem-per-cpu=16000

module load bedtools
ref=$1 #one sequence fasta
var=$2 # list of SNPs in the format as required by RNAsnp 
/home/zhongshan/software/bin/RNAsnp -f $ref -s $var > $ref.RNAsnpresult
/home/zhongshan/code/mutation_annotation/rnasnp_result_org.pl $transc $ref.$var.RNAsnpresult > $transc.RNAsnpresult.bed    



#transc=$1
#
#grep -A 1 $transc $ref > $ref.$transc
#grep $transc $var |awk 'BEGIN{FS="\t"}{print $4$3$5}' > $var.$transc
#
#wl1=`wc -l $ref.$transc | awk '{print $1}'`
#wl2=`wc -l $var.$transc | awk '{print $1}'`
#if [ $wl1 -ge 1 ] && [ $wl2 -gt 1 ]; then
#/home/zhongshan/software/bin/RNAsnp -f $ref.$transc -s $var.$transc > $var.$transc.RNAsnpresult
#/home/zhongshan/code/mutation_annotation/rnasnp_result_org.pl $transc $var.$transc.RNAsnpresult > $transc.RNAsnpresult.bed    
#fi
#rm -f $ref.$transc $var.$transc
#awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2-500,$2+500,$1":"$2","$4">"$5}' $var > $var.500bpflan$var > $var.k
#/home/zhongshan/code/mutation_annotation/genome_seq_extr.sh /home/zhongshan/data/hg19.fa $var.500bpflank
#/home/zhongshan/code/mutation_annotation/genome_seq_extr.sh $ref $var 100 #obtain $var.fa
#/home/zhongshan/code/mutation_annotation/RNAsnp_wrap.pl $var.fa # obtain $var.fa.RNAsnpresult
#/home/zhongshan/code/mutation_annotation/rnasnp_result_org.pl $var.fa.RNAsnpresult > $var.fa.RNAsnpresult.bed

