#ifndef SIGNAL_H
#define SIGNAL_H

#define SIG_DFL ((void (*)(int)) 0)
#define SIG_IGN ((void (*)(int)) 0)
#define SIG_INT ((void (*)(int)) 0)

#define SIGINT 2
#define SIGQUIT 3

#define signal(s, f) 0
#define kill(p, s) 0

#endif
