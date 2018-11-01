
library(synapseClient)
synapseLogin(username='yuwenliu', password='helab2017', rememberMe=TRUE)

setwd('/scratch/midway/zhongshan/psychEncode/datadownload')
organism='Homo sapiens'
organ='brain'
filetype='bed'

#download ERRBS
assays=c('ERRBS')#c('ChIP-seq','WGBS','ATAC-seq','Hi-C','ERRBS')
i=0;
for (assay in assays)
{
queryString <- sprintf("select id,study,disease, tissueType, assay,tissueTypeAbrv,assayTarget, dataType,fileType,name
from file where organism=='%s' AND assay=='%s' ", organism, assay)
queryResults1 <- synQuery(queryString)
print(paste("it is",nrow(queryResults1),assay,"\n"))
if(i==0){queryResults <- queryResults1}else{queryResults=rbind(queryResults,queryResults1)}
i=i+1
}
dir.create(paste(assay,'/',sep=''),recursive=T)
entity <- lapply(queryResults$file.id, function(x) synGet(x,downloadLocation=paste(assay,'/',sep='')))






for(assayTarget in unique(queryResults$file.assayTarget))
{
    for(tissue in unique(queryResults$file.tissueTypeAbrv)){
    queryResults1 <- subset(queryResults, file.tissueTypeAbrv == tissue & file.assayTarget == assayTarget)
    if(length(queryResults1)==0){next}
    
    #dir.create(paste(assayTarget,"/",tissue,'/',sep=''),recursive=T)
    #write.table(queryResults1,sep="\t",quote=F,file=paste(assayTarget,"/",tissue,'/queryResults',sep=''))
    #entity <- lapply(queryResults1$file.id, function(x) synGet(x,downloadLocation=paste(assayTarget,"/",tissue,'/',sep='')))
    print(paste("~/code/psychencode/bed_combine.sh ",assayTarget,"/",tissue,'/ ...',sep=''))
    system(command=paste("~/code/psychencode/bed_combine.sh ",assayTarget,"/",tissue,'/',sep=''),wait=T)
}
}

print ("all done！")

