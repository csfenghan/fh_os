#这个文件包含了makefile的配置信息
include makefile.defines

##################################################
#	构建过程
#################################################
all:BUILD_SUB_DIR
	@#先创建一个10M的镜像
	$(V) dd if=/dev/zero of=$(IMAGE) count=20000 2>/dev/null

	@#将boot中的起始扇区写入到镜像中，其是最后两个字节用于标识启动扇区的标识码
	$(V) dd if=boot/StartSector of=$(IMAGE) conv=notrunc 2>/dev/null

	@#将boot代码写入镜像中，注意不要覆盖启动扇区的最后两个字节
	$(V) dd if=boot/boot.bin of=$(IMAGE) bs=510 conv=notrunc 2>/dev/null

	@#将kernel的内容写入到镜像的第二个扇区以后的位置
	$(V) dd if=kernel/kernel.elf of=$(IMAGE) bs=512 seek=1 conv=notrunc 2>/dev/null

	@echo "All built"

#迭代构建子目录的目标
BUILD_SUB_DIR:$(SUB_DIR)
	@(for sub_dir in $(SUB_DIR);\
		do\
			make -C $$sub_dir;\
		done)

####################################################
#	伪指令
####################################################
.PHONY:clean qemu qemu-gdb
clean:
	rm $(IMAGE)
	@(for sub_dir in $(SUB_DIR);\
		do\
			make clean -C $$sub_dir;\
		done)

qemu:$(IMAGE)
	$(QEMU) $(QEMU_FLAGS) 

qemu-gdb:$(IMAGE)
	$(QEMU) $(QEMU_FLAGS) -S

qemu-nox:$(IMAGE)
	$(QEMU) $(QEMU_FLAGS) -nographic

qemu-nox-gdb:$(IMAGE)
	$(QEMU) $(QEMU_FLAGS) -nographic -S
