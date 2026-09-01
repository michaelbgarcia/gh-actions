# Lesson 07 — Schedules, concurrency, secrets, conditionals

**Workflow:** `.github/workflows/07-schedules-and-guards.yaml`

The operational layer: the keys that stop CI from wasting your minutes and from
leaking things it should not.

## Edit this before running

Replace `REPLACE_WITH_YOUR_GITHUB_USERNAME` in the `if:` guard with your
username.

## `schedule:`

```yaml
schedule:
  - cron: '0 7 * * 1-5'
```

Standard POSIX cron: minute, hour, day-of-month, month, day-of-week.

**Always UTC. There is no timezone option.** `0 7 * * 1-5` is 03:00 in
America/New_York during EDT and 02:00 during EST — a "9am daily" schedule
silently shifts by an hour twice a year. Write the UTC time you want and put
the local equivalent in a comment.

Two more things to know:

- Scheduled runs are **best-effort**. Under load GitHub delays them, sometimes
  by 10+ minutes. Never build anything that needs a precise time.
- Schedules are **disabled automatically after 60 days of repository
  inactivity**. On a quiet repo the nightly quietly stops. GitHub emails the
  repo owner; the email is easy to miss.

## `concurrency:`

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

Runs sharing a `group` never run simultaneously; the new one cancels the old.
Push three times in a minute and you get one run instead of three full
matrices. On any repo with more than one contributor this pays for itself
immediately.

The exception: **never** use `cancel-in-progress: true` on a deployment
workflow. Cancelling a deploy halfway leaves the target in an unknown state.

## The fork guard

```yaml
if: github.event_name != 'schedule' || github.repository_owner == 'your-username'
```

Someone forks your repo, and your nightly schedule comes with it — burning
their minutes on a schedule they never set. Standard practice on public repos.

## Secrets vs vars

| | `secrets.X` | `vars.X` |
|---|---|---|
| Visible in logs | no — masked as `***` | yes |
| Set at | Settings → Secrets and variables → Actions | same page, Variables tab |
| For | tokens, keys, credentials | environment names, feature flags |

Masking is literal substring replacement. It will not save you from a secret
that gets base64-encoded, split across lines, or written into an artifact.
Treat it as a safety net, not a control.

**Secrets are not available to workflows triggered by `pull_request` from a
fork.** That is deliberate — otherwise anyone could open a PR that prints your
tokens. If a fork PR needs them, that is what `pull_request_target` is for, and
it needs careful handling because it runs *your* workflow file against *their*
code.

## Status functions

| Function | Runs when |
|---|---|
| `success()` | default — everything before it passed |
| `failure()` | something before it failed |
| `always()` | no matter what, including cancellation |
| `cancelled()` | the run was cancelled |

`if: always()` is how you get logs and artifacts off a failed run. `if:
failure()` is how you report a failure without also running on every success.

## Inputs

`workflow_dispatch.inputs` turns the Run workflow button into a small form.
They are only present on manual runs, so supply a fallback:

```yaml
r-version: ${{ inputs.r_version || 'release' }}
```

On a scheduled run `inputs.r_version` is empty and `|| 'release'` fills in.

## Break it

1. **Run it manually** and pick `oldrel-1` from the dropdown. Confirm in the
   log that the input took effect.

2. **Set a `DEMO_API_KEY` secret** to something recognisable and re-run. The
   step echoes it — and you get `***`.

3. **Push twice in quick succession.** The first run is cancelled by
   `concurrency`.

4. **Change `if: failure()` to `if: always()`** on the issue-creating step.
   Now every nightly opens an issue. Change it back.

## Next

[The final form](08-final-form.md)
