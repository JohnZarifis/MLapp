body <- dashboardBody(
 
  tabItems(
    tabItem(tabName ="one",
              
              h1("DataSet"),
              hr(),
              tableOutput('contents')
     ),
     
     tabItem(tabName = "two",
          h1("Summary of the DataSet: ")
     ),
  
     tabItem(tabName = "Analysis",
          h1("Machine Learning Algorithms")
     )
     
  ) 
  
)