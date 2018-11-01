#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=5
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000

module load java


module load python
module load java
#1, fastqc and reads triming
file1=$1;
file2=$2;
output=$3;
trim_galore --paired -o $output --fastqc $file1 $file2


#the following process is based on the GATK best practice for RNA-seq reads mapping https://software.broadinstitute.org/gatk/documentation/article.php?id=3891

#creat genome index file, just once
genome='/project2/xinhe/zhongshan/data/hg19.fa'
gtf='/project2/xinhe/zhongshan/data/hg19_ensGene.gtf'
#echo "STAR --runThreadN 5 --runMode genomeGenerate --genomeDir /home/zhongshan/data/ --genomeFastaFiles $genome --sjdbGTFfile $gtf --sjdbOverhang 100"
#STAR --runThreadN 5 --runMode genomeGenerate --genomeDir /project2/xinhe/zhongshan/data/ --genomeFastaFiles $genome --sjdbGTFfile $gtf --sjdbOverhang 100

#mapping to genome
file1=$1 #'/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006_R1_001_val_1.fq'
file2=$2 #'/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006_R2_001_val_2.fq'
output= $3 #'/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006/'

#echo "STAR --runThreadN 5 --genomeDir /home/zhongshan/data/ --readFilesIn $file1 $file2 --outFileNamePrefix $output --outSAMattrIHstart 0 --outSAMstrandField intronMotif --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts"
#/home/zhongshan/software/bin/STAR --runThreadN 5 --genomeDir /project2/xinhe/zhongshan/data/ --readFilesIn $file1 $file2 --outFileNamePrefix $output --outSAMattrIHstart 0 --outSAMstrandField intronMotif --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts
/home/zhongshan/software/bin/STAR --runThreadN 5 --genomeDir /project2/xinhe/zhongshan/data/ --readFilesIn $file1 $file2 --outFileNamePrefix $output

#2 pass: remapping considering splice junctions identified in the first step
genomeDir=$output/hg19_2pass
mkdir $genomeDir
/home/zhongshan/software/bin/STAR --runMode genomeGenerate --genomeDir $genomeDir --genomeFastaFiles $genome \
    --sjdbFileChrStartEnd $output/SJ.out.tab --sjdbOverhang 120 --runThreadN 5

runDir=$output/2pass #where final alignments put at $output/2pass/Aligned.sortedByCoord.out.bam
mkdir $runDir
cd $runDir
/home/zhongshan/software/bin/STAR --genomeDir $genomeDir --readFilesIn $file1 $file2 --runThreadN 5

#Add read groups, sort, mark duplicates, and create index
java -jar /home/zhongshan/software/picard.jar AddOrReplaceReadGroups I=$output/2pass/Aligned.sortedByCoord.out.bam \
            O=$output/2pass/Aligned.sortedByCoord.out.rg.bam SO=coordinate RGID=id RGLB=library RGPL=platform \
            RGPU=machine RGSM=sample 
java -jar /home/zhongshan/software/picard.jar MarkDuplicates I=$output/2pass/Aligned.sortedByCoord.out.rg.bam \
            O=$output/2pass/Aligned.sortedByCoord.out.rg.dedupped.bam CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=output.metrics 

# Split'N'Trim and reassign mapping qualities
java -jar /home/zhongshan/software/GenomeAnalysisTK.jar -T SplitNCigarReads -R $genome -I $output/2pass/Aligned.sortedByCoord.out.rg.dedupped.bam \
-o $output/2pass/Aligned.sortedByCoord.out.rg.dedupped.split.bam -rf ReassignOneMappingQuality -RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS

#Base Recalibration
java -jar /home/zhongshan/software/GenomeAnalysisTK.jar \ 
    -T BaseRecalibrator \ 
    -R $genome \ 
    -I input_reads.bam \ 
    -L 20 \ 
    -knownSites /project2/xinhe/zhongshan/data/dbsnp_138.hg19.vcf \ 
    -knownSites /project2/xinhe/zhongshan/data/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \ 
    -o recal_data.table

java -jar /home/zhongshan/software/GenomeAnalysisTK.jar \ 
    -T PrintReads \ 
    -R $genome \ 
    -I input_reads.bam \ 
    -L 20 \ 
    -BQSR recal_data.table \ 
    -o recal_reads.bam


#variants calling
java -jar /home/zhongshan/software/GenomeAnalysisTK.jar -T HaplotypeCaller -R $genome -I input.bam -dontUseSoftClippedBases -stand_call_conf 20.0 -o output.vcf
java -jar /home/zhongshan/software/GenomeAnalysisTK.jar -T VariantFiltration -R $genome -V input.vcf -filterName FS -filter "FS > 30.0" -filterName QD -filter "QD < 2.0" -o output.vcf #-window 35 -cluster 3

#gene expression level estimates
module load cufflinks
file=$1
gtf=$2
outputdir=$3
cufflinks -o $outputdir -u -p 4 -G $gtf -m 145 $file

#final file would be: 
