#!/bin/bash
dnm=$1 #file contain DNMs in avinput format, with 6th column represent groups(be: ASD and Control) and 7th column sample ID/ Mutation group.
#/project2/xinhe/zhongshan/DNM/DNM_byZSL/ASD/WGS/raw/comb_SNPs_JONSSON_Yuen2017.bed.1
#/project2/xinhe/zhongshan/DNM/Simons_latest/comb

anno=$2 #file contain annotation regions in bed format, with the 4 th column represent ID,
#and 5th column represent groups (usually interaction targets), and 6th column usually for resources
#/project2/xinhe/zhongshan/noncodingRNA/anno_comb
# /project2/xinhe/zhongshan/data/anno.bed

module load bedtools
module load R

#annotate annotaton regions with DNM mutation rate
#if ! [ -f $anno.mutrate ];then
#echo "no $anno.mutrate, we produce it now ...."
##~/code/DNM_rate_fromYW.sh $anno # get $anno.mutrate
#awk 'BEGIN{FS="\t";OFS="\t"}{print $0, "0.00001","0.00001"}' $anno > $anno.mutrate # make one if the mutation rate is not important
#fi
#
##retreive information for DNMs: total DNMs, syn DNMs, sample sizes for each group seperately
#if [ ! -f $dnm.hg19_multianno.txt ];then
#~/code/mutation_annotation/annovar_anno.sh $dnm # obtain $dnm.hg19_multianno.txt
#~/software/annovar/annotate_variation.pl -splicing_threshold 10 -out ex1 -build hg19 $dnm /project2/xinhe/zhongshan/data/humandb_annovar/ # obtain ex1.variant_function
#grep splicing ex1.variant_function | awk 'BEGIN{FS="\t";OFS="\t"}{print $3,$4,$5}' > ./ex1.variant_function.spl
#awk 'NR>1{print $0}' $dnm.hg19_multianno.txt > $dnm.hg19_multianno.txt.1;
#bedtools intersect -v -a $dnm.hg19_multianno.txt.1 -b ./ex1.variant_function.spl > $dnm.hg19_multianno.txt.2
#fi
#/home/zhongshan/code/DNMdata_summ.pl $dnm.hg19_multianno.txt.2 > $dnm.summ #group:sample size:total DNM:syn DNM

#calculate DNMs within each annotation region for case-control groups 
#bedtools intersect -wo -a $anno.mutrate -b $dnm > $dnm.$anno1
awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7}' $dnm > $dnm.t1
bedtools intersect -wo -a $anno -b $dnm.t1 > /project2/xinhe/zhongshan/temp/tt #$dnm.$anno1
/home/zhongshan/code/DNMdata_summ1.pl /project2/xinhe/zhongshan/temp/tt $dnm.t1 > /project2/xinhe/zhongshan/temp/tt.1 #calculate DNMs in case and control for each ID/group/All
Rscript ~/code/DNM/dnm_burden2.r /project2/xinhe/zhongshan/temp/tt.1 #obtain /project2/xinhe/zhongshan/temp/tt.1.test_p
awk 'NR==1{print $0}' /project2/xinhe/zhongshan/temp/tt.1.test_p > ./tt
awk 'NR>1{print $0}' /project2/xinhe/zhongshan/temp/tt.1.test_p | awk 'BEGIN{FS="\t";OFS="\t"}$2+$3>=2{print $0}'| sort -k6,6rn >> ./tt; mv ./tt /project2/xinhe/zhongshan/temp/tt.1.test_p

rm -f $dnm.t1
echo "final results: /project2/xinhe/zhongshan/temp/tt.1.test_p"
#

##append DNM data information
#dnmsumm=`cat $dnm.summ`
#awk -v dnmsumm="$dnmsumm" 'BEGIN{FS="\t";OFS="\t"}{print $0,dnmsumm}' $dnm.$anno1.1 > $dnm.$anno1.2
#
##calculate DNM enrichment statistics
#Rscript ~/code/DNM/dnm_burden1.r $dnm.$anno1.2 # get $dnm.$anno1.2.mb    #$dnm.$anno1.mb #statistics test of case-control differences
#sort  -k10,10rn $dnm.$anno1.2.mb > ./tt; mv ./tt $dnm.$anno1.2.mb
#echo "final result: $dnm.$anno1.2.mb"

#
#asd_all=`awk 'BEGIN{FS="\t";OFS="\t"}$13=="ASD"{print $1,$2,$3}' $dnm.1.hg19_multianno.txt | sort|uniq|wc -l`
#control_all=`awk 'BEGIN{FS="\t";OFS="\t"}$13=="Control"{print $1,$2,$3}' $dnm.1.hg19_multianno.txt | sort|uniq|wc -l`
#asd_nc=`awk 'BEGIN{FS="\t";OFS="\t"}$13=="ASD" && $9!="synonymous SNV" && $9!="nonsynonymous SNV"{print $1,$2,$3}' $dnm.1.hg19_multianno.txt | sort|uniq|wc -l`
#control_nc=`awk 'BEGIN{FS="\t";OFS="\t"}$13=="Control" && $9!="synonymous SNV" && $9!="nonsynonymous SNV"{print $1,$2,$3}' $dnm.1.hg19_multianno.txt | sort|uniq|wc -l`
#
#
#
#
######this block append expected DNM rate for the ID and group 
##anno1=`echo $anno | perl -e 'while(<>){chomp;my @x=split/\//,$_;print $x[-1]}'`
##~/code/bed_regionlen.pl $anno > $anno.len
########
#
#
#
#######this block append 7th column of synDNM , user could also use total DNM, or other could be used as same dataset control
##awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2,$3,$4,$5,$6}' $dnm > $dnm.1
#
#asd_syn=`awk 'BEGIN{FS="\t";OFS="\t"}$9=="synonymous SNV" && $13=="ASD" && ($12=="NA" || $12> -1.414) {print $1,$2,$3}' $dnm.1.hg19_multianno.txt.2 | sort|uniq|wc -l`
#control_syn=`awk 'BEGIN{FS="\t";OFS="\t"}$9=="synonymous SNV" && $13=="Control" && ($12=="NA" || $12> -1.414) {print $1,$2,$3}' $dnm.1.hg19_multianno.txt.2 | sort|uniq|wc -l`
#
#
#
#awk -v ct=$asd_all;ct1=$asd_syn;ct2=$asd_nc 'BEGIN{FS="\t";OFS="\t"}$6=="ASD"{print $1,$2,$3,$4,$5,$6,ct,ct1,ct2}' $dnm.1 > $dnm.2
#awk -v ct=$control_all;ct1=$control_syn;ct2=$control_nc 'BEGIN{FS="\t";OFS="\t"}$6=="Control"{print $1,$2,$3,$4,$5,$6,ct,ct1,ct2}' $dnm.1 >> $dnm.2
#######
#
#bedtools intersect -wo -a $anno.len -b $dnm.2 > $dnm.$anno1
#~/code/DNM/dnm_burden.pl $dnm.$anno1 > $dnm.$anno1.1 #calculate DNMs in case and control for each ID/group/All
#Rscript ~/code/DNM/dnm_burden.r $dnm.$anno1.1 $dnm.$anno1.mb #statistics test of case-control differences
##rm -f $dnm.$anno1.1
#
#echo "final result as $dnm.$anno1.mb and $dnm.$anno1.mb.pdf"
