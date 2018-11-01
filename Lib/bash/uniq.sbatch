#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000
file1=$1
#nm=$2

#grep $nm $file1 > $file1.$nm

wl=`wc -l $file1 | awk '{print $1}'`
if [ $wl -gt 1 ];then
cut -f 1,2,3 $file1 | sort -k1,1 -k2,2n |uniq > $file1.sb
fi
rm -f $file1

