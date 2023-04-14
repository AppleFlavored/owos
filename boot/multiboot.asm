global start32

section .multiboot_header
mb_header:
	dd .magic
	dd .arch
	dd .size
	dd 0x100000000 - (.magic + .arch + .size)

	; end tag
	dw 0
	dw 0
	dd 8
.size: equ $ - mb_header
.arch: equ 0
.magic: equ 0xe85250d6

section .text
bits 32
start32:
	; We are now in protected mode (32-bit), but we now need to make the
	; switch to long mode (64-bit).

	mov esp, stack_top
	
	call check_multiboot
	call check_cpuid
	call check_longmode

	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	mov eax, p3_table
	or eax, 11b
	mov [p4_table], eax

	mov eax, p2_table
	or eax, 11b
	mov [p3_table], eax

	mov ecx, 0
.map_p2_table:
	mov eax, 0x200000
	mul ecx
	or eax, 10000011b
	mov [p2_table + ecx * 8], eax

	inc ecx
	cmp ecx, 512
	jne .map_p2_table

	mov eax, p4_table
	mov cr3, eax

	mov ecx, 0xc0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	lgdt [gdt64.ptr]
	jmp gdt64.code:start64

bits 64
start64:
	extern kernel_main
	call kernel_main
	hlt

bits 32
check_multiboot:
	cmp eax, 0x36d76289
	jne .no_multiboot
	ret
.no_multiboot:
	jmp error

check_cpuid:
	pushfd
	pop eax

	mov ecx, eax
	
	xor eax, 1 << 21
	
	push eax
	popfd

	pushfd
	pop eax

	push ecx
	popfd

	xor eax, ecx
	jz .no_cpuid
	ret
.no_cpuid:
	jmp error

check_longmode:
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb .no_longmode

	mov eax, 0x80000001
	cpuid
	test edx, 1 << 29
	jz .no_longmode

	ret
.no_longmode:
	jmp error

error:
	; TODO: print descriptive error code
	mov word [0xb8000], 0x4f45
	hlt

section .bss
align 4096
p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096
stack_bottom:
	resb 16384
stack_top:

section .rodata
gdt64:
	dq 0
.code: equ $ - gdt64
	dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)
.ptr:
	dw $ - gdt64 - 1
	dq gdt64