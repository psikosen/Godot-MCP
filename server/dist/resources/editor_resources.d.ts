import { Resource, FastMCPSessionAuth } from 'fastmcp';
/**
 * Resource that provides information about the current state of the Godot editor
 */
export declare const editorStateResource: Resource<FastMCPSessionAuth>;
/**
 * Resource that provides information about the currently selected node
 */
export declare const selectedNodeResource: Resource<FastMCPSessionAuth>;
/**
 * Resource that provides information about the currently edited script
 */
export declare const currentScriptResource: Resource<FastMCPSessionAuth>;
