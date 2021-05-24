#就两个文件，一个是负责引导进入保护模式的bootasm.asm，一个是
#使用c语言，负责加载内核程序的bootmain.c

#将bootasm.asm和bootmain.c编译成32位的elf文件后进行链接，链接后
#使用objcopy转换成bin文件

include ../makefile.defines

OBJ=boot_asm.o \
	boot_main.o

#构建输出
all:$(OBJ)
	$(V) $(LD) $(LD_FLAGS) -Ttext 0x7c00  -e boot_start -o boot.out $^
	$(V) $(OBJDUMP) -S boot.out > boot.asm
	$(V) $(OBJCOPY) -S -O binary -j .text  boot.out boot.bin

%.o:%.asm
	$(V) $(ASM) -f elf $^ -o $@

%.o:%.c
	$(V) $(CC) $(C_FLAGS) -Os -c $^ -o $@


.PHONY: clean
clean:
	rm $(OBJ) boot.out boot.asm boot.bin
