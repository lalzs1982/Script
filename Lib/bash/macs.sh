#!/bin/bash
module load python

cd /home/zhongshan/
inputdir=$1 

    for file in `ls $inputdir/ | grep -v "input" | grep ".bam$" `
    do
        echo "sbatch ~/code/psychencode/macs.sbatch $inputdir/$file $inputdir/input.bam"
        sbatch ~/code/psychencode/macs.sbatch $inputdir/$file $inputdir/input.bam # the results from .bam files will be .bam.bed 
    done
    
    sleep 60; # wait for 1 minutes for the job to be submitted and catched by squeue
    jobs=`squeue -u zhongshan|grep "ZSLmacs" | wc -l`
    while [ $jobs -gt 0 ]
        do
            echo "$jobs jobs is still runing, just wait ... !"
            sleep 300;
            jobs=`squeue -u zhongshan|grep "ZSLmacs" | wc -l` # note: the 'ZSLmacs' should be used to label all jobs 
        done
       
	sleep 120
 
        #ls $inputdir/*.bam | grep -v "input" | xargs rm
        
        echo "this batch of jobs are all finished !"

