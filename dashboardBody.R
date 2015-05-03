body <- dashboardBody(
  dashboardBody(
    tabItems(
      tabItem(tabName ="one",
              
              h1("File outpup from first button"),
              hr(),
        tableOutput('contents')
  
  
  ),
  tabItem(tabName = "two",
          h1("File outpup from second button"),
          tableOutput('contents2')
  )
 
  )))