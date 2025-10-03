import { CapabilityRole } from './types.js';

export type PathRule =
  | { type: 'directory'; value: string }
  | { type: 'file'; value: string }
  | { type: 'extension'; value: string };

export interface CommandRoleRule {
  tool: string;
  role: CapabilityRole;
  description?: string;
}

export interface CapabilityConfig {
  writeAllow: PathRule[];
  writeDeny: PathRule[];
  defaultRole?: CapabilityRole;
  commandRoles?: CommandRoleRule[];
}

/**
 * Default capability configuration describing which relative paths can be
 * written by automated patch tooling. These values err on the side of
 * protecting project assets that could break the sample project when edited
 * blindly (e.g. imported assets, binaries).
 */
export const defaultCapabilityConfig: CapabilityConfig = {
  writeAllow: [
    { type: 'directory', value: 'addons' },
    { type: 'directory', value: 'server' },
    { type: 'directory', value: 'docs' },
    { type: 'directory', value: 'project-manager' },
    { type: 'file', value: 'README.md' },
    { type: 'file', value: 'project.godot' },
    { type: 'extension', value: '.gd' },
    { type: 'extension', value: '.tscn' },
    { type: 'extension', value: '.tres' },
  ],
  writeDeny: [
    { type: 'directory', value: '.git' },
    { type: 'directory', value: 'server/node_modules' },
    { type: 'directory', value: 'server/dist' },
    { type: 'extension', value: '.import' },
  ],
  defaultRole: 'write',
  commandRoles: [
    { tool: 'preview_patch', role: 'write', description: 'Previews project file changes prior to application.' },
    { tool: 'apply_patch', role: 'admin', description: 'Applies diff patches to project files.' },
    { tool: 'cancel_patch', role: 'write', description: 'Cancels staged patch sessions.' },
    { tool: 'create_node', role: 'write', description: 'Adds a node to the active scene tree.' },
    { tool: 'delete_node', role: 'admin', description: 'Removes a node from the active scene tree.' },
    { tool: 'update_node_property', role: 'write', description: 'Mutates properties on scene nodes.' },
    { tool: 'create_script', role: 'write', description: 'Creates new scripts on disk and optionally attaches them.' },
    { tool: 'edit_script', role: 'write', description: 'Overwrites existing script contents.' },
    { tool: 'get_script', role: 'read', description: 'Reads script contents from disk.' },
    { tool: 'create_script_template', role: 'read', description: 'Generates local script templates.' },
    { tool: 'create_scene', role: 'write', description: 'Creates new scene files on disk.' },
    { tool: 'save_scene', role: 'write', description: 'Saves changes to the current scene on disk.' },
    { tool: 'open_scene', role: 'read', description: 'Opens a scene in the editor.' },
    { tool: 'get_current_scene', role: 'read', description: 'Queries the active scene metadata.' },
    { tool: 'get_project_info', role: 'read', description: 'Queries current project metadata.' },
    { tool: 'create_resource', role: 'write', description: 'Creates new resources on disk.' },
    { tool: 'begin_scene_transaction', role: 'write', description: 'Starts batched scene edits.' },
    { tool: 'commit_scene_transaction', role: 'admin', description: 'Commits queued scene changes.' },
    { tool: 'rollback_scene_transaction', role: 'admin', description: 'Rolls back queued scene changes.' },
    { tool: 'list_scene_transactions', role: 'read', description: 'Lists pending scene transactions.' },
    { tool: 'list_nodes', role: 'read', description: 'Enumerates children nodes under a parent.' },
    { tool: 'get_node_properties', role: 'read', description: 'Reads node property dictionaries.' },
    { tool: 'execute_editor_script', role: 'admin', description: 'Executes arbitrary code in the editor process.' },
    { tool: 'request_permission_escalation', role: 'read', description: 'Records an escalation request for higher privileges.' },
  ],
};
