# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-020/module-01/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `application-tracks-main`.

## Step 1: Find the bad commit

Read the state first. The `Application` is `Degraded` or `Progressing`, and the pod of `scout` is in `ImagePullBackOff` or `ErrImagePull`:

```sh
kubectl -n argocd get application scout-staging
kubectl -n starfleet-staging get pods
```

Clone the repository and read the history. The password for the user `platform` is `starfleet-gitops`:

```sh
git clone http://platform@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
git log --oneline
```

The log shows three commits. The newest, `Release 6.99.9`, is the bad one. The two tags `v1.0.0` and `v1.1.0` mark the earlier releases.

## Step 2: Revert it

A revert adds a new commit that undoes the changes of an earlier commit. The history only grows. Run it and push:

```sh
git revert --no-edit HEAD
git push origin main
```

Do not use `git reset` and `git push --force`: they rewrite history and the check `history-retained` fails.

## Step 3: Let Argo CD pull the fix

Argo CD checks the repository about every three minutes. To skip the wait, ask for a refresh:

```sh
kubectl -n argocd annotate application scout-staging argocd.argoproj.io/refresh=hard --overwrite
kubectl -n starfleet-staging rollout status deploy/scout
```

Then check the result:

```sh
kubectl -n argocd get application scout-staging
```

The `Application` is `Synced` and `Healthy`, and `scout` runs `ghcr.io/stefanprodan/podinfo:6.15.0`. Run `astrona submit`: all three checks pass.
