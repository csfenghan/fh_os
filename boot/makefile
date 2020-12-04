#就两个文件，一个是负责引导进入保护模式的bootasm.asm，一个是
#使用c语言，负责加载内核程序的bootmain.c

OUTPUT_DIR=$(ROOT_DIR)/$(OBJ_DIR)/boot
OBJ=$(OUTPUT_DIR)/bootasm.o $(OUTPUT_DIR)/bootmain.o
	
#构建输出
all:$(OBJ)
	$(V) $(LD) -m elf_i386 -s -Ttext 0x7c00  -e boot_start \
			-o $(OUTPUT_DIR)/boot.out $^
	$(V) objcopy -O binary -j .text $(OUTPUT_DIR)/boot.out boot
	$(V) mv boot $(OUTPUT_DIR)/

$(OUTPUT_DIR)/%.o:%.asm
	$(V) mkdir -p $(OUTPUT_DIR)
	$(V) nasm -f elf $^ -o $@

$(OUTPUT_DIR)/%.o:%.c
	$(V) mkdir -p $(OUTPUT_DIR)
	$(V) $(CC) $(C_FLAGS) -c $^ -o $@
