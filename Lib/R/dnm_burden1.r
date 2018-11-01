files=commandArgs(T)
data=as.matrix(read.table(file=files[1],sep="\t"))
re=matrix(NA,ncol=(ncol(data)+3),nrow=0)

for (i in 1:nrow(data))
{
matr=matrix(nrow=4,ncol=2)
aa=strsplit(x=data[i,3],split=':')[[1]]
bb=strsplit(x=data[i,4],split=':')[[1]]
cc=strsplit(x=data[i,5],split=':')[[1]]
dd=strsplit(x=data[i,6],split=':')[[1]]
colnames(matr)=c(aa[1],bb[1]);
matr[1,aa[1]]=aa[2]
matr[1,bb[1]]=bb[2]
matr[2:4,cc[1]]=cc[2:4]
matr[2:4,dd[1]]=dd[2:4]

if(matr[1,"ASD"]>=2)
{
mutrate=as.numeric(data[i,2])
control=as.numeric(matr[,"Control"])
case=as.numeric(matr[,"ASD"])

expect_case=case[2]*2*mutrate
exp_obs_p=poisson.test(x=case[1],r=expect_case)$p.value
case_control_p=fisher.test(matrix(as.numeric(matr[c(1,4),]),ncol=2))$p.value
case_control_or=fisher.test(matrix(as.numeric(matr[c(1,4),]),ncol=2))$estimate
re=rbind(re,c(data[i,],exp_obs_p,case_control_p,case_control_or))
}
}

if(nrow(re)>1)
{
    write.table(re,sep="\t",quote=F,file=paste(files[1],".mb",sep=''))
}

