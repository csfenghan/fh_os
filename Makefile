CC:=gcc
LD:=ld
MAKE:=make -C
ASM:=nasm
OBJDUMP:=objdump
OBJCOPY:=objcopy

#根目录、子文件夹目录和输出
OBJ_DIR:=obj
ROOT_DIR:=$(shell pwd)
SUB_DIR:=boot kernel 
IMAGE:=kernel.img
QEMU:=qemu-system-i386
GDBPORT=1234

#配置
C_FLAGS:=-Werror -g -m32 -O1 -fno-builtin -nostdinc \
		-static -fno-omit-frame-pointer -std=gnu99\
		-I$(ROOT_DIR)
LD_FLAGS:=-Bstatic -m elf_i386
V=@
QEMU_FLAGS:=-drive file=$(OBJ_DIR)/$(IMAGE),media=disk,format=raw -serial mon:stdio -gdb tcp::$(GDBPORT)

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

qemu:$(OBJ_DIR)/$(IMAGE)
	$(QEMU) $(QEMU_FLAGS) 

qemu-gdb:$(OBJ_DIR)/$(IMAGE)
	$(QEMU) $(QEMU_FLAGS) -S

qemu-nox:$(OBJ_DIR)/$(IMAGE)
	$(QEMU) $(QEMU_FLAGS) -nographic

qemu-nox-gdb:$(OBJ_DIR)/$(IMAGE)
	$(QEMU) $(QEMU_FLAGS) -nographic -S
