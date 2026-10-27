import { z } from 'zod';
import { MCPTool } from '../utils/types.js';
import { TOOLSETS, groupsOf, toolsetMenu } from '../utils/toolsets.js';

const GROUPS = TOOLSETS.filter(name => name !== 'core') as [string, ...string[]];

/**
 * load_tools turns tool groups on and off while the session runs. add/remove change the server's
 * tool list, which sends notifications/tools/list_changed so the client lists the tools again.
 * `enabled` is the live set of groups that are on; this tool changes it. A tool is on while any
 * of its groups is on, so unloading a task group keeps tools another loaded group still has.
 */
export function loadToolsTool(
  tools: MCPTool[],
  enabled: Set<string>,
  add: (tools: MCPTool[]) => Promise<void>,
  remove: (names: string[]) => Promise<void>,
): MCPTool {
  const byGroup = new Map<string, MCPTool[]>();
  for (const tool of tools) {
    for (const group of groupsOf(tool.name)) byGroup.set(group, [...(byGroup.get(group) ?? []), tool]);
  }
  const counts = new Map(Array.from(byGroup, ([group, list]): [string, number] => [group, list.length]));
  const isOn = (tool: MCPTool) => groupsOf(tool.name).some(group => enabled.has(group));
  const offGroups = () => GROUPS.filter(group => !enabled.has(group) && counts.get(group));

  return {
    name: 'load_tools',
    description: 'Turn on more Godot tools. At first only core is on (open, save and inspect scenes; edit nodes; scripts; ' +
      'undo; errors; search). Before you start, turn on what the task needs: a task group if one fits, else feature groups. ' +
      'Unload groups when done to save tokens. No arguments: show what is on.\n' + toolsetMenu(counts),
    parameters: z.object({
      groups: z.array(z.enum(GROUPS)).max(GROUPS.length).optional().describe('Groups to turn on, e.g. ["player_2d"]'),
      unload: z.array(z.enum(GROUPS)).max(GROUPS.length).optional().describe('Groups to turn off'),
    }),
    execute: async ({ groups = [], unload = [] }: { groups?: string[]; unload?: string[] }): Promise<string> => {
      const added = Array.from(new Set(groups)).filter(group => !enabled.has(group));
      const removed = Array.from(new Set(unload)).filter(group => enabled.has(group) && !groups.includes(group));
      const wasOn = new Set(tools.filter(isOn));
      added.forEach(group => enabled.add(group));
      removed.forEach(group => enabled.delete(group));
      const turnedOff = tools.filter(tool => wasOn.has(tool) && !isOn(tool));
      const turnedOn = tools.filter(tool => !wasOn.has(tool) && isOn(tool));
      if (turnedOff.length > 0) await remove(turnedOff.map(tool => tool.name));
      if (turnedOn.length > 0) await add(turnedOn);

      const lines = added.map(group => `Turned on ${group}: ${(byGroup.get(group) ?? []).map(tool => tool.name).join(', ')}`);
      if (removed.length > 0) {
        lines.push(`Turned off ${removed.join(', ')} (${turnedOff.length} tools; tools still in a loaded group stay on).`);
      }
      lines.push(`On: ${Array.from(enabled).join(', ')}. Off: ${offGroups().join(', ') || 'none'}.`);
      if (turnedOn.length > 0) {
        lines.push('If these tools do not appear, this app does not refresh its tool list: ask the user to set ' +
          `GODOT_MCP_TOOLSETS to "all" or to the groups you need (e.g. "${added.join(',')}") and restart the app.`);
      }
      return lines.join('\n');
    },
    metadata: { requiredRole: 'read' },
  };
}
