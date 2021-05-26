
#extern bootmain

#gdt的起始地址在0x7e00处
.set gdt_base,0x7e00

#lgdt的参数保存在0x7f00处
.set gdt_config,0x7f00

#一定要加，否则在生成32位的elf文件后会导致莫名其妙的错误！

.globl boot_start
.code16
boot_start:
	#关中断
	cli
	cld

	#对寄存器清零
    xorw    %ax,%ax             # Segment number zero
    movw    %ax,%ds             # -> Data Segment
    movw    %ax,%es             # -> Extra Segment
    movw    %ax,%ss 

	#清一下屏幕
	movw	$0x600,%ax
	movw	$0x700,%bx
	movw	$0,%cx
	movw	$0x184f,%dx
	int		$0x10

	#开启A20
	inb $0x92,%al
	or $0x02,%al
	outb %al,$0x92

	#设置gdt表
	#空描述符
	movl  $0x00,(gdt_base)
	movl $0x00,(gdt_base+0x04)

	#代码段描述符
	movl $0x0000ffff,(gdt_base+0x08)
	movl $0X00cf9a00,(gdt_base+0x0c)

	#数据段描述符
	movl $0x0000ffff,(gdt_base+0x10)
	movl $0x00cf9200,(gdt_base+0x14)

	movw $0x17,(gdt_config)
	movw $gdt_base,(gdt_config+2)

	#加载gdt表，进入保护模式
	cli
	lgdt (gdt_config)

	movl %cr0,%eax
	orl $0x01,%eax
	movl %eax,%cr0

	ljmp $0x08,$protect_mode_start
	
.code32
protect_mode_start:
	
	#设置选择子
	movw    $0x10,%ax
    movw    %ax, %ds                # -> DS: Data Segment
    movw    %ax, %es                # -> ES: Extra Segment
    movw    %ax, %fs                # -> FS
    movw    %ax, %gs                # -> GS
    movw    %ax, %ss                # -> SS: Stack Segment

    movl    $0x7c00, %esp	

	#调用c函数进行下一步任务	
	call bootmain

	#如果返回，则报错
	movb $'E',(0xb8000)
	movb $0x7,(0xb8001)
	movb $'R',(0xb8002)
	movb $0x7,(0xb8003)
	movb $'R',(0xb8004)
	movb $0x07,(0xb8005)
	movb $'O',(0xb8006)
	movb $0x07,(0xb8007)
	movb $'R',(0xb8008)
	movb $0x07,(0xb8009)
	movb $'!',(0xb800a)
	movb $0x07,(0xb800b)

spin:jmp spin		

