#!/bin/bash
module load R
input=$1

#a, overall DeepSEA score comparison in Case/Control DNMs
Rscript ~/code/DeepSEA_res_ana.r $input/infile.vcf.out.funsig DeepSea_score

#b, HGMD-probability comparison in Case/Control DNMs
Rscript ~/code/DeepSEA_res_ana1.r $input/infile.vcf.out.snpclass HGMDprob

#b, log fold changes comparison in Case/Control DNMs for all significant features
Rscript ~/code/deepsea_feature_ana.r $input/infile.vcf.out.logfoldchange # get Simons_lncRNA/infile.vcf.out.logfoldchangefeature_comp.pdf

