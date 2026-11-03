---
estimated_duration: 25m
---

# Lab: Generate The Environment Applications With An ApplicationSet

Graded lab for Section 040. **Status: UNTESTED.** It was built without booting the lab; run `astrona test -c .` before relying on it.

No Application exists at the start. The task is to generate the staging and production applications from one ApplicationSet. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-040/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-040/module-03/labs/lab-01
astrona destroy ats-065-lab-040-03
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

The Git server is plumbing: it only gives Argo CD a repository to pull from. Port 8080 serves the Argo CD web page and port 3000 serves the Git server. The Git user `platform` (password `starfleet-gitops`) can write to the repository.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-applicationset.sh` | The ApplicationSet scout uses a list generator with staging and production |
| `validate-applications.sh` | The generated Applications use automated sync with prune, self-heal, CreateNamespace and PruneLast |
| `validate-delivered.sh` | Each environment answers with its own message and the Applications are owned by the set |
