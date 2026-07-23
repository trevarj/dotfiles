---
name: guix-package-update
description: Update a package definition in Trevor's personal Guix channel (~/Workspace/trev-guix) to a newer Git commit and matching Guix content hash. Use when the user says "$update-guix-package", "update guix package", or after committing and pushing in a source repo that one of the channel's packages tracks. Handles locating the channel/package, bumping git-reference commits or release versions, refreshing the sha256/base32 hash, and updating version suffixes that embed a short Git hash.
---

# Guix Package Update

Update a package in the user's personal Guix channel to its latest commit (or
release) and refresh the content hash. Make precise Scheme edits; preserve the
package's existing style and update model.

## Channel location

- Personal channel root: `~/Workspace/trev-guix`.
- The `.guix-channel` declares `(directory "channel")`, so the module load path
  is `~/Workspace/trev-guix/channel` and package modules live under
  `~/Workspace/trev-guix/channel/trev-guix/packages/*.scm`
  (modules named `(trev-guix packages <file>)`).
- Build/lint with that load path:
  `guix build -L ~/Workspace/trev-guix/channel <package-name>`.

## Workflow

1. Determine the task mode.
   - **In the channel repo** with a package name: update that package.
   - **In a source repo** that was just committed and pushed: find the channel
     package that tracks this repo, then bump it to the pushed commit.

2. Find the package definition.
   - By name: search the channel for `(define-public <name>` and
     `(name "<name>")`.
     `rg -n '\(define-public <name>|\(name "<name>"' ~/Workspace/trev-guix/channel`
   - From a source repo: take `git remote -v`, normalize the URL (handle
     `git@host:owner/repo.git`, `ssh://git@host/owner/repo.git`,
     `https://host/owner/repo(.git)`), and grep the channel for that URL or the
     repo name; confirm the surrounding `origin` is the intended package.
   - Read enough of the package to see `source`, `origin`, the fetch `method`,
     `version`, the commit/tag, and the hash field.

3. Determine the target reference. Preserve the existing update model; do not
   switch commit<->tag, change the source URL, or rename the package unless
   asked.
   - `git-fetch` tracking a branch commit: resolve the upstream default branch
     and its HEAD.
     `git ls-remote --symref <url> HEAD`
   - `git-fetch` tracking a tag/release: find the newest matching tag.
     `git ls-remote --tags <url>`
   - `url-fetch` release tarball/binary: find the newest release version and
     rebuild the URI from the existing `version` template.
   - After a push in a source repo: use the pushed `HEAD`; confirm the remote
     has it with `git ls-remote <url> <ref>`.

4. Edit the version/commit.
   - `git-fetch`: replace the `(commit ...)` with the new full hash, or the tag
     string for a release-tracking package.
   - `(git-version base revision commit)`: update the `commit` binding; keep the
     existing `revision` unless channel convention says otherwise.
   - If `version` embeds a short commit hash, replace that suffix using the same
     length already present. Do not add a short-hash suffix to a version that
     lacks one.
   - `url-fetch`: bump `version`; the URI usually rebuilds from it.

5. Refresh the hash. Keep the existing syntax (`(base32 "...")`,
   `(content-hash ... sha256 ...)`) unless nearby packages migrated to a newer
   style.
   - Easiest reliable method: edit the commit/version, run
     `guix build -L ~/Workspace/trev-guix/channel <name>`, and copy the
     `sha256 hash mismatch ... expected ... got <base32>` value into the hash
     field, then rebuild.
   - For a `git-fetch` source you can also compute it directly: clone at the
     target ref, drop `.git`, and take the recursive nar hash.
     ```sh
     guix shell git -- git clone --depth 1 --branch <ref> <url> /tmp/pkgsrc
     rm -rf /tmp/pkgsrc/.git
     guix hash -S nar -H sha256 /tmp/pkgsrc
     ```
   - For a `url-fetch` source, `guix download <uri>` prints the base32 hash.

6. Verify.
   - `guix build -L ~/Workspace/trev-guix/channel <package-name>` must succeed.
   - If the build needs network/substitutes that aren't available, at least
     confirm the Scheme parses (`guix build -n` or load the module) and report
     the exact limitation.

## Safety checks

- The source URL and target ref must belong to the same repository.
- A post-push update must use a commit visible on the remote, not just locally.
- Preserve unrelated fields and formatting; edit only the source ref + hash
  (and version when appropriate).
- Do not move multiple packages unless they share the same source bump and the
  user expects it.
- Do not commit or push channel changes unless the user explicitly asks. When
  asked, follow the user's commit rules (Conventional Commits, GPG-signed).
