---
draft: true
exam_objectives:
  - Pulled Automatically
---
# Hub And Agent Topologies

Where the agent runs decides what must be reachable, where credentials live and what fails together. This part compares the main topologies and the trade-offs of each, so that the choice for a platform can be justified.

## Standalone: one agent per cluster

Each cluster runs its own agent, for example its own Argo CD or its own Flux controllers. Each agent reads Git and applies to its own cluster through the in-cluster address.

The benefits are clear. The cluster needs only outbound access to Git. No credential for the cluster leaves it. A failure in one agent affects one cluster. This is the strict form of the pull principle.

The costs are operational. There are as many installations to upgrade as clusters. There is no single view of all applications unless an extra layer is added. Configuration for each agent has to be distributed, which is often done by a bootstrap step that points each cluster at a configuration repository.

## Hub and spoke: one central agent

A central Argo CD manages many clusters. It has one UI, one place for policy and one installation to upgrade. The cost, as the previous part showed, is that the hub holds credentials for every cluster and needs network access to every API server. A failure or compromise of the hub touches all clusters. Teams reduce the risk with narrow roles per cluster, private connectivity and tight access to the hub.

The hub also carries the load of all clusters: the number of applications and resources it watches grows with every cluster. Sharding the application controller across replicas spreads this load.

## Agent-based: a small agent in each cluster

A third pattern puts a small agent in each workload cluster, which connects out to a central control plane. The workload cluster needs only outbound connectivity, and the central plane gives the single view. The Argo CD agent project follows this pattern, and other platforms exist as well. Depending on the mode, the control plane or the agent holds the full set of applications. Check the documentation of the version in use before relying on a specific behavior.

## Flux

Flux is built as a per-cluster agent. A fleet is usually managed by one configuration repository with a folder per cluster. Each cluster has a `GitRepository` and a `Kustomization` that point at its own folder, which is created at bootstrap by `flux bootstrap`. The common repository structure holds clusters, infrastructure and apps as separate folders, so a change to an application can be rolled out cluster by cluster by changing which clusters include it.

## Choosing

| Question | Standalone | Hub | Agent-based |
| --- | --- | --- | --- |
| Credentials for each cluster kept centrally | No | Yes | No |
| Inbound access to the cluster API | Not needed | Needed from the hub | Not needed |
| Single view of all clusters | Needs an extra layer | Built in | Built in |
| Installations to upgrade | One per cluster | One | One central and many small |
| Blast radius of an agent failure | One cluster | All clusters | Depends on the mode |

The right choice depends on the network, on the number of clusters and on how much the security team accepts a central credential store.

## Try it: see what the agent needs to reach

<!-- astrona:playground:renew -->

The playground is a standalone topology: Argo CD runs in the cluster it manages. List what it needs to reach.

```sh
kubectl -n argocd get applications -o custom-columns=NAME:.metadata.name,REPO:.spec.source.repoURL,SERVER:.spec.destination.server
kubectl -n argocd get networkpolicy
```

Create an `Application` first if the first list is empty. The repository URL is the only outbound address, and the destination is the in-cluster address. The playground sets no network policy. In a hardened cluster, the policy for the agent would allow egress to the Git host and to the API server only.

## What you know now

Standalone agents keep credentials inside each cluster and cost more to operate. A hub gives a single view and holds credentials for every cluster. An agent-based design needs only outbound connections and adds a control plane. Flux is per-cluster by design. The choice trades operational effort against blast radius and network access.

## Common pitfalls

> [!WARNING]
> A central controller that can write to every cluster is also a path for an attacker to every cluster. Plan access to the hub as access to the whole fleet.
