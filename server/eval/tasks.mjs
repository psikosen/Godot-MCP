// Agent eval tasks: a plain-language job, the scene it starts from, and a check on the result.
// {dir} is a fresh res:// folder per run. `expect` names the groups a sensible pick includes (any one).
const v3 = (x, y, z) => ({ x, y, z });
const v2 = (x, y) => ({ x, y });

export const TASKS = {
  player2d: {
    expect: ['player_2d', '2d'],
    setup: () => [],
    prompt: dir => `Create a new 2D scene ${dir}/level.tscn with a floor and a player character that runs left and right and jumps (arrow keys and space), with a camera that follows the player. Save the scene.`,
    scene: dir => `${dir}/level.tscn`,
    check: tree => [
      [/\(CharacterBody2D\)[^\n]*script=/.test(tree), 'CharacterBody2D with a script'],
      [/\(Camera2D\)/.test(tree), 'Camera2D'],
      [/\((StaticBody2D|TileMapLayer|TileMap)\)/.test(tree), 'a floor'],
    ],
  },
  enemy3d: {
    expect: ['enemies'],
    setup: dir => [
      ['create_scene', { path: `${dir}/arena.tscn`, root_node_type: 'Node3D' }],
      ['batch_create_nodes', { parent_path: '/root', nodes: [
        { node_type: 'StaticBody3D', node_name: 'Floor' },
        { node_type: 'CharacterBody3D', node_name: 'Player', properties: { position: v3(0, 1, 6) } }] }],
      ['batch_create_nodes', { parent_path: '/root/Floor', nodes: [
        { node_type: 'CollisionShape3D', node_name: 'Shape', properties: { shape: { type: 'BoxShape3D', size: v3(40, 1, 40) } } },
        { node_type: 'MeshInstance3D', node_name: 'Mesh', properties: { mesh: { type: 'BoxMesh', size: v3(40, 1, 40) } } }] }],
      ['batch_create_nodes', { parent_path: '/root/Player', nodes: [
        { node_type: 'CollisionShape3D', node_name: 'Shape', properties: { shape: 'CapsuleShape3D' } }] }],
      ['add_node_to_group', { node_path: '/root/Player', group_name: 'player', persistent: true }],
      ['save_scene', { path: `${dir}/arena.tscn` }],
    ],
    prompt: dir => `Open ${dir}/arena.tscn. Add an enemy that patrols back and forth between two points and chases the Player when it sees them. Save the scene.`,
    scene: dir => `${dir}/arena.tscn`,
    check: tree => [
      [tree.split('\n').some(line => /\(CharacterBody3D\)[^\n]*script=/.test(line) && !/^\s*Player /.test(line)), 'an enemy body with a script'],
    ],
  },
  tiles: {
    expect: ['tilemap_level', 'procgen_2d', '2d', 'art'],
    setup: dir => [['generate_placeholder_art', { sprites: [{ shape: 'tile', name: 'sheet', size: [128, 32] }], folder: dir }]],
    prompt: dir => `Use the sprite sheet ${dir}/sheet.png (32x32 pixel tiles) to make a TileSet, then build a small platformer level (a ground row and three floating platforms) on a TileMapLayer in a new scene ${dir}/level.tscn. Save the scene.`,
    scene: dir => `${dir}/level.tscn`,
    check: (tree, props) => [
      [/\(TileMapLayer\)/.test(tree), 'TileMapLayer'],
      [/tile_set: "res:\/\/|tile_set: "<TileSet>/.test(props.tilemap ?? ''), 'TileSet assigned'],
    ],
    propTypes: { tilemap: 'TileMapLayer' },
  },
  lighting: {
    expect: ['lighting', '3d', 'assets'],
    setup: dir => [
      ['create_scene', { path: `${dir}/scene.tscn`, root_node_type: 'Node3D' }],
      ['batch_create_nodes', { parent_path: '/root', nodes: [
        { node_type: 'MeshInstance3D', node_name: 'Ground', properties: { mesh: { type: 'PlaneMesh', size: v2(20, 20) } } },
        { node_type: 'MeshInstance3D', node_name: 'Box1', properties: { mesh: 'BoxMesh', position: v3(-2, 0.5, 0) } },
        { node_type: 'MeshInstance3D', node_name: 'Box2', properties: { mesh: 'BoxMesh', position: v3(2, 0.5, -1) } },
        { node_type: 'Camera3D', node_name: 'Camera', properties: { position: v3(0, 4, 10), rotation: v3(-0.3, 0, 0) } }] }],
      ['save_scene', { path: `${dir}/scene.tscn` }],
    ],
    prompt: dir => `Open ${dir}/scene.tscn and light it like a warm sunset: a low orange sun that casts shadows, and a sky. Save the scene.`,
    scene: dir => `${dir}/scene.tscn`,
    check: (tree, props) => [
      [/\(DirectionalLight3D\)/.test(tree), 'DirectionalLight3D'],
      [/shadow_enabled: true/.test(props.sun ?? ''), 'sun casts shadows'],
      [/\(WorldEnvironment\)/.test(tree), 'WorldEnvironment'],
    ],
    propTypes: { sun: 'DirectionalLight3D' },
  },
  island: {
    expect: ['world_3d', 'procgen_3d', 'water'],
    setup: dir => [
      ['create_scene', { path: `${dir}/tree.tscn`, root_node_type: 'MeshInstance3D' }],
      ['update_node_property', { node_path: '/root', property: 'mesh', value: { type: 'CylinderMesh', height: 3, top_radius: 0.2, bottom_radius: 0.3 } }],
      ['save_scene', { path: `${dir}/tree.tscn` }],
    ],
    prompt: dir => `Make an island in a new 3D scene ${dir}/world.tscn: hilly terrain surrounded by water, with about 30 copies of ${dir}/tree.tscn placed on the land. Save the scene.`,
    scene: dir => `${dir}/world.tscn`,
    check: (tree, _props, dir) => [
      [tree.split(`@${dir}/tree.tscn`).length > 20 || /\(MultiMeshInstance3D\)/.test(tree), '20+ trees'],
      [/water|ocean|sea/i.test(tree), 'water'],
      [/terrain|island|land|ground/i.test(tree), 'terrain'],
    ],
  },
  paths: {
    expect: ['paths'],
    setup: dir => [
      ['create_scene', { path: `${dir}/level.tscn`, root_node_type: 'Node2D' }],
      ['batch_create_nodes', { parent_path: '/root', nodes: [{ node_type: 'AnimatableBody2D', node_name: 'Platform', properties: { position: v2(100, 300) } }] }],
      ['batch_create_nodes', { parent_path: '/root/Platform', nodes: [
        { node_type: 'CollisionShape2D', node_name: 'Shape', properties: { shape: { type: 'RectangleShape2D', size: v2(96, 16) } } }] }],
      ['save_scene', { path: `${dir}/level.tscn` }],
    ],
    prompt: dir => `Open ${dir}/level.tscn and make the Platform move back and forth along a straight horizontal path of 300 pixels, forever, while the game runs. Save the scene.`,
    scene: dir => `${dir}/level.tscn`,
    check: tree => [
      [/\(Path2D\)[\s\S]*\(PathFollow2D\)|\(AnimationPlayer\)|Platform \(AnimatableBody2D\)[^\n]*script=/.test(tree), 'a path, animation or script moves it'],
    ],
  },
  vfx: {
    expect: ['vfx'],
    setup: dir => [
      ['create_scene', { path: `${dir}/level.tscn`, root_node_type: 'Node2D' }],
      ['batch_create_nodes', { parent_path: '/root', nodes: [{ node_type: 'CharacterBody2D', node_name: 'Player', properties: { position: v2(200, 300) } }] }],
      ['batch_create_nodes', { parent_path: '/root/Player', nodes: [
        { node_type: 'CollisionShape2D', node_name: 'Shape', properties: { shape: { type: 'CapsuleShape2D', radius: 12, height: 40 } } }] }],
      ['save_scene', { path: `${dir}/level.tscn` }],
    ],
    prompt: dir => `Open ${dir}/level.tscn. Add a dust particle effect at the Player's feet and a vignette over the whole screen. Save the scene.`,
    scene: dir => `${dir}/level.tscn`,
    check: tree => [
      [/\((GPUParticles2D|CPUParticles2D)\)/.test(tree), 'particles'],
      [/\(CanvasLayer\)/.test(tree), 'screen overlay'],
    ],
  },
  coins: {
    expect: ['gameplay'],
    setup: dir => [
      ['create_scene', { path: `${dir}/level.tscn`, root_node_type: 'Node2D' }],
      ['batch_create_nodes', { parent_path: '/root', nodes: [{ node_type: 'CharacterBody2D', node_name: 'Player', properties: { position: v2(100, 300) } }] }],
      ['batch_create_nodes', { parent_path: '/root/Player', nodes: [
        { node_type: 'CollisionShape2D', node_name: 'Shape', properties: { shape: { type: 'CircleShape2D', radius: 16 } } }] }],
      ['add_node_to_group', { node_path: '/root/Player', group_name: 'player', persistent: true }],
      ['save_scene', { path: `${dir}/level.tscn` }],
    ],
    prompt: dir => `Open ${dir}/level.tscn. Add 5 coins that disappear when the Player touches them and add 1 to a score shown on screen. Save the scene.`,
    scene: dir => `${dir}/level.tscn`,
    check: tree => [
      [(tree.match(/\(Area2D\)/g) ?? []).length >= 5 || (tree.match(/@res:\/\/[^\s]*coin[^\s]*\.tscn/gi) ?? []).length >= 5, '5 coins'],
      [/\(Label\)/.test(tree), 'score label'],
      [/script=/.test(tree), 'a script'],
    ],
  },
  // Held out: added after the groups and tools were tuned, to catch tuning that only fits the tasks above.
  player3d: {
    expect: ['player_3d', '3d'],
    setup: () => [],
    prompt: dir => `Create a new 3D scene ${dir}/world.tscn with a floor and a player that walks with WASD and jumps with space, with a third-person camera that follows behind the player. Save the scene.`,
    scene: dir => `${dir}/world.tscn`,
    check: tree => [
      [/\(CharacterBody3D\)[^\n]*script=/.test(tree), 'CharacterBody3D with a script'],
      [/\(Camera3D\)/.test(tree), 'Camera3D'],
      [/\((StaticBody3D|CSGBox3D|CSGCombiner3D|GridMap)\)/.test(tree), 'a floor'],
    ],
  },
  menu: {
    expect: ['ui'],
    setup: () => [],
    prompt: dir => `Create a main menu scene ${dir}/menu.tscn with the game's title and Start and Quit buttons. Quit closes the game. Save the scene.`,
    scene: dir => `${dir}/menu.tscn`,
    check: tree => [
      [(tree.match(/\((Button|TextureButton)\)/g) ?? []).length >= 2, 'two buttons'],
      [/\((Label|RichTextLabel)\)/.test(tree), 'a title'],
      [/script=/.test(tree), 'a script'],
    ],
  },
  pool2d: {
    expect: ['water', 'physics', 'gameplay', '2d'],
    setup: dir => [
      ['create_scene', { path: `${dir}/level.tscn`, root_node_type: 'Node2D' }],
      ['batch_create_nodes', { parent_path: '/root', nodes: [{ node_type: 'CharacterBody2D', node_name: 'Player', properties: { position: v2(200, 200) } }] }],
      ['batch_create_nodes', { parent_path: '/root/Player', nodes: [
        { node_type: 'CollisionShape2D', node_name: 'Shape', properties: { shape: { type: 'CapsuleShape2D', radius: 12, height: 40 } } }] }],
      ['save_scene', { path: `${dir}/level.tscn` }],
    ],
    prompt: dir => `Open ${dir}/level.tscn. Add a pool of water 400 pixels wide below the Player. While the Player is in the water, gravity is weaker and it moves slower. Save the scene.`,
    scene: dir => `${dir}/level.tscn`,
    check: tree => [
      [/water|pool/i.test(tree), 'water'],
      [/\(Area2D\)/.test(tree), 'an area that detects the Player'],
      [/script=/.test(tree), 'a script'],
    ],
  },
  arm_ik: {
    expect: ['rigging', 'animation', '3d'],
    setup: () => [],
    prompt: dir => `Create a new 3D scene ${dir}/arm.tscn with a simple arm: a Skeleton3D with three bones (shoulder, elbow, hand), and IK so the hand reaches toward a target node. Save the scene.`,
    scene: dir => `${dir}/arm.tscn`,
    check: tree => [
      [/\(Skeleton3D\)/.test(tree), 'Skeleton3D'],
      [/\([A-Za-z]*IK[A-Za-z0-9]*\)/.test(tree), 'an IK node'],
    ],
  },
  inspect: {
    expect: ['inspect', 'scripting', 'gameplay', 'refactor'],
    readOnly: true,
    setup: dir => [
      ['create_scene', { path: `${dir}/main.tscn`, root_node_type: 'Node2D' }],
      ['batch_create_nodes', { parent_path: '/root', nodes: [
        { node_type: 'Button', node_name: 'StartButton' }, { node_type: 'Timer', node_name: 'Spawner' }, { node_type: 'Node2D', node_name: 'Game' }] }],
      ['wire_signal_handler', { source_path: '/root/StartButton', signal_name: 'pressed', target_path: '/root/Game', method_name: '_on_start', script_path: `${dir}/game.gd`, create_script: true }],
      ['wire_signal_handler', { source_path: '/root/Spawner', signal_name: 'timeout', target_path: '/root/Game', method_name: '_on_spawn', script_path: `${dir}/game.gd` }],
      ['save_scene', { path: `${dir}/main.tscn` }],
    ],
    prompt: dir => `Tell me which nodes in ${dir}/main.tscn have scripts, and list every signal connection in it. Do not change anything.`,
    scene: dir => `${dir}/main.tscn`,
    check: (_tree, _props, _dir, answer) => [
      [/pressed/.test(answer) && /_on_start/.test(answer), 'reports StartButton.pressed'],
      [/timeout/.test(answer) && /_on_spawn/.test(answer), 'reports Spawner.timeout'],
      [/Game/.test(answer), 'names the scripted node'],
    ],
  },
};
