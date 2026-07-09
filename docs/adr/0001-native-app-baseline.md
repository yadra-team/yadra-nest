# ADR 0001: Native App Baseline

## Status

Accepted

## Context

Yadra Nest is the native-installed desktop app for Yadra. It must run on macOS, Linux, and Windows with strong OS integration while staying local-first and maintainable by AI-assisted contributors.

The project does not require a pure native-control UI. It requires a native-installed app shell, secure privileged operations, local storage, background work, local model integration, updater/signing support, and a maintainable editor-heavy interface.

Old desktop code is reference-only. New implementation starts in this repository.

## Decision

Yadra Nest uses this baseline architecture:

- **App shell:** Tauri 2.
- **Privileged core:** Rust Desktop Core with Tokio for async work.
- **UI:** React + TypeScript inside the system WebView.
- **Local database:** embedded SurrealDB through the Rust SDK with persistent local storage.
- **Local inference:** bundled localhost-only llama.cpp sidecar for first-party local model execution and embeddings.
- **Power-user runtimes:** Ollama, LM Studio, and custom OpenAI-compatible local endpoints through explicit runtime adapters.
- **External AI:** only through Desktop Core policy, redaction, audit, and user settings; optionally via Yadra Bridge.

React owns presentation, editor interactions, view state, command surfaces, and in-app workflows. Rust owns durable state, filesystem access, OS integration, migrations, background jobs, local model process control, privacy policy, proposal execution, and all writes to local storage.

Yad is a local agent subsystem, not a direct database writer. It reads through bounded retrieval adapters and submits typed proposals. Desktop Core applies approved proposals and records audit state.

## Boundaries

### Nest Owns

- Native-installed app lifecycle and windows.
- Local note/task/settings/import user experience.
- Desktop Core services for privileged local operations.
- Embedded local storage and migrations.
- Local runtime management and capability probing.
- Yad proposal review surfaces such as notifications, toasts, and Yad Inbox.
- Redaction and egress gates before any external AI request.

### Hub Owns

- Accounts, authentication, subscriptions, billing, admin, and account metadata.
- JWT issuance and refresh flows.
- No note/task/user-content storage.

### Bridge Owns

- Redacted external AI proxying.
- Provider routing and no-logging privacy boundary.
- No durable prompt/response storage.

### Seed Owns

- Model manifest metadata.
- Hardware compatibility hints.
- Model evaluation and recommendation metadata.
- No user notes or app state.

### Docs Own

- Cross-repository source of truth, roadmap, and architecture coordination.
- Repository naming and governance decisions.

## Rationale

Tauri 2 gives a native-installed cross-platform app, small bundles, OS integration, updater/signing paths, scoped permissions, and a Rust backend without bundling Chromium.

Rust is the right ownership boundary for privileged local operations because it gives memory safety, structured async work, filesystem and process control, and a strong boundary between UI code and durable data operations.

React + TypeScript is selected for the desktop UI because it is broadly maintainable, well understood by AI coding agents, and a strong fit for editor-heavy interfaces, virtualized lists, command palettes, split panes, graph views, and inspection panels.

Embedded SurrealDB keeps local-first data in-process and avoids a separate database sidecar. It also supports document, graph, full-text, and vector retrieval use cases needed by Yad.

llama.cpp is the bundled local runtime baseline because it supports local-first inference with predictable packaging and localhost-only control. User-managed runtimes remain available for power users without becoming the default operational path.

## Tradeoffs

- WebView UI is not a pure native widget UI. This is acceptable because editor-heavy productivity surfaces benefit from mature web UI tooling.
- Tauri depends on platform WebViews, so rendering differences must be tested on macOS, Linux, and Windows.
- Rust raises implementation rigor, but it is appropriate for the local data, security, process, and OS-integration boundary.
- Embedded SurrealDB simplifies user setup but requires strict migration tests and version pinning.
- Bundled local inference increases packaging complexity, but it preserves local-first behavior for non-power users.

## Consequences

- No app scaffold should be created until the first implementation issue references this ADR.
- UI work must assume React + TypeScript, not Svelte.
- All storage writes must go through Rust Desktop Core.
- Yad must not hold a write-capable database client.
- External AI calls must pass through Desktop Core redaction and policy gates.
- Runtime adapters must expose capability profiles instead of hard-coded model assumptions.
- CI must eventually include Rust checks, frontend checks, IPC contract tests, and packaged-app smoke checks.

## Verification

This ADR satisfies issue #1 when:

- It names the selected desktop path and tradeoffs.
- It defines what belongs in Nest versus Hub, Bridge, Seed, and docs.
- It states old desktop code is reference-only.
- It does not scaffold application source code.

