#ifndef _MEMORY_H
#define _MEMORY_H

#include <types.h>


struct page_info {
        struct page_info *next; //指向下一个空闲的物理页
        uint32_t link;              //当前物理页的引用计数
};
#define ALLOC_ZERO 1	//一旦定义，则分配的物理页的内容会被初始化为0

void mem_init();


#endif
