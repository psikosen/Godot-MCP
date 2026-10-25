import { describe, expect, it } from 'vitest';
import { ProjectIndexer } from '../src/utils/project_indexer.js';

describe('ProjectIndexer glob matching', () => {
  const toRegExp = (pattern: string): RegExp =>
    (new ProjectIndexer('/tmp') as unknown as { globToRegExp(p: string): RegExp }).globToRegExp(pattern);

  it('handles *, ** and ? wildcards', () => {
    expect(toRegExp('*.gd').test('player.gd')).toBe(true);
    expect(toRegExp('*.gd').test('scripts/player.gd')).toBe(false);
    expect(toRegExp('**/*.gd').test('scripts/ai/enemy.gd')).toBe(true);
    expect(toRegExp('**/*.gd').test('player.gd')).toBe(true);
    expect(toRegExp('addons/**').test('addons/godot_mcp/plugin.cfg')).toBe(true);
    expect(toRegExp('level?.tscn').test('level1.tscn')).toBe(true);
    expect(toRegExp('a+b.gd').test('a+b.gd')).toBe(true);
  });
});
