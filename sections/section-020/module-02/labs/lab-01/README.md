---
estimated_duration: 30m
---

# Lab: Audit A Change From The Git History

Graded lab for Section 020. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

The repository has five commits by three authors. The task is to find who raised the production replica count, record the commit in a ConfigMap and mark it with an annotated tag. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-065-lab-020-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-report.sh` | The ConfigMap holds the full commit id and the author name |
| `validate-tag.sh` | The annotated tag points at that commit |
| `validate-history.sh` | The five commits of main are unchanged and in order |
