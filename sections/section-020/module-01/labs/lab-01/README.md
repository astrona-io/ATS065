---
estimated_duration: 30m
---

# Lab: Roll Back With A Revert Commit

Graded lab for Section 020. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The cluster starts with Argo CD, a Git server and an `Application` that tracks `main`. The newest commit sets a container image that does not exist, so the rollout is stuck. The task is to restore the working state with a commit that keeps the history. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-065-lab-020-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-application-tracks-main.sh` | The Application still follows main with automated sync |
| `validate-rolled-back.sh` | scout runs podinfo 6.15.0 again and the Application is Synced and Healthy |
| `validate-history-retained.sh` | The bad commit is still in the history and the newest commit is a revert |
