#!/bin/bash

echo "=== Fixing all ternary operators in Godot MCP ==="

# Create backups
echo "Creating backups..."
find addons/godot_mcp -name "*.gd" -not -name "*.bak" -exec cp {} {}.bak \;

# Common patterns to fix
# Pattern 1: variable ? true_val : false_val
# Pattern 2: condition() ? true_val : false_val
# Pattern 3: object.method() ? true_val : false_val

echo "Fixing ternary operators..."

# This sed command handles most common cases
find addons/godot_mcp -name "*.gd" -not -name "*.bak" -exec sed -i '' -E '
    # Pattern: expr ? val1 : val2 -> val1 if expr else val2
    s/([a-zA-Z_][a-zA-Z0-9_\.]*(\([^)]*\))?) \? ([^:]+) : ([^,\n)]+)/\3 if \1 else \4/g
    s/([a-zA-Z_][a-zA-Z0-9_]*) \? ([^:]+) : ([^,\n)]+)/\2 if \1 else \3/g
' {} \;

echo "Done! Checking results..."

# Count remaining ternary operators
count=$(find addons/godot_mcp -name "*.gd" -not -name "*.bak" -exec grep -c " ? " {} \; | awk '{s+=$1} END {print s}')

if [ "$count" -eq "0" ]; then
    echo "✅ All ternary operators fixed!"
else
    echo "⚠️  Still found $count lines with ' ? ' - may need manual review"
    find addons/godot_mcp -name "*.gd" -not -name "*.bak" -exec grep -n " ? " {} + | head -20
fi
