import { Resource, FastMCPSessionAuth } from 'fastmcp';
import { getGodotConnection } from '../utils/godot_connection.js';

export const compressionSettingsResource: Resource<FastMCPSessionAuth> = {
  uri: 'godot/assets/compression-presets',
  name: 'Godot Texture Compression Presets',
  mimeType: 'application/json',
  async load() {
    const godot = getGodotConnection();
    const result = await godot.sendCommand('list_texture_compression_settings', {});
    return {
      text: JSON.stringify(result),
    };
  },
};
