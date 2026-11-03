---
draft: true
exam_objectives:
  - Declarative
---
# Summary

A configuration repository holds the declared state of a deployment apart from the source code of the application. A monorepo and several repositories both work with Argo CD and Flux. A folder per environment on one branch lets a reader see the whole declared state at one commit, while a branch per environment tends to drift. Each environment is usually its own `Application`, with its own path, destination and sync policy.

A base holds the manifests that are common, and an overlay states the differences. Built-in transformers set the namespace, labels, images and replicas. Strategic merge patches and JSON 6902 patches cover other differences, and JSON 6902 depends on list positions. Helm values play the same role as overlays. A render of an overlay shows the manifests that the agent will apply.

Settings that matter should be written in the overlay so that a reviewer sees them. A variable set in `env` wins over the same variable from `envFrom`. Running pods do not see a changed ConfigMap until they restart, and a generated ConfigMap with a content hash in its name ties the restart to the change. Secrets appear in the declaration as references.

Four checks run before merge: rendering, schema validation, a server-side dry run and a diff. They catch mistakes while they are cheap to fix.

Key facts:

- Prefer folders over long-lived branches for environments.
- An overlay should be short enough to read in one screen.
- `env` wins over `envFrom`.
- Check the rendered output, not only the overlay.

<!-- astrona:playground:destroy -->
