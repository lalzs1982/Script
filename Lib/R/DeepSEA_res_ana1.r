args=commandArgs(T)
data=as.matrix(read.table(file=args[1],sep=",",skip=1))
data1=data[,c(4,9)] #group and scores

groups=unique(data1[,1]) # groups
groups=c("Yuen2017JONSSON_ASD","Yuen2017JONSSON_Control","Simons_ASD","Simons_Control")
#t_testP=round(t.test(x=as.numeric(data[data[,1]==groups[1],2]),y=as.numeric(data[data[,1]==groups[2],2]))$p.value,3)
ecdf_g1 = ecdf(as.numeric(data1[data1[,1]==groups[1],2]))
ecdf_g2 = ecdf(as.numeric(data1[data1[,1]==groups[2],2]))
ecdf_g3 = ecdf(as.numeric(data1[data1[,1]==groups[3],2]))
ecdf_g4 = ecdf(as.numeric(data1[data1[,1]==groups[4],2]))


pdf(paste(args[1],".pdf",sep=''),height=9,width=4.5)
par(mfrow=c(2,1))
#boxplot(formula=y~grp,data=list(grp=data1[,1],y=as.numeric(data1[,2])),main=paste(args[2],"\n t-test p:",t_testP))
plot(ecdf_g1, xlim=c(0,1), xlab = 'Scores', ylab = 'Proportion', col='red',main = paste('eCDF\n', args[2]))
lines(ecdf_g2,col='blue')
legend(x='topleft',lty=1,col=c('red','blue'),legend=groups[c(1,2)])

plot(ecdf_g3, xlim=c(0,1), xlab = 'Scores', ylab = 'Proportion', col='red',main = paste('eCDF\n', args[2]))
lines(ecdf_g4,col='blue')
legend(x='topleft',lty=1,col=c('red','blue'),legend=groups[c(3,4)])

dev.off()


