#ifndef FH_OS_ELF_H
#define FH_OS_ELF_H

#include "include/types.h"

//elf文件的magic
#define ELF_MAGIC 0x464c457f

//elf的文件头
typedef struct{
    uint32_t e_magic; 
    uint8_t e_elf[12];
    uint16_t e_type;
    uint16_t e_machine;
    uint32_t e_version;
    uint32_t e_entry;
    uint32_t e_phoff;
    uint32_t e_shoff;
    uint32_t e_flags;
    uint16_t e_ehsize;
    uint16_t e_phentsize;
    uint16_t e_phnum;
    uint16_t e_shentsize;
    uint16_t e_shnum;
    uint16_t e_shstrndx;
}Elf32_Header;

//elf的程序头表，记录加载的段的位置
typedef struct{
    uint32_t p_type;
    uint32_t p_offset;
    uint32_t p_vaddr;
    uint32_t p_paddr;
    uint32_t p_filesz;
    uint32_t p_memsz;
    uint32_t p_flags;
    uint32_t p_align;

}Elf32_Program_Header;

//

#endif
