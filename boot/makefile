#就两个文件，一个是负责引导进入保护模式的bootasm.asm，一个是
#使用c语言，负责加载内核程序的bootmain.c

OUTPUT_DIR=$(ROOT_DIR)/$(OBJ_DIR)/boot
OBJ=$(OUTPUT_DIR)/bootasm.o $(OUTPUT_DIR)/bootmain.o
	
#构建输出
all:$(OBJ)

$(OUTPUT_DIR)/%.o:%.asm
	@mkdir -p $(OUTPUT_DIR)
	nasm $^ -o $@

$(OUTPUT_DIR)/%.o:%.c
	@mkdir -p $(OUTPUT_DIR)
	$(CC) -c $^ -o $@