[BITS 16]
[ORG 0x7C00]

start:
    mov si, prompt ;>
    call print_string

    mov di, buffer
    call get_string

    mov si, buffer
    call check_echo

    jmp start

prompt db '>', 0
buffer times 64 db 0

print_string:
    lodsb        ; grab a byte from SI
    or al, al    ; logical or AL by itself
    jz .done     ; if the result is zero, get out
    mov ah, 0x0E
    int 0x10     ; otherwise, print out the character!
    jmp print_string
.done:
    ret

get_string:
    xor cl, cl
.loop:
    mov ah, 0
    int 0x16     ; wait for keypress
    cmp al, 0x08 ; backspace pressed?
    je .backspace ; yes, handle it
    cmp al, 0x0D ; enter pressed?
    je .done     ; yes, we're done
    cmp cl, 0x3F ; 63 chars inputted?
    je .loop     ; yes, only let in backspace and enter
    mov ah, 0x0E
    int 0x10     ; print out character
    stosb        ; put character in buffer
    inc cl
    jmp .loop
.backspace: ;borrado
    cmp cl, 0    ; beginning of string?
    je .loop     ; yes, ignore the key
    dec di
    mov byte [di], 0 ; delete character
    dec cl       ; decrement counter as well
    mov ah, 0x0E
    mov al, 0x08
    int 10h      ; backspace on the screen
    mov al, ' '
    int 10h      ; blank character out
    mov al, 0x08
    int 10h      ; backspace again
    jmp .loop    ; go to the main loop
.done:
    mov al, 0    ; null terminator
    stosb
    call newline
    ret

check_echo:
    mov si, buffer
    mov di, echo_cmd
    mov cx, 4
    repe cmpsb
    jne .no_echo
    call print_string
    call newline
    ret
.no_echo:
    ret

newline:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10     ; newline
    ret

echo_cmd db 'echo', 0
times 510-($-$$) db 0
dw 0xAA55              ; Firma de bootloader