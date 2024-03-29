#######################################################
#内核的入口程序，负责打开虚拟内存并将控制权移交main函数
######################################################

#include <x86_memory_layout.h>

######################################################
#起始
######################################################
.text
.align 4

#给出内核的入口地址
.global kernel_entry

#计算内核的实际物理地址
kernel_entry=kernel_start-KERNEL_BASE

#内核起始
kernel_start:
    ############################################
    #初始化页目录（临时使用）
    ############################################
    #开启4MB支持
    movl %cr4,%eax
    orl $CR4_PSE,%eax
    movl %eax,%cr4

    movl $(entry_page_dir-KERNEL_BASE),%ebx
    
    #将[0,4MB]映射到[0,4MB]，没有写权限,开启超级页
    movl $(0x00|PT_P|PT_PS),%eax
    movl %eax,(%ebx)

    #将[KERNEL_BASE,KERNEL_BASE+4MB]映射到[0,4MB]，开启超级页，每个页4MB
    movl $(PD_INDEX(KERNEL_BASE)),%edx
    leal (%ebx,%edx,4),%ebx
    movl $(0x00|PT_W|PT_P|PT_PS),%eax
    movl %eax,(%ebx)

    ################################################
    #加载cr3并开启虚拟内存和写保护
    ################################################
    #加载cr3
    movl $(entry_page_dir-KERNEL_BASE),%eax
    movl %eax,%cr3

    #开启虚拟内存与写保护
    movl %cr0,%eax
    orl $0x80010001,%eax
    movl %eax,%cr0

    #跳转到高地址执行
    movl $next,%eax
    jmp *%eax

    #############################################################
    #虚拟内存已经打开，这里打印一串消息,然后完成部分初始化后移交c函数处理
    #############################################################

next:
    movl 0x00,%ebp
    movl $(KERNEL_STACK_TOP),%esp
    
    #不知道为什么，，直接call会出错，用jmp就没事
	push %ebp
    call main

spin:
	jmp spin


###################################################
#该段保存一个临时的页表，因为页目录和页表必须从一页的起始位置
#开始，因此必须4k对齐
###################################################
.data
.align PAGE_SIZE
#临时的页目录
entry_page_dir:
    .space PAGE_SIZE

#####################################################
#内核栈保存在这个位置
#####################################################
.align PAGE_SIZE
.global KERNEL_STACK_BOTTOM

KERNEL_STACK_BOTTOM:
    .space KERNEL_STACK_SIZE

.global KERNEL_STACK_TOP
KERNEL_STACK_TOP:
