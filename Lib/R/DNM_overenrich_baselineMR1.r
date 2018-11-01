files=commandArgs(T)
#file1: Reg     Mutationrate    Study   Phenotype       DNMs    Samplesizes     Scaling_factor
#test over-enrichment of DNMs within each regions using poisson test

data=as.matrix(read.table(files[1],sep="\t"))
data=data[as.numeric(data[,5])>2,]
exp=apply(X=data,MARGIN=1,FUN=function(x){exp=as.numeric(x[2])*as.numeric(x[6])*2*as.numeric(x[7])})
data=cbind(data,exp)

data1=as.matrix(data[,c(5,8)])
data2=matrix(as.numeric(data1),ncol=ncol(data1))
data1=data2
poissontest=t(apply(X=data1, MARGIN=1,FUN=function(x){test=poisson.test(x[1],x[2],alternative='g');return(c(test$estimate,test$p.value))}))
fdr=p.adjust(poissontest[,2],method ="BH")

data=cbind(data,poissontest,fdr)
colnames(data)=c("Reg","Mutationrate","Study","Phenotype","DNMs","Samplesizes","Scaling_factor","ExpectedDNMs","Burden","p(Poisson)","FDR(BH)")
data=data[order(log10(as.numeric(data[,10])),decreasing=F),]

write.table(data,file=paste(files[1],'.enrich',sep=''),col.names=T,row.names=F,sep="\t",quote=F)

pdf(file=paste(files[1],'.enrich.pdf',sep=''))
par(mfrow=c(2,1))
for (study in unique(data[,3]))
{
    for(phe in unique(data[,4]))
    {
    data1=data[data[,3]==study & data[,4]==phe,,drop=FALSE]
    if(nrow(data1)>0)
    {
    height=t(matrix(round(as.numeric(data1[,c(8,5)]),0),ncol=2))
    pos=barplot(height=height,beside=T,col=c('grey','black'),legend.text=c('Expected','Observed'),main=paste(study,phe,sep='_'),ylim=c(0,max(height)*1.2))
    mtext(side=1,at=apply(pos,2,mean),text=data1[,1],cex=0.5,padj=rep(c(0,1),10)[1:nrow(data1)])
    text(x=pos,y=height,labels=height,cex=0.5,pos=3)
    text(x=apply(pos,2,mean),y=as.numeric(data1[,5]),labels=paste("p:",round(as.numeric(data1[,10]),3)),col='red',pos=3,cex=0.7,offset=1)
    }
    }
}
dev.off()
