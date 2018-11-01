#!/bin/bash
#SBATCH --job-name=ZSLmacs
#SBATCH --output=/home/zhongshan/example_sbatch.out
#SBATCH --error=/home/zhongshan/example_sbatch.err
#SBATCH --time=24:00:00
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=16000

module unload hdf5
module unload mkl
module load python

inputfile=$1
control=$2
filename=`echo $inputfile | awk -F/ '{print $NF}'`
temp_outputdir='/project2/xinhe/zhongshan/temp/'

macs2 callpeak -t $inputfile -c $control -n $filename -f BAM -B --outdir $temp_outputdir --call-summits &> ./run_callpeak_narrow.log

if [ -f "$temp_outputdir/${filename}_peaks.narrowPeak" ]
then
    echo "mv $temp_outputdir/${filename}_peaks.narrowPeak $inputfile.narrowPeak"
    mv $temp_outputdir/${filename}_peaks.narrowPeak $inputfile.narrowPeak
    rm -f $temp_outputdir/$filename*
else
    echo "Error in: mv $temp_outputdir/${filename}_peaks.narrowPeak $inputfile.narrowPeak"
fi
