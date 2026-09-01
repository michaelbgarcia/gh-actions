# Lesson 05 — renv and caching

**Workflow:** `.github/workflows/05-renv.yaml`

## Do this first

The workflow fails deliberately until you generate a lockfile. From the project
root, in R:

```r
install.packages("renv")
renv::init()
renv::install(c("testthat", "covr", "shiny", "shinytest2", "lintr"))
renv::snapshot()
```

Commit `renv.lock` and `.Rprofile`. **Do not** commit `renv/library/` — the
`.gitignore` here already excludes it.

## Why bother, when DESCRIPTION already lists dependencies

They answer different questions.

| | DESCRIPTION | renv.lock |
|---|---|---|
| Says | `testthat (>= 3.2.0)` | `testthat 3.2.1, CRAN, hash abc123…` |
| Resolves to | whatever is newest today | the same thing every time |
| Includes | direct dependencies | the full transitive tree |

For a package you publish, DESCRIPTION ranges are correct — you *want* it to
work with future versions. For an application you deploy, and for anything that
has to be reproducible on a date in the past, you need the lockfile.

If you have ever been asked "reproduce the output from the March run," this is
the answer. A DESCRIPTION range cannot give you that; a lockfile can.

## Cache keys

`setup-renv` handles caching, but the mechanism is worth understanding because
you will hand-roll it eventually:

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.cache/R/renv
    key: ${{ runner.os }}-renv-${{ hashFiles('renv.lock') }}
    restore-keys: |
      ${{ runner.os }}-renv-
```

- `key` is an **exact** match. Hit → restore, skip installing entirely.
- `restore-keys` are **prefix** matches, tried newest first. A partial hit
  restores a slightly stale library so the install only fetches the delta.
- `hashFiles('renv.lock')` changes exactly when the lockfile changes — which is
  exactly when the cached library became wrong.

The commented-out block in the workflow is the manual version. Uncomment it,
comment out `setup-renv`, and confirm it behaves the same.

Two things that bite:

- **Caches are immutable.** A key that hit is never updated. To force a refresh
  you change the key — that is what `cache-version: 1` in `setup-r-dependencies`
  is for.
- **Caches are scoped to a branch.** A branch can read `main`'s cache, but not
  a sibling branch's. First run on a new branch is often slower.

## `renv::status()`

Checks whether the lockfile matches what the project actually uses. Catches the
classic "I `library()`'d something and forgot to `snapshot()`" bug in CI rather
than on a colleague's machine three weeks later.

## Break it

1. **Delete `renv.lock` and push.** Read the error annotation — that is
   `::error::` producing a message on the run summary page rather than burying
   it in the log.

2. **Hand-edit a version in `renv.lock`** to something old. Watch the cache
   miss and the reinstall.

3. **Add `library(jsonlite)` to a file in `R/` without snapshotting.**
   `renv::status()` should flag it.

## For regulated work

The combination that gets you closest to a reproducible, auditable pipeline:
`renv.lock` for exact package versions, an RSPM snapshot URL frozen to a date
for the repository state, and a pinned R version — not `release`, which moves.
Container images (`rocker/r-ver:4.4.1`) take it one step further by pinning the
system libraries too.

## Next

[Lesson 06 — check and coverage](06-check-and-coverage.md)
