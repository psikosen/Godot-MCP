# Godot MCP Command Reference

This document provides a reference for the commands available through the Godot MCP integration.

## Command Roles & Escalations

Each command now advertises a required role:

- **read** – Read-only operations that inspect project state.
- **edit** – Write operations covered by the filesystem allowlist.
- **admin** – High-impact operations that require a human escalation before execution.

When a command requires a role outside the default (`read` and `edit`), the server records an escalation request and returns its identifier along with a suggested approval prompt. Use `list_permission_escalations` and `resolve_permission_escalation` to review and resolve pending approvals.

## Node Tools

### create_node
Create a new node in the Godot scene tree.

**Parameters:**
- `parent_path` - Path to the parent node (e.g., "/root", "/root/MainScene")
- `node_type` - Type of node to create (e.g., "Node2D", "Sprite2D", "Label")
- `node_name` - Name for the new node

**Example:**
```
Create a Button node named "StartButton" under the CanvasLayer.
```

### delete_node
Delete a node from the scene tree.

**Parameters:**
- `node_path` - Path to the node to delete

**Example:**
```
Delete the node at "/root/MainScene/UI/OldButton".
```

### update_node_property
Update a property of a node.

**Parameters:**
- `node_path` - Path to the node to update
- `property` - Name of the property to update
- `value` - New value for the property

**Example:**
```
Update the "text" property of the node at "/root/MainScene/UI/Label" to "Game Over".
```

### get_node_properties
Get all properties of a node.

**Parameters:**
- `node_path` - Path to the node to inspect

**Example:**
```
Show me all the properties of the node at "/root/MainScene/Player".
```

### list_nodes
List all child nodes under a parent node.

**Parameters:**
- `parent_path` - Path to the parent node

**Example:**
```
List all nodes under "/root/MainScene/UI".
```

### rename_node
Rename an existing node in the edited scene with undo support.

**Parameters:**
- `node_path` - Path to the node that should be renamed
- `new_name` - New name to apply to the node
- `transaction_id` (optional) - Use an existing transaction to batch the rename

**Example:**
```
Rename the node at "/root/MainScene/Enemy" to "Boss" without affecting other children.
```

### add_node_to_group
Add a node to a named group, optionally persisting the membership to the scene file.

**Parameters:**
- `node_path` - Path to the node to modify
- `group_name` - Group to join (case-sensitive)
- `persistent` (optional) - Whether the membership should be saved with the scene (default true)
- `transaction_id` (optional) - Use an existing transaction to batch the operation

**Example:**
```
Add the player node to the "damageable" group so enemies can find it easily.
```

### remove_node_from_group
Remove a node from a named group with full undo/redo support.

**Parameters:**
- `node_path` - Path to the node to modify
- `group_name` - Group that should be removed from the node
- `persistent` (optional) - Whether undo should restore the membership as persistent (default true)
- `transaction_id` (optional) - Use an existing transaction to batch the operation

**Example:**
```
Remove "Boss" from the "spawned_enemies" group after the fight ends.
```

### configure_camera2d_limits
Configure Camera2D limit boundaries, smoothing behaviour, and editor visualization helpers using undo-aware transactions.

**Parameters:**
- `node_path` - Path to the Camera2D node to configure.
- `limits` (optional) - Dictionary of limit settings such as `enabled`, `left`, `right`, `top`, `bottom`, `smoothed`, and `draw_limits`.
- `smoothing` (optional) - Dictionary toggling `position_enabled`, `position_speed`, `rotation_enabled`, and `rotation_speed`.
- `transaction_id` (optional) - Use an existing transaction to batch configuration changes.

**Example:**
```
Clamp the gameplay camera to a 512x256 region and enable smoothed edges so movement feels natural.
```

### list_node_groups
List all groups a node currently belongs to.

**Parameters:**
- `node_path` - Path to the node to inspect

**Example:**
```
Show every group that the player node is assigned to.
```

### list_nodes_in_group
List every node in the edited scene that belongs to a specified group.

**Parameters:**
- `group_name` - Name of the group to query

**Example:**
```
List every node in the "interactable" group so I can audit them.
```

## Script Tools

### create_script
Create a new GDScript file.

**Parameters:**
- `script_path` - Path where the script will be saved
- `content` - Content of the script
- `node_path` (optional) - Path to a node to attach the script to

**Example:**
```
Create a script at "res://scripts/player_controller.gd" with a basic movement system.
```

### edit_script
Edit an existing GDScript file.

**Parameters:**
- `script_path` - Path to the script file to edit
- `content` - New content of the script

**Example:**
```
Update the script at "res://scripts/player_controller.gd" to add a jump function.
```

### get_script
Get the content of a GDScript file.

**Parameters:**
- `script_path` (optional) - Path to the script file
- `node_path` (optional) - Path to a node with a script attached

**Example:**
```
Show me the script attached to the node at "/root/MainScene/Player".
```

### create_script_template
Generate a GDScript template with common boilerplate.

**Parameters:**
- `class_name` (optional) - Optional class name for the script
- `extends_type` - Base class that this script extends (default: "Node")
- `include_ready` - Whether to include the _ready() function (default: true)
- `include_process` - Whether to include the _process() function (default: false)
- `include_input` - Whether to include the _input() function (default: false)
- `include_physics` - Whether to include the _physics_process() function (default: false)

**Example:**
```
Create a script template for a KinematicBody2D with process and input functions.
```

## Scene Tools

### create_scene
Creates a new empty scene with an optional root node type.

**Parameters:**
- `path` (string): Path where the new scene will be saved (e.g. "res://scenes/new_scene.tscn")
- `root_node_type` (string, optional): Type of root node to create (e.g. "Node2D", "Node3D", "Control"). Defaults to "Node" if not specified

**Returns:**
- `scene_path` (string): Path where the scene was saved
- `root_node_type` (string): The type of the root node that was created

**Example:**
```typescript
// Create a new scene with a Node2D as root
const result = await mcp.execute('create_scene', {
  path: 'res://scenes/game_level.tscn',
  root_node_type: 'Node2D'
});
console.log(`Created scene at ${result.scene_path}`);
```

### save_scene
Save the current scene to disk.

**Parameters:**
- `path` (optional) - Path where the scene will be saved (uses current path if not provided)

**Example:**
```
Save the current scene to "res://scenes/level_1.tscn".
```

### open_scene
Open a scene in the editor.

**Parameters:**
- `path` - Path to the scene file to open

**Example:**
```
Open the scene at "res://scenes/main_menu.tscn".
```

### get_current_scene
Get information about the currently open scene.

**Parameters:** None

**Example:**
```
What scene am I currently editing?
```

### get_project_info
Get information about the current Godot project.

**Parameters:** None

**Example:**
```
Tell me about the current project.
```

### create_resource
Create a new resource in the project.

**Parameters:**
- `resource_type` - Type of resource to create
- `resource_path` - Path where the resource will be saved
- `properties` (optional) - Dictionary of property values to set on the resource

**Example:**
```
Create a StyleBoxFlat resource at "res://resources/button_style.tres" with a blue background color.
```

### configure_physics_body
Configure properties on PhysicsBody2D and PhysicsBody3D nodes with undo/redo support.

**Parameters:**
- `node_path` - Path to the physics body node (e.g., "/root/MainScene/Player")
- `properties` - Dictionary of physics properties to update (e.g., `{ "mass": 8.5, "collision_mask": 3 }`)
- `transaction_id` (optional) - Use an existing transaction identifier to batch several edits

**Example:**
```
Increase the mass on the player rigid body and restrict it to collisions on layers 1 and 2.
```

### configure_physics_area
Adjust Area2D and Area3D monitoring, collision masks, and physics callbacks.

**Parameters:**
- `node_path` - Path to the area node that should be updated
- `properties` - Dictionary of area properties to change (e.g., `{ "monitoring": true, "gravity_space_override": 1 }`)
- `transaction_id` (optional) - Optional transaction identifier to stage the change before committing

**Example:**
```
Enable monitoring on the enemy detection area and expand the collision mask to include the NPC layer.
```

### configure_physics_joint
Update Joint2D and Joint3D configuration including connected bodies and constraint limits.

**Parameters:**
- `node_path` - Path to the joint node (e.g., "/root/MainScene/HingeJoint")
- `properties` - Dictionary of joint properties to update (e.g., `{ "node_a": "../BodyA", "angular_limit_lower": -0.5 }`)
- `transaction_id` (optional) - Optional transaction identifier when batching edits

**Example:**
```
Retarget the hinge joint to connect the new door and clamp its angular limits to ±30 degrees.
```

### configure_csg_shape
Configure CSGCombiner3D, CSGBox3D, and other CSG nodes with undo/redo aware property updates.

**Parameters:**
- `node_path` - Path to the target CSG node (e.g., "/root/Level/CSGCombiner3D")
- `properties` - Dictionary of CSG properties to update (e.g., `{ "operation": 1, "snap": 0.5 }`)
- `transaction_id` (optional) - Optional transaction identifier when batching edits

**Example:**
```
Hollow out the hallway CSG combiner and flip its boolean operation to subtraction.
```

### configure_material_resource
Create or update a Material resource on disk while wiring glslang shader code, lightmapper_rd textures, and meshoptimizer LOD metadata.

**Parameters:**
- `resource_path` - Path to the `.tres` or `.res` file to create/update (e.g., `"res://materials/brick.tres"`)
- `material_type` (optional) - Material class to instantiate when creating a new resource (e.g., `"ShaderMaterial"`, `"StandardMaterial3D"`)
- `resource_name` (optional) - Value to assign to `Resource.resource_name`
- `metadata` (optional) - Dictionary of metadata keys to persist on the resource
- `material_properties` (optional) - Dictionary of material property overrides to apply (e.g., `{"albedo_color": "Color(0.8, 0.7, 0.6, 1)"}`)
- `shader_code` (optional) - Inline shader code to assign when targeting a `ShaderMaterial`
- `shader_path` (optional) - Path to an existing `Shader` resource to reuse
- `shader_parameters` (optional) - Dictionary of shader parameter overrides (values may reference resources via `{ "resource_path": "res://textures/lightmap.png" }`)
- `glslang_shader` (optional) - Structured payload from the glslang pipeline including `code`, `path`, `metadata`, and `parameters`
- `lightmapper_rd` (optional) - Dictionary describing baked lightmapper textures (`texture_slots`) and scalar overrides (`scalar_parameters`)
- `meshoptimizer` (optional) - Dictionary describing meshoptimizer outputs such as `lod_meshes` and additional metadata

**Example:**
```
Compile the latest glslang shader for the hero material, assign the baked lightmap texture, and record meshoptimizer LOD metadata under res://materials/hero.tres.
```

### paint_gridmap_cells
Stamp MeshLibrary items into GridMap coordinates to block out level geometry quickly.

**Parameters:**
- `node_path` - Path to the GridMap node that should be modified
- `cells` - Array of cell dictionaries. Each entry must include either a `position` object with `x`, `y`, `z` fields or standalone `x`, `y`, `z` keys, plus an `item` id and optional `orientation` index.
- `transaction_id` (optional) - Optional transaction identifier to stage multiple edits before commit

**Example:**
```
Paint a 3×3 platform in the GridMap using the stone tile (item 4) with default orientation.
```

### clear_gridmap_cells
Erase previously painted GridMap cells, returning them to the empty slot while preserving undo history.

**Parameters:**
- `node_path` - Path to the GridMap node that should be cleared
- `cells` - Array of positions to clear. Each entry can provide a `position` object or explicit `x`, `y`, `z` values.
- `transaction_id` (optional) - Optional transaction identifier to queue the clears before committing

**Example:**
```
Clear the doorway cells we just carved out of the GridMap.
```

## Project Tools

### refresh_project_index
Rebuild the cached project index snapshot maintained by the MCP server.

**Parameters:** None

**Example:**
```
Force a fresh index of the project so I can query the latest files.
```

### query_project_index
Query the cached index using glob patterns to quickly list files or directories.

**Parameters:**
- `pattern` - Glob pattern or array of patterns (supports `*`, `**`, and `?`)
- `include_directories` (optional) - Whether to include directories (default true)
- `limit` (optional) - Maximum number of results (default 200, max 5000)

**Example:**
```
Show me every GDScript under addons and docs/*.md files.
```

### list_input_actions
List every configured input action along with its deadzone and registered events.

**Parameters:** None

**Example:**
```
Audit every action in the Input Map so I can document the controls.
```

### add_input_action
Create or overwrite a project input action, optionally seeding it with input events.

**Parameters:**
- `action_name` - Name of the action to create or overwrite
- `deadzone` (optional) - Custom deadzone value for analog inputs
- `overwrite` (optional) - Whether an existing action should be replaced (default false)
- `persistent` (optional) - Save the change to project.godot immediately (default true)
- `events` (optional) - Array of input event dictionaries to assign to the action

**Example:**
```
Create an action called "dash" that listens to Shift and a controller face button.
```

### remove_input_action
Delete an input action from the project settings.

**Parameters:**
- `action_name` - Name of the action to remove
- `persistent` (optional) - Save the change to project.godot immediately (default true)

**Example:**
```
Remove the unused "debug_toggle" action from the input map.
```

### add_input_event_to_action
Register an additional input event on an existing action.

**Parameters:**
- `action_name` - Name of the action to modify
- `event` - Dictionary describing the input event to add (e.g., key, mouse button, joypad button)
- `persistent` (optional) - Save the change to project.godot immediately (default true)

**Example:**
```
Add the right mouse button as an alternative way to trigger the "aim" action.
```

### remove_input_event_from_action
Remove a registered input event by index or by matching event fields.

**Parameters:**
- `action_name` - Name of the action to modify
- `event_index` (optional) - Index of the event to remove (0-based)
- `event` (optional) - Dictionary describing the event to match for removal
- `persistent` (optional) - Save the change to project.godot immediately (default true)

**Example:**
```
Remove the duplicate Spacebar binding from the "jump" action.
```

### list_audio_buses
Return the complete audio bus graph, capturing volume, routing, mute/solo state, and the enabled status of every effect.

**Parameters:** None

**Example:**
```
Show me the audio bus layout so I can review the reverb chain and send routing.
```

### configure_audio_bus
Mutate a single audio bus by adjusting its volume, routing, and effect toggles. Changes can optionally be saved back to the
project's default bus layout resource.

**Parameters:**
- `bus_name` or `bus_index` - Identify which bus to mutate.
- `new_name` (optional) - Rename the bus.
- `volume_db` (optional) - Set the bus volume in decibels.
- `solo` (optional) - Enable or disable solo mode.
- `mute` (optional) - Enable or disable mute.
- `bypass_effects` (optional) - Toggle bypass on the bus effect chain.
- `send` (optional) - Assign or clear the downstream send target.
- `effects` (optional) - Array of effect toggle requests (`index`, optional `enabled`).
- `persist` (optional) - Save the resulting layout to the configured default bus resource.

**Example:**
```
Solo the "Music" bus, drop it by -6 dB, and persist the updated layout.
```

### author_audio_stream_player
Create or configure an AudioStreamPlayer node, wiring in a stream resource and playback properties without leaving the MCP flow.

**Parameters:**
- `node_path` (optional) - Existing AudioStreamPlayer to configure.
- `parent_path` (optional) - Parent node to attach a new AudioStreamPlayer when `node_path` is omitted.
- `player_name` (optional) - Name assigned to a newly created player.
- `player_type` (optional) - AudioStreamPlayer class to instantiate (`AudioStreamPlayer`, `AudioStreamPlayer2D`, `AudioStreamPlayer3D`, or `AudioStreamPlayerMicrophone`).
- `stream_path` (optional) - AudioStream resource path (e.g. `res://audio/theme.ogg`).
- `properties` (optional) - Dictionary of additional properties (`volume_db`, `mix_target`, `unit_size`, etc.).
- `autoplay`, `bus`, `volume_db`, `pitch_scale`, `max_polyphony`, `stream_paused` (optional) - Convenience fields merged into `properties`.
- `create_if_missing` (optional) - Create the player when `node_path` is missing.
- `transaction_id` (optional) - Scene transaction identifier to batch edits.

**Example:**
```
Create an AudioStreamPlayer2D under /root/Main named Music, assign res://audio/theme.ogg, enable autoplay, and set volume to -6 dB.
```

### author_interactive_music_graph
Author or update an `AudioStreamInteractive` resource, wiring layered clip metadata and transition rules suitable for interactive music systems.

**Parameters:**
- `resource_path` (required) - Destination resource path for the `.tres` interactive music asset.
- `clips` (required) - Array of clip definitions. Each entry accepts:
  - `name` (optional) - Friendly clip name used for logging and transition references.
  - `stream_path` (optional) - AudioStream descriptor (`"res://music/intro.ogg"`, `{ "path": "res://..." }`, or `null` to clear).
  - `auto_advance_mode` (optional) - One of `disabled`, `enabled`, or `return_to_hold`.
  - `auto_advance_next_clip` (optional) - Clip reference (`index`, `name`, or `{ "name": "Loop" }`) used when auto-advance is enabled.
- `transitions` (optional) - Array of transition rules. Each rule accepts:
  - `from_clip` / `to_clip` (required) - Clip references (index, name, or `{ index/name }`).
  - `from_time` (optional) - Transition trigger (`immediate`, `next_beat`, `next_bar`, or `end`).
  - `to_time` (optional) - Destination start mode (`same_position` or `start`).
  - `fade_mode` (optional) - Fade behavior (`disabled`, `fade_in`, `fade_out`, `cross`, `automatic`).
  - `fade_beats` (optional) - Length of the fade in beats.
  - `use_filler_clip` (optional) - Whether to insert a filler clip mid-transition (requires `filler_clip`).
  - `filler_clip` (optional) - Clip reference for the filler segment.
  - `hold_previous` (optional) - Keep the origin clip active for return-to-hold flows.
- `initial_clip` (optional) - Clip reference used when playback begins.
- `clear_missing_transitions` (optional) - Remove any previously authored transitions that are not included in the current request.

**Example:**
```
Create res://audio/dynamic_theme.interactive with Intro and Loop clips plus a beat-aligned crossfade between them.
```

### generate_dynamic_music_layer
Add a new clip layer to an existing `AudioStreamInteractive` resource (or update an existing clip) while authoring entry and exit transitions between the base clip and the new layer.

**Parameters:**
- `resource_path` (required) - Interactive music resource to modify.
- `base_clip` (required) - Clip reference (index, name, or `{ index/name }`) used as the foundation layer.
- `layer_clip` or `layer` (optional) - Layer descriptor accepting:
  - `name` (optional) - Clip name to assign or reuse.
  - `reference` (optional) - Clip reference when updating an existing layer instead of creating a new clip.
  - `stream_path` (optional) - AudioStream descriptor (`"res://audio/layer.ogg"`, `{ "path": ... }`, or `null` to clear).
- `entry_transition` (optional) - Dictionary controlling the transition from the base clip into the layer. Supports `from_time`, `to_time`, `fade_mode`, `fade_beats`, `use_filler_clip`, `filler_clip`, and `hold_previous`.
- `exit_transition` (optional) - Dictionary configuring the return transition from the layer back to the base clip with the same fields as `entry_transition`.
- `make_initial` (optional) - When true, set the generated layer as the interactive stream's initial clip.

**Example:**
```
Add a "Drums" layer to res://audio/dynamic_theme.interactive using clip "Loop" as the base, crossfading on the next bar when entering and fading out over 2 beats when exiting.
```

## Animation Commands

### list_animation_players
Enumerate AnimationPlayer nodes in the active scene along with playback metadata and contained animations.

**Parameters:**
- `node_path` (optional) - Limit the search to a specific node and its descendants.
- `include_tracks` (optional, default `false`) - Include per-animation track metadata.
- `include_keys` (optional, default `false`) - Include keyframe timing, values, and transitions when `include_tracks` is enabled.

**Example:**
```
List every AnimationPlayer in the main scene and include their animation names.
```

### describe_animation_tracks
Inspect AnimationPlayer track configuration with optional keyframe dumps to audit interpolation and value changes.

**Parameters:**
- `node_path` (optional) - Target a single AnimationPlayer. When omitted the command inspects all players.
- `include_keys` (optional, default `true`) - Include arrays of keyframe timing, value, and transition metadata per track.

**Example:**
```
Show detailed track and keyframe data for the AnimationPlayer at "/root/Characters/Player/AnimationPlayer".
```

### describe_animation_state_machines
Summarise AnimationTree state machine graphs, nested machines, and transition properties for review or documentation.

**Parameters:**
- `node_path` (optional) - Focus on a specific AnimationTree node.
- `include_nested` (optional, default `true`) - Recursively include child state machines encountered within states.
- `include_graph` (optional, default `true`) - Include editor graph metadata such as node positions.
- `include_transitions` (optional, default `true`) - Include transition arrays with switch/advance metadata.

**Example:**
```
Describe the AnimationTree state machine graph for the Player AnimationTree so I can review transitions and nested states.
```

## MCP Resources

### godot://physics/world
Return a structured snapshot of every active physics space in the currently edited scene. The payload groups 2D and 3D spaces, exposes their gravity configuration, and enumerates every physics body, area, and joint assigned to each space.

**Response highlights:**
- `scene_path`, `scene_name`, and `captured_at` identify where the snapshot originated.
- `spaces.2d[]` / `spaces.3d[]` list physics spaces with `space_id`, `label`, `space_rid`, gravity metadata, activation state, and nested `bodies`, `areas`, and `joints` arrays.
- Each body entry surfaces collision layers/masks, key physics properties (mass, gravity scale, velocity, sleep state, etc.), and script/group metadata to help audit configuration.
- Area entries capture monitoring flags, gravity overrides, damping, and override modes, while joint entries report their endpoints, force/solver settings, and collision flags.
- `counts` summarizes totals for quick reporting (`overall.spaces`, `overall.bodies`, `overall.areas`, `overall.joints`).

**Example:**
```
@mcp godot-mcp read godot://physics/world
```

### godot://audio/buses
Provide the audio bus layout, including hierarchy, effect chains, and mute/solo states for every bus. Use this snapshot to audit mix routing or verify automation changes without opening the Godot editor UI.

## Using Commands with Claude

When working with Claude, you don't need to specify the exact command name or format. Instead, describe what you want to do in natural language, and Claude will use the appropriate command. For example:

```
Claude, can you create a new Label node under the UI node with the text "Score: 0"?
```

Claude will understand this request and use the `create_node` command with the appropriate parameters.