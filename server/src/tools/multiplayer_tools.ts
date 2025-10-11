import { z } from 'zod';
import { MCPTool, CommandResult } from '../utils/types.js';
import { getGodotConnection } from '../utils/godot_connection.js';

const peerTypeSchema = z.enum(['enet', 'websocket', 'webrtc']);
const peerModeSchema = z.enum(['server', 'client']);

export const multiplayerTools: MCPTool[] = [
  {
    name: 'get_multiplayer_state',
    description: 'Return a snapshot of the active SceneTree multiplayer configuration.',
    parameters: z.object({}),
    async execute(): Promise<string> {
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('get_multiplayer_state', {});
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'read',
    },
  },
  {
    name: 'create_multiplayer_peer',
    description: 'Create and attach a multiplayer peer (ENet/WebSocket/WebRTC) to the active SceneTree.',
    parameters: z.object({
      peer_type: peerTypeSchema.describe('Transport to configure for the SceneTree multiplayer peer.'),
      mode: peerModeSchema
        .default('server')
        .describe('Create the peer in server or client mode, depending on the desired topology.'),
      port: z
        .number()
        .int()
        .optional()
        .describe('Listening port for ENet/WebSocket servers or destination port for ENet clients.'),
      max_clients: z
        .number()
        .int()
        .optional()
        .describe('Maximum concurrent clients when creating an ENet server.'),
      address: z
        .string()
        .optional()
        .describe('Remote address for ENet clients (ignored for other peer types).'),
      url: z
        .string()
        .url()
        .optional()
        .describe('WebSocket URL when configuring a WebSocket client.'),
      protocols: z
        .array(z.string())
        .optional()
        .describe('Optional WebSocket subprotocols to register for server transports.'),
    }),
    async execute({ peer_type, mode, port, max_clients, address, url, protocols }): Promise<string> {
      const godot = getGodotConnection();
      const payload: Record<string, unknown> = {
        peer_type,
        mode,
      };

      if (port !== undefined) {
        payload.port = port;
      }

      if (max_clients !== undefined) {
        payload.max_clients = max_clients;
      }

      if (address !== undefined) {
        payload.address = address;
      }

      if (url !== undefined) {
        payload.url = url;
      }

      if (protocols !== undefined) {
        payload.protocols = protocols;
      }

      const result = await godot.sendCommand<CommandResult>('create_multiplayer_peer', payload);
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'teardown_multiplayer_peer',
    description: 'Disconnect and clear the SceneTree multiplayer peer, returning to single-player mode.',
    parameters: z.object({}),
    async execute(): Promise<string> {
      const godot = getGodotConnection();
      const result = await godot.sendCommand<CommandResult>('teardown_multiplayer_peer', {});
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'spawn_multiplayer_scene',
    description: 'Instantiate a PackedScene for multiplayer playtests and optionally assign authority.',
    parameters: z.object({
      scene_path: z
        .string()
        .min(1)
        .describe('PackedScene path to instantiate (e.g. res://scenes/level.tscn).'),
      parent_path: z
        .string()
        .optional()
        .describe('Parent node path where the new instance should be added. Defaults to /root.'),
      owner_peer_id: z
        .number()
        .int()
        .optional()
        .describe('Peer ID to assign as the multiplayer authority on the spawned instance.'),
    }),
    async execute({ scene_path, parent_path, owner_peer_id }): Promise<string> {
      const godot = getGodotConnection();
      const payload: Record<string, unknown> = { scene_path };

      if (parent_path !== undefined) {
        payload.parent_path = parent_path;
      }

      if (owner_peer_id !== undefined) {
        payload.owner_peer_id = owner_peer_id;
      }

      const result = await godot.sendCommand<CommandResult>('spawn_multiplayer_scene', payload);
      return JSON.stringify(result, null, 2);
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
];
