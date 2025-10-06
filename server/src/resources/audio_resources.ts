import { Resource } from 'fastmcp';
import { getGodotConnection } from '../utils/godot_connection.js';

export const audioBusResource: Resource = {
  uri: 'godot/audio/buses',
  name: 'Godot Audio Bus Layout',
  mimeType: 'application/json',
  async load() {
    const godot = getGodotConnection();

    try {
      const result = await godot.sendCommand('list_audio_buses', {});
      return {
        text: JSON.stringify(result, null, 2),
      };
    } catch (error) {
      console.error('Error fetching audio buses:', error);
      throw error;
    }
  },
};
