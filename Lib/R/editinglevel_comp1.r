files=commandArgs(T)

files=c('/project2/xinhe/zhongshan/RNA/RNASeq1/output/allmut','/project2/xinhe/zhongshan/RNA/RNASeq1/output/adarexpr','/project2/xinhe/zhongshan/RNA/RNASeq1/output/summplots')
data=as.matrix(read.table(file=files[1],sep="\t")) #variants file
data1=data[as.numeric(data[,6])>5,] #& as.numeric(data[,7])>3

tumors=c('KD_ATAGCG_S127_L006_2.gz.vcf')
normals=c('NC_AGGCTA_S126_L006_2.gz.vcf')

data_mut=cbind(paste(data1[,4],data1[,5],sep='>'),data1[,8])
data_mutct=table(data_mut[,1],data_mut[,2])
data_mutct=data_mutct[order(data_mutct[,1],decreasing=T),]
data_mutct1=apply(X=data_mutct,MARGIN=2,FUN=function(x){x/sum(x)})

#make plot of mutation distribution
pdf(paste(files[3],'/allmutdistr.pdf',sep=''),height=7,width=8)
xpos=matrix(rep(1:nrow(data_mutct1),ncol(data_mutct1)),ncol=ncol(data_mutct1))
colnames(xpos)=colnames(data_mutct1)
plot(x=xpos[,tumors],y=data_mutct1[,tumors],col='red',xlab='Mutation types',ylab='Proportion',main='Mutation distributions',ylim=c(0,max(data_mutct1)),type='h',axes=F)
points(x=xpos[,normals]+0.1,y=data_mutct1[,normals],col='blue',type='h')
axis(side=1,at=xpos[,1],labels=rownames(data_mutct1),tick=F,cex=0.5)
axis(side=2,at=seq(0,1,0.05),labels=seq(0,1,0.05))
legend(x='topright',legend=c('KD','NC'),text.col=c('red','blue'),bty='n')
dev.off()

#DARNED vs non-DARNED
data_mut=cbind(paste(data1[,4],data1[,5],sep='>'),data1[,c(8,9)])

data_mut1=data_mut[data_mut[,3]==1,]
data_mutct=table(data_mut1[,1],data_mut1[,2])
data_mutct=data_mutct[order(data_mutct[,1],decreasing=T),]
data_mutct_darned=apply(X=data_mutct,MARGIN=2,FUN=function(x){x/sum(x)})

data_mut1=data_mut[data_mut[,3]==0,]
data_mutct=table(data_mut1[,1],data_mut1[,2])
data_mutct=data_mutct[order(data_mutct[,1],decreasing=T),]
data_mutct_nondarned=apply(X=data_mutct,MARGIN=2,FUN=function(x){x/sum(x)})


data_mutct1=rbind(data_mutct_darned['A>G',tumors]/data_mutct_nondarned['A>G',tumors],data_mutct_darned['A>G',normals]/data_mutct_nondarned['A>G',normals])
pdf(paste(files[3],'/A2GmutProp.pdf',sep=''),height=7,width=8)
barplot(height=data_mutct1,beside=T,col=c('red','blue'),axes=F,names.arg=NULL,xlab='Samples',ylab='Ratio of A>G mutation proportion in DARNED vs other sites ')
#axis(side=1,tick=F)
axis(side=2)
legend(x='topright',legend=c('KD','NC'),text.col=c('red','blue'),bty='n')
dev.off()

#differential editing level sites
data2=data1[data1[,9]==1,]
data2_edlev=cbind(paste(data2[,1],data2[,3],sep=':'),data2[,8],as.numeric(data2[,7])/(as.numeric(data2[,7])+as.numeric(data2[,6])))
data2_edlev_matr=matrix(NA,nrow=length(unique(data2_edlev[,1])),ncol=length(unique(data2_edlev[,2])))
colnames(data2_edlev_matr)=unique(data2_edlev[,2])
rownames(data2_edlev_matr)=unique(data2_edlev[,1])
for(i in 1:nrow(data2_edlev))
{
    data2_edlev_matr[data2_edlev[i,1],data2_edlev[i,2]]=data2_edlev[i,3]
}
data2_edlev_matr=data2_edlev_matr[,c(tumors,normals)]
data2_edlev_matr1=matrix(as.numeric(data2_edlev_matr),ncol=ncol(data2_edlev_matr),dimnames=dimnames(data2_edlev_matr))
data2_edlev_matr2=data2_edlev_matr1
data2_edlev_matr2[is.na(data2_edlev_matr2)]=0.01
data2_edlev_matr2=data2_edlev_matr2[order((data2_edlev_matr2[,2]+0.05)/(data2_edlev_matr2[,1]+0.05),decreasing=T),]
data2_edlev_matr3=t(apply(X=data2_edlev_matr2,MARGIN=1,FUN=function(x){return(x-mean(x))}))



pdf(paste(files[3],'/DARNED_editinglevelDiff.pdf',sep=''),height=7,width=8)
plot(x=c(nrow(data2_edlev_matr1[!is.na(data2_edlev_matr1[,1]),]),nrow(data2_edlev_matr1[!is.na(data2_edlev_matr1[,2]),])),type='h',col=c('red','blue'),xlab='Samples',ylab='Number of Edited DARNED sites',axes=F,xlim=c(0,4),lwd=4)
axis(side=2)
legend(x='topleft',legend=c('KD','NC'),text.col=c('red','blue'),bty='n')

plot(x=data2_edlev_matr3[,1],col='red',xlab='DARNED sites',ylab='Editing level differences',axes=F,ylim=c(min(data2_edlev_matr3),max(data2_edlev_matr3)))
points(x=data2_edlev_matr3[,2],col='blue')
axis(side=2)
legend(x='topleft',legend=c('KD','NC'),text.col=c('red','blue'),bty='n')
dev.off()

#ADAR expression levels plot
adar=as.matrix(read.table(file=files[2],sep="\t")) #ADAR expression
adar_matr=matrix(NA,nrow=length(unique(adar[,1])),ncol=length(unique(adar[,3])))
colnames(adar_matr)=unique(adar[,3])
rownames(adar_matr)=unique(adar[,1])
for(i in 1:nrow(adar))
{
    adar_matr[adar[i,1],adar[i,3]]=adar[i,2]
}

adar_matr=adar_matr[c('ADAR','ADARB1','ADARB2'),]
xposs=matrix(rep(1:nrow(adar_matr),each=ncol(adar_matr)),ncol=ncol(adar_matr),byrow=T)
xposs=cbind(xposs[,1],xposs[,2]+0.2)
cols=matrix(rep(rep(c('red','blue'),each=ncol(adar_matr)/2),nrow(adar_matr)),ncol=ncol(adar_matr),byrow=T)
pdf(paste(files[3],'/ADARexpr.pdf',sep=''),height=7,width=8)
plot(x=xposs,y=adar_matr,xlab='',ylab='Transcript abundance (FPKM)',axes=F,col=cols,type='h')
axis(side=1,at=c(1.1,2.1,3.1),labels=c('ADAR1','ADAR2','ADAR3'))
axis(side=2)
legend(x='topright',legend=c('KD','NC'),text.col=c('red','blue'),bty='n')
dev.off()
