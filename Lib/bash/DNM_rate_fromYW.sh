#!/bin/bash
bed=$1
temp=/project2/xinhe/zhongshan/temp/
#rm -f $temp/*; cd $temp; split --lines $(( $(wc -l < $bed) / 200)) $bed; cd; ls $temp/ > $temp/filelist

for file in `cat $temp/filelist | grep -v filelist`
do

wl=`squeue -u zhongshan | wc -l`
while [ $wl -gt 200 ]
do
    echo "$wl jobs runing, too many, hold on ..."
    sleep 60
    wl=`squeue -u zhongshan | wc -l`
done
wl1=`wc -l $temp/$file.mutrate | awk '{print $1}'`
if [ $wl1 -lt 2 ];then
#if [ ! -f $temp/$file.mutrate ];then
sbatch /home/zhongshan/code/DNM_rate_fromYW.sbatch $temp/$file # get $temp/$file.mutrate 
echo "batch /home/zhongshan/code/DNM_rate_fromYW.batch $temp/$file"
fi
done

wl=`squeue -u zhongshan | wc -l`
while [ $wl -gt 1 ]
do
    echo "$wl jobs runing ..."
    sleep 30
    wl=`squeue -u zhongshan | wc -l`
done

for file in `cat $temp/filelist | grep -v filelist`
do
cat $temp/$file.mutrate >> $bed.mutrate
done
#/home/zhongshan/code/mutrate_add.pl $bed.mutrate > $bed.mutrate.1; mv $bed.mutrate.1 $bed.mutrate; #same region may be split apart in above file split steps, so need add up
#rm -f $temp/*
echo "final result: $bed.mutrate produced"