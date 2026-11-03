---
draft: true
exam_objectives:
  - Declarative
---
# Summary

A declarative description names the end state and leaves the steps to a program. An imperative script names actions, depends on what already exists and says nothing about what must stay true. Storing a script in Git adds history and review but does not make it declarative.

A declaration is sufficient when everything that decides behaviour is written in the repository or named as an accepted default. Rendering combines a base with overlays into the final manifests. It is a function of its inputs, so remote bases, chart dependency ranges and tool versions must be pinned for the output to stay the same. Argo CD renders in its repository server, and a render failure appears as a `ComparisonError` condition while the running workload stays unchanged.

A controller repeats one loop: read desired state, read actual state, act on the difference. Argo CD marks the objects it applies with the tracking annotation `argocd.argoproj.io/tracking-id` and compares only the objects it owns. Pruning deletes tracked objects that no longer have a manifest. It is off by default for automated sync and is refused for an empty render. Objects that hold data can opt out with `Prune=false`, and a field that two controllers write needs one owner.

Key facts:

- A repository of scripts is not a declaration.
- Missing values take platform defaults that the repository does not show.
- A failed render changes nothing in the cluster.
- A deleted `Application` leaves its workload unless the finalizer `resources-finalizer.argocd.argoproj.io` is set.

<!-- astrona:playground:destroy -->
