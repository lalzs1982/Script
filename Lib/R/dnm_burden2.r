files=commandArgs(T)
data=as.matrix(read.table(files[1],sep="\t"))
test_p=apply(X=data,MARGIN=1,FUN=function(x){
nums=as.numeric(x[2:5])
p=poisson.test(c(nums[1:2]),c(nums[3:4]))$p.value
return(p)
})
data=cbind(data,test_p,p.adjust(test_p))
colnames(data)=c("Regions","DNMinASD","DNMinControl","AllDNM_inASD","AllDNM_incontrol","OR","p","FDR")
write.table(data,file=paste(files[1],".test_p",sep=''),row.names=F,sep="\t",quote=F)

