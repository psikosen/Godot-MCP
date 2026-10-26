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
import { fail, send, vector2 } from './workflow_tools.js';
import { vector3 } from './builder_tools.js';
var status = function (r) { return "[".concat(r.status, "]"); };
var point = z.union([vector2, vector3]);
var boneAxis = z.enum(['+x', '-x', '+y', '-y', '+z', '-z']);
export var editableNote = function (r) {
    var _a;
    var opened = (_a = r.editable_children) !== null && _a !== void 0 ? _a : [];
    return opened.length ? "\nTurned on Editable Children for ".concat(opened.join(', '), " so the change saves") : '';
};
export var featureTools = [
    {
        name: 'describe_skeleton',
        description: 'Show a Skeleton3D\'s bone tree (finds the skeleton under a model node too), its modifiers, and arm/leg chains (root, middle, end) ready for setup_ik_chain.',
        parameters: z.object({
            node_path: z.string().describe('The Skeleton3D, or a model node that holds one'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, limbs, modifiers, error_1;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('describe_skeleton', args)];
                    case 1:
                        r = _a.sent();
                        limbs = r.limbs.map(function (l) { return "".concat(l.root, " > ").concat(l.middle, " > ").concat(l.end); });
                        modifiers = r.modifiers;
                        return [2 /*return*/, "".concat(r.skeleton_path, ": ").concat(r.bone_count, " bones\n").concat(r.outline)
                                + (limbs.length ? "\nLimbs: ".concat(limbs.join('; ')) : '')
                                + (modifiers.length ? "\nModifiers: ".concat(modifiers.join(', ')) : '')];
                    case 2:
                        error_1 = _a.sent();
                        return [2 /*return*/, fail('describe skeleton', error_1)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'read' },
    },
    {
        name: 'setup_ik_chain',
        description: 'Add inverse kinematics (Godot 4.6+) so bone chains reach for targets: two_bone for arms and legs (only end_bone needed), fabrik/ccdik/jacobian for longer chains, spline to follow a Path3D. Creates a Marker3D target per chain unless target_path is given, and for two_bone a pole marker the knee or elbow bends toward; move the markers to pose the limb. Undo-aware.',
        parameters: z.object({
            skeleton_path: z.string().describe('The Skeleton3D, or a model node that holds one'),
            solver: z.enum(['two_bone', 'fabrik', 'ccdik', 'jacobian', 'spline']).optional().describe('Default two_bone'),
            chains: z.array(z.object({
                end_bone: z.string().describe('e.g. "LeftHand" or "mixamorig:LeftFoot"'),
                root_bone: z.string().optional().describe('two_bone: default is the grandparent of end_bone; other solvers: required'),
                middle_bone: z.string().optional().describe('two_bone only; default is the parent of end_bone'),
                target_path: z.string().optional().describe('A 3D node to reach for; default creates "<end_bone>Target"'),
                pole_path: z.string().optional().describe('two_bone: a 3D node the knee or elbow points at; default creates "<middle_bone>Pole"'),
                path_3d: z.string().optional().describe('spline: the Path3D the chain follows'),
            }).strict()).min(1).max(16),
            max_iterations: z.number().int().min(1).max(1000).optional().describe('fabrik, ccdik, jacobian'),
            influence: z.number().min(0).max(1).optional(),
            name: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, chains, error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('setup_ik_chain', args)];
                    case 1:
                        r = _a.sent();
                        chains = r.chains.map(function (c) { var _a; return "".concat([c.root, c.middle, c.end].filter(Boolean).join(' > '), " -> ").concat((_a = c.target) !== null && _a !== void 0 ? _a : c.path_3d).concat(c.pole ? " (pole ".concat(c.pole, ")") : ''); });
                        return [2 /*return*/, "".concat(r.solver, " ").concat(r.node_path, " ").concat(status(r), ":\n").concat(chains.join('\n'))];
                    case 2:
                        error_2 = _a.sent();
                        return [2 /*return*/, fail('set up IK chain', error_2)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'add_bone_constraint',
        description: 'Make one bone follow something: aim (point at a node or bone, Godot 4.5+), copy_transform (copy another bone or node\'s position/rotation/scale, 4.5+), look_at (smoothly turn toward a node, with optional delay, 4.4+). Undo-aware.',
        parameters: z.object({
            skeleton_path: z.string(),
            type: z.enum(['aim', 'copy_transform', 'look_at']),
            bone: z.string().describe('The bone that moves, e.g. "Head"'),
            target_path: z.string().optional().describe('A 3D node to follow'),
            target_bone: z.string().optional().describe('Or a bone to follow (aim, copy_transform)'),
            forward_axis: boneAxis.optional().describe('Bone axis that points at the target (aim, look_at); default +y, the way Godot bones point'),
            amount: z.number().min(0).max(1).optional().describe('aim, copy_transform: blend 0..1 (default 1)'),
            copy: z.array(z.enum(['position', 'rotation', 'scale'])).optional().describe('copy_transform: default all three'),
            relative: z.boolean().optional().describe('copy_transform: copy relative to the rest pose'),
            duration: z.number().min(0).max(10).optional().describe('look_at: seconds to turn (0 = instant)'),
            name: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_3;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('add_bone_constraint', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "".concat(r.type, " ").concat(r.node_path, " ").concat(status(r), ": bone ").concat(r.bone, " follows ").concat(r.target)];
                    case 2:
                        error_3 = _a.sent();
                        return [2 /*return*/, fail('add bone constraint', error_3)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'setup_spring_bones',
        description: 'Make hair, tails, ears, capes or antennas jiggle and swing with SpringBoneSimulator3D (Godot 4.4+). One chain per root..end bone run; optional collision spheres on bones (e.g. head, chest) keep hair out of the body. Undo-aware.',
        parameters: z.object({
            skeleton_path: z.string(),
            chains: z.array(z.object({
                root_bone: z.string(),
                end_bone: z.string(),
                stiffness: z.number().min(0).max(4).optional().describe('How hard it springs back (Godot default 1)'),
                drag: z.number().min(0).max(1).optional().describe('Air resistance; higher settles faster'),
                gravity: z.number().min(0).max(10).optional().describe('Pull down, in m/s2'),
                gravity_direction: vector3.optional(),
                radius: z.number().min(0).max(1).optional().describe('Bone thickness for collisions, in meters'),
                extend_end_bone: z.boolean().optional().describe('Default true: let the last bone swing too'),
            }).strict()).min(1).max(32),
            colliders: z.array(z.object({
                bone: z.string(),
                radius: z.number().min(0.001).max(100).optional(),
                offset: vector3.optional(),
            }).strict()).max(32).optional(),
            name: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, colliders, error_4;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('setup_spring_bones', args)];
                    case 1:
                        r = _a.sent();
                        colliders = r.colliders;
                        return [2 /*return*/, "".concat(r.node_path, " ").concat(status(r), ":\n").concat(r.chains.join('\n'))
                                + (colliders.length ? "\nColliders: ".concat(colliders.join(', ')) : '')];
                    case 2:
                        error_4 = _a.sent();
                        return [2 /*return*/, fail('set up spring bones', error_4)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'set_stencil_effect',
        description: 'Outline a 3D object, or show it through walls (xray), with the stencil buffer (Godot 4.5+). Works on one MeshInstance3D or every mesh under a model node; each surface gets its own material copy. effect none removes it. Undo-aware.',
        parameters: z.object({
            node_path: z.string(),
            effect: z.enum(['outline', 'xray', 'none']).optional().describe('Default outline'),
            color: z.any().optional().describe('e.g. "#ffcc33"'),
            thickness: z.number().min(0).max(1).optional().describe('outline width in meters (default 0.02)'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, skipped, error_5;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('set_stencil_effect', args)];
                    case 1:
                        r = _a.sent();
                        skipped = r.skipped;
                        return [2 /*return*/, "".concat(r.effect, " on ").concat(r.node_path, ": ").concat(r.surfaces, " surface(s) ").concat(status(r))
                                + (skipped.length ? "; skipped: ".concat(skipped.join(', ')) : '')
                                + editableNote(r)];
                    case 2:
                        error_5 = _a.sent();
                        return [2 /*return*/, fail('set stencil effect', error_5)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'create_spatial_shader',
        description: 'Give a 3D mesh or CSG shape a ready-made shader: toon (cel shading), rim_glow (glowing edges), hologram, dissolve (animate progress 0..1), wind_sway (grass and leaves). Writes res://shaders/<effect>_3d.gdshader once and sets material_override.',
        parameters: z.object({
            node_path: z.string(),
            effect: z.enum(['toon', 'rim_glow', 'hologram', 'dissolve', 'wind_sway']),
            uniforms: z.record(z.any()).optional().describe('e.g. {"albedo": "#d08050", "bands": 3} or {"glow_color": "#33ccff"}'),
            shader_path: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_6;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('create_spatial_shader', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "".concat(r.effect, " on ").concat(r.node_path, " ").concat(status(r), " using ").concat(r.shader_path, "; uniforms: ").concat(r.uniforms.join(', '), ". Animate one with update_node_property \"material_override:shader_parameter/<name>\".").concat(editableNote(r))];
                    case 2:
                        error_6 = _a.sent();
                        return [2 /*return*/, fail('create spatial shader', error_6)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'add_touch_controls',
        description: 'Add phone and tablet controls on a CanvasLayer: a VirtualJoystick bound to move actions (Godot 4.7+) and round TouchScreenButtons bound to input actions (bottom right). The layer shows only on touch screens unless show_on_desktop. Undo-aware.',
        parameters: z.object({
            parent_path: z.string().optional().describe('Default /root'),
            joystick: z.boolean().optional().describe('Default true; false for buttons only (any Godot 4)'),
            joystick_actions: z.object({ left: z.string(), right: z.string(), up: z.string(), down: z.string() }).partial().strict().optional()
                .describe('Default ui_left, ui_right, ui_up, ui_down'),
            joystick_mode: z.enum(['fixed', 'dynamic', 'following']).optional().describe('dynamic (default) appears where the thumb lands'),
            joystick_size: z.number().min(60).max(500).optional(),
            buttons: z.array(z.object({
                action: z.string(),
                label: z.string().optional(),
                position: vector2.optional().describe('Pixels; default is a row in the bottom right'),
                name: z.string().optional(),
            }).strict()).max(8).optional(),
            button_size: z.number().min(32).max(400).optional().describe('Pixels, default 96'),
            show_on_desktop: z.boolean().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, undefinedActions, error_7;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('add_touch_controls', args)];
                    case 1:
                        r = _a.sent();
                        undefinedActions = r.undefined_actions;
                        return [2 /*return*/, "".concat(r.node_path, " ").concat(status(r), ": ").concat(r.joystick ? 'joystick, ' : '', "buttons ").concat(r.buttons.join(', ') || 'none')
                                + (undefinedActions.length ? "\nNot defined yet (add with add_input_action): ".concat(undefinedActions.join(', ')) : '')];
                    case 2:
                        error_7 = _a.sent();
                        return [2 /*return*/, fail('add touch controls', error_7)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'set_accessibility_info',
        description: 'Set screen-reader names and descriptions on UI Controls (Godot 4.5+). auto_fill_root names every button, slider or field under it that has no text and no name yet, from its tooltip or node name. Pair with validate_accessibility. Undo-aware.',
        parameters: z.object({
            entries: z.array(z.object({
                node_path: z.string(),
                name: z.string().optional(),
                description: z.string().optional(),
            }).strict()).max(200).optional(),
            auto_fill_root: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, applied, error_8;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('set_accessibility_info', args)];
                    case 1:
                        r = _a.sent();
                        applied = r.applied;
                        return [2 /*return*/, applied.length ? "Set ".concat(applied.length, " ").concat(status(r), ":\n").concat(applied.join('\n')).concat(editableNote(r)) : 'Nothing to set: every interactive control already has text or a name.'];
                    case 2:
                        error_8 = _a.sent();
                        return [2 /*return*/, fail('set accessibility info', error_8)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'create_path',
        description: 'Create a Path2D or Path3D (from the parent type) through points, for patrol routes, rails, rivers or camera tracks. smooth rounds the corners; closed makes a loop. Undo-aware.',
        parameters: z.object({
            parent_path: z.string().optional(),
            points: z.array(point).min(2).max(1000).describe('[[x, y], ...] for 2D or [[x, y, z], ...] for 3D'),
            smooth: z.boolean().optional(),
            closed: z.boolean().optional(),
            name: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_9;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('create_path', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "".concat(r.type, " ").concat(r.node_path, " ").concat(status(r), ": ").concat(r.points, " points, length ").concat(r.length)];
                    case 2:
                        error_9 = _a.sent();
                        return [2 /*return*/, fail('create path', error_9)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'place_along_path',
        description: 'Place copies of a scene along a Path2D or Path3D (coins on an arc, fence posts, torches down a corridor) by count or spacing, turned to follow the path. Copies go in one container under the path. Undo-aware.',
        parameters: z.object({
            path_path: z.string(),
            scene_path: z.string().describe('res:// scene to copy; 2D root for Path2D, 3D root for Path3D'),
            count: z.number().int().min(1).max(500).optional().describe('Default 10, evenly spread'),
            spacing: z.number().positive().optional().describe('Distance between copies (instead of count)'),
            align: z.boolean().optional().describe('Default true: turn each copy along the path'),
            name: z.string().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_10;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('place_along_path', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "Placed ".concat(r.count, " under ").concat(r.node_path, " ").concat(status(r), " (path length ").concat(r.path_length, ")")];
                    case 2:
                        error_10 = _a.sent();
                        return [2 /*return*/, fail('place along path', error_10)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'snap_to_ground',
        description: 'Drop 3D nodes onto the ground below them, like the editor\'s Snap Object to Floor: a physics ray finds the first collision body underneath (terrain, floors, blockouts). Use after placing coins, props or spawn points on uneven ground. Undo-aware.',
        parameters: z.object({
            node_paths: z.array(z.string()).max(2000).optional(),
            parent_path: z.string().optional().describe('Snap every 3D child of this node'),
            offset: z.number().optional().describe('Height above the ground, in meters (default 0)'),
            align_to_normal: z.boolean().optional().describe('Tilt each node to the slope'),
            max_rise: z.number().min(0).optional().describe('Look for ground up to this far above the node too (default 50)'),
            remove_below: z.number().optional().describe('Delete nodes whose ground is lower than this y (trees that land in the sea)'),
            remove_above: z.number().optional().describe('Delete nodes whose ground is higher than this y'),
            collision_mask: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, missed, error_11;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('snap_to_ground', args)];
                    case 1:
                        r = _a.sent();
                        missed = r.missed;
                        return [2 /*return*/, "Snapped ".concat(r.moved, " node(s) ").concat(status(r)).concat(r.changes.length ? ": ".concat(r.changes.join(', ')) : '')
                                + (r.removed ? "\nRemoved ".concat(r.removed, " outside the height range") : '')
                                + (missed.length ? "\nNo ground under: ".concat(missed.join(', ')) : '') + editableNote(r)];
                    case 2:
                        error_11 = _a.sent();
                        return [2 /*return*/, fail('snap to ground', error_11)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'build_mesh_library',
        description: 'Make a GridMap MeshLibrary from a scene (or open-scene node) whose children are MeshInstance3D tiles, like Scene > Export As > MeshLibrary. StaticBody3D children give collision; NavigationRegion3D children give navmesh. Optionally assigns it to a GridMap.',
        parameters: z.object({
            source: z.string().describe('res://tiles.tscn, or a node path like /root/Tiles'),
            save_path: z.string().describe('res://.../tiles.tres (or .meshlib)'),
            gridmap_path: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, error_12;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('build_mesh_library', args)];
                    case 1:
                        r = _a.sent();
                        return [2 /*return*/, "Saved ".concat(r.save_path, " with ").concat(r.items.length, " item(s): ").concat(r.items.join(', '))
                                + (r.gridmap_path ? "\nAssigned to ".concat(r.gridmap_path, " ").concat(status(r)) : '')];
                    case 2:
                        error_12 = _a.sent();
                        return [2 /*return*/, fail('build mesh library', error_12)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
];
//# sourceMappingURL=feature_tools.js.map