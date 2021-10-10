gdt:
    dw .size - 1 + 8
    dd .start - 8
.start:
    dw 0xffff
    dw 0x0000
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0
    
    dw 0xffff
    dw 0x0000
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
.end:

.size: equ .end - .start