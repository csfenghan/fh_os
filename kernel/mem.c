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
    4.ROUND_UP(kernel_end)~    第一页保存内核的页目录，第二页开始第一个是free_page_list,
    从第2个开始每一个结构对应一个物理页
*/

void print(char *);
///////////////////////////////////////////////////////////////////
//空闲链表的节点，每一个物理页都有一个对应的结构
struct phy_page_info{
    struct phy_page_info *next; 
    uint32_t link;
};
static struct phy_page_info *free_page_head;   //空闲链表的头部,即第一个物理页
static struct phy_page_info *free_page_list;    //空闲链表，指向下一个空闲页
static pde_t *kernel_pgdir;    //内核页目录
static uint32_t number_pages;   //实际的物理页数目

extern char kernel_end[];   //定义在kernel.ld中
static char *next_free=(char *)kernel_end;   //指向先一个空闲的地址

//////////////////////////////////////////////////////////////////
//从struct page_info转换到对应的物理页地址
#define PAGE_INFO_TO_PHY(page_info)   \
({   \
    (paddr_t)(((struct phy_page_info *)page_info-free_page_head)*PAGE_SIZE);  \
})   \
   
//得到物理地址对应的struct page_info结构
#define PHY_TO_PAGE_INFO(paddr)     \
({  \
    (struct phy_page_info *)((paddr_t *)paddr/PAGE_SIZE+free_page_head);    \
})  \

//////////////////////////////////////////////////////////////////

//检测实际可使用的物理内存大小
static void detect_mem_size()
{
    number_pages=1024*256; 
}

//使用新的页表
void kernel_pgdir_init()
{
    kernel_pgdir=(pde_t *)ROUND_UP((char *)kernel_end,PAGE_SIZE);
}

//function:初始化空闲链表
void free_page_init()
{
    /*如果声明成extern char *kerenl_end，kernel_end的值则会被翻译成一个指针！！！
    但是如下声明则不会有错，声明成其他类型也是被当作一个指针，太奇怪了*/
    char *extend_start=(char *)(ROUND_UP((char *)kernel_end,PAGE_SIZE)+PAGE_SIZE); 

    free_page_list=(struct phy_page_info *)(extend_start+4);
    free_page_list->link=-1;
    free_page_list->next=NULL;
    free_page_head=(struct phy_page_info *)(extend_start+8);

    //初始化空闲链表，将已分配的页跳过(这些页将永不释放)
    /*因为一开始内核只被分配了4MB的内存，这些内存无法存储过大的物理页结构，因此先按1G来计算*/
    for(size_t i=0;i<number_pages;i++){
        if((i>BASE_MEM_LIMIT/PAGE_SIZE)&&
                (i<(vaddr_t)KERNEL_TO_PHY(free_page_head+number_pages)/PAGE_SIZE)){
            free_page_head[i].next=NULL; 
            free_page_head[i].link=-1;
        }
        else{
            free_page_head[i].next=free_page_list->next;
            free_page_head[i].link=0;
            free_page_list->next=&free_page_head[i];
        }
    }

}


//内存初始化
void mem_init()
{
    detect_mem_size();  //检测实际可用的内存大小
    free_page_init();   //空闲链表初始化
}