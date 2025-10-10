import { Resource } from 'fastmcp';
import { getGodotConnection } from '../utils/godot_connection.js';

export const animationStateMachinesResource: Resource = {
  uri: 'godot/animation/state-machines',
  name: 'Godot Animation State Machines',
  mimeType: 'application/json',
  async load() {
    const godot = getGodotConnection();

    try {
      const result = await godot.sendCommand('describe_animation_state_machines', {
        include_nested: true,
        include_graph: true,
        include_transitions: true,
      });
      return {
        text: JSON.stringify(result, null, 2),
      };
    } catch (error) {
      console.error('Error fetching animation state machines:', error);
      throw error;
    }
  },
};

export const animationTracksResource: Resource = {
  uri: 'godot/animation/tracks',
  name: 'Godot Animation Track Overview',
  mimeType: 'application/json',
  async load() {
    const godot = getGodotConnection();

    try {
      const result = await godot.sendCommand('describe_animation_tracks', {
        include_keys: true,
      });
      return {
        text: JSON.stringify(result, null, 2),
      };
    } catch (error) {
      console.error('Error fetching animation tracks:', error);
      throw error;
    }
  },
};
