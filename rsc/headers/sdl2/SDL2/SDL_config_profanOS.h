/*
  Simple DirectMedia Layer
  Copyright (C) 1997-2024 Sam Lantinga <slouken@libsdl.org>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/

#ifndef SDL_config_profanOS_h_
#define SDL_config_profanOS_h_
#define SDL_config_h_

#include "SDL_platform.h"

/**
 *  \file SDL_config_minimal.h
 *
 *  This is the minimal configuration that can be used to build SDL.
 */
#ifdef __profanOS__
#define HAVE_STDARG_H   1
#define HAVE_STDDEF_H   1

#define HAVE_STDINT_H 1
#define HAVE_DLOPEN 1
#define HAVE_MALLOC 1
#define HAVE_CALLOC 1
#define HAVE_REALLOC    1
#define HAVE_FREE   1
#define HAVE_ALLOCA 1
#define HAVE_GETENV 1
#define HAVE_SETENV 1
#define HAVE_PUTENV 1
#define HAVE_SETENV 1
#define HAVE_UNSETENV   1
#define HAVE_QSORT  1
#define HAVE_BSEARCH 1
#define HAVE_ABS    1
#define HAVE_BCOPY  1
#define HAVE_MEMSET 1
#define HAVE_MEMCPY 1
#define HAVE_MEMMOVE    1
#define HAVE_MEMCMP 1
#define HAVE_STRLEN 1
#define HAVE_STRLCPY    1
#define HAVE_STRLCAT    1
#define HAVE_STRCHR 1
#define HAVE_STRRCHR    1
#define HAVE_STRSTR 1
#define HAVE_STRTOK_R 1
#define HAVE_STRTOL 1
#define HAVE_STRTOUL    1
#define HAVE_STRTOLL    1
#define HAVE_STRTOULL   1
#define HAVE_STRTOD 1
#define HAVE_ATOI   1
#define HAVE_ATOF   1
#define HAVE_STRCMP 1
#define HAVE_STRNCMP    1
#define HAVE_SETJMP 1
#define HAVE_MMAP 0
#define HAVE_ALLOCA 1
#define HAVE_FLOOR 1
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#ifdef __GNUC__
#define HAVE_GCC_SYNC_LOCK_TEST_AND_SET 1
#endif

/* Enable the dummy audio driver (src/audio/dummy/\*.c) */
#define SDL_AUDIO_DRIVER_DUMMY  0

/* Enable the stub joystick driver (src/joystick/dummy/\*.c) */
#define SDL_JOYSTICK_DISABLED   1

/* Enable the stub haptic driver (src/haptic/dummy/\*.c) */
#define SDL_HAPTIC_DISABLED 1

/* Enable the stub HIDAPI */
#define SDL_HIDAPI_DISABLED 1

/* Enable the stub sensor driver (src/sensor/dummy/\*.c) */
#define SDL_SENSOR_DISABLED 1

/* Enable the stub shared object loader (src/loadso/dummy/\*.c) */
#define SDL_LOADSO_DISABLED 1

/* Enable the stub thread support (src/thread/generic/\*.c) */
#define SDL_THREADS_DISABLED    1

/* Enable the stub timer support (src/timer/dummy/\*.c) */
#undef SDL_TIMERS_DISABLED

/* disable the dummy video driver (src/video/dummy/\*.c) */
#undef SDL_VIDEO_DRIVER_DUMMY

/* disable the dummy filesystem driver (src/filesystem/dummy/\*.c) */
#undef SDL_FILESYSTEM_DUMMY 

#define SDL_BYTEORDER 1234

#ifdef SDL_DYNAMIC_API
#undef SDL_DYNAMIC_API
#define SDL_DYNAMIC_API 0
#endif

#undef SDL_HAVE_YUV
#define SDL_HAVE_YUV 0

#endif

#endif /* SDL_config_minimal_h_ */
