---
name: rg-search
description: Use when a task needs fast content search across files. Provides a ripgrep-based workflow equivalent to a dedicated rg search tool, including line numbers, no headings, no color, modified-time sorting, optional path, and optional include glob.
---

# rg Search

Use `rg` for content search. Prefer this command shape:

```sh
rg --line-number --no-heading --color never --sort modified -- <pattern> <path>
```

When the user provides an include glob, add `--glob <include>` before `--`.
When no path is specified, search the current working directory.
If `rg` exits with status 1, treat it as "No matches found." For other nonzero statuses, report the error.

A helper script is available at `scripts/rg-search.sh`:

```sh
scripts/rg-search.sh <pattern> [path] [include-glob]
```
