files=commandArgs(T)
data=read.table(files[1],sep="\t") #"Region","Study","Phenotype","RegDNMs","RegDNMrate","controlDNMs","controlDNMrate",
data=data[as.numeric(data[,4])>=2,]

testre=matrix(nrow=0,ncol=5) #for Expected_RegDNMs, Enrichment, p, confidence_interval_L, confidence_interval_H 
for(i in 1:nrow(data))
{
    dnm=as.numeric(data[i,4])
    rate=as.numeric(data[i,5])
    controldnm=as.numeric(data[i,6])
    controlrate=as.numeric(data[i,7])
    #expdnm=controldnm*(rate/controlrate)
    #foldchange=dnm/(expdnm)
    test=binom.test(x=c(dnm,controldnm),p=rate/(controlrate+rate),alternative='t')
    expdnm=(dnm+controldnm)*test$estimate
    foldchange=(test$estimate)/(rate/(controlrate+rate))
foldchange_l=(test$conf.int[1])/(rate/(controlrate+rate))
foldchange_u=(test$conf.int[2])/(rate/(controlrate+rate))

testre=rbind(testre,c(expdnm,foldchange,test$p.value,foldchange_l,foldchange_u))
}
data=cbind(data,testre)
colnames(data)=c("Region","Study","Phenotype","RegDNMs","RegDNMrate","ControlDNMs","ControlDNMrate", "Expected_RegDNMs","Enrichment(Obs/Exp)","p(binom.test)","Enrichment_conf_L","Enrichment_conf_U")
data=data[order(log10(as.numeric(data[,10]))),]
write.table(data,paste(files[1],".dnm.enrich",sep=''),sep="\t",row.names=F,quote=F)

#make plot
clip=grep(pattern='CLIP',x=unique(as.character(data[,1])),value=T)
rbpvar=grep(pattern='RBPvar_cate12',x=unique(as.character(data[,1])),value=T)
rnasnp=grep(pattern='RNAsnp',x=unique(as.character(data[,1])),value=T)
studies_sel=as.character(data[,2])
#studies_sel=c('DDD_2017','DeRubeis2014','Fromer2014','Helbig2016','Homsy2015','Iossifov_Nature2014','Krumm','Lelieveld2016','Lifton','Sifrim2016','Willsey2017','epi4k2013','EuroEPINOMICS-RES_AJHG2014','FitzgeraldTW_Nature2015')
regions_sel=as.character(data[,1]) #rnasnp #rbpvar #clip #c('CLIPdb','RBPvar_cate12','RNAsnp','Splicing','Stopgain/loss','Syn_SNV','Sim1','Sim2','Sim3')

res1=data[is.element(as.character(data[,2]),studies_sel) & is.element(as.character(data[,1]),regions_sel),]
res1=res1[order(as.numeric(res1[,9]),decreasing=T),]
res1=res1[as.numeric(res1[,4])>=5,]

pdf(paste(files[1],".dnm.enrich.pdf",sep=''),width=10,height=7)
par(mfrow=c(2,2))
for(st in unique(res1[,2]))
{
    for(ph in unique(res1[,3]))
    {
        res2=res1[res1[,2]==st & res1[,3]==ph,,drop=F]
        if(nrow(res2)>1)
        {
        plot(x=1:nrow(res2),y=as.numeric(res2[,9]),pch=20,main=paste(st, ph),ylab="Fold Change",xlab="Samples",xlim=c(-2,nrow(res2)+2),ylim=c(0,max(2,as.numeric(res2[,9])))*1.2) #,,ylim=c(0,3)ylim=c(0,max(10,as.numeric(res2[,9])))
        
	stars=unlist(lapply(as.numeric(res2[,10]),FUN=function(x){if(x<0.0001){return("***")}else if(x<0.001){return("**")}else if(x<0.05){return("*")}else{return(" ")}}))
	#text(x=1:nrow(res2),y=as.numeric(res2[,9]),labels=paste(as.character(res2[,1]),"p:",round(as.numeric(res2[,10]),4),sep=" "),cex=0.5,srt=30)
	text(x=1:nrow(res2),y=as.numeric(res2[,9]),labels=paste(as.character(res2[,1]),"\n",as.numeric(res2[,4]),stars,sep=""),cex=0.7,srt=20,col="red")
	rect(xleft=1:nrow(res2), ybottom=as.numeric(res2[,11]), xright=1:nrow(res2), ytop=as.numeric(res2[,12]),col="grey")
        abline(h=1,lty=2)
        }
    }
}

#next block to plot mutation burden for specific region of multiple studies  
res1=res1[as.numeric(res1[,4])>=5,]
region_mean=aggregate(as.numeric(res1[,9]),list(res1[,1]),median)
region_mean=region_mean[order(as.numeric(region_mean[,2]),decreasing=T),]
res2=matrix(nrow=0,ncol=ncol(res1)+1)
i=1
for(reg in region_mean[,1])
{
    res2=rbind(res2,cbind(res1[res1[,1]==reg,],i))
    i=i+1
}

plot(x=as.numeric(res2[,ncol(res2)]),y=as.numeric(res2[,9]),type='n',axes=F,main="Mutation burden for RBP binding sites",xlab="RBP",ylab="Mutation burden")
text(x=as.numeric(res2[,ncol(res2)]),y=as.numeric(res2[,9]),labels=as.character(res2[,3]),cex=0.2,srt=30,col='grey')
text(x=1:nrow(region_mean),y=as.numeric(region_mean[,2]),labels=gsub("CLIPdb:","",as.character(region_mean[,1])),cex=0.3,srt=-30,pos=3)
axis(side=2)
#axis(side=1,at=1:length(as.character(unique(res2[,1]))),labels=as.character(unique(res2[,1])))
abline(h=1,lty=2,col='red')
abline(v=1:nrow(region_mean),lty=3,col='grey')

dev.off()
warnings()
