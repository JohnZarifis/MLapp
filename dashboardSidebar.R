sidebar <- dashboardSidebar(
  img(src="Aquamanager-logo.png" ,class = "img-responsive"),
  sliderInput("ColumnNo", "Number of Dimensions",
              min = 0, max = 50, value = 3, step = 1
  ),
  fileInput('file1', 'Choose file to upload'
  ),
  
  sidebarMenu(
    menuItem("Navigation",  icon = icon("navicon"),
             menuSubItem("Univariate", tabName = "Univariate",icon = icon("signal")),
             menuSubItem("readme", tabName = "readme")
    ),
    menuItem("Widgets", icon = icon("th"), tabName = "widgets", badgeLabel = "new",
             badgeColor = "green"),
    menuItem("Charts", icon = icon("bar-chart-o"),
             menuSubItem("Sub-item 1", tabName = "subitem1"),
             menuSubItem("Sub-item 2", tabName = "subitem2")
             
    ),
    menuItem( "Test", icon = icon("navicon"),
              menuItem("FileInput" ,icon = icon("file"),
                       menuSubItem( "rwar",icon=NULL
                                                
                       ))
              
    )
  )
)