# Yad Agent Boundary Requirements

## Status

Accepted for v0.1 planning.

## Purpose

This document defines the v0.1 boundary between Yad, the local agent subsystem, and Yadra Nest Desktop Core.

Yad may reason, retrieve bounded context, ask for local model inference through approved runtime paths, and submit typed proposals. Desktop Core is the only authority that applies durable changes, writes local storage, touches the filesystem, changes protected settings, performs external AI egress, and records audit state.

This document does not define final IPC payloads, database schema, prompt templates, model prompts, or UI layouts. Those belong to later implementation issues.

Cross-project planning reference: [V0.1 Implementation Roadmap](https://github.com/yadra-team/yadra/blob/main/docs/1.ProductStrategyAndPlanning/50.V0.1ImplementationRoadmap.md).

No application implementation should start for Yad until this boundary is accepted.

## Core Boundary

Yad is a contained reasoning subsystem. It can inspect scoped context and request actions, but it is not an app-core executor.

Desktop Core owns:

- durable writes to local storage;
- filesystem reads and writes;
- migrations and import writes;
- proposal validation and proposal application;
- protected settings changes;
- runtime process management;
- external AI routing, redaction, approval, and audit;
- background job scheduling and cancellation;
- local audit records for proposals and external egress.

Yad owns:

- interpreting user requests;
- choosing when it needs retrieval;
- asking Desktop Core for scoped context;
- deciding whether a response can be handled locally;
- requesting local model inference through approved runtime adapters;
- creating typed proposals for user-data changes;
- explaining what it can and cannot do;
- updating metadata-only memory through Desktop Core when policy allows it.

Yad must never hold direct write-capable database, filesystem, settings, network, or runtime-control access.

## Allowed Read Access

Yad reads through scoped retrieval adapters provided by Desktop Core. Retrieval must be bounded by policy, user settings, token budget, graph depth, and job cancellation.

Allowed read categories:

- selected note content or bounded note chunks;
- note metadata and tags;
- linked-note and backlink context within traversal limits;
- tasks and events relevant to the current request;
- import provenance and import status;
- app-help records that explain Yadra features and settings;
- prior Yad proposal state;
- metadata-only memory events;
- runtime capability profiles;
- user-visible settings that Yad is allowed to explain.

Read adapters must support:

- retrieval limits;
- source references;
- cancellation;
- cycle-aware linked-note traversal;
- no raw content logging;
- clear distinction between user content, system metadata, and app-help records.

Yad should prefer bounded note chunks, metadata, and source references over full-note loading. Full-note retrieval is allowed only when Desktop Core policy decides the request needs it.

## Capability Groups Yad May Request

Yad may request actions only through proposal-capable app-core tool groups. Later implementation issues may define exact command names and payloads, but every command must preserve the boundary in this document.

Allowed proposal-capable groups:

- note creation;
- note body edits;
- metadata changes;
- tag changes;
- note-to-note links;
- directory or organization moves;
- summaries;
- task creation and task updates;
- event creation and event updates;
- import enrichment;
- relationship discovery;
- metadata-only memory writes;
- app-help guidance responses.

Allowed read-only groups:

- settings reads;
- runtime profile reads;
- model capability reads;
- proposal status reads;
- app navigation/help explanations.

Protected groups:

- Yad model selection;
- runtime selection;
- Yad autonomy settings;
- privacy and egress settings;
- approval policy settings;
- destructive account or local-data operations.

Yad may explain protected groups and tell the user where to change them, but it must not change them.

## Prohibited Actions

Yad must not:

- directly write to local storage;
- directly mutate SurrealDB or any future local database;
- directly write to the filesystem;
- directly call external AI providers;
- directly call Yadra Bridge;
- bypass Desktop Core redaction or egress policy;
- change its own model, runtime, safety, autonomy, privacy, or approval settings;
- silently apply a proposal;
- apply a proposal hidden from local audit;
- override read-only mode;
- delete or wipe user data;
- execute shell commands or arbitrary code;
- install plugins, runtimes, or models without an explicit Desktop Core flow;
- persist raw note bodies into memory records;
- log raw user content, prompts, retrieved chunks, or external AI responses.

If a user asks Yad to do a prohibited action, Yad must clearly say it cannot perform that action and, when safe, explain the user-controlled app path that can perform it.

## Proposal Lifecycle

All durable user-data changes requested by Yad must become proposals first unless a future implementation issue proves a narrower operation is read-only.

Proposal states:

- `created`: Yad submitted a proposed action to Desktop Core.
- `pending_review`: the proposal waits for user review.
- `approved`: the user or explicit auto-approval policy approved it.
- `rejected`: the user rejected it.
- `refined`: the user asked Yad to adjust it before application.
- `auto_approved`: Desktop Core accepted it under a user-enabled low-risk policy.
- `applied`: Desktop Core applied it.
- `failed`: Desktop Core could not apply it.
- `expired`: the proposal is no longer valid.

Every proposal must include:

- proposal type;
- affected targets;
- proposed change preview;
- reason;
- confidence;
- risk level;
- approval mode expectation;
- source or retrieval references when available;
- created timestamp;
- user feedback when rejected or refined;
- application result when applied or failed.

Desktop Core validates proposals before they are shown, approved, auto-approved, or applied. Validation must check target existence, policy, protected settings, read-only state, risk level, and stale source references.

## Approval Policy

V0.1 defaults to manual approval for durable changes.

Manual approval must be required by default for:

- note body edits;
- metadata edits;
- directory moves;
- task or event creation;
- import enrichment that changes generated records;
- relationship/link changes when confidence is not high;
- summaries that create or update user-visible notes;
- any proposal touching multiple records.

Auto-approval is allowed only when the user explicitly enables it for low-risk categories. Even then, Desktop Core remains the executor and must record audit state.

Low-risk categories that may be eligible for explicit auto-approval:

- adding non-destructive tags;
- adding low-risk related-note suggestions;
- writing a generated summary to a clearly generated destination;
- refreshing metadata-only memory from a rejected or approved proposal reason.

High-risk and blocked categories must not be auto-approved:

- note body replacement;
- bulk moves;
- destructive deletion;
- protected setting changes;
- external AI egress;
- model/runtime/safety/autonomy changes;
- anything Desktop Core classifies as stale or ambiguous.

## Review Surfaces

Yadra Nest must provide review surfaces for Yad proposals. Exact UI layout is deferred, but the product requirements are fixed.

Review surfaces:

- notification or toast for small, time-sensitive proposals;
- Yad Inbox for pending proposal review and history;
- inline note context for proposals attached to a visible note;
- proposal detail view for preview, reason, confidence, risk, evidence, and affected targets.

Review actions:

- approve;
- reject;
- reject with reason;
- refine;
- apply approved proposal;
- dismiss expired or stale proposal;
- inspect source references.

Rejected proposal reasons may update Yad memory only as metadata-level preference or summary. They must not copy full note bodies into memory.

## Sensitive Data Handling

Yad must operate local-first by default.

Sensitive data rules:

- raw note content stays local unless the user explicitly uses external AI features through Desktop Core policy;
- retrieval results must not be written to logs;
- memory records store preferences, summaries, and decisions, not raw note bodies;
- proposal previews remain local;
- external AI requests require local redaction before egress;
- egress must create local audit metadata;
- Yad cannot bypass user settings or approval policy for external AI;
- imported files follow the same local-first and proposal rules as normal notes.

Yad may ask Desktop Core to escalate to Margin or another external AI path only when local capability is insufficient or user settings request it. Desktop Core performs redaction, approval checks, routing, and audit. Yad receives the result only through Desktop Core.

## Resource And Loop Controls

Yad must be designed for constrained local devices.

Required controls:

- token budgets per turn;
- retrieval result limits;
- linked-note graph depth limits;
- cycle detection;
- cancellable foreground turns;
- cancellable background jobs;
- per-job resource budgets;
- runtime capability checks before expensive work;
- graceful fallback when local model capability is insufficient;
- no unbounded recursive tool loops.

If Yad cannot complete a request within limits, it must explain the limit and offer a smaller or safer next step.

## Acceptance Criteria For Future Implementation Issues

Future implementation issues that claim this boundary must prove:

- Yad has no direct write-capable local storage access;
- Yad reads through scoped retrieval adapters;
- Yad proposals include preview, reason, confidence, risk, targets, and source references where available;
- Desktop Core validates and applies approved proposals;
- manual approval is the default for durable changes;
- auto-approval requires explicit user enablement and is limited to low-risk categories;
- rejected proposals can capture user feedback without storing raw note bodies as memory;
- Yad cannot change model, runtime, autonomy, safety, privacy, egress, or approval settings;
- external AI escalation goes through Desktop Core redaction, approval, routing, and audit;
- retrieval and linked-note traversal are bounded and cycle-aware.

## Risk Areas

- A vague proposal preview can cause users to approve the wrong change.
- Over-broad retrieval can leak unnecessary private context into prompts.
- Auto-approval can damage trust if risk categories are too broad.
- External AI escalation can leak sensitive data if redaction, consent, and audit are weak.
- Background jobs can consume too much CPU, memory, or battery if limits are missing.
- Recursive linked-note traversal can create loops or runaway context growth.
