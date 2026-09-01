# Lesson 03 — Automatic testing with testthat

**Workflow:** `.github/workflows/03-testthat.yaml`
**Time:** ~2–4 minutes first run, under 2 once cached

This is the lesson the whole repo exists for. Everything before it is setup;
everything after is refinement.

## The mental model

Three steps, always in this order:

1. **Install dependencies** — `setup-r-dependencies` reads `DESCRIPTION`,
   resolves `Depends`/`Imports`/`Suggests`, installs, and caches the result.
2. **Install the package** — `R CMD INSTALL .` so `library(enrollr)` works and
   `system.file()` resolves `inst/`.
3. **Run the suite** — `testthat::test_local()`.

## `test_local()` vs `R CMD check`

| | `test_local()` | `R CMD check` |
|---|---|---|
| Runs | your tests | tests + examples + docs + NAMESPACE + portability |
| Speed | seconds | minutes |
| Use as | the fast loop, on every push | the gate, on PRs and releases |

Use both, in separate jobs. This lesson does the first; lesson 06 adds the
second.

## Caching

`setup-r-dependencies` handles the cache for you, keyed on the *resolved*
dependency versions. First run installs everything; subsequent runs restore in
seconds. You will see the difference between run 1 and run 2 of this workflow
immediately.

The cache invalidates when DESCRIPTION changes — which is exactly when the
cached library became wrong. Lesson 05 shows the manual version so this stops
being magic.

## The two patterns worth stealing from this file

**`stop_on_failure = FALSE` plus a manual `quit(status = 1)`.**
If testthat aborts on the first failure, the JUnit XML never gets written, and
you lose the report on precisely the runs where you want it. Let the suite
finish, write the file, *then* set the exit code.

**`if: always()` on the upload step.**
Without it, the artifact upload is skipped whenever the tests fail. Any step
whose output you need in order to debug a failure needs `if: always()`.

## What to look at

- The **Run testthat** step log — testthat's progress reporter, then the
  summary block.
- The **Artifacts** section at the bottom of the run page: `test-results.xml`.
- The run summary page — the `$GITHUB_STEP_SUMMARY` markdown appears above the
  job list.

## Break it

1. **Change an expectation.** In `tests/testthat/test-enrollment.R`, change
   `expect_equal(out$n, c(2L, 1L, 3L))` to `c(2L, 2L, 3L)`. Push. Read the
   failure output — testthat tells you the expected and actual values.

2. **Break the code instead of the test.** In `R/enrollment.R`, delete the
   `[!is.na(data$enrol_date), ]` filter. Three tests should fail. This is the
   version that matters: the tests caught a real behaviour change.

3. **Remove `if: always()` from the upload step** and break a test. The
   artifact disappears.

4. **Open a pull request** with a broken test. The check appears inline on the
   PR. Then go to Settings → Branches → add a rule on `main` requiring the
   `test` check — now the merge button is blocked. That is the payoff.

## Test-writing notes

Look at what the tests in this repo actually assert:

- **Error messages, not just errors.** `expect_error(f(x), "site_id")` keeps
  failing if you break the message. `expect_error(f(x))` does not.
- **Types, not just values.** `expect_type(x, "integer")` catches the
  double/integer drift that formats as `2.00` three layers downstream.
- **The empty case.** `screen_failure_rate()` on zero rows returns `NA`, not
  `0` — and there is a test pinning that, because "no failures" and "no
  subjects" are different facts.
- **Time is an argument.** `days_on_study(..., as_of =)` exists so tests can
  pin the date. A test that calls `Sys.Date()` passes today and fails in CI on
  a day you changed nothing.

## Next

[Lesson 04 — Matrix builds](04-matrix.md)
