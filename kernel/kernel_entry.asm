extern main

global kernel_entry
kernel_entry:
    times 10 nop
    call main

jmp $
