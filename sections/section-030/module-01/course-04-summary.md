---
draft: true
exam_objectives:
  - Pulled Automatically
---
# Summary

In a push model an outside system holds a credential for the cluster and applies once. In a pull model an agent that runs where the cluster is reads the repository itself and applies the difference, and it keeps doing so. The test for pull is who fetches the content and who holds the authority to change the cluster, not the direction of one network connection. A pipeline in this model writes to the repository and has no cluster credential.

Argo CD needs source access and target access as two separate things. A repository Secret with the label `argocd.argoproj.io/secret-type: repository` holds the URL and credential for one repository, and a `repo-creds` Secret is a template for a URL prefix. Base64 is not encryption, so access to the `argocd` namespace is access to every credential. The credential should be read-only and dedicated. The condition on the `Application` shows whether a failure is authentication, connection or path.

Argo CD polls on a timer, three minutes by default, and a webhook to `/api/webhook` shortens the delay by asking for a refresh. The webhook carries no desired state, so the model stays pull and a lost request costs only time. When the Git server is down, the cluster keeps its last state and Argo CD resumes at the next successful refresh, applying the newest revision.

Key facts:

- A refresh is a request for fresh comparison, and a hard refresh also drops caches.
- A webhook is a hint, and polling is the fallback.
- A failed read never changes the cluster.
- Desired state is the newest revision, so no missed commits are replayed.

<!-- astrona:playground:destroy -->
