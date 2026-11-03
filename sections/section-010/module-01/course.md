---
draft: true
exam_objectives:
  - Declarative
---
# Declared State, Rendering And Controllers

GitOps starts with one idea: the system is described by what should exist, and a program makes it so. This module explains what a declaration is, how a source repository turns into the objects that run in a cluster, and which component owns which object. It then practises the three ideas with Argo CD in a playground.

## Learning Goals

- Tell a declarative description from an ordered list of commands.
- Explain what makes a declaration sufficient and how rendering turns it into concrete objects.
- Describe how a controller finds the objects it owns and what pruning removes.
- Deliver a Kustomize overlay with an Argo CD `Application` and read its status.

## Before You Start

You should know what a pod, a Deployment, a namespace and a Service are, and what a Git commit is. The hands-on steps use a playground with a kind cluster, Argo CD, a Git repository, `kubectl` and `git`. Technical terms are defined where they first appear.

## Reading Order

1. Desired State Versus Imperative Steps
2. Sufficient Intent And Rendering
3. Controllers, Ownership And Pruning
4. Where Imperative Steps Still Fit
5. Summary

<!-- astrona:playground -->
