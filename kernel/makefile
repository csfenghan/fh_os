#对内核文件进行编译并使用链接文件将其分配至指定的地址
#最终生成的文件为elf32格式，不是bin格式
#内核入口为kernel_entry

OUTPUT_DIR=$(ROOT_DIR)/$(OBJ_DIR)/kernel
SOURCE_FILES=kernel_entry.asm\
			 main.c

OBJ_FILES:=$(patsubst %.asm,$(OUTPUT_DIR)/%.o,$(SOURCE_FILES))
OBJ_FILES:=$(patsubst %.c,$(OUTPUT_DIR)/%.o,$(OBJ_FILES))
LD_FILE=kernel.ld

all:$(OBJ_FILES)
	$(V) $(LD) $(LD_FLAGS)  -T $(LD_FILE) $^ -o $(OUTPUT_DIR)/kernel
	$(V) $(OBJDUMP) -S $(OUTPUT_DIR)/kernel > $(OUTPUT_DIR)/kernel.asm


##################################################
$(OUTPUT_DIR)/%.o:%.asm
	$(V) mkdir -p $(OUTPUT_DIR)
	$(V) $(ASM) -f elf $^ -o $@

$(OUTPUT_DIR)/%.o:%.c
	$(V) mkdir -p $(OUTPUT_DIR)
	$(V) $(CC) $(C_FLAGS) -c $^ -o $@

