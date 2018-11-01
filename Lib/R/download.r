
library(synapseClient)
synapseLogin(username='yuwenliu', password='helab2017', rememberMe=TRUE)

setwd('/scratch/midway/zhongshan/psychEncode/datadownload1')
organism='Homo sapiens'
organ='brain'
filetype='bed'
assays=c('ChIP-seq','WGBS','ATAC-seq','Hi-C','ERRBS')
i=0;
for (assay in assays)
{
queryString <- sprintf("select id,study,disease, tissueType, assay,tissueTypeAbrv,assayTarget, dataType,fileType,name
from file where organism=='%s' AND fileType =='%s' AND assay=='%s' ", organism, filetype,assay)
queryResults1 <- synQuery(queryString)
print(paste("it is",nrow(queryResults1),assay,"\n"))
if(i==0){queryResults <- queryResults1}else{queryResults=rbind(queryResults,queryResults1)}
i=i+1
}

for(assayTarget in unique(queryResults$file.assayTarget))
{
    for(tissue in unique(queryResults$file.tissueTypeAbrv)){
    for(disease in unique(queryResults$file.disease)){
    disease1=unlist(strsplit(x=disease,split=" ",fixed=T))[1]
    
    queryResults1 <- subset(queryResults, file.tissueTypeAbrv == tissue & file.assayTarget == assayTarget & file.disease==disease)
    if(length(queryResults1)<=1){next}
    
    #dir.create(paste(assayTarget,"/",tissue,'/',disease1,'/',sep=''),recursive=T)
    #write.table(queryResults1,sep="\t",quote=F,file=paste(assayTarget,"/",tissue,'/',disease1,'/queryResults',sep=''))
    #entity <- lapply(queryResults1$file.id, function(x) synGet(x,downloadLocation=paste(assayTarget,"/",tissue,'/',disease1,'/',sep='')))
    
    #entity <- lapply(queryResults1$file.id, function(x) synGet(x,downloadLocation=paste(assayTarget,"/",tissue,'/',sep='')))
    #print(paste("sbatch ~/code/psychencode/work.sbatch \"~/code/psychencode/bed_combine.sh ","~/scratch-midway/psychEncode/datadownload/",assayTarget,"/",tissue,"/\"",sep=''))
    
    #print (paste(assayTarget,"/",tissue, "/combined_merge_picked.hist",sep=''));
    #if(!file.exists(paste(assayTarget,"/",tissue,"/combined_merge_picked.hist",sep=''))){
    #print (paste("dealing with ",assayTarget,"/",tissue,sep=''));
    #system(command=paste("sbatch ~/code/psychencode/work.sbatch \"~/code/psychencode/bed_combine.sh ","~/scratch-midway/psychEncode/datadownload/",assayTarget,"/",tissue,"/\"",sep=''),wait=T)
    print(paste("~/code/psychencode/bed_combine1.sh ","~/scratch-midway/psychEncode/datadownload1/",assayTarget,"/",tissue,"/",disease1,"/",sep=''))
    system(command=paste("~/code/psychencode/bed_combine1.sh ","~/scratch-midway/psychEncode/datadownload1/",assayTarget,"/",tissue,"/",disease1,'/',sep=''),wait=T)
    #}
}
}
}

print ("all done！")

