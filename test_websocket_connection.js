const WebSocket = require('ws');

async function testConnection(url) {
    return new Promise((resolve, reject) => {
        console.log(`\nTesting connection to: ${url}`);
        
        const ws = new WebSocket(url, {
            protocol: 'json',
            handshakeTimeout: 5000,
            perMessageDeflate: false
        });
        
        const timeout = setTimeout(() => {
            ws.terminate();
            resolve({ url, status: 'timeout' });
        }, 5000);
        
        ws.on('open', () => {
            clearTimeout(timeout);
            console.log(`✅ Connected to ${url}`);
            ws.close();
            resolve({ url, status: 'connected' });
        });
        
        ws.on('error', (err) => {
            clearTimeout(timeout);
            console.log(`❌ Error connecting to ${url}: ${err.message}`);
            resolve({ url, status: 'error', error: err.message });
        });
    });
}

async function main() {
    console.log('Testing WebSocket connections to Godot...');
    
    const urls = [
        'ws://localhost:9080',
        'ws://127.0.0.1:9080',
        'ws://[::1]:9080',
        'ws://0.0.0.0:9080'
    ];
    
    for (const url of urls) {
        await testConnection(url);
    }
    
    console.log('\n=== Summary ===');
    console.log('If all connections failed, the WebSocket server in Godot is not running.');
    console.log('Check that the Godot MCP plugin is enabled and initialized.');
}

main().catch(console.error);
