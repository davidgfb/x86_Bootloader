ASM=nasm
ASM_SRC=Main.asm
MAIN_IMG=Main.img
ASM_FLAGS=-f bin -o $(MAIN_IMG)
EMU=qemu-system-x86_64
EMU_FLAGS=-drive format=raw,file=$(MAIN_IMG)

game: $(ASM_SRC)
	$(ASM) $(ASM_SRC) $(ASM_FLAGS)
	make run

run:
	$(EMU) $(EMU_FLAGS)