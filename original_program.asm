; Original Assembly Program - Reads 5 signed integers, stores in array, displays them
; Uses push/pop instructions and handles negative numbers

section .data
    prompt db 'Enter integer: ', 0
    prompt_len equ $ - prompt - 1
    output_msg db 'Array contents: ', 0
    output_msg_len equ $ - output_msg - 1
    newline db 10, 0
    minus_sign db '-', 0
    space db ' ', 0
    
section .bss
    array resw 5        ; Array to store 5 integers (2 bytes each)
    input_buffer resb 2 ; Buffer for single character input
    number_buffer resb 10 ; Buffer to build numbers
    output_buffer resb 10 ; Buffer for output conversion
    
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
    
    ; Read input
    push r12            ; Save counter
    call read_integer
    pop r12             ; Restore counter
    
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
    
    push r12            ; Save counter
    call print_integer
    pop r12             ; Restore counter
    
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

; Function to read integer (handles negative numbers)
read_integer:
    push rbp
    push rbx
    push rcx
    push rdx
    
    ; Clear number buffer
    mov r8, 0
clear_number_buffer_orig:
    mov byte [number_buffer + r8], 0
    inc r8
    cmp r8, 10
    jl clear_number_buffer_orig
    
    ; Read number character by character
    mov r8, 0           ; Buffer index
    mov r9, 0           ; Sign flag (0=positive, 1=negative)
    
read_char_loop_orig:
    ; Read one character
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, input_buffer
    mov rdx, 1
    syscall
    
    ; Check if character is newline or end
    mov al, [input_buffer]
    cmp al, 10          ; newline
    je parse_number_orig
    cmp al, 0           ; null
    je parse_number_orig
    
    ; Check for minus sign (only at start)
    cmp r8, 0
    jne check_digit_orig
    cmp al, '-'
    jne check_digit_orig
    mov r9, 1           ; Set negative flag
    jmp read_char_loop_orig
    
check_digit_orig:
    cmp al, '0'
    jl read_char_loop_orig   ; Skip non-digit characters
    cmp al, '9'
    jg read_char_loop_orig   ; Skip non-digit characters
    
    ; Store digit in number buffer
    mov [number_buffer + r8], al
    inc r8
    cmp r8, 9           ; Prevent buffer overflow
    jl read_char_loop_orig
    
parse_number_orig:
    ; Convert number buffer to integer
    mov rsi, number_buffer
    mov rax, 0          ; Result
    
convert_loop_orig:
    mov cl, [rsi]       ; Load character
    cmp cl, 0           ; Check for null terminator
    je conversion_done
    cmp cl, '0'
    jl conversion_done
    cmp cl, '9'
    jg conversion_done
    
    sub cl, '0'         ; Convert to digit
    imul rax, 10        ; Multiply result by 10
    movzx rcx, cl       ; Zero extend cl to rcx
    add rax, rcx        ; Add new digit
    inc rsi             ; Next character
    jmp convert_loop_orig
    
conversion_done:
    ; Apply sign
    cmp r9, 1
    jne read_integer_done
    neg rax             ; Make negative
    
read_integer_done:
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret

; Function to print integer (handles negative numbers)
print_integer:
    push rbp
    push rbx
    push rcx
    push rdx
    push rsi
    
    mov rbx, rax        ; Copy number
    mov rsi, output_buffer + 9  ; Point to end of buffer
    mov byte [rsi], 0   ; Null terminate
    mov rcx, 0          ; Sign flag
    
    ; Check if negative
    cmp rbx, 0
    jge convert_to_string
    mov rcx, 1          ; Set negative flag
    neg rbx             ; Make positive for conversion
    
convert_to_string:
    dec rsi
    mov rax, rbx
    mov rbx, 10
    mov rdx, 0
    div rbx             ; Divide by 10
    add dl, '0'         ; Convert remainder to ASCII
    mov [rsi], dl       ; Store digit
    mov rbx, rax        ; Quotient becomes new number
    cmp rbx, 0
    jne convert_to_string
    
    ; Add minus sign if negative
    cmp rcx, 1
    jne print_number
    dec rsi
    mov byte [rsi], '-'
    
print_number:
    ; Calculate length
    mov rdx, output_buffer + 9
    sub rdx, rsi
    
    ; Print string
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall
    
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rbp
    ret