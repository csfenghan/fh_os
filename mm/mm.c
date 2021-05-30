/*
    本文件负责内存的初始化，分配管理物理内存等
*/

#include <kclock.h>
#include <mm.h>
#include <stdio.h>
#include <string.h>
#include <types.h>
#include <x86_io.h>
#include <x86_memory_layout.h>

/*
内存布局自下向上为：
    1.代码段
    2.数据段（其顶部包括栈）
    3.经过一个页对其后，接下是内核的页目录(kernel_page_dir)
    4.该位置保存物理页信息，即一个struct page_info的数组
*/

/**********************************************************
 *	用于管理内存分配的全局变量
 *********************************************************/
static struct page_info *free_list_head; //空闲链表的头部,即第一个物理页
static struct page_info *free_list_ptr;  //当前的空闲链表入口，指向一个空闲页

static pde_t *kernel_pgdir; //内核页目录

static uint32_t base_pages;   //基础内存的页数
static uint32_t total_pages;  //全部内存的页数
static uint32_t base_memory;  //基础内存的实际大小
static uint32_t total_memory; //物理内存的实际大小

//将struct page_info转换成对应的物理页地址
#define PAGE_INFO_TO_PHY(pp) ((paddr_t)(((struct page_info *)pp - free_list_head) * PAGE_SIZE))

//得到物理地址对应的struct page_info结构
#define PHY_TO_PAGE_INFO(paddr) ((struct page_info *)(free_list_head + (uint32_t)paddr / PAGE_SIZE))

/*******************************************************
 *	内存管理函数
 ******************************************************/
// 获取可用的内存空间的大小
int nvram_read(int r) { return mc146818_read(r) | (mc146818_read(r + 1) << 8); }
void i386_detect_memory(void) {
        size_t basemem, extmem, ext16mem, totalmem;

        //读取CMOS芯片来获取可用内存大小
        basemem = nvram_read(NVRAM_BASELO);
        extmem = nvram_read(NVRAM_EXTLO);
        ext16mem = nvram_read(NVRAM_EXT16LO) * 64;

        // Calculate the number of physical pages available in both base
        // and extended memory.
        if (ext16mem)
                totalmem = 16 * 1024 + ext16mem;
        else if (extmem)
                totalmem = 1 * 1024 + extmem;
        else
                totalmem = basemem;

        base_pages = basemem / (PAGE_SIZE / 1024);
        total_pages = totalmem / (PAGE_SIZE / 1024);

        base_memory = 1024 * base_pages;
        total_memory = 1024 * total_pages;

        cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n", totalmem, basemem,
                totalmem - basemem);
}
// function:初始化空闲链表
static void free_page_init() {
        // 计算空闲链表占用的内存大小
        size_t nbytes;

        nbytes = ROUND_UP(total_pages * sizeof(struct page_info), PAGE_SIZE);
        free_list_head = (struct page_info *)(ROUND_UP((char *)kernel_pgdir, PAGE_SIZE));
        memset(free_list_head, 0, nbytes);

        // 初始化空闲链表，将已分配的页跳过(这些页将永不释放,主要是前1M的空洞内存和内核占用的部分内存)
        // 因为一开始内核只被分配了4MB的内存，因此将空闲链表的入口定在前4M，优先分配前4M内存
        free_list_ptr = NULL;
        for (int32_t i = total_pages - 1; i >= 1; i--) {
                if (i >= base_pages &&
                    i < KERNEL_TO_PHY((uint32_t)free_list_head + nbytes) / PAGE_SIZE) {
                        free_list_ptr[i].next = NULL;
                        free_list_ptr[i].link = 0;
                } else {
                        free_list_head[i].link = 0;
                        free_list_head[i].next = free_list_ptr;
                        free_list_ptr = &free_list_head[i];
                }
        }
}

//分配一个物理页
static struct page_info *page_alloc(int alloc_flags) {
        if (free_list_ptr == NULL)
                return NULL;

        struct page_info *result;

        result = free_list_ptr;
        free_list_ptr = free_list_ptr->next;

        result->next = NULL;
        if (alloc_flags & ALLOC_ZERO)
                memset((void *)PAGE_INFO_TO_PHY(result), 0, PAGE_SIZE);

        return result;
}

//释放一个物理页
static void page_free(struct page_info *page) {
        if (page->next != NULL || page->link != 0) {
                cprintf("page_free error! struct page_info is not empty\n");
                return;
        }
        page->next = free_list_ptr;
        free_list_ptr = page;
}

// 根据虚拟地址查询对应的PTE,当create=1时分配对应的PTE
static pte_t *look_up_pte(pde_t *pgdir, vaddr_t va, char create) {
        if (pgdir == NULL)
                return NULL;

        pde_t *page_dir;
        pte_t *page_table;

        page_dir = &pgdir[PD_INDEX(va)];
        //如果二级目录项不存在，则根据create标志决定是否分配
        if (!(*page_dir & PT_P)) {
                if (create) {
                        struct page_info *page = page_alloc(ALLOC_ZERO);
                        *page_dir = PAGE_INFO_TO_PHY(page) | PT_P | PT_W | PT_U;
                        page_table = (pte_t *)PHY_TO_KERNEL(PAGE_INFO_TO_PHY(
                            page)); //这是二级页表的虚拟地址，注意二级页表实际保存的地址是物理地址
                } else {
                        return NULL;
                }
        } else {
                page_table = (pte_t *)PHY_TO_KERNEL(PDE(*page_dir));
        }
        return &page_table[PT_INDEX(va)];
}

//将起始为v_start，长度为len的虚拟地址空间映射到物理地址p_start处，其属性为perm
//地址都是已经对齐的
void memory_map(pde_t *pgdir, vaddr_t va, size_t len, paddr_t pa, uint32_t perm) {

        for (size_t n = 0; n <= len; n += PAGE_SIZE) {
                pte_t *pte = look_up_pte(pgdir, va, 1);
                *pte = pa | PT_P | perm;
                va += PAGE_SIZE;
                pa += PAGE_SIZE;
        }
}

//内存初始化
void mem_init() {
        //内核内存的边界，定义在kernel.ld中
        extern char kernel_end[];
        extern uint32_t KERNEL_STACK_BOTTOM;

        // 1.检测内存大小
        i386_detect_memory();

        // 2.从kernel_end的上对齐边界开始，第一个页存放页表的一级目录
        // 将USER_PAGE_TABLE映射到kernel_pgdir的物理地址上，这样可以通过USER_PAGE_TABLE访问内核页表
        kernel_pgdir = (pde_t *)ROUND_UP((char *)kernel_end, PAGE_SIZE);
        memset(kernel_pgdir, 0, PAGE_SIZE);
        kernel_pgdir[PD_INDEX(USER_PAGE_TABLE)] = (pde_t)KERNEL_TO_PHY(kernel_pgdir) | PT_U | PT_P;

        // 3.第二个页开始，存放一个struct page_info数组
        free_page_init(); //空闲链表初始化

        // 4.将物理内存映射到内和空间，即[0,实际物理内存大小]-->[KERNEL_BASE,最大4G]
        // 因此，kernel最多只能支持256M内存
        memory_map(kernel_pgdir, KERNEL_BASE, total_memory, 0, PT_W);

        // 5.将struct
        // page_info数组映射到[USER_PAGE_INFO，]，使USER可读（不知道啥用，jos这么写，我也先这么弄了）
        memory_map(kernel_pgdir, USER_PAGE_INFO,
                   ROUND_UP(total_pages * sizeof(struct page_info), PAGE_SIZE),
                   (paddr_t)KERNEL_TO_PHY(free_list_head), PT_U);

        // 6. 将内核栈映射到[UKERNEL_STACK_TOP-KERNEL_STACK_SIZE，]的位置，用户无权限
        memory_map(kernel_pgdir, UKERNEL_STACK_TOP - KERNEL_STACK_SIZE, KERNEL_STACK_SIZE,
                   KERNEL_TO_PHY(KERNEL_STACK_BOTTOM), PT_W);

        // 7.加载新的页表
        lcr3((uint32_t)KERNEL_TO_PHY(kernel_pgdir));

        cprintf("memory init done\n");
}

////////////////////////////////////////////////////////////
//参考jos，对内存分配功能进行测试
int test() {
        struct page_info *p1, *p2, *p3;

        //清空p1
        //这里存在一个问题，就是free之后p1指向的结构虽然被重新加入到了空闲链表中，但是
        // p1仍然指向该结构体，一旦被使用将会造成很大问题，因此需要手动将p1指向NULL
        // page_free(p1);
        // assert(p1->next == free_page_list->next->next);
        // p1 = NULL;

        //将空闲链表置空，不应该分配页面
        // free_page_list->next=NULL;
        // p1=page_alloc();
        // assert(p1==NULL);
}
