import { Resource } from 'fastmcp';
import { getGodotConnection } from '../utils/godot_connection.js';

export const uiThemeResource: Resource = {
  uri: 'godot/ui/theme',
  name: 'Godot UI Theme Summary',
  mimeType: 'application/json',
  async load() {
    const godot = getGodotConnection();

    try {
      const result = await godot.sendCommand('get_ui_theme_summary', {
        include_palettes: true,
        include_icons: true,
        include_fonts: true,
      });

      return {
        text: JSON.stringify(result, null, 2),
      };
    } catch (error) {
      console.error('Error fetching UI theme summary:', error);
      throw error;
    }
  },
};
