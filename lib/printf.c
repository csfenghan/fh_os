
#include <stdarg.h>
#include <stdio.h>
#include <types.h>

void putch(int ch, int *cnt) {
        cputchar(ch);
        *cnt++;
}

int vcprintf(const char *fmt, va_list ap) {
        int cnt = 0;

        vprintfmt((void *)putch, &cnt, fmt, ap);
        return cnt;
}

int cprintf(const char *fmt, ...) {
        va_list ap;
        int cnt;

        va_start(ap, fmt);
        cnt = vcprintf(fmt, ap);
        va_end(ap);

        return cnt;
}
