#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=50
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=16000
module load R
Rscript /home/zhongshan/code/caret.r $1 $2 #defined the input tab file and dependent variable
echo "Rscript /home/zhongshan/code/caret.r $1 $2"

