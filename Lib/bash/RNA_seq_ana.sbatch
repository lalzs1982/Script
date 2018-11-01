#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000

module load java
module load python
module load cufflinks

genome='/project2/xinhe/zhongshan/data/hg19.fa'
gtf='/project2/xinhe/zhongshan/data/hg19_ensGene.gtf'
gtf1='/project2/xinhe/zhongshan/data/hg19_refGenes_exons.gtf'
snp='/project2/xinhe/zhongshan/data/dbsnp_138.hg19.vcf'
indel='/project2/xinhe/zhongshan/data/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf'

file1=$1;
file2=$2;
output=$3;

file=`echo $file2 | perl -e 'while(<>){@x=split/\//,$_;print $x[-1]}'`;

if ! [ -f $output/${file}.vcf ]; then
#1, fastqc and reads triming
/home/zhongshan/software/bin/trim_galore --paired -o $output --fastqc $file1 $file2 # obtain _val_1, _va2_2
file=`echo $file1 | perl -e 'while(<>){@x=split/\//,$_;print $x[-1]}'`; file1="$output/${file}_val_1.fq.gz"
file=`echo $file2 | perl -e 'while(<>){@x=split/\//,$_;print $x[-1]}'`; file2="$output/${file}_val_2.fq.gz"
#note the $file will be used as prefix for following analysis

#the following process is based on the GATK best practice for RNA-seq reads mapping https://software.broadinstitute.org/gatk/documentation/article.php?id=3891

#creat genome index file, just once
#echo "STAR --runThreadN 5 --runMode genomeGenerate --genomeDir /home/zhongshan/data/ --genomeFastaFiles $genome --sjdbGTFfile $gtf --sjdbOverhang 100"
#STAR --runThreadN 5 --runMode genomeGenerate --genomeDir /project2/xinhe/zhongshan/data/ --genomeFastaFiles $genome --sjdbGTFfile $gtf --sjdbOverhang 100

#creat dict
#java -jar /home/zhongshan/software/picard.jar CreateSequenceDictionary R=/project2/xinhe/zhongshan/data/hg19.fa O=/project2/xinhe/zhongshan/data/hg19.dict


#mapping to genome
#file1=$1 #'/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006_R1_001_val_1.fq'
#file2=$2 #'/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006_R2_001_val_2.fq'
#output= $3 #'/project2/xinhe/zhongshan/RNAediting/RNA-Seq1/trimmed/NC_AGGCTA_S126_L006/'

#echo "STAR --runThreadN 5 --genomeDir /home/zhongshan/data/ --readFilesIn $file1 $file2 --outFileNamePrefix $output --outSAMattrIHstart 0 --outSAMstrandField intronMotif --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts"
echo "/home/zhongshan/software/bin/STAR --runThreadN 2 --genomeDir /project2/xinhe/zhongshan/data/ \
--readFilesIn $file1 $file2 --outFileNamePrefix $output/$file --outSAMattrIHstart 0 --outSAMstrandField intronMotif \
--outSAMtype BAM SortedByCoordinate --quantMode GeneCounts"
/home/zhongshan/software/bin/STAR --runThreadN 3 --readFilesCommand zcat --genomeDir /project2/xinhe/zhongshan/data/ \
--readFilesIn $file1 $file2 --outFileNamePrefix $output/$file --outSAMattrIHstart 0 --outSAMstrandField intronMotif \
--outSAMtype BAM SortedByCoordinate --quantMode GeneCounts
#obtain $output/${file}Aligned.sortedByCoord.out.bam

#2 pass: remapping considering splice junctions identified in the first step, important for junction finding
#genomeDir=$output/star_2pass
#mkdir $genomeDir
#/home/zhongshan/software/bin/STAR --runMode genomeGenerate --genomeDir $genomeDir --genomeFastaFiles $genome \
#    --sjdbFileChrStartEnd $output/SJ.out.tab --sjdbOverhang 120 --runThreadN 5
#
#runDir=$output/2pass #where final alignments put at $output/2pass/Aligned.sortedByCoord.out.bam
#mkdir $runDir
#cd $runDir
#/home/zhongshan/software/bin/STAR --genomeDir $genomeDir --readFilesIn $file1 $file2 --runThreadN 5

#Add read groups, sort, mark duplicates, and create index
java -jar /home/zhongshan/software/picard.jar AddOrReplaceReadGroups I=$output/${file}Aligned.sortedByCoord.out.bam \
            O=$output/${file}Aligned.sortedByCoord.out.rg.bam SO=coordinate RGID=id RGLB=library RGPL=ILLUMINA \
            RGPU=machine RGSM=sample 
java -jar /home/zhongshan/software/picard.jar MarkDuplicates I=$output/${file}Aligned.sortedByCoord.out.rg.bam \
            O=$output/${file}Aligned.sortedByCoord.out.rg.dedupped.bam CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=output.metrics 

# Split'N'Trim and reassign mapping qualities
java -jar /home/zhongshan/software/GenomeAnalysisTK.jar -T SplitNCigarReads -R $genome \
-I $output/${file}Aligned.sortedByCoord.out.rg.dedupped.bam \
-o $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.bam -rf ReassignOneMappingQuality \
-RMQF 255 -RMQT 60 -U ALLOW_N_CIGAR_READS

#Base Recalibration
java -jar /home/zhongshan/software/GenomeAnalysisTK.jar -T BaseRecalibrator -nct 8 -R $genome \
-I $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.bam -knownSites $snp \
-knownSites $indel -o $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.bam.recal

java -jar /home/zhongshan/software/GenomeAnalysisTK.jar -T PrintReads -nct 8 \
-R $genome -I $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.bam \
-BQSR $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.bam.recal \
-o $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.recal.bam

#variants calling
java -jar /home/zhongshan/software/GenomeAnalysisTK.jar -T HaplotypeCaller -nct 8 -R $genome \
-I $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.recal.bam \
-dontUseSoftClippedBases -stand_call_conf 20.0 -o $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.recal.bam.vcf

java -jar /home/zhongshan/software/GenomeAnalysisTK.jar -T VariantFiltration -R $genome \
-V $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.recal.bam.vcf \
-filterName FS -filter "FS > 30.0" -filterName QD -filter "QD < 2.0" \
-o $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.recal.bam.filtered.vcf #-window 35 -cluster 3

#gene expression level estimates
mkdir $output/$file
cufflinks -o $output/$file -u -p 8 -G $gtf1 -m 145 $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.recal.bam
mv $output/$file/genes.fpkm_tracking $output/$file.genes.fpkm_tracking; rm -rf $output/$file

#rm -f $output/${file}Aligned.sortedByCoord.out.bam $output/${file}Aligned.sortedByCoord.out.rg.bam \
$output/${file}Aligned.sortedByCoord.out.rg.dedupped.bam $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.bam \

#final file would be:
#$output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.recal.bam.filtered.vcf
#$output/$file.genes.fpkm_tracking
cp $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.recal.bam.filtered.vcf $output/${file}.vcf
cp $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.recal.bam $output/${file}.bam

fi

rm -f $output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.recal.bam.filtered.vcf \
$output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.recal.bam \
$file1 $file2 \
$output/${file}Aligned.sortedByCoord.out.bam \
$output/${file}Aligned.sortedByCoord.out.rg.bam \
$output/${file}Aligned.sortedByCoord.out.rg.dedupped.bam \
$output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.bam \
$output/${file}Aligned.sortedByCoord.out.rg.dedupped.split.recal.bam


echo "all finished"