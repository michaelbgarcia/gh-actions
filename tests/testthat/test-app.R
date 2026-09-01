# shinytest2 drives a real headless browser, so it needs Chrome on the runner
# and it is an order of magnitude slower than the unit tests. Skip it locally
# unless the packages are present, and skip it on CRAN-like checks entirely.
#
# Lesson 07 turns this on in its own job so a browser failure never masks a
# logic failure.

test_that("the app starts and renders the expected values", {
  skip_on_cran()
  skip_if_not_installed("shiny")
  skip_if_not_installed("shinytest2")

  app_dir <- system.file("app", package = "enrollr")
  skip_if(app_dir == "", "enrollr not installed; run devtools::install() first")

  app <- shinytest2::AppDriver$new(
    app_dir,
    name = "enrollr-demo",
    height = 800,
    width = 1200,
    load_timeout = 30 * 1000
  )
  on.exit(app$stop(), add = TRUE)

  app$set_inputs(as_of = "2026-07-01")

  values <- app$get_values(output = c("sfr", "by_site"))

  expect_match(values$output$sfr, "25%")
  expect_match(values$output$by_site, "101")
})
