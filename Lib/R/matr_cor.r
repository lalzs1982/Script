files=commandArgs(T) #file with colnames, and the first columns represent names, and all numeric except first column/row
data=as.matrix(read.table(files[1],sep="\t"))
data1=matrix(as.numeric(data[-1,-1]),ncol=(ncol(data)-1))
colnames(data1)=data[1,2:ncol(data)]
rownames(data1)=data[2:nrow(data),1]
data=data1

pdf(paste(files[1],'.pdf',sep=''))
par(mfrow=c(2,2))
for(i in 1:(ncol(data)-1))
{
for(j in (i+1):ncol(data))
{
cor=cor.test(x=data[,i],y=data[,j],method="pearson")
plot(x=data[,i],y=data[,j],xlab=paste(colnames(data)[i]),ylab=paste(colnames(data)[j]),main=paste("Corr:",round(cor$estimate,3),"\n","p(log10):",log10(cor$p.value)))
}
}
dev.off()

