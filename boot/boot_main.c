/*
    1. 本文件负责读取内核的elf头，将内核加载至内存，并把控制权移交给内核
*/

#include "elf.h"
#include "io.h"

void ReadDisk(uint32_t sector,uint32_t paddr,uint8_t count);

void bootmain()
{
    Elf32_Header *elf_header;
    Elf32_Program_Header *program_header;

    /*这里有一个很奇怪的错误，如果吧ReadDisk中的elf_header换成0x7f00的话,
    则读取后elf_header->e_magic值为0x7f00？？然后就无法继续执行。明明
    elf_header的值就是0x7f00，这里有什么不一样吗？？*/

    /*把elf头加载到0x7f00处*/
    elf_header=(Elf32_Header *)0x7f00;
    ReadDisk(1,(uint32_t)elf_header,1);

    /*判断是否是elf文件*/
    if(elf_header->e_magic!=ELF_MAGIC){
        return;
    }

    program_header=(Elf32_Program_Header *)((void *)elf_header+elf_header->e_phoff);
    /*将kernel的各个程序段加载至对应的位置*/
    for(int i=0;i<elf_header->e_phnum;i++){
        /*因为内核文件的加载的段都是4k对齐的，因此可以直接加载*/
        uint32_t start_sector=(program_header[i].p_offset)/512+1;
        uint32_t paddr=program_header[i].p_paddr;
        uint8_t count=program_header[i].p_memsz/512+1;

        ReadDisk(start_sector,paddr,count);
    }

    /*终于要进去OS了！！*/
    ((void (*)(void)) (elf_header->e_entry))();
    
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
        入和写入数据。(note:不过不知道为什么这种方法&0x80!=0x08无法读取磁盘，最后还是用
        的&0xc0!=0x0来读取的，不知道为什么第3位恒为0)
        (5)0x1f1是错误寄存器，保存错误原因
*/
void ReadDisk(uint32_t sector,uint32_t paddr,uint8_t count)
{
    //为了省事，干脆就默认count小于255吧，反正内核也不会那么大
    while((inb(0x1f7)&0x80)!=0x0); //wait
    outb(0x1f2,count);
    outb(0x1f3,(uint8_t)(sector));
    outb(0x1f4,(uint8_t)(sector>>8));
    outb(0x1f5,(uint8_t)(sector>>16));
    //outb(0x1f6,(uint8_t)(((sector>>24)&0x0f)|0xe0));
    outb(0x1f6,(sector>>24)|0xe0);
    outb(0x1f7,0x20);
    while((inb(0x1f7)&0x80)!=0x0); //wait
    insw(0x1f0,(void *)paddr,count*256);
}
