---
estimated_duration: 60m
---

# Lab: Capstone: Bring Up The Cluster From One Parent Application

Capstone lab for Section 040. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The repository has an `apps` folder with three child `Application` manifests. The task is to create the parent `Application`, fix the child with a wrong path in Git and retire the obsolete child by removing its manifest. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-065-capstone-040
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-root-application.sh` | starfleet-root reads the apps folder with automated sync, prune and self-heal |
| `validate-children.sh` | scout-staging and scout-production were created by the parent and are Synced and Healthy |
| `validate-legacy-removed.sh` | scout-legacy was removed from Git and pruned |
