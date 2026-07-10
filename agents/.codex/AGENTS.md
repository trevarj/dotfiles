# Agent orchestration

## Default workflow

- Act as a coordinator first. Delegate substantive research, investigation,
  implementation, and review work to the closest matching specialist.
- Handle conversation, status questions, simple explanations, and one-line
  commands directly when delegation would add no useful evidence or review.
- Run the normal pipeline autonomously: investigate, plan when needed,
  implement, validate, review, revise, and report. Ask the user only when
  intent, permissions, destructive actions, or consequential tradeoffs require
  a decision.
- Keep the main thread focused on requirements, decisions, phase updates, and
  the final synthesis. Do not copy raw subagent chatter into it.

## Routing

- Prefer an existing language or domain specialist over a generic worker.
- Use Terra agents for routine research, debugging, implementation, and review.
- Use the Sol architect before implementation when work is ambiguous,
  architectural, security-sensitive, concurrency-heavy, migration-related,
  multi-repository, public-API-facing, or blocked on an unresolved root cause.
- Use a Sol reviewer for those same risk classes and for security, performance,
  or safety-critical Bitcoin work. Use a matching Terra reviewer otherwise.
- Start research with one Terra researcher. Add a second only for a clearly
  independent evidence lane.
- A Terra subagent may consult the Sol architect once when blocked or facing a
  consequential design choice. It must not delegate further work.

## Coordination and completion

- Parallel writers must have explicit, non-overlapping file or subsystem
  ownership. Serialize work that shares files, interfaces, schemas, or generated
  artifacts. The coordinator may handle only small integration edits or conflict
  resolution when that is safer than another handoff.
- Require implementation agents to run the closest relevant validation before
  review. Reviewers report concrete correctness findings, not style-only noise.
- Allow at most two fix-and-review cycles. Escalate routine work to a Sol review
  no later than the second cycle. If a material finding remains, stop and report
  the blocker with evidence.
- Give concise phase updates when agents are assigned, when a material finding
  changes the approach, and when validation or review finishes.

## Project override

- A closer project `AGENTS.md` may disable automatic delegation. When it does,
  the main agent works directly unless the user explicitly requests subagents.
