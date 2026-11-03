---
estimated_duration: 30m
---

# Lab: Fix A Synced But Degraded Application

Graded lab for Section 040. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The Application is Synced but not Healthy because Git names an image tag that does not exist. The task is to fix it in Git, order a ConfigMap with a sync wave and add a retry policy. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-065-lab-040-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-fixed-in-git.sh` | The fix came from Git and the Application is Synced and Healthy |
| `validate-sync-wave.sh` | The ConfigMap has sync wave -1 live and in Git |
| `validate-retry.sh` | The retry policy has limit 5 and the required backoff |
