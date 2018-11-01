files=commandArgs(T)
data=read.table(files[1],sep="\t")
data=data[as.numeric(data[,4])>=2,]

res=matrix(nrow=0,ncol=7) 
colnames(res)=c("Study","Phenotype","Region","ObservedDNMs", "ExpectedDNMs","Enrichment(Obs/Exp)","p(binom.test)")

for (study in unique(data[,2]))
{
    for (ph in unique(data[data[,2]==study,3]))
    {
        data1=data[data[,2]==study & data[,3]==ph,]
        data1_total=data1[data1[,1]=="Total",,drop=F]
        data1_reg=data1[data1[,1]!="Total",,drop=F]
        
        if(nrow(data1_total)==1 && nrow(data1_reg)>0)
        {
            total_obs=as.numeric(data1_total[,4])
            total_mr=as.numeric(data1_total[,6])
            #neg_mr=as.numeric(data1_neg[,6])
            #neg_obs=as.numeric(data1_neg[,4])
            
            for(i in 1:nrow(data1_reg))
            {
                reg_mr=as.numeric(data1_reg[i,6])
                reg_obs=as.numeric(data1_reg[i,4])
                
                reg_exp=total_obs*(reg_mr/total_mr)
                #exp=(obs+neg_obs)*(mr/(neg_mr+mr))
                #neg_exp=(obs+neg_obs)*(neg_mr/(neg_mr+mr))
                #name=paste(study,ph,data1_reg[i,1],sep="_")
                test=binom.test(x=reg_obs,n=total_obs,p=reg_mr/total_mr,alternative='g')
                res=rbind(res,c(study,ph,as.character(data1_reg[i,1]),reg_obs, reg_exp,reg_obs/reg_exp,test$p.value))
            }
        }
    }
}

res=cbind(res,p.adjust(as.numeric(res[,7]),method='BH'))
colnames(res)[8]="FDR"
res=res[order(log10(as.numeric(res[,7]))),]
write.table(res,paste(files[1],".dnm.enrich",sep=''),sep="\t",row.names=F,quote=F)

#make plot
res1=res[order(as.numeric(res[,6]),decreasing=T),]
#res1=res[1:6,]
res1=res1[as.numeric(res1[,6])>=10,]

pdf(paste(files[1],".dnm.enrich.pdf",sep=''))
par(mfrow=c(2,2))
for(st in unique(res1[,1]))
{
    for(ph in unique(res1[,2]))
    {
        res2=res1[res1[,1]==st & res1[,2]==ph,,drop=F]
        if(nrow(res2)>1)
        {
        plot(x=1:nrow(res2),y=as.numeric(res2[,6]), col='red',main=paste(st, ph),ylab="Fold Change",xlab="Samples",ylim=c(0,max(10,as.numeric(res2[,8]))),xlim=c(-2,nrow(res2)+2))
        text(x=1:nrow(res2),y=as.numeric(res2[,6]),labels=paste(as.character(res2[,3]),round(as.numeric(res2[,7]),4),sep="\n"),cex=0.5,srt=30)
        abline(h=1,lty=2)
        }
    }
}

dev.off()
warnings()
