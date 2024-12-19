#include <profan/syscall.h>
#include <stdlib.h>
#include <stdio.h>

char *msgs[] = {
    "- A cyber-security expert would tell you that\n"
    "  using your first and last name as a password\n"
    "  is probably not a good idea.\n"
    "- You know, I don't need a cyber-security expert\n"
    "  to tell me that.",

    "Coding in C++ has given me specific reasons to\n"
    "hate it, rather than just doing it on principle.",

    "I had written sopt instead of stop\n\n"
    "       -- asqel, sulfur commit message",

    "I don't want it to become garbage\n\n"
    "       -- asqel on the sulfur language",

    "But I have a holy crusade. I dislike waste.\n"
    "I dislike over-engineering. I absolutely detest\n"
    "the \"because we can\" mentality. I think small\n"
    "is beautiful, and the guildeline should always\n"
    "be that performance and size are more important\n"
    "than features.\n\n"
    "       -- Linus Torvalds on the Linux kernel",

    "An idiot admires complexity, a genius admires\n"
    "simplicity, a physicist tries to make it simple,\n"
    "for an idiot anything the more complicated it is\n"
    "the more he will admire it, if you make something\n"
    "so clusterfucked he can't understand it he's\n"
    "gonna think you're a god cause you made it so\n"
    "complicated nobody can understand it.\n\n"
    "       -- Terry A. Davis",

    "You see\n"
    "I'm a real poet\n\n"
    "My life is my poetry\n"
    "My lovemaking is my legacy\n\n"
    "You can have a life beyond your wildest dreams\n\n"
    "All you have to do is change everything...\n\n"
    "       -- Lana Del Rey, Salamander",
};

int main(int argc, char **argv) {
    if (argc != 1) {
        fprintf(stderr, "Usage: %s\n", argv[0]);
        return 1;
    }

    // set the random seed to the current time
    srand(syscall_timer_get_ms());

    // print a random message
    printf("\n%s\n\n", msgs[rand() % (sizeof(msgs) / sizeof(msgs[0]))]);

    return 0;
}
