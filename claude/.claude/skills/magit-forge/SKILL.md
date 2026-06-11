---
name: magit-forge
description: Fetch and inspect GitHub issues and pull requests through the user's local Emacs Magit Forge/Ghub setup. Use whenever a user mentions a GitHub issue, pull request, PR, issue number, PR number, "#123" in a GitHub-backed repository, "latest issue", "latest PR", comments, labels, assignees, or GitHub pull request review threads, especially when working inside or referring to a local Git worktree that Forge can resolve.
---

# Magit Forge

## Workflow

Use this skill when issue or pull request context should come from Emacs Forge instead of a separate CLI or API integration.

Keep user-facing answers focused on the requested issue or pull request. Do not mention exporter commands, temporary files, GPG/auth handling, or lookup mechanics unless the user asks for debugging details or file paths.

When the user mentions an issue or pull request naturally, treat the skill as an internal lookup facility. Fetch the data, read the generated JSON or Markdown, and answer the user's actual question directly.

1. Prefer the exporter script:

```sh
emacs -Q --batch -l /home/trev/.claude/skills/magit-forge/scripts/forge-export.el -- \
  --repo auto \
  --type pullreq \
  --number latest \
  --refresh \
  --include-review-threads \
  --format both \
  --out-dir /tmp/forge-export
```

Run it from the target Git worktree when using `--repo auto`. Use `--type issue` for issues and `--type pullreq` for pull requests. Use `--number latest` for the newest issue or pull request by creation time.

2. Read the generated files:

- `topic.json` for structured metadata, bodies, comments, and review threads.
- `topic.md` for human-readable summaries or quoting small excerpts.

3. If GPG auth fails, do not ask the user for secrets. Run:

```sh
/home/trev/.codex/bin/codex-gpg-unlock
```

Then retry the export.

## Exporter Options

- `--repo auto`: resolve the repository from the current Git worktree and Forge remote detection.
- `--repo OWNER/NAME`: target a GitHub repository explicitly.
- `--repo github.com/OWNER/NAME`: target a GitHub repository with host.
- `--type issue|pullreq`: choose the topic type.
- `--number N|latest`: issue or pull request number, or the newest item of the selected type by creation time.
- `--refresh`: fetch live data through Forge/Ghub before exporting.
- `--no-refresh`: export cached Forge data only.
- `--include-review-threads`: include GitHub PR review threads and inline comments.
- `--format json|markdown|both`: choose output files.
- `--out-dir DIR`: output directory.
- `--self-test`: verify JSON and Markdown serialization without loading Forge or using the network.

## Notes

Read `references/forge-notes.md` when adjusting the exporter, debugging local Forge behavior, or checking what Forge stores by default.
