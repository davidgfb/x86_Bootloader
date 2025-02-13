[BITS 16]
[ORG 0x7C00]

start:
    ; Mostrar el prompt y obtener la entrada del usuario
    call show_prompt

    ; Llamar a la función sleep si está habilitada
    cmp byte [puede_Dormir], 1
    jne .no_sleep
    mov cx, 60 ; 60 ticks o hz, 1 segundo
    call sleep
.no_sleep:

    jmp start

show_prompt:
    mov si, prompt
    call print_string

    mov di, buffer
    call get_string

    mov si, buffer
    call check_command
    ret

prompt db '>', 0
buffer times 64 db 0

puede_Dormir db 0

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

get_string:
    xor cl, cl
.loop:
    mov ah, 0
    int 0x16
    cmp al, 0x08
    je .backspace
    cmp al, 0x0D
    je .done
    cmp cl, 0x3F
    je .loop
    mov ah, 0x0E
    int 0x10
    stosb
    inc cl
    jmp .loop
.backspace:
    cmp cl, 0
    je .loop
    dec di
    mov byte [di], 0
    dec cl
    mov ah, 0x0E
    mov al, 0x08
    int 10h
    mov al, ' '
    int 10h
    mov al, 0x08
    int 10h
    jmp .loop
.done:
    mov al, 0
    stosb
    call newline
    ret

check_command:
    mov si, buffer
    mov di, echo_cmd
    mov cx, 4
    repe cmpsb
    jne .check_print
    cmp byte [si], ' '
    jne .no_command
    inc si
    call print_string
    call newline
    ret

.check_print:
    mov si, buffer
    mov di, print_cmd
    mov cx, 5
    repe cmpsb
    jne .no_command
    cmp byte [si], ' '
    jne .no_command
    inc si
    call print_string
    call newline
    ret

.no_command:
    ret

newline:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ret

sleep:
    ; Esperar cx ticks del temporizador
    mov bx, cx
.wait_loop:
    hlt
    dec bx
    jnz .wait_loop
    ret

echo_cmd db 'echo', 0
print_cmd db 'print', 0
times 510-($-$$) db 0
dw 0xAA55              ; Firma de bootloader