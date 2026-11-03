# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS065.git -c sections/section-040/module-02/labs/lab-01
```

## Step 1: Separate the two statuses

The sync status compares Git with the cluster. The health status asks whether the objects work. Read both and then read the pod:

```sh
kubectl -n argocd get application scout-staging -o jsonpath='{.status.sync.status} {.status.health.status}{"\n"}'
kubectl -n starfleet-staging get pods
kubectl -n starfleet-staging describe pod -l app=scout
```

The `Application` is `Synced` and `Progressing` or `Degraded`. The pod waits in `ErrImagePull` or `ImagePullBackOff`, and the events of the pod name the image tag `6.99.0`, which does not exist.

## Step 2: Fix the tag and the order in Git

Clone the repository and change the image tag in the staging overlay:

```sh
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
sed -i.orig 's/newTag: 6.99.0/newTag: 6.15.0/' overlays/staging/kustomization.yaml
```

A sync wave is a number in the annotation `argocd.argoproj.io/sync-wave`. Argo CD applies lower waves first and waits for them to be healthy. The default wave is 0, so wave `-1` runs before the Deployment. Replace `base/configmap.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: scout-settings
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
data:
  PODINFO_UI_MESSAGE: staging
```

Remove the backup file, then commit and push:

```sh
rm -f overlays/staging/kustomization.yaml.orig
git commit -am "Fix image tag and order the ConfigMap first"
git push origin main
```

## Step 3: Add the retry policy

```sh
kubectl -n argocd patch application scout-staging --type merge -p '{"spec":{"syncPolicy":{"retry":{"limit":5,"backoff":{"duration":"10s","factor":2,"maxDuration":"3m"}}}}}'
```

The patch is a merge, so `automated` stays in place.

## Step 4: Check the result

Ask for a refresh and wait for `Healthy`:

```sh
kubectl -n argocd annotate application scout-staging argocd.argoproj.io/refresh=hard --overwrite
kubectl -n argocd get application scout-staging
```

The `Application` becomes `Synced` and `Healthy`, and the Deployment has a ready pod. Run `astrona submit`: all three checks pass.
