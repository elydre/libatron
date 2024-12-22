#ifndef SIGNAL_H
#define SIGNAL_H

void (*signal(int sig, void (*func)(int)))(int);

// sig_atomic_t definition
typedef int sig_atomic_t;

#define SIGINT 2
#define SIG_DFL 0

#endif
