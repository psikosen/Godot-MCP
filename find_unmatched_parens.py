#!/usr/bin/env python3

import re

def find_unmatched_parens(filepath):
    """Find locations of unmatched parentheses in a file"""
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    stack = []  # Stack to track open parentheses with their locations
    
    for line_num, line in enumerate(lines, 1):
        # Skip comments
        comment_pos = line.find('#')
        if comment_pos >= 0:
            line = line[:comment_pos]
        
        # Skip strings (simple approach - may not catch all cases)
        line = re.sub(r'"[^"]*"', '', line)
        line = re.sub(r"'[^']*'", '', line)
        
        for col_num, char in enumerate(line, 1):
            if char == '(':
                stack.append((line_num, col_num))
            elif char == ')':
                if stack:
                    stack.pop()
                else:
                    print(f"Extra closing parenthesis at line {line_num}, column {col_num}")
    
    if stack:
        print(f"\n{len(stack)} unclosed parentheses found:")
        # Show the last few unclosed parens as they're likely the problem
        for line_num, col_num in stack[-5:]:
            print(f"  Line {line_num}, column {col_num}")
            
            # Show context
            with open(filepath, 'r') as f:
                lines = f.readlines()
                if line_num <= len(lines):
                    context_start = max(0, line_num - 2)
                    context_end = min(len(lines), line_num + 1)
                    print("    Context:")
                    for i in range(context_start, context_end):
                        prefix = ">>> " if i == line_num - 1 else "    "
                        print(f"{prefix}{i+1}: {lines[i].rstrip()}")
                    print()

def main():
    filepath = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/node_commands.gd"
    print(f"Checking for unmatched parentheses in: {filepath}\n")
    find_unmatched_parens(filepath)

if __name__ == "__main__":
    main()
