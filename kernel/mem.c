/*
    本文件负责内存的初始化，分配管理物理内存等
*/

#include <include/types.h>
#include <include/mmu.h>
#include <kernel/mem.h>

/*
内存布局为
        vaddr                   paddr                   description
    1.0xf0000000~0Xf0100000:    [0,1MB]
    2.0xf0100000~0Xf0101000:    [1MB,1MB+4KB]           内核代码段
    3.0xf0101000~kernel_end:    [1MB+4KB,kernel_end]    内核数据段,kernel_end由
                                                        链接器给出
    4.kernel_end~                    [,]                  这里保存物理页的分配信息
*/

//空闲链表的节点，每一个物理页都有一个对应的结构
struct phy_page_info{
    struct phy_page_info *next; 
    uint32_t link;
};
static struct phy_page_info *free_page_head;   //空闲链表的头部
static struct phy_page_info *free_page_list;    //空闲链表，指向下一个空闲页
static pde_t *kernel_pgdir;    //内核页目录

//实际物理内存的页数，每页4kb
static uint32_t number_pages;


//////////////////////////////////////////////////////////////////

//检测实际可使用的物理内存大小
static void detect_mem_size()
{
    number_pages=1024*1024; 
}

/*
    function:初始化空闲链表
        地址起始于ROUND_UP(kernel_end,PAGE_SIZE),前4个字节是free_page_list,
        然后从free_page_head开始，每个结构体对应一个物理页

*/
void free_page_init()
{
    extern char *kernel_end;    //内核的结尾位置，定义在kerenl.ld中

    free_page_list=ROUND_UP(kernel_end,PAGE_SIZE);
    free_page_list->link=-1;

    free_page_head=(struct phy_page_info *)((uint32_t)free_page_list+4);
    free_page_head[0].link=0;
    free_page_head[0].next=NULL;

    for(int i=1;i<number_pages;i++){
        free_page_head[i].link=0;
        free_page_head[i].next=&free_page_head[i-1];
        free_page_list->next=&free_page_head[i];
    }
}


//内存初始化
void mem_init()
{
    detect_mem_size();  //检测实际可使用的物理内存大小
    free_page_init();   //空闲链表初始化
}