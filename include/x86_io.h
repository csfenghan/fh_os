#ifndef FH_OS_X86_H
#define FH_OS_X86_H

/*
    本文件主要定义了x86的端口操作的封装，便于在c函数中调用
*/

#include "types.h"

static inline uint8_t
inb(int port)
{
    uint8_t data;
    __asm__ volatile("inb %w1,%0":"=a"(data):"d"(port));
    return data;
}

static inline void
insw(int port,void *addr,int cnt)
{
    __asm__ volatile("cld\n\t"
                    "repne\n\t"
                    "insw"
                    :"=D"(addr),"=c"(cnt)
                    :"d"(port),"0"(addr),"1"(cnt)
                    :"memory","cc");
}

static inline void
outb(int port,uint8_t data)
{
    __asm__ volatile("outb %0,%w1"::"a"(data),"d"(port));
}

static inline void
outsw(int port, const void *addr, int cnt)
{
    __asm__ volatile("cld\n\t"
                    "repne\n\t"
                    "outsw"
                    :"=S"(addr),"=c"(cnt)
                    :"d"(port),"0"(addr),"1"(cnt)
                    :"cc");
}





#endif
