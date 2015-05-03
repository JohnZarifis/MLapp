body <- dashboardBody(
  dashboardBody(
    tabItems(
      tabItem(tabName ="Univariate",
              h4("End Average Weight:"),
              h1("My title"),
              hr(),
        tableOutput('contents')
  
  
  ),
  tabItem(tabName = "readme",
          h1("My title readme")
  )
 
  )))