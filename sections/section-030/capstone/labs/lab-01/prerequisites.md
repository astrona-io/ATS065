# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 3 GiB of free memory.
- `kubectl`, `git` and `jq`.
- You know the content of Section 030: pull-based delivery, credentials and webhooks.

The lab starts a single-node kind cluster (Kubernetes 1.35) with Argo CD 3.5.4, a Git server inside the cluster and the example workload `shuttle` in the namespace `starfleet`. Port 8080 (Argo CD) and port 3000 (Git server) on your machine must be free. The first start downloads several container images and takes a few minutes.
