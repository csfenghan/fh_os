#######################################################
#内核的入口程序，负责打开虚拟内存并将控制权移交main函数
######################################################

#include <include/mmu.h>


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
    movl $KERNEL_TO_PHY(entry_page_dir),%ebx
    
    #将[0,4MB]映射到[0,4MB]，没有写权限
    movl $KERNEL_TO_PHY(entry_page_table),%eax
    orl $PT_P,%eax
    movl %eax,(%ebx)

    #将[KERNEL_BASE,KERNEL_BASE+4MB]映射到[0,4MB]，有写权限
    movl $KERNEL_BASE,%ecx
    shr $PDE_SHIFT,%ecx
    leal (%ebx,%ecx,4),%ebx
    orl $PT_W,%eax
    movl %eax,(%ebx)

    #############################################
    #初始化页表（临时使用）
    #############################################
    #分配映射到[0,4MB]的物理页
    movl $PTE_NUMBER,%ecx
    movl $KERNEL_TO_PHY(entry_page_table),%ebx
    movl $0,%eax
    orl $(PT_P|PT_W),%eax
lo:
    movl %eax,(%ebx)
    addl $0x1000,%eax
    addl $0x04,%ebx
    loop lo

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

    ################################################
    #虚拟内存已经打开，完成部分初始化后移交c函数处理
    ################################################

next:
    movb $'H',(KERNEL_BASE+0xb8000)
    movb $0x07,(KERNEL_BASE+0xb8001)


    #不知道为什么，，直接call会出错，用jmp就没事
    jmp main

spin:
	jmp spin


###################################################
#该段定义一个临时的页表
.data
.align PAGE_SIZE

#临时的页目录
entry_page_dir:
    .space PAGE_SIZE

#临时的页表
entry_page_table:
    .space PAGE_SIZE

