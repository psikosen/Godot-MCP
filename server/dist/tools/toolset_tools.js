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
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
import { z } from 'zod';
import { TOOLSETS, groupsOf, toolsetMenu } from '../utils/toolsets.js';
var GROUPS = TOOLSETS.filter(function (name) { return name !== 'core'; });
/**
 * load_tools turns tool groups on and off while the session runs. add/remove change the server's
 * tool list, which sends notifications/tools/list_changed so the client lists the tools again.
 * `enabled` is the live set of groups that are on; this tool changes it. A tool is on while any
 * of its groups is on, so unloading a task group keeps tools another loaded group still has.
 */
export function loadToolsTool(tools, enabled, add, remove) {
    var _this = this;
    var _a;
    var byGroup = new Map();
    for (var _i = 0, tools_1 = tools; _i < tools_1.length; _i++) {
        var tool = tools_1[_i];
        for (var _b = 0, _c = groupsOf(tool.name); _b < _c.length; _b++) {
            var group = _c[_b];
            byGroup.set(group, __spreadArray(__spreadArray([], ((_a = byGroup.get(group)) !== null && _a !== void 0 ? _a : []), true), [tool], false));
        }
    }
    var counts = new Map(Array.from(byGroup, function (_a) {
        var group = _a[0], list = _a[1];
        return [group, list.length];
    }));
    var isOn = function (tool) { return groupsOf(tool.name).some(function (group) { return enabled.has(group); }); };
    var offGroups = function () { return GROUPS.filter(function (group) { return !enabled.has(group) && counts.get(group); }); };
    return {
        name: 'load_tools',
        description: 'Turn on more Godot tools. At first only core is on (open, save and inspect scenes; edit nodes; scripts; ' +
            'undo; errors; search). Before you start, turn on what the task needs: a task group if one fits, else feature groups. ' +
            'Unload groups when done to save tokens. No arguments: show what is on.\n' + toolsetMenu(counts),
        parameters: z.object({
            groups: z.array(z.enum(GROUPS)).max(GROUPS.length).optional().describe('Groups to turn on, e.g. ["player_2d"]'),
            unload: z.array(z.enum(GROUPS)).max(GROUPS.length).optional().describe('Groups to turn off'),
        }),
        execute: function (_a) { return __awaiter(_this, [_a], void 0, function (_b) {
            var added, removed, wasOn, turnedOff, turnedOn, lines;
            var _c = _b.groups, groups = _c === void 0 ? [] : _c, _d = _b.unload, unload = _d === void 0 ? [] : _d;
            return __generator(this, function (_e) {
                switch (_e.label) {
                    case 0:
                        added = Array.from(new Set(groups)).filter(function (group) { return !enabled.has(group); });
                        removed = Array.from(new Set(unload)).filter(function (group) { return enabled.has(group) && !groups.includes(group); });
                        wasOn = new Set(tools.filter(isOn));
                        added.forEach(function (group) { return enabled.add(group); });
                        removed.forEach(function (group) { return enabled.delete(group); });
                        turnedOff = tools.filter(function (tool) { return wasOn.has(tool) && !isOn(tool); });
                        turnedOn = tools.filter(function (tool) { return !wasOn.has(tool) && isOn(tool); });
                        if (!(turnedOff.length > 0)) return [3 /*break*/, 2];
                        return [4 /*yield*/, remove(turnedOff.map(function (tool) { return tool.name; }))];
                    case 1:
                        _e.sent();
                        _e.label = 2;
                    case 2:
                        if (!(turnedOn.length > 0)) return [3 /*break*/, 4];
                        return [4 /*yield*/, add(turnedOn)];
                    case 3:
                        _e.sent();
                        _e.label = 4;
                    case 4:
                        lines = added.map(function (group) { var _a; return "Turned on ".concat(group, ": ").concat(((_a = byGroup.get(group)) !== null && _a !== void 0 ? _a : []).map(function (tool) { return tool.name; }).join(', ')); });
                        if (removed.length > 0) {
                            lines.push("Turned off ".concat(removed.join(', '), " (").concat(turnedOff.length, " tools; tools still in a loaded group stay on)."));
                        }
                        lines.push("On: ".concat(Array.from(enabled).join(', '), ". Off: ").concat(offGroups().join(', ') || 'none', "."));
                        if (turnedOn.length > 0) {
                            lines.push('If these tools do not appear, this app does not refresh its tool list: ask the user to set ' +
                                "GODOT_MCP_TOOLSETS to \"all\" or to the groups you need (e.g. \"".concat(added.join(','), "\") and restart the app."));
                        }
                        return [2 /*return*/, lines.join('\n')];
                }
            });
        }); },
        metadata: { requiredRole: 'read' },
    };
}
//# sourceMappingURL=toolset_tools.js.map