---
draft: true
exam_objectives:
- Declarative
---
# Sufficient Intent, Rendering And Controller Contracts

The declarative principle asks whether authoritative input describes the intended condition of the managed system. It is not satisfied merely because a workflow stores files in version control. A shell script can have a carefully reviewed history while still prescribing a sequence of actions. A declarative resource describes what should hold, allowing the implementation to choose supported actions based on current conditions.

Sufficiency is part of the contract. A declaration should include the inputs needed within its scope or identify the external assumptions deliberately. If an application depends on an image, configuration and a database claim, declaring only its display name is not enough. Missing inputs may be supplied by stable platform defaults, but those defaults then become part of the management contract.

Higher-level rendering can remain declarative. A chart or overlay expresses parameters and transformations that produce concrete resource intent. The renderer does not remove the need to identify versions, values and dependencies. A mutable remote base can change output without a local source edit. Reviewing higher-level input therefore includes reviewing the chain that gives it meaning.

Consider a reusable service package with a capacity value. The package translates that value into resource requests and replica settings. Users can express their required operating class without editing every low-level field. That is useful abstraction when the mapping is stable and documented. If the mapping changes silently between renders, the same intent can produce a materially different workload.

Controller ownership determines how intent is implemented. A GitOps agent may own selected resource specifications, while an autoscaler owns a field whose value changes dynamically. Declaring a fixed value for the same field without a clear agreement can create conflict. Declarative syntax does not automatically coordinate independent control processes.

Policy constrains what intent is acceptable. A schema can recognize a privileged workload request while an admission policy rejects it. An organization can also restrict artifact sources or require ownership metadata. Those controls should be evaluated through their own contracts rather than weakened simply because the requested state was stored in a repository.

Dependencies can make valid intent temporarily unrealizable. A declared workload may await storage, secrets or capacity. The implementation should report the condition and revisit it according to policy. A successful parse says only that the input can be interpreted; it does not establish that every dependency exists. Students should connect each declared relationship to the component responsible for satisfying it.

Deletion semantics deserve explicit intent as well. Removing a resource from a source may mean it should be deleted, retained or handed to another owner, depending on the controller and policy. A persistent database is not an incidental leftover in the same sense as a temporary test workload. The desired lifecycle should be understood before automatic cleanup is enabled.

Changes can be reviewed by state difference. A reviewer can identify that an image changes, a permission expands or a retention setting disappears. This transparency improves reasoning but does not replace it. An unsafe desired condition remains unsafe even when the diff is clear. The review should explain operational consequences and meaningful failure boundaries.

The useful conclusion is that declarative input needs an interpreter, a sufficient scope and stable contracts. The agent performs procedures behind that abstraction while returning feedback about progress. Students can then distinguish a convenient text format from an actual desired-state management model.

## Common pitfalls

> [!WARNING]
> Version control and YAML syntax do not make a procedure declarative. Review rendering inputs, ownership and lifecycle as well as schema. A clear description can still be unsafe, incomplete or impossible for the target to satisfy.
