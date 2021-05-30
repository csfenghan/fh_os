#ifndef _ERROR_H
#define _ERROR_H

enum {
    // 内核的错误代码
    E_UNSPECIFIED = 1, // 未知错误
    E_BAD_ENV,         // 环境变量不存在或错误
    E_INVAL,           // 参数无效
    E_NO_MEM,          // 申请分配内存错误
    E_NO_FREE_ENV,     // 申请创建的内存超出了最大内存限制
    E_FAULT,           // 内存错误

    MAXERROR
};

#endif
