import { Resource, FastMCPSessionAuth } from 'fastmcp';
import { getGodotConnection } from '../utils/godot_connection.js';

export const physicsWorldResource: Resource<FastMCPSessionAuth> = {
  uri: 'godot/physics/world',
  name: 'Godot Physics World Snapshot',
  mimeType: 'application/json',
  async load() {
    const godot = getGodotConnection();

    try {
      const result = await godot.sendCommand('get_physics_world_snapshot', {});
      return {
        text: JSON.stringify(result),
      };
    } catch (error) {
      console.error('Error fetching physics world snapshot:', error);
      throw error;
    }
  },
};
