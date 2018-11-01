#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/sbatch.out
#SBATCH --error=/home/zhongshan/sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000

command=$1
echo "$command ..."
$command
echo "finished"

