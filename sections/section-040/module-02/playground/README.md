# Health, Hooks And Feedback - Playground

- **ID:** PLAYGROUND
- **Slug:** ats-065-playground-040-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading
- **Status:** built untested (never booted by the author)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with Argo CD 3.5.4, a Git server inside the cluster (plumbing only) and the example workload `shuttle` in `starfleet`. The repository `scout-deploy` is already pushed. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-065-playground-040-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, port forwards, preloaded images, bootstrap) |
| `bootstrap/` | Plumbing scripts: Git server, Argo CD and the repository seed |
| `manifests/` | The Git server and the `shuttle` client |
| `repos/` | The content that is pushed to the repository |
| `docs/overview.md` | What the environment contains and ideas to try |
