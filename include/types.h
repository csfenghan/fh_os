#ifndef FH_OS_TYPES_H
#define FH_OS_TYPES_H

/*
    该文件定义了用到的各种类型
*/

//基本数据类型
typedef char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned int uint32_t;

//vaddr_t一般指虚拟地址，paddr_t一般指物理内存地址
typedef uint32_t vaddr_t;
typedef uint32_t paddr_t;

//mmu用到的一些定义
typedef uint32_t pde_t;
typedef uint32_t pte_t;

#endif