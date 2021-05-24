################################################
#打印字符串
################################################
#include <x86/mmu.h>

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
    movl 0x10(%esp),%esi

    movl $(BASE),%ebp

show:
    movl (curr_point),%ebx;

    #取字符串，处理控制字符
    movb (%edi),%al
    cmpb %al,'\0'
    jz end

next:
    #bx保存基址
    leal (%ebp,%ebx,2),%edx
    movb $0x07,%ah
    movw %ax,(%edx) 

    #显示下一个字符
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

