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
var vector = z.union([
    z.object({ x: z.number(), y: z.number(), z: z.number().optional() }),
    z.array(z.number()).min(2).max(3),
]);
export var vfxTools = [
    {
        name: 'build_vfx_effect',
        description: 'One-call layered effect: explosion, hit_impact, muzzle_flash, magic_burst, fire or sparks. Core flash, sparks (sub-emitters where they fit), smoke, a light pop, optional camera shake; 2D or 3D. Plays when the game runs; play() fires it again. Undo-aware.',
        parameters: z.object({
            preset: z.enum(['explosion', 'hit_impact', 'muzzle_flash', 'magic_burst', 'fire', 'sparks']),
            dimension: z.enum(['3d', '2d']).optional().describe('Default 3d'),
            parent_path: z.string().optional(),
            name: z.string().optional(),
            position: vector.optional(),
            direction: vector.optional().describe('Where it points: a surface normal (wall hit), a gun barrel. Default up; muzzle -Z, right in 2D'),
            scale: z.number().min(0.05).max(100).optional().describe('Size multiplier (default 1: about a 3 m explosion, 2D at 64 px per meter)'),
            color: z.any().optional().describe('Tint, e.g. "#40a0ff" for a blue explosion'),
            loop: z.boolean().optional().describe('Repeat instead of one burst (fire loops by default)'),
            light: z.boolean().optional().describe('Default true'),
            camera_shake: z.boolean().optional().describe('Default true for explosion'),
            autoplay: z.boolean().optional().describe('Default true: plays when it enters the game'),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, subs, extras, error_1;
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _b.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('build_vfx_effect', args)];
                    case 1:
                        r = _b.sent();
                        subs = r.sub_emitters;
                        extras = [r.light ? 'light pop' : '', r.camera_shake ? 'camera shake' : '', r.loop ? 'looping' : ''].filter(Boolean);
                        return [2 /*return*/, "".concat(r.preset, " (").concat(r.dimension, ") at ").concat(r.node_path, " [").concat(r.status, "]: ").concat(r.layers.join(', '))
                                + (subs.length ? "; sub-emitters ".concat(subs.join(', ')) : '') + (extras.length ? "; ".concat(extras.join(', ')) : '')
                                + ". Plays when the game runs; call play() on it to fire again. Tune a layer with configure_particles_3d (3D)."
                                + ((_a = r.notes) !== null && _a !== void 0 ? _a : []).map(function (note) { return "\nNote: ".concat(note); }).join('')];
                    case 2:
                        error_1 = _b.sent();
                        return [2 /*return*/, fail('build VFX effect', error_1)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
    {
        name: 'build_pixel_vfx',
        description: 'Pixel-art 2D effect drawn live by a shader: hard colour bands on a real pixel grid, stepped frames. One-shots: explosion, lightning, heal, slash, impact, poof, slam. Loops: tornado, vortex, fireball, beam, portal, shield, flame. element or color recolours it. Optional light and camera shake. Plays when the game runs; play() fires it again. Undo-aware.',
        parameters: z.object({
            preset: z.enum(['tornado', 'explosion', 'lightning', 'vortex', 'heal', 'slash', 'impact', 'poof', 'slam', 'fireball', 'beam', 'portal', 'shield', 'flame']),
            element: z.enum(['fire', 'ice', 'lightning', 'wind', 'dark', 'holy', 'nature', 'arcane', 'poison', 'water', 'blood', 'earth', 'plasma', 'steel'])
                .optional().describe('Colours (default per preset: wind tornado, fire explosion, ...); fire + tornado makes a firestorm'),
            color: z.any().optional().describe('Any colour instead of an element, e.g. "#40a0ff"'),
            parent_path: z.string().optional(),
            name: z.string().optional(),
            position: vector.optional().describe('Ground effects (tornado, lightning, heal, slam, flame) stand on this point; beam starts here'),
            pixel_scale: z.number().int().min(1).max(16).optional().describe('Screen pixels per art pixel (default 4)'),
            flip: z.boolean().optional().describe('Face left (slash, fireball and beam face right)'),
            light: z.boolean().optional().describe('A PointLight2D that pops or glows with the effect (default on for glowing presets)'),
            camera_shake: z.boolean().optional().describe('Default on for explosion, lightning, impact and slam'),
            autoplay: z.boolean().optional().describe('Default true: plays when it enters the game'),
            replay_every: z.number().min(0).optional().describe('Seconds between replays of a one-shot (0 plays once)'),
            seed: z.number().int().optional(),
            transaction_id: z.string().optional(),
        }),
        execute: function (args) { return __awaiter(void 0, void 0, void 0, function () {
            var r, _a, w, h, extras, error_2;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _b.trys.push([0, 2, , 3]);
                        return [4 /*yield*/, send('build_pixel_vfx', args)];
                    case 1:
                        r = _b.sent();
                        _a = r.canvas, w = _a[0], h = _a[1];
                        extras = [r.light ? 'light' : '', r.camera_shake ? 'camera shake' : '', r.loop ? 'looping' : 'one-shot'].filter(Boolean);
                        return [2 /*return*/, "".concat(r.element, " ").concat(r.preset, " at ").concat(r.node_path, " [").concat(r.status, "]: ").concat(w, "x").concat(h, " art pixels at ").concat(r.pixel_scale, "x, ").concat(r.frames, " frames at ").concat(r.fps, " fps; ").concat(extras.join(', '), ".")
                                + " Plays when the game runs; play() fires it again. Colours: ".concat(r.ramps.map(function (slot) { return "FX material ".concat(slot, "_ramp"); }).join(', '), ".")
                                + ' See it move: capture_scene_image with filmstrip.'];
                    case 2:
                        error_2 = _b.sent();
                        return [2 /*return*/, fail('build pixel VFX', error_2)];
                    case 3: return [2 /*return*/];
                }
            });
        }); },
        metadata: { requiredRole: 'edit' },
    },
];
//# sourceMappingURL=vfx_tools.js.map