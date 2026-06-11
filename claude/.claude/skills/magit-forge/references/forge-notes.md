# Forge Notes

## Local Setup

- Emacs is available at `/home/trev/.guix-home/profile/bin/emacs`.
- Forge 0.6.3 is installed under `/home/trev/.emacs.d/elpa/forge`.
- Magit is configured in `/home/trev/.emacs.d/init.el`; Forge loads after Magit.
- Forge's default database file is `~/.emacs.d/forge-database.sqlite`.
- Ghub/Forge authentication should use Emacs auth-source, likely `~/.authinfo.gpg`.

## Data Coverage

Forge's GitHub repository query stores:

- Issue and pull request metadata.
- Topic bodies.
- Main issue/PR comments.
- Labels, assignees, milestones, review requests.

Forge does not store GitHub PR review threads in the normal issue/PR post tables. Use Ghub's review-thread GraphQL query for inline code-review comments.

## Safety

- Do not print or inspect auth-source secret values.
- If auth prompts need GPG, run `/home/trev/.codex/bin/codex-gpg-unlock` and retry.
- Use `--no-refresh` when the user explicitly asks to avoid network access.
