# Lesson 04 — Matrix builds

**Workflow:** `.github/workflows/04-matrix.yaml`
**Time:** ~5–8 minutes (five jobs in parallel)

## The mental model

`strategy.matrix` generates N copies of the same job, one per combination.
Each is a separate VM, all running at once.

Two ways to write it:

```yaml
# Cartesian product: 3 x 3 = 9 jobs. Usually more than you want.
matrix:
  os: [ubuntu-latest, macos-latest, windows-latest]
  r: ['release', 'oldrel-1', 'devel']

# Explicit list of objects: exactly the 5 pairs you chose.
matrix:
  config:
    - { os: ubuntu-latest, r: 'release' }
    - { os: macos-latest,  r: 'release' }
```

Use the second form. The product form gets expensive fast, and most of the
combinations tell you nothing.

## `fail-fast: false`

**The default is `true`, and it is wrong for test matrices.** With `true`, the
first failing job cancels all its siblings — so a Windows failure hides the
fact that macOS also failed, and you fix one thing, push, and discover the
next. Set it to `false` and see all the failures at once.

## Minute costs

On private repos, runner minutes are billed with a multiplier:

| Runner | Multiplier |
|---|---|
| Linux | 1× |
| Windows | 2× |
| macOS | 10× |

A 5-minute macOS job costs 50 minutes of quota. Public repos are free, but the
habit of keeping macOS rows to a minimum is worth forming now.

## `shell: bash` — the classic matrix bug

Windows runners default to PowerShell. A `run: |` block using `[ -f file ]` or
`$(...)` works on Linux and macOS and fails on Windows only. Adding
`shell: bash` to every `run` step in a cross-platform matrix makes one script
work everywhere — Git Bash ships on the Windows image.

## `continue-on-error`

The R-devel row uses it. R-devel is a moving target: it breaks for reasons that
are not your fault, and blocking merges on it means blocking merges on someone
else's commit. `continue-on-error: true` means the job runs, you see the
result, and it does not gate anything.

## Break it

1. **Set `fail-fast: true`** and break a test. Watch the other four jobs get
   cancelled mid-flight.

2. **Remove `shell: bash`** from the "Run testthat" step. The Windows job — and
   only the Windows job — fails.

3. **Add `- { os: ubuntu-latest, r: '4.0.0' }`** to the matrix. The package
   declares `R (>= 4.1)`. Does the job fail? (Not on `test_local()` alone — see
   lesson 06.)

## Next

[Lesson 05 — renv](05-renv.md)
