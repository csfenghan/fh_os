/*
    该函数用于在内核启动时生成一个临时的页表，供内核临时使用
*/

#include <include/types.h>
#include <include/mmu.h>

//页目录和页表的首地址都必须位于一个页的起始位置，因此必须4k对齐
pte_t entry_page_table[PTE_NUMBER];

//page directory table
__attribute__((__aligned__(PAGE_SIZE)))
pde_t entry_page_dir[PTE_NUMBER]={
    //将[0,4MB)映射到[0,4MB]
    [0]=KERNEL_TO_PHY((vaddr_t)entry_page_table)+PT_P,

    //将[KERNEL_BASE,KERNEL_BASE+4MB)映射到[0,4MB)
    [PDE(KERNEL_BASE)]=KERNEL_TO_PHY((vaddr_t)entry_page_table)+PT_P+PT_W,
};

//负责映射到[0,4MB)的page table
__attribute__((__aligned__(PAGE_SIZE)))
pte_t entry_page_table[PTE_NUMBER]={};

//该函数负责初始化entry_page_table
void entry_pgdir_init()
{
    paddr_t pa=0;
    for(uint32_t i=0;i<1024;i++){
        entry_page_table[i]=pa|PT_P|PT_W;
        pa+=0x1000;
    }
}