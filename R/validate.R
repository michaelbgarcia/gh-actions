#' Validate an enrollment data frame
#'
#' Fails loudly and specifically. Vague errors are the enemy of a useful CI
#' log: when a job goes red you want the message to tell you which column is
#' wrong, not just that "something" is.
#'
#' @param data Object to validate.
#' @return `TRUE`, invisibly, if valid. Otherwise it throws.
#' @export
validate_enrollment <- function(data) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame, not ", class(data)[1], ".", call. = FALSE)
  }

  required <- c("subject_id", "site_id", "enrol_date")
  missing_cols <- setdiff(required, names(data))
  if (length(missing_cols) > 0L) {
    stop("`data` is missing required column(s): ",
         paste(missing_cols, collapse = ", "), ".", call. = FALSE)
  }

  if (!inherits(data$enrol_date, "Date")) {
    stop("`enrol_date` must be a Date, not ", class(data$enrol_date)[1], ".",
         call. = FALSE)
  }

  dup <- duplicated(data$subject_id)
  if (any(dup)) {
    stop("Duplicate subject_id(s): ",
         paste(unique(data$subject_id[dup]), collapse = ", "), ".",
         call. = FALSE)
  }

  invisible(TRUE)
}
