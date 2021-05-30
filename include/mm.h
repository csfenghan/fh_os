#ifndef _MEMORY_H
#define _MEMORY_H

#include <types.h>

struct phy_page_info {
        struct phy_page_info *next; //指向下一个空闲的物理页
        uint32_t link;              //当前物理页的引用计数
};

void mem_init();


#endif
