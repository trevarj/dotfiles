---
name: orchestrate-engineering
description: "Coordinate an explicitly requested, high-assurance engineering handoff from evidence gathering and a strong Sol plan to a bounded lower-cost implementation worker and validation. Use only when the user invokes $orchestrate-engineering; do not invoke for normal direct work or plain-language delegation requests."
---

# Orchestrate Engineering

Coordinate one deliberate, serialized engineering workflow. Keep the controller
responsible for requirements, scope, approvals, validation, and the final
result. Give each specialist one bounded job.

Read [references/routing.md](references/routing.md) before choosing a mode.
Read [references/handoff-contract.md](references/handoff-contract.md) before
planning or delegating implementation.

## Gate and preflight

- Treat explicit invocation of this skill as authorization for its sequential
  workflow only. Do not apply delegation to later ordinary requests.
- Obey all applicable `AGENTS.md` files, approval boundaries, and user limits.
  Work directly if delegation is disallowed by a higher-priority instruction.
- Inspect the task, repository guidance, current branch, and dirty worktree
  before selecting a mode. Preserve unrelated user changes.
- Keep one specialist active at a time. Do not allow any specialist to spawn
  another. Do not parallelize writers.
- Before spawning a worker, inspect the models and reasoning efforts exposed by
  the agent-spawn tool. Use only `high`, `xhigh`, `max`, or `ultra` in this
  workflow; never accept a `low` or `medium` worker route.
- Use a fresh worker context when possible. Pass a compact task packet rather
  than relying on hidden controller context; include the complete accepted Plan
  Contract verbatim for implementation.
- If the user requests analysis or a plan only, stop after the relevant
  evidence brief or Plan Contract. Do not spawn an implementer.

## Choose a mode

Select `deep` automatically whenever the task includes architecture,
concurrency, persistence, security, protocol, migration, public API, or an
unresolved root cause. Use `guided` only when no mode is named and none of
those deep triggers applies. If the user explicitly requests `guided` for a
deep task, call out the downgrade and require an explicit lower-cost exception
before proceeding. State the selected mode and one-sentence reason before
delegation.

| Mode | Use it for | Serialized workflow |
| --- | --- | --- |
| `guided` | Normal multi-file feature, bug fix, or refactor | `engineering_planner` -> `engineering_implementer` -> controller validation |
| `deep` | Architecture, concurrency, persistence, security, protocol, migration, public API, or unresolved root-cause work | optional `engineering_scout` -> `engineering_deep_planner` -> `engineering_implementer` -> `engineering_reviewer` -> controller validation |
| `mechanical` | Exact, low-risk edits whose files, symbols, behavior, and tests are already prescribed | one bounded high-or-higher `worker`, then controller validation |

Do not use `mechanical` for ambiguous behavior, design choices, new public API,
schema or persistence changes, concurrency, security, migrations, or a failed
test whose cause is unknown. Work directly instead of delegating a small,
obvious task unless the user specifically asks for a worker.

Use `engineering_scout` only when a deep task needs a focused repository map,
test-location discovery, or log triage before planning. Do not make scouting a
default extra stage. If Ultra is unavailable, use `engineering_planner` and
state the downgrade before proceeding.

## Select a worker model

After accepting a plan, select the lowest-cost available 5.6 worker route that
meets the plan's uncertainty and risk:

- Use Luna / `high` for an exact mechanical patch with prescribed behavior and
  validation.
- Use Terra / `high` for normal implementation; raise it to `xhigh` when the
  worker must reconcile multiple integrations, ambiguous tests, or meaningful
  compatibility risk.
- Reserve Sol / `max` for an explicit implementation exception where the
  accepted plan still leaves consequential technical judgment. Do not use it
  for routine implementation. Reserve Ultra for the existing deep-planner
  route unless the user explicitly expands the delegation policy.

Set both `model` and `reasoning_effort` in every generic worker-spawn call. An
omitted override is an inherited route and violates this skill. If the selected
route is not offered or the spawn rejects it, choose the next suitable
available 5.6 route at `high` or above and report the actual route. Do not
claim a model is unavailable without catalog or rejected-spawn evidence. If no
explicit high-or-higher worker route is available, use the configured
`engineering_implementer` or stop for user direction; never silently inherit a
worker model.

## Gather evidence

For a scout, send only the task packet and request an Evidence Brief containing:

1. Relevant files, symbols, callers, and tests.
2. Observed current behavior and the likely control/data flow.
3. Constraints from repository guidance and existing interfaces.
4. Unknowns, risks, and the smallest useful next inspection.

Do not ask the scout to edit, decide the final design, or create a speculative
implementation plan. Incorporate its evidence into the planner packet.

## Produce and accept a plan

Spawn `engineering_planner` for `guided` work or
`engineering_deep_planner` for `deep` work. Give it the task packet, evidence,
user constraints, and the complete Plan Contract specification. Copy the
`# Plan Contract` section of
[references/handoff-contract.md](references/handoff-contract.md), through
`## Risks and rollback`, verbatim into every planner packet; do not send only
the headings.

Require every heading and requirement from
[references/handoff-contract.md](references/handoff-contract.md). Reject a
plan that lacks source-backed evidence, exact implementation steps, required
non-goals or boundaries, edge cases, expected assertions, observability or
rollback where applicable, or executable validation. If the plan is `BLOCKED`,
resolve the question with the user or work directly; do not hand ambiguity to
an implementer.

## Delegate implementation

Send the complete accepted Plan Contract to `engineering_implementer` along
with its permitted ownership and the repository state it must preserve. Require
it to inspect the current source before editing, implement only the accepted
scope, and return the Worker Report defined in the contract.

If the source contradicts the plan, require a `PLAN CONFLICT` report. Do not
ask the worker to silently redesign, widen scope, or spawn another specialist.
Do not ask a worker to commit, push, open a PR, or make external changes unless
the user separately authorizes them.

## Review and validate

- Require the implementation worker to run the closest relevant validation.
- Inspect the final diff and independently run the agreed validation from the
  controller before declaring success.
- For `deep` work, send the diff, Plan Contract, Worker Report, and validation
  evidence to `engineering_reviewer`. Require concrete correctness findings or
  an explicit `NO MATERIAL FINDINGS` result.
- Allow at most one fix-and-review cycle unless the user asks for more. Stop and
  report material blockers with evidence instead of creating a recursive loop.
- Distinguish a pre-existing failing check from a regression introduced by the
  work. Do not claim a passing suite when required checks were skipped or fail.

## Controller output

Lead with the outcome. Record the selected mode, delegated roles and actual
model/effort, material plan or scope changes, changed files, validation results,
remaining risks, and any work not performed. Keep intermediate logs and
repeated reasoning out of the final response.
