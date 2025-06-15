/* tcaposix.c */

#ifdef FEATURE_RCSID
char id_tcaposix[] = "$Id: tcaposix.h,v 2.13 2003/01/26 19:41:36 steve Exp $";
#endif

#include <signal.h>
#include <unistd.h>

/* HPUX does a "#define ttysize winsize".  Elvis doesn't like that. */
#undef ttysize


#if USE_PROTOTYPES
static void catchsig(int signo);
#endif


/* this function is used to catch signals */
static void catchsig(signo)
	int	signo;
{
	caught = (1 << signo);
}

/* get the original tty state */
static void ttyinit2()
{
}

/* switch to the tty state that elvis runs in */
void ttyraw(erasekey)
	char	*erasekey;	/* where to store the ERASE char */
{
    *erasekey = '\b'; // Set the erase key to backspace
}

/* switch back to the original tty state */
void ttynormal()
{
}

#include <profan/syscall.h>
#include <profan.h>

/* Read from keyboard with timeout.  For POSIX, we use VMIN/VTIME to implement
 * the timeout.  For no timeout, VMIN should be 1 and VTIME should be 0; for
 * timeout, VMIN should be 0 and VTIME should be the timeout value.
 */
int ttyread(buf, len, timeout)
	char	*buf;	/* where to place the read characters */
	int	len;	/* maximum number of characters to read */
	int	timeout;/* timeout (0 for none) */
{
    int debut, sc = 0;
    int clen = 0;

    static int shift = 0;

    if (timeout > 0)
        debut = syscall_timer_get_ms();

    while (clen < len - 3) {
        sc = syscall_sc_get();

        if (sc == 0) {
            if (clen || (timeout && syscall_timer_get_ms() - debut >= timeout))
                break;
            usleep(10000); // Sleep for 10 ms
            continue;
        }

        if (sc >= KB_RVAL) {
            if (sc == KB_RVAL + KB_LSHIFT || sc == KB_RVAL + KB_RSHIFT) {
                shift = 0;
            }
            continue;
        }

        char c;

        switch (sc) {
            case KB_LSHIFT:
            case KB_RSHIFT:
                shift = 1;
                continue;
            case KB_ENTER:
                c = '\n';
                break;
            case KB_BACK:
                c = '\b';
                break;
            case KB_TAB:
                c = '\t';
                break;
            case KB_DEL:
                buf[clen++] = '\033';
                buf[clen++] = '[';
                buf[clen++] = '3';
                buf[clen++] = '~'; // Delete key
                continue;
            case KB_ESC: // Escape key
                buf[clen++] = '\033';
                return clen;
            case KB_TOP:
                buf[clen++] = '\033';
                buf[clen++] = '[';
                buf[clen++] = 'A'; // Move cursor up
                continue;
            case KB_BOT:
                buf[clen++] = '\033';
                buf[clen++] = '[';
                buf[clen++] = 'B'; // Move cursor down
                continue;
            case KB_RIGHT:
                buf[clen++] = '\033';
                buf[clen++] = '[';
                buf[clen++] = 'C'; // Move cursor right
                continue;
            case KB_LEFT:
                buf[clen++] = '\033';
                buf[clen++] = '[';
                buf[clen++] = 'D'; // Move cursor left
                continue;
            default:
                c = profan_kb_get_char(sc, shift);
                break;
        }

        if (c == 0)
            continue;

        buf[clen++] = c;
    }

    return clen;
}
