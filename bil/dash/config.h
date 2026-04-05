// handmade config.h for profanOS, "dash 0.5.11.5"

// Define if __attribute__((__alias__())) is supported
#define HAVE_ALIAS_ATTRIBUTE

// Define to 1 if you have the <alloca.h> header file.
#define HAVE_ALLOCA_H 1

// Define if you have the `bsearch' function.
#define HAVE_BSEARCH

// Define to 1 if you have the declaration of `isblank' or to 0 if you don't.
#define HAVE_DECL_ISBLANK 0

// Define if you have the `faccessat' function.
#undef HAVE_FACCESSAT

// Define if you have the `fnmatch' function.
#undef HAVE_FNMATCH

// Define if you have the `getpwnam' function.
#undef HAVE_GETPWNAM

// Define if you have the `getrlimit' function.
#undef HAVE_GETRLIMIT

// Define if you have the `glob' function.
#undef HAVE_GLOB

// Define if you have the `isalpha' function.
#define HAVE_ISALPHA

// Define if you have the `killpg' function.
#undef HAVE_KILLPG

// Define if you have the `mempcpy' function.
#define HAVE_MEMPCPY

// Define if you have the <minix/config.h> header file.
#undef HAVE_MINIX_CONFIG_H

// Define if you have the <paths.h> header file.
#undef HAVE_PATHS_H

// Define if you have the `sigsetmask' function.
#undef HAVE_SIGSETMASK

// Define if you have the <stdint.h> header file.
#define HAVE_STDINT_H

// Define if you have the <stdio.h> header file.
#define HAVE_STDIO_H

// Define if you have the <stdlib.h> header file.
#define HAVE_STDLIB_H

// Define if you have the `stpcpy' function.
#define HAVE_STPCPY

// Define if you have the `strchrnul' function.
#define HAVE_STRCHRNUL

// Define if you have the `strsignal' function.
#define HAVE_STRSIGNAL

// Define if you have the `strtod' function.
#define HAVE_STRTOD

// Define if you have the `strtoimax' function.
#undef HAVE_STRTOIMAX

// Define if you have the `strtoumax' function.
#undef HAVE_STRTOUMAX

// Define if your `struct stat' has `st_mtim'
#undef HAVE_ST_MTIM

// Define if you have the `sysconf' function.
#define HAVE_SYSCONF

// Define if your faccessat tells root all files are executable
#undef HAVE_TRADITIONAL_FACCESSAT

// Define to printf format string for intmax_t
#define PRIdMAX "lld"

// Define if you build with -DSMALL
#define SMALL

// Define if you build with -DWITH_LINENO
#define WITH_LINENO 0

// Define to system shell path
#define _PATH_BSHELL "/bin/h/dash.elf"

// Define to devnull device node path
#define _PATH_DEVNULL "/dev/null"

// Define to tty device node path
#define _PATH_TTY "/dev/panda"

// Default prompt and prompt colors
#define CONFIG_DEFAULT_PS1  "\e[37m(\e[93mdash\e[37m in \e[97m$(pwd)\e[37m) $ \e[0m"

#define CONFIG_DEFAULT_PS2 "\e[97m> \e[0m"
#define CONFIG_DEFAULT_PS4 "\e[97m+ \e[0m"

// Misc
#define PATH_MAX 1023
#define NAME_MAX 255

#define EWOULDBLOCK EAGAIN
#define open64 open
#define vfork fork
