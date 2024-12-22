#ifdef __profanOS__

#include <profan/syscall.h>
#include <stdlib.h>
#include "devices.h"

// display_update
// display_handle_events

int x, y;
uint32_t *screen;

void display_init(void) {
    screen = NULL;
    x = y = 0;
}

void *display_get_pixels(void) {
    return screen;
}

void display_set_resolution(int width, int height) {
    if (screen)
        free(screen);
    screen = malloc(width * height * sizeof(uint32_t));
    x = width;
    y = height;
}

void display_sleep(int ms) {
    syscall_process_sleep(ms, syscall_process_pid());
}

void display_release_mouse(void) {
    ;
}

void display_handle_events(void) {
    int k = syscall_sc_get();
    if (k == 0)
        return;
    kbd_add_key(k & 0xFF);
}

void display_update(void) {
    uint32_t *fb = syscall_vesa_fb();
    uint32_t pitch = syscall_vesa_pitch();

    for (int i = 0; i <= x; i++) {
        for (int j = 0; j <= y; j++) {
            if (i == x || j == y)
                fb[i + j * pitch] = 0xFFFFFF;
            else
                fb[i + j * pitch] = screen[i + j * x];
        }
    }
}


#endif
