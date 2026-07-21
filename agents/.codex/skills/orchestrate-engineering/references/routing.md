# Routing

Use the least expensive available 5.6 route that can still meet the task's
correctness bar. Use `high` as the reasoning floor: never use `low` or
`medium`. Do not treat a higher reasoning setting as a substitute for a clear
task, source evidence, or validation.

| Route | Agent and model | Use | Do not use |
| --- | --- | --- | --- |
| Direct | Controller only | Small, obvious changes and ordinary requests | Work requiring an explicit handoff or a hard design decision |
| Scout | `engineering_scout`: Terra / high / read-only | Repository mapping, test discovery, log triage | Final design or implementation |
| Guided planner | `engineering_planner`: Sol / max / read-only | Nontrivial feature, bug, or refactor | A trivial mechanical patch |
| Deep planner | `engineering_deep_planner`: Sol / ultra / read-only | Security, concurrency, persistence, protocol, migration, public API, or unresolved root-cause work | Routine work or a task whose correct scope is already obvious |
| Implementer | `engineering_implementer`: Terra / high / workspace-write | An accepted source-backed Plan Contract | A blocked or ambiguous plan |
| Mechanical worker | Built-in `worker`: selected available 5.6 route / high-or-higher / workspace-write | Exact low-risk edits with prescribed behavior and validation | Any design, compatibility, security, state, or failure-path judgment |
| Deep reviewer | `engineering_reviewer`: Sol / high / read-only | Review after a deep implementation | Style-only cleanup or ordinary guided work |

`ultra` is optional account/model capability. Fall back to the Max planner when
it is unavailable and state the downgrade. Do not silently add a scout, reviewer,
or second implementation worker merely because one exists.

## Worker selection

Inspect the model choices and reasoning efforts offered by the agent-spawn tool
before each generic worker spawn. Select and pass an explicit `model` and
`reasoning_effort`; do not rely on inheritance.

1. Choose Luna / `high` for an exact mechanical change with prescribed files,
   behavior, and validation.
2. Choose Terra / `high` for normal implementation. Raise it to `xhigh` for
   nontrivial integration, compatibility, or test uncertainty.
3. Choose Sol / `max` only when the accepted plan still requires consequential
   technical judgment. Keep Sol / `ultra` for the deep planner unless the user
   explicitly broadens the delegation policy.

If the first choice is unavailable or rejected, move to the next suitable
available 5.6 route without dropping below `high`, and state the actual model
and effort. Do not report a route as unavailable without evidence. If no
explicit high-or-higher generic worker route is available, use
`engineering_implementer` or stop for direction instead of inheriting the
controller model.

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
