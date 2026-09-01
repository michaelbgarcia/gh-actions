# A deliberately thin Shiny app.
#
# Note what is NOT here: any arithmetic. Every number on screen comes from an
# exported enrollr function that already has unit tests. That split is what
# makes a Shiny project testable in CI at all -- server logic that computes
# things inline can only be tested by driving a browser, which is slow and
# flaky. Push the logic down, keep the app dumb.

library(shiny)
library(enrollr)

ui <- fluidPage(
  titlePanel("enrollr demo"),
  sidebarLayout(
    sidebarPanel(
      dateInput(
        "as_of",
        "Data cut date",
        value = as.Date("2026-07-01")
      ),
      checkboxInput("hide_empty", "Hide sites with no enrollments", FALSE),
      helpText(
        "The data cut date is an input, not Sys.Date(). ",
        "That is what makes the screenshot tests in lesson 07 reproducible."
      )
    ),
    mainPanel(
      h4("Screen failure rate"),
      textOutput("sfr"),
      h4("Enrollment by site"),
      tableOutput("by_site"),
      h4("Days on study"),
      tableOutput("dos")
    )
  )
)

server <- function(input, output, session) {
  data <- reactive(demo_enrollment())

  output$sfr <- renderText({
    rate <- screen_failure_rate(data())
    if (is.na(rate)) "No subjects screened." else paste0(rate * 100, "%")
  })

  output$by_site <- renderTable({
    out <- enrollment_by_site(data())
    if (isTRUE(input$hide_empty)) out <- out[out$n > 0L, , drop = FALSE]
    out
  })

  output$dos <- renderTable({
    d <- data()

    # days_on_study() throws when a subject's exit precedes their enrollment,
    # which happens as soon as the user picks a cut date before someone
    # enrolled. Catching it here turns a crashed app into a readable message.
    # The validation belongs in the function; the presentation belongs here.
    days <- tryCatch(
      days_on_study(d$enrol_date, d$exit_date, as_of = input$as_of),
      error = function(e) {
        validate(need(FALSE, paste("Invalid data cut date:", conditionMessage(e))))
      }
    )

    d$days <- days
    d[, c("subject_id", "site_id", "days")]
  })
}

shinyApp(ui, server)
