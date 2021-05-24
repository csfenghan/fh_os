/*
    该文件负责完成内核的初始化工作
*/
#include <mem.h>

extern void print(char *);

static int test(){
	print("hello,nihao");
};

int main()
{
    mem_init();

	while(1);
}
