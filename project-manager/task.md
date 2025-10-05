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
- [x] Transactional scene edits with UndoRedo integration.
- [ ] Capability scoping & permissions (allowlists, read-only vs read-write, escalation prompts).
  - [x] Enforce write allowlist for patch pipeline touching scripts/scenes/docs.
  - [x] Introduce escalation prompts & per-command roles for high-risk operations.
- [ ] Structural validation for scenes/scripts (lint, gdformat, scene integrity checks).
- [ ] Robust error model & diagnostics (standard envelope, log capture).
- [x] State/model context indexing (project map) with incremental updates.
  - [x] Server-side cached project index with glob queries and MCP resource exposure.
- [ ] Godot run/stop with headless test hook (run-project, run-tests).
- [ ] Concurrency control (per-resource mutexes, global write queue, ETag handling).

## Current Iteration — Safety Controls
- [x] Implement persistent permission escalation queue for write operations that miss allowlist.
- [x] Expose MCP tools to review and resolve pending escalation requests.
- [x] Update capability guard to surface escalation identifiers to clients.

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

## Upstream Alignment — Godot master insights
- [ ] Surface Godot editor debugger warnings exposed in `editor/debugger/editor_debugger_node.cpp` as structured diagnostics via MCP.
- [ ] Mirror the official `modules/gdscript/tools/lint` checks through the structural validation gate.
- [ ] Track upstream `scene/3d` node additions (e.g. `voxel_gi` changes) to keep node tool metadata in sync.

## Upstream Alignment — Module coverage backlog
- [x] Navigation: expose navmesh baking, region, and agent configuration endpoints that wrap `modules/navigation_2d` and `modules/navigation_3d` APIs.
- [ ] Physics: add inspection and mutation helpers for `godot_physics_2d`, `godot_physics_3d`, and `jolt_physics` bodies, joints, and areas.
- [ ] Rendering assets: support GLTF/FBX import workflows leveraging `modules/gltf`, `modules/fbx`, and `modules/xatlas_unwrap` utilities.
- [ ] Materials & light transport: surface shader, lightmap, and mesh optimization pipelines aligned with `modules/glslang`, `modules/lightmapper_rd`, and `modules/meshoptimizer`.
- [ ] Audio: automate audio bus, stream, and interactive music tooling with `modules/interactive_music`, `modules/ogg`, and `modules/vorbis`.
- [ ] XR & VR: implement project configuration flows for `modules/openxr`, `modules/mobile_vr`, and `modules/webxr`.
- [ ] Multiplayer & networking: add project scaffolds and live session utilities for `modules/multiplayer`, `modules/webrtc`, and `modules/websocket`.
- [ ] Compression & texture pipelines: orchestrate transcoding and compression tasks across `modules/astcenc`, `modules/ktx`, and `modules/webp`.
