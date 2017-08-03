

suppressWarnings(library(shiny))

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Predict Next Word"),
  
  fluidRow(HTML("<strong>Author: Fan Ouyang</strong>") ),
  fluidRow(HTML("<strong>Date: 3-Aug-2017</strong>") ),
  
  fluidRow(
    br(),
    p("This is a Shiny application, useing N-Gram Back Off model to predict next word in the user entered words sequence.")),
  br(),
  br(),
  
  fluidRow(HTML("<strong>Enter an incomplete sentence. Press \"Next Word\" button to predict the next word</strong>") ),
  fluidRow( p("\n") ),
  
  # Sidebar layout
  sidebarLayout(
    
    sidebarPanel(
      textInput("inputString", "Enter an incomplete sentence here",value = ""),
      submitButton("Next Word")
    ),
    
    mainPanel(
      h4("Predicted Next Word"),
      verbatimTextOutput("prediction"),
      textOutput('text1'),
      textOutput('text2')
    )
  )
    ))