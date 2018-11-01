#!/bin/bash

#point_alignment="/scratch/midway2/zhongshan/human_macaque/homo_sapiens_GRCh38_vs_macaca_mulatta_Mmul_8_0_1_lastz_net.chrY_32.emf" # downloaded from the ensemb database
#
##calculate block alignment data:
#cd /scratch/midway2/zhongshan/human_macaque
#cat /dev/null > ./genome_alignment_mutSum
#for file in `ls $point_alignment | egrep -v "CHR_HSCHR|scaffold"`
#do
#    ./genome_alignment_sum.pl $dir/$file >> ./genome_alignment_mutSum 
#done
#
##liftover the block coordinates from GRCH38 to hg19
#~/software/liftOver ./genome_alignment_mutSum ./hg38ToHg19.over.chain.gz ./genome_alignment_mutSum.hg19 ./unlifted.bed


##summarize to nearby 1-M block mutation counts for each point or interval
#./block_prod.pl ~/data/hg19_chrLen 1000000 | egrep -v "random|Un"> ./hg19_blocks.bed
#interval="/project2/xinhe/TADA-A/data/Example_windows_with_UTRs.bed"
#./block_prod_flank.pl 500000 $interval > ./Example_windows_with_UTRs.bed.block
#block="./Example_windows_with_UTRs.bed.block"
block=$1
awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3}' $block > $block.1
module load bedtools
#bedtools intersect -wo -F 0.5 -a ./hg19_blocks.bed -b ./genome_alignment_mutSum.hg19 > ./hg19_blocks.mut
#./block_mut_sum.pl ./hg19_blocks.mut | sort -k1,1 -k2,2n -k3,3n > ./hg19_blocks.mut.sum

mkdir ./temp/; rm -f ./temp/*; split -l 100000 -a 4 $block.1 ./temp/
for file in `ls $PWD/temp/* | grep -v mut`
do
cm1="bedtools intersect -wo -a $file -b /scratch/midway2/zhongshan/human_macaque/genome_alignment_mutSum.hg19 > $file.mut"
cm2="/scratch/midway2/zhongshan/human_macaque/block_mut_sum.pl $file.mut | sort -k1,1 -k2,2n -k3,3n > $file.mut.1"
cp /home/zhongshan/code/genome_alignment/work.sbatch ./
echo "$cm1; $cm2" >> ./work.sbatch
sbatch ./work.sbatch
#sbatch ~/code/mutation_annotation/work.sbatch "$cm1; $cm2";
sleep 5
done

jobs=`squeue -u zhongshan|grep "work" | wc -l`
while [ $jobs -gt 0 ]
do
echo "$jobs jobs is still runing, just wait ... !"
sleep 50
jobs=`squeue -u zhongshan|grep "work" | wc -l`
done

cat ./temp/*mut.1 > $block.diver
echo "final results put at $block.diver"
#rm -rf ./temp/


