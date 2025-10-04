import { z } from 'zod';
import { MCPTool } from '../utils/types.js';
import { projectIndexer } from '../utils/project_indexer.js';

const ENTRY_LIMIT = 5000;

export const projectTools: MCPTool[] = [
  {
    name: 'refresh_project_index',
    description: 'Refresh the cached project structure index and return summary statistics.',
    parameters: z.object({}),
    execute: async (): Promise<string> => {
      const snapshot = await projectIndexer.refresh();
      return JSON.stringify({
        generated_at: snapshot.generatedAt,
        stats: snapshot.stats,
        root_entries: snapshot.root,
      }, null, 2);
    },
    metadata: {
      requiredRole: 'edit',
    },
  },
  {
    name: 'query_project_index',
    description: 'Query the cached project index using glob-style patterns.',
    parameters: z.object({
      pattern: z.union([
        z.string(),
        z.array(z.string()).min(1),
      ]).describe('Glob pattern or list of patterns (supports * and **).'),
      include_directories: z.boolean()
        .optional()
        .describe('Whether to include directories in the results (default true).'),
      limit: z.number()
        .int()
        .positive()
        .max(ENTRY_LIMIT)
        .optional()
        .describe('Maximum number of entries to return (default 200, max 5000).'),
    }),
    execute: async ({
      pattern,
      include_directories,
      limit,
    }: {
      pattern: string | string[];
      include_directories?: boolean;
      limit?: number;
    }): Promise<string> => {
      const patterns = Array.isArray(pattern) ? pattern : [pattern];
      const matches = await projectIndexer.query(patterns, {
        includeDirectories: include_directories ?? true,
        limit,
      });

      return JSON.stringify({
        patterns,
        count: matches.length,
        matches,
      }, null, 2);
    },
    metadata: {
      requiredRole: 'read',
    },
  },
];
