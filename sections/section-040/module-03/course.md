---
draft: true
exam_objectives:
  - Continuously Reconciled
---
# Reconciliation At Scale

One `Application` per environment is easy to write by hand. A fleet of clusters, teams and environments is not. This module covers how to generate `Application` objects from data, how to bootstrap a whole system from one root, how to keep the reconcile load of the controller under control, and how to roll a change across environments in order.

## Learning Goals

- Generate `Application` objects with an `ApplicationSet` and a generator.
- Build a bootstrap tree with the app-of-apps pattern.
- Explain what drives the load of the application controller and how sharding and refresh settings change it.
- Describe progressive rollout across environments and the status of the feature.

## Before You Start

You should know the first two modules of this section: drift, sync policies, prune, self-heal, health, hooks and waves. The hands-on steps use a playground with a kind cluster, Argo CD, a Git repository, `kubectl` and `git`. Technical terms are defined where they first appear.

## Reading Order

1. ApplicationSets And Generators
2. App Of Apps And Bootstrapping
3. Controlling Reconciliation Load
4. Progressive Rollouts Across Environments
5. Summary

<!-- astrona:playground -->
