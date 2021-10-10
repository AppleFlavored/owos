AS = nasm
QEMU = qemu-system-x86_64

.PHONY: all
all: clean kernel.bin

kernel.bin: boot/boot.asm
	$(AS) -f bin -o $@ $^

.PHONY: qemu
qemu:
	$(QEMU) -drive format=raw,file=kernel.bin

.PHONY: clean
clean:
	rm -f *.o *.bin