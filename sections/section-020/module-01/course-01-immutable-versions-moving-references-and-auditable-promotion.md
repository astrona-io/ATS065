---
draft: true
exam_objectives:
- Versioned and Immutable
---
# Immutable Versions, Moving References And Auditable Promotion

Versioning gives desired state an identifiable history. Immutability means a particular identified version is not silently changed after it is recorded. Together these properties let reviewers, agents and operators refer to the same intended content. They support audit and recovery, but they require attention to the references and external inputs that the content uses.

A Git commit identifies a particular version, while a branch selects a commit and can advance. An agent following a branch should report the resolved commit it evaluated. A tag is not automatically protected against movement merely because people call it a release. Repository policy determines whether selected references can be rewritten and who can perform that change.

Consider configuration that names an image with a moving tag. The Git version is immutable, but the image content can change when the registry tag moves. Replaying the same configuration later can therefore run different code. Content-identified artifacts or an equivalent controlled identity contract strengthen reproducibility. The desired-state version and its dependency versions need to be considered together.

Rendering introduces similar input questions. A pinned configuration can use a chart dependency that resolves differently later or a mutable remote base. The resulting resources can change even though the local source did not. Auditable promotion should identify the rendering inputs and relevant tool versions rather than assume the final text alone describes every dependency.

Promotion can move an approved artifact and configuration into another environment without rebuilding unrelated content. That preserves the relationship between tested input and selected release. Environment-specific settings still need review, and a successful staging result does not prove production capacity or permissions. Promotion reduces one source of variation; it does not remove every operational difference.

History also needs retention. An identified old configuration is less useful for recovery if its artifacts were deleted or its source was rewritten beyond retrieval. The team should define which versions and dependencies remain available. Audit evidence should connect approvals, content identity and target evaluation so an operator can determine what was actually applied.

Immutability does not mean desired state never changes. New versions express new intent, and agents obtain them according to policy. The important distinction is that changes create identifiable versions rather than silently altering what an existing identity means. This lets a review discuss the difference between versions and lets an incident report name the version involved.

Access controls support that accountability. Contributors may propose changes without having permission to move the authoritative production reference directly. Protected review paths and suitable audit can make unauthorized movement harder to conceal. These controls are not supplied merely by choosing Git; the surrounding repository and organizational policy must implement them.

Secrets require separate handling because immutable history retains data. A password committed once can remain in old versions and clones after its current file is deleted. Hashing a commit does not encrypt its contents. Versioning references or approved encrypted representations can preserve configuration accountability while the credential value follows its own access and rotation process.

The useful reasoning connects source version, dependency identity, approval and evaluated target revision. Students should be able to explain why a moving reference is convenient for selection but insufficient as sole content evidence. That distinction supports both reliable promotion and a truthful account of what a rollback can reproduce.

## Common pitfalls

> [!WARNING]
> Immutable source versions can still depend on mutable artifacts. Branch names and release tags need explicit reference policy. Retained history does not protect plaintext secrets, and a familiar release name does not prove identical content across environments.
