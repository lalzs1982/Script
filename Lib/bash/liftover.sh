#!/bin/bash
input=$1 #avinput 
overchain=$2

temp=/project2/xinhe/zhongshan/temp/
rm -f $temp/*; cd $temp; split --lines $(( $(wc -l < $input) / 2)) $input; cd;
ls $temp/ > $temp/filelist

for file in `cat $temp/filelist | grep -v filelist`
do
wl=`squeue -u zhongshan | wc -l`
while [ $wl -gt 100 ]
do
    echo "$wl jobs runing, too many, hold on ..."
    sleep 60
    wl=`squeue -u zhongshan | wc -l`
done
sbatch /home/zhongshan/code/liftover.sbatch $temp/$file $overchain # get $temp/$file.over
echo "sbatch /home/zhongshan/code/liftover.sbatch $temp/$file $overchain"
done

wl=`squeue -u zhongshan | wc -l`
while [ $wl -gt 1 ]
do
    echo "$wl jobs runing ..."
    sleep 30
    wl=`squeue -u zhongshan | wc -l`
done

cat /dev/null > $input.over
for file in `cat $temp/filelist | grep -v filelist`
do
cat $temp/$file.over >> $input.over
#rm -f $temp/$file.over
done

echo "final result: $input.over produced"
