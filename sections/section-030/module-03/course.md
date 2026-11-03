---
draft: true
exam_objectives:
  - Pulled Automatically
---
# Multi-Cluster Pull And Tenancy

One cluster with one team is the simple case. Real platforms run many clusters and many teams. This module covers how clusters are registered, which topologies exist for the agent, how projects limit what a team can deploy, and how to trust the source of the declared state. It then practises tenant boundaries in a playground.

## Learning Goals

- Explain how a cluster is registered with Argo CD and what the destination refers to.
- Compare standalone, hub and agent topologies and name the trade-offs.
- Limit a team with an `AppProject`: repositories, destinations and resource kinds.
- Describe how a pull-based agent can verify the source it pulls from.

## Before You Start

You should know the first two modules of this section: push versus pull, credentials, polling, webhooks and the components and permissions of the agent. The hands-on steps use a playground with a kind cluster, Argo CD, a Git repository, `kubectl` and `git`. Technical terms are defined where they first appear.

## Reading Order

1. Registering Clusters
2. Hub And Agent Topologies
3. Projects And Tenant Boundaries
4. Trusting The Source
5. Summary

<!-- astrona:playground -->
