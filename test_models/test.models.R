library('readxl')
library("e1071")
library("caret")
library("pROC")
library("glmnet")
library("effects")
library("relaimpo")
library("ROCR")

path <- getwd()
full.path = paste(path, 'periodic_dataset_AvWtDev.xlsx', sep="/")

dataset <- read_excel(full.path, sheet = 1 ,col_names = TRUE, na='na')
nr <- nrow(dataset)
nc <- ncol(dataset)

var.names <- names(dataset)
class.name <- var.names[nc]
inpt.names <- var.names[-nc]

num.categ.vars <- 9
num.numeric.vars <- length(inpt.names) - num.categ.vars 

dataset[, 1:num.categ.vars] <- sapply( dataset[, 1:num.categ.vars], as.factor )

dset.train <- dataset[, names(dataset) %in% unlist(inpt.names)]
fmla <- as.formula( paste(class.name, paste(inpt.names, collapse="+"), sep=" ~ ") )

dummy.ds <- dummyVars(fmla, data=dataset[, 1:length(var.names)], fullRank=F)

dummy.dset.train <- data.frame(predict(dummy.ds, newdata = dataset),"Class"= dataset[class.name])

fitControl <- trainControl(## 10-fold CV
  method = "cv",
  number = 10,
  ## repeated ten times
  repeats = 10)

var.names <- names(dummy.dset.train)
preds.names <- var.names[ var.names != class.name ]

fmla_2 <- as.formula( paste(class.name, paste(preds.names, collapse="+"), sep=" ~ ") )    

glmnetFit <- train( fmla_2 , data=dummy.dset.train, method = "glmnet", metric = "RMSE", trControl = fitControl)
res <- glmnetFit$results[rownames(glmnetFit$bestTune),]



# pr = as.matrix(dummy.dset.train[, preds.names])
# tg = as.matrix(dummy.dset.train[, class.name])
# glmnetFit <- cv.glmnet(x=pr, y=tg, nfolds=10)


#----------------------------------------------------
RocImp <- varImp(glmnetFit, scale = FALSE)
plot(RocImp)

results <- data.frame(row.names(RocImp$importance),RocImp$importance$Overall)
results$VariableName <- rownames(RocImp)
colnames(results) <- c('VariableName','Class')
results <- results[order(results$Class),]
results <- results[(results$Class != 0),]


# par(mar=c(5,15,4,2)) # increase y-axis margin. 
# xx <- barplot(results$Class, width = 0.25, 
#               main = paste("Variable Importance using GLM model"), horiz = T, 
#               xlab = "< (-) importance >  < neutral >  < importance (+) >", axes = TRUE, 
#               col = ifelse((results$Class > 0), 'blue', 'red')) 
# axis(2, at=xx, labels=results$VariableName, tick=FALSE, las=2, line=-0.3, cex.axis=0.6) 


#------------------------ 
predictorsNames <- names(dummy.dset.train)[names(dummy.dset.train) != class.name]  
# 
nro = nrow(dummy.dset.train)
# 
perc = 1 #50/100
ids <- sort(ceiling(sample( seq(1,nro), nro*perc, replace = FALSE)))
dummy.ds.test <- dummy.dset.train[ ids, ]
# 
newdata <- as.matrix(data.frame(dummy.ds.test[, predictorsNames]))

test.instance <- rbind(newdata[1,],newdata[1,])
best.alpha <- glmnetFit$bestTune$alpha
best.lambda <- glmnetFit$bestTune$lambda
testPred <- predict(glmnetFit, test.instance, type="raw", na.action = na.omit )



# auc <- roc(dummy.ds.test[,class.name], testPred)
# 
# results.model<-auc$auc

