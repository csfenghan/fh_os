
extern bootmain
global boot_start

;gdt的起始地址在0x7e00处
gdt_base equ 0x7e00

;lgdt的参数保存在0x7f00处
gdt_config equ 0x7f00

;一定要加，否则在生成32位的elf文件后会导致莫名其妙的错误！
[bits 16]

global boot_start
boot_start:

	;对寄存器清零
	xor ax,ax
	mov ds,ax
	mov ss,ax
	mov fs,ax
	mov gs,ax

	;清一下屏幕
	mov ax,0x600
	mov bx,0x700
	mov cx,0
	mov dx,0x184f
	int 0x10

	;开启A20端口
    in al,0x92                      
    or al,0000_0010B
    out 0x92,al                 

	;设置gdt表
	;空描述符
	mov dword [gdt_base],0x00		
	mov dword [gdt_base+0x04],0x00		

	;代码段描述符
	mov dword [gdt_base+0x08],0x0000ffff
	mov dword [gdt_base+0x0c],0x00cf9a00

	;数据段描述符
	mov dword [gdt_base+0x10],0x0000ffff
	mov dword [gdt_base+0x14],0x00cf9200

	mov word [gdt_config],0x17
	mov dword [gdt_config+2],gdt_base

	;加载gdt表，进入保护模式
	cli    ;关闭中断
	lgdt [gdt_config]
	mov eax,cr0
	or eax,0x01
	mov cr0,eax

	jmp dword 0x08:protect_mode_start
	
[bits 32]
protect_mode_start:
	
	;设置选择子
	mov ax,0x10
	mov ds,ax
	mov ss,ax
	mov fs,ax
	mov gs,ax
	mov es,ax
	mov esp,0x7c00
		
	;调用c函数进行下一步任务	
	call bootmain

	mov byte [0xb8000],'E'
	mov byte [0xb8001],0x7
	mov byte [0xb8002],'R'
	mov byte [0xb8003],0x7
	mov byte [0xb8004],'R'
	mov byte [0xb8005],0x7
	mov byte [0xb8006],'O'
	mov byte [0xb8007],0x7
	mov byte [0xb8008],'R'
	mov byte [0xb8009],0x7
	mov byte [0xb800a],'!'
	mov byte [0xb800b],0x7

spin:jmp $		

