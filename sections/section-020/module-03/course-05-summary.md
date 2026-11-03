---
draft: true
exam_objectives:
  - Versioned and Immutable
---
# Summary

A version has a name for people and an identifier for tools. Semantic versioning and calendar versioning are conventions that the tools do not check. Commit IDs and image digests are content identifiers that cannot move, while registry tags and Git tags can. A Helm chart has a chart version and an application version. A deployment should record the repository revision, the image digest and the chart version.

A release is a build followed by a commit in the configuration repository. The image is built once and its reference is promoted from one environment to the next. The pipeline writes only to the configuration repository, and the agent holds the cluster credentials. The build checks the code, the pull request checks the deployment and the environment checks the result.

Image update automation watches a registry and writes new versions into Git. Flux uses `ImageRepository`, `ImagePolicy` and `ImageUpdateAutomation`. Argo CD Image Updater is a separate component, and its Git write-back keeps the record in the repository. A rule with a version range is predictable, and a rule that follows `latest` is not.

A revert commit is the default rollback because it adds to the history and uses the normal path. A reset with a force push removes history. The rollback command of Argo CD works only with automated sync off and leaves Git unchanged. When the old version cannot run with new data, roll forward and design releases to be backward compatible.

Key facts:

- A name can be reused and a digest cannot.
- The pipeline never needs cluster credentials.
- A rollback that exists only in the cluster is undone by the next sync.
- A revert of a merge commit needs `-m`.

<!-- astrona:playground:destroy -->
