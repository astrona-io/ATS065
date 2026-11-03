---
draft: true
exam_objectives:
  - Pulled Automatically
---
# Summary

Argo CD is several programs with separate jobs. The application controller compares desired and live state and applies the difference. The repository server clones Git and renders Helm, Kustomize or plain YAML. The API server handles people, the command line and webhooks, and Redis caches the state. A stopped repository server stops new comparisons while the workloads keep running. A stopped API server does not stop reconciliation.

Flux splits the same work into controllers. The source controller fetches Git and OCI sources, the kustomize controller applies a path and prunes, the helm controller runs Helm releases, and the notification controller sends alerts and receives webhooks. Both tools pull from Git and reconcile continuously. They differ in packaging and in how they model an application.

In a pull system the agent opens outbound connections to Git and talks to the Kubernetes API of its own cluster. The cluster API needs no inbound path from CI, and a webhook only hints that Git has changed, because the agent still pulls the manifests. The credentials are a read-only Git credential, none for the home cluster, and a stored token for every remote cluster that a central agent manages. One agent per cluster avoids storing those tokens.

The agent runs as a service account. The default cluster-wide Argo CD installation grants its controller a wildcard role, which makes the agent the ceiling of what any commit can do. A namespaced installation, projects, Flux impersonation with a service account and admission policy narrow that ceiling. The permissions can be read with `kubectl auth can-i` and the `--as` option.

Key facts:

- The repository server holds Git access, and the application controller holds cluster rights.
- A webhook carries no manifests.
- Read the permissions of the agent instead of assuming them.

<!-- astrona:playground:destroy -->
