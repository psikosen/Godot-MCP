// Tool groups for GODOT_MCP_TOOLSETS. Listing every tool costs about 62k tokens per session in
// clients that load all tool schemas up front; a project can expose only the groups it uses.
// The first matching rule wins; anything unmatched is core, and core is always on.
const RULES: Array<[string, RegExp]> = [
  ['xr', /xr_/],
  ['multiplayer', /multiplayer/],
  ['procedural', /planet|ocean|crater|ring_system|starfield|moon|sand_field|slime_mold|water_|weather|cave_|dungeon|tentacle|creature|smoke|fire_|sparks|mist|electricity|wave_spawner|heightmap|blockout|scatter_|tilemap_noise|terrain_autopaint|triplanar/],
  ['animation', /animat|tween|skeleton|sprite_frames/],
  ['audio', /audio|music|waveform|sfx/],
  ['navigation', /navigation|navmesh|pathfollow|path[23]d_followers|chase_step/],
  ['physics', /physics|joint|collision/],
  ['ui', /hud_|menu_ui|theme|accessibility|layout_ui|minimap|control_layout/],
  ['assets', /texture|lightmap|mesh_lods|material|shader|environment|sun_settings|import_asset/],
  ['2d', /_2d$|2d_|tilemap|parallax|sprite|camera2d/],
  ['3d', /_3d$|3d_|gridmap|csg|camera3d|springarm|light_node|particles/],
];

export const TOOLSETS = ['core', ...RULES.map(([name]) => name)];

export function toolsetOf(toolName: string): string {
  return RULES.find(([, pattern]) => pattern.test(toolName))?.[0] ?? 'core';
}

/** Parses GODOT_MCP_TOOLSETS ("2d,animation" or "all"); unset means all. Returns null for all. */
export function enabledToolsets(value: string | undefined): Set<string> | null {
  const names = (value ?? '').split(',').map(name => name.trim().toLowerCase()).filter(Boolean);
  if (names.length === 0 || names.includes('all')) return null;
  const unknown = names.filter(name => !TOOLSETS.includes(name));
  if (unknown.length > 0) {
    console.error(`GODOT_MCP_TOOLSETS: unknown toolset(s) ${unknown.join(', ')}; known: ${TOOLSETS.join(', ')}`);
  }
  return new Set(['core', ...names]);
}
