################################################
#打印字符串
################################################
#include <include/mmu.h>

.global print

#define COLS 80
#define ROWS 25
#define MAX_NUMBER (COLS*ROWS)
#define BASE (KERNEL_BASE+0xb8000)

.text
print:
    pushl %ebx
    pushl %ebp

    #第一个参数
    movl 0xc(%esp),%edi
    #第二个参数
    movl $(BASE),%ebp

show:
    movb (%edi),%al
    cmpb %al,'\0'
    jz end

    #bx保存基址
    movl (curr_point),%ebx;
    leal (%ebp,%ebx,2),%edx
    movb $0x07,%ah
    movw %ax,(%edx) 

    incl %edi
    incl %ebx
    movl %ebx,(curr_point)
    jmp show

end:
    popl %ebp
    popl %ebx
    ret

####################################3
.data

curr_point:
    .long 0x00

