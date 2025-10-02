# Task List

## Execution Plan
1. Audit existing MCP server/client architecture and identify extension points for reliability features.
2. Implement hardened diff/patch pipeline with preview/apply/cancel flow and transactional apply semantics.
3. Add task tracking infrastructure and design transactional scene operation abstractions leveraging Godot's UndoRedo.
4. Implement capability scoping and permission enforcement with allowlists and escalation prompts.
5. Integrate structural validation (GDScript lint/format, scene checks) into the patch pipeline.
6. Standardize error model with diagnostics envelope and log capture.
7. Build project context indexer with query APIs and incremental updates.
8. Implement run-project/run-tests headless hooks and reporting.
9. Introduce concurrency control mechanisms (resource mutexes and ETags).
10. Continue with P1/P2 productivity features once P0 milestones are stable.

## P0 — Core reliability, safety, and ergonomics
- [x] Hardened apply-changes & diff/patch pipeline (preview/apply/cancel, atomic apply, rollback, file locks).
- [ ] Transactional scene edits with UndoRedo integration.
- [ ] Capability scoping & permissions (allowlists, read-only vs read-write, escalation prompts).
- [ ] Structural validation for scenes/scripts (lint, gdformat, scene integrity checks).
- [ ] Robust error model & diagnostics (standard envelope, log capture).
- [ ] State/model context indexing (project map) with incremental updates.
- [ ] Godot run/stop with headless test hook (run-project, run-tests).
- [ ] Concurrency control (per-resource mutexes, global write queue, ETag handling).

## P0 — Scripting
- [ ] GDScript static analysis + formatter gate.
- [ ] AST-level code actions (rename/extract/insert/change signature).
- [ ] Typed-API scaffolds & guardrails.
- [ ] Unit + behavior test harness integration.
- [ ] Script dependency graph & dead-code detection.
- [ ] Hot-reload safe patching.

## P0 — TileMaps
- [ ] Tileset validator & fixer.
- [ ] Deterministic TileMap edit API with transactions.
- [ ] Rule-based autotile/terrain application.
- [ ] Snapshot tests for TileMaps.

## P1 — DevX & productivity
- [ ] Refactor-safe edit primitives (AST-level script edits, typed scene ops).
- [ ] Context packs / task presets.
- [ ] Project-wide safe search & replace (AST aware).
- [ ] Asset pipeline helpers.
- [ ] Prompted code actions in editor.
- [ ] Crash repro harness.
- [ ] On-device prompt budgeter & context diet.

## P1 — Scripting
- [ ] Performance hints & micro-profiler hooks.
- [ ] Signal wiring assistant.
- [ ] Script doc generator (API surface).
- [ ] Project-wide safe search/replace (AST aware).
- [ ] Lint presets & style fixer.

## P1 — TileMaps
- [ ] Tileset builder & atlas slicer.
- [ ] Rule-driven paint brushes.
- [ ] Pathfinding grid exporter & validator.
- [ ] Chunked TileMap streaming helpers.
- [ ] Procedural generation templates.

## P2 — Integration & polish
- [ ] Git integration guard rails.
- [ ] "Design → Implement → Test" workflow template.
- [ ] Metrics & telemetry dashboard.
- [ ] Multi-model fallback & tool routing.
- [ ] Tutorials & sample "golden" project.

## P2 — Scripting + TileMaps
- [ ] "Fix-it" quick actions from diagnostics.
- [ ] Scene/TileMap invariants checker.
- [ ] Live TileMap editing during play (guarded).
- [ ] Asset import policy enforcer.
- [ ] Migration helpers for Godot upgrades.
