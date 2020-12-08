#ifndef FH_OS_MMU_H
#define FH_OS_MMU_H

/*
    这个文件定义了内核的内存布局和mmu的相关信息
*/


/*内核布局的定义*/
//内核的基地址
#define KERNEL_BASE 0xf0000000  

//给出从内核空间和物理空间的变换
#define KERNEL_TO_PHY(addr) ((addr)-KERNEL_BASE)
#define PHY_TO_KERNEL(addr) ((addr)+KERNEL_BASE)

//定义页信息
#define PAGE_SIZE 4096  //页大小
#define PTE_NUMBER 1024 //一页的PTE数目

/*下面定义的是mmu的信息*/
//以下是x86的PDE和PTE的位的定义(简称PT(Page Table))
#define PT_P 0x01   //present
#define PT_W 0x02   //writable
#define PT_U 0x04   //user
#define PT_WT 0x08  //write through
#define PT_CD 0x10  //cache disable(不清楚什么功能)
#define PT_A 0x20    //accessed(不清楚。。。)
#define PT_D 0x40   //dirty(只有在二级目录才有脏位，一级页目录该位无效)
#define PT_PS 0x80  //在页目录里面表示page size，在页表(PTE)中是page table attribute index
#define PT_G 0x100  //gobal page

//virtual address分段
#define PDE_SHIFT 22 //page directory的偏移
#define PTE_SHIFT 12 //page table的偏移

#define PDE(addr) ((addr)>>PDE_SHIFT)
#define PTE(addr) ((addr)>>PTE_SHIFT)

//控制寄存器的位


#endif