/*内核链接控制*/

OUTPUT_FORMAT("elf32-i386","elf32-i386","elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(kernel_entry)

SECTIONS
{
	/*链接的起始地址，即VMA*/
	. =0xf0100000;
	PROVIDE(text_start = .);
	/*AT可以给定LMA地址*/
	.text :AT(0x100000) {
		*(.text .stub .text.* .gnu.linkonce.t.*)
   	 }

	PROVIDE(text_end = .);

	.rodata :{	
		*(.rodata .rodata.* .gnu.linkonce.r.*)
   	}

	/*加入debug信息*/
	.stab :{
		PROVIDE(__STAB_BEGIN__ = .);
		*(.stab)
		PROVIDE(__STAB_END__ = .);
	}

	.stabstr :{
		PROVIDE(__STABSTR_BEGIN__ = .);
		*(.stabstr)
		PROVIDE(__STABSTR_END__ = .);
	}

	/*使数据段页对齐*/
	. =ALIGN(0x1000);

	.data :{
		*(.data)
		/*这里给出data段的结尾,方便后续分配内存*/
 	}

    	.bss :{
		PROVIDE(data_end = .);
		*(.bss)
		PROVIDE(kernel_end = .);
	}

	/DISCARD/ :{
		*(.eh_frame .note.GUN-stack)
	}
}
