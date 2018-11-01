#!/bin/bash
module load python

cd /home/zhongshan/
inputdir=$1 
#jobs=`squeue -u zhongshan|grep "ZSLmacs" | wc -l`
        
    for file in `ls $inputdir/ | grep -v "input" | grep ".bam$" `
    do
        
        if [ -e $inputdir/$file.narrowPeak ]
        then
            echo "$inputdir/$file.narrowPeak existed!"
            continue
        fi
        #echo "rm -f $inputdir/$file"
        #rm -f $inputdir/$file
        echo "sbatch ~/code/psychencode/macs.sbatch $inputdir/$file $inputdir/input.bam"
        sbatch ~/code/psychencode/macs.sbatch $inputdir/$file $inputdir/input.bam # the results from .bam files will be .bam.bed 
        #sleep 5; # wait for 1 minutes for the job to be submitted and catched by squeue
    
    done

        #ls $inputdir/*.bam | grep -v "input" | xargs rm
        
        echo "this batch of jobs are all submitted !"

