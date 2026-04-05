#ifndef SIGNAL_H
#define SIGNAL_H

// sig_atomic_t
typedef int sig_atomic_t;

// sigset_t
typedef int sigset_t;

// struct sigaction
struct sigaction {
    void (*sa_handler)(int);
    sigset_t sa_mask;
    int sa_flags;
};

#define SIGINT 2
#define SIGKILL 9
#define SIGTERM 15
#define SIGHUP 1
#define SIGQUIT 3
#define SIGPIPE 13
#define SIGTSTP 20
#define SIGTTOU 21
#define SIGTTIN 22
#define SIGCHLD 17
#define SIGCONT 18

#define NSIG 64
#define SIG_SETMASK 0

#define SIG_IGN NULL
#define SIG_DFL NULL

#define signal(signum, handler) (void) 0
#define sigaction(signum, act, oldact) (int) 0
#define sigfillset(set) (void) 0
#define sigprocmask(how, set, oldset) (void) 0
#define sigsuspend(mask) (void) 0
#define raise(signum) (int) 0
#define kill(pid, signum) (int) 0
#define sigemptyset(set) (void) 0

#endif // SIGNAL_H
