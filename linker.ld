ENTRY(start32)
SECTIONS {
    . = 1M;
    
    .text.boot : {
        *(.multiboot_header)
    }

    .text : {
        *(.text)
    }

    .rodata : {
        *(.rodata)
    }
}