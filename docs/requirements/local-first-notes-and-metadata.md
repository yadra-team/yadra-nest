# Local-First Notes and Metadata Requirements

## Status

Accepted for v0.1 planning.

## Purpose

This document defines the v0.1 product and architecture requirements for Yadra Nest notes, metadata, imports, read-only mode, linked notes, nested note windows, and Yad's note-related proposal behavior.

It does not choose a markdown parser, editor package, spreadsheet parser, database schema, or UI layout. Those choices must be made by later implementation issues while preserving these requirements.

## Principles

- Notes are local-first. Raw note content stays on the user's device by default.
- Markdown source is the durable user-owned note body.
- Desktop Core owns durable writes, filesystem access, import writes, migrations, and proposal application.
- UI surfaces can edit, preview, navigate, and inspect notes, but they must route durable writes through Desktop Core.
- Yad can analyze notes through bounded retrieval and submit typed proposals. Yad must not directly mutate notes, metadata, folders, tasks, events, links, imports, or storage.
- Imports must preserve source provenance so users can understand where generated records came from.
- Linked-note traversal must be bounded, cycle-aware, and resource-limited.

## V0.1 Markdown Requirements

Yadra Nest must treat markdown as the note source of truth. V0.1 targets a practical markdown core rather than full parity with every external editor extension.

V0.1 must support:

- paragraphs, headings, emphasis, strong text, inline code, links, images, blockquotes, ordered lists, unordered lists, and fenced code blocks;
- tables, task lists, and horizontal rules;
- wikilinks for note-to-note references;
- frontmatter-like metadata at the top of a note;
- sanitized inline HTML for common formatting use cases;
- source editing as text;
- preview rendering that never becomes the durable storage source;
- graceful display of unsupported markdown extensions as visible source text rather than hidden data loss;
- read-only rendering that prevents content and metadata mutation while keeping copy, search, navigation, and inspection available.

Inline HTML is a v0.1 risk area. The renderer must not execute scripts, event handlers, unsafe URLs, remote code, or privileged app commands from note content. Later implementation must define a sanitizer allowlist before enabling rendered HTML.

Deferred beyond v0.1:

- plugin-defined markdown syntax;
- collaborative editing;
- CRDT synchronization;
- full WYSIWYG document storage;
- math rendering as a required feature;
- external editor plugin compatibility.

## V0.1 Metadata Requirements

Metadata must work as user-visible note properties and as system-visible provenance, organization, and AI-assistance context.

V0.1 user-facing metadata must support these property categories:

- text;
- number;
- boolean;
- date;
- time;
- date-time;
- tags;
- single-select values;
- multi-select values;
- URL values;
- related-note references;
- import/source references.

Users must be able to add, edit, remove, and inspect visible metadata properties. System metadata must be distinguishable from user-created metadata so import provenance, indexing state, and AI audit hints do not look like ordinary user fields.

Metadata changes must be durable only after Desktop Core validates and applies them. Yad may propose metadata changes, but the proposal must include target notes, proposed field changes, reason, confidence, and evidence references when available.

Deferred beyond v0.1:

- formulas;
- rollups;
- plugin-defined property types;
- team-shared metadata schemas;
- remote metadata synchronization.

## V0.1 Import Requirements

Yadra Nest must support import with provenance. The first import goal is reliable intake and traceability, not perfect conversion for every file format.

V0.1 import targets:

- markdown files and folders;
- CSV and TSV files;
- Excel-family spreadsheets such as `.xlsx`, `.xlsm`, `.xlsb`, and `.xls` where parser support allows;
- user files that should be attached as local assets even when their content cannot yet be semantically converted.

Every import must record provenance metadata where available:

- original file name;
- original path at import time;
- file size;
- content hash or stable fingerprint when available;
- import timestamp;
- detected file type;
- parser or adapter used;
- generated note, table, task, or asset records related to the source.

Spreadsheet imports must preserve workbook, sheet, row, and column context where parser support allows. The product may represent imported spreadsheet data as generated notes, structured records, attachments, or inspectable import views in later implementation, but users must be able to trace generated content back to its source file.

Import failure must be visible and non-destructive. A failed import must not silently overwrite existing user notes or metadata. Partial import behavior must be explicit: either all changes are rolled back, or imported partial results are clearly marked with failure state and source context.

Yad may analyze imports and propose:

- summaries;
- tags;
- metadata;
- related-note links;
- tasks or events;
- organization changes;
- follow-up questions when import confidence is low.

Yad must not silently rewrite imported content. Any Yad-generated change to imported notes or metadata follows the same proposal and approval rules as ordinary note changes.

Deferred beyond v0.1:

- real-time folder synchronization;
- cloud drive synchronization;
- OCR;
- PDF semantic extraction;
- destructive import reconciliation;
- automatic merge of repeated imports without user-visible policy.

## Read-Only Mode Requirements

Read-only mode must protect note content and metadata from accidental mutation while still allowing useful knowledge work.

Read-only mode must allow:

- selecting and copying text;
- searching within the note;
- opening links and related notes;
- inspecting metadata;
- viewing backlinks and related-note context;
- asking Yad questions about the note;
- receiving Yad proposals.

Read-only mode must block:

- note body edits;
- metadata edits;
- folder moves;
- direct link creation or deletion;
- task/event creation from selected note content unless the user confirms a policy-approved proposal flow.

If Yad proposes a change that targets a read-only note, Desktop Core must not apply the change unless the user exits read-only mode or explicitly confirms a policy-approved exception.

## Linked Notes and Nested Window Requirements

Yadra Nest must support note-to-note linking and related-note exploration without creating infinite traversal loops or unbounded resource usage.

V0.1 must support:

- wikilinks that resolve to notes by stable identity after resolution;
- backlinks;
- related-note surfaces;
- opening linked notes in adjacent or nested note windows;
- tracking traversal origin, visited notes, and traversal depth;
- displaying already-visited notes as already visited instead of expanding them forever;
- lazy loading for linked-note context;
- bounded retrieval for Yad context gathering.

Resource controls must exist at the product requirement level even before implementation details are chosen:

- traversal depth must have a limit;
- linked-note expansion must be cancellable or interruptible;
- large graphs must load progressively;
- Yad retrieval must use bounded chunks and metadata filters instead of loading entire note networks into context.

Deferred beyond v0.1:

- infinite canvas editing;
- full graph-layout editing;
- multi-user graph collaboration;
- unbounded recursive note expansion.

## Yad Proposal Requirements For Notes

Yad is allowed to be proactive, but it must remain proposal-driven for durable user data changes.

V0.1 Yad note-related proposal types:

- add, remove, or update tags;
- add, remove, or update metadata;
- link related notes;
- create a summary;
- propose a folder or organization change;
- create a task from note content;
- create an event from note content;
- suggest import cleanup or enrichment;
- propose a small note-body edit when risk policy allows it.

Every Yad proposal must include:

- proposal type;
- affected targets;
- proposed change preview;
- reason;
- confidence;
- risk level;
- evidence references when available;
- approval mode expectation: manual approval, automatic approval, or blocked by policy.

Manual approval proposals must be visible through an in-app review surface such as a notification, toast, or Yad Inbox. Rejections may include user feedback. Feedback may update Yad memory only as metadata-level preference or summary, not by copying full note bodies into memory.

Automatic approval is allowed only for proposal types and risk levels explicitly enabled by user settings. Yad must not change its own autonomy settings, model settings, or approval policy.

Blocked proposals must explain why they cannot be applied and, when useful, tell the user where they can perform the action manually.

## Acceptance Criteria For Future Implementation Issues

Future implementation issues that claim this requirements document must prove:

- markdown source remains the durable note body;
- supported markdown renders without data loss;
- unsafe HTML is blocked or sanitized before rendering;
- metadata supports the v0.1 property categories;
- user metadata and system metadata are distinguishable;
- imports preserve provenance metadata;
- import failures are visible and non-destructive;
- read-only mode blocks durable note and metadata writes;
- linked-note traversal is cycle-aware and bounded;
- Yad proposals include target, preview, reason, confidence, risk, and evidence references where available;
- Yad cannot directly mutate durable storage.

## Risk Areas

- Markdown HTML can become an injection and privilege-escalation path if sanitizer policy is too broad.
- Spreadsheet imports can create memory pressure, parser compatibility issues, malformed data, and confusing partial results.
- Linked-note cycles can cause infinite loops, UI lockups, or runaway Yad retrieval.
- Large notes and large imported files can exceed local resource budgets.
- Yad proposal previews can mislead users if the diff is incomplete, vague, or disconnected from source evidence.
