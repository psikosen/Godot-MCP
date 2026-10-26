import { z } from 'zod';
import type { ContentResult } from 'fastmcp';

/**
 * Interface for FastMCP tool definition
 */
export type CommandRole = 'read' | 'edit' | 'admin';

export interface ToolMetadata {
  /**
   * Minimum role required to execute the command without escalation. Defaults
   * to `read` which covers informational commands.
   */
  requiredRole?: CommandRole;
  /**
   * Suggested natural language prompt that a human reviewer can use when
   * approving an escalation for the command.
   */
  escalationPrompt?: string;
}

export interface MCPTool<T = any> {
  name: string;
  description: string;
  parameters: z.ZodType<T>;
  // A string becomes one text block; ContentResult carries images (capture_scene_image).
  execute: (args: T) => Promise<string | ContentResult>;
  metadata?: ToolMetadata;
}

/**
 * Generic response from a Godot command
 */
export interface CommandResult {
  [key: string]: any;
}