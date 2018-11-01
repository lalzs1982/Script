#!/bin/bash
module load bedtools

#source data
basedir='/project2/xinhe/zhongshan/UTR3'
UTR3_coor_hg19="$basedir/UTRs/UTR3_coor_hg19_longestUTR_coding"
hg19='/home/zhongshan/data/hg19.fa'
commonSNPs="$basedir/ExAC/ExAC.r1.sites.vephg19_common.vcf"
Hu_pfm_CisBP="$basedir/CisBP-RNA/Human/pwms_all_motifs/"
Hu_pfm_RBPDB="$basedir/RBPDB_database/PFMDir/"
RBP_bdsites="$basedir/auar_database/AURAlight_trans-factors.txt"
ribosnitch="$basedir/PMID24476892/RiboSNitches"

#preparations
#use bedtools to obtain common SNPs in 3'UTR
#commonSNPs_3UTR="$basedir/ExAC/ExAC.r1.sites.vephg19_common.3UTR.vcf"

#combine the multiple PFM files into one MEME format file for FIMO using tomeme.sh and add name using add_genename.pl in specific directory :
Hu_pfm_CisBP="$basedir/CisBP-RNA/Human/motif_withname.meme"
Hu_pfm_RBPDB="$basedir/RBPDB_database/motif_withnames.meme"

#extract human RBPs, add absolute coordinates, and format to BED:
egrep -v "let|miR|mir|P-" $RBP_bdsites |grep "hg19" > $basedir/auar_database/AURAlight_trans-factors.hg19.RBP.txt
$basedir/auar_database/absolute_coor.pl $basedir/auar_database/UTR_hg19.fasta $basedir/auar_database/AURAlight_trans-factors.hg19.RBP.txt | awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$5,1,$4}' > $basedir/auar_database/AURAlight_trans-factors.hg19.RBP.abscoor.txt
RBP_bdsites= "$basedir/auar_database/AURAlight_trans-factors.hg19.RBP.abscoor.txt"

#ribosnitch file formated to BED: Note, sthe RiboSnitches should consider base changes and positions, but only position here
ribosnitch="$basedir/PMID24476892/RiboSNitches"
ribosnitch="$basedir/PMID24476892/RiboSNitches_hg19.bed"

#convert RBP binding coordinates to hg19 coordinates using /home/zhongshan/code/mutation_annotation/absolute_coor.pl
RBP_bdsites="$basedir/auar_database/AURAlight_trans-factors.hg19.RBP.abscoor.txt"

#analysis
#obtain all possible sequence variants on 3'UTR from human genome
## retrive 3'UTR sequences
~/code/mutation_annotation/genome_seq_extr.sh $hg19 $UTR3_coor_hg19 #obtain $UTR3_coor_hg19.fa 
#to be finished

#convert variants analyzed to avinput format
~/software/annovar/convert2annovar.pl -format vcf4 $commonSNPs > $commonSNPs.avinput
var="$commonSNPs.avinput"

#retrive 3UTR vars
bedtools intersect -wo -a $var -b $UTR3_coor_hg19 | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5}' > $var.3utr
var="$var.3utr"

#annotations
# match with RBP binding sites from experiment
bedtools intersect -wao -a $var -b $RBP_bdsites | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$9}' > $var.rbp

#match with conserved elements, miRNA binding and predicted mutaton effects:
~/code/mutation_annotation/annovar_anno.sh $var
~/code/mutation_annotation/multianno_pars1.pl $var.hg19_multianno.txt Chr     Start   End     Ref     Alt     targetScanS CADD_phred GERP++_RS phyloP46way_placental phastConsElements46way | awk 'NR>1{print $0}' > $var.annovar
rm -f $var.hg19_*

#8 predicted mutation effect on RNA secondary structure
awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2-500,$2+500,$1":"$2","$4">"$5}' $var > $var.500bpflank
~/code/mutation_annotation/genome_seq_extr.sh ~/data/hg19.fa $var.500bpflank
~/code/mutation_annotation/RNAsnp_wrap.pl $var.500bpflank.fa # obtain $var.500bpflank.fa.RNAsnpresult
~/code/mutation_annotation/rnasnp_result_org.pl $var.500bpflank.fa.RNAsnpresult > $var.500bpflank.fa.RNAsnpresult.bed

#9, match with RiboSNitches
bedtools intersect -wao -a $var -b $ribosnitch | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$11}' > $var.ribosnitch

#10, match with PFM (predicted RNA binding sites)
#we have matched the PFM downloaded to 3'UTR sequences using online tool fimo,with results at:
Hu_pfm_CisBP_fimo="$basedir/CisBP-RNA/Human/motif_withnames.meme2UTR.fimo"
Hu_pfm_RBPDB_fimo="$basedir/RBPDB_database/motif_withnames.meme2UTR.fimo"
awk '$9<0.10{print $0}' $Hu_pfm_CisBP_fimo > $Hu_pfm_CisBP_fimo.q0.1
awk '$9<0.10{print $0}' $Hu_pfm_RBPDB_fimo > $Hu_pfm_RBPDB_fimo.q0.1
~/code/mutation_annotation/fimo_to_bed.pl $UTR3_coor_hg19 $Hu_pfm_CisBP_fimo.q0.1 > $Hu_pfm_CisBP_fimo.q0.1.bed
~/code/mutation_annotation/fimo_to_bed.pl $UTR3_coor_hg19 $Hu_pfm_RBPDB_fimo.q0.1 > $Hu_pfm_RBPDB_fimo.q0.1.bed

bedtools intersect -wao -a $var -b $Hu_pfm_CisBP_fimo.q0.1.bed | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$11}' > $var.CisBP
bedtools intersect -wao -a $var -b $Hu_pfm_RBPDB_fimo.q0.1.bed | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$11}' > $var.RBPDB

#11, match with PFM (predicted RNA binding sites) in the case of mutations
#to be doing

#last step, combine all into one big annotation table
~/code/mutation_annotation/bedcombine.pl "RBP,RNAsnp,ribosnitch,PFM(CisBP),PFM(RBPDB),targetScanS,CADD_phred,GERP++_RS,phyloP46way_placental,phastConsElements46way" $var.rbp $var.500bpflank.fa.RNAsnpresult.bed $var.ribosnitch $var.CisBP $var.RBPDB $var.annovar > $var.anno
