args=commandArgs(T)
data=as.matrix(read.table(file=args[1],sep=","))
data1=data[-1,]
groups=c("Yuen2017JONSSON_ASD","Yuen2017JONSSON_Control","Simons_ASD","Simons_Control")

comp_p=matrix(ncol=3,nrow=0)

for(col in 7:ncol(data1))
{
g1=as.numeric(data1[data1[,4]==groups[1],col])
g2=as.numeric(data1[data1[,4]==groups[2],col])
g3=as.numeric(data1[data1[,4]==groups[3],col])
g4=as.numeric(data1[data1[,4]==groups[4],col])
wilc_p12=wilcox.test(x=g1,y=g2)$p.value
wilc_p34=wilcox.test(x=g3,y=g4)$p.value
comp_p=rbind(comp_p,c(col,wilc_p12,wilc_p34))
}

comp_p=comp_p[order(as.numeric(comp_p[,2])),]
pdf(paste(args[1],".feature_comp_Yuen_JONSSON.pdf",sep=''))
par(mfrow=c(3,3))
for(col in comp_p[,1])
{
g1=as.numeric(data1[data1[,4]==groups[1],col])
g2=as.numeric(data1[data1[,4]==groups[2],col])
wilc=wilcox.test(x=g1,y=g2)$p.value
boxplot(formula=y~grp,names=c("ASD","Normal"),data=list(grp=rep(c(groups[1],groups[2]),times=c(length(g1),length(g2))),y=c(g1,g2)),main=paste(data[1,col],"\n Wilcoxn test p: ",round(wilc,3)),outline=TRUE)
#plot(ecdf(g1),xlab = 'Scores', ylab = 'Proportion', col='red',main=paste(data[1,col],"\n Wilcoxn test p: ",round(wilc,3)))
#lines(ecdf(g2),col='blue')
#legend(x='topleft',lty=1,col=c('red','blue'),legend=groups[c(1,2)])
}
dev.off()

comp_p=comp_p[order(as.numeric(comp_p[,3])),]
pdf(paste(args[1],".feature_comp_Simons.pdf",sep=''))
par(mfrow=c(3,3))
for(col in comp_p[,1])
{
g1=as.numeric(data1[data1[,4]==groups[3],col])
g2=as.numeric(data1[data1[,4]==groups[4],col])
wilc=wilcox.test(x=g1,y=g2)$p.value
boxplot(formula=y~grp,names=c("ASD","Normal"),data=list(grp=rep(c(groups[1],groups[2]),times=c(length(g1),length(g2))),y=c(g1,g2)),main=paste(data[1,col],"\n Wilcoxn test p: ",round(wilc,3)),outline=TRUE)
#plot(ecdf(g1),xlab = 'Scores', ylab = 'Proportion', col='red',main=paste(data[1,col],"\n Wilcoxn test p: ",round(wilc,3)))
#lines(ecdf(g2),col='blue')
#legend(x='topleft',lty=1,col=c('red','blue'),legend=groups[c(3,4)])
}
dev.off()

