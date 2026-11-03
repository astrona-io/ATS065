---
draft: true
exam_objectives:
  - Versioned and Immutable
---
# Release Management And Rollback

A release is the act of moving a specific version into an environment. In GitOps that act is a commit. This module covers how versions are named, how a change travels from a build to the cluster, how tools update image references automatically, and how to roll back safely. It then practises a rollback in a playground.

## Learning Goals

- Choose a versioning scheme and say what each identifier points to.
- Describe the path of a release from a build to the declared state in Git.
- Explain how image update automation writes versions into Git.
- Roll back a bad release with a revert commit and know when rolling forward is safer.

## Before You Start

You should know the first two modules of this section: commits, branches, tags, pinning, promotion, history and audit. The hands-on steps use a playground with a kind cluster, Argo CD, a Git repository, `kubectl` and `git`. Technical terms are defined where they first appear.

## Reading Order

1. Versioning Schemes And Identifiers
2. From Build To Declared State
3. Image Update Automation
4. Rolling Back Safely
5. Summary

<!-- astrona:playground -->
