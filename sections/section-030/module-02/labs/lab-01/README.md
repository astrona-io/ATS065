---
estimated_duration: 30m
---

# Lab: Read The Agent And Pull From Git

Graded lab for Section 030. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The task is to deliver staging by pull and to write a short report of what the Argo CD components do, read from the live cluster. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-065-lab-030-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-application.sh` | The Application pulls overlays/staging from main with automated sync |
| `validate-agent-report.sh` | The ConfigMap matches the real components and the real permission |
| `validate-delivered.sh` | Synced, Healthy and the service answers with the staging message |
