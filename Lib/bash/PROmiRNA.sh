#!/bin/bash
module load bedtools R python

gff=$1 # annotations of miRNA in gff, /project2/xinhe/zhongshan/noncodingRNA/miRNA/miRBase/hsa.hg19.gff3
genes=/project2/xinhe/zhongshan/data/Gencode/hg19/gencode.v19.annotation.coding.geneboundary.gtf
outputdir=zsl_regions
mkdir /project2/xinhe/zhongshan/tools/PROmiRNA/$outputdir

#awk 'BEGIN{FS="\t";OFS="\t"}$3=="miRNA_primary_transcript"{print $0}' $gff > $gff.premiRNA
bedtools intersect -u -a $gff -b $genes | \
awk 'BEGIN{FS="\t";OFS="\t"}$3=="miRNA_primary_transcript"{print $1,"miRBase","intron",$4,$5,$6,$7,$8,$9}' > $gff.forPROmiRNA
bedtools intersect -v -a $gff -b $genes | \
awk 'BEGIN{FS="\t";OFS="\t"}$3=="miRNA_primary_transcript"{print $1,"miRBase","intergenic",$4,$5,$6,$7,$8,$9}' >> $gff.forPROmiRNA

perl -e 'while(<>){chomp;my @x=split/\t/;my ($l,$r);if($x[6] eq "+"){$r=$x[3];$l=$r-100000>0?($r-100000):1}else{$l=$x[4];$r=$l+100000};print join("\t",@x[0..2],$l,$r,@x[5..8]),"\n";}' $gff.forPROmiRNA > $gff.forPROmiRNA.1

#awk 'BEGIN{FS="\t";OFS="\t"}$7=="+"{print $1,$2,$3,$4-100000,$4,$6,$7,$8,$9}' $gff.forPROmiRNA > $gff.forPROmiRNA.1
#awk 'BEGIN{FS="\t";OFS="\t"}$7=="-"{print $1,$2,$3,$5,$5+100000,$6,$7,$8,$9}' $gff.forPROmiRNA >> $gff.forPROmiRNA.1
perl -e 'while(<>){chomp;my @x=split/\t/;$_=~/Name=(.*)/;print join("\t",@x[0..7],"microRNA_id=$1"),"\n"}' $gff.forPROmiRNA.1 > /project2/xinhe/zhongshan/tools/PROmiRNA/zsl_regions.gff

cd /project2/xinhe/zhongshan/tools/PROmiRNA/
split -l 50 zsl_regions.gff split

for file in `ls ./ | grep "^split"`
do
outputdir="dir_$file"
mkdir $outputdir 
echo "sbatch ~/code/PROmiRNA.sbatch $outputdir $file"
sbatch ~/code/PROmiRNA.sbatch $outputdir $file
done

cat /dev/null > /project2/xinhe/zhongshan/tools/PROmiRNA/zsl_regions.gff.PROmiRNA.re
for file in `ls dir_split*/mirna_predicted_promoters.txt`
do
cat $file >> /project2/xinhe/zhongshan/tools/PROmiRNA/zsl_regions.gff.PROmiRNA.re
done

~/code/PROmiRNA.re.bestsel.pl /project2/xinhe/zhongshan/tools/PROmiRNA/zsl_regions.gff.PROmiRNA.re > /project2/xinhe/zhongshan/tools/PROmiRNA/zsl_regions.gff.PROmiRNA.re.best

#perl -e 'while(<>){chomp;my @x=split/\t/;$x[6]=~/prob_prom:(.*)/;my $p=$1;if($p>0.8){print join("\t","chr".$x[1],@x[2..3]),"\n"}}' /project2/xinhe/zhongshan/tools/PROmiRNA/zsl_regions.gff.PROmiRNA.re > /project2/xinhe/zhongshan/tools/PROmiRNA/zsl_regions.gff.PROmiRNA.re.sig


