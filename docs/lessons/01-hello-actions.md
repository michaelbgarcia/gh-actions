# Lesson 01 — Hello, Actions

**Workflow:** `.github/workflows/01-hello-actions.yaml`
**Time:** ~1 minute per run

## The mental model

A workflow is a YAML file in `.github/workflows/`. GitHub watches for the
events in its `on:` block and, when one fires, hands the file to a scheduler.

Four nested things, in order:

- **Workflow** — the file. One `on:` block, many jobs.
- **Job** — runs on its own fresh virtual machine. Jobs run **in parallel** by
  default. Nothing on disk is shared between them.
- **Step** — runs sequentially inside a job, in the same directory on the same
  machine. First failure stops the rest.
- **Action** — someone else's reusable step, pulled in with `uses:`.

The one that trips people up is the second: two jobs never see each other's
files. If job A builds something job B needs, you upload an artifact in A and
download it in B, or you merge them into one job.

## Run it

Actions tab → **01 - Hello Actions** → **Run workflow**.

## What to look at

- The two jobs in the sidebar. `second-job` shows as queued while `greet` runs,
  because of `needs: greet`.
- The **Look around the machine** step: 4 CPUs, ~16 GB RAM, ~14 GB free disk.
  Know these numbers — they are the budget you are working in.
- The **Inspect the trigger** step. `github.event_name` will be
  `workflow_dispatch`; push a commit to this file and it becomes `push`.

## Break it

1. **Comment out the `actions/checkout@v4` step.** Re-run. The next step fails
   with an empty directory listing. This is the single most common beginner
   bug: the runner starts with *nothing* — not your code, not your git history.

2. **Change `needs: greet` to nothing.** Both jobs now start simultaneously and
   the run finishes faster. Add it back.

3. **Add `exit 1` to the end of the "Say hello" step.** Notice that every
   later step in that job is skipped, and `second-job` never runs at all
   because its dependency failed.

## Worth knowing

- `workflow_dispatch:` is free to add and makes every workflow manually
  runnable. Put it on everything while you are learning.
- Pin actions to a major version (`@v4`), not a floating branch. `@main` means
  a third party can change what runs in your pipeline without you noticing.
- The `paths:` filter on the `push:` trigger keeps this lesson from firing on
  every commit. Without path filters on a repo with eight workflows, one push
  starts eight runs.

## Next

[Lesson 02 — Set up R](02-setup-r.md)
