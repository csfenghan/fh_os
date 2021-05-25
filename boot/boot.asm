
boot.elf:     file format elf32-i386


Disassembly of section .text:

00007c00 <boot_start>:
    7c00:	31 c0                	xor    %eax,%eax
    7c02:	8e d8                	mov    %eax,%ds
    7c04:	8e d0                	mov    %eax,%ss
    7c06:	8e e0                	mov    %eax,%fs
    7c08:	8e e8                	mov    %eax,%gs
    7c0a:	b8 00 06 bb 00       	mov    $0xbb0600,%eax
    7c0f:	07                   	pop    %es
    7c10:	b9 00 00 ba 4f       	mov    $0x4fba0000,%ecx
    7c15:	18 cd                	sbb    %cl,%ch
    7c17:	10 e4                	adc    %ah,%ah
    7c19:	92                   	xchg   %eax,%edx
    7c1a:	0c 02                	or     $0x2,%al
    7c1c:	e6 92                	out    %al,$0x92
    7c1e:	66 c7 06 00 7e       	movw   $0x7e00,(%esi)
    7c23:	00 00                	add    %al,(%eax)
    7c25:	00 00                	add    %al,(%eax)
    7c27:	66 c7 06 04 7e       	movw   $0x7e04,(%esi)
    7c2c:	00 00                	add    %al,(%eax)
    7c2e:	00 00                	add    %al,(%eax)
    7c30:	66 c7 06 08 7e       	movw   $0x7e08,(%esi)
    7c35:	ff                   	(bad)  
    7c36:	ff 00                	incl   (%eax)
    7c38:	00 66 c7             	add    %ah,-0x39(%esi)
    7c3b:	06                   	push   %es
    7c3c:	0c 7e                	or     $0x7e,%al
    7c3e:	00 9a cf 00 66 c7    	add    %bl,-0x3899ff31(%edx)
    7c44:	06                   	push   %es
    7c45:	10 7e ff             	adc    %bh,-0x1(%esi)
    7c48:	ff 00                	incl   (%eax)
    7c4a:	00 66 c7             	add    %ah,-0x39(%esi)
    7c4d:	06                   	push   %es
    7c4e:	14 7e                	adc    $0x7e,%al
    7c50:	00 92 cf 00 c7 06    	add    %dl,0x6c700cf(%edx)
    7c56:	00 7f 17             	add    %bh,0x17(%edi)
    7c59:	00 66 c7             	add    %ah,-0x39(%esi)
    7c5c:	06                   	push   %es
    7c5d:	02 7f 00             	add    0x0(%edi),%bh
    7c60:	7e 00                	jle    7c62 <boot_start+0x62>
    7c62:	00 fa                	add    %bh,%dl
    7c64:	0f 01 16             	lgdtl  (%esi)
    7c67:	00 7f 0f             	add    %bh,0xf(%edi)
    7c6a:	20 c0                	and    %al,%al
    7c6c:	66 83 c8 01          	or     $0x1,%ax
    7c70:	0f 22 c0             	mov    %eax,%cr0
    7c73:	66 ea 7b 7c 00 00    	ljmpw  $0x0,$0x7c7b
    7c79:	08 00                	or     %al,(%eax)

00007c7b <protect_mode_start>:
    7c7b:	66 b8 10 00          	mov    $0x10,%ax
    7c7f:	8e d8                	mov    %eax,%ds
    7c81:	8e d0                	mov    %eax,%ss
    7c83:	8e e0                	mov    %eax,%fs
    7c85:	8e e8                	mov    %eax,%gs
    7c87:	8e c0                	mov    %eax,%es
    7c89:	bc 00 7c 00 00       	mov    $0x7c00,%esp
    7c8e:	e8 c8 00 00 00       	call   7d5b <bootmain>
    7c93:	c6 05 00 80 0b 00 45 	movb   $0x45,0xb8000
    7c9a:	c6 05 01 80 0b 00 07 	movb   $0x7,0xb8001
    7ca1:	c6 05 02 80 0b 00 52 	movb   $0x52,0xb8002
    7ca8:	c6 05 03 80 0b 00 07 	movb   $0x7,0xb8003
    7caf:	c6 05 04 80 0b 00 52 	movb   $0x52,0xb8004
    7cb6:	c6 05 05 80 0b 00 07 	movb   $0x7,0xb8005
    7cbd:	c6 05 06 80 0b 00 4f 	movb   $0x4f,0xb8006
    7cc4:	c6 05 07 80 0b 00 07 	movb   $0x7,0xb8007
    7ccb:	c6 05 08 80 0b 00 52 	movb   $0x52,0xb8008
    7cd2:	c6 05 09 80 0b 00 07 	movb   $0x7,0xb8009
    7cd9:	c6 05 0a 80 0b 00 21 	movb   $0x21,0xb800a
    7ce0:	c6 05 0b 80 0b 00 07 	movb   $0x7,0xb800b

00007ce7 <spin>:
    7ce7:	eb fe                	jmp    7ce7 <spin>

00007ce9 <ReadDisk>:
        入和写入数据。(note:不过不知道为什么这种方法&0x80!=0x08无法读取磁盘，最后还是用
        的&0xc0!=0x0来读取的，不知道为什么第3位恒为0)
        (5)0x1f1是错误寄存器，保存错误原因
*/
void ReadDisk(uint32_t sector,uint32_t paddr,uint8_t count)
{
    7ce9:	55                   	push   %ebp
    7cea:	89 e5                	mov    %esp,%ebp
    7cec:	57                   	push   %edi
    7ced:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cf0:	56                   	push   %esi

static inline uint8_t
inb(int port)
{
    uint8_t data;
    __asm__ volatile("inb %w1,%0":"=a"(data):"d"(port));
    7cf1:	be f7 01 00 00       	mov    $0x1f7,%esi
    7cf6:	53                   	push   %ebx
    7cf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
    7cfa:	89 f2                	mov    %esi,%edx
    7cfc:	ec                   	in     (%dx),%al
    //为了省事，干脆就默认count小于255吧，反正内核也不会那么大
    while((inb(0x1f7)&0x80)!=0x0); //wait
    7cfd:	84 c0                	test   %al,%al
    7cff:	78 f9                	js     7cfa <ReadDisk+0x11>
    outb(0x1f2,count);
    7d01:	0f b6 cb             	movzbl %bl,%ecx
}

static inline void
outb(int port,uint8_t data)
{
    __asm__ volatile("outb %0,%w1"::"a"(data),"d"(port));
    7d04:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7d09:	89 d8                	mov    %ebx,%eax
    7d0b:	ee                   	out    %al,(%dx)
    7d0c:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7d11:	89 f8                	mov    %edi,%eax
    7d13:	ee                   	out    %al,(%dx)
    outb(0x1f3,(uint8_t)(sector));
    outb(0x1f4,(uint8_t)(sector>>8));
    7d14:	89 f8                	mov    %edi,%eax
    7d16:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7d1b:	c1 e8 08             	shr    $0x8,%eax
    7d1e:	ee                   	out    %al,(%dx)
    outb(0x1f5,(uint8_t)(sector>>16));
    7d1f:	89 f8                	mov    %edi,%eax
    7d21:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7d26:	c1 e8 10             	shr    $0x10,%eax
    7d29:	ee                   	out    %al,(%dx)
    //outb(0x1f6,(uint8_t)(((sector>>24)&0x0f)|0xe0));
    outb(0x1f6,(sector>>24)|0xe0);
    7d2a:	89 f8                	mov    %edi,%eax
    7d2c:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7d31:	c1 e8 18             	shr    $0x18,%eax
    7d34:	83 c8 e0             	or     $0xffffffe0,%eax
    7d37:	ee                   	out    %al,(%dx)
    7d38:	b0 20                	mov    $0x20,%al
    7d3a:	89 f2                	mov    %esi,%edx
    7d3c:	ee                   	out    %al,(%dx)
    __asm__ volatile("inb %w1,%0":"=a"(data):"d"(port));
    7d3d:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7d42:	ec                   	in     (%dx),%al
    outb(0x1f7,0x20);
    while((inb(0x1f7)&0x80)!=0x0); //wait
    7d43:	84 c0                	test   %al,%al
    7d45:	78 fb                	js     7d42 <ReadDisk+0x59>
    insw(0x1f0,(void *)paddr,count*256);
    7d47:	c1 e1 08             	shl    $0x8,%ecx
    __asm__ volatile("cld\n\t"
    7d4a:	8b 7d 0c             	mov    0xc(%ebp),%edi
    7d4d:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7d52:	fc                   	cld    
    7d53:	f2 66 6d             	repnz insw (%dx),%es:(%edi)
}
    7d56:	5b                   	pop    %ebx
    7d57:	5e                   	pop    %esi
    7d58:	5f                   	pop    %edi
    7d59:	5d                   	pop    %ebp
    7d5a:	c3                   	ret    

00007d5b <bootmain>:
{
    7d5b:	55                   	push   %ebp
    7d5c:	89 e5                	mov    %esp,%ebp
    7d5e:	56                   	push   %esi
    7d5f:	53                   	push   %ebx
    ReadDisk(1,(uint32_t)elf_header,1);
    7d60:	52                   	push   %edx
    7d61:	6a 01                	push   $0x1
    7d63:	68 00 7f 00 00       	push   $0x7f00
    7d68:	6a 01                	push   $0x1
    7d6a:	e8 7a ff ff ff       	call   7ce9 <ReadDisk>
    if(elf_header->e_magic!=ELF_MAGIC){
    7d6f:	83 c4 10             	add    $0x10,%esp
    7d72:	81 3d 00 7f 00 00 7f 	cmpl   $0x464c457f,0x7f00
    7d79:	45 4c 46 
    7d7c:	75 49                	jne    7dc7 <bootmain+0x6c>
    for(int i=0;i<elf_header->e_phnum;i++){
    7d7e:	a1 1c 7f 00 00       	mov    0x7f1c,%eax
    7d83:	31 f6                	xor    %esi,%esi
    7d85:	8d 98 00 7f 00 00    	lea    0x7f00(%eax),%ebx
    7d8b:	0f b7 05 2c 7f 00 00 	movzwl 0x7f2c,%eax
    7d92:	39 f0                	cmp    %esi,%eax
    7d94:	7e 25                	jle    7dbb <bootmain+0x60>
        ReadDisk(start_sector,paddr,count);
    7d96:	50                   	push   %eax
        uint8_t count=program_header[i].p_memsz/512+1;
    7d97:	8b 43 14             	mov    0x14(%ebx),%eax
    for(int i=0;i<elf_header->e_phnum;i++){
    7d9a:	46                   	inc    %esi
    7d9b:	83 c3 20             	add    $0x20,%ebx
        uint8_t count=program_header[i].p_memsz/512+1;
    7d9e:	c1 e8 09             	shr    $0x9,%eax
    7da1:	40                   	inc    %eax
        ReadDisk(start_sector,paddr,count);
    7da2:	0f b6 c0             	movzbl %al,%eax
    7da5:	50                   	push   %eax
    7da6:	ff 73 ec             	pushl  -0x14(%ebx)
        uint32_t start_sector=(program_header[i].p_offset)/512+1;
    7da9:	8b 43 e4             	mov    -0x1c(%ebx),%eax
    7dac:	c1 e8 09             	shr    $0x9,%eax
    7daf:	40                   	inc    %eax
        ReadDisk(start_sector,paddr,count);
    7db0:	50                   	push   %eax
    7db1:	e8 33 ff ff ff       	call   7ce9 <ReadDisk>
    for(int i=0;i<elf_header->e_phnum;i++){
    7db6:	83 c4 10             	add    $0x10,%esp
    7db9:	eb d0                	jmp    7d8b <bootmain+0x30>
}
    7dbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
    7dbe:	5b                   	pop    %ebx
    7dbf:	5e                   	pop    %esi
    7dc0:	5d                   	pop    %ebp
    ((void (*)(void)) (elf_header->e_entry))();
    7dc1:	ff 25 18 7f 00 00    	jmp    *0x7f18
}
    7dc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
    7dca:	5b                   	pop    %ebx
    7dcb:	5e                   	pop    %esi
    7dcc:	5d                   	pop    %ebp
    7dcd:	c3                   	ret    
