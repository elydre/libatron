/*
** $Id: lprofanlib.c $
** unofficial profanOS library
*/

#define lprofanlib_c
#define LUA_LIB

#include "lprefix.h"

#include <profan/syscall.h>
#include <stdlib.h>
#include <dlfcn.h>

#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"


static int pf_setpixel (lua_State *L) {
  int x = luaL_checkinteger(L, 1);
  int y = luaL_checkinteger(L, 2);
  int color = luaL_checkinteger(L, 3);
  
  uint32_t *fb = syscall_vesa_fb();
  int pitch = syscall_vesa_pitch();
  
  fb[y * pitch + x] = color;

  return 1;
}

static int pf_ticks (lua_State *L) {
  lua_pushinteger(L, syscall_timer_get_ms());
  return 1;
}

static int pf_cfunc (lua_State *L) {
  // lua: profan.cfunc(function_name, arg1_size, arg1, arg2_size, arg2, ...)
  // all arguments are integers
  
  void *function_pointer = dlsym(NULL, luaL_checkstring(L, 1));

  if (!function_pointer) {
    luaL_error(L, "dlsym failed");
    return 0;
  }

  int arg_count = lua_gettop(L) - 1;
  if (arg_count % 2 != 0) {
    luaL_error(L, "Usage: function, arg1_size, arg1, arg2_size, arg2, ...");
    return 0;
  }

  if (arg_count > 12) {
    luaL_error(L, "too many arguments, max is 6");
    return 0;
  }

  uint32_t args[6];
  int i, size;

  for (i = 0; i < arg_count; i += 2) {
    size = luaL_checkinteger(L, i + 2);
    if (size == 1) {
      args[i / 2] = luaL_checkinteger(L, i + 3) << 24;
    } else if (size == 2) {
      args[i / 2] = luaL_checkinteger(L, i + 3) << 16;
    } else if (size == 4) {
      args[i / 2] = luaL_checkinteger(L, i + 3);
    } else {
      luaL_error(L, "invalid argument size");
      return 0;
    }
  }

  int return_value = 0;

  switch (arg_count) {
    case 0:
      return_value = ((uint32_t (*)())
            function_pointer)();
      break;
    case 2:
      return_value = ((uint32_t (*)(uint32_t))
            function_pointer)(args[0]);
      break;
    case 4:
      return_value = ((uint32_t (*)(uint32_t, uint32_t))
            function_pointer)(args[0], args[1]);
      break;
    case 6:
      return_value = ((uint32_t (*)(uint32_t, uint32_t, uint32_t))
            function_pointer)(args[0], args[1], args[2]);
      break;
    case 8:
      return_value = ((uint32_t (*)(uint32_t, uint32_t, uint32_t, uint32_t))
            function_pointer)(args[0], args[1], args[2], args[3]);
      break;
    case 10:
      return_value = ((uint32_t (*)(uint32_t, uint32_t, uint32_t, uint32_t, uint32_t))
            function_pointer)(args[0], args[1], args[2], args[3], args[4]);
      break;
    case 12:
      return_value = ((uint32_t (*)(uint32_t, uint32_t, uint32_t, uint32_t, uint32_t, uint32_t))
            function_pointer)(args[0], args[1], args[2], args[3], args[4], args[5]);
      break;
  }

  lua_pushinteger(L, return_value);
  return 1;
}

static int pf_memval (lua_State *L) {
  // lua: profan.memval(address, size)
  // size is 1, 2 or 4
  int address = luaL_checkinteger(L, 1);
  int size = luaL_checkinteger(L, 2);
  if (size == 1) {
    lua_pushinteger(L, *((uint8_t *) address));
  } else if (size == 2) {
    lua_pushinteger(L, *((uint16_t *) address));
  } else if (size == 4) {
    lua_pushinteger(L, *((uint32_t *) address));
  } else {
    luaL_error(L, "invalid size");
  }
  return 1;
}

static int pf_memset (lua_State *L) {
  // lua: profan.memset(address, size, value)
  // size is 1, 2 or 4
  int address = luaL_checkinteger(L, 1);
  int size = luaL_checkinteger(L, 2);
  int value = luaL_checkinteger(L, 3);
  if (size == 1) {
    *((char *)address) = value;
  } else if (size == 2) {
    *((short *)address) = value;
  } else if (size == 4) {
    *((int *)address) = value;
  } else {
    luaL_error(L, "invalid size");
  }
  return 1;
}

static int pf_pin (lua_State *L) {
  // lua: profan.pin(port, size)
  // size is 1, 2 or 4
  int port = luaL_checkinteger(L, 1);
  int size = luaL_checkinteger(L, 2);
  int result;
  if (size == 1) {
    asm volatile("in %%dx, %%al" : "=a" (result) : "d" (port));
  } else if (size == 2) {
    asm volatile("in %%dx, %%ax" : "=a" (result) : "d" (port));
  } else if (size == 4) {
    asm volatile("in %%dx, %%eax" : "=a" (result) : "d" (port));
  } else {
    luaL_error(L, "invalid size");
  }
  lua_pushinteger(L, result);
  return 1;
}

static int pf_pout (lua_State *L) {
  // lua: profan.pout(port, size, value)
  // size is 1, 2 or 4
  int port = luaL_checkinteger(L, 1);
  int size = luaL_checkinteger(L, 2);
  int value = luaL_checkinteger(L, 3);
  if (size == 1) {
    asm volatile("out %%al, %%dx" : : "a" (value), "d" (port));
  } else if (size == 2) {
    asm volatile("out %%ax, %%dx" : : "a" (value), "d" (port));
  } else if (size == 4) {
    asm volatile("out %%eax, %%dx" : : "a" (value), "d" (port));
  } else {
    luaL_error(L, "invalid size");
  }
  return 1;
}

static const luaL_Reg profanlib[] = {
  {"setpixel",  pf_setpixel},
  {"ticks",     pf_ticks},
  {"cfunc",     pf_cfunc},
  {"memval",    pf_memval},
  {"memset",    pf_memset},
  {"pin",       pf_pin},
  {"pout",      pf_pout},
  {NULL, NULL}
};


/* }====================================================== */


LUAMOD_API int luaopen_profan (lua_State *L) {
  luaL_newlib(L, profanlib);
  return 1;
}
