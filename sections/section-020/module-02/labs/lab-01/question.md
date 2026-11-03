# Question

Solve this question on: `terminal`

The repository `scout-deploy` (branch `main`) at `http://127.0.0.1:3000/starfleet/scout-deploy.git` holds five commits. Production load rose last week and the on-call team needs a record of who raised the production replica count to 5 and in which commit. The Git user is `platform` with the password `starfleet-gitops`.

Use the Git history to find the commit that changed the replica count of the production overlay to 5. Record it in a ConfigMap, and mark it with an annotated tag so that it is easy to find again. Do not rewrite the history and do not change any file.

When you finish, these must be true:

- **Report**: the ConfigMap `audit-report` in the namespace `starfleet` has the key `commit` with the full 40-character commit id of that commit, and the key `author` with the name of its author.
- **Tag**: the annotated tag `replicas-incident` exists in the repository and points at that commit.
- **History**: `main` still has its five commits in the original order. You did not force push.

Check your work with `astrona submit`.
