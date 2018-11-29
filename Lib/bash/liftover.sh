#!/bin/bash
input=$1 #avinput 
overchain=$2
#awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2-1,$3,$1":"$2":"$3}' $input > $input.tt
awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2-1,$3,$1":"$2":"$3}' $input > $input.tt
~/software/liftOver $input.tt $overchain $input.ttt ./unmatched
~/code/liftover_back.pl $input.ttt $input > $input.over
#awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2+1,$3,$4,$5,$6,$7,$8,$9}' $input.over > ./tt; mv ./tt $input.over
#rm -f $input.ttt $input.tt ./unmatched
echo "final result: $input.over"
