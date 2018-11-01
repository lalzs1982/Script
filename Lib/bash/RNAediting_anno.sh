#!/bin/bash
module load bedtools
#source data
input="/project2/xinhe/zhongshan/data/RNAediting/comb.bed"
hg19='/project2/xinhe/zhongshan/data/hg19.fa'
#transc_coors='/project2/xinhe/zhongshan/data/hg19_refGenes_exons.gtf'
#transcript_seq="$transc_coors.transc.fa"
#cut -f 1,4,5 $transc_coors | sort -k1,1 -k2,2n |uniq > $transc_coors.1
#basedir='/project2/xinhe/zhongshan/UTR3'
#Hu_pfm_CisBP="$basedir/CisBP-RNA/Human/motif_withname.meme"
#Hu_pfm_RBPDB="$basedir/RBPDB_database/motif_withnames.meme"
RBP_bdsites="/project2/xinhe/zhongshan/CLIPdb/human_combined"
ribosnitch="/project2/xinhe/zhongshan/data/hg19_refGenes_exons.gtf.lg.transc.fa.RNAsnpM3.bed.abspos"
phastconsscores="/project2/xinhe/zhongshan/phastcons_hg19/" #from UCSC
phylopscores="/project2/xinhe/zhongshan/phyloP46way_hg19/" #from UCSC
#ribosnitch="$basedir/PMID24476892/RiboSNitches_hg19.bed"
repeat='/project2/xinhe/zhongshan/data/hg19_repeatmask.bed'

utrciselements="/project2/xinhe/zhongshan/UTRdb/UTR_Hum.dat.ciselements_hg18.hg19" #from UTRdb
utrmirna='/project2/xinhe/zhongshan/UTRdb/3UTRaspic.Hum.dat.ciselements_hg18.hg19.miRNA'
#outdir='/project2/xinhe/zhongshan/data/transcript_anno/'
out="/project2/xinhe/zhongshan/data/RNAediting/tt"
#unitran='/project2/xinhe/zhongshan/data/transcript_anno/unitran'
#simplified coors
#awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$4,$5}' $transc_coors | sort -k1,1 -k2,2n -k3,3n | uniq > $transc_coors.1  

#gene mutation effect
awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$3,$3,"A","G"}' $input > $input.avinput

~/software/annovar/table_annovar.pl --outfile $out $input.avinput /scratch/midway2/zhongshan/humandb_annovar/ -otherinfo -buildver hg19 -protocol refGene,targetScanS,gwava,gerp++,fathmm,dann,cadd,eigen -operation g,r,f,f,f,f,f,f -nastring NA

#position annotations
##RBP
anno="$RBP_bdsites"
bedtools intersect -wo -a $transc_coors.1 -b $anno > $out.1
~/code/mutation_annotation/bed2point.pl $out.1 |sort -k1,1 -k2,2n |uniq > $out.rbp; 

##UTR ciselement
anno="$utrciselements"
bedtools intersect -wo -a $transc_coors.1 -b $anno > $out.1
~/code/mutation_annotation/bed2point.pl $out.1 |sort -k1,1 -k2,2n |uniq > $out.utrcis; 

##miRNA binding from expeiment
anno="$utrmirna"
bedtools intersect -wo -a $transc_coors.1 -b $anno > $out.1
~/code/mutation_annotation/bed2point.pl $out.1 |sort -k1,1 -k2,2n |uniq > $out.UTRdb_miRNA; 

##Ribosnitch
anno="$ribosnitch"
bedtools intersect -wo -a $transc_coors.1 -b $anno > $out.1
~/code/mutation_annotation/bed2point.pl $out.1 |sort -k1,1 -k2,2n |uniq > $out.ribosnitch; 

##repeat
anno="$repeat"
bedtools intersect -wo -a $transc_coors.1 -b $anno > $out.1
~/code/mutation_annotation/bed2point.pl $out.1 |sort -k1,1 -k2,2n |uniq > $out.repeat;

##GC contents
#~/code/gccontents.sh $var 50 #obtain $var.gccontent
#echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tGC"}' > $var.gc
#bedtools intersect -f 1 -wao -a $var -b $var.gccontent | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$10}' >> $var.gc

##phastcons
~/code/phastcon_phylop/score_retrive_wholetranscript.sh $transc_coors /project2/xinhe/zhongshan/phastcons_hg19/ #obtain $var.withscore
sort -k 4nr $transc_coors.withscore > $transc_coors.withscore.phastcon #ordered

##phylop
~/code/phastcon_phylop/score_retrive_wholetranscript.sh $transc_coors /project2/xinhe/zhongshan/phyloP46way_hg19/ #obtain $var.withscore
mv $transc_coors.withscore $transc_coors.withscore.phylop

##RNA secondary structure: stem or not
~/code/RNALfold1.sh $transcript_seq #obtain $transcript_seq.RNALfold.bed
mv $transcript_seq.RNALfold.bed $out.RNALfold
./code/uniq.sh $out.RNALfold # obtain $out.RNALfold.sb
grep "^N" $out.RNALfold.sb |sort -k1,1 -k2,2n > $out.RNALfold.unipos

#evofold
/home/zhongshan/code/RNALfold2.pl /project2/xinhe/zhongshan/data/hg19_Evofold > /project2/xinhe/zhongshan/data/hg19_Evofold.pos
bedtools intersect -u -a /project2/xinhe/zhongshan/data/hg19_Evofold.pos -b $transc_coors > /project2/xinhe/zhongshan/data/hg19_Evofold.pos.intranscript
mv /project2/xinhe/zhongshan/data/hg19_Evofold.pos.intranscript $out.Evofold

###motif binding
#~/code/FIMO/fimo2.sh $transcript_seq $Hu_pfm_CisBP # obtain $transcript_seq.fimo
#mv $transcript_seq.fimo $transcript_seq.CisBP.fimo
#awk 'BEGIN{FS="\t";OFS="\t"}{print $3,$4,$5,$1}' $transcript_seq.CisBP.fimo | grep -v "^#"> $transcript_seq.CisBP.fimo.bed
#~/code/mutation_annotation/bed2point1.pl $transcript_seq.CisBP.fimo.bed > $transcript_seq.CisBP.fimo.bed.pos
#mv $transcript_seq.CisBP.fimo.bed.pos $out.CisBP.fimo
#
#~/code/FIMO/fimo2.sh $transcript_seq $Hu_pfm_RBPDB # obtain $transcript_seq.fimo
#mv $transcript_seq.fimo $transcript_seq.RBPDB.fimo
#awk 'BEGIN{FS="\t";OFS="\t"}{print $3,$4,$5,$1}' $transcript_seq.RBPDB.fimo | grep -v "^#"> $transcript_seq.RBPDB.fimo.bed
#~/code/mutation_annotation/bed2point1.pl $transcript_seq.RBPDB.fimo.bed > $transcript_seq.RBPDB.fimo.bed.pos
#mv $transcript_seq.RBPDB.fimo.bed.pos $out.RBPDB.fimo

#allele specific annotations

##RNAsnp
###first retrive RNA secondary structure positions based on RNALfold software:
#/home/zhongshan/code/bedtools.sh
#~/code/bedtools.sh $allmut $out.RNALfold.unipos #obtain $allmut.sba
#mv $allmut.sba $allmut.inRNALfold
#bedtools intersect -sorted -u -a $allmut -b $out.RNALfold.unipos | awk 'BEGIN{FS="\t";OFS="\t"}$3==$14{print $1,$2,$3,$4,$5}' | sort|uniq > $allmut.forRNAsnp
###run RNAsnp using mode 3 on longest transcripts

#~/code/mutation_annotation/RNAsnp.sh $transc_coors.lg.transc.fa # obtain $transc_coors.lg.transc.fa.RNAsnpM3.bed.abspos

#convert to allele specific changes for YW
#~/code/AS_muteff.pl $transc_coors.lg.transc.fa.RNAsnpM3.bed.abspos > /project2/xinhe/zhongshan/whole_transc_anno_forYW/hg19_refGenes.RNAsnpM3

#$allmut.inRNALfold obtain $allmut.inRNALfold.RNAsnpresult.bed, p value in last columns
#awk 'BEGIN{FS="\t";OFS="\t"}$6<0.05{print $0}' $var.500bpflank.fa.RNAsnpresult.bed > $var.500bpflank.fa.RNAsnpresult.bed.1
#echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tRNAsnp"}' > $var.RNAsnp
#bedtools intersect -f 1 -wao -a $var -b $var.500bpflank.fa.RNAsnpresult.bed | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$12}' >> $var.RNAsnp

##motif binding differences
###frist retrive mutations within motif binding regions
#bedtools intersect -sorted -u -a $allmut -b $out.CisBP.fimo | awk 'BEGIN{FS="\t";OFS="\t"}$3==$13{print $1,$2,$3,$4,$5}' |uniq|sort|uniq > $out.CisBP.fimo.forfimo

###compare for differences
#~/code/FIMO/fimo1.sh $Hu_pfm_CisBP $transc_coors.formotif $transc_coors.transc.fa # obtain $transc_coors.formotif.fimodiff


















##splicing



##SIFT
##Polyphen
##CADD


#####

#pathovar="/project2/xinhe/zhongshan/eQTL/eQTL_pathogenic_vars" #another set of pathogenic variants

#preparations
#use bedtools to obtain common SNPs, eQTLs in 3'UTR, in avinput format, and remove indels
#awk 'BEGIN{FS="\t";OFS="\t"}NR>1{if($6>0.05 && $2==$3)print "chr"$1,$2,$3,$4,$5}' $popSNPs > $popSNPs.avinput
#bedtools intersect -wo -a $popSNPs.avinput -b $UTR3_coor_hg19 | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5, "Common"}' | grep -v '-'> $var
#bedtools intersect -wo -a $eQTLgtex -b $UTR3_coor_hg19 | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,"eQTL"}' | grep -v '-' >> $var
#~/code/mutation_annotation/beduni.pl $var | sort -k1,1 -k2,2n > $var.1; mv $var.1 $var 

#bedtools intersect -wo -a $pathovar -b $UTR3_coor_hg19 | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6}' > $pathovar.utr3
#var="$pathovar.utr3"
#
#annotations
# match with RBP binding sites from experiment
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tRBP"}' > $var.rbp
bedtools intersect -f 1 -wao -a $var -b $RBP_bdsites | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$10}' >> $var.rbp

#9, match with RiboSNitches
#bedtools intersect -f 1 -wao -a $var.rbp -b $ribosnitch | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$13}' > $var.rbp.ribosnitch
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tribosnitch"}' > $var.ribosnitch
bedtools intersect -f 1 -wao -a $var -b $ribosnitch | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$12}' >> $var.ribosnitch

#match with UTR ciselements
#bedtools intersect -f 1 -wao -a $var.rbp.ribosnitch -b $utrciselements | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$12}' > $var.rbp.ribo.cise
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tutrciselements"}' > $var.utrciselements
bedtools intersect -f 1 -wao -a $var -b $utrciselements | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$10}' >> $var.utrciselements

#retrive phastcons score
~/code/phastcon_phylop/score_retrive.sh $var /project2/xinhe/zhongshan/phastcons_hg19/ #obtain $var.withscore
mv $var.withscore $var.withscore.phastcon
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tphastcons"}' > $var.phastcons
bedtools intersect -f 1 -wao -a $var -b $var.withscore.phastcon | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$12}' >> $var.phastcons

#retrive phylop score
~/code/phastcon_phylop/score_retrive.sh $var /project2/xinhe/zhongshan/phyloP46way_hg19/ #obtain $var.withscore
mv $var.withscore $var.withscore.phylop
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tphylop"}' > $var.phylop
bedtools intersect -f 1 -wao -a $var -b $var.withscore.phylop | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$12}' >> $var.phylop

#GC content
~/code/gccontents.sh $var 50 #obtain $var.gccontent
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tGC"}' > $var.gc
bedtools intersect -f 1 -wao -a $var -b $var.gccontent | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$10}' >> $var.gc

#RBP motif matching score differences between ref alt
~/code/FIMO/fimo1.sh $Hu_pfm_CisBP $var # obtain $var.fimodiff, from 7th columns: motif, ref score, ref p value, mut score, mut p value, score diff
mv $var.fimodiff $var.CisBP.fimodiff
awk 'BEGIN{FS="\t";OFS="\t"}$9<0.0001 || $11<0.0001{print $0}' $var.CisBP.fimodiff > $var.CisBP.fimodiff.1
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tCisBP"}' > $var.CisBP
bedtools intersect -f 1 -wao -a $var -b $var.CisBP.fimodiff.1 | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$13}' >> $var.CisBP

~/code/FIMO/fimo1.sh $Hu_pfm_RBPDB $var # obtain $var.fimodiff
mv $var.fimodiff $var.RBPDB.fimodiff
awk 'BEGIN{FS="\t";OFS="\t"}$9<0.0001 || $11<0.0001{print $0}' $var.RBPDB.fimodiff > $var.RBPDB.fimodiff.1
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tRBPDB"}' > $var.RBPDB
bedtools intersect -f 1 -wao -a $var -b $var.RBPDB.fimodiff.1 | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$13}' >> $var.RBPDB

#RNAsnp predicted mutation effect on RNA secondary structure
#~/code/mutation_annotation/RNAsnp.sh $var # obtain $var.500bpflank.fa.RNAsnpresult.bed, p value in last columns
#awk 'BEGIN{FS="\t";OFS="\t"}$6<0.05{print $0}' $var.500bpflank.fa.RNAsnpresult.bed > $var.500bpflank.fa.RNAsnpresult.bed.1
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tRNAsnp"}' > $var.RNAsnp
bedtools intersect -f 1 -wao -a $var -b $var.500bpflank.fa.RNAsnpresult.bed | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$12}' >> $var.RNAsnp

#miRNA targeting, gwava and CADD scores ...
#match miRNA binding and predicted mutaton effects:
~/code/mutation_annotation/annovar_anno.sh $var
~/code/mutation_annotation/multianno_pars1.pl $var.hg19_multianno.txt Chr     Start   End     Ref     Alt     targetScanS GWAVA_region_score gerp++ FATHMM_noncoding dann CADD Eigen| awk 'NR>0{print $0}' > $var.annovar
awk 'NR>1{print $0}' $var.annovar > $var.annovar.1
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\ttargetScanS\tGWAVA_region_score\tgerp\tFATHMM_noncoding\tdann\tCADD\tEigen"}' > $var.annovar
bedtools intersect -f 1 -wao -a $var -b $var.annovar.1 | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$12,$13,$14,$15,$16,$17,$18}' >> $var.annovar
#rm -f $var.hg19_*

#match with miRNA binding from UTRdb
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tmiRNA"}' > $var.miRNA
bedtools intersect -f 1 -wao -a $var -b $utrmirna | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$10}' >> $var.miRNA

#RNA secondary structure annotations by RNALfold: whether in Stem or Loop strucure:
~/code/RNALfold.sh $UTR3fa $var #obtain $var.RNALfold
awk 'NR>1{print $0}' $var.RNALfold > $var.RNALfold.1
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tRNALfold"}' > $var.rnalfold
bedtools intersect -f 1 -wao -a $var -b $var.RNALfold.1 | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$13}' >> $var.rnalfold

#add distance to 3'UTR 5'end
bedtools intersect -wo -a $UTR3_coor_hg19 -b $var > ./tt.bed
~/code/utr3_pos.pl ./tt.bed > $var.UTRenddist
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tUTRenddist"}' > $var.UTRdist
bedtools intersect -f 1 -wao -a $var -b $var.UTRenddist | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$10}' >> $var.UTRdist

#add repeat sequence annotations
echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\trepeat"}' > $var.repeat
bedtools intersect -f 1 -wao -a $var -b /project2/xinhe/zhongshan/data/rm_sd_sr.bed | awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$10}' >> $var.repeat

##combined together as columns
/home/zhongshan/code/bedcombine.pl $var.rbp $var.ribosnitch $var.utrciselements $var.phastcons $var.phylop $var.gc $var.CisBP $var.RBPDB $var.RNAsnp $var.annovar $var.miRNA $var.rnalfold $var.UTRdist $var.repeat > $var.anno



##
#echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tRBP\tRibosnitch\tUTRcis\tPhastcons\tPhylop\tGC\tCisBP\tRBPDB\tRNAsnp\ttargetScanS\tGWAVA_region_score\tCADD_Phred\tgerp++\tFATHMM_noncoding\tdann\tEigen"}' > $var.anno
#echo "" | awk '{print "Chr\tStart\tEnd\tRef\tAlt\tCate\tRBP\tRibosnitch\tUTRcis\tPhastcons\tPhylop\tGC\tCisBP\tRBPDB\tRNAsnp\ttargetScanS\tGWAVA_region_score\tgerp\tFATHMM_noncoding\tdann\tCADD\tEigen"}' > $var.anno
#cat $var.rbp.ribo.cise.phastcons.phylop.gc.CisBP.RBPDB.RNAsnp.annovar >> $var.anno

#~/code/mutation_annotation/pos_neg_split.pl $var.anno Phylop CisBP RBPDB > $var.anno.2;
#mv $var.anno.2 $var.anno #split negative, positive values to seperate columns

#summarize and organize the table
#~/code/mutation_annotation/forcaret.pl $var.anno > $var.anno.caret1 # caret1 split more specificly, for example each RBP per column, rather than all RBPs in caret1
#~/code/mutation_annotation/factor_reduce.pl $var.anno.caret1 0.005 > $var.anno.caret1.1 #remove fators with values in too few positions


#~/code/mutation_annotation/bed_collapse.pl $var.anno > $var.anno.1
~/code/mutation_annotation/forcaret1.pl  $var.anno > $var.anno.forcaret # this dosnot split
