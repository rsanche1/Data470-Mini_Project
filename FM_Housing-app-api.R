library(shiny)
library(tibble)
library(httr2)
library(log4r)

api_url <- "http://127.0.0.1:8080/predict"
log <- log4r::logger()

ui <- fluidPage(
  titlePanel("House Price Predictor"),
  
  # Model input values
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "Total_SqFt",  # No spaces in the input ID
        "Square Feet (sq_ft)",
        min = 500,
        max = 5000,
        value = 2000,
        step = 50
      ),
      selectInput(
        "Book_Section",  # Keep input names consistent
        "Book Section",
        c("Single Family Residence", "Condominium", "Twinhomes", "Duplex")
      ),
      sliderInput(
        "Total_Bedrooms",
        "Number of Bedrooms",
        min = 1,
        max = 10,
        value = 3,
        step = 1
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

server <- function(input, output) {
  log4r::info(log, "App Started")
  
  # Input params
  vals <- reactive({
    tibble(
      sq_ft = input$Total_SqFt,  # Fix the input name to match the UI
      property_type = input$Book_Section,
      bedrooms = input$Total_Bedrooms
    )
  })
  
  # Fetch prediction from API
  pred <- eventReactive(input$predict, {
    log4r::info(log, "Prediction Requested")
    
    # Perform API request
    r <- httr2::request(api_url) |>
      httr2::req_body_json(vals()) |>
      httr2::req_error(is_error = \(resp) FALSE) |>
      httr2::req_perform()
    
    log4r::info(log, "Prediction Returned")
    
    if (httr2::resp_is_error(r)) {
      log4r::error(log, paste("HTTP Error", httr2::resp_status(r), httr2::resp_status_desc(r)))
      return(NULL)
    }
    
    httr2::resp_body_json(r)
  }, ignoreInit = TRUE)
  
  # Render to UI
  output$pred <- renderText({
    if (!is.null(pred())) {
      pred()$.pred[[1]]
    } else {
      "No prediction available"
    }
  })
  
  output$vals <- renderPrint(vals())
}

# Run the application
shinyApp(ui = ui, server = server)

