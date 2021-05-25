#######################################################
#内核的入口程序，负责打开虚拟内存并将控制权移交main函数
######################################################

#include <mmu.h>

######################################################
#起始
######################################################
.text
.align 4

#给出内核的入口地址
.global kernel_entry

#计算内核的实际物理地址
kernel_entry=KERNEL_TO_PHY(kernel_start)

#内核起始
kernel_start:
    ############################################
    #初始化页目录（临时使用）
    ############################################
    #开启4MB支持
    movl %cr4,%eax
    orl $CR4_PSE,%eax
    movl %eax,%cr4

    movl $KERNEL_TO_PHY(entry_page_dir),%ebx
    
    #将[0,4MB]映射到[0,4MB]，没有写权限,开启超级页
    movl $(0x00|PT_P|PT_PS),%eax
    movl %eax,(%ebx)

    #将[KERNEL_BASE,KERNEL_BASE+4MB]映射到[0,4MB]，开启超级页，每个页4MB
    movl $PD_INDEX(KERNEL_BASE),%edx
    leal (%ebx,%edx,4),%ebx
    movl $(0x00|PT_W|PT_P|PT_PS),%eax
    movl %eax,(%ebx)

    ################################################
    #加载cr3并开启虚拟内存和写保护
    ################################################
    #加载cr3
    movl $(KERNEL_TO_PHY(entry_page_dir)),%eax
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
    
    #打印一串消息表示成功启动
    movl (len),%ecx
    movl $(message),%ebx
    movl $(PHY_TO_KERNEL(0xb8000)),%edx

show:
    movb (%ebx),%al
    movb $0x07,%ah 
    movw %ax,(%edx)

    addl $0x01,%ebx
    addl $0x02,%edx

    loop show

    #不知道为什么，，直接call会出错，用jmp就没事
    call main

spin:
	jmp spin


###################################################
#该段保存一个临时的页表，因为页目录和页表必须从一页的起始位置
#开始，因此必须4k对齐
###################################################
.data

#要显示的消息
message:
#    .ascii "Hello,fenghan!You have successfully Started kernel!"
    .ascii " "
len:
    .long len-message

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
