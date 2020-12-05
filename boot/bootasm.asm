
extern bootmain
global boot_start
gdt_base equ 0x7e00
gdt_config equ 0x7f00

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
	mov dword [gdt_base+4],0x00		

	;代码段描述符
	mov dword [gdt_base+8],0x0000ffff
	mov dword [gdt_base+12],0x00cf9a00

	;数据段描述符
	mov dword [gdt_base+16],0x0000ffff
	mov dword [gdt_base+24],0x00cf9200

	mov word [gdt_config],23
	mov dword [gdt_config+2],gdt_base
	;加载gdt表，进入保护模式
	lgdt [cs:gdt_config]
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
		
	;call bootmain

spin:jmp $		

