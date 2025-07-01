; Rewritten Assembly Program - Reads 5 positive integers only
; NO push/pop instructions, NO negative number handling
; Simplified code with core functionality: read 5 positive integers, store in array, display

section .data
    prompt db 'Enter positive integer: ', 0
    prompt_len equ $ - prompt - 1
    output_msg db 'Array contents: ', 0
    output_msg_len equ $ - output_msg - 1
    newline db 10, 0
    space db ' ', 0
    
section .bss
    array resw 5        ; Array to store 5 positive integers (2 bytes each)
    input_buffer resb 2 ; Buffer for single character input
    number_buffer resb 10 ; Buffer to build numbers
    output_buffer resb 10 ; Buffer for output conversion
    
    ; Register save areas (instead of using push/pop)
    saved_r12 resq 1
    saved_r13 resq 1
    saved_r14 resq 1
    saved_r15 resq 1
    
section .text
    global _start

_start:
    mov r12, 0          ; Counter for array index
    
input_loop:
    ; Display prompt
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, prompt
    mov rdx, prompt_len
    syscall
    
    ; Read positive integer (no push/pop, no negative handling)
    mov [saved_r12], r12    ; Save counter using memory instead of push
    call read_positive_integer
    mov r12, [saved_r12]    ; Restore counter using memory instead of pop
    
    ; Store in array
    mov [array + r12*2], ax
    
    ; Increment counter
    inc r12
    cmp r12, 5
    jl input_loop
    
    ; Display output message
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, output_msg
    mov rdx, output_msg_len
    syscall
    
    ; Display array contents
    mov r12, 0          ; Reset counter
    
output_loop:
    mov ax, [array + r12*2]  ; Load array element
    
    mov [saved_r12], r12    ; Save counter using memory instead of push
    call print_positive_integer
    mov r12, [saved_r12]    ; Restore counter using memory instead of pop
    
    ; Print space
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, space
    mov rdx, 1
    syscall
    
    inc r12
    cmp r12, 5
    jl output_loop
    
    ; Print newline
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, newline
    mov rdx, 1
    syscall
    
    ; Exit program
    mov rax, 60         ; sys_exit
    mov rdi, 0          ; exit status
    syscall

; Function to read positive integer only (0-32767)
; NO push/pop instructions, NO negative number handling
read_positive_integer:
    ; Save registers using unused registers instead of push/pop
    mov r13, rbx
    mov r14, rcx
    mov r15, rdx
    
    ; Clear number buffer
    mov r8, 0
clear_number_buffer:
    mov byte [number_buffer + r8], 0
    inc r8
    cmp r8, 10
    jl clear_number_buffer
    
    ; Read number character by character
    mov r8, 0           ; Buffer index
    
read_char_loop:
    ; Read one character
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, input_buffer
    mov rdx, 1
    syscall
    
    ; Check if character is newline or end
    mov al, [input_buffer]
    cmp al, 10          ; newline
    je parse_number
    cmp al, 0           ; null
    je parse_number
    cmp al, '0'
    jl read_char_loop   ; Skip non-digit characters
    cmp al, '9'
    jg read_char_loop   ; Skip non-digit characters
    
    ; Store digit in number buffer
    mov [number_buffer + r8], al
    inc r8
    cmp r8, 9           ; Prevent buffer overflow
    jl read_char_loop
    
parse_number:
    ; Convert number buffer to integer
    mov rsi, number_buffer
    mov rax, 0          ; Result
    
convert_loop:
    mov cl, [rsi]       ; Load character
    cmp cl, 0           ; Check for null terminator
    je conversion_done_positive
    cmp cl, '0'
    jl conversion_done_positive
    cmp cl, '9'
    jg conversion_done_positive
    
    sub cl, '0'         ; Convert to digit
    mov rbx, 10
    mul rbx             ; Multiply result by 10 (rax = rax * rbx)
    movzx rcx, cl       ; Zero extend cl to rcx
    add rax, rcx        ; Add new digit
    inc rsi             ; Next character
    jmp convert_loop
    
conversion_done_positive:
    ; Ensure result fits in 16 bits (0-32767)
    cmp rax, 32767
    jle read_positive_done
    mov rax, 32767      ; Cap at maximum positive value
    
read_positive_done:
    ; Restore registers using unused registers instead of pop
    mov rbx, r13
    mov rcx, r14
    mov rdx, r15
    ret

; Function to print positive integer only
; NO push/pop instructions, NO negative number handling
print_positive_integer:
    ; Save registers using unused registers instead of push/pop
    mov r13, rbx
    mov r14, rcx
    mov r15, rdx
    mov [saved_r15], rsi    ; Save rsi in memory
    
    mov rbx, rax        ; Copy number
    mov rsi, output_buffer + 9  ; Point to end of buffer
    mov byte [rsi], 0   ; Null terminate
    
    ; NO negative number check - only handle positive
convert_to_string_positive:
    dec rsi
    mov rax, rbx
    mov rcx, 10         ; Use rcx instead of rbx for divisor
    mov rdx, 0
    div rcx             ; Divide by 10
    add dl, '0'         ; Convert remainder to ASCII
    mov [rsi], dl       ; Store digit
    mov rbx, rax        ; Quotient becomes new number
    cmp rbx, 0
    jne convert_to_string_positive
    
    ; NO minus sign handling needed
    
print_positive_number:
    ; Calculate length
    mov rdx, output_buffer + 9
    sub rdx, rsi
    
    ; Print string
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall
    
    ; Restore registers using unused registers instead of pop
    mov rsi, [saved_r15]    ; Restore rsi from memory
    mov rbx, r13
    mov rcx, r14
    mov rdx, r15
    ret