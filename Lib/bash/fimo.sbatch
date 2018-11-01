#!/bin/bash
#SBATCH --job-name=work
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32000

database=$1
motif=$2
~/software/bin/fasta-get-markov -rna -norc $database $database.background.forfimo # just once
/home/zhongshan/software/bin/fimo --bgfile $database.background.forfimo --skip-matched-sequence --text --norc --max-stored-scores 100000 $motif $database > $database.fimo # --oc $toutput.withmut --no-qvalue

