#include <string.h>
#include <stdio.h>

// localeconv
struct lconv *localeconv(void) {
    puts("localeconv is not implemented yet...\n");
    return NULL;
}

// strcoll
int strcoll(const char *s1, const char *s2) {
    return strcmp(s1, s2);
}

// setlocale
char *setlocale(int category, const char *locale) {
    puts("setlocale is not implemented yet...\n");
    return NULL;
}

// signal
void (*signal(int sig, void (*func)(int)))(int) {
    return func;
}
