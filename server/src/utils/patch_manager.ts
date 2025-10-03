import { promises as fs } from 'node:fs';
import { randomUUID } from 'node:crypto';
import * as path from 'node:path';
import { parsePatch, applyPatch, ParsedDiff } from 'diff';
import { permissionManager } from './permission_manager.js';

interface PatchFilePlan {
  absolutePath: string;
  relativePath: string;
  mode: 'modify' | 'create' | 'delete';
  originalContent: string;
  patchedContent: string;
  patch: ParsedDiff;
  existedBefore: boolean;
}

interface PatchSession {
  id: string;
  diff: string;
  files: PatchFilePlan[];
  createdAt: Date;
}

export interface PatchPreviewResult {
  patchId: string;
  files: Array<{
    path: string;
    mode: 'modify' | 'create' | 'delete';
    originalSize: number;
    patchedSize: number;
  }>;
}

export interface PatchApplyResult {
  patchId: string;
  appliedFiles: Array<{
    path: string;
    mode: 'modify' | 'create' | 'delete';
  }>;
}

/**
 * Manages preview, application, and cancellation of unified diff patches with
 * atomic file writes and rollback semantics.
 */
export class PatchManager {
  private readonly projectRoot: string;
  private readonly sessions = new Map<string, PatchSession>();
  private readonly lockedPaths = new Set<string>();

  constructor(projectRoot?: string) {
    this.projectRoot = projectRoot ?? path.resolve(process.cwd(), '..');
  }

  /**
   * Registers a diff for preview, returning a patch identifier if the diff
   * applies cleanly against the current working tree.
   */
  async preview(diffText: string): Promise<PatchPreviewResult> {
    if (!diffText.trim()) {
      throw new Error('Cannot preview an empty diff.');
    }

    const parsed = parsePatch(diffText);
    if (parsed.length === 0) {
      throw new Error('Diff did not contain any file changes.');
    }

    const files: PatchFilePlan[] = [];

    for (const patch of parsed) {
      const resolved = await this.prepareFilePlan(patch);
      files.push(resolved);
    }

    const patchId = randomUUID();
    this.sessions.set(patchId, {
      id: patchId,
      diff: diffText,
      files,
      createdAt: new Date(),
    });

    this.logEvent('Generated patch preview', {
      systemSection: 'preview',
      details: {
        patchId,
        fileCount: files.length,
      },
    });

    return {
      patchId,
      files: files.map(file => ({
        path: file.relativePath,
        mode: file.mode,
        originalSize: Buffer.byteLength(file.originalContent, 'utf8'),
        patchedSize: Buffer.byteLength(file.patchedContent, 'utf8'),
      })),
    };
  }

  /**
   * Applies a previously previewed patch atomically. If any file fails to
   * update, all changes are rolled back.
   */
  async apply(patchId: string): Promise<PatchApplyResult> {
    const session = this.sessions.get(patchId);
    if (!session) {
      throw new Error(`No preview found for patch ID ${patchId}.`);
    }

    const paths = session.files.map(file => file.absolutePath);
    this.acquireLocks(paths);

    const applied: Array<() => Promise<void>> = [];

    try {
      for (const file of session.files) {
        if (file.mode === 'delete') {
          await this.ensurePathWithinProject(file.absolutePath);

          if (file.existedBefore) {
            await fs.unlink(file.absolutePath);
            applied.push(async () => {
              await this.writeAtomic(file.absolutePath, file.originalContent);
            });
          }
        } else {
          await this.ensureDirectory(path.dirname(file.absolutePath));
          await this.writeAtomic(file.absolutePath, file.patchedContent);

          if (file.existedBefore) {
            applied.push(async () => {
              await this.writeAtomic(file.absolutePath, file.originalContent);
            });
          } else {
            applied.push(async () => {
              await this.safeCleanup(file.absolutePath);
            });
          }
        }
      }

      this.sessions.delete(patchId);
      this.logEvent('Applied patch', {
        systemSection: 'apply',
        details: {
          patchId,
          files: session.files.map(file => ({
            path: file.relativePath,
            mode: file.mode,
          })),
        },
      });
      return {
        patchId,
        appliedFiles: session.files.map(file => ({
          path: file.relativePath,
          mode: file.mode,
        })),
      };
    } catch (error) {
      await this.rollback(applied);
      this.logEvent(`Failed to apply patch: ${(error as Error).message}`, {
        systemSection: 'apply',
        error: true,
        details: { patchId },
      });
      throw error;
    } finally {
      this.releaseLocks(paths);
    }
  }

  /**
   * Cancels a previewed patch without applying it.
   */
  cancel(patchId: string): void {
    if (!this.sessions.has(patchId)) {
      throw new Error(`No preview found for patch ID ${patchId}.`);
    }
    this.sessions.delete(patchId);
    this.logEvent('Cancelled patch preview', {
      systemSection: 'cancel',
      details: { patchId },
    });
  }

  private async prepareFilePlan(patch: ParsedDiff): Promise<PatchFilePlan> {
    const targetPath = this.resolvePatchPath(patch.newFileName ?? patch.oldFileName);
    const relativePath = path.relative(this.projectRoot, targetPath);

    if (!relativePath || relativePath.startsWith('..') || path.isAbsolute(relativePath)) {
      throw new Error(`Patch targets path outside project root: ${patch.newFileName ?? patch.oldFileName}`);
    }

    const exists = await this.fileExists(targetPath);
    const originalContent = await this.readOriginalContent(patch, targetPath, exists);

    if (patch.hunks.length === 0) {
      throw new Error(`Patch for ${relativePath} did not contain any hunks.`);
    }

    const patched = applyPatch(originalContent, patch);
    if (patched === false) {
      throw new Error(`Failed to apply diff for ${relativePath}.`);
    }

    const mode: PatchFilePlan['mode'] = this.determineMode(patch, exists);

    await permissionManager.assertWriteAllowed(relativePath, mode);

    return {
      absolutePath: targetPath,
      relativePath,
      mode,
      originalContent,
      patchedContent: patched,
      patch,
      existedBefore: exists,
    };
  }

  private determineMode(patch: ParsedDiff, exists: boolean): PatchFilePlan['mode'] {
    if (patch.oldFileName === '/dev/null') {
      return 'create';
    }
    if (patch.newFileName === '/dev/null') {
      return 'delete';
    }
    return exists ? 'modify' : 'create';
  }

  private async ensureDirectory(dirPath: string): Promise<void> {
    await fs.mkdir(dirPath, { recursive: true });
  }

  private async writeAtomic(targetPath: string, content: string): Promise<void> {
    const dir = path.dirname(targetPath);
    const base = path.basename(targetPath);
    const tempPath = path.join(dir, `${base}.tmp-${randomUUID()}`);

    try {
      await fs.mkdir(dir, { recursive: true });
      await fs.writeFile(tempPath, content, 'utf8');
      await fs.rename(tempPath, targetPath);
    } catch (error) {
      await this.safeCleanup(tempPath);
      throw error;
    }
  }

  private async safeCleanup(filePath: string): Promise<void> {
    try {
      await fs.unlink(filePath);
    } catch (error) {
      const err = error as NodeJS.ErrnoException;
      if (err.code !== 'ENOENT') {
        throw error;
      }
    }
  }

  private async readOriginalContent(patch: ParsedDiff, targetPath: string, exists: boolean): Promise<string> {
    if (patch.oldFileName === '/dev/null') {
      return '';
    }

    if (!exists) {
      throw new Error(`Target file for patch does not exist: ${patch.oldFileName}`);
    }

    return fs.readFile(targetPath, 'utf8');
  }

  private resolvePatchPath(fileName?: string): string {
    if (!fileName) {
      throw new Error('Patch file entry missing file name.');
    }

    const cleaned = fileName.replace(/^a\//, '').replace(/^b\//, '');
    const normalized = path.normalize(cleaned);
    const resolved = path.resolve(this.projectRoot, normalized);
    return resolved;
  }

  private async fileExists(targetPath: string): Promise<boolean> {
    try {
      await fs.access(targetPath);
      return true;
    } catch (error) {
      const err = error as NodeJS.ErrnoException;
      if (err.code === 'ENOENT') {
        return false;
      }
      throw error;
    }
  }

  private async rollback(operations: Array<() => Promise<void>>): Promise<void> {
    for (const revert of operations.reverse()) {
      try {
        await revert();
      } catch (error) {
        this.logEvent(`Rollback step failed: ${(error as Error).message}`, {
          systemSection: 'rollback',
          error: true,
        });
      }
    }
  }

  private acquireLocks(paths: string[]): void {
    const sorted = [...paths].sort();
    for (const filePath of sorted) {
      if (this.lockedPaths.has(filePath)) {
        throw new Error(`Resource is currently locked: ${path.relative(this.projectRoot, filePath)}`);
      }
    }
    sorted.forEach(filePath => this.lockedPaths.add(filePath));
  }

  private releaseLocks(paths: string[]): void {
    paths.forEach(filePath => this.lockedPaths.delete(filePath));
  }

  private async ensurePathWithinProject(targetPath: string): Promise<void> {
    const relative = path.relative(this.projectRoot, targetPath);
    if (!relative || relative.startsWith('..') || path.isAbsolute(relative)) {
      throw new Error(`Resolved path is outside of project root: ${targetPath}`);
    }
  }

  private logEvent(message: string, {
    systemSection,
    error = false,
    details,
  }: {
    systemSection: string;
    error?: boolean;
    details?: Record<string, unknown>;
  }): void {
    const logEntry = {
      filename: 'server/src/utils/patch_manager.ts',
      timestamp: new Date().toISOString(),
      classname: 'PatchManager',
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

export const patchManager = new PatchManager();
