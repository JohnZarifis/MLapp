sidebar <- dashboardSidebar(
  img(src="Aquamanager-logo.png" ,class = "img-responsive"),
  sliderInput("ColumnNo", "Number of Categorical Dimensions",
              min = 2, max = 50, value = 3, step = 1
  ),
#   fileInput('file1', 'Choose file to upload'
#   ),
  hr(),
  shinyFilesButton('file', 'Select a File', 'Please select a file', FALSE),
  hr(),
  sidebarMenu(
    menuItem("Navigation",  icon = icon("navicon"),
             menuSubItem("FirstButton", tabName = "one",icon = icon("signal")),
             menuSubItem("SecondButton", tabName = "two")
    ),
    menuItem("Analysis", icon = icon("bar-chart-o"),
             menuSubItem(icon=NULL, actionButton(inputId = 'Train',  
             label = ' Train ML model', icon =icon("signal")
            )),
            menuSubItem("Training results", tabName = "TrainResults"),
            menuSubItem("Predict with model", tabName = "Predict")
    ) # end menu Analysis
  ) # end sidebarMenu
) # end dashboardSidebar