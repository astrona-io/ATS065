---
draft: true
exam_objectives:
  - Versioned and Immutable
---
# Versions, References And Promotion

GitOps treats the history of desired state as a first-class record. This module explains what a Git commit identifies, how branches and tags point at commits, how to pin and roll back a deployment, and how a release moves from one environment to the next. It then practises each idea with Argo CD in a playground.

## Learning Goals

- Explain what a commit identifies and how a branch and a tag differ from it.
- Pin an `Application` to a version and read which commit Argo CD actually evaluated.
- Roll back with a change that keeps the history and explain why rewriting history is a different operation.
- Describe promotion of one release through environments and the limits of immutable history.

## Before You Start

You should know what a Git commit, a branch and a tag are, and how `git log` and `git push` work. The hands-on steps use a playground with a kind cluster, Argo CD, a Git repository, `kubectl` and `git`. Technical terms are defined where they first appear.

## Reading Order

1. Commits, Branches And Tags
2. Pinning, Rollback And Audit
3. Promotion, Immutable Artifacts And Secrets
4. Keeping The History Safe
5. Summary

<!-- astrona:playground -->
