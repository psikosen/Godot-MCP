var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
import { z } from 'zod';
import { fail, send } from './workflow_tools.js';
import { vector3 } from './builder_tools.js';
import { editableNote } from './feature_tools.js';
var status = function (r) { return "[".concat(r.status, "]"); };
// One readable block for inspect_model and configure_model_import.
var modelSummary = function (r) {
    var lines = ["".concat(r.model_path, " imports as ").concat(r.import_as).concat(r.root ? ", root ".concat(r.root) : '')];
    var meshes = r.meshes;
    if (meshes.length) {
        lines.push('Meshes: ' + meshes.map(function (m) { return m.collision
            ? "".concat(m.path, " (collision ").concat(m.collision, ")")
            : "".concat(m.path).concat(m.skinned ? ' (skinned)' : '', " [").concat(m.materials.join(', '), "]"); }).join('; '));
    }
    var skeletons = r.skeletons;
    if (skeletons.length)
        lines.push('Skeletons: ' + skeletons.map(function (s) { return "".concat(s.path, " (").concat(s.bones, " bones, ").concat(s.humanoid, " match humanoid names)"); }).join('; '));
    var animations = r.animations;
    if (animations.length)
        lines.push('Animations: ' + animations.map(function (a) { return "".concat(a.name, " ").concat(a.length, "s loop ").concat(a.loop); }).join('; '));
    var settings = Object.entries(r.settings);
    if (settings.length)
        lines.push('Import settings: ' + settings.map(function (_a) {
            var k = _a[0], v = _a[1];
            return "".concat(k, "=").concat(JSON.stringify(v));
        }).join(', '));
    return lines.join('\n');
};
export var assetTools = [
    {
        name: 'inspect_model',
        description: 'Show what a 3D model file (.glb, .gltf, .fbx, .blend, .obj, .dae) holds after import: meshes and materials, skeletons, animations with length and loop, and its import settings. Use before configure_model_import.',
        parameters: z.object({
            model_path: z.string().describe('res:// model file'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var _a, error_1;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _b.trys.push([0, 2, , 3]);
                        _a = modelSummary;
                        return [4 /*yield*/, send('inspect_model', args)];
                    case 1: return [2 /*return*/, _a.apply(void 0, [_b.sent()])];
                    case 2:
                        error_1 = _b.sent();
                        return [2 /*return*/, fail('inspect model', error_1)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'read' },
    },
    {
        name: 'configure_model_import',
        description: 'Change how Godot imports a 3D model, then reimport it: root node type and scale, collision bodies on its meshes, looping animations, a humanoid bone map (so Mixamo/VRM/Unreal-style rigs share animations), importing as an animation library, extracting materials to files, lightmap UVs.',
        parameters: z.object({
            model_path: z.string(),
            import_as: z.enum(['scene', 'animation_library']).optional().describe('animation_library: the file loads as animations for add_animation_library'),
            root_type: z.string().optional().describe('e.g. CharacterBody3D, RigidBody3D, StaticBody3D'),
            root_name: z.string().optional(),
            root_scale: z.number().positive().optional(),
            collision: z.object({
                shape: z.enum(['trimesh', 'convex', 'decompose', 'box', 'sphere', 'cylinder', 'capsule', 'auto', 'none']).optional().describe('Default trimesh (exact, for static level art)'),
                body: z.enum(['static', 'rigid', 'area']).optional().describe('Default static'),
                meshes: z.array(z.string()).optional().describe('Mesh names or paths from inspect_model; default all'),
            }).strict().optional(),
            loop: z.union([z.boolean(), z.array(z.string())]).optional().describe('true loops every animation, false none, or a list of names'),
            loop_mode: z.enum(['linear', 'pingpong']).optional(),
            humanoid: z.boolean().optional().describe('Map the skeleton to Godot\'s humanoid profile; do it for the character and for each animation file'),
            extract_materials_to: z.string().optional().describe('res:// folder; materials become editable .tres files'),
            lightmap_uv: z.boolean().optional().describe('Generate UV2 for baked lightmaps'),
            animation_fps: z.number().int().min(1).max(240).optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, changed, error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('configure_model_import', args)];
                    case 1:
                        r = _a.sent();
                        changed = r.changed;
                        return [2 /*return*/, "Reimported.".concat(changed.length ? " ".concat(changed.join('; '), ".") : '', "\n").concat(modelSummary(r))];
                    case 2:
                        error_2 = _a.sent();
                        return [2 /*return*/, fail('configure model import', error_2)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'add_animation_library',
        description: 'Add animations to an AnimationPlayer from an AnimationLibrary file or a model (a model imported as animation_library is shared, a scene model is copied in). Reports how many tracks find their bones, so a skeleton mismatch shows at once. Undo-aware.',
        parameters: z.object({
            player_path: z.string(),
            source: z.string().describe('res:// .res/.tres library, or a .glb/.fbx model with animations'),
            library_name: z.string().optional().describe('Default: the file name; play as "<library>/<animation>"'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, unresolved, error_3;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('add_animation_library', args)];
                    case 1:
                        r = _a.sent();
                        unresolved = r.unresolved_examples;
                        return [2 /*return*/, "Library \"".concat(r.library_name, "\" on ").concat(r.player_path, " ").concat(status(r), ": ").concat(r.animations.join(', '))
                                + "".concat(r.embedded_copy ? ' (copied into the scene; import the file as animation_library to share it instead)' : '')
                                + "\nTracks that find their node or bone: ".concat(r.tracks_resolved, "/").concat(r.tracks_total)
                                + (unresolved.length ? "\nNot found, e.g.: ".concat(unresolved.join(', '), " (retarget both models with configure_model_import humanoid)") : '')
                                + editableNote(r)];
                    case 2:
                        error_3 = _a.sent();
                        return [2 /*return*/, fail('add animation library', error_3)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'generate_mesh_collision',
        description: 'Collision that follows a 3D mesh\'s real shape (like Mesh > Create Collision Shape): trimesh (exact, static only), convex, simplified_convex, or multiple_convex (for moving bodies). Works on one MeshInstance3D or all meshes under a node; meshes not under a body get a StaticBody3D. Undo-aware.',
        parameters: z.object({
            node_path: z.string(),
            shape: z.enum(['trimesh', 'convex', 'simplified_convex', 'multiple_convex']).optional().describe('Default trimesh'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_4;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('generate_mesh_collision', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "".concat(r.shape, " collision ").concat(status(r), ":\n").concat(r.created.join('\n'))];
                    case 2:
                        error_4 = _a.sent();
                        return [2 /*return*/, fail('generate mesh collision', error_4)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'sprite_to_polygon',
        description: 'Trace a Sprite2D\'s visible pixels into a polygon (like the Sprite2D menu): collision (CollisionPolygon2D, in a new StaticBody2D unless the sprite is already under a body), occluder (LightOccluder2D for 2D shadows) or polygon (textured Polygon2D). Uses the region or current frame. Undo-aware.',
        parameters: z.object({
            node_path: z.string(),
            output: z.enum(['collision', 'occluder', 'polygon']).optional().describe('Default collision'),
            simplify: z.number().min(0).max(32).optional().describe('Pixels of error allowed; higher = fewer points (default 2)'),
            grow: z.number().int().min(-16).max(16).optional().describe('Grow or shrink the shape, in pixels'),
            alpha_threshold: z.number().min(0).max(1).optional().describe('Pixels above this alpha count (default 0.1)'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_5;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('sprite_to_polygon', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "".concat(r.output, ": ").concat(r.polygons, " polygon(s) ").concat(status(r), "\n").concat(r.created.join('\n'))];
                    case 2:
                        error_5 = _a.sent();
                        return [2 /*return*/, fail('trace sprite', error_5)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'bake_csg',
        description: 'Turn a CSG blockout into a plain mesh plus trimesh collision (Godot 4.4+), so it runs fast in the game. Replaces the CSG node unless keep_csg. Undo-aware.',
        parameters: z.object({
            node_path: z.string().describe('The outermost CSG node'),
            collision: z.boolean().optional().describe('Default true'),
            keep_csg: z.boolean().optional(),
            save_mesh_to: z.string().optional().describe('res://...res to keep the mesh out of the scene file'),
            name: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_6;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('bake_csg', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "Baked ".concat(r.node_path, " ").concat(status(r), ": ").concat(r.triangles, " triangles").concat(r.collision ? ', with collision' : '')
                                + "".concat(r.csg_removed ? '; CSG removed' : '; CSG kept').concat(r.mesh_path ? "; mesh saved to ".concat(r.mesh_path) : '')];
                    case 2:
                        error_6 = _a.sent();
                        return [2 /*return*/, fail('bake CSG', error_6)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'generate_terrain_3d',
        description: 'Generate rolling 3D terrain from noise: a mesh colored by height (sand, grass, rock, snow) with HeightMapShape3D collision, optional island shape and water plane. Mesh and shape are saved as .res files.',
        parameters: z.object({
            parent_path: z.string().optional(),
            size: z.number().min(2).max(4096).optional().describe('Width in meters (default 64)'),
            resolution: z.number().int().min(2).max(512).optional().describe('Cells per side (default 64)'),
            height: z.number().min(0).max(1000).optional().describe('Highest point in meters (default 8)'),
            frequency: z.number().min(0.0001).max(1).optional().describe('Higher = more, smaller hills (default 0.02)'),
            octaves: z.number().int().min(1).max(9).optional().describe('Detail layers (default 4)'),
            seed: z.number().int().optional(),
            island: z.boolean().optional().describe('Fade to sea level at the edges'),
            water_level: z.number().min(0).max(1).optional().describe('Add a water plane at this fraction of height'),
            position: vector3.optional(),
            name: z.string().optional(),
            save_dir: z.string().optional().describe('Default res://terrain'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, range, error_7;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('generate_terrain_3d', args)];
                    case 1:
                        r = _a.sent();
                        range = r.height_range;
                        return [2 /*return*/, "".concat(r.node_path, " ").concat(status(r), ": ").concat(r.size, " m, ").concat(r.cells, "x").concat(r.cells, " cells, heights ").concat(range[0], "..").concat(range[1], " m")
                                + "".concat(r.water ? ', with water' : '', "\nSaved ").concat(r.mesh_path, " and ").concat(r.shape_path)];
                    case 2:
                        error_7 = _a.sent();
                        return [2 /*return*/, fail('generate terrain', error_7)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'generate_ui_theme',
        description: 'Make a whole UI Theme from a primary and a background color: buttons (hover, pressed, disabled, focus), panels, popups, tooltips, text fields, sliders, progress bars, tabs, check boxes, optional font. Saves a .tres and by default sets it as the project theme.',
        parameters: z.object({
            primary: z.any().optional().describe('Button and accent color, e.g. "#4c8bf5"'),
            background: z.any().optional().describe('Panel color; dark or light decides the text color'),
            text: z.any().optional(),
            corner_radius: z.number().int().min(0).max(64).optional(),
            border_width: z.number().int().min(0).max(8).optional(),
            font_size: z.number().int().min(8).max(96).optional(),
            font_path: z.string().optional().describe('res:// .ttf/.otf/.woff2'),
            save_path: z.string().optional().describe('Default res://ui/theme.tres'),
            apply_to_project: z.boolean().optional().describe('Default true: Project Settings > GUI > Theme > Custom'),
            node_path: z.string().optional().describe('Also set it on this Control'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, applied, error_8;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('generate_ui_theme', args)];
                    case 1:
                        r = _a.sent();
                        applied = r.applied_to;
                        return [2 /*return*/, "Saved ".concat(r.save_path, " (").concat(r.dark ? 'dark' : 'light', ", font size ").concat(r.font_size, ")").concat(applied.length ? "; applied to ".concat(applied.join(', ')) : '')];
                    case 2:
                        error_8 = _a.sent();
                        return [2 /*return*/, fail('generate UI theme', error_8)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
];
//# sourceMappingURL=asset_tools.js.map