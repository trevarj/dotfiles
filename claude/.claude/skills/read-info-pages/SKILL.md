---
name: read-info-pages
description: Read GNU Info manuals from the local system or a Guix shell. Use when Codex needs authoritative local documentation from Info pages for GNU, Guix, Emacs, Scheme, libc, coreutils, Texinfo, or any tool/library that installs .info manuals; when a user asks to inspect, summarize, cite, or verify behavior from Info documentation; or when command behavior should be checked against installed manuals instead of memory.
---

# Read Info Pages

## Workflow

Use local Info manuals as the source of truth when a task depends on installed GNU/Guix documentation.

1. Check for the Info reader before using it:

```sh
command -v info || guix shell texinfo -- info --version
```

If `info` is unavailable, run the same command through `guix shell texinfo --`.

2. Discover the relevant manual or node:

```sh
info --apropos='search terms'
info --where MANUAL
info --index-search='index entry' MANUAL
```

Use `--apropos` when the manual name is unclear. Use `--where` to confirm which installed manual is being read.

3. Read targeted content:

```sh
info --output=- MANUAL
info --output=- MANUAL -n 'Node Name'
info --output=- --subnodes MANUAL -n 'Node Name'
```

Prefer a specific node or index entry over dumping a whole manual. Use `--subnodes` only for a bounded subtree.

4. Read package-specific manuals that are not in the current profile:

```sh
guix shell PACKAGE texinfo -- info --output=- MANUAL
guix shell PACKAGE texinfo -- info --apropos='search terms'
```

Include the package that provides the manual in the shell. Add `texinfo` when the `info` reader itself is needed.

5. Read a local Info file directly:

```sh
info --file ./path/to/file.info --output=-
info --file ./path/to/file.info.gz --output=-
```

Use `--directory=/path/to/share/info` when a manual is installed outside the active `INFOPATH`.

## Answering From Info Pages

- Cite the manual and node in the answer, for example: `coreutils`, node `cp invocation`.
- Quote only short phrases when necessary; otherwise summarize.
- Mention when the installed manual is missing or differs from the command available on `PATH`.
- If the user asks about current upstream behavior, distinguish local installed documentation from upstream documentation and browse only when the task requires current external information.

## Common Patterns

Find an option:

```sh
info --index-search='--option-name' MANUAL
```

Find a concept:

```sh
info --apropos='concept or command'
```

Inspect the top menu:

```sh
info --output=- MANUAL
```

Dump one subtree for searching:

```sh
info --output=- --subnodes MANUAL -n 'Node Name'
```
