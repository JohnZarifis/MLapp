
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library('shiny')
library('readxl')
library('shinyFiles')
library("e1071")
library("caret")
library("pROC")
library("glmnet")
library("effects")
library("relaimpo")
library("ROCR")
library("stringr")


shinyServer(function(input, output,session) {
  
  volumes <- c('Project Files'=getwd())  #getVolumes() #c('R Installation'=R.home())
  fileChoose<- shinyFileChoose(input, 'file', roots=volumes, session=session, restrictions=system.file(package='base'))
  
  # reactive function to load & transform dataset
  passData <- reactive ({
    if (is.null(fileChoose))
      return(NULL)
    fileSelected <- parseFilePaths(volumes, input$file)
  
    dataset <- read_excel(as.character(fileSelected$datapath), sheet = 1 ,col_names = TRUE, na='na')
    colnames( dataset ) <- str_replace_all(colnames( dataset ), c(" " = "", "-" = ".","%"=".perc"))
    # transform data set
    num.cat.var <- as.numeric(input$ColumnNo)
    dataset[, 1:num.cat.var] <- sapply( dataset[, 1:num.cat.var], as.factor )
    
    return(dataset)
  })
  
  
#------------------------------------- GLM function
runGLM <- reactive({
  
  data <- passData()  
  num.cols <- ncol(data)

  # names of inputs & output
  variable.names <- names(data) 
  class.name <- variable.names[num.cols]
  inpts.vars <- variable.names[ -num.cols ] 

  dset.train <- data[, names(data) %in% unlist(variable.names)]
  #fmla <- as.formula( paste(class.name, paste(inpts.vars, collapse="+"), sep=" ~ ") )
  #fmla <- as.formula( paste("", paste(inpts.vars, collapse="+"), sep=" ~ ") )
  
  # transform categorical variables to numeric making dummy variables
  num.cat.var <- as.numeric(input$ColumnNo)
  
  dummy.ds <- dummyVars("~.", data=dset.train[inpts.vars], sep=".", fullRank=F)
  dummy.dset.train <- data.frame(predict(dummy.ds, newdata = dset.train), dset.train[class.name])

#View(dummy.dset.train)

  fitControl <- trainControl(## 10-fold CV
    method = "repeatedcv",
    number = 10,
    ## repeated ten times
    repeats = 10)
  
  dummy.fmla <- as.formula( paste(class.name, paste(names(dummy.dset.train[-ncol(dummy.dset.train)]), collapse="+"), sep=" ~ ") )   
  
  glmnetFit <- train(dummy.fmla, data=dummy.dset.train, method = "glmnet", metric = "RMSE", trControl = fitControl)
  
  return(glmnetFit)
  
})
#------------------------------------- End GLM function

output$contents <- renderDataTable({
  if (is.null(passData()))
    return(NULL)
  dataset <- passData()
  return(dataset)
})

#----------------------------------------- Summary GLMnet
output$summary.model <- renderPrint({
  if (input$goTrain == 0){
    return() }
  else{ 
    isolate({ 
      
      glm.mod <- runGLM()
      res <- glm.mod$results[rownames(glm.mod$bestTune),]
      print(res) 
      
    }) # end isolate
  } # end if...else 

}) # end renderPrint

#--------------- plot relative importance
output$plot_ML.Rel.Impo <- renderPlot({ 
  if (input$goTrain == 0){
    return() }
  else{ 
    isolate({ 
      gml.mod <- runGLM()
      RocImp <- varImp(gml.mod, scale = FALSE)
      
      results <- data.frame(row.names(RocImp$importance),RocImp$importance$Overall)
      results$VariableName <- rownames(RocImp)
      colnames(results) <- c('VariableName','Class')
      results <- results[order(results$Class),]
      results <- results[(results$Class != 0),]
      
      par(mar=c(5,15,4,2)) # increase y-axis margin. 
      xx <- barplot(results$Class, width = 0.25, 
                    main = paste("Variable Importance using GLM model"), horiz = T, 
                    xlab = "< (-) importance >  < neutral >  < importance (+) >", axes = TRUE, 
                    col = ifelse((results$Class > 0), 'blue', 'red')) 
      axis(2, at=xx, labels=results$VariableName, tick=FALSE, las=2, line=-0.3, cex.axis=0.6) 
 
    }) # end isolate
  } # end if..else
})
      
output$ML.Rel.Impo <- renderPrint({ 
  if (input$goTrain == 0){
    return() }
  else{ 
    isolate({  
        gml.mod <- runGLM()
        RocImp <- varImp(gml.mod, scale = FALSE)
        print(RocImp, digits=3, justify="left")
    }) # end isolate
  } # end if..else
})    
      
#---------------------------------------------------------------------------------------------------
# Tab: Predict with Machine Learning Models
#
predict.with.ML.Model <- reactive({
  # load the GLMnet model  
  ML.model <- runGLM()
  data <- passData()
  
  num.cols <- ncol(data)
  
  # create an instance from the input values 
  # names of inputs & output
  variable.names <- names(data) 
  list.predictors <- variable.names[ -num.cols ] 
  num.preds <- length(list.predictors)
  targ <- variable.names[num.cols]
  
#  fmla <- as.formula( paste(targ, paste(list.predictors, collapse="+"), sep=" ~ ") )
#  fmla <- as.formula( paste(" ", paste(list.predictors, collapse="+"), sep=" ~ ") )

  # Create an instance data from the user-defined values
  instance.data <- as.data.frame(matrix(0, nrow = 1, ncol=num.preds))
  instance.data <- lapply(1:num.preds, function(i) {
    input_name <- paste0("input", i, sep="")
    input[[ input_name ]]
  } # end function
  )# end lapply
  names(instance.data) <- list.predictors
  instance.data <- data.frame(instance.data)

  tm.data <- rbind(data[ list.predictors ], instance.data)
  names(tm.data) <- list.predictors

  no.cat.vars <- as.numeric(input$ColumnNo)
  for (i in 1:no.cat.vars){
    levels( tm.data[ list.predictors[i] ] ) <- unique(tm.data[list.predictors[i]])
  }
  
  dummy.instance.data <- dummyVars("~.", data=tm.data, fullRank=F, sep="")
  dummy.newdata <- data.frame( predict( dummy.instance.data, newdata = tm.data), 'Class'=NA)

  dummy.inpts <- as.matrix(data.frame(dummy.newdata[ nrow(dummy.newdata), ]))
  
  pred_ML_model <- predict(ML.model, dummy.inpts, type="raw", na.action = na.omit)

  names(pred_ML_model) <- as.character(targ)
  
  return(pred_ML_model)
  
})

output$dyn_input <- renderUI({
  
  data <- passData()
  num.cols <- ncol(data)
  variable.names <- names(data) 
  list.predictors <- variable.names[ -num.cols ] 
  num.preds <- length(list.predictors)
  num.cat.var <- as.numeric(input$ColumnNo)
  
  #num.cat.var
  inputs.categ <- lapply(1:num.cat.var, function(i) {
    input_name <- paste0("input", i, sep="")
#   fluidRow(column(width=3, 
                    list.values <- unique( data[, list.predictors[[i]]] )
                    selectInput(inputId=input_name, label=h4( as.character(list.predictors[[i]]) ), 
                                  choices=as.character(list.values), multiple=FALSE) 
#            ) # end column
#    ) # end fluidRow
  } # end function
  ) # end lapply 
 
  inputs.numeric <- lapply( (num.cat.var+1) : num.preds, function(i) {
    input_name <- paste0("input", i, sep="")
#    fluidRow(column(width=6, 
                    numericInput( input_name, label = h4( as.character(list.predictors[[i]]) ), value = NA) 
 #           ) # end column
#    ) # end fluidRow
  } # end function
  ) # end lapply
  
  
  do.call(tagList, list(inputs.categ,inputs.numeric) )
}) 

# predict value regarding the predictors' values
output$prediction.value.ML <- renderPrint({ 
  
  if (input$goMLPredict == 0){
    return() }
  else{ 
    isolate({
      
      pred_val <- predict.with.ML.Model()
      print( pred_val )
      
    }) # end isolate
  } # end if...else
  
})      
      
      
      
      
      
      
}) # end shinyServer
