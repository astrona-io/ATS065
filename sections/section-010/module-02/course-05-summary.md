---
draft: true
exam_objectives:
  - Declarative
---
# Summary

A Kubernetes object keeps two halves. The `spec` is the declaration, written by a user or a tool. The `status` is the observation, written by the controller of that type. A manifest in Git holds only the `spec`, and the generation and observed generation numbers show whether a controller has handled the latest change.

`kubectl create` fails when the object exists, and `kubectl replace` overwrites the whole object. `kubectl apply` merges a file into the live object and is idempotent: a second run with the same file changes nothing. Client-side apply stores the last applied file in an annotation and makes a three-way merge, so a field that the file does not name is left alone. `kubectl diff` and a server-side dry run show the result before it is written.

Server-side apply records an owner for every field in `managedFields`. A write that would take a field from another manager fails with a conflict. The writer can drop the field from its file or force the conflict. Argo CD uses server-side apply with the sync option `ServerSideApply=true`, and it helps for large objects and shared fields.

Helm fills templates from values, and Kustomize patches plain manifests. Argo CD renders both in its repository server and applies the output itself, so no Helm release exists in the cluster. The render is repeatable only when the chart version, the dependency versions and the remote bases are pinned.

Key facts:

- Idempotence is what lets a controller apply the same state again and again.
- Several controllers on one object need field ownership.
- `helm template` is read-only and shows what Argo CD will apply.

<!-- astrona:playground:destroy -->
