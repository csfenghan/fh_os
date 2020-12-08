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
    
    #该函数用于初始化页表，用于过渡时期使用(sp在BootLoader中设置好了，可以正常使用)
    call entry_pgdir_init

    #加载page table
    movl $(KERNEL_TO_PHY(entry_page_dir)),%eax
    movl %eax,%cr3

    #开启虚拟内存与写保护
    movl %cr0,%eax
    orl $0x10001,%eax
    movl %eax,%cr0

    #跳转到高地址执行
    movl $next,%eax
    jmp *%eax

next:
    movb $'H',(0xb8000)
    movb $0x07,(0xb8001)

    call main

spin:
	jmp spin
