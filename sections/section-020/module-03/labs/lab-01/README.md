---
estimated_duration: 25m
---

# Lab: Roll Back A Bad Release With A Revert

Graded lab for Section 020. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The last release on main is bad. The task is to roll back through Git without rewriting history and to mark the restored commit. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-020/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-020/module-03/labs/lab-01
astrona destroy ats-065-lab-020-03
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-history.sh` | The earlier commits are still on main and the head is a new commit |
| `validate-restored.sh` | The Application is Synced and Healthy on the image 6.15.0 |
| `validate-tag.sh` | The annotated tag known-good points at the head commit |
