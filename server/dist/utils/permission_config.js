/**
 * Default capability configuration describing which relative paths can be
 * written by automated patch tooling. These values err on the side of
 * protecting project assets that could break the sample project when edited
 * blindly (e.g. imported assets, binaries).
 */
export var defaultCapabilityConfig = {
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
};
//# sourceMappingURL=permission_config.js.map