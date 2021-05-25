#include "include/types.h"

int strlen(const char *s) {
    int n;

    for (n = 0; *s != '\0'; s++)
        n++;
    return n;
}

int strnlen(const char *s, size_t size){
    int n;

    for(n=0;size>0&&*s!='\0';s++,size--)
        n++;
    return n;
}

char *strcpy(char *dst, const char *src){
    char *ret;

    ret = dst;
    while((*dst++ = *src++) != '\0');
    return ret;
}

char *strncpy(char *dst, const char *src, size_t size){
    char *ret;
    int i;

    ret=dst;
    for(i=0;i<size;i++){
        *dst++=*src;
        if(*src!='\0')
            src++;
    } 
    return ret;
}

char *strcat(char *dst, const char *src){
    int len;

    len = strlen(dst);
    strcpy(dst+len,src);
    return dst;
}

char *strncpy(char *dst, const char *src, size_t size){
    char *ret;

    ret=dst;
    if(size>0){
        while(size-->0 && *src!='\0'){
            *dst++=*src++;
        }
        *dst='\0';
    }
    return ret;
}

int strcmp(const char *s1, const char *s2){
    while(*s1 && *s1 == *s2){
        s1++,s2++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
}

int strncmp(const char *s1, const char *s2, size_t size){
    while(n > 0 && *s1 && *s1 == *s2){
        n--,s1++,s2++;
    }
    if(n==0)
        return 0;
    else
        return (int)((unsigned char)*s1 - (unsigned char)*s2);
}

char *strchr(const char *s, char c){
    for(;*s;s++){
        if(*s == c)
            return (char *)s;
    }
    return 0;
}
char *strfind(const char *s, char c);

void *memset(void *dst, int c, size_t len){
    
}

void *memcpy(void *dst, const void *src, size_t len);
void *memmove(void *dst, const void *src, size_t len);
int memcmp(const void *s1, const void *s2, size_t len);
void *memfind(const void *s, int c, size_t len);

long strtol(const char *s, char **endptr, int base);
