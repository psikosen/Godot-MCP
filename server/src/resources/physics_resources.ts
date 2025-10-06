import { Resource } from 'fastmcp';
import { getGodotConnection } from '../utils/godot_connection.js';

export const physicsWorldResource: Resource = {
  uri: 'godot/physics/world',
  name: 'Godot Physics World Snapshot',
  mimeType: 'application/json',
  async load() {
    const godot = getGodotConnection();

    try {
      const result = await godot.sendCommand('get_physics_world_snapshot', {});
      return {
        text: JSON.stringify(result, null, 2),
      };
    } catch (error) {
      console.error('Error fetching physics world snapshot:', error);
      throw error;
    }
  },
};
