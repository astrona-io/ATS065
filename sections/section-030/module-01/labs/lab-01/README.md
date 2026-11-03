---
estimated_duration: 30m
---

# Lab: Pull From A Private Repository

Graded lab for Section 030. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The cluster starts with Argo CD and a private repository that only a read-only user can clone with a password. The task is to give Argo CD that read-only credential, create the `Application` and prove that a Git change reaches the cluster by being pulled. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-030/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-065-lab-030-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-repository-secret.sh` | A repository Secret for the private repository uses the read-only user argocd-reader |
| `validate-application.sh` | Application scout-staging pulls overlays/staging from main with automated sync |
| `validate-pulled-change.sh` | The new message was committed to Git and pulled: scout serves pulled and Argo CD applied the newest commit |
