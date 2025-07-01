# Assembly Code Rewrite Documentation

## Problem Statement
Rewrite assembly code to:
1. Remove all push and pop instructions
2. Remove handling for negative numbers (positive integers only 0-32767)
3. Simplify code while maintaining core functionality

## Changes Made

### Original Program (`original_program.asm`)
- Uses push/pop instructions for register saving
- Handles negative numbers with minus sign parsing
- Supports signed integers including negative values
- Uses stack-based register preservation

### Rewritten Program (`rewritten_program.asm`)
- **NO push/pop instructions** - Uses memory locations and unused registers instead
- **NO negative number handling** - Only accepts positive integers (0-32767)
- **Simplified input parsing** - Character-by-character reading without minus sign support
- **Memory-based register saving** - Uses `.bss` section variables instead of stack

## Key Differences

### Register Saving
**Original:** `push rbx` / `pop rbx`
**Rewritten:** `mov r13, rbx` / `mov rbx, r13` or memory locations

### Input Handling
**Original:** Checks for minus sign, handles negative conversion
**Rewritten:** Skips minus sign checks, only processes digits 0-9

### Value Range
**Original:** Full signed integer range
**Rewritten:** Positive integers only, capped at 32767

## Verification

### Functionality Test
```bash
# Original program with signed integers
echo -e "5\n-3\n10\n-7\n2" | ./original_program
# Output: 5 65533 10 65529 2 (negative numbers in two's complement)

# Rewritten program with positive integers only
echo -e "5\n3\n10\n7\n2" | ./rewritten_program  
# Output: 5 3 10 7 2
```

### Push/Pop Verification
```bash
objdump -d rewritten_program | grep -E "(push|pop)" | wc -l
# Output: 0 (no push/pop instructions found)
```

### Maximum Value Handling
```bash
echo -e "32767\n50000\n1\n2\n3" | ./rewritten_program
# Output: 32767 32767 1 2 3 (values capped at 32767)
```

## Core Functionality Maintained
✅ Read 5 integers from user input  
✅ Store them in an array  
✅ Display all array elements  
✅ No push/pop instructions  
✅ No negative number handling  
✅ Simplified code structure