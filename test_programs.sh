#!/bin/bash

echo "Testing original program (with push/pop and negative number handling)..."
echo "Assembling original_program.asm..."
nasm -f elf64 original_program.asm -o original_program.o
if [ $? -eq 0 ]; then
    ld original_program.o -o original_program
    if [ $? -eq 0 ]; then
        echo "Original program assembled successfully."
        echo "Test input: 5 -3 10 -7 2"
        echo -e "5\n-3\n10\n-7\n2" | ./original_program
        echo
    else
        echo "Failed to link original program"
    fi
else
    echo "Failed to assemble original program"
fi

echo "Testing rewritten program (NO push/pop, positive integers only)..."
echo "Assembling rewritten_program.asm..."
nasm -f elf64 rewritten_program.asm -o rewritten_program.o
if [ $? -eq 0 ]; then
    ld rewritten_program.o -o rewritten_program
    if [ $? -eq 0 ]; then
        echo "Rewritten program assembled successfully."
        echo "Test input: 5 3 10 7 2"
        echo -e "5\n3\n10\n7\n2" | ./rewritten_program
        echo
    else
        echo "Failed to link rewritten program"
    fi
else
    echo "Failed to assemble rewritten program"
fi

echo "Checking for push/pop instructions in rewritten program..."
objdump -d rewritten_program | grep -E "(push|pop)" && echo "ERROR: Found push/pop instructions!" || echo "SUCCESS: No push/pop instructions found."

echo "Checking for negative number handling in rewritten program..."
grep -n "neg\|minus" rewritten_program.asm && echo "Check for negative handling in source" || echo "SUCCESS: No negative number handling found in source."