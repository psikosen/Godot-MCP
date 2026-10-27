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
var transactionId = z.string().optional()
    .describe('Add the node change to an open scene transaction instead of committing it now');
var status = function (r) { return (r.status ? " [".concat(r.status, "]") : ''); };
var assigned = function (r) { return (r.node_path ? ", assigned to ".concat(r.node_path).concat(status(r)) : ''); };
var animation = z.object({
    name: z.string().min(1),
    frames: z.array(z.number().int().min(0)).max(256).optional()
        .describe('Frame numbers, counted left to right then top to bottom from 0'),
    row: z.number().int().min(0).optional()
        .describe('Use every frame of this row (instead of frames)'),
    fps: z.number().positive().optional().describe('Frames per second (default 10)'),
    loop: z.boolean().optional().describe('Default true'),
});
export var authoringTools = [
    {
        name: 'create_tileset_2d',
        description: 'Make a TileSet from a sprite sheet: one tile per grid cell (fully transparent cells skipped), saved as .tres. Optional full-tile collision and assignment to a TileMapLayer. Then paint with paint_tilemap_cells_2d or paint_tilemap_ascii (source_id 0).',
        parameters: z.object({
            texture_path: z.string().describe('Sprite sheet image, e.g. "res://art/tiles.png"'),
            tile_size: vector2.describe('Tile size in pixels, e.g. {"x": 16, "y": 16}'),
            save_path: z.string().describe('Where to save the TileSet, e.g. "res://tiles/world.tres"'),
            margins: vector2.optional().describe('Pixels to skip at the left and top edge of the sheet'),
            separation: vector2.optional().describe('Pixels between tiles'),
            skip_empty: z.boolean().optional().describe('Skip fully transparent cells (default true)'),
            collision: z.union([z.enum(['none', 'all']), z.array(vector2).max(4096)]).optional()
                .describe('Full-tile square collision: "none" (default), "all", or tile coordinates [[x, y], ...]'),
            node_path: z.string().optional().describe('TileMapLayer to give the TileSet to (undoable)'),
            overwrite: z.boolean().optional().describe('Replace save_path if it exists (default false)'),
            transaction_id: transactionId,
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, _a, columns, rows, skipped, collision, error_1;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _b.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('create_tileset_2d', args)];
                    case 1:
                        r = _b.sent();
                        _a = r.grid, columns = _a[0], rows = _a[1];
                        skipped = r.skipped_empty ? ", ".concat(r.skipped_empty, " empty skipped") : '';
                        collision = r.collision_tiles ? ", collision on ".concat(r.collision_tiles) : '';
                        return [2 /*return*/, "Saved TileSet ".concat(r.save_path, ": ").concat(r.tiles, " tiles (").concat(columns, "x").concat(rows, " grid").concat(skipped).concat(collision, "), source_id ").concat(r.source_id).concat(assigned(r))];
                    case 2:
                        error_1 = _b.sent();
                        return [2 /*return*/, fail('create TileSet', error_1)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'create_sprite_frames',
        description: 'Make SpriteFrames (named animations) for AnimatedSprite2D/3D from a grid sprite sheet. Save as .tres, give to a node, or both.',
        parameters: z.object({
            texture_path: z.string().describe('Sprite sheet image, e.g. "res://art/hero.png"'),
            frame_size: vector2.optional().describe('Frame size in pixels; or use hframes/vframes'),
            hframes: z.number().int().min(1).optional().describe('Frames across the sheet'),
            vframes: z.number().int().min(1).optional().describe('Frames down the sheet'),
            animations: z.array(animation).min(1).max(64)
                .describe('e.g. [{"name": "run", "row": 1, "fps": 12}, {"name": "jump", "frames": [8, 9], "loop": false}]'),
            save_path: z.string().optional().describe('Where to save the SpriteFrames (.tres)'),
            node_path: z.string().optional().describe('AnimatedSprite2D or AnimatedSprite3D to give the frames to (undoable)'),
            autoplay: z.string().optional().describe('Animation the node plays on start'),
            overwrite: z.boolean().optional().describe('Replace save_path if it exists (default false)'),
            transaction_id: transactionId,
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, animations, where, error_2;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('create_sprite_frames', args)];
                    case 1:
                        r = _a.sent();
                        animations = r.animations
                            .map(function (a) { return "".concat(a.name, " (").concat(a.frames, " frames, ").concat(a.fps, " fps").concat(a.loop ? ', loop' : '', ")"); });
                        where = r.save_path ? "Saved SpriteFrames ".concat(r.save_path) : 'Created SpriteFrames';
                        return [2 /*return*/, "".concat(where, ": ").concat(animations.join(', ')).concat(assigned(r))];
                    case 2:
                        error_2 = _a.sent();
                        return [2 /*return*/, fail('create SpriteFrames', error_2)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'undo_redo',
        description: 'Undo or redo the last editor actions, the same as pressing Undo/Redo in the Godot editor (scene and project history). Says which actions it undid. Files saved by save_path or update_resource_properties stay as written.',
        parameters: z.object({
            action: z.enum(['undo', 'redo']).optional().describe('Default "undo"'),
            steps: z.number().int().min(1).max(20).optional().describe('How many actions (default 1)'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, verb, done, head, error_3;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('undo_redo', args)];
                    case 1:
                        r = _a.sent();
                        verb = r.action === 'redo' ? 'Redid' : 'Undid';
                        done = r.actions.map(function (name) { return name || '(unnamed)'; });
                        head = done.length ? "".concat(verb, " ").concat(done.length, ": ").concat(done.join(', '), ".") : "Nothing to ".concat(r.action, ".");
                        return [2 /*return*/, "".concat(head, " Can undo: ").concat(r.can_undo ? 'yes' : 'no', ", can redo: ").concat(r.can_redo ? 'yes' : 'no', ".")];
                    case 2:
                        error_3 = _a.sent();
                        return [2 /*return*/, fail('undo/redo', error_3)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'get_resource_properties',
        description: 'Read the saved properties of a resource file (.tres/.res: custom Resources, materials, styleboxes, curves, TileSets, SpriteFrames). Sub-resources show as their file path or <Class>.',
        parameters: z.object({
            path: z.string().describe('Resource file, e.g. "res://data/sword.tres"'),
            properties: z.array(z.string()).max(200).optional().describe('Only these properties'),
            changed_only: z.boolean().optional().describe('Only properties that differ from the class or script default'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, lines, missing, script, error_4;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _b.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('get_resource_properties', args)];
                    case 1:
                        r = _b.sent();
                        lines = Object.entries(r.properties)
                            .map(function (_a) {
                            var key = _a[0], value = _a[1];
                            return "".concat(key, ": ").concat(JSON.stringify(value));
                        });
                        missing = (_a = r.missing) !== null && _a !== void 0 ? _a : [];
                        if (missing.length > 0)
                            lines.push("missing: ".concat(missing.join(', ')));
                        script = r.script ? " (script ".concat(r.script, ")") : '';
                        return [2 /*return*/, "".concat(r.class, " ").concat(r.path).concat(script, ":\n").concat(lines.join('\n') || '(none differ from defaults)')];
                    case 2:
                        error_4 = _b.sent();
                        return [2 /*return*/, fail('read resource', error_4)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'read' },
    },
    {
        name: 'update_resource_properties',
        description: 'Set properties on a resource file and save it. All values are checked first; one bad value changes nothing. Not for scenes or scripts. Not on the undo history.',
        parameters: z.object({
            path: z.string().describe('Resource file, e.g. "res://data/sword.tres"'),
            properties: z.record(z.unknown()).describe('e.g. {"damage": 12, "color": "#ff8800", "icon": "res://icons/sword.png"}'),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, changes, error_5;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        _a.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('update_resource_properties', args)];
                    case 1:
                        r = _a.sent();
                        changes = Object.entries(r.changed)
                            .map(function (_a) {
                            var key = _a[0], change = _a[1];
                            return "".concat(key, ": ").concat(JSON.stringify(change.from), " -> ").concat(JSON.stringify(change.to));
                        });
                        return [2 /*return*/, "Saved ".concat(r.path, ":\n").concat(changes.join('\n'))];
                    case 2:
                        error_5 = _a.sent();
                        return [2 /*return*/, fail('update resource', error_5)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
];
//# sourceMappingURL=authoring_tools.js.map