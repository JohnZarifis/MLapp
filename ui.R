# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinydashboard)
library('shinyFiles')

source("dashboardHeader.R")
source("dashboardSidebar.R")
source("dashboardBody.R")

dashboardPage(header, sidebar, body)