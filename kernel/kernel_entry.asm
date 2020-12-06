extern main

;将入口的地址换算成物理地址后给出
global kernel_entry
kernel_entry equ kernel_start-0xf0000000

kernel_start:

    mov byte [0xb8000],'H'
	mov byte [0xb8001],0x7
	mov byte [0xb8002],'E'
	mov byte [0xb8003],0x7
	mov byte [0xb8004],'L'
	mov byte [0xb8005],0x7
	mov byte [0xb8006],'L'
	mov byte [0xb8007],0x7
	mov byte [0xb8008],'O'
	mov byte [0xb8009],0x7
	mov byte [0xb800a],'!'
	mov byte [0xb800b],0x7
	
    call main

jmp $
