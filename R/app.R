#' Launch the demo Shiny app
#'
#' The app is stored in `inst/app` so it ships with the installed package and
#' so shinytest2 can find it on a runner via [system.file()].
#'
#' @param ... Passed to [shiny::runApp()].
#' @return Invoked for its side effect.
#' @export
run_app <- function(...) {
  # shiny is in Suggests, not Imports: the package's testable logic must work
  # without it. R CMD check will flag an unguarded shiny:: call, so guard it.
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required to run the app. Install it first.",
         call. = FALSE)
  }

  app_dir <- system.file("app", package = "enrollr")
  if (app_dir == "") {
    stop("Could not find the app directory. Is enrollr installed?",
         call. = FALSE)
  }
  shiny::runApp(app_dir, ...)
}
