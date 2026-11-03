---
draft: true
exam_objectives:
  - Declarative
---
# Repository Layout And Environment Design

A declaration is only useful if people can find it, review it and reuse it across environments. This module covers how to lay out the repositories and folders that hold declared state, how bases and overlays remove duplication, how environment settings and defaults are written down, and how to check a declaration before it merges. It then practises the layout in a playground.

## Learning Goals

- Choose a repository and folder layout for several environments and explain the trade-offs.
- Use a base and overlays so that only the differences are written per environment.
- Write environment settings explicitly and know which value wins when two places set the same variable.
- Validate a declaration before merge with rendering, dry runs and diffs.

## Before You Start

You should know the first two modules of this section: declared state, rendering, controllers and apply semantics. The hands-on steps use a playground with a kind cluster, Argo CD, a Git repository, `kubectl` and `git`. Technical terms are defined where they first appear.

## Reading Order

1. Repository Structure And Environments
2. Bases, Overlays And Reducing Duplication
3. Environment Settings And Defaults
4. Validating Declarations Before Merge
5. Summary

<!-- astrona:playground -->
