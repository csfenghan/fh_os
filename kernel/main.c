/*
    该文件负责完成内核的初始化工作
*/
#include <console.h>
#include <stdio.h>
#include <string.h>

int main() {
    extern char data_end[], kernel_end[];

    memset(data_end, 0, kernel_end - data_end);
    cons_init();
	cprintf("hello,fenghan\n");
    while (1)
        ;
}
