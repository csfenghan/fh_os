#ifndef FH_OS_MMU_H
#define FH_OS_MMU_H

/*
    这个文件定义了内核的内存布局和mmu的相关信息
*/


/*内核布局的定义*/
//定义页信息
#define PAGE_SIZE 4096  //页大小
#define PAGE_EXTEND_SIZE 0x400000   //超级页大小4MB
#define PTE_NUMBER 1024 //一页的PTE数目

//内核的基地址
#define KERNEL_BASE 0xf0000000  

//基础的可用内存为0~640K
#define BASE_MEM_LIMIT 0xA0000

//内核栈的大小
#define KERNEL_STACK_SIZE (10*PAGE_SIZE)

//内核虚拟地址与实际物理地址的映射
#define KERNEL_TO_PHY(vaddr) ((vaddr)-KERNEL_BASE)
#define PHY_TO_KERNEL(paddr) ((paddr)+KERNEL_BASE)

///////////////////////////////////////////////////////////////////

/*下面定义的是mmu的信息*/
//虚拟地址中的分段
#define PD_INDEX_SHIFT 22 //page directory的偏移
#define PT_INDEX_SHIFT 12 //page table的偏移

//虚拟地址中的page directory index和page table index
#define PD_INDEX(addr) ((addr)>>PD_INDEX_SHIFT)
#define PT_INDEX(addr) (((addr)>>PT_INDEX_SHIFT)&(0xfffffc00))

//PDE和PTE中的保存的地址项
#define PDE(pde) ((pde)&(0xfffff000))
#define PTE(pte) ((pte)&(0xfffff000))

//以下是x86的PDE和PTE的位的定义(简称PT(Page Table))
#define PT_P 0x01   //present
#define PT_W 0x02   //writable
#define PT_U 0x04   //user
#define PT_WT 0x08  //write through
#define PT_CD 0x10  //cache disable(不清楚什么功能)
#define PT_A 0x20    //accessed(不清楚。。。)
#define PT_D 0x40   //dirty(只有在二级目录才有脏位，一级页目录该位无效)
#define PT_PS 0x80  //在页目录里面表示page size，如果设置，则表示该页是4MB
#define PT_G 0x100  //gobal page

//寄存器设置
#define CR4_PSE 0x10    //开启4MB超级页

#endif
