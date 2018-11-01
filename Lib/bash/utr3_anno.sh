#!/bin/bash
module load bedtools
#note hg19 assembly was used
var=$1 #avinput format, only SNPs
awk 'BEGIN{FS="\t";OFS="\t"}{if(length($4)==1 && length($5)==1){print $0}}' $var > $var.1
mv $var.1 $var

basedir='/project2/xinhe/zhongshan/UTR3'
RBP_bdsites="$basedir/auar_database/AURAlight_trans-factors.hg19.RBP.abscoor.txt"
ribosnitch="$basedir/PMID24476892/RiboSNitches_hg19.bed"
Hu_pfm_CisBP_fimo="$basedir/CisBP-RNA/Human/motif_withnames.meme2UTR.fimo.q0.1.bed"
Hu_pfm_RBPDB_fimo="$basedir/RBPDB_database/motif_withnames.meme2UTR.fimo.q0.1.bed"
## retrive 3'UTR sequences
#~/code/mutation_annotation/genome_seq_extr.sh $hg19 $UTR3_coor_hg19 #obtain $UTR3_coor_hg19.fa
#analysis
# match with RBP binding sites from experiment
bedtools intersect -wao -a $var -b $RBP_bdsites | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$9}' | sort|uniq > $var.rbp

#predicted mutation effect on RNA secondary structure
awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2-500,$2+500,$1":"$2","$4">"$5}' $var > $var.500bpflank
~/code/mutation_annotation/genome_seq_extr.sh ~/data/hg19.fa $var.500bpflank #$var.500bpflank.fa
#~/code/mutation_annotation/RNAsnp_wrap.pl $var.500bpflank.fa # obtain $var.500bpflank.fa.RNAsnpresult
mkdir ./temp/; split -l 1800 $var.500bpflank.fa ./temp/
for file in `ls $PWD/temp/* | grep -v RNAsnpresult`
do
sbatch ~/code/mutation_annotation/work.sbatch "/home/zhongshan/code/mutation_annotation/RNAsnp_wrap.pl $file";
sleep 5
done

jobs=`squeue -u zhongshan|grep "work" | wc -l`
while [ $jobs -gt 0 ]
do
echo "$jobs jobs is still runing, just wait ... !"
sleep 100
jobs=`squeue -u zhongshan|grep "work" | wc -l`
done
cat ./temp/*RNAsnpresult > $var.500bpflank.fa.RNAsnpresult
rm -rf ./temp/

~/code/mutation_annotation/rnasnp_result_org.pl $var.500bpflank.fa.RNAsnpresult > $var.500bpflank.fa.RNAsnpresult.bed

#match with RiboSNitches
bedtools intersect -wao -a $var -b $ribosnitch | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$11}' | sort|uniq > $var.ribosnitch

#match with PFM
bedtools intersect -wao -a $var -b $Hu_pfm_CisBP_fimo | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$11}' | sort|uniq > $var.CisBP
bedtools intersect -wao -a $var -b $Hu_pfm_RBPDB_fimo | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$11}' | sort|uniq > $var.RBPDB

#match with conserved elements, miRNA binding and predicted mutaton effects:
~/code/mutation_annotation/annovar_anno.sh $var
~/code/mutation_annotation/multianno_pars1.pl $var.hg19_multianno.txt Chr     Start   End     Ref     Alt     targetScanS CADD_phred GERP++_RS phyloP46way_placental phastConsElements46way | awk 'NR>1{print $0}' > $var.annovar
rm -f $var.hg19_*

# combine all into one big annotation table
~/code/mutation_annotation/bedcombine.pl "RBP,RNAsnp,ribosnitch,PFM(CisBP),PFM(RBPDB),targetScanS,CADD_phred,GERP++_RS,phyloP46way_placental,phastConsElements46way" $var.rbp $var.500bpflank.fa.RNAsnpresult.bed $var.ribosnitch $var.CisBP $var.RBPDB $var.annovar > $var.anno

#convert table for use by CARET (machine learning), which contail categorical, numeric or NA values only
~/code/mutation_annotation/table2caret.pl $var.anno > $var.anno.forcaret


