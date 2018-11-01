files=commandArgs(T)
data=as.matrix(read.table(files[1],sep="\t"))
colnames(data)=data[1,]
data=data[-1,]

#genome region distributions
distr=table(data[,1])

distr1=c(1:7)
names(distr1)=c('exon','intron','5UTR','3UTR','splicing','ncRNA','intergenic')
distr1['exon']=distr['exonic']
distr1['intron']=distr['intronic']
distr1['5UTR']=distr['UTR5']
distr1['3UTR']=distr['UTR3']
distr1['splicing']=distr['exonic;splicing']+distr['splicing']
distr1['ncRNA']=distr['ncRNA_exonic']+distr['ncRNA_intronic']+distr['ncRNA_splicing']
distr1['intergenic']=distr['intergenic']+distr['upstream']+distr['downstream']+distr['upstream;downstream']
distr1=distr1[order(distr1)]
pdf("./DNM_genomewide_distr.pdf")
pie(distr1, labels=names(distr1), main="DNM distributions")
dev.off()

data_asd=data[data[,12]=="ASD",]
data_ct=data[data[,12]=="Control",]
pdf("./DNM_score_distr.pdf")
par(mfrow=c(2,2))
for(i in 2:(ncol(data)-1))
{
    case=data_asd[,i]
    case=as.numeric(case[!is.na(case)])
    control=data_ct[,i]
    control=as.numeric(control[!is.na(control)])
    nm=colnames(data)[i]
    
    if(length(case)>10 && length(control)>10)
    {
        plot(density(case),col='red',xlim=c(min(c(case,control)),max(c(case,control))),main=nm,xlab='Score',ylab='Freq')
        points(density(control),col='blue',type='l')
    }
}
dev.off()
