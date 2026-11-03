---
estimated_duration: 25m
---

# Lab: Add A Production Environment From The Shared Base

Graded lab for Section 010. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The staging environment is delivered. The task is to add production from the shared base with an overlay patch and a second Application. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-010/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-010/module-03/labs/lab-01
astrona destroy ats-065-lab-010-03
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-layout.sh` | The base is unchanged and the production overlay sets its own message through a patch |
| `validate-production-app.sh` | The Application scout-production delivers overlays/production with automated sync |
| `validate-delivered.sh` | Production runs 2 replicas with the message production and staging is unchanged |
