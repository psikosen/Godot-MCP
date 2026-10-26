var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
// Tool groups for GODOT_MCP_TOOLSETS. Listing every tool costs about 69k tokens per session in
// clients that load all tool schemas up front; a project can expose only the groups it uses.
// The first matching rule wins; anything unmatched is core, and core is always on.
var RULES = [
    ['xr', /xr_/],
    ['multiplayer', /multiplayer/],
    ['procedural', /along_path|terrain_3d|planet|ocean|crater|ring_system|starfield|moon|sand_field|slime_mold|water_|weather|cave_|dungeon|tentacle|creature|smoke|fire_|sparks|mist|electricity|wave_spawner|heightmap|blockout|scatter_|tilemap_noise|terrain_autopaint|triplanar/],
    ['animation', /animat|tween|skeleton|sprite_frames|ik_chain|bone_constraint|spring_bones/],
    ['audio', /audio|music|waveform|sfx/],
    ['navigation', /navigation|navmesh|pathfollow|path[23]d_followers|chase_step/],
    ['physics', /physics|joint|collision|ragdoll/],
    ['ui', /hud_|menu_ui|theme|accessibility|layout_ui|minimap|control_layout|touch_controls/],
    ['assets', /texture|lightmap|mesh_lods|material|shader|stencil|model|screen_effect|placeholder|environment|sun_settings|import_asset/],
    ['2d', /_2d$|2d_|tilemap|parallax|sprite|camera2d/],
    ['3d', /_3d$|3d_|gridmap|mesh_library|multimesh|day_night|csg|camera3d|springarm|light_node|particles/],
];
export var TOOLSETS = __spreadArray(['core'], RULES.map(function (_a) {
    var name = _a[0];
    return name;
}), true);
export function toolsetOf(toolName) {
    var _a, _b;
    return (_b = (_a = RULES.find(function (_a) {
        var pattern = _a[1];
        return pattern.test(toolName);
    })) === null || _a === void 0 ? void 0 : _a[0]) !== null && _b !== void 0 ? _b : 'core';
}
/** Parses GODOT_MCP_TOOLSETS ("2d,animation" or "all"); unset means all. Returns null for all. */
export function enabledToolsets(value) {
    var names = (value !== null && value !== void 0 ? value : '').split(',').map(function (name) { return name.trim().toLowerCase(); }).filter(Boolean);
    if (names.length === 0 || names.includes('all'))
        return null;
    var unknown = names.filter(function (name) { return !TOOLSETS.includes(name); });
    if (unknown.length > 0) {
        console.error("GODOT_MCP_TOOLSETS: unknown toolset(s) ".concat(unknown.join(', '), "; known: ").concat(TOOLSETS.join(', ')));
    }
    return new Set(__spreadArray(['core'], names, true));
}
//# sourceMappingURL=toolsets.js.map