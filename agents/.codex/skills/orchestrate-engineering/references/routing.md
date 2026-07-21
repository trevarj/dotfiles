# Routing

Use the least expensive route that can still meet the task's correctness bar.
Do not treat a higher reasoning setting as a substitute for a clear task,
source evidence, or validation.

| Route | Agent and model | Use | Do not use |
| --- | --- | --- | --- |
| Direct | Controller only | Small, obvious changes and ordinary requests | Work requiring an explicit handoff or a hard design decision |
| Scout | `engineering_scout`: Terra / medium / read-only | Repository mapping, test discovery, log triage | Final design or implementation |
| Guided planner | `engineering_planner`: Sol / max / read-only | Nontrivial feature, bug, or refactor | A trivial mechanical patch |
| Deep planner | `engineering_deep_planner`: Sol / ultra / read-only | Security, concurrency, persistence, protocol, migration, public API, or unresolved root-cause work | Routine work or a task whose correct scope is already obvious |
| Implementer | `engineering_implementer`: Terra / high / workspace-write | An accepted source-backed Plan Contract | A blocked or ambiguous plan |
| Mechanical worker | Built-in `worker`: Luna / medium / workspace-write | Exact low-risk edits with prescribed behavior and validation | Any design, compatibility, security, state, or failure-path judgment |
| Deep reviewer | `engineering_reviewer`: Sol / high / read-only | Review after a deep implementation | Style-only cleanup or ordinary guided work |

`ultra` is optional account/model capability. Fall back to the Max planner when
it is unavailable and state the downgrade. Do not silently add a scout, reviewer,
or second implementation worker merely because one exists.

## Task packet

Pass each agent only what it needs:

1. User goal, non-goals, and approval boundary.
2. Selected mode, role, and permitted action scope.
3. Repository path, branch/dirty-worktree facts, and applicable guidance.
4. Evidence from earlier stages, with file and symbol references.
5. Required output format and stop condition.

For either planner, include the complete `# Plan Contract` section through
`## Risks and rollback` verbatim, not merely its heading list. For the
implementer, include the full accepted Plan Contract. For the reviewer, include
the Plan Contract, Worker Report, final diff, and validation evidence.
