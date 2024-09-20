library(shiny)
library(tibble)

api_url <- "http://127.0.0.1:8080/predict"
log <- log4r::logger()

ui <- fluidPage(
  titlePanel("Penguin Mass Predictor"),
  
  # Model input values
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "sq_ft",
        "Square Feet (sq_ft)",
        min = 500,
        max = 5000,
        value = 2000,
        step = 50
      ),
      selectInput(
        "book_section",
        "Book Section",
        c("Single Family Residence", "Condominium", "Twinhomes", "Duplex")
      ),
      sliderInput(
        "total_bedrooms",
        "Number of Bedrooms",
        min = 1,
        max = 10,
        Value = 3,
        step = 1,
      ),
      # Get model predictions
      actionButton(
        "predict",
        "Predict House Price"
      )
    ),
    
    mainPanel(
      h2("Selected Housing Parameters"),
      verbatimTextOutput("vals"),
      
      h2("Predicted House Price"),
      textOutput("pred")
    )
  )
)

