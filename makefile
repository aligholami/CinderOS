COMPILER = gcc
LINKER = ld
ASSEMBLER = nasm
CFLAGS = -m32 -c --freestanding
ASFLAGS = -f elf32
LDFLAGS = -m elf_i386 -T src/link.ld
EMUALATOR = qemu-system-i386
EMUALATOR_FLAGS = -kernel


OBJS = Objects/cinder.o Objects/cinderc.o Objects/idt.o Objects/isr.o Objects/screen.o Objects/string.o Objects/system.o Objects/util.o Objects/keyb.o Objects/shell.o
OUTPUT = os/boot/kernel.bin

run:all
	$(EMUALATOR) $(EMUALATOR_FLAGS) $(OUTPUT)

all:$(OBJS)
	mkdir os/ -p
	mkdir os/boot -p
	$(LINKER) $(LDFLAGS) -o $(OUTPUT) $(OBJS)

Objects/cinder.o:src/kernel.asm
	$(ASSEMBLER) $(ASFLAGS) -o Objects/cinder.o src/kernel.asm

Objects/cinderc.o:src/kernel.c
	$(COMPILER) $(CFLAGS) src/kernel.c -o Objects/cinderc.o

Objects/idt.o:src/idt.c
	$(COMPILER) $(CFLAGS) src/idt.c -o Objects/idt.o

Objects/keyb.o:src/keyb.c
	$(COMPILER) $(CFLAGS) src/keyb.c -o Objects/keyb.o

Objects/isr.o:src/isr.c
	$(COMPILER) $(CFLAGS) src/isr.c -o Objects/isr.o

Objects/screen.o:src/screen.c
	$(COMPILER) $(CFLAGS) src/screen.c -o Objects/screen.o

Objects/string.o:src/string.c
	$(COMPILER) $(CFLAGS) src/string.c -o Objects/string.o

Objects/system.o:src/system.c
	$(COMPILER) $(CFLAGS) src/system.c -o Objects/system.o

Objects/util.o:src/util.c
	$(COMPILER) $(CFLAGS) src/util.c -o Objects/util.o

Objects/shell.o:src/shell.c
	$(COMPILER) $(CFLAGS) src/shell.c -o Objects/shell.o

build:all
	rm os/boot/grub/ -r -f
	mkdir os/boot/grub/
	echo set default=0 >> os/boot/grub/grub.cfg
	echo set timeout=0 >> os/boot/grub/grub.cfg
	echo menuentry "os" { >> os/boot/grub/grub.cfg
	echo         set root='(hd96)' >> os/boot/grub/grub.cfg
	echo         multiboot /boot/kernel.bin >> os/boot/grub/grub.cfg
	echo } >> os/boot/grub/grub.cfg

	grub-mkrescue -o os.iso os/

clear:
	rm -f Objects/*.o
	rm -r -f os/
