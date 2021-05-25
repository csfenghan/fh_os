
kernel.elf:     file format elf32-i386


Disassembly of section .text:

f0100000 <kernel_start>:
kernel_start:
    ############################################
    #初始化页目录（临时使用）
    ############################################
    #开启4MB支持
    movl %cr4,%eax
f0100000:	0f 20 e0             	mov    %cr4,%eax
    orl $CR4_PSE,%eax
f0100003:	83 c8 10             	or     $0x10,%eax
    movl %eax,%cr4
f0100006:	0f 22 e0             	mov    %eax,%cr4

    movl $KERNEL_TO_PHY(entry_page_dir),%ebx
f0100009:	bb 00 20 10 00       	mov    $0x102000,%ebx
    
    #将[0,4MB]映射到[0,4MB]，没有写权限,开启超级页
    movl $(0x00|PT_P|PT_PS),%eax
f010000e:	b8 81 00 00 00       	mov    $0x81,%eax
    movl %eax,(%ebx)
f0100013:	89 03                	mov    %eax,(%ebx)

    #将[KERNEL_BASE,KERNEL_BASE+4MB]映射到[0,4MB]，开启超级页，每个页4MB
    movl $PD_INDEX(KERNEL_BASE),%edx
f0100015:	ba c0 03 00 00       	mov    $0x3c0,%edx
    leal (%ebx,%edx,4),%ebx
f010001a:	8d 1c 93             	lea    (%ebx,%edx,4),%ebx
    movl $(0x00|PT_W|PT_P|PT_PS),%eax
f010001d:	b8 83 00 00 00       	mov    $0x83,%eax
    movl %eax,(%ebx)
f0100022:	89 03                	mov    %eax,(%ebx)

    ################################################
    #加载cr3并开启虚拟内存和写保护
    ################################################
    #加载cr3
    movl $(KERNEL_TO_PHY(entry_page_dir)),%eax
f0100024:	b8 00 20 10 00       	mov    $0x102000,%eax
    movl %eax,%cr3
f0100029:	0f 22 d8             	mov    %eax,%cr3

    #开启虚拟内存与写保护
    movl %cr0,%eax
f010002c:	0f 20 c0             	mov    %cr0,%eax
    orl $0x80010001,%eax
f010002f:	0d 01 00 01 80       	or     $0x80010001,%eax
    movl %eax,%cr0
f0100034:	0f 22 c0             	mov    %eax,%cr0

    #跳转到高地址执行
    movl $next,%eax
f0100037:	b8 3e 00 10 f0       	mov    $0xf010003e,%eax
    jmp *%eax
f010003c:	ff e0                	jmp    *%eax

f010003e <next>:
    #############################################################
    #虚拟内存已经打开，这里打印一串消息,然后完成部分初始化后移交c函数处理
    #############################################################

next:
    movl 0x00,%ebp
f010003e:	8b 2d 00 00 00 00    	mov    0x0,%ebp
    movl $(KERNEL_STACK_TOP),%esp
f0100044:	bc 00 d0 10 f0       	mov    $0xf010d000,%esp
    
    #打印一串消息表示成功启动
    movl (len),%ecx
f0100049:	8b 0d 01 10 10 f0    	mov    0xf0101001,%ecx
    movl $(message),%ebx
f010004f:	bb 00 10 10 f0       	mov    $0xf0101000,%ebx
    movl $(PHY_TO_KERNEL(0xb8000)),%edx
f0100054:	ba 00 80 0b f0       	mov    $0xf00b8000,%edx

f0100059 <show>:

show:
    movb (%ebx),%al
f0100059:	8a 03                	mov    (%ebx),%al
    movb $0x07,%ah 
f010005b:	b4 07                	mov    $0x7,%ah
    movw %ax,(%edx)
f010005d:	66 89 02             	mov    %ax,(%edx)

    addl $0x01,%ebx
f0100060:	83 c3 01             	add    $0x1,%ebx
    addl $0x02,%edx
f0100063:	83 c2 02             	add    $0x2,%edx

    loop show
f0100066:	e2 f1                	loop   f0100059 <show>

    #不知道为什么，，直接call会出错，用jmp就没事
    call main
f0100068:	e8 02 00 00 00       	call   f010006f <main>

f010006d <spin>:

spin:
	jmp spin
f010006d:	eb fe                	jmp    f010006d <spin>

f010006f <main>:
    该文件负责完成内核的初始化工作
*/
#include <mem.h>

int main()
{
f010006f:	55                   	push   %ebp
f0100070:	89 e5                	mov    %esp,%ebp
f0100072:	53                   	push   %ebx
f0100073:	83 e4 f0             	and    $0xfffffff0,%esp
f0100076:	e8 0d 00 00 00       	call   f0100088 <__x86.get_pc_thunk.bx>
f010007b:	81 c3 85 cf 00 00    	add    $0xcf85,%ebx
    mem_init();
f0100081:	e8 07 00 00 00       	call   f010008d <mem_init>

	while(1);
f0100086:	eb fe                	jmp    f0100086 <main+0x17>

f0100088 <__x86.get_pc_thunk.bx>:
f0100088:	8b 1c 24             	mov    (%esp),%ebx
f010008b:	c3                   	ret    

f010008c <memory_map>:

//将起始为v_start，长度为len的虚拟地址空间映射到物理地址p_start处，其属性为config
void memory_map(pde_t* pgdir,vaddr_t v_start,size_t len,paddr_t p_start,uint32_t config)
{
     
}
f010008c:	c3                   	ret    

f010008d <mem_init>:


//内存初始化
void mem_init()
{
f010008d:	55                   	push   %ebp
f010008e:	89 e5                	mov    %esp,%ebp
f0100090:	56                   	push   %esi
f0100091:	53                   	push   %ebx
f0100092:	e8 e5 00 00 00       	call   f010017c <__x86.get_pc_thunk.ax>
f0100097:	05 69 cf 00 00       	add    $0xcf69,%eax
    number_pages=1024*256;  //先假设1G的空间
f010009c:	c7 80 0c 00 00 00 00 	movl   $0x40000,0xc(%eax)
f01000a3:	00 04 00 
    kernel_pgdir=(pde_t *)ROUND_UP((char *)kernel_end,PAGE_SIZE);
f01000a6:	c7 c1 18 d0 10 f0    	mov    $0xf010d018,%ecx
f01000ac:	89 ca                	mov    %ecx,%edx
f01000ae:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01000b4:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
    kernel_end[PD_INDEX(KERNEL_BASE)]=(0x00|PT_P|PT_W|PT_PS);  //映射到[0,4MB]，超级页
f01000ba:	c6 81 c0 03 00 00 83 	movb   $0x83,0x3c0(%ecx)
    free_page_list=(struct phy_page_info *)(extend_start+4);
f01000c1:	8d 8a 04 20 00 00    	lea    0x2004(%edx),%ecx
f01000c7:	89 88 10 00 00 00    	mov    %ecx,0x10(%eax)
    free_page_list->link=-1;
f01000cd:	c7 83 08 10 00 00 ff 	movl   $0xffffffff,0x1008(%ebx)
f01000d4:	ff ff ff 
    free_page_list->next=NULL;
f01000d7:	c7 83 04 10 00 00 00 	movl   $0x0,0x1004(%ebx)
f01000de:	00 00 00 
    free_page_head=(struct phy_page_info *)(extend_start+8);
f01000e1:	81 c2 08 20 00 00    	add    $0x2008,%edx
f01000e7:	89 90 14 00 00 00    	mov    %edx,0x14(%eax)
    for(size_t i=0;i<number_pages;i++){
f01000ed:	89 d1                	mov    %edx,%ecx
f01000ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01000f4:	eb 22                	jmp    f0100118 <mem_init+0x8b>
            free_page_head[i].next=free_page_list->next;
f01000f6:	8b b3 04 10 00 00    	mov    0x1004(%ebx),%esi
f01000fc:	89 31                	mov    %esi,(%ecx)
            free_page_head[i].link=0;
f01000fe:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
            free_page_list->next=&free_page_head[i];
f0100105:	89 8b 04 10 00 00    	mov    %ecx,0x1004(%ebx)
    for(size_t i=0;i<number_pages;i++){
f010010b:	83 c0 01             	add    $0x1,%eax
f010010e:	83 c1 08             	add    $0x8,%ecx
f0100111:	3d ff ff 03 00       	cmp    $0x3ffff,%eax
f0100116:	77 25                	ja     f010013d <mem_init+0xb0>
        if((i>BASE_MEM_LIMIT/PAGE_SIZE)&&
f0100118:	8d b0 5f ff ff ff    	lea    -0xa1(%eax),%esi
f010011e:	81 fe 5e 03 00 00    	cmp    $0x35e,%esi
f0100124:	77 d0                	ja     f01000f6 <mem_init+0x69>
            free_page_head[i].next=NULL; 
f0100126:	c7 04 c2 00 00 00 00 	movl   $0x0,(%edx,%eax,8)
            free_page_head[i].link=-1;
f010012d:	c7 44 c2 04 ff ff ff 	movl   $0xffffffff,0x4(%edx,%eax,8)
f0100134:	ff 
    for(size_t i=0;i<number_pages;i++){
f0100135:	83 c0 01             	add    $0x1,%eax
f0100138:	83 c1 08             	add    $0x8,%ecx
f010013b:	eb db                	jmp    f0100118 <mem_init+0x8b>
    detect_mem_size();  //检测实际可用的内存大小
    kernel_pgdir_init();    //kernel的页表初始化
    free_page_init();   //空闲链表初始化
    pte_t *pte=look_up_pte(kernel_pgdir,KERNEL_BASE,0);

}
f010013d:	5b                   	pop    %ebx
f010013e:	5e                   	pop    %esi
f010013f:	5d                   	pop    %ebp
f0100140:	c3                   	ret    

f0100141 <test>:


////////////////////////////////////////////////////////////
//参考jos，对内存分配功能进行测试
int test()
{
f0100141:	e8 36 00 00 00       	call   f010017c <__x86.get_pc_thunk.ax>
f0100146:	05 ba ce 00 00       	add    $0xceba,%eax
    if(free_page_list->next==NULL){
f010014b:	8b 90 10 00 00 00    	mov    0x10(%eax),%edx
f0100151:	8b 02                	mov    (%edx),%eax
f0100153:	85 c0                	test   %eax,%eax
f0100155:	74 1e                	je     f0100175 <test+0x34>
    free_page_list->next=result->next;
f0100157:	8b 08                	mov    (%eax),%ecx
f0100159:	89 0a                	mov    %ecx,(%edx)
    result->next=NULL;
f010015b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(page->link!=0){
f0100161:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100165:	75 06                	jne    f010016d <test+0x2c>
    page->next=free_page_list->next;
f0100167:	8b 0a                	mov    (%edx),%ecx
f0100169:	89 08                	mov    %ecx,(%eax)
    free_page_list->next=page;
f010016b:	89 02                	mov    %eax,(%edx)

    //清空p1
    //这里存在一个问题，就是free之后p1指向的结构虽然被重新加入到了空闲链表中，但是
    //p1仍然指向该结构体，一旦被使用将会造成很大问题，因此需要手动将p1指向NULL
    phy_page_free(p1);
    assert(p1->next==free_page_list->next->next);
f010016d:	8b 12                	mov    (%edx),%edx
f010016f:	8b 0a                	mov    (%edx),%ecx
f0100171:	39 08                	cmp    %ecx,(%eax)
f0100173:	74 06                	je     f010017b <test+0x3a>
f0100175:	b8 00 00 00 00       	mov    $0x0,%eax

    //将空闲链表置空，不应该分配页面
    //free_page_list->next=NULL;
    //p1=phy_page_alloc();
    //assert(p1==NULL);
}
f010017a:	c3                   	ret    
f010017b:	c3                   	ret    

f010017c <__x86.get_pc_thunk.ax>:
f010017c:	8b 04 24             	mov    (%esp),%eax
f010017f:	c3                   	ret    
