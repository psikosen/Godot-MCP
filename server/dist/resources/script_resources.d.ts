import { Resource } from 'fastmcp';
/**
 * Resource that provides the content of a specific script
 * Note: As a Resource (not ResourceTemplate), it cannot handle dynamic paths
 */
export declare const scriptResource: Resource;
/**
 * Resource that provides a list of all scripts in the project
 */
export declare const scriptListResource: Resource;
/**
 * Resource that provides metadata for a specific script, including classes and methods
 */
export declare const scriptMetadataResource: Resource;
