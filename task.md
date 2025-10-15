# Task Plan

## Latest Session Tasks
- [x] Investigate the reported preload failure for `command_handler.gd` in the MCP server startup logs.
- [x] Replace any legacy inline conditional syntax that prevents `command_handler.gd` from parsing under Godot 4.
- [x] Run the available automated test suite to ensure no regressions after the parser fix.
- [x] Add explicit preloads for MCP command processors in the command handler to resolve editor parse errors.
- [x] Run a Godot CLI lint/check to validate MCP scripts load cleanly after the preload changes *(fails: multiple pre-existing parse errors across MCP command scripts when executed with Godot v4.2.2 headless)*.
- [x] Diagnose Godot MCP startup errors related to `command_handler.gd` preloading and typed variable inference.
- [x] Update GDScript typing and resource loading so `mcp_server.gd` and `command_handler.gd` parse without errors.
- [x] Run server-side tests/lints to verify stability after parser fixes.
- [x] Replace the inline `?` conditional in `addons/godot_mcp/mcp_server.gd` with Godot's ternary syntax to resolve the parse error.
- [x] Run automated tests to ensure the MCP addon remains stable after the ternary syntax fix.
- [x] Investigate the GDScript parse errors reported for `mcp_server.gd` and `command_handler.gd`.
- [x] Correct the stray indentation block in `addons/godot_mcp/mcp_server.gd` so the parser no longer encounters unexpected indents.
- [x] Normalize indentation in `addons/godot_mcp/command_handler.gd` to use spaces consistently within affected functions.
- [ ] Run available automated lint/test scripts to confirm the MCP addon loads without indentation issues (blocked: legacy `verify_fixes.sh` flags legitimate ternary usage and exits non-zero).
- [x] Replace invalid inline conditional expressions with Godot 4 ternary syntax across affected MCP addon scripts.
- [x] Normalize indentation to tabs in modified command processors to satisfy Godot parser expectations.
- [x] Run available automated tests or lint scripts to validate the MCP addon after fixes.
- [x] Replace Python-style inline conditional expressions with ternary syntax throughout the MCP addon scripts to restore parser compatibility.
- [x] Recompute command handler/server command ID coercion using ternaries to avoid inline conditional parsing failures.
- [x] Attempt Godot CLI validation of addon scripts *(fails: Godot v4.2.2 headless reports legacy ternary syntax, indentation, and base processor parse errors across existing scripts)*.
- [x] Add EditorInterface-aware node create/delete flows with selection updates and structured responses.
- [x] Support nested node property updates with typed conversion and transaction logging.
- [x] Normalize GDScript indentation to resolve parser errors in command processors.
- [x] Guard command identifier coercion in the MCP command handler.
- [x] Execute server vitest suite to confirm MCP endpoints remain stable.
- [x] Restore runtime loading of MCP command processor scripts in `command_handler.gd`.
- [ ] Run automated tests after reinstating command processor loading to ensure stability (blocked: missing `websockets` dependency for pytest collection).

## Current Execution Plan
- [x] Audit existing MCP command processor coverage to confirm available operations.
- [x] Reinstate command handler routing so processors execute incoming commands.
- [x] Bridge JSON-RPC requests through the Godot MCP server and transform responses.
- [x] Capture validation via automated tests or tooling runs for the restored pipeline.
- [x] Deliver rendering and environment command processors covering material variants, shader previews, UV2 unwrapping, mesh LOD optimization, and environment configuration/preview flows.
- [x] Extend the Godot addon with XR, multiplayer, and compression command processors plus structured logging hooks.
- [x] Publish matching MCP server tool definitions and resources so the new commands are discoverable.
- [x] Update README and reference docs alongside roadmap trackers to reflect the new capabilities.
- [x] Expand Vitest coverage and rebuild the distribution bundle for the new tooling.
- [x] Run lint, test, and build suites in the server package prior to shipping (lint script not available; attempt documented).

## Completed
- [x] Research additional Godot editor features that expand MCP automation options
- [x] Implement new node group management commands in the Godot MCP plugin
- [x] Implement new input map management commands in the Godot MCP plugin
- [x] Expose new commands through the MCP server tool definitions
- [x] Update README with a comprehensive abilities list and new capabilities
- [x] Update command documentation to include the new tooling
- [x] Run TypeScript build to ensure the server compiles after changes
- [x] Ship read-only audio bus inspection via AudioServer to expose routing and effect metadata

## Upcoming — Align MCP coverage with core Godot systems
- [x] Add navigation map and agent tooling so MCP can read, bake, and edit resources backed by the `navigation_2d` and `navigation_3d` modules.
- [x] Extend scene commands to support physics body, area, and joint configuration in line with `godot_physics_2d` and `godot_physics_3d` modules.
- [x] Provide CSG and GridMap manipulation helpers covering the `csg` and `gridmap` modules for rapid level prototyping.
- [x] Integrate GLTF and FBX import automation to mirror workflows supported by the `gltf` and `fbx` modules.
- [x] Surface audio bus, interactive music, and audio stream configuration commands to match `interactive_music`, `ogg`, and `vorbis` module capabilities.
  - [x] Deliver `configure_audio_bus` editing support via MCP project commands and tooling.
  - [x] Expose interactive music graph authoring helpers for layered playback.
  - [x] Provide audio stream player creation/configuration utilities.
- [x] Add shader and material editing pipelines that understand `glslang`, `lightmapper_rd`, and `meshoptimizer` module outputs.
- [x] Support XR platform setup commands for `openxr`, `mobile_vr`, and `webxr` modules.
- [x] Enable multiplayer session scaffolding and high-level networking helpers aligned with the `multiplayer`, `webrtc`, and `websocket` modules.
- [x] Provide compression and texture pipeline automation for `astcenc`, `ktx`, and `webp` module workflows.

## New MCP Capability Roadmap — Derived from Godot upstream modules
### High-priority resource endpoints
- [x] `godot://animation/state-machines` — surface AnimationTree graphs, state transitions, and blend spaces for inspection.
- [x] `godot://animation/tracks` — expose timeline tracks from AnimationPlayer resources for read/write editing.
- [x] `godot://physics/world` — provide a structured snapshot of physics bodies, areas, and joints per space.
- [x] `godot://ui/theme` — fetch active theme metadata, styles, and font resources for UI audits.
- [x] `godot://audio/buses` — return audio bus layout, effects stack, and mute/solo state for project mixes.

### Command expansions — Animation & VFX
- [x] `list_animation_players` to enumerate AnimationPlayer content across the edited scene.
- [x] `edit_animation` to author AnimationPlayer content.
- [x] `configure_animation_tree` to adjust AnimationTree nodes, blend amounts, and parameters.
- [x] `bake_skeleton_pose` to capture Skeleton3D poses into an animation resource.
- [x] `generate_tween_sequence` for programmatic Tween node timelines.
- [x] `sync_particles_with_animation` to align GPUParticles3D emission with AnimationPlayer tracks.

### Command expansions — Physics & Navigation
- [x] `configure_physics_body` to set mass, collision layers/masks, and damping using UndoRedo transactions.
- [x] `link_joint_bodies` to create and configure Joint2D/Joint3D relationships.
- [x] `rebuild_physics_shapes` to regenerate convex and trimesh shapes from Mesh resources.
- [x] `profile_physics_step` to trigger PhysicsServer profiling captures via the editor.
- [x] `synchronize_navmesh_with_tilemap` to rebake navigation after TileMap edits.

### Command expansions — UI & Interaction
- [x] `create_theme_override` to author Control theme overrides on nodes.
- [x] `configure_input_action_context` to batch-edit input actions tied to context-specific gameplay states.
- [x] `configure_camera2d_limits` to adjust limit bounds, smoothing, and new dedicated editor settings for Camera2D nodes.
- [x] `wire_signal_handler` to connect node signals to target scripts with stub generation.
- [x] `layout_ui_grid` to auto-arrange Containers using anchor/margin presets from upstream templates.
- [x] `validate_accessibility` to scan UI scenes for accessibility metadata (focus, labels, navigation).

### Command expansions — Audio & Media
- [x] `list_audio_buses` to enumerate audio routing, volume, and effect state for review.
- [x] `configure_audio_bus` to insert/remove effects and adjust sends on the AudioServer.
- [x] `author_audio_stream_player` to attach AudioStream resources with autoplay, 3D attenuation, and bus routing.
- [x] `generate_dynamic_music_layer` to build InteractiveMusic transition tables.
- [x] `analyze_waveform` to produce basic waveform/loudness summaries for preview.
- [x] `batch_import_audio_assets` to drive import presets for WAV/OGG via the editor importer.

### Command expansions — Rendering & Assets
- [x] `generate_material_variant` to clone materials with parameter overrides and optionally baked textures.
- [x] `compile_shader_preview` to validate shader code via the RenderingServer and return compilation diagnostics.
- [x] `unwrap_lightmap_uv2` to invoke the lightmapper/xatlas UV unwrap pipeline from MCP.
- [x] `optimize_mesh_lods` to call meshoptimizer decimation for LOD generation.
- [x] `configure_environment` to edit WorldEnvironment settings (sky, fog, lighting) with undo support.
- [x] `preview_environment_sun_settings` to drive the sun/environment preview popup with undo-aware adjustments.

### Command expansions — Project & Editor automation
- [x] `configure_project_setting` guard-railed writes to `ProjectSettings` with typed validation.
- [x] `run_godot_headless` to launch deterministic headless playtests with log capture.
- [x] `capture_editor_profile` to stream Godot editor profiling data (CPU/GPU) back to MCP clients.
- [x] `manage_editor_plugins` to enable/disable addons and surface compatibility metadata.
- [x] `snapshot_scene_state` to save per-scene diffs for review before patching.

## Research & dependencies
- [x] Review Godot upstream modules (animation, physics, audio, rendering) for exposed editor APIs enabling remote control.
- [x] Document authentication and permission considerations for higher-impact commands (e.g., headless run, profiling).
- [x] Align JSON schema for new resources/commands with FastMCP tool metadata to maintain discoverability.

