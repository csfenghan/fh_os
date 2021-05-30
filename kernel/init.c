/*
    该文件负责完成内核的初始化工作
*/
#include <console.h>
#include <stdio.h>
#include <string.h>
#include <mm.h>

int main() {
        extern char data_end[], kernel_end[];

        memset(data_end, 0, (size_t)kernel_end - (size_t)data_end); //清零bss段
        cons_init();                                                //输出初始化
	mem_init();
		
	cprintf("hello world\n");
	
        while (1)
                ;
}
