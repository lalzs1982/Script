#!/bin/bash
module load bedtools
#cd /project2/xinhe/zhongshan/UTR3/UTRs

ref=$1 #human genome reference
coor=$2 # gtf file with only exons
awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$4-1,$5,$1":"$4":"$5":"$7,0,$7}' $coor |sort|uniq > $coor.0
bedtools getfasta -fi $ref -bed $coor.0 -s -name -fo $coor.fa #note, here we use gtf for $coor, sequence is accurate, but the left cordinates on resultant fa file name line should add 1 to match that of gtf
#order exons, then sequences could be directly concnated later by order

perl -e 'while(<>){chomp;my @x=split/\t/;$_=~/transcript_id\s\"(.*?)\"/;my $ti=$1;print join("\t",@x[0,3,4],$ti,0,$x[6]),"\n"}' $coor > $coor.1
awk 'BEGIN{FS="\t";OFS="\t"}$6=="+"{print $0}' $coor.1 | sort -k4,4 -k2,2n > $coor.2;
awk 'BEGIN{FS="\t";OFS="\t"}$6=="-"{print $0}' $coor.1 | sort  -k4,4 -k2,2rn >> $coor.2;

#mv $coor.1 $coor
~/code/exonseq_concnate.pl $coor.fa $coor.2 > $coor.transc.fa #note the exon orders in $coor should be increasingly ordered
echo "output $coor.transc.fa"