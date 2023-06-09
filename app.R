library(sass)
library(shiny)
library(bslib)
library(glue)
library(shinyWidgets)
library(dplyr)
library(tibble)
library(stats)
library(scales)

source("weightedPickerInput.R")

css <- sass(sass_file("www/css/styles.scss"))

ui <- fluidPage(
  theme = bs_theme(5),
  tags$head(tags$style(css)),
  tags$head(tags$script(src = "js/index.js")),
  tags$h4("Weighted Picker Input App"),

  weightedPickerInput(
    "car_options",
    c("mpg", "disp", "hp", "drat", "wt", "qsec"),
    selected = NULL
  ),
  verbatimTextOutput("result"),
  tableOutput("table")
)

server <- function(input, output) {
  # allow user to smoothly set needed values
  values_weights <- reactive(input$`car_options-stats_weights`) |>
    debounce(1000)

  output$result <- renderPrint({
    req(values_weights())

    # use it for better readability in app
    as.data.frame(values_weights()$weights, row.names = "weights")
  })

  output$table <- renderTable({
    req(length(values_weights()$weights) > 0)
    stats <- values_weights()$weights

    # get names of stats
    stats_names <- names(stats)
    # get_weights
    stats_weights <- as.numeric(stats)

    # select 5 best cars based on user stats selection
    mtcars |>
      select(all_of(stats_names)) |>
      mutate(across(where(is.numeric), rescale)) |>
      rownames_to_column(var = "car") |>
      rowwise() |>
      mutate(
        mean = mean(c_across(all_of(stats_names))),
        weighted_mean = weighted.mean(c_across(all_of(stats_names)), stats_weights)
      ) |>
      arrange(desc(weighted_mean)) |>
      head(5)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
