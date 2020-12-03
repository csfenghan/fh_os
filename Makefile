CC=gcc
MAKE=-make -C
ASM=nasm

#根目录、子文件夹目录和输出
OBJ_DIR=obj
ROOT_DIR=$(shell pwd)
SUB_DIR=boot kernel 
IMAGE=kernel.img

#向子目录的makefile输出
export CC ROOT_DIR OBJ_DIR

#构建目标
all:$(SUB_DIR) 
	#构建磁盘
	dd if=/dev/zero of=$(OBJ_DIR)/$(IMAGE) count=10000 2>/dev/null
	dd if=$(OBJ_DIR)/boot/bootasm.o of=$(OBJ_DIR)/$(IMAGE) conv=notrunc 2>/dev/null

#迭代构建子目录的目标
$(SUB_DIR):not_use
	@$(MAKE) $@
not_use:


##############################################################
.PHONY:clean qemu qemu-gdb
clean:
	rm -rf $(OBJ_DIR)

qemu:
	qemu-system-i386 $(OBJ_DIR)/$(IMAGE) 

qemu-gdb:
	qemu-system-i386 $(OBJ_DIR)/$(IMAGE) -gdb tcp::1234 -S