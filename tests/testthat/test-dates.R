test_that("days_on_study uses the exit date when present", {
  expect_equal(
    days_on_study(as.Date("2026-01-01"), as.Date("2026-01-31")),
    30L
  )
})

test_that("subjects still on study are closed out at as_of", {
  expect_equal(
    days_on_study(as.Date("2026-01-01"), as.Date(NA), as_of = as.Date("2026-02-01")),
    31L
  )
})

test_that("as_of is pinned in tests, never left to Sys.Date()", {
  # This is the whole point of the `as_of` argument. If this test called
  # days_on_study() without as_of, it would pass today and fail tomorrow --
  # and the failure would land in CI on a day you changed nothing.
  d <- demo_enrollment()

  out <- days_on_study(d$enrol_date, d$exit_date, as_of = as.Date("2026-07-01"))

  expect_length(out, 8L)
  expect_equal(out[1], 151L)                 # 2026-01-05 -> 2026-06-05
  expect_equal(out[2], 171L)                 # open, closed at as_of
  expect_true(is.na(out[3]))                 # never enrolled
})

test_that("mismatched lengths are rejected", {
  expect_error(
    days_on_study(as.Date("2026-01-01"), as.Date(c("2026-01-02", "2026-01-03"))),
    "same length"
  )
})

test_that("an exit before enrollment is an error, not a negative number", {
  expect_error(
    days_on_study(as.Date("2026-02-01"), as.Date("2026-01-01")),
    "precedes enrollment"
  )
})

test_that("the default as_of really is today", {
  # Guarding the default itself is fine -- just make the assertion relative
  # rather than absolute, so it holds on any runner on any day.
  today <- Sys.Date()
  expect_equal(
    days_on_study(today - 10L, as.Date(NA)),
    10L
  )
})
