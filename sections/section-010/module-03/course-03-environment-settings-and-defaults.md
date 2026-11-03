---
draft: true
exam_objectives:
  - Declarative
---
# Environment Settings And Defaults

An environment differs in settings: a message, a replica count, a feature switch. Where those settings are written decides whether a reviewer can see them. This part explains how to write settings so they are explicit, how a change in a setting reaches the pods, and which value wins when two places set the same variable.

## Write the setting down

A setting that is not in the repository comes from somewhere else: a default in the container image, a default in the API server, or a value someone set by hand. The repository then does not describe the deployment fully. The rule from the first module applies: a missing value takes a platform default that the repository does not show.

For settings that matter, write the value in the overlay, even if it equals the default. A reviewer can then see it and a change shows up as a diff.

## Two ways to pass a setting to a container

A container reads settings from environment variables. They can be set directly with `env`, or as a group from a ConfigMap with `envFrom`. If the same variable name is set in both, the value in `env` wins over the value from `envFrom`. This is how an overlay can override a default from the base ConfigMap with a small patch.

## A change in a ConfigMap does not restart pods

Environment variables are read when a container starts. If a ConfigMap changes, running pods keep the old values until they restart. Kustomize offers `configMapGenerator`, which adds a hash of the content to the name of the generated ConfigMap and updates every reference to it. A change in content produces a new name, the Deployment template changes, and Kubernetes rolls out new pods.

```yaml
configMapGenerator:
  - name: scout-settings
    literals:
      - PODINFO_UI_MESSAGE=production
```

With a generated ConfigMap, the setting and the rollout are one change in Git.

## Secrets are references

A secret value must not be committed in plain form. The declaration holds a reference: the name of a Secret that exists in the cluster, or an encrypted object that a controller decrypts. The way to encrypt values is a topic of the versioning section. For this module, the point is that the declaration names the Secret and the Deployment reads it with `secretKeyRef`, so the layout stays the same for every environment.

## Defaults in the tools

The tools add defaults too. Kubernetes fills fields such as `strategy` and `revisionHistoryLimit` when they are missing. Argo CD compares the desired state with the live object and knows common defaulted fields, but for custom resources a default added by a controller can show as a difference. The remedy is to write the field explicitly or to add a narrow ignore rule.

## Try it: override a setting with an overlay patch

<!-- astrona:playground:renew -->

```sh
git_clone
cd scout-deploy
cat overlays/staging/message.yaml
sed -i.bak 's/value: staging/value: staging-from-overlay/' overlays/staging/message.yaml
rm overlays/staging/message.yaml.bak
kubectl kustomize overlays/staging | grep -A1 PODINFO_UI_MESSAGE
```

The overlay file `message.yaml` is a strategic merge patch that sets the variable in `env`. The render shows the new value. The base ConfigMap sets the same variable through `envFrom`. Commit and push, create the `Application` for the staging overlay and request the service:

```sh
git add -A && git commit -m "Set the staging message in the overlay" && git push origin main
kubectl -n starfleet exec deploy/shuttle -- curl -s http://scout.starfleet-staging/
```

The service answers with `staging-from-overlay`, because `env` wins over the ConfigMap that supplies the same variable through `envFrom`.

## What you know now

Settings that matter should be written in the overlay. `env` wins over `envFrom`. A changed ConfigMap needs a pod restart, and a generated ConfigMap with a hash suffix makes the restart part of the change. Secrets appear in the declaration only as references.

## Common pitfalls

> [!WARNING]
> Editing a ConfigMap that pods consume as environment variables does not change running pods. If the change must take effect, make the Deployment template change as well.
