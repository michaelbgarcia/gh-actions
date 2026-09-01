# Lesson: error-path tests are the ones that pay for themselves in CI.
# A passing happy path tells you the code ran. A passing error path tells you
# the code will tell *you* what went wrong at 2am.

test_that("valid data passes silently", {
  expect_true(validate_enrollment(demo_enrollment()))
  expect_invisible(validate_enrollment(demo_enrollment()))
})

test_that("non-data-frame input is rejected by class", {
  expect_error(validate_enrollment(list(a = 1)), "must be a data frame")
  expect_error(validate_enrollment(1:10), "must be a data frame")
})

test_that("missing columns are named in the error", {
  d <- demo_enrollment()
  d$site_id <- NULL

  # Match the message, not just the fact that it threw. A test that only
  # asserts "it errored" will keep passing after you break the message.
  expect_error(validate_enrollment(d), "site_id")
})

test_that("enrol_date must actually be a Date", {
  d <- demo_enrollment()
  d$enrol_date <- as.character(d$enrol_date)

  expect_error(validate_enrollment(d), "must be a Date")
})

test_that("duplicate subject ids are caught", {
  d <- demo_enrollment()
  d$subject_id[2] <- d$subject_id[1]

  expect_error(validate_enrollment(d), "Duplicate subject_id")
})
