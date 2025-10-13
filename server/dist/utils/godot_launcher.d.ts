/**
 * Manages launching and monitoring the Godot editor
 */
export declare class GodotLauncher {
    private godotProcess;
    private projectPath;
    private godotExecutable;
    private maxStartupTime;
    /**
     * Creates a new Godot launcher
     * @param projectPath Path to the Godot project (containing project.godot)
     * @param godotExecutable Path or command to launch Godot (default: 'godot' or '/Applications/Godot.app/Contents/MacOS/Godot')
     * @param maxStartupTime Maximum time to wait for Godot to start in ms
     */
    constructor(projectPath?: string, godotExecutable?: string, maxStartupTime?: number);
    /**
     * Checks if Godot is running and the WebSocket server is accessible
     */
    isGodotRunning(): Promise<boolean>;
    /**
     * Launches the Godot editor with the specified project
     * @returns Promise that resolves when Godot is ready and WebSocket server is accessible
     */
    launch(): Promise<void>;
    /**
     * Ensures Godot is running - launches it if necessary
     */
    ensureGodotRunning(): Promise<void>;
    /**
     * Stops the Godot process if it was launched by this instance
     */
    stop(): void;
}
/**
 * Gets the singleton instance of GodotLauncher
 * Uses environment variables for configuration:
 * - GODOT_PROJECT_PATH: Path to the Godot project directory
 * - GODOT_EXECUTABLE: Path to the Godot executable
 * - GODOT_STARTUP_TIMEOUT: Maximum startup time in milliseconds
 */
export declare function getGodotLauncher(): GodotLauncher;
