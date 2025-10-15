#!/usr/bin/env python3

def find_paren_issue(filepath):
    """Find where parentheses become unbalanced"""
    with open(filepath, 'r') as f:
        content = f.read()
    
    lines = content.split('\n')
    
    running_balance = 0
    max_depth = 0
    issue_lines = []
    
    for line_num, line in enumerate(lines, 1):
        line_balance = 0
        for char in line:
            if char == '(':
                line_balance += 1
                running_balance += 1
                max_depth = max(max_depth, running_balance)
            elif char == ')':
                line_balance -= 1
                running_balance -= 1
                if running_balance < 0:
                    issue_lines.append((line_num, "Extra closing parenthesis", running_balance))
        
        # Check specific problematic patterns
        if "child_changes.append_array(_capture_property_change(child" in line:
            print(f"Line {line_num}: Found append_array pattern")
            print(f"  Content: {line.strip()}")
            open_count = line.count('(')
            close_count = line.count(')')
            if open_count != close_count:
                print(f"  ⚠ Unbalanced: {open_count} open, {close_count} close")
    
    print(f"\nFinal balance: {running_balance} (should be 0)")
    print(f"Max depth reached: {max_depth}")
    
    if running_balance != 0:
        print(f"\n{'Missing' if running_balance > 0 else 'Extra'} {abs(running_balance)} {'closing' if running_balance > 0 else 'opening'} parentheses")
    
    # Check for specific patterns that might be problematic
    print("\n=== Checking for common issues ===")
    
    # Look for lines with many parentheses that might have issues
    for line_num, line in enumerate(lines, 1):
        open_count = line.count('(')
        close_count = line.count(')')
        if open_count > 5 or close_count > 5:
            if open_count != close_count:
                print(f"Line {line_num}: {open_count} open, {close_count} close")
                if abs(open_count - close_count) >= 2:
                    print(f"  >>> {line.strip()[:100]}...")

def main():
    filepath = "/Users/raymondgonzalez/mcp/Godot-MCP/addons/godot_mcp/commands/node_commands.gd"
    print(f"Analyzing parentheses in: {filepath}\n")
    find_paren_issue(filepath)

if __name__ == "__main__":
    main()
