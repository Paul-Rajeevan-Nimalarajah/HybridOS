; boot.asm - simple boot sector (512 bytes)
org 0x7c00

start:
    ; save boot drive (DL) so int13 reads know which drive to use
    mov [boot_drive], dl

    ; print "BOOTING..."
    mov si, boot_msg
.print_char:
    lodsb
    cmp al, 0
    je .after_print
    mov ah, 0x0E    ; teletype BIOS
    mov bh, 0
    mov bl, 0x07
    int 0x10
    jmp .print_char
.after_print:

    ; prepare ES:BX -> 0x0000:0x8000 for read
    xor ax, ax
    mov es, ax
    mov bx, 0x8000

    ; restore drive into DL
    mov dl, [boot_drive]

    ; BIOS read: AH=0x02, AL=1 sector, CH=0, CL=2 (sector 2), DH=0, DL=drive
    mov ah, 0x02
    mov al, 0x01
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    int 0x13
    jc .disk_error

    ; jump to loaded kernel at 0x0000:0x8000
    jmp 0x0000:0x8000

.disk_error:
    mov si, disk_err
.err_loop:
    lodsb
    cmp al,0
    je .hang
    mov ah,0x0E
    int 0x10
    jmp .err_loop

.hang:
    cli
    hlt
    jmp .hang

boot_drive: db 0

boot_msg: db "BOOTING...",0
disk_err: db "DISK ERR",0

; pad to 510 bytes, then write boot signature
times 510 - ($ - $$) db 0
dw 0xAA55
