/*
    1. 本文件负责读取内核的elf头，将内核加载至内存，并把控制权移交给内核
*/

#include "include/elf.h"
#include "include/x86.h"

void LoadDisk(uint32_t sector,uint32_t paddr,uint8_t count);

int bootmain()
{
	while(1);
		
}


/*
    功能：从硬盘中读取数据
        sector:逻辑扇区号
        paddr:要加载到的内存位置
        count:读取的扇区数量
    注：
        (1)intel早期io采用独立编制，因此可以使用IO命令对其进行访问。主磁盘的地址
        为0x1f0~0x1f7，扇区编制方法采用LBA28，即使用28位来表示逻辑扇区号。
        (2)0x1f2存放读取的扇区数量，0xf13~0x1f6保存读取的扇区号，其中0x1f6的高
        4位用于CHS、LBA模式的选择和主从硬盘的选择。
        (3)向0x1f7写入0x20表示读硬盘，写入0x30表示写硬盘。同时，0x1f7还是状态端
        口，其第7位为1表示硬盘忙，第3位为1表示硬盘已经准备就绪
        (4)0x1f0是硬盘的数据端口，这是一个16位的端口，可以连续的从这个端口读
        入和写入数据。
        (5)0x1f1是错误寄存器，保存错误原因
*/
void ReadDisk(uint32_t sector,uint32_t paddr,uint8_t count)
{
    //为了省事，干脆就默认count小于255吧，反正内核也不会那么大
    while((inb(0x1f7)&0x88)!=0x08); //wait
    outb(0x1f2,count);
    outb(0x1f3,(uint8_t)(sector));
    outb(0x1f4,(uint8_t)(sector>>8));
    outb(0x1f5,(uint8_t)(sector>>16));
    outb(0x1f6,(uint8_t)(((sector>>24)&0x0f)|0xe0));
    while((inb(0x1f7)&0x88)!=0x08); //wait
    insw(0x1f0,(void *)paddr,count*32);
}
