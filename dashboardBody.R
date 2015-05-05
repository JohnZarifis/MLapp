body <- dashboardBody(
 
  tabItems(
    tabItem(tabName ="one",
          h1("DataSet"),
          hr(),
          dataTableOutput('contents')
     ), # end tabItem
    
     tabItem(tabName = "two",
          h1("Summary of the DataSet: ")
     ), # end tabItem
  
     tabItem(tabName = "Analysis",
          h1("Machine Learning Algorithms"),
          hr()
      ), # end tabItem
    
     tabItem(tabName = "TrainResults",
          h1("Train Machine Learning Model"),
          hr(),
          h3('Summary:'),
          verbatimTextOutput("summary.model"),
          hr(),
          h3(' Relative Importance:'),  
          plotOutput("plot_ML.Rel.Impo",height="600px"),
          hr(),
          verbatimTextOutput("ML.Rel.Impo"),
          hr()
     ), # end tabItem
    
    tabItem(tabName = "Predict",
          h1('Predict with Machine Learning model'),
          hr(),    
          h3('Set values to Predictors:'),
          uiOutput("dyn_input"),
          hr(),
          actionButton(inputId = 'goMLPredict',  label = 'Start prediction'),
          hr(),
          h3("Prediction:"),
          verbatimTextOutput("prediction.value.ML")
    ) # end tabItem
    
    ) # end tabItems
) # end dashboardBody
 