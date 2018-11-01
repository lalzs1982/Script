#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=5
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000

file1=$1 #gtf file for transcripts
file2=$2; #fasta file of genome sequences
module load bedtools

perl -e 'while(<>){chomp;my @x=split/\t/,$_;$_=~/transcript_id\s\"(.*)\"/;print join("\t",@x[0,3,4],$1,"0",$x[6]),"\n"}' $file1 > $file1.bed
awk 'BEGIN{FS="\t";OFS="\t"}$6=="+"{print $0}' $file1.bed | sort -k 4 -k 2n > $file1.1;
awk 'BEGIN{FS="\t";OFS="\t"}$6=="-"{print $0}' $file1.bed | sort -k 4 -k 2rn >> $file1.1;
mv $file1.1 $file1.bed

awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2-1,$3,$4,$5,$6}' $file1.bed > $file1.bed.1 #
bedtools getfasta -fi $file2 -bed $file1.bed.1 -s -name -fo $file1.fa #note, the left coordinates on header line should +1
perl -e 'while(<>){chomp;if($_=~/(chr.*):(\d+)\-(\d+)(\([+-]\))/){print ">$1:",$2+1,"-","$3$4\n";}else{print $_,"\n";}}' $file1.fa > $file1.fa.1
mv $file1.fa.1 $file1.fa

~/code/exonseq_concnate.pl $file1.fa $file1.bed > $file1.transc.fa # concnate to produce whole transcript sequences

#
/home/zhongshan/code/mutation_annotation/Allmutation_introduce.pl $file1.transc.fa > $file1.Allmut # produce all possible mutations

cut -f 1##add genomic coordinates
~/code/allmut_on_transcript.pl $file1.bed > $file1.Allmut.withgenomiccoors
#sort -k1,1 -k2,2n $file1.Allmut > $file1.Allmut.1; mv $file1.Allmut.1 $file1.Allmut
#sort -k1,1 -k2,2n $file1.Allmut.withgenomiccoors > $file1.Allmut.withgenomiccoors.1; mv $file1.Allmut.withgenomiccoors.1 $file1.Allmut.withgenomiccoors
cut -f 1 $file1.Allmut |uniq > /project2/xinhe/zhongshan/temp/all_transc



cat /dev/null > $file1.Allmut.1
for transc in `cat /project2/xinhe/zhongshan/temp/all_transc`
do

if [ -f $file1.Allmut.cooroverlap.$transc ]; then
#sbatch ~/code/mutation_annotation/coor_overlap.sbatch $transc # obtain $file1.Allmut.cooroverlap.$transc
#echo "sbatch ~/code/mutation_annotation/coor_overlap.sbatch $transc"

#jobs=`squeue -u zhongshan | wc -l`
#echo "$jobs jobs run"
#
#while [ $jobs -gt 50 ]
#do
#    echo "$jobs jobs run, please wait ...";
#    sleep 10
#    jobs=`squeue -u zhongshan | wc -l`
#done
rm -f $file1.Allmut.cooroverlap.$transc
#cat $file1.Allmut.cooroverlap.$transc >> $file1.Allmut.1
fi
done

perl -e 'my %comp=("A"=>"T","T"=>"A","G"=>"C","C"=>"G","U"=>"A"); my($ref,$alt);while(<>){chomp;my @x=split;if($x[8] eq '-'){$ref=$compl{uc($x[4])};$alt=$compl{uc($x[5])}}else{$ref=$x[4] eq "U"?T:$x[4];$alt=$x[5] eq "U"?T:$x[5];}; print $_,"$ref\t$alt","\n"} ' $file1.Allmut.1 > $file1.Allmut.2




#awk 'BEGIN{FS="\t";OFS="\t"}$2==$9{print $4,$5,$6,$11,$12,$1,$2,$3,$7}' /project2/xinhe/zhongshan/tt1 > /project2/xinhe/zhongshan/tt2
#echo "comes to perl now";
#cat /project2/xinhe/zhongshan/tt2 | perl -e my %comp=(A=>T,T=>A,G=>C,C=>G); while(<>){chomp;my @x=split;if($x[7] eq '-'){$x[3]=$compl{uc($x[3])};$x[4]=$compl{uc($x[4])}};print $_,"\n"}' > $file1.Allmut.withgenomiccoors.1
