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
    4.kernel_end~                    [,]                这里保存物理页的分配信息
*/

void print(char *);
///////////////////////////////////////////////////////////////////
//空闲链表的节点，每一个物理页都有一个对应的结构
struct phy_page_info{
    struct phy_page_info *next; 
    uint32_t link;
};
static struct phy_page_info *free_page_head;   //空闲链表的头部
static struct phy_page_info *free_page_list;    //空闲链表的入口

//实际物理内存的页数，每页4kb
static uint32_t number_pages;

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
    number_pages=1024*1024; 
}

/*
    function:初始化空闲链表
*/
void free_page_init()
{
    extern uint32_t kernel_end;
    if(kernel_end==0xf010e01c){
        print("hello");
        while(1); 
    }
    free_page_list=(struct phy_page_info *)ROUND_UP(kernel_end,PAGE_SIZE); 
    free_page_list->link=-1;
    free_page_head=(struct phy_page_info *)((uint32_t)free_page_list+4);

    print("hello");
    //初始化空闲链表，将已分配的页跳过(这些页将永不释放)
    for(size_t i=1;i<number_pages;i++){
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
    detect_mem_size();
    free_page_init();

}