#就两个文件，一个是负责引导进入保护模式的bootasm.asm，一个是
#使用c语言，负责加载内核程序的bootmain.c

#将bootasm.asm和bootmain.c编译成32位的elf文件后进行链接，链接后
#使用objcopy转换成bin文件

OUTPUT_DIR=$(ROOT_DIR)/$(OBJ_DIR)/boot
OBJ=$(OUTPUT_DIR)/boot_asm.o $(OUTPUT_DIR)/boot_main.o

#构建输出
all:$(OBJ)
	$(V) $(LD) $(LD_FLAGS) -Ttext 0x7c00  -e boot_start \
			-o $(OUTPUT_DIR)/boot.out $^
	$(V) $(OBJDUMP) -S $(OUTPUT_DIR)/boot.out >$(OUTPUT_DIR)/boot.asm
	$(V) $(OBJCOPY) -S -O binary -j .text  $(OUTPUT_DIR)/boot.out $(OUTPUT_DIR)/boot

$(OUTPUT_DIR)/%.o:%.asm
	$(V) mkdir -p $(OUTPUT_DIR)
	$(V) $(ASM) -f elf $^ -o $@

$(OUTPUT_DIR)/%.o:%.c
	$(V) mkdir -p $(OUTPUT_DIR)
	$(V) $(CC) $(C_FLAGS) -Os -c $^ -o $@
