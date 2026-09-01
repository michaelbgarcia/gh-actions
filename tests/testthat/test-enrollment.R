test_that("enrollment_by_site counts only enrolled subjects", {
  out <- enrollment_by_site(demo_enrollment())

  expect_s3_class(out, "data.frame")
  expect_named(out, c("site_id", "n"))
  expect_equal(out$site_id, c("101", "102", "103"))
  expect_equal(out$n, c(2L, 1L, 3L))
})

test_that("a site that enrolled nobody still appears with n = 0", {
  d <- demo_enrollment()
  d$enrol_date[d$site_id == "102"] <- NA

  out <- enrollment_by_site(d)

  expect_equal(out$n[out$site_id == "102"], 0L)
  expect_equal(nrow(out), 3L)  # site 102 must not vanish
})

test_that("enrollment_by_site returns integers, not doubles", {
  # Type stability matters downstream: a numeric 2 formats as "2" in some
  # contexts and "2.00" in others. Assert the type you promised.
  expect_type(enrollment_by_site(demo_enrollment())$n, "integer")
})

test_that("screen_failure_rate matches a hand calculation", {
  # 8 screened, 2 with no enrol_date -> 2/8 = 0.25
  expect_equal(screen_failure_rate(demo_enrollment()), 0.25)
})

test_that("screen_failure_rate honours digits", {
  d <- demo_enrollment()[1:3, ]           # 1 of 3 failed -> 0.3333...
  expect_equal(screen_failure_rate(d, digits = 2), 0.33)
  expect_equal(screen_failure_rate(d, digits = NULL), 1 / 3)
})

test_that("an empty study returns NA, not zero", {
  empty <- demo_enrollment()[0, ]

  expect_true(is.na(screen_failure_rate(empty)))
  expect_type(screen_failure_rate(empty), "double")
})
