import { beforeEach, describe, expect, it, vi } from 'vitest';

const snapshot = {
  generatedAt: '2024-01-01T00:00:00.000Z',
  projectRoot: '/workspace/Godot-MCP',
  root: [],
  entries: {},
  stats: { files: 0, directories: 0, totalSize: 0, skipped: [], truncated: false },
};

const mockState = vi.hoisted(() => ({
  mockSendCommand: vi.fn<(command: string, payload?: unknown) => Promise<any>>(async () => ({})),
  mockGetIndex: vi.fn(async () => snapshot),
}));

const { mockSendCommand, mockGetIndex } = mockState;

vi.mock('../dist/utils/godot_connection.js', () => ({
  getGodotConnection: () => ({
    sendCommand: mockSendCommand,
    connect: vi.fn(),
    disconnect: vi.fn(),
  }),
}));

vi.mock('../dist/utils/project_indexer.js', () => ({
  projectIndexer: {
    refresh: vi.fn(async () => snapshot),
    query: vi.fn(async () => []),
    getIndex: mockGetIndex,
  },
}));

const { sceneListResource, sceneStructureResource } = await import('../dist/resources/scene_resources.js');
const { scriptResource, scriptListResource, scriptMetadataResource } = await import('../dist/resources/script_resources.js');
const {
  projectStructureResource,
  projectSettingsResource,
  projectResourcesResource,
  projectIndexResource,
} = await import('../dist/resources/project_resources.js');
const { audioBusResource } = await import('../dist/resources/audio_resources.js');
const { physicsWorldResource } = await import('../dist/resources/physics_resources.js');
const { animationStateMachinesResource, animationTracksResource } = await import('../dist/resources/animation_resources.js');
const { editorStateResource, selectedNodeResource, currentScriptResource } = await import('../dist/resources/editor_resources.js');
const { uiThemeResource } = await import('../dist/resources/ui_resources.js');

describe('Godot MCP resources', () => {
  beforeEach(() => {
    mockSendCommand.mockClear();
    mockSendCommand.mockImplementation(async () => ({}));
    mockGetIndex.mockClear();
    mockGetIndex.mockResolvedValue(snapshot);
  });

  it('loads the scene list from Godot', async () => {
    mockSendCommand.mockResolvedValueOnce({ files: ['res://Main.tscn'] });
    const result = await sceneListResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('list_project_files', { extensions: ['.tscn', '.scn'] });
    expect(result.text).toContain('res://Main.tscn');
  });

  it('loads the current scene structure', async () => {
    mockSendCommand.mockResolvedValueOnce({ nodes: [] });
    const result = await sceneStructureResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('get_current_scene_structure', {});
    expect(result.text).toContain('nodes');
  });

  it('loads a script resource with metadata', async () => {
    mockSendCommand.mockResolvedValueOnce({ content: 'print("hi")', script_path: 'res://default_script.gd' });
    const result = await scriptResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('get_script', { path: 'res://default_script.gd' });
    expect(result.text).toContain('print');
    expect(result.metadata?.path).toBe('res://default_script.gd');
  });

  it('loads the script list from Godot', async () => {
    mockSendCommand.mockResolvedValueOnce({ files: ['res://player.gd'] });
    const result = await scriptListResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('list_project_files', { extensions: ['.gd', '.cs'] });
    expect(result.text).toContain('player.gd');
  });

  it('loads script metadata', async () => {
    mockSendCommand.mockResolvedValueOnce({ classes: [] });
    const result = await scriptMetadataResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('get_script_metadata', { path: 'res://default_script.gd' });
    expect(result.text).toContain('classes');
  });

  it('loads project structure data', async () => {
    mockSendCommand.mockResolvedValueOnce({ directories: [] });
    const result = await projectStructureResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('get_project_structure');
    expect(result.text).toContain('directories');
  });

  it('loads project settings data', async () => {
    mockSendCommand.mockResolvedValueOnce({ project_name: 'Demo' });
    const result = await projectSettingsResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('get_project_settings');
    expect(result.text).toContain('Demo');
  });

  it('loads project resource listings', async () => {
    mockSendCommand.mockResolvedValueOnce({ resources: [] });
    const result = await projectResourcesResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('list_project_resources');
    expect(result.text).toContain('resources');
  });

  it('loads the cached project index snapshot', async () => {
    const result = await projectIndexResource.load();

    expect(mockGetIndex).toHaveBeenCalledTimes(1);
    expect(result.text).toContain('generatedAt');
  });

  it('loads audio bus data', async () => {
    mockSendCommand.mockResolvedValueOnce({ buses: [] });
    const result = await audioBusResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('list_audio_buses', {});
    expect(result.text).toContain('buses');
  });

  it('loads physics world snapshots', async () => {
    mockSendCommand.mockResolvedValueOnce({ spaces: [] });
    const result = await physicsWorldResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('get_physics_world_snapshot', {});
    expect(result.text).toContain('spaces');
  });

  it('loads animation state machines', async () => {
    mockSendCommand.mockResolvedValueOnce({ state_machines: [] });
    const result = await animationStateMachinesResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('describe_animation_state_machines', {
      include_nested: true,
      include_graph: true,
      include_transitions: true,
    });
    expect(result.text).toContain('state_machines');
  });

  it('loads animation track data', async () => {
    mockSendCommand.mockResolvedValueOnce({ tracks: [] });
    const result = await animationTracksResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('describe_animation_tracks', { include_keys: true });
    expect(result.text).toContain('tracks');
  });

  it('loads editor state data', async () => {
    mockSendCommand.mockResolvedValueOnce({ editors: [] });
    const result = await editorStateResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('get_editor_state');
    expect(result.text).toContain('editors');
  });

  it('loads selected node data', async () => {
    mockSendCommand.mockResolvedValueOnce({ path: '/root/Node' });
    const result = await selectedNodeResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('get_selected_node');
    expect(result.text).toContain('/root/Node');
  });

  it('loads the current script being edited', async () => {
    mockSendCommand.mockResolvedValueOnce({ script_found: true, content: 'print()', script_path: 'res://script.gd' });

    const result = await currentScriptResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('get_current_script');
    expect(result.text).toContain('print');
    expect(result.metadata?.path).toBe('res://script.gd');
  });

  it('loads UI theme summaries', async () => {
    mockSendCommand.mockResolvedValueOnce({ types: [] });
    const result = await uiThemeResource.load();

    expect(mockSendCommand).toHaveBeenCalledWith('get_ui_theme_summary', {
      include_palettes: true,
      include_icons: true,
      include_fonts: true,
    });
    expect(result.text).toContain('types');
  });

});
