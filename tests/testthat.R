# This file is what `R CMD check` runs. It is intentionally tiny: its only job
# is to hand control to testthat, which then discovers everything in
# tests/testthat/. On a GitHub Actions runner this is the entry point that
# turns a red X into a stack trace you can read.
library(testthat)
library(enrollr)

test_check("enrollr")
