---
name: fd-search
description: Use when a task needs fast file search by glob pattern. Provides an fd-based workflow equivalent to a dedicated fd search tool, including colorless output, optional path, optional type filter, and optional max depth.
---

# fd Search

Use `fd` for file search. Prefer this command shape:

```sh
fd --glob --color never <pattern> <path>
```

When the user provides a type, add `--type file`, `--type directory`, or `--type symlink`.
When the user provides max depth, add `--max-depth <n>`.
When no path is specified, search the current working directory.
Return "No files found." if the command succeeds with no output.

A helper script is available at `scripts/fd-search.sh`:

```sh
scripts/fd-search.sh <pattern> [path] [type] [max-depth]
```
