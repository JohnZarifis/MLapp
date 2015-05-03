
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library('shiny')
library('readxl')
library('shinyFiles')

shinyServer(function(input, output,session) {
  
  passData <- reactive({
    inFile <- input$file1
    print(inFile)
    print(str(inFile))
    if (is.null(inFile))
      return(NULL)
    dataset <- read_excel(as.character(inFile$name), sheet = 1 ,col_names = TRUE, na='na')
    #dataset <- read_excel(paste(inFile$datapath,inFile$name,sep="\\"), sheet = 1 ,col_names = TRUE, na='na')
    View(dataset)
    return(dataset)
  })
  
  output$contents <- renderTable({
    
     if (is.null(passData()))
       return(NULL)
     
      passData()
     
  })

})
