import { Resource, FastMCPSessionAuth } from 'fastmcp';
import { getGodotConnection } from '../utils/godot_connection.js';

export const xrInterfacesResource: Resource<FastMCPSessionAuth> = {
  uri: 'godot/xr/interfaces',
  name: 'Godot XR Interfaces',
  mimeType: 'application/json',
  async load() {
    const godot = getGodotConnection();
    const result = await godot.sendCommand('list_xr_interfaces', {});
    return {
      text: JSON.stringify(result),
    };
  },
};
