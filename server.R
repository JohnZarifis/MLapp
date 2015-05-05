
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library('shiny')
library('readxl')
library('shinyFiles')

shinyServer(function(input, output,session) {
  
  volumes <- c('Project Files'=getwd())  #getVolumes() #c('R Installation'=R.home())
  fileChoose<- shinyFileChoose(input, 'file', roots=volumes, session=session, restrictions=system.file(package='base'))
  
  # reactive function to load & transform dataset
  passData <- reactive ({
    if (is.null(fileChoose))
      return(NULL)
    fileSelected <- parseFilePaths(volumes, input$file)
  
    dataset <- read_excel(as.character(fileSelected$datapath), sheet = 1 ,col_names = TRUE, na='na')
    
    # transform data set
    num.cat.var <- as.numeric(input$ColumnNo)
    dataset[, 1:num.cat.var] <- sapply( dataset[, 1:num.cat.var], as.factor )
    
    return(dataset)
  })
  
  
  output$contents <- renderTable({
    if (is.null(passData()))
      return(NULL)
    dataset <- passData()
    return(dataset)
  })



#------------------------------------- GLM function
runGLM <- reactive({
  
  
  list.vars <- list()


})
#------------------------------------- End GLM function

}) # end shinyServer
