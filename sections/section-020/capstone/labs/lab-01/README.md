---
estimated_duration: 60m
---

# Lab: Capstone: Promote A Release By Tag

Capstone lab for Section 020. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The repository has a branch `main` with a newer release and two tags. The task is to run staging from `main`, pin production to a tag, then promote production to the next tag by a Git change. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-065-capstone-020
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-applications.sh` | staging follows main, production is pinned to the tag v1.2.0, both have automated sync |
| `validate-tag-promoted.sh` | The tag v1.2.0 exists on the commit Release 1.2 and production applied that exact commit |
| `validate-environments-served.sh` | Both environments are Synced, Healthy and serve release 1.2 on podinfo 6.15.0 |
