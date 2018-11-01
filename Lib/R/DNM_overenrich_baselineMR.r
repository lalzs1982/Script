files=commandArgs(T)
#file1: Group Reg Study length Baseline_MR Sample_sizes DNMs
#test over-enrichment of DNMs within each regions using poisson test

data_dnm=as.matrix(read.table(files[1],sep="\t"))
data_dnm=rbind(data_dnm,rep(1,ncol(data_dnm)))
#data_dnm=data_dnm[as.numeric(data_dnm[,7])>=2,]
data_dnm=data_dnm[data_dnm[,7]>1,]

colnames(data_dnm)=data_dnm[1,]
data_dnm=data_dnm[-1,]
data_dnm=cbind(data_dnm,c(as.numeric(data_dnm[,5])*as.numeric(data_dnm[,6])*2))
colnames(data_dnm)[8]="Expected_DNM"
data_dnm=data_dnm[,c(1,2,3,4,5,6,8,7)]

test_matr=matrix(nrow=0,ncol=2)

for (i in 1:nrow(data_dnm))
{
    dnm_sum=as.numeric(data_dnm[i,8])
    mr_sum=as.numeric(data_dnm[i,5])
    ss=as.numeric(data_dnm[i,6])
    test=poisson.test(dnm_sum,mr_sum*ss*2,alternative='g')
    test_matr=rbind(test_matr,c(test$estimate,test$p.value))
}
fdr=p.adjust(test_matr[,2],method ="BH")
test_matr=cbind(test_matr,fdr)
colnames(test_matr)=c("foldchange","pvalue(poisson)","FDR(BH)")

data_dnm=cbind(data_dnm,test_matr)
data_dnm=data_dnm[1:(nrow(data_dnm)-1),]
data_dnm=data_dnm[order(as.numeric(data_dnm[,10]),decreasing=F),]
write.table(data_dnm,file=paste(files[1],'.enrich',sep=''),col.names=T,row.names=F,sep="\t",quote=F)