# Task Plan

## Current Execution Plan
- [ ] Implement remaining MCP command families before closing out roadmap items.
- [ ] Add accompanying server tool definitions and validation schemas.
- [ ] Update documentation and roadmap tracking artifacts.
- [ ] Refresh automated tests spanning new commands and resources.
- [ ] Run full lint, test, and build suites for the MCP server before shipping.

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
- [ ] Support XR platform setup commands for `openxr`, `mobile_vr`, and `webxr` modules.
- [ ] Enable multiplayer session scaffolding and high-level networking helpers aligned with the `multiplayer`, `webrtc`, and `websocket` modules.
- [ ] Provide compression and texture pipeline automation for `astcenc`, `ktx`, and `webp` module workflows.

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
- [ ] `configure_physics_body` to set mass, collision layers/masks, and damping using UndoRedo transactions.
- [ ] `link_joint_bodies` to create and configure Joint2D/Joint3D relationships.
- [ ] `rebuild_physics_shapes` to regenerate convex and trimesh shapes from Mesh resources.
- [ ] `profile_physics_step` to trigger PhysicsServer profiling captures via the editor.
- [ ] `synchronize_navmesh_with_tilemap` to rebake navigation after TileMap edits.

### Command expansions — UI & Interaction
- [ ] `create_theme_override` to author Control theme overrides on nodes.
- [ ] `configure_input_action_context` to batch-edit input actions tied to context-specific gameplay states.
- [x] `configure_camera2d_limits` to adjust limit bounds, smoothing, and new dedicated editor settings for Camera2D nodes.
- [ ] `wire_signal_handler` to connect node signals to target scripts with stub generation.
- [ ] `layout_ui_grid` to auto-arrange Containers using anchor/margin presets from upstream templates.
- [ ] `validate_accessibility` to scan UI scenes for accessibility metadata (focus, labels, navigation).

### Command expansions — Audio & Media
- [x] `list_audio_buses` to enumerate audio routing, volume, and effect state for review.
- [x] `configure_audio_bus` to insert/remove effects and adjust sends on the AudioServer.
- [x] `author_audio_stream_player` to attach AudioStream resources with autoplay, 3D attenuation, and bus routing.
- [x] `generate_dynamic_music_layer` to build InteractiveMusic transition tables.
- [ ] `analyze_waveform` to produce basic waveform/loudness summaries for preview.
- [ ] `batch_import_audio_assets` to drive import presets for WAV/OGG via the editor importer.

### Command expansions — Rendering & Assets
- [ ] `generate_material_variant` to clone materials with parameter overrides and optionally baked textures.
- [ ] `compile_shader_preview` to validate shader code via the RenderingServer and return compilation diagnostics.
- [ ] `unwrap_lightmap_uv2` to invoke the lightmapper/xatlas UV unwrap pipeline from MCP.
- [ ] `optimize_mesh_lods` to call meshoptimizer decimation for LOD generation.
- [ ] `configure_environment` to edit WorldEnvironment settings (sky, fog, lighting) with undo support.
- [ ] `preview_environment_sun_settings` to drive the sun/environment preview popup with undo-aware adjustments.

### Command expansions — Project & Editor automation
- [ ] `configure_project_setting` guard-railed writes to `ProjectSettings` with typed validation.
- [ ] `run_godot_headless` to launch deterministic headless playtests with log capture.
- [ ] `capture_editor_profile` to stream Godot editor profiling data (CPU/GPU) back to MCP clients.
- [ ] `manage_editor_plugins` to enable/disable addons and surface compatibility metadata.
- [ ] `snapshot_scene_state` to save per-scene diffs for review before patching.

## Research & dependencies
- [ ] Review Godot upstream modules (animation, physics, audio, rendering) for exposed editor APIs enabling remote control.
- [ ] Document authentication and permission considerations for higher-impact commands (e.g., headless run, profiling).
- [ ] Align JSON schema for new resources/commands with FastMCP tool metadata to maintain discoverability.

