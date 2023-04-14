AS = yasm
QEMU = qemu-system-x86_64

all: clean kernel

kernel: boot/multiboot.asm boot/kernel.asm
	$(AS) -f elf64 -o boot/multiboot.o boot/multiboot.asm
	$(AS) -f elf64 -o boot/kernel.o boot/kernel.asm
	ld -n -T linker.ld -o base/boot/kernel boot/kernel.o boot/multiboot.o

qemu: kernel
	grub-mkrescue -d /usr/lib/grub/i386-pc -o owos.iso base/
	$(QEMU) -drive format=raw,file=owos.iso -m 2G

clean:
	rm -f **/*.o **/*.bin owos.iso

.PHONY: all clean qemu