# Godot MCP (Model Context Protocol)

A comprehensive integration between Godot Engine and AI assistants using the Model Context Protocol (MCP). This plugin allows AI assistants to interact with your Godot projects, providing powerful capabilities for code assistance, scene manipulation, and project management.

## Features

- **Full Godot Project Access**: AI assistants can access and modify scripts, scenes, nodes, and project resources
- **Two-way Communication**: Send project data to AI and apply suggested changes directly in the editor
- **Capability-Aware Editing**: Patch application is scoped to an allowlisted set of directories, file types, and critical assets for safer automation
- **Project Indexing & Query**: Cached project map with glob-style queries for quick discovery of files and directories
- **Node Workflow Enhancements**: Rename nodes, manage group membership, and enumerate group contents with full undo/redo support
- **Input Map Automation**: Inspect, add, and remove input actions or individual input events without leaving the editor
- **Headless Execution & Profiling**: Launch deterministic headless runs, capture editor performance snapshots, and manage plugin state with audit-friendly logs
- **Command Categories**:
  - **Node Commands**: Create, modify, and manage nodes in your scenes
  - **Script Commands**: Edit, analyze, and create GDScript files
  - **Scene Commands**: Manipulate scenes and their structure
  - **Physics Configuration**: Configure physics bodies, areas, and joints with transaction-aware updates
  - **CSG & GridMap Helpers**: Prototype boolean geometry and GridMap layouts with undo-safe editing primitives
  - **Project Commands**: Access project settings and resources
  - **Editor Commands**: Control various editor functionality
  - **XR Commands**: Inspect interfaces, initialize platforms, and persist XR project settings
  - **Multiplayer Commands**: Spin up ENet/WebSocket/WebRTC peers and spawn network-ready scenes
  - **Compression Commands**: Manage GPU texture presets, import profiles, and batch reimports

## Godot Versions

The addon runs on Godot 4.4 and newer. It is built and tested on Godot 4.7, and checked to load on 4.4.1. Tools for features that arrived after 4.4 check the running engine and say which version they need:

| Feature | Needs |
|---|---|
| `get_godot_errors`, stencil outlines, accessibility names, bone aim/copy constraints | Godot 4.5+ |
| `setup_ik_chain` (TwoBoneIK3D, FABRIK3D, CCDIK3D, JacobianIK3D, SplineIK3D) | Godot 4.6+ |
| `add_touch_controls` joystick (VirtualJoystick), `hdr_output` setting | Godot 4.7+ |

## Quick Setup

### 1. Clone the Repository

```bash
git clone https://github.com/ee0pdt/godot-mcp.git
cd godot-mcp
```

### 2. Set Up the MCP Server

```bash
cd server
npm install
npm run build
# Return to project root
cd ..
```

### 3. Set Up Claude Desktop

1. Edit or create the Claude Desktop config file:
   ```bash
   # For macOS
   nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

2. Add the following configuration (or use the included `claude_desktop_config.json` as a reference):
   ```json
   {
	 "mcpServers": {
	   "godot-mcp": {
		 "command": "node",
		 "args": [
		   "PATH_TO_YOUR_PROJECT/server/dist/index.js"
		 ],
		 "env": {
		   "MCP_TRANSPORT": "stdio"
		 }
	   }
	 }
   }
   ```
   > **Note**: Replace `PATH_TO_YOUR_PROJECT` with the absolute path to where you have this repository stored.

3. Restart Claude Desktop

### 4. Open the Example Project in Godot

1. Open Godot Engine
2. Select "Import" and navigate to the cloned repository
3. Open the `project.godot` file
4. The MCP plugin is already enabled in this example project

## Using MCP with Claude

After setup, you can work with your Godot project directly from Claude using natural language. Here are some examples:

### Example Prompts

```
@mcp godot-mcp read godot://script/current

I need help optimizing my player movement code. Can you suggest improvements?
```

```
@mcp godot-mcp run get-scene-tree

Add a cube in the middle of the scene and then make a camera that is looking at the cube.
```

```
@mcp godot-mcp read godot://scene/current

Create an enemy AI that patrols between waypoints and attacks the player when in range.
```

### Natural Language Tasks Claude Can Perform

- "Create a main menu with play, options, and quit buttons"
- "Add collision detection to the player character"
- "Implement a day/night cycle system"
- "Refactor this code to use signals instead of direct references"
- "Debug why my player character falls through the floor sometimes"

## Available Resources and Commands

### Resource Endpoints:
- `godot://script/current` - The currently open script
- `godot://scene/current` - The currently open scene
- `godot://project/info` - Project metadata and settings
- `godot://project/index` - Cached project file and directory index snapshot
- `godot://audio/buses` - Project audio bus layout, routing metadata, and effect stacks
- `godot://physics/world` - Live snapshot of 2D/3D physics spaces with per-space gravity, body/area/joint inventories, and configuration metadata.
- `godot://animation/state-machines` - Inspect AnimationTree graphs, blend spaces, and transitions for the active scene.
- `godot://animation/tracks` - Read AnimationPlayer timelines, tracks, and keyframes with keyframe metadata.
- `godot://xr/interfaces` - Report available XR interfaces, initialization state, and capabilities.
- `godot://multiplayer/state` - Summarize the active SceneTree multiplayer peer, connectivity, and authority configuration.
- `godot://assets/compression-presets` - Surface configured texture compression presets and import profiles.

#### Upcoming Resource Endpoints (sourced from godotengine/godot)
- `godot://ui/theme` - Surface the currently applied UI Theme resources, styles, and fonts for audit.

### Command Categories:

#### Node Commands
- `create_node` - Create a new node under a specified parent path
- `delete_node` - Delete a node from the edited scene
- `update_node_property` - Change a node property with undo support
- `get_node_properties` - Inspect the properties of a node, or of several nodes in one call
- `list_nodes` - Enumerate the children of a node in the scene tree
- `rename_node` - Rename a node while preserving undo history
- `add_node_to_group` - Add a node to a named group (optionally persisting to the scene file)
- `remove_node_from_group` - Remove a node from a group with undo/redo
- `create_theme_override` - Author Control theme overrides with undo-safe transactions
- `wire_signal_handler` - Connect node signals to scripted methods with optional stub generation
- `layout_ui_grid` - Apply column-based layouts to Control containers with consistent spacing
- `validate_accessibility` - Inspect Control nodes for missing focus, labels, or accessible descriptions
- `list_node_groups` - List all groups the node currently belongs to
- `list_nodes_in_group` - Enumerate nodes that are members of a group in the edited scene

#### Workflow Commands
- `describe_class` - Godot class reference (properties with types and defaults, methods, signals, enums) for engine classes and project `class_name` scripts
- `search_project` - Search project text files for text or a regex; returns `file:line: text`
- `replace_in_script` - Replace an exact piece of a `.gd`/`.gdshader` file (cheaper than rewriting it); reports compile errors
- `list_signal_connections` / `disconnect_signal` - Show a node's connections in and out; remove one (undo-aware)
- `manage_autoloads` - List, add or remove autoload singletons
- `configure_game_settings` - Game name, main scene, icon, window size, stretch, background color, texture filter, gravity, physics engine (Jolt), physics rate and interpolation, renderer, vsync, HDR output, layer names
- `set_control_layout` - UI anchor presets (full_rect, center, top_right, ...), margin, size, size flags (undo-aware)
- `create_inherited_scene` - New scene inheriting another (Godot's "New Inherited Scene")
- `save_branch_as_scene` - Godot's "Save Branch as Scene": the branch becomes its own scene and an instance takes its place, keeping its connections
- `capture_scene_image` - PNG picture of the open scene (needs the editor window, not `--headless`)
- `export_project` - Export for macOS, Windows, Linux or Web with the installed export templates (admin; creates a preset if needed)
- `get_script_outline` - A script's extends, signals, exports, vars, consts, enums and funcs with line numbers
- `move_project_file` - Move or rename a file with its `.import`/`.uid` and rewrite references to it
- `configure_particles_2d` - Create or tune CPU/GPU 2D particles from a preset (dust, sparkle, rain, snow, confetti, burst) (undo-aware)
- `manage_translations` - Translation CSV (keys x locales), registered translations and fallback locale
- `select_in_editor` - Select a node and show it in the Inspector for the person at the editor
- `run_game_tests` - Run `extends SceneTree` test scripts headless and report pass/fail (admin)
- `capture_game_frame` - Run a scene in a game window, optionally holding inputs, and return a frame as a picture (admin)
- `create_project` - New Godot project with a main scene and the MCP addon enabled (admin)
- `check_project` - Health check: missing main scene/autoload files, links to missing files, scripts that do not compile, undefined input actions
- `find_unused_files` - Assets, scenes, resources and scripts nothing refers to
- `replace_in_project` - Find and replace across project files with a preview (dry run) and compile checks
- `set_collision_layers` - Collision layer and mask by layer name or number
- `fit_collision_shape` - Size a body's collision shape to its sprites, polygons or meshes (2D and 3D)
- `create_canvas_shader` - 2D shader effects: outline, flash, dissolve, wave, grayscale
- `generate_sfx` - Synthesized retro sound effects (jump, coin, hit, explosion, laser, powerup, blip, footstep) saved as WAV
- `paint_tilemap_ascii` - Paint a TileMapLayer from text rows and a legend
- `build_blockout_3d` - 3D level blockout: boxes, spheres, cylinders, capsules with materials and collision
- `setup_2d_lighting` - CanvasModulate darkness plus PointLight2D glows
- `profile_game` - Run a scene and report frame time, draw calls, nodes and memory (admin)
- `import_asset_files` - Copy images, sounds, fonts or models from this computer into the project (admin)

#### Authoring Commands
- `create_tileset_2d` - TileSet from a sprite sheet: one tile per grid cell (empty cells skipped), optional full-tile collision, optionally given to a TileMapLayer (undo-aware)
- `create_sprite_frames` - SpriteFrames for AnimatedSprite2D/3D from a grid sprite sheet: named animations by row or frame list, fps, loop, autoplay (undo-aware)
- `undo_redo` - Undo or redo the last editor actions, the same as the editor's Undo/Redo, and say which actions changed
- `get_resource_properties` - Read the saved properties of a `.tres`/`.res` file
- `update_resource_properties` - Set properties on a `.tres`/`.res` file and save it; one bad value changes nothing (not on the undo history)

#### Newer Godot Features
- `describe_skeleton` - A Skeleton3D's bone tree, its modifiers, and arm/leg chains ready for IK
- `add_skeleton_bones` - Build a rig from scratch: add bones to a Skeleton3D (a list makes a chain, each bone's rest offset from its parent); undo-aware
- `setup_ik_chain` - Inverse kinematics: two-bone (arms, legs) with auto-made target and pole markers, FABRIK, CCDIK, Jacobian, spline (4.6+)
- `add_bone_constraint` - A bone aims at, copies, or smoothly looks at a node or another bone (aim/copy 4.5+, look_at 4.4+)
- `setup_spring_bones` - Hair, tails and capes that swing (SpringBoneSimulator3D), with collision spheres on bones
- `set_stencil_effect` - Outline a 3D object, or show it through walls (x-ray), with the stencil buffer (4.5+)
- `create_spatial_shader` - 3D shader effects: toon, rim_glow, hologram, dissolve, wind_sway
- `add_touch_controls` - Phone controls: VirtualJoystick bound to move actions plus round touch buttons; hidden on desktop
- `set_accessibility_info` - Screen-reader names and descriptions on UI controls, or auto-fill the missing ones (4.5+)
- `create_path` - Path2D/Path3D through points, smooth or closed
- `place_along_path` - Copies of a scene along a path by count or spacing, turned to follow it
- `snap_to_ground` - Drop nodes onto the ground below them (like Snap Object to Floor); can remove ones that land in the sea or on peaks
- `build_mesh_library` - GridMap MeshLibrary from a scene of mesh tiles (with collision and navmesh), like Export As MeshLibrary

#### Asset Pipeline
- `inspect_model` - What a .glb/.gltf/.fbx/.blend/.obj model holds: meshes, materials, skeletons, animations, import settings
- `configure_model_import` - Model import settings, then reimport: root type and scale, collision on meshes, looping animations, humanoid bone map (Mixamo, VRM, Unreal and Blender rigs share animations), import as animation library, extract materials, lightmap UVs
- `add_animation_library` - Animations from a library or model onto an AnimationPlayer; reports how many tracks find their bones
- `generate_mesh_collision` - Trimesh, convex or multiple-convex collision from 3D meshes
- `sprite_to_polygon` - A Sprite2D's visible pixels traced into collision, a light occluder or a textured Polygon2D
- `bake_csg` - CSG blockout to a plain mesh plus collision (4.4+)
- `generate_terrain_3d` - Noise terrain colored by height, HeightMapShape3D collision, optional island and water
- `generate_ui_theme` - A full UI Theme (buttons, panels, fields, sliders, tabs...) from a primary and a background color

#### Polish and Prototyping
- `create_ragdoll` - PhysicalBoneSimulator3D with capsule PhysicalBone3Ds per bone (Create Physical Skeleton), mass by bone length
- `add_screen_effect` - Full-screen vignette, damage flash, CRT, pixelate, chromatic aberration, grayscale, blur, color grade; effects stack
- `setup_day_night_cycle` - Looping sun, light color and sky colors from sunrise to night, with no script
- `convert_to_multimesh` - Many copies of one mesh merged into a MultiMeshInstance3D (one draw call)
- `configure_texture_import` - Image import presets (pixel_art, ui, 3d, normal_map), compression, mipmaps, size limit
- `create_audio_randomizer` - AudioStreamRandomizer from several sounds with pitch and volume variation
- `generate_placeholder_art` - Antialiased PNG sprites for prototypes: shapes, coin, star, heart, crate, beveled tile, character with eyes

#### Script Commands
- `create_script` - Create a new GDScript file and optionally attach it to a node (fails if the file exists unless `overwrite: true`)
- `edit_script` - Replace the contents of an existing `.gd` script file, or change one exact piece with `find` + `replace`
- `get_script` - Fetch a script by file path or by attached node
- `create_script_template` - Generate a GDScript skeleton with common callbacks

Script paths must stay inside the project: anything that resolves outside `res://` (for example `res://../escape.gd`) is rejected. Check it headlessly with `godot --headless --path . --script res://test_script_path_guard.gd`.

#### Scene Commands
- `create_scene` - Create a new scene with an optional root node type
- `save_scene` - Save the currently edited scene to disk
- `open_scene` - Open a scene in the editor
- `get_current_scene` - Report information about the open scene
- `get_project_info` - Return the project name, version, and active scene details
- `create_resource` - Create and serialize a new resource asset
- `begin_scene_transaction` - Start a named transaction for batching scene edits
- `commit_scene_transaction` - Commit a pending scene transaction
- `rollback_scene_transaction` - Roll back a transaction (even after commit)
- `list_scene_transactions` - List transaction identifiers that are currently tracked
- `configure_physics_body` - Adjust PhysicsBody2D/3D properties with undo/redo
- `configure_physics_area` - Update Area2D/Area3D monitoring, gravity, and masks
- `configure_physics_joint` - Rewire Joint2D/3D connections and constraint limits
- `link_joint_bodies` - Connect joints to specific physics bodies and optionally tweak constraint settings
- `rebuild_physics_shapes` - Regenerate CollisionShape3D resources from Mesh nodes or assets
- `profile_physics_step` - Capture PhysicsServer and Performance metrics for quick diagnostics
- `configure_csg_shape` - Tweak CSG combiners and primitives with undo/redo support
- `configure_material_resource` - Create/update Material resources, apply glslang shader code, bind lightmapper textures, and persist meshoptimizer metadata
- `paint_gridmap_cells` - Stamp MeshLibrary items into GridMap coordinates in batches
- `clear_gridmap_cells` - Remove items from GridMap cells while preserving undo history
- `author_audio_stream_player` - Create or configure AudioStreamPlayer nodes with stream assignments and playback settings
- `author_interactive_music_graph` - Build or update AudioStreamInteractive resources with layered clips and transition logic
- `generate_dynamic_music_layer` - Layer a new clip onto an interactive music resource with configurable entry/exit transitions
- `analyze_waveform` - Produce amplitude, RMS, and crest factor summaries for AudioStream resources with optional envelope bins
- `batch_import_audio_assets` - Apply import presets or parameter overrides to audio files and trigger a batch reimport

#### Animation Commands
- `list_animation_players` - Enumerate AnimationPlayer nodes, active playback settings, and contained animations.
- `describe_animation_tracks` - Inspect AnimationPlayer track configurations with optional keyframe timing and values.
- `describe_animation_state_machines` - Summarize AnimationTree state machines, nested graphs, and transition metadata.
- `edit_animation` - Apply structured operations to animation resources (tracks, keys, properties) with undo/redo support.
- `configure_animation_tree` - Update AnimationTree properties, blend parameters, and state playback targets.
- `bake_skeleton_pose` - Capture Skeleton2D/3D poses into an Animation resource at a specified timestamp.
- `generate_tween_sequence` - Build Animation timelines from tween-style step definitions.
- `sync_particles_with_animation` - Align particle emission properties and animation keys with an animation clip.

#### Navigation Commands
- `list_navigation_maps` - Summarize NavigationRegion2D/3D nodes and their resources
- `list_navigation_agents` - Inspect NavigationAgent2D/3D avoidance and target settings
- `bake_navigation_region` - Trigger baking on a navigation region (threaded by default)
- `update_navigation_region` - Change navigation region node properties with undo/redo
- `update_navigation_resource` - Edit NavigationPolygon or NavigationMesh resource properties
- `update_navigation_agent` - Adjust NavigationAgent parameters with undo/redo
- `synchronize_navmesh_with_tilemap` - Rebake TileMap navigation layers and optional navigation regions

#### Project Commands
- `refresh_project_index` - Rebuild the cached project index snapshot
- `query_project_index` - Query the cached project index with glob patterns
- `list_input_actions` - List every input action and associated events
- `add_input_action` - Create or overwrite an input action definition
- `remove_input_action` - Delete an input action from the project settings
- `add_input_event_to_action` - Register an additional event on an existing input action
- `remove_input_event_from_action` - Remove an input event by index or matching fields
- `configure_input_action_context` - Batch manage related input actions and persist context metadata
- `list_audio_buses` - Enumerate the audio bus graph with volume, routing, and effect status
- `configure_audio_bus` - Adjust audio bus volume, routing, and effect enablement with optional persistence
- `configure_project_setting` - Guard-railed ProjectSettings writes with type-aware validation and optional persistence

#### XR Commands
- `list_xr_interfaces` - Enumerate XR interfaces, initialization state, and capabilities exposed by the project build.
- `initialize_xr_interface` - Initialize a named XR interface and optionally promote it to the primary interface.
- `shutdown_xr_interface` - Gracefully end the XR session for a specific interface and release resources.
- `save_xr_project_settings` - Persist XR-related ProjectSettings entries for deterministic editor configuration.

#### Multiplayer Commands
- `get_multiplayer_state` - Capture the SceneTree multiplayer snapshot including connected peers and authority metadata.
- `create_multiplayer_peer` - Configure ENet, WebSocket, or WebRTC peers in server/client mode for playtesting.
- `teardown_multiplayer_peer` - Disconnect and clear the active multiplayer peer returning the scene to single-player mode.
- `spawn_multiplayer_scene` - Instantiate a PackedScene and optionally assign multiplayer authority for quick session setup.

#### Compression Commands
- `configure_texture_compression` - Apply GPU compression options scoped to a platform and optionally save to disk.
- `batch_reimport_textures` - Reimport a batch of textures so new compression presets are applied consistently.
- `create_texture_import_preset` - Register reusable import presets for ASTC/KTX/WebP oriented workflows.
- `list_texture_compression_settings` - Inspect the current compression presets and import settings stored in ProjectSettings.

#### Rendering Commands
- `generate_material_variant` - Duplicate a Material resource, apply property and shader overrides, and optionally save it to disk.
- `compile_shader_preview` - Compile Godot shader source and surface uniform/default texture metadata without touching files.
- `unwrap_lightmap_uv2` - Invoke ArrayMesh lightmap unwrapping for a Mesh resource or MeshInstance3D node with optional saving.
- `optimize_mesh_lods` - Produce simplified meshes for requested LOD ratios and optionally assign or persist the generated meshes.
- `configure_environment` - Update Environment ambient light, fog, sky, and sun scattering properties with undo transactions.
- `preview_environment_sun_settings` - Inspect current fog sun values and preview overrides before committing configuration changes.

#### Patch Commands
- `preview_patch` - Preview a diff before it is applied
- `apply_patch` - Apply a previously previewed diff (requires admin approval)
- `cancel_patch` - Discard a pending diff preview

#### Permission Commands
- `list_permission_escalations` - List permission escalation requests, newest first, one line each (`limit`, default 20)
- `resolve_permission_escalation` - Deny (withdraw) a recorded escalation request. It cannot approve; approval is human-only (see below)

#### Editor Commands
- `execute_editor_script` - Run arbitrary GDScript in the editor context (requires admin approval)
- `run_godot_headless` - Launch the Godot editor binary headlessly and capture combined output for deterministic test runs
- `capture_editor_profile` - Gather CPU, rendering, and memory metrics from the active editor session
- `manage_editor_plugins` - Enable or disable project addons with optional persistence and structured logging
- `snapshot_scene_state` - Capture the edited scene tree, node metadata, and key properties for pre-change review

#### Planned Command Expansions (roadmap)
- **Animation & VFX** *(delivered)*: `edit_animation`, `configure_animation_tree`, `bake_skeleton_pose`, `generate_tween_sequence`, `sync_particles_with_animation`.
- **Physics & Navigation**: `configure_physics_body`, `link_joint_bodies`, `rebuild_physics_shapes`, `profile_physics_step`, `synchronize_navmesh_with_tilemap`.
- **UI & Interaction**: `create_theme_override`, `configure_input_action_context`, `wire_signal_handler`, `layout_ui_grid`, `validate_accessibility`.
- **Audio & Media**: `configure_audio_bus`, `analyze_waveform`, `batch_import_audio_assets`.
- **Rendering & Assets** *(delivered)*: `generate_material_variant`, `compile_shader_preview`, `unwrap_lightmap_uv2`, `optimize_mesh_lods`, `configure_environment`, `preview_environment_sun_settings`.
- **Project & Editor Automation** *(delivered)*: `configure_project_setting`, `run_godot_headless`, `capture_editor_profile`, `manage_editor_plugins`, `snapshot_scene_state`.

### Saving Tokens

- Tools load on demand. A session starts with the 24 `core` tools (open, save and inspect scenes; create, edit and delete nodes; scripts; undo; errors; search) plus `load_tools`, about 5k tokens instead of 68k for all 261 tools. The AI calls `load_tools` with the groups its task needs, and the client gets `notifications/tools/list_changed`; `unload` turns groups or tools off again. `load_tools` with no arguments shows what is on.
  - This saves the most in clients that load every tool schema up front: in tests, a 2D player cost $0.14 instead of $0.59. Claude Code's own tool search already hides MCP tools until the AI looks for them, so there both starts cost about the same (four tasks: $0.35 small start, $0.38 every tool).
  - **Task groups** hold just what one job needs, across areas, so they cost less than whole areas. A tool can be in several; it stays on while any loaded group has it: `player_2d`, `player_3d`, `enemies`, `tilemap_level`, `gameplay` (pickups, signals, groups, score HUD, sounds), `art` (import or make art), `procgen_2d`, `procgen_3d`, `water`, `paths` (splines and followers), `world_3d`, `rigging`, `lighting`, `vfx`, `release`, `refactor`, `inspect` (read-only tools).
  - **Feature groups** hold every tool for one area: `scene`, `scripting`, `project`, `testing`, `2d`, `3d`, `animation`, `audio`, `navigation`, `physics`, `ui`, `assets`, `levelgen`, `effects`, `space`, `xr`, `multiplayer`. The largest is about 7.3k tokens.
  - For a need no group covers, `load_tools` with `find` (e.g. `"ragdoll"`) lists matching tools and their groups, and `tools` turns on single tools by name.
  - `GODOT_MCP_TOOLSETS` picks the groups that are on at start, for example `player_2d,tilemap_level`. Set it to `all` for every tool at start, which you need for clients that ignore `tools/list_changed`.
- `get_scene_tree` outlines a whole scene at about ten tokens per node.
- Resource properties take a new built-in resource inline, so no file is needed: `"mesh": "BoxMesh"` or `"shape": {"type": "CapsuleShape3D", "radius": 0.4}`, nested too (`"material": {"type": "StandardMaterial3D", "albedo_color": "#ff0000"}`).
- `get_node_properties` takes `properties` (only these names) or `changed_only` (only values that differ from the defaults), and a list of nodes in `node_path` to read them all in one call. `set_node_script` also takes a list, to put one script on many nodes.
- `batch_update_nodes` sets properties on many nodes in one call, and `instantiate_scene` takes starting `properties`. `batch_create_nodes` also places many copies of a scene at once (`scene_path` instead of `node_type`), e.g. 30 trees in one call.
- Node paths start at `/root`, the open scene's root. The running-game form with the root's name (`/root/Level/Player`) works too.
- A call with missing or wrong parameters gets the tool's parameter list back in the error, so the AI can retry without loading the schema. Short names AIs often use are read as the one parameter they fit: `path` for `script_path`, `type` and `name` for `node_type` and `node_name`, `group` for `group_name`, `property_name` for `property`, `search` for `find`. A `null` for a parameter the AI means to leave out is dropped.
- Property values also take Godot text (`"Vector3(1, 2, 3)"`, even quoted twice), `"null"` to clear a resource or script, a resource as its properties alone when the property's type can be made (`"sky": {"sky_material": {...}}`), and polygons as a flat number list (`[x1, y1, x2, y2, ...]`).
- `update_node_property`, `batch_update_nodes` and `bulk_update_node_properties` reach into sub-resources with Godot's property paths: `"environment:sky:sky_material:sky_horizon_color"`.
- `list_input_actions` lists the project's own actions, one line each; input events take key names (`"keycode": "Space"`).
- `list_signal_connections` without `node_path` lists every connection saved in the scene.
- `get_godot_errors` reads Godot's recent errors and warnings (Godot 4.5+). `create_script` and `edit_script` report compile errors with line numbers.

### Command Roles & Escalations

Every tool is tagged with a required role that indicates the level of trust needed to run it:

- **read** – Safe, read-only commands that never mutate project state.
- **edit** – Commands that edit project files or the scene tree under the existing capability allowlist.
- **admin** – High-risk commands that can execute arbitrary code or bypass guardrails.

The MCP server automatically records an escalation request for any command whose required role is not in the default auto-approved set (currently `read` and `edit`). When an escalation is required, the call fails and returns the escalation id. Requests are stored in `project-manager/permission_escalations.json` (next to `server/`, whatever directory the server was launched from).

#### Approving an escalation (human only)

The MCP client can never approve its own request. `resolve_permission_escalation` only denies. A human approves with the CLI:

```bash
cd server
npm run approve                  # list pending requests with their tool and args
npm run approve -- <id> [notes]  # approve one request
```

Then the client retries the same call within 10 minutes. An approval is single-use and only matches the exact tool and arguments that were recorded. A call with different arguments creates a new request. After use, the record gets a `consumedAt` timestamp, and the next identical call needs a new approval. Use `list_permission_escalations` to see requests and their status.

The escalation store is inside the Godot project, so Godot tools can write to it. For that reason, editing the JSON file by hand does **not** approve anything. `npm run approve` signs each approval (HMAC-SHA256 over id, tool, role, args and approval time) with a secret key kept outside the project:

- Default key path: `~/.config/godot-mcp/approval.key`. The first approval creates it with mode `0600`.
- To use another path, set `GODOT_MCP_APPROVAL_KEY_PATH` for both the server and the CLI. Never put the key inside the Godot project, and keep the `.key` extension: Godot cannot load or save `.key` files, so editor tools cannot read or replace the key.
- The server ignores any `"approved"` record without a valid signature. It also ignores all approvals if the key file is not exactly 64 hex characters.
- To revoke all approvals, delete the key file and restart the server.

Commands that currently require `admin` approval include:

- `apply_patch`
- `execute_editor_script`
- `run_godot_headless`
- `manage_editor_plugins`
- `configure_project_setting`

## Troubleshooting

### Connection Issues
- Ensure the plugin is enabled in Godot's Project Settings
- Check the Godot console for any error messages
- Verify the server is running when Claude Desktop launches it


### Plugin Not Working
- Reload Godot project after any configuration changes
- Check for error messages in the Godot console
- Make sure all paths in your Claude Desktop config are absolute and correct

## Adding the Plugin to Your Own Godot Project

If you want to use the MCP plugin in your own Godot project:

1. Copy the `addons/godot_mcp` folder to your Godot project's `addons` directory
2. Open your project in Godot
3. Go to Project > Project Settings > Plugins
4. Enable the "Godot MCP" plugin

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Tests

- `cd server && npm test` builds the server and runs the unit tests, including the real server over stdio for tool groups and `load_tools`.
- `cd server && npm run eval:agents` has a real Claude (the `claude` CLI) do plain-language Godot tasks (a 2D player, an enemy, a tile level, lighting, an island, a moving platform, effects, coins, inspecting signals, and four held-out tasks added after tuning to catch over-fitting: a 3D player, a main menu, a 2D water pool, an IK arm) in headless Godot editors. It reports which tool groups the AI loaded, errors, turns, peak context and cost, and checks each scene. It costs real API money, about $0.05–0.60 per run on Sonnet. Pick runs with `task:mode`, for example `player2d:default player2d:all` to compare the small start with every tool; the tasks are in `server/eval/tasks.mjs`. These modes turn Claude Code's tool search off, like clients that load every tool up front. Add `+ts` (`player2d:default+ts player2d:all+ts`) to keep it on, as Claude Code users have it. `--repeat 3` runs each task three times and prints averages; one run is too few to compare modes.

## Documentation

For more detailed information, check the documentation in the `docs` folder:

- [Getting Started](docs/getting-started.md)
- [Installation Guide](docs/installation-guide.md)
- [Command Reference](docs/command-reference.md)
- [Architecture](docs/architecture.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
