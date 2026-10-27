import { describe, expect, it } from 'vitest';
import { PermissionManager } from '../src/utils/permission_manager.js';

describe('PermissionManager path rules', () => {
  it('denies protected folders whatever the letter case', async () => {
    const manager = new PermissionManager();
    await expect(manager.assertWriteAllowed('server/DIST/index.js', 'write')).rejects.toThrow(/denied/);
    await expect(manager.assertWriteAllowed('.GIT/config.gd', 'write')).rejects.toThrow(/denied/);
    await expect(manager.assertWriteAllowed('addons/thing.GD', 'write')).resolves.toBeUndefined();
  });
});
