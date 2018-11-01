library(synapseClient)
synapseLogin(username='yuwenliu', password='helab2017', rememberMe=TRUE)

#setwd('/scratch/midway/zhongshan/psychEncode/datadownload')
organism='Homo sapiens'
organ='brain'
assayTarget='H3K27ac'
study='UCLA-ASD'
#outputdir=paste('/project2/xinhe/zhongshan/',assayTarget,'/',study,"/",sep='') #set up where to deposit the data
outputdir='/project/xinhe/zhongshan/' 
dir.create(outputdir,recursive=T) 

#outputdir_t=paste('~/scratch-midway/psychEncode/datadownload/',assayTarget,'/',study,"/",sep='')
#dir.create(outputdir_t,recursive=T)


queryString <- sprintf("select id,study,disease, tissueType, tissueTypeAbrv,assayTarget, dataType,fileType,name
from file where organism=='%s' AND organ=='%s' AND assayTarget=='%s' AND study =='%s' ", organism, organ,assayTarget,study)
queryResults <- synQuery(queryString)
#write.table(queryResults,sep="\t",quote=F,file=paste(outputdir,'/queryResults',sep=''))

###first extract the input data #in this part I don't know how to download input by code
#inputids=c('syn6782222','syn6784817','syn5786372')
#entity <- lapply(inputids, function(x) synGet(x,downloadLocation=outputdir)) # one input for each tisssue and moved to specific tissue fold with name input.bam
######

queryResults1 <- subset(queryResults, file.fileType == "bam")

#for(tissue in unique(queryResults1$file.tissueTypeAbrv)){
for(tissue in c('C')){
#dir.create(paste(outputdir_t,'/',tissue,'/',sep=''),recursive=T)
#dir.create(paste(outputdir,'/',tissue,'/',sep=''),recursive=T)
queryResults1 <- subset(queryResults, file.fileType == "bam" & file.tissueTypeAbrv==tissue)

#check to remove data already processed：
queryResults2=queryResults1[!(unlist(lapply(queryResults1$file.name,function(x){file.exists(paste(outputdir,'/',tissue,'/',x,'.narrowPeak',sep=''))}))),] 
if(nrow(queryResults2)==0){next}
queryResults1=queryResults2

chunk <- function(x,n) split(x, factor(sort(rank(x)%%n)))
chunks=chunk(1:nrow(queryResults1),1)
for(i in 1:length(chunks))
{
print (paste("it is downloading ", tissue, chunks[[i]], "rows files now ...\n",sep=''))

    queryResults2=queryResults1[chunks[[i]],]
    entity <- lapply(queryResults2$file.id, function(x){synGet(x,downloadLocation=paste(outputdir,'/',tissue,'/',sep=''))})
    print(paste("it is downloading to ",outputdir,'/',tissue,'/',sep=''))
    #system(command=paste("mv ",outputdir,tissue,"/*.bam ",outputdir,tissue,'/', sep=''))
	#system(command=paste("~/code/psychencode/macs.sh ",outputdir,'/',tissue,'/',sep=''),wait=T)
}
}
print ("all done!\n")
