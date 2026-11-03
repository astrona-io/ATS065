---
draft: true
exam_objectives:
  - Pulled Automatically
---
# The In-Cluster Agent And Pull Mechanics

Pulled delivery needs software that runs next to the cluster and reads the desired state from Git. This module looks at that software: the components of Argo CD and what each one does, the Flux controllers that do the same job, which direction network connections go, and what the agent is allowed to do in the cluster. It then practises these in a playground.

## Learning Goals

- Name the Argo CD components and say what each one does in one sync.
- Name the Flux controllers and map them to the Argo CD components.
- Explain which connections the agent opens and why no cluster credentials need to leave the cluster.
- Read the permissions of the agent with Kubernetes RBAC commands and describe how to limit them.

## Before You Start

You should know the first module of this section: push versus pull, repository credentials and webhooks. You should know what a Deployment, a StatefulSet, a service account and a Role are. The hands-on steps use a playground with a kind cluster, Argo CD, a Git repository and `kubectl`. Technical terms are defined where they first appear.

## Reading Order

1. Argo CD Components
2. Flux Controllers And The Comparison
3. Network Direction And Cluster Credentials
4. The Permissions Of The Agent
5. Summary

<!-- astrona:playground -->
