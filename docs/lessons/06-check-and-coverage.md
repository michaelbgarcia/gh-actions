# Lesson 06 — R CMD check, coverage, and writing back to a PR

**Workflow:** `.github/workflows/06-check-and-coverage.yaml`

Three parallel jobs: `r-cmd-check`, `coverage`, `shiny-test`. They are separate
on purpose — a flaky browser test should not hide a coverage regression, and a
coverage number is still useful when Windows is broken.

## `R CMD check`

Everything `test_local()` does, plus: every `@examples` block runs, docs match
the code, `NAMESPACE` matches the `@export` tags, DESCRIPTION is well-formed,
no non-portable file paths, no undeclared dependencies.

`error-on` sets the strictness:

- `'"error"'` — only hard errors fail the job
- `'"warning"'` — warnings fail too **← start here**
- `'"note"'` — notes fail too; use once the package is clean and you want it
  to stay that way

Note the double quoting: `'"warning"'`. The outer quotes are YAML, the inner
ones are R. This is a real R expression being passed through.

## Coverage

```r
covr::package_coverage(line_exclusions = list("R/app.R"))
```

`R/app.R` is excluded because it is exercised by shinytest2, not by unit tests.
Counting it would make the number a lie in the direction that flatters you.

**On the 80% floor:** a floor is not a target. Set it just below where you are
today and ratchet it up as you add tests. A floor you set aspirationally gets
ignored, and a CI check people ignore is worse than no check.

And coverage measures which lines *ran*, not whether the assertions are any
good. A test file of `expect_true(TRUE)` can hit 100%.

## `permissions:`

```yaml
permissions:
  contents: read
  pull-requests: write
```

By default `GITHUB_TOKEN` gets broad write scopes on every job. Narrowing them
per workflow means a compromised third-party action cannot push to your repo.
This is the highest-value security setting in Actions and it costs two lines.

Here, `pull-requests: write` exists solely so the coverage comment step can
post. Drop that step, drop the permission.

## `actions/github-script`

Runs JavaScript with an authenticated Octokit client already wired up. Much
less fiddly than curl-ing the REST API and handling auth headers yourself. Two
useful globals: `github` (the API client) and `context` (repo, PR number, SHA).

## shinytest2

Drives real headless Chrome via chromote. Slow, occasionally flaky, and the
only way to test that the app actually renders.

The test in `tests/testthat/test-app.R` sets `as_of` explicitly. If the app
used `Sys.Date()` internally, the "days on study" table would change every day
and the test could never assert a value. **Making the data cut date an input is
what makes the app testable** — that design decision is more important than any
CI configuration in this repo.

Snapshot failures upload as an artifact under `if: failure()`, because the
before/after images are the whole point of a snapshot test.

## Break it

1. **Add an unexported function with a broken `@examples` block.**
   `test_local()` passes; `R CMD check` fails. That gap is why both jobs exist.

2. **Delete a line from `NAMESPACE`.** `R CMD check` catches the drift.

3. **Delete `tests/testthat/test-dates.R`.** Watch coverage drop while the
   check job still passes — and see whether it falls under the 80% floor. If it
   does not, that tells you the floor is set too low for this package; raise it
   until it bites.

4. **Set `error-on: '"note"'`.** See how much noise a clean-looking package
   actually produces.

## Next

[Lesson 07 — schedules and guards](07-schedules-and-guards.md)
