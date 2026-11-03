---
draft: true
exam_objectives:
  - Pulled Automatically
---
# Repository Credentials

The `scout` manifests live in a private repository. Argo CD can only render them if it can clone the repository, and the Git server allows that only with a credential. This part explains how Argo CD stores and uses a repository credential, which rights it should have, and how to tell a credential failure from other failures.

## Two kinds of access

Argo CD needs two separate kinds of access. **Source access** is the right to read the repository. **Target access** is the right to change a cluster. They are independent: Argo CD can read a repository and be unable to apply, and it can have broad cluster rights and fail to read the source.

Each kind has its own credential and its own place where it is stored. Source access is configured as a repository entry. Target access, for the cluster that Argo CD runs in, is the Kubernetes service account of its own controller. For other clusters it is a cluster entry. This part covers source access.

## How Argo CD stores a repository credential

Argo CD reads its repository configuration from Kubernetes Secrets in its own namespace. A Secret with the label `argocd.argoproj.io/secret-type: repository` describes one repository. It carries these fields in its data: `type`, which is `git` for a Git repository, `url`, and the credential, for example `username` and `password` for HTTPS, or `sshPrivateKey` for SSH.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: repo-scout-deploy
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  username: argocd-reader
  password: reader-pass-1
```

The `stringData` field accepts plain text that Kubernetes stores base64-encoded in `data`. Base64 is an encoding and not encryption: anyone who can read Secrets in the `argocd` namespace can read the password. Access to that namespace is therefore access to every repository credential.

An `Application` does not name the Secret. It names the repository by `spec.source.repoURL`. The repository server looks for an entry with a matching URL and uses its credential. If no entry matches, the repository server tries an anonymous clone, which works for a public repository and fails for a private one.

## Credential templates

An organisation with many repositories under one URL prefix does not want one Secret for each. A Secret with the label `argocd.argoproj.io/secret-type: repo-creds` is a **credential template**. Its `url` is a prefix such as `http://gitea-http.gitea.svc:3000/starfleet`, and every repository whose URL starts with the prefix uses its credential. A repository entry with its own credential takes precedence.

## What rights the credential needs

The repository server only reads: it clones and fetches. A read-only credential is enough. With a deploy key or a service user that has only read permission, a leak of the Argo CD secret does not let an attacker change the repository, and so does not let them change what the cluster runs.

The credential should also be limited in scope. A personal account of a team member breaks when the person leaves, and it has access to more repositories than Argo CD needs. A dedicated user or deploy key, limited to the repositories that the platform delivers, keeps the rights small and the audit clear.

Credentials expire or get rotated. When a token expires, the repository server can no longer fetch. Argo CD keeps the last state it applied, the workload keeps running, and the `Application` shows an error until a new credential is stored.

## Telling failures apart

Three layers can fail between a commit and a running pod. The Git server can be unreachable. The credential can be missing, wrong or expired. The `Application` can point at a path or revision that does not exist. The condition of the `Application` shows which one by its message. An authentication failure mentions that authentication is required or has failed. A network failure mentions a connection error or a timeout. A bad path mentions that the path does not exist.

```mermaid
flowchart TB
    A["Application: comparison error"] --> Q1{"Message mentions authentication?"}
    Q1 -->|"yes"| C["Fix the repository credential"]
    Q1 -->|"no"| Q2{"Message mentions connection or timeout?"}
    Q2 -->|"yes"| N["Fix the Git server or the network"]
    Q2 -->|"no"| P["Check path, revision and rendering"]
```

Reading the condition before changing anything avoids a common mistake: rotating a credential when the real problem is a mistyped path.

## Try it: fail first, then give read access

The repository is private and no credential exists. Create the `Application` first and read what happens. Save this as `application-scout-staging.yaml`:

<!-- astrona:playground:renew -->

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: scout-staging
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
    targetRevision: main
    path: overlays/staging
  destination:
    server: https://kubernetes.default.svc
    namespace: starfleet-staging
  syncPolicy:
    automated: {}
    syncOptions:
      - CreateNamespace=true
```

```sh
kubectl apply -f application-scout-staging.yaml
app_refresh scout-staging
kubectl -n argocd get application scout-staging -o jsonpath='{.status.conditions[*].type}{"\n"}{.status.conditions[*].message}{"\n"}'
```

The type is `ComparisonError` and the message says that the repository could not be read because authentication is required. No workload was created. Now give Argo CD the read-only credential. Save this as `secret-repo-scout-deploy.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: repo-scout-deploy
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: http://gitea-http.gitea.svc:3000/starfleet/scout-deploy.git
  username: argocd-reader
  password: reader-pass-1
```

```sh
kubectl apply -f secret-repo-scout-deploy.yaml
app_refresh scout-staging
app_status
```

The `Application` reaches `Synced` and `Healthy`. The user `argocd-reader` can clone the repository and cannot push to it. Prove that with a push attempt using the same credential from your machine:

```sh
git clone http://argocd-reader:reader-pass-1@127.0.0.1:3000/starfleet/scout-deploy.git reader-clone
cd reader-clone
git commit --allow-empty -m "Should be refused"
git push origin main
```

The clone works and the push is refused. Last, break the credential on purpose. Change the password in the Secret and read the condition:

```sh
kubectl -n argocd patch secret repo-scout-deploy --type merge -p '{"stringData":{"password":"wrong"}}'
app_refresh scout-staging
kubectl -n argocd get application scout-staging -o jsonpath='{.status.conditions[*].message}{"\n"}'
kubectl -n starfleet-staging get deployment scout
```

The condition shows an authentication error again. The Deployment is still there and still running, because a failed read does not change the cluster. Restore the right password with the same command and the original value.

## Common pitfalls

> [!WARNING]
> Base64 in a Secret is not encryption, so access to the `argocd` namespace is access to every repository credential. Give Argo CD a dedicated read-only credential, and read the `Application` condition before you rotate anything: a bad path and a bad password look alike from far away.
