library("caret")
#library('RANN')
#library(AppliedPredictiveModeling)
#transparentTheme(trans = .4)
library(pROC)
library(doMC)
registerDoMC(cores = 10)
files=commandArgs(T) #should be one tab-delimited file, first cols and rows be col/row names, and outcome variable
files=c('/project2/xinhe/zhongshan/eQTL/allsnps.anno.forcaret','cate')

#data<-as.matrix(read.table("/project2/xinhe/zhongshan/eQTL/allsnps.anno.caret2",stringsAsFactors = F,sep="\t")) #
#data<-as.matrix(read.table("/project2/xinhe/zhongshan/eQTL/allsnps.anno.caret1.1",stringsAsFactors = F,sep="\t")) #
data<-as.matrix(read.table(files[1],stringsAsFactors = F,sep="\t")) #
colnames(data)=data[1,]
rownames(data)=data[,1]
data=data[-1,-1]
data=as.data.frame(data)

index=sapply(X=1:ncol(data),FUN=function(x){length(levels(data[,x]))}) #obtain numeric columns based on large factor level counts 
index=index>10
data[,index] <- lapply(data[,index], function(x) as.numeric(as.character(x)))
#data=data[sample(x=1:nrow(data),size=10000),] #subsample for testing

#random subsample of common to improve computational efficiency
data0=data
data_com=data[data$cate =='Common',]
data_com=data_com[sample(1:nrow(data_com),size=40000),]
data=rbind(data[data$cate !='Common',],data_com)

#data=cbind(data,rnorm(nrow(data),1,1)) # a small test by simulation
#colnames(data)[ncol(data)]='Pred1'
#data[data$Cate=='eQTL',ncol(data)]=rnorm(nrow(data[data$Cate=='eQTL',]),10,1)

#impute value for NA and normalizations
nas=apply(X=data[,index],MARGIN=1,FUN=function(x){length(x[is.na(x)])})
data=data[nas<11,] #remove all NAs in 11 nuneric variables
preProcValues <- preProcess(data, method = c("knnImpute","center","scale"))
data_processed <- predict(preProcValues, data)

#hot encoding
#data_processed$Cate<-ifelse(data_processed$Cate=='eQTL',1,0)
rec=data_processed[,files[2]];data_processed[,files[2]]=0
dmy <- dummyVars(" ~ .", data = data_processed,fullRank = T)
data_transformed <- data.frame(predict(dmy, newdata = data_processed))
data_transformed[,files[2]]=rec
#data_transformed$Cate<-as.factor(data_transformed$Cate)
#data_transformed=data_transformed[,setdiff(colnames(data_transformed),c('eQTL'))]

#split
#index <- createDataPartition(data_transformed$Cate, p=0.75, list=FALSE)
index <- createDataPartition(data_transformed[,files[2]], p=0.75, list=FALSE) #Note: first column should be outcome
trainSet0 <- data_transformed[index,]
testSet0 <- data_transformed[-index,]
#trainSet$Cate=as.numeric(as.character(trainSet$Cate))
#testSet$Cate=as.numeric(as.character(testSet$Cate))

#feature selection
control <- rfeControl(functions = rfFuncs,
                   method = "repeatedcv",
                   repeats = 5,
                   verbose = FALSE)
#outcomeName<-'Cate'
outcomeName<-colnames(data_transformed)[1]
predictors<-names(trainSet0)[!names(trainSet0) %in% outcomeName]

rematr=matrix(ncol=3,nrow=0)
colnames(rematr)=c('CateVScommon','AUC','Predictors')
categories=setdiff(as.character(unique(data_transformed$cate)),'Common')
for(cate in categories)
{
print(paste("it is",cate," now: \n"))
predictors<-names(trainSet0)[!names(trainSet0) %in% outcomeName]
#cate=categories[2]
trainSet=trainSet0[trainSet0$cate=='Common' |trainSet0$cate==cate,]
testSet=testSet0[testSet0$cate=='Common' |testSet0$cate==cate,]
trainSet=cbind(as.character(trainSet[,1]),trainSet[,-1])
testSet=cbind(as.character(testSet[,1]),testSet[,-1])
colnames(trainSet)[1]='cate'
colnames(testSet)[1]='cate'

Pred_Profile <- rfe(trainSet[,predictors], trainSet[,outcomeName],rfeControl = control)
if(length(predictors(Pred_Profile))>5){predictors= predictors(Pred_Profile)[1:5]}else{predictors= predictors(Pred_Profile)} #c('Eigen', 'dann', 'gerp', 'FATHMM_noncoding', 'Phastcons') #use top predictors 
predictorss=paste(predictors,collapse=',')

fitControl <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 3)
#model training and parameter tunning: rf
model_rf<-train(trainSet[,predictors],trainSet[,outcomeName],method='rf',trControl=fitControl,tuneLength=10)                      
#model_rf<-train(trainSet[,predictors],trainSet[,outcomeName],method='nb',trControl=fitControl,tuneLength=10)                      
predictions_rf<-predict.train(object=model_rf,testSet[,predictors],type="prob") #type="raw"
result.roc <- roc(testSet$cate, predictions_rf$Common)
rematr=rbind(rematr,c(cate,result.roc$auc[[1]],predictorss))
#confusionMatrix(predictions_rf,testSet[,outcomeName])
}

save.image(paste(files[1],".RData",sep=''))


#print(model_rf)


#model training and parameter tunning: SVM
#model_svm<-train(trainSet[,predictors],trainSet[,outcomeName],method='svmLinear',trControl=fitControl,tuneLength=10)                      

#model training and parameter tunning: logistic regression
#model_lr <- train(Cate ~ RBP.Yes+Ribosnitch.Yes+UTRcis.Yes+Phastcons+Phylop+GC+CisBP+RBPDB+RNAsnp+targetScanS.Yes+GWAVA_region_score+
#CADD_Phred+X.gerp...+FATHMM_noncoding+dann+Eigen,  data=trainSet, method="glm", family="binomial",trControl=fitControl,tuneLength=10)
#model_lr <- train(Cate ~ Eigen+dann+gerp+FATHMM_noncoding+Phastcons, data=trainSet, method="glm", family="binomial",trControl=fitControl,tuneLength=10)

##Variable Importance
#varImp(object=model_rf)

##Predictions
#predictions_rf<-predict.train(object=model_rf,testSet[,predictors],type="raw")
#confusionMatrix(predictions_rf,testSet[,outcomeName])

#predictions_lr<-predict.train(object=model_lr,testSet[,predictors],type="raw")
#confusionMatrix(predictions_lr,testSet[,outcomeName])

#predictions_svm<-predict.train(object=model_svm,testSet[,predictors],type="raw")
#confusionMatrix(predictions_svm,testSet[,outcomeName])

#save.image(paste(files[1],".RData",sep=''))
#load("/scratch/midway2/zhongshan/CARET/3UTR/eqtlvscommonsnp.RData")
