# gh-actions — a hands-on GitHub Actions course for R and Shiny

A working R package (`enrollr`) with a small Shiny app, wrapped in seven
numbered workflows that each teach one thing, plus one production-grade
workflow that combines them.

The package itself is deliberately boring. It exists so testthat has something
real to assert against and so CI has something real to break.

## Run this first

```r
install.packages(c("devtools", "testthat", "covr", "shiny", "shinytest2", "lintr"))
devtools::load_all()
testthat::test_local()      # should be all green
enrollr::run_app()          # the Shiny app
```

If the tests pass locally, everything the workflows do will make sense. If
they do not, fix that before touching CI — a red pipeline you cannot reproduce
on your laptop is the worst place to start learning.

## The course

Work through these in order. Each lesson doc says what the workflow teaches,
what to look at in the run log, and **what to break** to see it fail — the
breaking is the point.

| # | Workflow | Teaches | Doc |
|---|----------|---------|-----|
| 01 | `01-hello-actions.yaml` | Triggers, jobs, steps, runners, `needs` | [doc](docs/lessons/01-hello-actions.md) |
| 02 | `02-setup-r.yaml` | `r-lib/actions`, binary installs, `Rscript -e` | [doc](docs/lessons/02-setup-r.md) |
| 03 | `03-testthat.yaml` | **Automatic testing**, artifacts, `if: always()` | [doc](docs/lessons/03-testthat.md) |
| 04 | `04-matrix.yaml` | Matrix builds, `fail-fast`, cross-platform shells | [doc](docs/lessons/04-matrix.md) |
| 05 | `05-renv.yaml` | renv restore, cache keys, reproducibility | [doc](docs/lessons/05-renv.md) |
| 06 | `06-check-and-coverage.yaml` | `R CMD check`, covr, PR comments, `permissions` | [doc](docs/lessons/06-check-and-coverage.md) |
| 07 | `07-schedules-and-guards.yaml` | `schedule`, `concurrency`, secrets, conditionals | [doc](docs/lessons/07-schedules-and-guards.md) |
| — | `ci.yaml` | All of it, arranged the way a real project would | [doc](docs/lessons/08-final-form.md) |

Each lesson workflow has a `workflow_dispatch:` trigger, so you can run any of
them by hand from the **Actions** tab without pushing a commit. Lessons 01, 02
and 05 also have `paths:` filters so they only fire when their own file
changes — otherwise every push would trigger everything.

## What is in the package

```
R/enrollment.R   enrollment_by_site(), screen_failure_rate(), demo_enrollment()
R/dates.R        days_on_study()  — deliberately time-dependent, see lesson 04
R/validate.R     validate_enrollment() — the error paths the tests lean on
R/app.R          run_app()
inst/app/app.R   the Shiny app: no arithmetic, all logic delegated to R/
tests/testthat/  unit tests + one shinytest2 browser test
```

The design rule worth stealing: **the app computes nothing.** Every number on
screen comes from an exported, unit-tested function. That is what makes a
Shiny project testable in CI without driving a browser for everything.

## Before lesson 05

Lesson 05 needs a lockfile that is not in this repo yet — you have to generate
it from your own machine:

```r
install.packages("renv")
renv::init()
renv::install(c("testthat", "covr", "shiny", "shinytest2", "lintr"))
renv::snapshot()
```

Then commit `renv.lock` and `.Rprofile`. The workflow fails with a clear
message until you do.

## Before lesson 07

Edit the fork guard in `07-schedules-and-guards.yaml` — replace
`REPLACE_WITH_YOUR_GITHUB_USERNAME` with your actual username.

## Reading a failed run

1. **Actions** tab → click the red run → click the red job.
2. The failing step is auto-expanded. Scroll to the first error, not the last.
3. For testthat failures, the artifact `test-results.xml` is attached at the
   bottom of the run page.
4. For Shiny snapshot failures, download the `shinytest2-failures` artifact and
   compare the images.

Anything logged with `::error::` shows up as an annotation on the run summary
page — that is the mechanism the workflows here use to surface the important
line without you having to hunt through the log.
