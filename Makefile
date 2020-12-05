CC=gcc
LD=ld
MAKE=-make -C
ASM=nasm

#根目录、子文件夹目录和输出
OBJ_DIR=obj
ROOT_DIR=$(shell pwd)
SUB_DIR=boot kernel 
IMAGE=kernel.img

#配置
C_FLAGS=-Werror -I$(ROOT_DIR) -m32 -fno-builtin -nostdinc
V=@

#向子目录的makefile输出
export CC LD C_FLAGS ROOT_DIR OBJ_DIR V

all:$(SUB_DIR) 
	$(V) dd if=/dev/zero of=$(OBJ_DIR)/$(IMAGE) count=10000 2>/dev/null
	$(V) dd if=boot/StartSector of=$(OBJ_DIR)/$(IMAGE) conv=notrunc 2>/dev/null
	$(V) dd if=$(OBJ_DIR)/boot/boot of=$(OBJ_DIR)/$(IMAGE) bs=510 conv=notrunc 2>/dev/null

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
