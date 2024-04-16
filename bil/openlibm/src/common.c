#include <openlibm_math.h>

#include "math_private.h"

complex long double __mulxc3(long double a, long double b, long double c, long double d) {
    complex long double result = (a + b * I) * (c + d * I);
    return result;
}

OLM_DLLEXPORT int isopenlibm(void) {
    return 1;
}
