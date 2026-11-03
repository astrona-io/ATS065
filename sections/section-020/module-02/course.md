---
draft: true
exam_objectives:
  - Versioned and Immutable
---
# Git History, Audit And Change Control

A versioned system is only as useful as the record it keeps. This module looks at what a Git commit stores, how to read that record to answer audit questions, how signatures prove who made a change, how review and branch protection control what reaches the branch that Argo CD follows, and what happens when someone rewrites history. It then practises these in a playground.

## Learning Goals

- Name the fields of a commit and use `git log`, `git show`, `git blame` and `git diff` to answer who, what and when.
- Explain what a signed commit or tag proves and where Argo CD and Flux can verify it.
- Describe how review, CODEOWNERS and branch protection limit changes to the tracked branch.
- Explain what a force push does to the audit record and to a running `Application`.

## Before You Start

You should know the first module of this section: commits, branches, tags, pinning and rollback. The hands-on steps use a playground with a kind cluster, Argo CD, a Git repository, `kubectl` and `git`. Technical terms are defined where they first appear.

## Reading Order

1. What The History Records
2. Signed Commits And Tag Verification
3. Review, CODEOWNERS And Branch Protection
4. Rewriting History
5. Summary

<!-- astrona:playground -->
