
extern bootmain

[bits 16]
global boot_start
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
	mov ss,ax
	mov fs,ax
	mov gs,ax
	mov es,ax
	mov esp,0x7c00
		
	call bootmain

spin:jmp $		


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;gdt的设置
gdt:
	;空描述符
	dd 0x00
	dd 0x00

	;代码段描述符
	dd 0x0000ffff
	dd 0x00cf9a00

	;数据段描述符
	dd 0x0000ffff
	dd 0x00cf9200
gdt_config:
	dw gdt_config-gdt-1
	dd 0x7c00+gdt

