# Godot MCP (Model Context Protocol)

A comprehensive integration between Godot Engine and AI assistants using the Model Context Protocol (MCP). This plugin allows AI assistants to interact with your Godot projects, providing powerful capabilities for code assistance, scene manipulation, and project management.

## Features

- **Full Godot Project Access**: AI assistants can access and modify scripts, scenes, nodes, and project resources
- **Two-way Communication**: Send project data to AI and apply suggested changes directly in the editor
- **Capability-Aware Editing**: Patch application is scoped to an allowlisted set of directories, file types, and critical assets for safer automation
- **Project Indexing & Query**: Cached project map with glob-style queries for quick discovery of files and directories
- **Node Workflow Enhancements**: Rename nodes, manage group membership, and enumerate group contents with full undo/redo support
- **Input Map Automation**: Inspect, add, and remove input actions or individual input events without leaving the editor
- **Command Categories**:
  - **Node Commands**: Create, modify, and manage nodes in your scenes
  - **Script Commands**: Edit, analyze, and create GDScript files
  - **Scene Commands**: Manipulate scenes and their structure
  - **Project Commands**: Access project settings and resources
  - **Editor Commands**: Control various editor functionality

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

### Command Categories:

#### Node Commands
- `create_node` - Create a new node under a specified parent path
- `delete_node` - Delete a node from the edited scene
- `update_node_property` - Change a node property with undo support
- `get_node_properties` - Inspect every exposed property on a node
- `list_nodes` - Enumerate the children of a node in the scene tree
- `rename_node` - Rename a node while preserving undo history
- `add_node_to_group` - Add a node to a named group (optionally persisting to the scene file)
- `remove_node_from_group` - Remove a node from a group with undo/redo
- `list_node_groups` - List all groups the node currently belongs to
- `list_nodes_in_group` - Enumerate nodes that are members of a group in the edited scene

#### Script Commands
- `create_script` - Create a new GDScript file and optionally attach it to a node
- `edit_script` - Replace the contents of an existing script file
- `get_script` - Fetch a script by file path or by attached node
- `create_script_template` - Generate a GDScript skeleton with common callbacks

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

#### Project Commands
- `refresh_project_index` - Rebuild the cached project index snapshot
- `query_project_index` - Query the cached project index with glob patterns
- `list_input_actions` - List every input action and associated events
- `add_input_action` - Create or overwrite an input action definition
- `remove_input_action` - Delete an input action from the project settings
- `add_input_event_to_action` - Register an additional event on an existing input action
- `remove_input_event_from_action` - Remove an input event by index or matching fields

#### Patch Commands
- `preview_patch` - Preview a diff before it is applied
- `apply_patch` - Apply a previously previewed diff (requires admin approval)
- `cancel_patch` - Discard a pending diff preview

#### Permission Commands
- `list_permission_escalations` - List pending and resolved permission escalation requests
- `resolve_permission_escalation` - Approve or deny a recorded escalation request (requires admin approval)

#### Editor Commands
- `execute_editor_script` - Run arbitrary GDScript in the editor context (requires admin approval)

### Command Roles & Escalations

Every tool is tagged with a required role that indicates the level of trust needed to run it:

- **read** – Safe, read-only commands that never mutate project state.
- **edit** – Commands that edit project files or the scene tree under the existing capability allowlist.
- **admin** – High-risk commands that can execute arbitrary code or bypass guardrails.

The MCP server automatically records an escalation request for any command whose required role is not in the default auto-approved set (currently `read` and `edit`). When an escalation is required, the tool returns the escalation identifier along with a suggested natural-language prompt that a human reviewer can use to approve the action. Reviewers can inspect and resolve queued requests via the `list_permission_escalations` and `resolve_permission_escalation` tools.

Commands that currently require `admin` approval include:

- `apply_patch`
- `execute_editor_script`
- `resolve_permission_escalation`

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

## Documentation

For more detailed information, check the documentation in the `docs` folder:

- [Getting Started](docs/getting-started.md)
- [Installation Guide](docs/installation-guide.md)
- [Command Reference](docs/command-reference.md)
- [Architecture](docs/architecture.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
