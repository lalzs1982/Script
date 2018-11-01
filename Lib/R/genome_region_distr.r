files=commandArgs(T)
data=as.matrix(read.table(files[1]))
data_p=apply(X=data,MARGIN=2,FUN=function(x){x/sum(x)})
#data_p=data_p[order(data_p[,1],decreasing=T),]
data_p=data_p[order(apply(X=data_p,MARGIN=1,FUN=sum),decreasing=T),]
asd= grep("ASD",colnames(data))
control=grep("Control",colnames(data))
data_p_asd=data_p[,asd]
data_p_ctr=data_p[,control]

pdf("./genome_distr.pdf",height=14,width=20)
par(mfrow=c(2,1))
barplot(height=data_p_asd,beside=T,ylab='Proportions',main="ASD",names.arg=colnames(data_p_asd),legend.text=rownames(data_p_asd),col=rainbow(n=nrow(data_p_asd)))
barplot(height=data_p_ctr,beside=T,ylab='Proportions',main="Control",names.arg=colnames(data_p_ctr),legend.text=rownames(data_p_ctr),col=rainbow(n=nrow(data_p_ctr)))
dev.off()
