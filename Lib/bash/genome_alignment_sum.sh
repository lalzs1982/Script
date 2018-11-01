#!/bin/bash
cd /scratch/midway2/zhongshan/human_macaque
cat /dev/null > ./genome_alignment_mutSum
dir=$1;
for file in `ls $dir | egrep -v "CHR_HSCHR|scaffold"`
do
    echo "./genome_alignment_sum.pl $dir/$file >> ./genome_alignment_mutSum"
    ./genome_alignment_sum.pl $dir/$file >> ./genome_alignment_mutSum 
done

exit 1

#liftover the coordinates from GRCH38 to hg19
~/software/liftOver ./genome_alignment_mutSum ./hg38ToHg19.over.chain.gz ./genome_alignment_mutSum.hg19 ./unlifted.bed


#summarize to 1-M block mutation counts on hg19
#./block_prod.pl ~/data/hg19_chrLen 1000000 | egrep -v "random|Un"> ./hg19_blocks.bed
./block_prod_flank.pl 500000 /project2/xinhe/TADA-A/data/Example_windows.bed > ./Example_windowsYW.block
./block_prod_flank.pl 500000 /project2/xinhe/TADA-A//data/enhancers_flanking_2.5kb/Example_enhancer_windows.bed > ./Example_enhancer_windowsYW.block

module load bedtools
#bedtools intersect -wo -F 0.5 -a ./hg19_blocks.bed -b ./genome_alignment_mutSum.hg19 > ./hg19_blocks.mut
#./block_mut_sum.pl ./hg19_blocks.mut | sort -k1,1 -k2,2n -k3,3n > ./hg19_blocks.mut.sum

bedtools intersect -wo -F 0.5 -a ./Example_windowsYW.block -b ./genome_alignment_mutSum.hg19 > ./Example_windowsYW.block.mut
./block_mut_sum.pl ./Example_windowsYW.block.mut | sort -k1,1 -k2,2n -k3,3n > ./Example_windowsYW.block.mut.sum

bedtools intersect -wo -F 0.5 -a ./Example_enhancer_windowsYW.block -b ./genome_alignment_mutSum.hg19 > ./Example_enhancer_windowsYW.block.mut
./block_mut_sum.pl ./Example_enhancer_windowsYW.block.mut | sort -k1,1 -k2,2n -k3,3n > ./Example_enhancer_windowsYW.block.mut.sum
