; kernel.asm - second sector, loaded at 0x0000:0x8000
org 0x8000

start:
    mov si, kernel_msg
.kloop:
    lodsb
    cmp al, 0
    je .halt
    mov ah, 0x0E
    int 0x10
    jmp .kloop

.halt:
    cli
    hlt
    jmp .halt

kernel_msg: db "MY OS KERNEL STARTED",0

; pad to 512 bytes (so kernel.bin is exactly one sector)
times 512 - ($ - $$) db 0
