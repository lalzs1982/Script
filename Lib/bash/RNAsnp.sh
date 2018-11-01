#!/bin/bash
#var=$1 # list of variants
ref=$1 #fasta sequences
gtf=$2 #gtf file corresponding to $ref

temp="/project2/xinhe/zhongshan/temp/"
mkdir $temp
rm -rf $temp/*

for ti in `grep '>' $ref | perl -e 'while(<>){chomp;$_=~/>(.*)/;print "$1\n"}'`
do
    if [ ! -f $temp/$ti ];then
    grep -A 1 "$ti$" $ref > $temp/$ti
    echo "sbatch ~/code/mutation_annotation/RNAsnp.sbatch $temp/$ti"
    sbatch ~/code/mutation_annotation/RNAsnp.sbatch $temp/$ti # obtain $temp/$ti.rnasnp 
    fi
    
    wc=`squeue -u zhongshan | grep -v "TIME" | wc -l `
    while [ $wc -gt 100 ]
    do
        echo "$wc jobs runing, wait..."
        sleep 300
        wc=`squeue -u zhongshan | grep -v "TIME" | wc -l`
    done

done

sleep 10
wc=`squeue -u zhongshan | grep -v "TIME" | wc -l `
while [ $wc -gt 0 ]
do
    echo "$wc jobs runing, wait..."
    sleep 300
    wc=`squeue -u zhongshan | grep -v "TIME" | wc -l`
done

cat /dev/null > $ref.RNAsnp.1
for res in `ls $temp/ | grep "rnasnp$" `
do
echo "awk -v tr=$res 'BEGIN{FS="\t";OFS="\t"}{print $0,tr}' $temp/$res >> $ref.RNAsnpM3"
awk -v tr=$res 'BEGIN{FS="\t";OFS="\t"}{print $0,tr}' $temp/$res >> $ref.RNAsnpM3
#rm -f $res
done

/home/zhongshan/code/mutation_annotation/rnasnp_result_org.pl $ref.RNAsnpM3 > $ref.RNAsnpM3.bed

#obtain absolute genomic coordinates:
#order the gtf file, positive strand increasing, negative strand decreasing
perl -e 'while(<>){chomp;$_=~/transcript_id\s\"(.*?)\"/;print join("\t",$_,$1),"\n"}' $gtf > $gtf.1
awk 'BEGIN{FS="\t";OFS="\t"}$7=="+"{print $0}' $gtf.1 | sort -k 10 -k 4n > $gtf.ordered
awk 'BEGIN{FS="\t";OFS="\t"}$7=="-"{print $0}' $gtf.1 | sort -k 10 -k 4nr >> $gtf.ordered
/home/zhongshan/code/mutation_annotation/transPos2genomePos.pl $ref.RNAsnpM3.bed $gtf.ordered >$ref.RNAsnpM3.bed.abspos


echo "finished, all result put in $ref.RNAsnp"

