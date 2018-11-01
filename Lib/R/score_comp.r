args=commandArgs(T)
data=as.matrix(read.table(file=args[1],sep="\t"))
data1=cbind(data[,6],as.numeric(data[,8])-as.numeric(data[,7]),data[,9])

pdf(paste(args[1],"score_comp.pdf",sep=''))
par(mfrow=c(2,2))

for(cat in unique(data1[,3]))
{
data2=data1[data1[,3]==cat,]
wilc=wilcox.test(x=as.numeric(data2[data2[,1]=="ASD",2]),y=as.numeric(data2[data2[,1]=="Control",2]))$p.value
boxplot(formula=y~grp,data=list(grp=data2[,1],y=as.numeric(data2[,2])),main=paste(cat,"\n Wilcoxn test p: ",round(wilc,3)),outline=FALSE)
}
dev.off()

