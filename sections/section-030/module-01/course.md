---
draft: true
exam_objectives:
  - Pulled Automatically
---
# Pull, Credentials And Webhooks

In GitOps the component that changes the cluster reads the desired state itself. This module explains what that means for credentials and network direction, how Argo CD authenticates to a private repository, and how it learns that a new commit exists. It then practises each idea with Argo CD in a playground.

## Learning Goals

- Contrast a pipeline that pushes changes into a cluster with an agent that pulls them.
- Give Argo CD read-only access to a private repository and read the error when access fails.
- Explain polling, webhooks and what happens during a Git server outage.
- Show that a change in Git reaches the cluster without anyone applying it.

## Before You Start

You should know what a Kubernetes Secret and a Service are, and what an HTTP request is. The hands-on steps use a playground with a kind cluster, Argo CD, a private Git repository, `kubectl` and `git`. Technical terms are defined where they first appear.

## Reading Order

1. Push Versus Pull
2. Repository Credentials
3. Polling, Webhooks And Outages
4. Verifying What Was Pulled
5. Summary

<!-- astrona:playground -->
