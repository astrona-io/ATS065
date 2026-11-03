---
estimated_duration: 30m
---

# Lab: Declare The Desired State In Git

Graded lab for Section 010. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The cluster starts with Argo CD, a Git server and the repository `scout-deploy`. The staging overlay declares one replica. The task is to deliver `overlays/staging` with an `Application` and to declare two replicas and a memory limit in Git instead of on the live Deployment. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-065-lab-010-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-application.sh` | Application scout-staging reads overlays/staging on main with automated sync and prune |
| `validate-live-matches-git.sh` | The live Deployment has 2 replicas and a 64Mi memory limit that come from Git |
| `validate-delivered.sh` | Application is Synced and Healthy with 2 ready replicas |
