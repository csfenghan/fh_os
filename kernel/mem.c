/*
    本文件负责内存的初始化，分配管理物理内存等
*/

#include <include/types.h>
#include <include/mmu.h>
#include <kernel/mem.h>

/*
内存布局自下向上为：
    1.代码段
    2.数据段（其顶部包括栈）
    3.经过一个页对其后，接下是内核的页目录(kernel_page_dir)
    4.该位置保存物理页信息，即一个struct phy_page_info的数组
*/

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

extern void print(char *);
extern char kernel_end[];   //定义在kernel.ld中
static char *next_free=(char *)kernel_end;   //指向先一个空闲的地址

//////////////////////////////////////////////////////////////////
//从struct page_info转换到对应的物理页地址
#define PAGE_INFO_TO_PHY(page_info)   \
    ((paddr_t)(((struct phy_page_info *)page_info-free_page_head)*PAGE_SIZE))
   
//得到物理地址对应的struct page_info结构
#define PHY_TO_PAGE_INFO(paddr)     \
    ((struct phy_page_info *)((paddr_t *)paddr/PAGE_SIZE+free_page_head))


//检测实际可使用的物理内存大小
static void detect_mem_size()
{
    number_pages=1024*256;  //先假设1G的空间
}

//使用新的页表
static void kernel_pgdir_init()
{
    kernel_pgdir=(pde_t *)ROUND_UP((char *)kernel_end,PAGE_SIZE);
    kernel_end[KERNEL_BASE>>PDE_SHIFT]=(0x00|PT_P|PT_W|PT_PS);  //映射到[0,4MB]，超级页
}

//function:初始化空闲链表
static void free_page_init()
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
                (i<(vaddr_t)KERNEL_TO_PHY(KERNEL_BASE+PAGE_EXTEND_SIZE)/PAGE_SIZE)){
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

//分配一个物理页
static struct phy_page_info*
phy_page_alloc()
{
    if(free_page_list->next==NULL){
        return NULL;
    } 
    struct phy_page_info *result;
    result=free_page_list->next;
    free_page_list->next=result->next;
    return result;
}

//释放一个物理页
static void phy_page_free(struct phy_page_info *page)
{
    if(page->link!=0){
        return;
    }
    page->next=free_page_list->next;
    free_page_list->next=page;
}

//根据虚拟地址查找对应的PTE(这里的物理页是4KB,只有内核代码数据才使用4MB)
//根据参数决定是否分配对应的PTE(create!=0时分配pte，否则只查询)
static pte_t*
look_up_pte(pde_t *pgdir,vaddr_t vaddr,char create)
{
    //如果对应的二级页存在
    pde_t *pde=PDE(vaddr);
    if((*pde)|PT_P){
        
    }

    //如果对应的二级页不存在，若create为真则创建，否则退出
    else{
        if(!create){
            return NULL;
        }

    }
    
}

//将起始为v_start，长度为len的虚拟地址空间映射到物理地址p_start处，其属性为config
void memory_map(pde_t* pgdir,vaddr_t v_start,size_t len,paddr_t p_start,uint32_t config)
{

}


//内存初始化
void mem_init()
{
    detect_mem_size();  //检测实际可用的内存大小
    kernel_pgdir_init();    //kernel的页表初始化
    free_page_init();   //空闲链表初始化
}