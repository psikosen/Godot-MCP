import { Resource, ResourceTemplate } from 'fastmcp';
import { getGodotConnection } from '../utils/godot_connection.js';

type GodotConnection = ReturnType<typeof getGodotConnection>;

const SCRIPT_EXTENSIONS = ['.gd', '.cs'] as const;
const SCRIPT_COMPLETION_LIMIT = 25;

const isNonEmptyString = (value: unknown): value is string =>
  typeof value === 'string' && value.trim().length > 0;

const inferScriptLanguage = (scriptPath: string): string => {
  if (scriptPath.endsWith('.gd')) return 'gdscript';
  if (scriptPath.endsWith('.cs')) return 'csharp';
  return 'unknown';
};

const decodeScriptPath = (rawPath: string): string => {
  try {
    return decodeURIComponent(rawPath);
  } catch {
    return rawPath;
  }
};

const normalizeScriptPath = (rawPath: string): string => {
  const decoded = decodeScriptPath(rawPath ?? '');
  const normalized = decoded.trim();

  if (!normalized) {
    throw new Error('A script resource path is required.');
  }

  if (!normalized.includes('://')) {
    throw new Error(
      'Script path must be a valid Godot resource path (e.g., res://player.gd).',
    );
  }

  return normalized;
};

const fetchScriptPaths = async (
  godot: GodotConnection = getGodotConnection(),
): Promise<string[]> => {
  const response = await godot.sendCommand('list_project_files', {
    extensions: SCRIPT_EXTENSIONS,
  });

  if (!response || !Array.isArray(response.files)) {
    return [];
  }

  const rawFiles = (response.files ?? []) as unknown[];
  const filtered = rawFiles.filter(isNonEmptyString);
  const trimmed = filtered.map(path => path.trim());
  const deduped = Array.from(new Set<string>(trimmed));

  deduped.sort((a, b) => a.localeCompare(b));
  return deduped;
};

const completeScriptPath = async (partial: string): Promise<{
  values: string[];
  total: number;
  hasMore: boolean;
}> => {
  const scripts = await fetchScriptPaths();
  const query = partial.trim().toLowerCase();

  const matches = query
    ? scripts.filter(script => script.toLowerCase().includes(query))
    : scripts;

  const values = matches.slice(0, SCRIPT_COMPLETION_LIMIT);

  return {
    values,
    total: matches.length,
    hasMore: matches.length > values.length,
  };
};

const buildScriptPathArgument = () => ({
  name: 'path',
  description: 'Full resource path to the script (e.g., res://player.gd).',
  complete: (value: string) => completeScriptPath(value ?? ''),
});

/**
 * Resource template that provides the content of a specific script
 */
export const scriptResourceTemplate: ResourceTemplate = {
  uriTemplate: 'godot/script/{path}',
  name: 'Godot Script Content',
  description: 'Fetch raw script source for a given Godot resource path.',
  mimeType: 'text/plain',
  arguments: [buildScriptPathArgument()],
  async load({ path }) {
    const scriptPath = normalizeScriptPath(path);
    const godot = getGodotConnection();

    try {
      const result = await godot.sendCommand('get_script', {
        path: scriptPath,
      });

      const resolvedPath = isNonEmptyString(result?.script_path)
        ? result.script_path.trim()
        : scriptPath;
      const content = isNonEmptyString(result?.content) ? result.content : '';

      return {
        text: content,
        metadata: {
          path: resolvedPath,
          language: inferScriptLanguage(resolvedPath),
        },
      } as any;
    } catch (error) {
      console.error('Error fetching script content:', error);
      throw error;
    }
  },
};

/**
 * Resource that provides a list of all scripts in the project
 */
export const scriptListResource: Resource = {
  uri: 'godot/scripts',
  name: 'Godot Script List',
  mimeType: 'application/json',
  async load() {
    try {
      const scripts = await fetchScriptPaths();
      return {
        text: JSON.stringify({
          scripts,
          count: scripts.length,
          gdscripts: scripts.filter(script => script.endsWith('.gd')),
          csharp_scripts: scripts.filter(script => script.endsWith('.cs')),
        }),
      };
    } catch (error) {
      console.error('Error fetching script list:', error);
      throw error;
    }
  }
};

/**
 * Resource template that provides metadata for a specific script, including classes and methods
 */
export const scriptMetadataResourceTemplate: ResourceTemplate = {
  uriTemplate: 'godot/script/{path}/metadata',
  name: 'Godot Script Metadata',
  description: 'Retrieve declared classes, methods, and signals for a script path.',
  mimeType: 'application/json',
  arguments: [buildScriptPathArgument()],
  async load({ path }) {
    const scriptPath = normalizeScriptPath(path);
    const godot = getGodotConnection();

    try {
      const result = await godot.sendCommand('get_script_metadata', {
        path: scriptPath,
      });

      return {
        text: JSON.stringify(result, null, 2),
      };
    } catch (error) {
      console.error('Error fetching script metadata:', error);
      throw error;
    }
  },
};
