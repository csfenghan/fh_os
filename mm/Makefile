###########################################################
#	内存管理目录构建
#########################################################

include ../makefile.defines

SOURCE_FILES=mm.c

OBJ_FILES:=$(patsubst %.S,%.o,$(SOURCE_FILES))
OBJ_FILES:=$(patsubst %.c,%.o,$(OBJ_FILES))

##########################################################
#	构建过程
#########################################################
all:libmm.a
	@echo "successfully build the libmm.a"

libmm.a:$(OBJ_FILES)
	@ar rs $@ $^

%.o:%.S
	$(V) $(CC) $(C_FLAGS) -c $^ -o $@

%.o:%.c
	$(V) $(CC) $(C_FLAGS) -c $^ -o $@

#######################################################
#	伪指令
#######################################################
.PHONY:clean
clean:
	rm $(OBJ_FILES)  libmm.a
