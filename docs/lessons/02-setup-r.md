# Lesson 02 — Getting R onto a runner

**Workflow:** `.github/workflows/02-setup-r.yaml`
**Time:** ~1–2 minutes

## The mental model

The runner image has git, curl, Python and Node preinstalled. It does not have
R. `r-lib/actions/setup-r@v2` installs it.

`r-lib/actions` is maintained by the people who maintain devtools and usethis.
Do not hand-roll `apt-get install r-base` — you will get an old R and no binary
repository.

## The one line that matters

```yaml
use-public-rspm: true
```

This points R at Posit Public Package Manager, which serves **precompiled Linux
binaries**. Without it, every package installs from source. `dplyr` alone takes
several minutes to compile; a full dependency tree can take twenty. With it,
the same install is seconds.

If an R workflow is inexplicably slow, check this line first.

## `r-version` values

| Value | Means |
|---|---|
| `release` | current stable — the default choice |
| `oldrel-1` | one minor version back — what your colleagues probably run |
| `4.4.1` | an exact pin |
| `devel` | tomorrow's R — for early warning, never as a merge gate |

## What to look at

- **Confirm the R install** — `sessionInfo()` tells you the exact version and
  platform. `getOption("repos")` shows the RSPM URL if the flag worked.
- **Source the package files directly** — this loads `R/*.R` with `source()`
  and calls the functions. It works, but it is not how to run tests: it skips
  `NAMESPACE`, skips dependency checks, and `system.file()` will not find
  `inst/app`. Lesson 03 installs the package properly.

## Break it

1. **Set `use-public-rspm: false`** and re-run. Compare the duration of the
   dependency install. This is the lesson.

2. **Change `r-version` to `4.0.0`.** The package declares `R (>= 4.1)` in
   DESCRIPTION — but note that nothing here *enforces* that yet. `R CMD check`
   in lesson 06 is what catches it.

3. **Flip the last step's `if: false` to `if: true`.** That is what a failing R
   step looks like: the `stop()` message, a non-zero exit, a red X.

## Worth knowing

`Rscript -e 'expr'` is the workhorse. The quoting rule: single quotes on the
outside for the shell, double quotes inside for R. Multi-line R inside a
`run: |` block works, but once it exceeds ~15 lines put it in a real `.R` file
and call `Rscript path/to/script.R` — you get syntax highlighting, linting and
the ability to run it locally.

## Next

[Lesson 03 — Run testthat](03-testthat.md)
