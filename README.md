# fh_os
本来是打算跟着MIT6.828写一个内核玩玩，后来有事耽搁了就废弃了。实现的功能有开机启动、内存分配、以及一些基本的C库函数

## 运行
    $ sudo apt install gcc-multilib nasm qemu-system-x86
    $ git clone https://github.com/csfenghan/fh_os.git
    $ cd fh_os
    $ make
    $ make qemu
如果要调试的话运行
    $ make qemu-gdb
