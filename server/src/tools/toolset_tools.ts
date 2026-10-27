import { z } from 'zod';
import { MCPTool } from '../utils/types.js';
import { TOOLSETS, groupsOf, toolsetMenu } from '../utils/toolsets.js';

const GROUPS = TOOLSETS.filter(name => name !== 'core') as [string, ...string[]];
const MAX_FOUND = 8;

const summary = (tool: MCPTool) => tool.description.split(/(?<=\.)\s/)[0].slice(0, 110);

/**
 * load_tools turns tool groups, or single tools, on and off while the session runs. add/remove
 * change the server's tool list, which sends notifications/tools/list_changed so the client lists
 * the tools again. `enabled` is the live set of groups that are on; this tool changes it. A tool is
 * on while any of its groups is on or it was loaded by name, so unloading a group keeps tools
 * another loaded group still has.
 */
export function loadToolsTool(
  tools: MCPTool[],
  enabled: Set<string>,
  add: (tools: MCPTool[]) => Promise<void>,
  remove: (names: string[]) => Promise<void>,
): { tool: MCPTool; offToolsHint: (text: string) => string } {
  const byGroup = new Map<string, MCPTool[]>();
  for (const tool of tools) {
    for (const group of groupsOf(tool.name)) byGroup.set(group, [...(byGroup.get(group) ?? []), tool]);
  }
  const byName = new Map(tools.map(tool => [tool.name, tool]));
  const counts = new Map(Array.from(byGroup, ([group, list]): [string, number] => [group, list.length]));
  const single = new Set<string>(); // tools loaded by name
  const isOn = (tool: MCPTool) => single.has(tool.name) || groupsOf(tool.name).some(group => enabled.has(group));
  const offGroups = () => GROUPS.filter(group => !enabled.has(group) && counts.get(group));

  // Tools whose name or description has the most query words; names count double.
  const find = (query: string) => {
    const words = query.toLowerCase().split(/[^a-z0-9]+/).filter(word => word.length > 1);
    return tools
      .map(tool => ({
        tool,
        score: words.reduce((sum, word) => sum + (tool.name.includes(word) ? 2 : 0)
          + (tool.description.toLowerCase().includes(word) ? 1 : 0), 0),
      }))
      .filter(match => match.score > 0)
      .sort((a, b) => b.score - a.score || a.tool.name.localeCompare(b.tool.name))
      .slice(0, MAX_FOUND)
      .map(({ tool }) => `- ${tool.name} [${groupsOf(tool.name).join(', ')}]${isOn(tool) ? ' (on)' : ''}: ${summary(tool)}`);
  };

  // Results often name the next tool to use ("then paint with paint_tilemap_ascii"); when that tool
  // is off, say how to turn it on instead of leaving the AI to hit "no such tool".
  const offToolsHint = (text: string) => {
    const off = Array.from(new Set(text.match(/\b[a-z][a-z0-9]*(?:_[a-z0-9]+)+\b/g) ?? []))
      .filter(name => byName.has(name) && !isOn(byName.get(name)!));
    return off.length === 0 ? '' :
      `\n(Not on yet: ${off.map(name => `${name} [${groupsOf(name).join(', ')}]`).join('; ')}. Turn on with load_tools.)`;
  };

  const tool: MCPTool = {
    name: 'load_tools',
    description: 'Turn on more Godot tools. At first only core is on (open, save and inspect scenes; edit nodes; scripts; ' +
      'undo; errors; search). Before you start, turn on what the task needs: a task group if one fits, else feature groups. ' +
      'Need something no group covers? find it, then load the tool by name. Unload when done to save tokens. ' +
      'No arguments: show what is on.\n' + toolsetMenu(counts),
    parameters: z.object({
      groups: z.array(z.enum(GROUPS)).max(GROUPS.length).optional().describe('Groups to turn on, e.g. ["player_2d"]'),
      tools: z.array(z.string()).max(50).optional().describe('Single tools to turn on by name'),
      find: z.string().max(200).optional().describe('Words describing what you need, e.g. "ragdoll"; lists matching tools and groups'),
      unload: z.array(z.string()).max(100).optional().describe('Groups or tool names to turn off'),
    }),
    execute: async ({ groups = [], tools: names = [], find: query, unload = [] }:
      { groups?: string[]; tools?: string[]; find?: string; unload?: string[] }): Promise<string> => {
      const unknown = [...names, ...unload].filter(name => !byName.has(name) && !GROUPS.includes(name));
      if (unknown.length > 0) {
        return `Unknown: ${unknown.join(', ')}. Use a group name from the menu, or find a tool by what it does.`;
      }
      const added = Array.from(new Set(groups)).filter(group => !enabled.has(group));
      const removed = Array.from(new Set(unload)).filter(name => (enabled.has(name) || single.has(name)) && !groups.includes(name));
      const wasOn = new Set(tools.filter(isOn));
      added.forEach(group => enabled.add(group));
      names.forEach(name => single.add(name));
      removed.forEach(name => { enabled.delete(name); single.delete(name); });
      const turnedOff = tools.filter(tool => wasOn.has(tool) && !isOn(tool));
      const turnedOn = tools.filter(tool => !wasOn.has(tool) && isOn(tool));
      if (turnedOff.length > 0) await remove(turnedOff.map(tool => tool.name));
      if (turnedOn.length > 0) await add(turnedOn);

      const lines = added.map(group => `Turned on ${group}: ${(byGroup.get(group) ?? []).map(tool => tool.name).join(', ')}`);
      const singles = turnedOn.filter(tool => names.includes(tool.name)).map(tool => tool.name);
      if (singles.length > 0) lines.push(`Turned on ${singles.join(', ')}.`);
      if (removed.length > 0) {
        lines.push(`Turned off ${removed.join(', ')} (${turnedOff.length} tools; tools still in a loaded group stay on).`);
      }
      if (query !== undefined) {
        const found = find(query);
        lines.push(found.length > 0 ? `Tools for "${query}" [their groups]:\n${found.join('\n')}` : `No tool matches "${query}".`);
      }
      lines.push(`On: ${Array.from(enabled).concat(Array.from(single)).join(', ')}. Off: ${offGroups().join(', ') || 'none'}.`);
      if (turnedOn.length > 0) {
        lines.push('If these tools do not appear, this app does not refresh its tool list: ask the user to set ' +
          `GODOT_MCP_TOOLSETS to "all" or to the groups you need (e.g. "${added.join(',') || 'all'}") and restart the app.`);
      }
      return lines.join('\n');
    },
    metadata: { requiredRole: 'read' },
  };
  return { tool, offToolsHint };
}
