---
estimated_duration: 60m
---

# Lab: Capstone: Pull, Notify And Change Through Git

Capstone lab for Section 030. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The repository is private and has a read-only user. The task is to give Argo CD read access, deliver the production overlay, add a push webhook and raise the replica count by a Git commit. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-065-capstone-030
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-repository-secret.sh` | Argo CD reads the private repository with the read-only user argocd-reader |
| `validate-application.sh` | scout-production pulls overlays/production from main into the same cluster |
| `validate-webhook.sh` | The Git server has an active push webhook to the Argo CD webhook endpoint |
| `validate-pulled-change.sh` | Production runs 3 replicas from a Git commit that Argo CD pulled |
