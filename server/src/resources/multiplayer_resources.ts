import { Resource } from 'fastmcp';
import { getGodotConnection } from '../utils/godot_connection.js';

export const multiplayerStateResource: Resource = {
  uri: 'godot/multiplayer/state',
  name: 'Godot Multiplayer State Snapshot',
  mimeType: 'application/json',
  async load() {
    const godot = getGodotConnection();
    const result = await godot.sendCommand('get_multiplayer_state', {});
    return {
      text: JSON.stringify(result, null, 2),
    };
  },
};
