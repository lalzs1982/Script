#!/bin/bash
temp=/project2/xinhe/zhongshan1/temp/dnmrate_exome
mkdir $temp
#0, datasets:
#all possible syn, unsplicing mutations with context and gene information across transcriptome:
allmut=/project2/xinhe/zhongshan1/data/gene_stru/gencode.v29lift37.basic.annotation.cds.gtf.bed.allmut.syn

#DNM related genomic features:
features_withvalues=/project2/xinhe/zhongshan1/data/DNM_genomicfeatures/DNM_genomicfeatures_withvalues_comb
features_regions=/project2/xinhe/zhongshan1/data/DNM_genomicfeatures/DNM_genomicfeatures_regions_comb

#population variation data with allele frequency 
popvar=/project2/xinhe/zhongshan1/data/popVar/gnomAD/exome/gnomad.exomes.r2.1.sites.AC_AN
#genome=/project2/xinhe/zhongshan1/data/hg19.fa

#1, annotate allmut as for wheter it's singleton popvar
awk 'BEGIN{FS="\t";OFS="\t"}$6==1{print $1,$2,$2,$4,$5}' $popvar > $temp/gnome.singleton
/project2/xinhe/zhongshan1/code/perl/overlap.pl $allmut $temp/gnome.singleton 0,1,2,3,4 0,1,2,3,4 \
|   awk 'BEGIN{FS="\t";OFS="\t"}{if($8=="NULL") print $1,$2,$3,$4,$5,$6,$7,0;else print $1,$2,$3,$4,$5,$6,$7,1}' \
> $temp/allmut.anno

#2,  annotate allmut as for population singleton variation frequency (observed/total syn) for each gene
perl -e 'my %rec;while(<>){chomp;my @x=split/\t/;my($gene,$var)=@x[5,7];$rec{$gene}{'total'}++;$rec{$gene}{'var'}+=$var};for my $gene(keys%rec){print join("\t",$gene,$rec{$gene}{"var"}/$rec{$gene}{"total"}),"\n"}' \
                         $temp/allmut.anno > $temp/allmut.anno.1;
/project2/xinhe/zhongshan1/code/perl/overlap.pl $temp/allmut.anno  $temp/allmut.anno.1 5 0 | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$10}'
                                                > $temp/allmut.anno.2
mv $temp/allmut.anno.2 $temp/allmut.anno; rm $temp/allmut.anno.1

#add column names manually

#3, annotate allmut as for genomics features
/project2/xinhe/zhongshan1/code/bash/bed_anno.sh $temp/allmut.anno $features_regions #get $temp/allmut.anno.1
/project2/xinhe/zhongshan1/code/bash/bed_anno.sh $temp/allmut.anno.1 $features_withvalues # get $temp/allmut.anno.1.1
mv $temp/allmut.anno.1.1 $temp/allmut.anno
rm $temp/allmut.anno.1






##
#estimtate DNM rate in exom regions using population variation data


#1, pre-processings: all possible mutations from CDS regions produced along with 7-mer features:

#annotate retrieve synonymous ones  for further use:
# $genes.bed.allmut.syn 

#2, annotate syn mutations as for 


###
#2, annotate the synonymous mutations as for popvar and genomic features


#3, add nonsplicing syn variants for each gene dividid by total possible nonsplicing syn variants

#4, statistics modeling

#5, Comparison with other mutation rate models:


