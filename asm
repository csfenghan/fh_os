
obj/boot/bootasm.o:     file format elf32-i386


Disassembly of section .text:

00000000 <boot_start>:
   0:	fa                   	cli    
   1:	66 31 c0             	xor    %ax,%ax
   4:	8e d8                	mov    %eax,%ds
   6:	8e d0                	mov    %eax,%ss
   8:	8e e0                	mov    %eax,%fs
   a:	8e e8                	mov    %eax,%gs
   c:	e4 92                	in     $0x92,%al
   e:	0c 02                	or     $0x2,%al
  10:	e6 92                	out    %al,$0x92
  12:	c7 05 00 7e 00 00 00 	movl   $0x0,0x7e00
  19:	00 00 00 
  1c:	c7 05 04 7e 00 00 00 	movl   $0x0,0x7e04
  23:	00 00 00 
  26:	c7 05 08 7e 00 00 ff 	movl   $0xffff,0x7e08
  2d:	ff 00 00 
  30:	c7 05 0c 7e 00 00 00 	movl   $0xcf9a00,0x7e0c
  37:	9a cf 00 
  3a:	c7 05 10 7e 00 00 ff 	movl   $0xffff,0x7e10
  41:	ff 00 00 
  44:	c7 05 18 7e 00 00 00 	movl   $0xcf9200,0x7e18
  4b:	92 cf 00 
  4e:	66 c7 05 00 7f 00 00 	movw   $0x17,0x7f00
  55:	17 00 
  57:	c7 05 02 7f 00 00 00 	movl   $0x7e00,0x7f02
  5e:	7e 00 00 
  61:	2e 0f 01 15 00 7f 00 	lgdtl  %cs:0x7f00
  68:	00 
  69:	0f 20 c0             	mov    %cr0,%eax
  6c:	83 c8 01             	or     $0x1,%eax
  6f:	0f 22 c0             	mov    %eax,%cr0
  72:	ea 79 00 00 00 08 00 	ljmp   $0x8,$0x79

00000079 <protect_mode_start>:
  79:	66 b8 10 00          	mov    $0x10,%ax
  7d:	8e d8                	mov    %eax,%ds

0000007f <spin>:
  7f:	eb fe                	jmp    7f <spin>
