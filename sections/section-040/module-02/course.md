---
draft: true
exam_objectives:
  - Continuously Reconciled
---
# Health, Sync Status And Feedback Loops

A reconciliation loop is only useful if it reports what it finds. This module covers the two statuses an `Application` reports and what each one means, how sync phases, waves and hooks order a sync, how failed syncs are retried, and how to observe the loop with conditions, events, metrics and notifications. It then practises these in a playground.

## Learning Goals

- Explain the difference between sync status and health status and read both.
- Order resources and run jobs around a sync with waves and hooks.
- Configure a retry policy with backoff and say when automated sync does not retry.
- Find the cause of a failure in the conditions, events, logs and metrics.

## Before You Start

You should know the first module of this section: drift, refresh, automated sync, self-heal and prune. The hands-on steps use a playground with a kind cluster, Argo CD, a Git repository, `kubectl` and `git`. Technical terms are defined where they first appear.

## Reading Order

1. Sync Status And Health Status
2. Sync Phases, Waves And Hooks
3. Retries And Failed Syncs
4. Observing Reconciliation
5. Summary

<!-- astrona:playground -->
