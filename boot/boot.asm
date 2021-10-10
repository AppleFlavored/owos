[bits 16]
[org 0x7c00]

start:
    cli
    cld

    ; Zero segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    mov sp, 0x7c00
    sti

    ; Print out welcome message
    mov si, EntryMsg
    call print

.enable_a20:
    ; Using fast A20 which won't work on all systems
    in al, 0x92
    test al, 2
    jnz .enable_a20_after

    or al, 2
    and al, 0xfe
    out 0x92, al
.enable_a20_after:
    ; A20 is probably enabled, so let's head into protected mode
    jmp enter_protected_mode

enter_protected_mode:
    cli
    push ds
    push es
    
    lgdt [gdt]

    mov eax, cr0
    or al, 1
    mov cr0, eax
.protected_mode:
    mov bx, 0x10
    mov ds, bx
    mov es, bx

    and al, 0xfe
    mov cr0, eax

    ; We are in protected mode!
    ; Nothing to do here atm so just loop indefinitely.
jmp $

%include "boot/print16.asm"
%include "boot/gdt.asm"

; data
EntryMsg db "bootwoadew gonnya boot into owo!!11", 0x0D, 0x0A, 0

times 510 - ($-$$) db 0
dw 0xaa55