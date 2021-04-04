library(shiny)
library(tidyverse)
library(ggplot2)
library(reshape2)
#setwd("C:/Repositorios/DevelopDataProducts/ShinyApp")

# Load Data
data <- read.csv(file = "caso.csv", 
                 header = TRUE, 
                 encoding = "UTF-8",
                 sep = ",")

# Select only State records (delete city records) 
data <- data %>% filter(place_type=='state')
data <- data[, c(1,2,5,6)] 

shinyUI(fluidPage(
  titlePanel("Confirmed/ Death Covid Cases in Brazil"),
  sidebarLayout(
    sidebarPanel(
      
      helpText("Just select a State ",
      "and verify the number of confirmed and death Covid cases ",
      "in each year/month."),
      selectInput("State", "State:", choices=unique(data[c("state")])),
      hr(),
      helpText("Data from: ",
      "https://data.brasil.io/dataset/covid19/",
      "caso.csv.gz")
    ),
    
    # Show the plot
    mainPanel(
     plotOutput("Covid_States")
    )
  )
))