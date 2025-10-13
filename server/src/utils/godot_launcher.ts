import { spawn, ChildProcess } from 'child_process';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { getGodotConnection } from './godot_connection.js';

// Get __dirname equivalent in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Manages launching and monitoring the Godot editor
 */
export class GodotLauncher {
  private godotProcess: ChildProcess | null = null;
  private projectPath: string;
  private godotExecutable: string;
  private maxStartupTime: number;

  /**
   * Creates a new Godot launcher
   * @param projectPath Path to the Godot project (containing project.godot)
   * @param godotExecutable Path or command to launch Godot (default: 'godot' or '/Applications/Godot.app/Contents/MacOS/Godot')
   * @param maxStartupTime Maximum time to wait for Godot to start in ms
   */
  constructor(
    projectPath: string = resolve(__dirname, '../../../'),
    godotExecutable: string = '/Applications/Godot.app/Contents/MacOS/Godot',
    maxStartupTime: number = 30000
  ) {
    this.projectPath = projectPath;
    this.godotExecutable = godotExecutable;
    this.maxStartupTime = maxStartupTime;
  }

  /**
   * Checks if Godot is running and the WebSocket server is accessible
   */
  async isGodotRunning(): Promise<boolean> {
    try {
      const godot = getGodotConnection();
      await godot.connect();
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Launches the Godot editor with the specified project
   * @returns Promise that resolves when Godot is ready and WebSocket server is accessible
   */
  async launch(): Promise<void> {
    console.error(`Launching Godot editor with project: ${this.projectPath}`);

    // Launch Godot with the project path
    // Use --editor flag to open the editor, and pass the project path
    this.godotProcess = spawn(
      this.godotExecutable,
      ['--editor', this.projectPath],
      {
        stdio: 'ignore', // Ignore stdio to prevent interfering with MCP protocol
        detached: false,
      }
    );

    this.godotProcess.on('error', (error) => {
      console.error('Failed to launch Godot:', error);
      throw new Error(`Failed to launch Godot: ${error.message}`);
    });

    this.godotProcess.on('exit', (code, signal) => {
      console.error(`Godot process exited with code ${code}, signal ${signal}`);
      this.godotProcess = null;
    });

    // Wait for the WebSocket server to become available
    const startTime = Date.now();
    let lastError: Error | null = null;

    while (Date.now() - startTime < this.maxStartupTime) {
      try {
        const godot = getGodotConnection();
        await godot.connect();
        console.error('Successfully connected to Godot WebSocket server');
        return;
      } catch (error) {
        lastError = error as Error;
        // Wait a bit before retrying
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }

    // If we get here, we timed out
    if (this.godotProcess) {
      this.godotProcess.kill();
      this.godotProcess = null;
    }
    throw new Error(
      `Timed out waiting for Godot WebSocket server to start. Last error: ${lastError?.message}`
    );
  }

  /**
   * Ensures Godot is running - launches it if necessary
   */
  async ensureGodotRunning(): Promise<void> {
    if (await this.isGodotRunning()) {
      console.error('Godot is already running');
      return;
    }

    console.error('Godot is not running, launching it now...');
    await this.launch();
  }

  /**
   * Stops the Godot process if it was launched by this instance
   */
  stop(): void {
    if (this.godotProcess) {
      console.error('Stopping Godot process...');
      this.godotProcess.kill();
      this.godotProcess = null;
    }
  }
}

// Singleton instance
let launcherInstance: GodotLauncher | null = null;

/**
 * Gets the singleton instance of GodotLauncher
 * Uses environment variables for configuration:
 * - GODOT_PROJECT_PATH: Path to the Godot project directory
 * - GODOT_EXECUTABLE: Path to the Godot executable
 * - GODOT_STARTUP_TIMEOUT: Maximum startup time in milliseconds
 */
export function getGodotLauncher(): GodotLauncher {
  if (!launcherInstance) {
    const projectPath = process.env.GODOT_PROJECT_PATH || resolve(__dirname, '../../../');
    const godotExecutable = process.env.GODOT_EXECUTABLE || '/Applications/Godot.app/Contents/MacOS/Godot';
    const maxStartupTime = parseInt(process.env.GODOT_STARTUP_TIMEOUT || '30000', 10);
    
    console.error('=== Godot Launcher Configuration ===');
    console.error(`Project Path: ${projectPath}`);
    console.error(`Godot Executable: ${godotExecutable}`);
    console.error(`Max Startup Time: ${maxStartupTime}ms`);
    console.error('===================================');
    
    launcherInstance = new GodotLauncher(projectPath, godotExecutable, maxStartupTime);
  }
  return launcherInstance;
}
