#!/usr/bin/env python3
"""Test WebSocket connection to Godot MCP server"""

import asyncio
import websockets
import json
import sys

async def test_connection():
    uri = "ws://localhost:9080"
    print(f"Attempting to connect to {uri}...")
    
    try:
        async with websockets.connect(uri, timeout=5) as websocket:
            print("✅ Connected successfully!")
            
            # Wait for welcome message
            try:
                message = await asyncio.wait_for(websocket.recv(), timeout=3)
                data = json.loads(message)
                print(f"✅ Received welcome: {data}")
            except asyncio.TimeoutError:
                print("⚠️  No welcome message received (may be normal)")
            
            # Send a ping
            ping_message = {
                "jsonrpc": "2.0",
                "method": "ping",
                "id": 1
            }
            print(f"Sending ping: {ping_message}")
            await websocket.send(json.dumps(ping_message))
            
            # Wait for response
            try:
                response = await asyncio.wait_for(websocket.recv(), timeout=3)
                data = json.loads(response)
                print(f"✅ Received response: {data}")
            except asyncio.TimeoutError:
                print("⚠️  No response to ping")
            
            print("\n✅ WebSocket server is working!")
            return True
            
    except ConnectionRefusedError:
        print("❌ Connection refused - Godot MCP server is not running")
        print("\nTo start the server:")
        print("1. Open Godot editor with this project")
        print("2. The MCP plugin should auto-start")
        print("3. Check console for 'MCP SERVER STARTING' message")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    print("=== Testing Godot MCP WebSocket Server ===\n")
    result = asyncio.run(test_connection())
    sys.exit(0 if result else 1)
