---
estimated_duration: 20m
---

# Lab: Restrict A Team With An AppProject

Graded lab for Section 030. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The staging Application runs in the open default project. The task is to create a restrictive project and move the Application into it. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-030/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-030/module-03/labs/lab-01
astrona destroy ats-065-lab-030-03
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-project.sh` | The AppProject team-scout allows one repository, one destination and no cluster kinds |
| `validate-application.sh` | scout-staging belongs to team-scout and is Synced and Healthy |
| `validate-boundary.sh` | The project does not allow starfleet-production and the staging service still answers |
