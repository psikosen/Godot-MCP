import { z } from 'zod';
import { MCPTool } from '../utils/types.js';
import { patchManager } from '../utils/patch_manager.js';

export const patchTools: MCPTool[] = [
  {
    name: 'preview_patch',
    description: 'Preview a unified diff patch without applying it',
    parameters: z.object({
      diff: z.string().describe('Unified diff to preview'),
    }),
    execute: async ({ diff }: { diff: string }): Promise<string> => {
      const preview = await patchManager.preview(diff);
      return JSON.stringify({
        patch_id: preview.patchId,
        diff,
        files: preview.files,
      }, null, 2);
    },
  },
  {
    name: 'apply_patch',
    description: 'Apply a previously previewed patch atomically',
    parameters: z.object({
      patch_id: z.string().describe('Identifier returned from preview_patch'),
    }),
    execute: async ({ patch_id }: { patch_id: string }): Promise<string> => {
      const result = await patchManager.apply(patch_id);
      return JSON.stringify({
        patch_id: result.patchId,
        applied_files: result.appliedFiles,
      }, null, 2);
    },
  },
  {
    name: 'cancel_patch',
    description: 'Cancel a previously previewed patch without applying it',
    parameters: z.object({
      patch_id: z.string().describe('Identifier returned from preview_patch'),
    }),
    execute: async ({ patch_id }: { patch_id: string }): Promise<string> => {
      patchManager.cancel(patch_id);
      return JSON.stringify({
        patch_id,
        cancelled: true,
      }, null, 2);
    },
  },
];
