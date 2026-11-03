# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-020/module-02/labs/lab-01
```

## Step 1: Find the commit

Clone the repository and list the history of the production overlay with the changes of each commit:

```sh
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
git log -p --format='%H %an %s' -- overlays/production/kustomization.yaml
```

Two commits touch the file. The newer one is `Raise production replicas to 5`. Its patch changes `count: 2` to `count: 5`. The line before the patch holds the full commit id and the author name. The older commit created the file.

## Step 2: Record the commit in a ConfigMap

Put the id and the author in shell variables, so that you do not copy them by hand, and create the ConfigMap:

```sh
commit=$(git log --format=%H --grep='^Raise production replicas to 5' -n 1)
author=$(git log --format=%an -n 1 "$commit")
kubectl -n starfleet create configmap audit-report --from-literal=commit="$commit" --from-literal=author="$author"
```

## Step 3: Mark the commit with an annotated tag

An annotated tag is a Git object of its own with a tagger, a date and a message. Create it on the commit and push only the tag:

```sh
git tag -a replicas-incident "$commit" -m "Production replicas raised to 5"
git push origin replicas-incident
```

The push adds a tag and leaves the branch alone, so the history of `main` does not change. Run `astrona submit`: all three checks pass.
