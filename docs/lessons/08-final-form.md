# The final form — `ci.yaml`

**Workflow:** `.github/workflows/ci.yaml`

What the seven lessons add up to. Its comments explain *decisions* rather than
syntax, on the assumption you now know the syntax.

## The job graph

```
quick-test  (2 min, one platform, unit tests + lint)
    |
    +-- matrix-test  (4 platforms, R CMD check)
    +-- coverage     (covr, 80% floor)
    +-- shiny        (shinytest2, skipped on draft PRs)
              |
         ci-status  (if: always)
```

## The four decisions worth copying

**1. Fast job first, gating the rest.**
`quick-test` runs one platform in about two minutes. Everything else `needs:`
it. A typo does not spin up four runners to fail identically four times, and
you get feedback on the common case in the time it takes to read the diff.

**2. The three heavy jobs run in parallel, not in a chain.**
Coverage does not `need` the matrix. The number is useful even when Windows is
broken. Chaining jobs that do not depend on each other just makes the pipeline
slower.

**3. Lint is `continue-on-error: true`.**
Style should be visible, not blocking. Nothing trains a team to ignore CI
faster than a red X for a trailing space. Report it, do not gate on it.

**4. One aggregate status check.**
`ci-status` is the job to make required in branch protection. One name to
configure, and adding a matrix row later does not mean editing branch
protection settings. The alternative — listing every matrix job by name —
breaks every time the matrix changes.

Note the loop inside it: `skipped` must not count as a failure, because the
`shiny` job is legitimately skipped on draft PRs. Getting this wrong makes
every draft PR red.

## `timeout-minutes`

Every job has one. The default is **six hours**. A hung R process — a browser
that never starts, a package prompting for input — burns six hours of your
quota before anyone notices. Set a timeout to roughly 3× the expected duration
on every job you ever write.

## Turning it on

1. Push this to `main` and let CI run once so the check names exist.
2. Settings → Branches → Add branch protection rule for `main`.
3. Require status checks to pass → search for **CI status** → select it.
4. Optionally: require branches to be up to date before merging.

Now a PR cannot merge until the pipeline is green.

## What is deliberately not here

- **Deployment.** Publishing a Shiny app is a different shape of workflow —
  `environment:` for approval gates, no `cancel-in-progress`, secrets that
  actually matter. Worth building separately once this is comfortable.
- **`renv`.** `ci.yaml` uses `setup-r-dependencies` reading DESCRIPTION, which
  is right for a package. For a deployed application, swap in
  `r-lib/actions/setup-renv@v2` per lesson 05.
- **Reusable workflows.** Once you have three repos with near-identical CI,
  `workflow_call` lets one repo define the pipeline and the others reference
  it. Worth knowing exists; premature with one repo.
- **Self-hosted runners.** Relevant for validated environments where code
  cannot leave your infrastructure. Different security model entirely — a
  self-hosted runner on a public repo is a well-known way to get compromised.

## Where to go next

- Pick a real project of yours and port `ci.yaml` to it. The friction you hit
  is the actual lesson.
- Read the [r-lib/actions examples](https://github.com/r-lib/actions/tree/v2/examples)
  — they are the reference implementations for the R ecosystem.
- Add a deployment workflow with an `environment:` approval gate.
