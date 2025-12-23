; Debug version to understand input reading
section .data
    prompt db 'Enter integer: ', 0
    debug_msg db 'Read: ', 0
    newline db 10, 0
    
section .bss
    input_buffer resb 10
    
section .text
    global _start

_start:
    ; Read one number
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt
    mov rdx, 15
    syscall
    
    ; Clear buffer
    mov r8, 0
clear_loop:
    mov byte [input_buffer + r8], 0
    inc r8
    cmp r8, 10
    jl clear_loop
    
    ; Read input
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 10
    syscall
    
    ; Show what we read
    mov rax, 1
    mov rdi, 1
    mov rsi, debug_msg
    mov rdx, 6
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, input_buffer
    mov rdx, 10
    syscall
    
    ; Exit
    mov rax, 60
    mov rdi, 0
    syscall