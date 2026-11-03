# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-020/module-03/labs/lab-01
```

## Step 1: Find the bad release

```sh
kubectl -n argocd get application scout-staging -o jsonpath='{.status.sync.status} {.status.health.status}{"\n"}'
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
git log --oneline
```

The `Application` is `Synced` and not `Healthy`. The log shows three commits. The newest, `Upgrade scout to 6.99.0`, is the bad release: `git show HEAD` shows that it changed the image tag in the staging overlay to a tag that does not exist.

## Step 2: Revert it

A revert adds a new commit that undoes the change, so the history stays:

```sh
git revert --no-edit HEAD
git push origin main
```

The log now has four commits, and the newest one is the revert. The Deployment returns to the tag `6.15.0`.

## Step 3: Mark the known good commit

An annotated tag is a Git object with its own message:

```sh
git tag -a known-good -m "Restored after the 6.99.0 release"
git push origin known-good
```

## Step 4: Check the result

```sh
kubectl -n argocd annotate application scout-staging argocd.argoproj.io/refresh=hard --overwrite
kubectl -n argocd get application scout-staging
```

The `Application` becomes `Synced` and `Healthy`. Run `astrona submit`: all three checks pass.
