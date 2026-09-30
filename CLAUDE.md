# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a hands-on GitHub Actions course using an R package (`enrollr`) as the test subject. The package provides clinical enrollment helpers and exists solely to give testthat something to assert against and CI something to break.

## Common Commands

```r
# Install dependencies and load package
install.packages(c("devtools", "testthat", "covr", "shiny", "shinytest2", "lintr"))
devtools::load_all()

# Run all tests
testthat::test_local()

# Run a single test file
testthat::test_file("tests/testthat/test-enrollment.R")

# Run tests matching a pattern
testthat::test_local(filter = "enrollment")

# Run the Shiny app
enrollr::run_app()

# Lint the package
lintr::lint_package()

# Check coverage
covr::package_coverage(line_exclusions = list("R/app.R"))
```

## Architecture

**Package structure:**
- `R/` - Core functions: `enrollment.R` (enrollment_by_site, screen_failure_rate, demo_enrollment), `dates.R` (days_on_study), `validate.R` (validate_enrollment), `app.R` (run_app wrapper)
- `inst/app/app.R` - The Shiny app UI/server
- `tests/testthat/` - Unit tests plus one shinytest2 browser test

**Design principle:** The Shiny app computes nothing. All logic lives in exported, unit-tested R functions. The app only calls those functions and renders results.

**Workflows (`.github/workflows/`):**
- `01-07-*.yaml` - Numbered lesson workflows, each teaching one concept
- `ci.yaml` - Production-grade workflow combining all lessons

Each lesson workflow has `workflow_dispatch:` so it can be triggered manually from the Actions tab.

## Workflow Job Structure in ci.yaml

1. `quick-test` - Fast feedback: one OS, one R version, unit tests only
2. `matrix-test` - Cross-platform: ubuntu/macos/windows × R release/oldrel (needs quick-test)
3. `coverage` - covr report, fails if <80% (needs quick-test)
4. `shiny` - Browser tests via shinytest2, skipped on draft PRs (needs quick-test)
5. `ci-status` - Summary job for branch protection (needs all above)

## Before Working on Specific Lessons

- **Lesson 05 (renv):** Requires `renv.lock` generated locally via `renv::init()` and `renv::snapshot()`
- **Lesson 07 (schedules):** Replace `REPLACE_WITH_YOUR_GITHUB_USERNAME` in the fork guard
