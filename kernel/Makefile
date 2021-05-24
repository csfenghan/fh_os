###########################################################
#	对内核文件进行编译并使用链接文件将其分配至指定的地址
#	最终生成的文件为elf32格式，不是bin格式
#	内核入口为kernel_entry
#########################################################

include ../makefile.defines

SOURCE_FILES=kernel_entry.S\
			 main.c\
			 print.c

OBJ_FILES:=$(patsubst %.S,%.o,$(SOURCE_FILES))
OBJ_FILES:=$(patsubst %.c,%.o,$(OBJ_FILES))
LD_FILE=kernel.ld

##########################################################
#	构建过程
#########################################################
all:kernel.elf kernel.asm
	@echo "successfully build the kernel"

kernel.asm:kernel.elf
	$(V) $(OBJDUMP) -S $^ > $@

kernel.elf:$(OBJ_FILES)
	$(V) $(LD) -T $(LD_FILE) $^ -o $@ $(LD_FLAGS)  

%.o:%.S
	$(V) $(CC) -c $^ -o $@ $(C_FLAGS) 

%.o:%.c
	$(V) $(CC) -c $^ -o $@ $(C_FLAGS) 

#######################################################
#	伪指令
#######################################################
.PHONY:clean
clean:
	rm $(OBJ_FILES) kernel.elf kernel.asm
