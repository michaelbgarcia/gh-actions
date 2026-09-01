#' Days on study
#'
#' Elapsed days between enrollment and exit. Subjects still on study (no exit
#' date) are measured against `as_of`, which defaults to today -- so this
#' function is *time dependent*, and lesson 05 uses it to show why a test that
#' passes on your laptop can fail on a runner in a different time zone.
#'
#' @param start Date vector of enrollment dates.
#' @param end Date vector of exit dates; `NA` means still on study.
#' @param as_of Date used to close out subjects still on study.
#' @return An integer vector of day counts. `NA` where `start` is `NA`.
#' @export
#' @examples
#' d <- demo_enrollment()
#' days_on_study(d$enrol_date, d$exit_date, as_of = as.Date("2026-07-01"))
days_on_study <- function(start, end, as_of = Sys.Date()) {
  if (length(start) != length(end)) {
    stop("`start` and `end` must be the same length.", call. = FALSE)
  }

  start <- as.Date(start)
  end <- as.Date(end)
  as_of <- as.Date(as_of)

  closed <- ifelse(is.na(end), as_of, end)
  closed <- as.Date(closed, origin = "1970-01-01")

  out <- as.integer(closed - start)

  if (any(!is.na(out) & out < 0L)) {
    stop("Exit date precedes enrollment date for at least one subject.",
         call. = FALSE)
  }

  out
}
