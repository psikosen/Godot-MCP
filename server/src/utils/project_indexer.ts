import { promises as fs } from 'node:fs';
import path from 'node:path';
import { Dirent } from 'node:fs';

export type ProjectIndexEntryType = 'file' | 'directory';

export interface ProjectIndexEntry {
  path: string;
  type: ProjectIndexEntryType;
  size: number;
  modified: string;
  extension?: string;
  children?: string[];
}

export interface ProjectIndexSnapshot {
  generatedAt: string;
  projectRoot: string;
  root: string[];
  entries: Record<string, ProjectIndexEntry>;
  stats: {
    files: number;
    directories: number;
    totalSize: number;
    skipped: string[];
    truncated: boolean;
  };
}

interface SnapshotCache {
  snapshot: ProjectIndexSnapshot;
  entryMap: Map<string, ProjectIndexEntry>;
}

interface QueryOptions {
  includeDirectories?: boolean;
  limit?: number;
}

const DEFAULT_SKIP_PATHS = new Set([
  'server/dist',
]);

const DEFAULT_SKIP_SEGMENTS = new Set([
  '.git',
  '.godot',
  '.import',
  'node_modules',
]);

const ENTRY_LIMIT = 5000;

/**
 * Builds and caches a structural index of the Godot project to support
 * high-level queries from MCP tools. The index intentionally mirrors the
 * capability guardrails by skipping transient or high-churn directories.
 */
export class ProjectIndexer {
  private readonly projectRoot: string;
  private cache: SnapshotCache | null = null;
  private building = false;

  constructor(projectRoot?: string) {
    this.projectRoot = projectRoot ?? path.resolve(process.cwd(), '..');
  }

  /**
   * Returns the cached snapshot or rebuilds it when missing or forced.
   */
  async getIndex(forceRefresh = false): Promise<ProjectIndexSnapshot> {
    if (!forceRefresh && this.cache) {
      return this.cache.snapshot;
    }

    if (this.building) {
      // Prevent concurrent rebuilds by awaiting the current run.
      while (this.building) {
        await new Promise(resolve => setTimeout(resolve, 25));
      }
      if (this.cache) {
        return this.cache.snapshot;
      }
    }

    this.building = true;

    try {
      const built = await this.buildSnapshot();
      this.cache = built;
      this.log('Rebuilt project index snapshot', {
        systemSection: 'build',
        details: {
          files: built.snapshot.stats.files,
          directories: built.snapshot.stats.directories,
          truncated: built.snapshot.stats.truncated,
        },
      });
      return built.snapshot;
    } finally {
      this.building = false;
    }
  }

  /**
   * Forces a rebuild and returns the latest snapshot.
   */
  async refresh(): Promise<ProjectIndexSnapshot> {
    return this.getIndex(true);
  }

  /**
   * Queries the cached snapshot using glob-like path patterns.
   */
  async query(patterns: string[], options: QueryOptions = {}): Promise<ProjectIndexEntry[]> {
    const snapshot = await this.getIndex();
    const includeDirectories = options.includeDirectories ?? true;
    const limit = Math.min(options.limit ?? 200, ENTRY_LIMIT);

    const normalizedPatterns = patterns.map(pattern => this.normalizePath(pattern));
    const regexes = normalizedPatterns.map(pattern => this.globToRegExp(pattern));

    const results: ProjectIndexEntry[] = [];

    for (const [entryPath, entry] of Object.entries(snapshot.entries)) {
      if (entryPath === '.') continue;
      if (!includeDirectories && entry.type === 'directory') continue;

      if (regexes.some(regex => regex.test(entryPath))) {
        results.push(entry);
        if (results.length >= limit) {
          break;
        }
      }
    }

    return results.sort((a, b) => a.path.localeCompare(b.path));
  }

  private async buildSnapshot(): Promise<SnapshotCache> {
    const stats = {
      files: 0,
      directories: 0,
      totalSize: 0,
      skipped: [] as string[],
      truncated: false,
    };

    const entryMap = new Map<string, ProjectIndexEntry>();

    const rootEntry = await this.scanDirectory(this.projectRoot, '.', entryMap, stats);

    const snapshot: ProjectIndexSnapshot = {
      generatedAt: new Date().toISOString(),
      projectRoot: this.projectRoot,
      root: rootEntry.children ?? [],
      entries: Object.fromEntries(entryMap.entries()),
      stats,
    };

    return { snapshot, entryMap };
  }

  private async scanDirectory(
    absolutePath: string,
    relativePath: string,
    entryMap: Map<string, ProjectIndexEntry>,
    stats: ProjectIndexSnapshot['stats'],
    visited: Set<string> = new Set(),
  ): Promise<ProjectIndexEntry> {
    const normalizedRelative = this.normalizePath(relativePath);
    const realPath = await fs.realpath(absolutePath).catch(() => absolutePath);

    if (visited.has(realPath)) {
      stats.skipped.push(normalizedRelative);
      return entryMap.get(normalizedRelative) ?? {
        path: normalizedRelative,
        type: 'directory',
        size: 0,
        modified: new Date(0).toISOString(),
        children: [],
      };
    }

    visited.add(realPath);

    const directoryChildren: string[] = [];
    let aggregateSize = 0;

    let dirStat: { mtime: Date };
    try {
      const stat = await fs.stat(absolutePath);
      dirStat = { mtime: stat.mtime };
    } catch (error) {
      const err = error as Error;
      this.log(`Failed to stat directory: ${err.message}`, {
        systemSection: 'scan',
        error: true,
        details: { path: normalizedRelative },
      });
      dirStat = { mtime: new Date(0) };
    }

    stats.directories += normalizedRelative === '.' ? 0 : 1;

    let dirents: Dirent[] = [];
    try {
      dirents = await fs.readdir(absolutePath, { withFileTypes: true });
    } catch (error) {
      const err = error as Error;
      this.log(`Failed to read directory: ${err.message}`, {
        systemSection: 'scan',
        error: true,
        details: { path: normalizedRelative },
      });
    }

    for (const dirent of dirents) {
      if (entryMap.size >= ENTRY_LIMIT) {
        stats.truncated = true;
        break;
      }

      const childRelative = normalizedRelative === '.'
        ? dirent.name
        : `${normalizedRelative}/${dirent.name}`;
      const childAbsolute = path.join(absolutePath, dirent.name);

      if (this.shouldSkip(childRelative, dirent)) {
        stats.skipped.push(childRelative);
        continue;
      }

      if (dirent.isDirectory()) {
        const childEntry = await this.scanDirectory(childAbsolute, childRelative, entryMap, stats, visited);
        directoryChildren.push(childEntry.path);
        aggregateSize += childEntry.size;
      } else if (dirent.isFile()) {
        const fileEntry = await this.createFileEntry(childAbsolute, childRelative);
        entryMap.set(fileEntry.path, fileEntry);
        directoryChildren.push(fileEntry.path);
        aggregateSize += fileEntry.size;
        stats.files += 1;
        stats.totalSize += fileEntry.size;
      } else {
        stats.skipped.push(childRelative);
      }
    }

    directoryChildren.sort();

    const entry: ProjectIndexEntry = {
      path: normalizedRelative,
      type: 'directory',
      size: aggregateSize,
      modified: dirStat.mtime.toISOString(),
      children: directoryChildren,
    };

    entryMap.set(entry.path, entry);
    return entry;
  }

  private async createFileEntry(absolutePath: string, relativePath: string): Promise<ProjectIndexEntry> {
    const stat = await fs.stat(absolutePath);
    return {
      path: this.normalizePath(relativePath),
      type: 'file',
      size: stat.size,
      modified: stat.mtime.toISOString(),
      extension: path.extname(relativePath) || undefined,
    };
  }

  private shouldSkip(relativePath: string, dirent: Dirent): boolean {
    if (dirent.isSymbolicLink()) {
      return true;
    }

    const normalized = this.normalizePath(relativePath);
    if (DEFAULT_SKIP_PATHS.has(normalized)) {
      return true;
    }

    let pathMatch = false;
    DEFAULT_SKIP_PATHS.forEach(skipPath => {
      if (!pathMatch && normalized.startsWith(`${skipPath}/`)) {
        pathMatch = true;
      }
    });
    if (pathMatch) {
      return true;
    }

    const segments = normalized.split('/');
    if (segments.some(segment => DEFAULT_SKIP_SEGMENTS.has(segment))) {
      return true;
    }

    return false;
  }

  private normalizePath(input: string): string {
    if (!input || input === '.') {
      return '.';
    }
    const normalized = path.posix.normalize(input.replace(/\\/g, '/'));
    return normalized.startsWith('./') ? normalized.slice(2) : normalized;
  }

  private globToRegExp(pattern: string): RegExp {
    const escaped = pattern.replace(/[.+^${}()|[\]\\]/g, '\\$&');
    const translated = escaped
      .replace(/\\\*\\\*/g, '§§DOUBLESTAR§§')
      .replace(/\\\*/g, '[^/]*')
      .replace(/§§DOUBLESTAR§§/g, '.*')
      .replace(/\\\?/g, '[^/]');
    return new RegExp(`^${translated}$`);
  }

  private log(message: string, {
    systemSection,
    details,
    error = false,
  }: {
    systemSection: string;
    details?: Record<string, unknown>;
    error?: boolean;
  }): void {
    const logEntry = {
      filename: 'server/src/utils/project_indexer.ts',
      timestamp: new Date().toISOString(),
      classname: 'ProjectIndexer',
      function: systemSection,
      system_section: systemSection,
      line_num: 0,
      error,
      db_phase: 'none' as const,
      method: 'NONE' as const,
      message,
      ...(details ? { details } : {}),
    };

    console.error(JSON.stringify(logEntry));
    console.error(`[Continuous skepticism (Sherlock Protocol)] ${message}`);
  }
}

export const projectIndexer = new ProjectIndexer();
