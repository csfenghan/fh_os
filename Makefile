CC=gcc
LD=ld
MAKE=make -C
ASM=nasm
OBJDUMP=objdump
OBJCOPY=objcopy

#根目录、子文件夹目录和输出
OBJ_DIR=obj
ROOT_DIR=$(shell pwd)
SUB_DIR=boot kernel 
IMAGE=kernel.img
QEMU=qemu-system-i386

#配置
C_FLAGS=-Werror -g -m32 -O1 -fno-builtin -nostdinc \
		-static -fno-omit-frame-pointer -std=gnu99\
		-I$(ROOT_DIR)
LD_FLAGS=-Bstatic -m elf_i386
V=@

#向子目录的makefile输出
export CC LD MAKE ASM OBJDUMP OBJCOPY \
		OBJ_DIR ROOT_DIR C_FLAGS LD_FLAGS V


#构建目标
all:$(SUB_DIR) 
	$(V) dd if=/dev/zero of=$(OBJ_DIR)/$(IMAGE) count=10000 2>/dev/null
	$(V) dd if=boot/StartSector of=$(OBJ_DIR)/$(IMAGE) conv=notrunc 2>/dev/null
	$(V) dd if=$(OBJ_DIR)/boot/boot of=$(OBJ_DIR)/$(IMAGE) bs=510 conv=notrunc 2>/dev/null
	$(V) dd if=$(OBJ_DIR)/kernel/kernel of=$(OBJ_DIR)/$(IMAGE) bs=512 seek=1 conv=notrunc 2>/dev/null

#迭代构建子目录的目标
$(SUB_DIR):not_use
	@$(MAKE) $@
not_use:


##############################################################
.PHONY:clean qemu qemu-gdb
clean:
	rm -rf $(OBJ_DIR)

qemu:
	$(QEMU) $(OBJ_DIR)/$(IMAGE) 
qemu-nox:
	$(QEMU) -nographic $(OBJ_DIR)/$(IMAGE) 

qemu-gdb:
	$(QEMU) -nographic $(OBJ_DIR)/$(IMAGE) -gdb tcp::1234 -S
