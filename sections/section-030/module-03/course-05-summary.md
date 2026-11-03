---
draft: true
exam_objectives:
  - Pulled Automatically
---
# Summary

A destination names a cluster and a namespace. The in-cluster address needs no stored credential, and a remote cluster is registered with a Secret that carries the cluster label and a credential. That credential decides what Argo CD may change in the remote cluster. A central controller that reaches out to remote clusters still reads Git as the single source, but it holds credentials for every cluster and needs network access to their API servers.

Three topologies exist. Standalone agents keep credentials inside each cluster and need only outbound access to Git, at the cost of many installations. A hub gives a single view and concentrates credentials and load. An agent-based design places a small agent in each cluster that connects out to a control plane. Flux runs per cluster and often manages a fleet from one repository with a folder per cluster.

An `AppProject` limits source repositories, destinations and resource kinds for its applications. The default project allows everything and is not a boundary. An empty cluster resource whitelist blocks cluster-scoped kinds. A project controls delivery, and Kubernetes controls such as quotas, network policies and pod security control runtime. Only the platform team should create projects and `ApplicationSet` objects.

The agent applies what the source says, so the source needs protection: write access limited, the followed branch protected, read-only agent credentials, signature verification through `signatureKeys` or `spec.verify`, pinned references and verified connections. OCI artifacts are an immutable alternative to a Git source.

Key facts:

- Registering a cluster gives the agent the rights of the stored credential.
- The default project is not a tenant boundary.
- A signature proves who made the commit and not that it is correct.
- Turning off connection verification removes a pull-model protection.

<!-- astrona:playground:destroy -->
