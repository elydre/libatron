//doomgeneric for cross-platform development library 'Simple DirectMedia Layer'

#include "doomkeys.h"
#include "m_argv.h"
#include "doomgeneric.h"

#include <profan/syscall.h>
#include <profan.h>

uint32_t *current_screen;

void DG_Init() {
    current_screen = calloc(DOOMGENERIC_RESX * DOOMGENERIC_RESY, sizeof(uint32_t));
}

uint8_t convertToDoomKey(uint8_t scancode) {
    switch (scancode) {
        case 0x9C:
        case 0x1C:
            return KEY_ENTER;
        case 0x01:
            return KEY_ESCAPE;
        case 0xCB:
        case 0x4B:
            return KEY_LEFTARROW;
        case 0xCD:
        case 0x4D:
            return KEY_RIGHTARROW;
        case 0xC8:
        case 0x48:
            return KEY_UPARROW;
        case 0xD0:
        case 0x50:
            return KEY_DOWNARROW;
        case 0x1D:
            return KEY_FIRE;
        case 0x39:
            return KEY_USE;
        case 0x2A:
        case 0x36:
            return KEY_RSHIFT;
        default:
            return profan_kb_get_char(scancode, scancode < 10);
    }

    return 0;
}


void DG_DrawFrame() {
    uint32_t *fb = syscall_vesa_fb();
    uint32_t pitch = syscall_vesa_pitch();

    int pos = -1;
    for (int y = 0; y < DOOMGENERIC_RESY * 2; y += 2) {
        for (int x = 0; x < DOOMGENERIC_RESX * 2; x += 2) {
            pos++;
            if (current_screen[pos] == DG_ScreenBuffer[pos]) continue;
            current_screen[pos] = DG_ScreenBuffer[pos];
            fb[y * pitch + x] = current_screen[pos];
            fb[y * pitch + x + 1] = current_screen[pos];
            fb[(y + 1) * pitch + x] = current_screen[pos];
            fb[(y + 1) * pitch + x + 1] = current_screen[pos];
        }
    }
}

void DG_SleepMs(uint32_t ms) {
    syscall_process_sleep(syscall_process_pid(), ms);
    return;
}

uint32_t DG_GetTicksMs() {
    return syscall_timer_get_ms();
}

int DG_GetKey(int* pressed, uint8_t* doomKey) {
    uint8_t scancode, key;

    scancode = (uint8_t) syscall_sc_get();
    if (scancode == 0) return 0;

    if (scancode > 127) {
        scancode -= 128;
        *pressed = 0;
    } else {
        *pressed = 1;
    }

    key = convertToDoomKey(scancode);
    if (key == 0) return 0;

    *doomKey = key;

    return 1;
}

void DG_SetWindowTitle(const char * title) {
    return;
}

int main(int argc, char **argv) {
    doomgeneric_Create(argc, argv);

    while (1) {
        doomgeneric_Tick();
    }

    return 0;
}
