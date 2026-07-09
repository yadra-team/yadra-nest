# yadra-nest AI Rules

This repository is part of Yadra.

## Responsibility

Yadra Nest owns the native-installed desktop app: app shell, local-first note experience, local app-core orchestration, and the boundary between user-facing workflows and Yad.

## Source Of Truth

- This file is the canonical project-local AI instruction file for `yadra-nest`.
- Cross-project rules live in the root workspace `AGENTS.md` and `ai-context/`.
- Do not copy private user data, secrets, personal memory, or local-only paths into committed files.

## Architecture Constraints

- Do not reuse old desktop code as active implementation.
- Treat `archive/desktop-legacy/` only as historical reference when explicitly requested.
- Do not scaffold app source until the relevant v0.1 architecture issue is accepted.
- Keep Yad reasoning separate from app-core execution.
- Yad must not directly mutate user data storage.

## Workflow

- Work on feature branches; do not push directly to `main`, `preprod`, or `production`.
- Use squash merge through pull requests.
- Run repository validation before commit or push.
- For AI-assisted changes, include verification commands in the pull request.

## Validation

Run:

```bash
bash scripts/verify-ai-governance.sh
```

