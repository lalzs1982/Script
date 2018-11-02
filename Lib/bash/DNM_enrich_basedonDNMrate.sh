#!/bin/bash #this script was used to calculate enrichment of DNMs in specific genomic regions according to estimated DNM rate
dnm=$1 #DNM lists file (annovar input format, with 6-8 columns for individual ID, phenotype and study)
DNMrate=$2 #DNM rate for each position (.bw maybe for different mutation types)
regions=$3 #specific genomic regions for DNM overenrichment analysis (.bed, id on 4th columns), this could also be bed with ref/alt allele in the 5th/6th columns 
total=$3 #total possible regions analyzed (.bed), same format as for regions above. 

#0,  



