---
draft: true
exam_objectives:
  - Declarative
---
# Declarative Formats, Idempotence And Apply Semantics

A declaration only works when the system that reads it behaves the same way every time. This module looks at the Kubernetes API as a declarative interface, at the difference between the commands that create, apply and replace an object, at server-side apply and field ownership, and at Helm and Kustomize as the tools that turn a description into manifests. It then practises each idea in a playground.

## Learning Goals

- Tell the `spec` of an object from its `status` and explain who writes each.
- Explain why `kubectl apply` is idempotent and `kubectl create` is not.
- Describe what a field manager is and how server-side apply reports a conflict.
- Compare how Helm and Kustomize take inputs and how Argo CD renders a Helm chart.

## Before You Start

You should know the first module of this section: desired state, rendering and controllers. You should be able to read a Kubernetes manifest. The hands-on steps use a playground with a kind cluster, Argo CD, a Git repository, `kubectl` and `git`. Technical terms are defined where they first appear.

## Reading Order

1. Spec, Status And The Declarative API
2. Create, Apply, Replace And Idempotence
3. Server-Side Apply And Field Managers
4. Helm And Kustomize As Renderers
5. Summary

<!-- astrona:playground -->
