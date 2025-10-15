#!/usr/bin/env python3
"""Verify the Godot MCP files are error-free"""

import subprocess
import time

print("=== Verifying Godot MCP Setup ===\n")

# 1. Check for syntax errors in GDScript files
print("1. Checking GDScript syntax...")
result = subprocess.run(
    ["/Applications/Godot.app/Contents/MacOS/Godot", "--headless", "--quit", "--path", "/Users/raymondgonzalez/mcp/Godot-MCP"],
    capture_output=True,
    text=True,
    timeout=15
)

if "ERROR" in result.stderr or "Parse Error" in result.stderr:
    print("❌ Syntax errors found:")
    for line in result.stderr.split('\n'):
        if 'ERROR' in line or 'Parse Error' in line:
            print(f"  {line}")
else:
    print("✅ No syntax errors found!")

# 2. Check file structure
print("\n2. Checking required files...")
import os

required_files = [
    "addons/godot_mcp/mcp_server.gd",
    "addons/godot_mcp/command_handler.gd",
    "addons/godot_mcp/commands/node_commands.gd",
    "addons/godot_mcp/commands/scene_commands.gd",
    "addons/godot_mcp/utils/scene_transaction_manager.gd",
]

os.chdir("/Users/raymondgonzalez/mcp/Godot-MCP")

for filepath in required_files:
    if os.path.exists(filepath):
        size = os.path.getsize(filepath)
        print(f"  ✅ {filepath} ({size} bytes)")
    else:
        print(f"  ❌ {filepath} MISSING")

print("\n=== Verification Complete ===")
