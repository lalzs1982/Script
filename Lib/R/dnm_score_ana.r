files=commandArgs(T)
data=as.matrix(read.table(files[1],sep="\t"))
colnames(data)=data[1,]
data=data[-1,]
regs=unique(as.character(data[,1]))

pdf(file=paste(files[1],".pdf",sep=""))
par(mfrow=c(2,2),cex.main=0.5)
for (reg in regs)
{
 for (anno_i in 4:ncol(data)){
    data1=data[data[,1]==reg,c(2,anno_i)]
    if(!is.null(nrow(data1)))
    {
    asd=as.character(data1[data1[,1]=="ASD",2])
    control=as.character(data1[data1[,1]=="Control",2])
    #asd=as.numeric(asd[asd!="NA"])
    asd=as.numeric(asd[!is.na(asd)])
    control=as.numeric(control[!is.na(control)])
    #control=as.numeric(control[control!="NA"])
    if(length(asd)>5 && length(control)>5)
    {
    wil_p=wilcox.test(x=asd,y=control)$p.value
    if(!is.nan(wil_p) && wil_p<0.1)
    {
    data2=list(y=c(asd,control),grp=c(rep("asd",length(asd)),rep("control",length(control))))
    boxplot(y~grp,data=data2,main=paste(reg,colnames(data)[anno_i],"\n Wilconxon test p:",wil_p))
    }
    }
    }
 }
}
dev.off()
warnings()