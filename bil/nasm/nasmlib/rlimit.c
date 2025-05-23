 /* ----------------------------------------------------------------------- *
 *
 *   Copyright 2020 The NASM Authors - All Rights Reserved
 *   See the file AUTHORS included with the NASM distribution for
 *   the specific copyright holders.
 *
 *   Redistribution and use in source and binary forms, with or without
 *   modification, are permitted provided that the following
 *   conditions are met:
 *
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above
 *     copyright notice, this list of conditions and the following
 *     disclaimer in the documentation and/or other materials provided
 *     with the distribution.
 *
 *     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
 *     CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
 *     INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 *     MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *     DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 *     CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *     SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 *     NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *     HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 *     OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 *     EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ----------------------------------------------------------------------- */

#include "compiler.h"
#include "nasmlib.h"

#undef HAVE_SYS_RESOURCE_H

#ifdef HAVE_SYS_RESOURCE_H
# include <sys/resource.h>
#endif

#if defined(HAVE_GETRLIMIT) && defined(RLIMIT_STACK)

size_t nasm_get_stack_size_limit(void)
{
    struct rlimit rl;

    if (getrlimit(RLIMIT_STACK, &rl))
        return SIZE_MAX;

# ifdef RLIM_SAVED_MAX
    if (rl.rlim_cur == RLIM_SAVED_MAX)
        rl.rlim_cur = rl.rlim_max;
# endif

    if (
# ifdef RLIM_INFINITY
        rl.rlim_cur >= RLIM_INFINITY ||
# endif
# ifdef RLIM_SAVED_CUR
        rl.rlim_cur == RLIM_SAVED_CUR ||
# endif
# ifdef RLIM_SAVED_MAX
        rl.rlim_cur == RLIM_SAVED_MAX ||
# endif
        (size_t)rl.rlim_cur != rl.rlim_cur)
        return SIZE_MAX;

    return rl.rlim_cur;
}

#else

size_t nasm_get_stack_size_limit(void)
{
    return SIZE_MAX;
}

#endif
