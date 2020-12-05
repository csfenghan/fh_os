
extern bootmain
global boot_start

gdt_base equ 0x7e00
gdt_config equ 0x7f00
[bits 16]
boot_start:
	cli    ;关闭中断
	
	;对寄存器清零
	xor ax,ax
	mov ds,ax
	mov ss,ax
	mov fs,ax
	mov gs,ax

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
	;mov ss,ax
	;mov fs,ax
	;mov gs,ax
	;mov es,ax
	;mov esp,0x7c00
	mov byte [0xb8000],"A"
	mov byte [0xb8001],0x07
	mov byte [0xb8002],"!"
	mov byte [0xb8003],0x07
		
	;call bootmain

spin:jmp $		

