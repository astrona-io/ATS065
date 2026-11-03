---
draft: true
exam_objectives:
  - Continuously Reconciled
---
# Drift, Refresh And Reconciliation

Deploying once is not enough: the cluster changes after the deployment, and the agent must keep the two states aligned. This module explains drift, the difference between a refresh and a sync, the automated sync policy with self-heal and prune, ignore rules for fields that another controller owns, and the patterns that manage many applications from Git. It then practises each idea with Argo CD in a playground.

## Learning Goals

- Define drift and read the sync and health status of an `Application`.
- Distinguish a refresh from a sync and automated sync from self-heal and prune.
- Write a narrow ignore rule and explain why `RespectIgnoreDifferences` matters.
- Describe app-of-apps and ApplicationSet, and diagnose a failure layer by layer.

## Before You Start

You should know what an `Application`, a Deployment and a commit are. The hands-on steps use a playground with a kind cluster, Argo CD, a Git repository, `kubectl` and `git`. Technical terms are defined where they first appear.

## Reading Order

1. Drift And Refresh
2. Automated Sync, Self-Heal And Prune
3. Ignore Rules And Reconciliation Patterns
4. Summary

<!-- astrona:playground -->
