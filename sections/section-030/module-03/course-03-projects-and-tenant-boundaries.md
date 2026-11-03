---
draft: true
exam_objectives:
  - Pulled Automatically
---
# Projects And Tenant Boundaries

When several teams share one Argo CD, each must be able to deploy its own applications and nothing else. An `AppProject` sets those boundaries. This part explains what a project controls, which defaults are open, and how to write a restrictive project.

## What a project controls

An `AppProject` is a custom resource in the namespace `argocd`. Every `Application` belongs to exactly one project through `spec.project`. The project limits:

- the source repositories an `Application` may use, in `spec.sourceRepos`;
- the clusters and namespaces it may deploy to, in `spec.destinations`;
- the cluster-scoped kinds it may create, in `spec.clusterResourceWhitelist`;
- the namespaced kinds it may not create, in `spec.namespaceResourceBlacklist`, or may create only if listed, in `spec.namespaceResourceWhitelist`;
- sync windows, signature keys and roles for people.

## The default project

A fresh installation has a project named `default`. It allows every repository, every destination and every kind. It exists so that a first `Application` works, and it is not a tenant boundary. A shared installation should avoid the default project for real work and may restrict it.

## A restrictive project

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-scout
  namespace: argocd
spec:
  description: The scout team
  sourceRepos:
    - http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  destinations:
    - server: https://kubernetes.default.svc
      namespace: starfleet-staging
  clusterResourceWhitelist: []
```

The project allows one repository and one namespace on one cluster. An empty `clusterResourceWhitelist` means no cluster-scoped kind may be created, so the team cannot create namespaces, cluster roles or custom resource definitions through this project. Whitelists and blacklists for other kinds are optional.

An `Application` that violates the project is not synced. The condition on the `Application` names the reason, for example that the destination namespace is not permitted. The error appears in `status.conditions` as an `InvalidSpecError`.

## Projects are not isolation by themselves

A project checks what an `Application` asks for. It does not isolate the workloads in the cluster. Two teams with different projects can still run in the same cluster, so Kubernetes controls are also needed: namespaces, resource quotas, network policies and pod security settings. The project controls the delivery path and the cluster controls the runtime.

Who can create `Application` and `AppProject` objects matters too. If a team can create an `AppProject`, it can widen its own limits. Only platform administrators should create projects, and teams should be allowed to create applications only in their project. Argo CD roles in `spec.roles` and the RBAC policy of the installation are the tools for that.

## ApplicationSet and projects

An `ApplicationSet` generates `Application` objects and can set their project. The controller applies the same project limits to the generated objects, but the template could name another project. Restrict who may create `ApplicationSet` objects as strictly as projects.

## Try it: move an application into a restrictive project

<!-- astrona:playground:renew -->

Create an `Application` named `scout-staging` for the staging overlay in the project `default`. Then create the project from the manifest above:

```sh
kubectl apply -f - <<'Y'
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-scout
  namespace: argocd
spec:
  description: The scout team
  sourceRepos:
    - http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  destinations:
    - server: https://kubernetes.default.svc
      namespace: starfleet-staging
  clusterResourceWhitelist: []
Y
kubectl -n argocd patch application scout-staging --type merge -p '{"spec":{"project":"team-scout"}}'
app_status
```

The `Application` stays `Synced` because it asks for allowed things. Now point its destination to another namespace:

```sh
kubectl -n argocd patch application scout-staging --type merge -p '{"spec":{"destination":{"namespace":"starfleet-production"}}}'
kubectl -n argocd get application scout-staging -o jsonpath='{range .status.conditions[*]}{.type}: {.message}{"\n"}{end}'
```

The condition reports that the namespace is not permitted in the project. Patch the namespace back to `starfleet-staging`.

## What you know now

A project limits repositories, destinations and resource kinds for the applications that belong to it. The default project is open and should not be used as a boundary. An empty cluster resource whitelist blocks cluster-scoped kinds. Projects govern delivery, and Kubernetes controls govern runtime, so both are needed.

## Common pitfalls

> [!WARNING]
> A tenant who can edit the `AppProject` of its own applications can remove the limits. Keep project creation and changes with the platform team.
