# Task Plan

## Completed
- [x] Research additional Godot editor features that expand MCP automation options
- [x] Implement new node group management commands in the Godot MCP plugin
- [x] Implement new input map management commands in the Godot MCP plugin
- [x] Expose new commands through the MCP server tool definitions
- [x] Update README with a comprehensive abilities list and new capabilities
- [x] Update command documentation to include the new tooling
- [x] Run TypeScript build to ensure the server compiles after changes

## Upcoming — Align MCP coverage with core Godot systems
- [x] Add navigation map and agent tooling so MCP can read, bake, and edit resources backed by the `navigation_2d` and `navigation_3d` modules.
- [ ] Extend scene commands to support physics body, area, and joint configuration in line with `godot_physics_2d` and `godot_physics_3d` modules.
- [ ] Provide CSG and GridMap manipulation helpers covering the `csg` and `gridmap` modules for rapid level prototyping.
- [ ] Integrate GLTF and FBX import automation to mirror workflows supported by the `gltf` and `fbx` modules.
- [ ] Surface audio bus, interactive music, and audio stream configuration commands to match `interactive_music`, `ogg`, and `vorbis` module capabilities.
- [ ] Add shader and material editing pipelines that understand `glslang`, `lightmapper_rd`, and `meshoptimizer` module outputs.
- [ ] Support XR platform setup commands for `openxr`, `mobile_vr`, and `webxr` modules.
- [ ] Enable multiplayer session scaffolding and high-level networking helpers aligned with the `multiplayer`, `webrtc`, and `websocket` modules.
- [ ] Provide compression and texture pipeline automation for `astcenc`, `ktx`, and `webp` module workflows.
