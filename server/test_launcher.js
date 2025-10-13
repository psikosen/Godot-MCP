import { getGodotLauncher } from './dist/utils/godot_launcher.js';

console.log('Testing Godot launcher...');

async function test() {
  try {
    const launcher = getGodotLauncher();
    console.log('Checking if Godot is running...');
    const isRunning = await launcher.isGodotRunning();
    console.log('Godot running:', isRunning);
    
    if (!isRunning) {
      console.log('Attempting to launch Godot...');
      await launcher.ensureGodotRunning();
      console.log('Godot launched successfully!');
    }
  } catch (error) {
    console.error('Error:', error.message);
    console.error('Stack:', error.stack);
  }
  
  // Keep process alive for 5 seconds to verify
  setTimeout(() => {
    console.log('Test complete!');
    process.exit(0);
  }, 5000);
}

test();
