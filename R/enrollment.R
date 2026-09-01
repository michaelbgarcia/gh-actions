#' Count enrolled subjects per site
#'
#' Counts subjects with a non-missing enrollment date, grouped by site. Sites
#' with zero enrollments are still reported (as 0) as long as they appear in
#' `data`, because a site that screened everyone out is not the same thing as a
#' site that does not exist.
#'
#' @param data A data frame with columns `subject_id`, `site_id`, `enrol_date`.
#' @return A data frame with columns `site_id` and `n`, ordered by `site_id`.
#' @export
#' @examples
#' enrollment_by_site(demo_enrollment())
enrollment_by_site <- function(data) {
  validate_enrollment(data)

  sites <- sort(unique(as.character(data$site_id)))
  enrolled <- data[!is.na(data$enrol_date), , drop = FALSE]
  counts <- table(factor(as.character(enrolled$site_id), levels = sites))

  data.frame(
    site_id = sites,
    n = as.integer(counts),
    stringsAsFactors = FALSE,
    row.names = NULL
  )
}

#' Screen failure rate
#'
#' A screen failure is a screened subject who never got an enrollment date.
#' Returns a proportion in `[0, 1]`, or `NA_real_` when nobody was screened --
#' deliberately *not* 0, because "no failures" and "no subjects" are different
#' facts and a dashboard should not conflate them.
#'
#' @param data A data frame as described in [validate_enrollment()].
#' @param digits Number of digits to round to. `NULL` means no rounding.
#' @return A single numeric value.
#' @export
#' @examples
#' screen_failure_rate(demo_enrollment())
screen_failure_rate <- function(data, digits = 3) {
  validate_enrollment(data)

  n_screened <- nrow(data)
  if (n_screened == 0L) {
    return(NA_real_)
  }

  rate <- sum(is.na(data$enrol_date)) / n_screened
  if (is.null(digits)) rate else round(rate, digits)
}

#' A small deterministic enrollment data set
#'
#' Used by the examples, the tests and the Shiny app so all three agree on what
#' "the data" means.
#'
#' @return A data frame of 8 subjects across 3 sites.
#' @export
demo_enrollment <- function() {
  data.frame(
    subject_id = sprintf("S%03d", 1:8),
    site_id = c("101", "101", "101", "102", "102", "103", "103", "103"),
    enrol_date = as.Date(c(
      "2026-01-05", "2026-01-11", NA,
      "2026-02-02", NA,
      "2026-02-14", "2026-03-01", "2026-03-09"
    )),
    exit_date = as.Date(c(
      "2026-06-05", NA, NA,
      "2026-04-02", NA,
      NA, "2026-05-01", NA
    )),
    stringsAsFactors = FALSE
  )
}
