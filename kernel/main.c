/*
    该文件负责完成内核的初始化工作
*/
#include <kernel/mem.h>

int main()
{
    mem_init();
    while (1);
}
