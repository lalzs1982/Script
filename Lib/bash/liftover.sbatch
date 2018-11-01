#!/bin/bash
#SBATCH --job-name=ZSL_job
#SBATCH --output=/home/zhongshan/sbatch.out
#SBATCH --error=/home/zhongshan/sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000

input=$1 #avinput 
overchain=$2
awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2-1,$3,$1":"$2":"$3}' $input > $input.tt
~/software/liftOver $input.tt $overchain $input.ttt ./unmatched
~/code/liftover_back.pl $input.ttt $input > $input.over
awk 'BEGIN{FS="\t";OFS="\t"}{print $1,$2+1,$3,$4,$5,$6,$7,$8,$9}' $input.over > ./tt; mv ./tt $input.over

rm -f $input.ttt $input.tt ./unmatched

#echo "final result: $input.over"

