# Plan Contract

Return exactly these headings. Use `READY` only when implementation can proceed
without a material design choice or missing fact. Use `BLOCKED` otherwise.

## Status

`READY` or `BLOCKED`, followed by one sentence explaining why.

## Goal and acceptance criteria

State the required user-visible behavior and the measurable completion criteria.
List explicit non-goals.

## Evidence and constraints

List the source-backed facts that justify the plan. Include relevant paths and
symbols, repository guidance, interface/compatibility constraints, and any
important current worktree state.

## Design decision

State the chosen approach, why it satisfies the evidence and acceptance
criteria, and the material alternative rejected. Name required invariants.

## Change map

For every affected file or symbol, state the exact change, its purpose, and
which invariant or behavior it preserves. Order changes by implementation
dependency.

## Implementation steps

Give a concrete ordered algorithm. Describe data flow, state transitions,
failure handling, and cleanup where applicable. Avoid vague directions such as
"update the logic" or "handle errors."

## Edge cases and compatibility

Cover invalid input, empty or missing state, retries or duplicates, cancellation
or partial failure, backward compatibility, migration and rollback, concurrency,
and resource cleanup when relevant. Explicitly mark inapplicable categories.

## Test and validation plan

List tests to add or amend, exact existing commands to run, expected assertions,
and manual or integration checks. Distinguish required checks from optional
follow-up validation.

## Implementation boundaries

List files or APIs that must not change, authorization limits, and conditions
that require a `PLAN CONFLICT` instead of an implementation choice.

## Risks and rollback

List remaining risks, observability signals, and a concrete reversal path when
the change has persistent or user-visible effects.

# Worker Report

Return these headings after implementation:

## Changed

List files and the behavior implemented.

## Validation

List commands run, results, and checks not run.

## Deviations

List approved deviations from the plan. Use `None` when there are none.

## Plan conflict or remaining risk

Use `None` only if no material conflict or unresolved risk remains. Otherwise,
state the evidence and stop condition.
