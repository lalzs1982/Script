files=commandArgs(T)
#files=c('/project2/xinhe/zhongshan/RNA/TC/output/final/allmut','/project2/xinhe/zhongshan/RNA/TC/output/final/adarexpr')
data=as.matrix(read.table(file=files[1],sep="\t")) #variants file

tumors=c('Sample_3017-JP-T_2.gz.vcf','Sample_3019-PFY-T_2.gz.vcf','Sample_3021-YXM-T_2.gz.vcf','Sample_A102_2.gz.vcf','Sample_A104_2.gz.vcf',
'Sample_A106_2.gz.vcf','Sample_A108_2.gz.vcf','Sample_A111_2.gz.vcf','Sample_A113_2.gz.vcf','Sample_A143_2.gz.vcf','Sample_A145_2.gz.vcf',
'Sample_A147_2.gz.vcf','Sample_A150_2.gz.vcf','Sample_A152_2.gz.vcf')

normals=c('Sample_3018-JP-N_2.gz.vcf','Sample_3020-PFY-N_2.gz.vcf','Sample_3022-YXM-N_2.gz.vcf','Sample_A103_2.gz.vcf','Sample_A105_2.gz.vcf',
'Sample_A107_2.gz.vcf','Sample_A110_2.gz.vcf','Sample_A112_2.gz.vcf','Sample_A142_2.gz.vcf','Sample_A144_2.gz.vcf','Sample_A146_2.gz.vcf',
'Sample_A148_2.gz.vcf','Sample_A151_2.gz.vcf','Sample_A153_2.gz.vcf')

data1=data[as.numeric(data[,6])>10,] #& as.numeric(data[,7])>3

data_mut=cbind(paste(data1[,4],data1[,5],sep='>'),data1[,8])
data_mutct=table(data_mut[,1],data_mut[,2])
data_mutct=data_mutct[order(data_mutct[,1],decreasing=T),]
data_mutct1=apply(X=data_mutct,MARGIN=2,FUN=function(x){x/sum(x)})

#make plot of mutation distribution
pdf(paste(files[3],'/allmutdistr.pdf',sep=''),height=7,width=8)
xpos=matrix(rep(1:nrow(data_mutct1),ncol(data_mutct1)),ncol=ncol(data_mutct1))
colnames(xpos)=colnames(data_mutct1)
plot(x=xpos[,tumors],y=data_mutct1[,tumors],col='red',xlab='Mutation types',ylab='Proportion',main='Mutation distributions',axes=F)
points(x=xpos[,normals]+0.2,y=data_mutct1[,normals],col='blue')
axis(side=1,at=xpos[,1],labels=rownames(data_mutct1),tick=F,cex=0.5)
axis(side=2,at=seq(0,1,0.05),labels=seq(0,1,0.05))
legend(x='topleft',legend=c('Tumor','Normal'),text.col=c('red','blue'))
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
legend(x='topright',legend=c('Tumor','Normal'),text.col=c('red','blue'),bty='n')
dev.off()

# mean editing level comparison between normal and tumor on DARNED sites
data2=data1[data1[,9]==1,]
data2_edlev=cbind(data2[,8],as.numeric(data2[,7])/(as.numeric(data2[,7])+as.numeric(data2[,6])))
data2_edlev1=matrix(ncol=2,nrow=0)
for(sample in c(tumors,normals))
{
    data2_edlev1=rbind(data2_edlev1,data2_edlev[data2_edlev[,1]==sample,])
}
colnames(data2_edlev1)=c('Sample','Editinglevel')
data2_edlev1=as.data.frame(data2_edlev1)
data2_edlev1[,2]=as.numeric(as.character(data2_edlev1[,2]))
pdf(paste(files[3],'/DARNED_editinglevel.pdf',sep=''),height=7,width=8)
boxplot(formula=Editinglevel~Sample,data=data2_edlev1[is.element(data2_edlev1[,1],tumors),],col='red',xlab='Samples',ylab='Editing level',main='RNA editing level on DARNED sites',axes=F) #,at=1:length(tumors)
boxplot(formula=Editinglevel~Sample,data=data2_edlev1[is.element(data2_edlev1[,1],normals),],col='blue',add=T) #at=(1:length(tumors))+0.5,
dev.off()

#clustering based on RNA editing level of DARNED sites
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
colnames(data2_edlev_matr)=c('T1','T2','T3','T4','T5','T6','T7','T8','T9','T10','T11','T12','T13','T14','N1','N2','N3','N4','N5','N6','N7','N8','N9','N10','N11','N12','N13','N14')
data2_edlev_matr=data2_edlev_matr[,-10]

pdf(paste(files[3],'/DARNED_editinglevel_clust.pdf',sep=''),height=7,width=8)
data2_edlev_matr1=na.exclude(data2_edlev_matr)
d <- dist(t(data2_edlev_matr1), method = "euclidean") # distance matrix
fit <- hclust(d, method="ward.D")
plot(fit) # display dendogram
dev.off()

#differential DARNED editing sites identifications
pvalues=apply(X=data2_edlev_matr,MARGIN=1,FUN=function(x){
a=as.numeric(x[1:14]);b=as.numeric(x[15:28]);a=a[!is.na(a)];b=b[!is.na(b)];
p=NA;
if(length(a)>=5 && length(b)>=5){p=wilcox.test(a,b)$p.value}
return(p)
})
data2_edlev_matr=cbind(data2_edlev_matr,pvalues)
data2_edlev_matr=data2_edlev_matr[order(pvalues),]

pdf(paste(files[3],'/DARNED_editinglevel_diff.pdf',sep=''),height=7,width=8)
par(mfrow=c(3,3))
for(i in 1:10)
{
    plot(x=rep(1:14,2),y=as.numeric(data2_edlev_matr[i,1:28]),col=rep(c('red','blue'),each=14),
    xlab='Samples',ylab='Editing level',main=rownames(data2_edlev_matr)[i],ylim=c(0,1),axes=F)
    axis(side=1)
    axis(side=2)
    legend(x='topright',legend=c('Tumor','Normal'),text.col=c('red','blue'),bty='n')
}
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
xposs=cbind(xposs[,1:14],xposs[,15:28]+0.2)
cols=matrix(rep(rep(c('red','blue'),each=ncol(adar_matr)/2),nrow(adar_matr)),ncol=ncol(adar_matr),byrow=T)
pdf(paste(files[3],'/ADARexpr.pdf',sep=''),height=7,width=8)
plot(x=xposs,y=adar_matr,xlab='',ylab='Transcript abundance (FPKM)',axes=F,col=cols)
axis(side=1,at=c(1.1,2.1,3.1),labels=c('ADAR1','ADAR2','ADAR3'))
axis(side=2)
legend(x='topright',legend=c('Tumor','Normal'),text.col=c('red','blue'),bty='n')
dev.off()
