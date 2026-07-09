# Yadra Nest

Native-installed desktop app for Yadra.

Yadra Nest is the future local-first desktop application. It will own the installed app shell, local user experience, local data orchestration, and the boundary between the app core and Yad, the local agent.

## Status

This repository is in v0.1 planning and architecture setup. Product implementation must start from accepted issues in the `v0.1 Platform Baseline` milestone.

## Architecture And Requirements

- [ADR 0001: Native App Baseline](docs/adr/0001-native-app-baseline.md)
- [Local-First Notes and Metadata Requirements](docs/requirements/local-first-notes-and-metadata.md)
- [Yad Agent Boundary Requirements](docs/requirements/yad-agent-boundary.md)

## Rules For Contributors

- Read `AGENTS.md` before making changes.
- Start fresh in this repository.
- Keep architecture docs and implementation issues aligned.
- Run repository validation before opening a pull request.

```bash
bash scripts/verify-ai-governance.sh
```
