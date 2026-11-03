---
draft: true
exam_objectives:
  - Declarative
---
# Bases, Overlays And Reducing Duplication

Copying a manifest for each environment works until the first change that must reach all copies. This part explains how a base and overlays keep one definition of what is common and a small file for what differs, and how to choose between the kinds of patch.

## Base and overlay

A **base** holds the manifests that every environment shares. An **overlay** names the base and then states changes. In Kustomize the overlay is a `kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: starfleet-production
resources:
  - ../../base
labels:
  - pairs:
      environment: production
images:
  - name: ghcr.io/stefanprodan/podinfo
    newTag: 6.15.0
replicas:
  - name: scout
    count: 2
```

The `namespace` field sets the namespace on every object. The `labels` field adds labels. The `images` field changes the tag of one image everywhere. The `replicas` field sets the replica count of a named workload. These built-in transformers cover most differences without writing a patch.

## Patches

A difference that the built-in fields do not cover is written as a patch. Kustomize supports two kinds.

A **strategic merge patch** is a partial manifest of the same kind and name. Kustomize merges it into the matching object, using the known structure of the type to merge lists such as containers by name:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
spec:
  template:
    spec:
      containers:
        - name: scout
          env:
            - name: PODINFO_UI_MESSAGE
              value: production
```

A **JSON 6902 patch** is a list of operations (`add`, `replace`, `remove`) on exact paths. It works for any object, including custom resources, and for removing a field, but it depends on positions in lists.

The overlay lists them under `patches`, with a path to the file or inline content.

## Helm values as overlays

In Helm the same idea uses values. A chart defines defaults in `values.yaml`, and an environment supplies the values that differ, in a file or in `helm.valuesObject` of the `Application`. The result is again one definition and a small per-environment difference.

## How much to share

Sharing too little leaves copies that drift. Sharing too much makes the base full of options, and a reader must know several layers to understand one environment. A workable rule is that the base holds what is true in every environment, and an overlay is short enough to read in one screen. If an overlay grows large, the base is probably missing a concept.

## Check the render

The rendered result is what Argo CD applies, so read it. Run it locally with `kubectl kustomize overlays/production`. The output is the full set of manifests for that environment, which is easier to review than the overlay alone.

## Try it: render two environments and compare

<!-- astrona:playground:renew -->

```sh
git_clone
cd scout-deploy
kubectl kustomize overlays/staging > /tmp/staging.yaml
kubectl kustomize overlays/production > /tmp/production.yaml
diff /tmp/staging.yaml /tmp/production.yaml
```

The diff lists the namespace, the environment label and the replica count. These are the lines that the two overlays change. Now add a one-line change to the base, for example a new label under `labels` in `base/kustomization.yaml`, and render both again. Both outputs change with one edit, which is the benefit of a shared base.

## What you know now

A base holds the shared manifests and an overlay states the differences. Built-in transformers handle namespace, labels, images and replicas. Strategic merge patches and JSON 6902 patches cover the rest. A render shows the final manifests for review.

## Common pitfalls

> [!WARNING]
> A JSON 6902 patch addresses list items by position. Inserting a new item before the target silently changes what the patch edits. Prefer a strategic merge patch for lists of named items.
