
library(synapseClient)
synapseLogin(username='yuwenliu', password='helab2017', rememberMe=TRUE)

setwd('/scratch/midway/zhongshan/psychEncode/datadownload/')
organism='Homo sapiens'
assays=c('ChIP-seq', 'RNA-seq', 'miRNA-seq', 'WGBS', 'ATAC-seq', 'NOMe-seq', 'Hi-C', 'ERRBS', 'IsoSeq', 'SNPgenotypes', 'arrayMethylation', 'RPPA')
filetypes=c('bed','bam','fastq')
i=0;
for (filetype in filetypes)
{
for (assay in assays)
{
queryString <- sprintf("select id,study,disease, tissueType, group,assay,tissueTypeAbrv,assayTarget, dataType,fileType,name
from file where organism=='%s' AND fileType =='%s' AND assay=='%s' ", organism, filetype,assay) #AND fileType =='%s' 
queryResults1 <- synQuery(queryString)
print(paste("it is",nrow(queryResults1),assay,"\n"))
if(i==0){queryResults <- queryResults1}else{queryResults=rbind(queryResults,queryResults1)}
i=i+1
}
}

rec=matrix(ncol=6,nrow=0)
colnames(rec)=c('assay','assayTarget','tissueType','disease','fileType','files')
for (assay in unique(queryResults$file.assay)){
for (assaytarget in unique(queryResults$file.assayTarget)){
for(tissue in unique(queryResults$file.tissueType)){
for(disease in unique(queryResults$file.disease)){
for(filetype in unique(queryResults$file.fileType)){
    nm=nrow(queryResults[queryResults$file.assayTarget==assaytarget &
    queryResults$file.tissueType==tissue &
    queryResults$file.disease==disease &
    queryResults$file.fileType==filetype,])
    if(nm==0){next}
    rec=rbind(rec,c(assay,assaytarget,tissue,disease,filetype,nm))
}}}}}

write.table(rec,sep="\t",row.names=F,col.names=T,quote=F,file='~/scratch-midway/psychEncode/datadownload/wholedata.xls')


assays=c('ChIP-seq','WGBS','ATAC-seq','Hi-C','ERRBS')
queryResults1 <- subset(queryResults, is.element(file.assay, assays) & file.fileType=='bed')

rec1=matrix(ncol=6,nrow=0)
colnames(rec1)=c('assay','assayTarget','tissueType','disease','fileType','files')
for (assay in unique(queryResults1$file.assay)){
for (assaytarget in unique(queryResults1$file.assayTarget)){
for(tissue in unique(queryResults1$file.tissueType)){
for(disease in unique(queryResults1$file.disease)){
for(filetype in unique(queryResults1$file.fileType)){
    nm=nrow(queryResults1[queryResults1$file.assayTarget==assaytarget &
    queryResults1$file.tissueType==tissue &
    queryResults1$file.disease==disease &
    queryResults1$file.fileType==filetype,])
    if(nm==0){next}
    rec1=rbind(rec1,c(assay,assaytarget,tissue,disease,filetype,nm))
}}}}}

write.table(rec1,sep="\t",row.names=F,col.names=T,quote=F,file='~/scratch-midway/psychEncode/datadownload/wholedata1.xls')

print ("all done！")

