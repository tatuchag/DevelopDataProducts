library(shiny)
library(tidyverse)
library(ggplot2)
library(reshape2)

#setwd("C:/Repositorios/DevelopDataProducts/ShinyApp")


shinyServer(function(input, output) { 

  # Load Data
  # Data from https://data.brasil.io/dataset/covid19/caso.csv.gz
  data <- read.csv(file = "caso.csv", 
                   header = TRUE, 
                   encoding = "UTF-8",
                   sep = ",")
 
  # Select only State records (delete city records) 
  data <- data %>% filter(place_type=='state')
  
  # Select only the most relevant columns
  data <- data[, c(1,2,5,6)] 
  
  # Rename/ format columns
  colnames(data) <- c('Date','State', 'confirmed', 'deaths')
  data$Date <- as.Date(data$Date, format = '%Y-%m-%d')
  
  # Group Covid Cases by State and Date  
  data_grp <- as.data.frame(
    data %>%
      mutate(month = format(Date, "%m"), year = format(Date, "%Y")) %>%
      group_by(State, month, year) %>%
      summarise(confirmed = sum(confirmed), deaths = sum(deaths)))
  
  # Includes column that concatenate Year and Month
  data_grp$monYear <- paste(data_grp$year, '-', data_grp$month)
  
  # Sort dataframe 
  data_grp <- data_grp[order(data_grp$State, data_grp$monYear, decreasing=FALSE),]
  
  # Prepare/ Format dataframe to plots 
  data_consol <- melt(data_grp[c('State','monYear', 'confirmed','deaths')], 
                        id.vars=c("State", "monYear"), variable.factor=FALSE) 
  colnames(data_consol) <- c('State', 'YearMonth','Covid','Total')


  output$Covid_States <- renderPlot( {
    data_consol <- data_consol %>% filter(State==input$State) 
    ggplot(data = data_consol, 
           aes(x=YearMonth, y=Total/1000, 
               width = 0.75,
               fill=factor(Covid,levels=c("deaths","confirmed")))) +
      geom_bar(stat="identity", colour="white", position=position_dodge())+
      geom_text(aes(label=round(Total/1000,2)), vjust=-1, 
                color= ifelse(data_consol$Covid=="confirmed", "blue","red"),
                position = position_dodge(1), size=3.5, fontface="bold")+
      scale_fill_brewer(palette="Set1", direction=1) + theme_minimal() + 
      theme(legend.position = "right") + 
      theme(axis.text.x = element_text(angle=90,  size=12, vjust=0.5, hjust=1),
            axis.ticks.length = unit(0.25,"mm")) + 
      labs(title = "Confirmed/ Death Covid Cases in Brazilian",
           subtitle= paste("State: ", input$State),
           x="Year/ Month", 
           y="Number of cases (x1000)") + 
      guides(fill=guide_legend(title="Covid Cases"))
  }, height = 500, width = 1000, units="px")
  })
