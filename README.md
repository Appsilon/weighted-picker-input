
# weight-picker-input

To use weighted pickerInput in your application:

Add this to your `ui`:

```r
source("weightedPickerInput.R")
css <- sass(sass_file("www/css/styles.scss"))

ui <- fluidPage(
  theme = bs_theme(5),
  # css + js needed for proper functionality
  tags$head(tags$style(css)),
  tags$head(tags$script(src = "js/index.js")),

  weightedPickerInput(
    "car_options",
    c("mpg", "disp", "hp", "drat", "wt", "qsec")
  )
)
```

Then you can access the input in `server`

```r
observeEvent(input$`car_options-stats_weights`, {
  state <- input$`car_options-stats_weights`
  weights <- state$weights
})
```
