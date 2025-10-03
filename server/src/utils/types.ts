import { z } from 'zod';

export type CapabilityRole = 'read' | 'write' | 'admin';

export interface ToolCapability {
  role: CapabilityRole;
  escalationMessage?: string;
}

/**
 * Interface for FastMCP tool definition
 */
export interface MCPTool<T = any> {
  name: string;
  description: string;
  parameters: z.ZodType<T>;
  execute: (args: T) => Promise<string>;
  capability?: ToolCapability;
}

/**
 * Generic response from a Godot command
 */
export interface CommandResult {
  [key: string]: any;
}
