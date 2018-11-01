library(GEOquery) #this code should be run on the midway2
args=commandArgs(TRUE) #first parameter is the file containing GEO accession IDs, second parameter is the folder to put downloaded data in

setwd('./')
#system(command=paste("wget",),wait=T)

#read in the GEO accession list
IDs=scan(file=args[1],what='character')
IDs=unique(IDs)

for (id in IDs)
{
dir.create(paste(args[2],"/",id,"/",sep=''))
gse <- getGEO(id, destdir=paste(args[2],"/",id,"/",sep=''),GSEMatrix=TRUE) #read in gse file
sample_info=pData(gse[[1]])
write.table(sample_info,file=paste(args[2],"/",id,"/sample_info",sep=''),quote=F,sep="\t")
#gsms<-GSMList(gse) #get all samples for the gse
gsms<-unique(as.character(rownames(sample_info)))
i=1;
for (gsmname in gsms)
{
print(paste("it is done with ",id,gsmname,"...\n"))
dir.create(paste(args[2],"/",id,"/",gsmname,"/",sep=''))
getGEOSuppFiles(gsmname, makeDirectory = TRUE, baseDir=paste(args[2],"/",id,"/",sep='')) # download supplementary files
i=i+1
}
}

print ("all done!")

