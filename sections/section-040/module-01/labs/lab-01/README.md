---
estimated_duration: 30m
---

# Lab: Self-Heal With A Narrow Ignore Rule

Graded lab for Section 040. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The cluster starts with a synced `Application` that someone changed by hand: the image is wrong and the replica count was raised on purpose by another controller. The task is to make Argo CD revert the image and leave the replica count alone. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-065-lab-040-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-sync-policy.sh` | Automated sync has prune and selfHeal, and RespectIgnoreDifferences is set |
| `validate-ignore-narrow.sh` | One ignore rule covers only /spec/replicas of the Deployment scout |
| `validate-drift-handled.sh` | The manual image change is reverted and the 3 replicas are kept |
