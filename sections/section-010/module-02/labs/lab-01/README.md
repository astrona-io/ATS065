---
estimated_duration: 30m
---

# Lab: Render A Helm Chart From Declared Values

Graded lab for Section 010. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The repository holds a Helm chart with default values. The task is to deliver it to staging with different values that live on the Argo CD `Application`, not in the chart. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-065-lab-010-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-application.sh` | The Application renders charts/scout from main with automated sync and prune |
| `validate-values.sh` | The three Helm values are declared on the Application and the chart default is unchanged |
| `validate-delivered.sh` | Synced, Healthy, 2 ready replicas, image 6.15.0 and the declared message |
