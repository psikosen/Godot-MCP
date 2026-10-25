import { Resource, ResourceTemplate, FastMCPSessionAuth } from 'fastmcp';
import { getGodotConnection } from '../utils/godot_connection.js';
import { z } from 'zod';

/**
 * Resource that provides a list of all scenes in the project
 */
export const sceneListResource: Resource<FastMCPSessionAuth> = {
  uri: 'godot/scenes',
  name: 'Godot Scene List',
  mimeType: 'application/json',
  async load() {
    const godot = getGodotConnection();
    
    try {
      // Call a command on the Godot side to list all scenes
      const result = await godot.sendCommand('list_project_files', {
        extensions: ['.tscn', '.scn']
      });
      
      if (result && result.files) {
        return {
          text: JSON.stringify({
            scenes: result.files,
            count: result.files.length
          })
        };
      } else {
        return {
          text: JSON.stringify({
            scenes: [],
            count: 0
          })
        };
      }
    } catch (error) {
      console.error('Error fetching scene list:', error);
      throw error;
    }
  }
};

/**
 * Resource that provides detailed information about a specific scene
 */
export const sceneStructureResource: Resource<FastMCPSessionAuth> = {
    uri: 'godot/scene/current',
    name: 'Godot Scene Structure',
    mimeType: 'application/json',
    async load() {
        const godot = getGodotConnection();
        
        try {
            // Call a command on the Godot side to get current scene structure
            const result = await godot.sendCommand('snapshot_scene_state', {});
            
            return {
                text: JSON.stringify(result)
            };
        } catch (error) {
            console.error('Error fetching scene structure:', error);
            throw error;
        }
    }
};
