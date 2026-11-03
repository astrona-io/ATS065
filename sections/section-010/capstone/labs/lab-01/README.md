---
estimated_duration: 60m
---

# Lab: Capstone: Deliver Two Environments From One Repository

Capstone lab for Section 010. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The repository declares `scout` for staging and production with a Kustomize base. The production overlay does not build and the base lists a ConfigMap that was retired. The task is to deliver both environments with Argo CD and fix the repository through Git. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-065-capstone-010
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-applications.sh` | Both Applications read their overlay from main with automated sync and prune, Synced and Healthy |
| `validate-production-intent.sh` | Production declares 3 replicas and the message production |
| `validate-legacy-pruned.sh` | legacy-banner is removed from Git and pruned from both namespaces |
