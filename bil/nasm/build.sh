#!/bin/sh

PROFAN_PATH="../../profanOS"
OUT_PATH="../../build"

CFLAGS="-std=c17 -fwrapv -U__STRICT_ANSI__ -fno-common -ffunction-sections -fdata-sections -fvisibility=hidden -Wall \
-W -pedantic -Wno-variadic-macros -Wno-long-long -Wno-stringop-truncation -Wno-unused -Wno-attributes \
-Wno-shift-negative-value -ffreestanding -fno-exceptions -m32 -I$PROFAN_PATH/include/zlibs -O1 -nostdinc -DHAVE_CONFIG_H \
-I. -I. -I./include -I./include -I./x86 -I./x86 -I./asm -I./asm -I./disasm -I./disasm -I./output -I./output"

SRCDIRS="asm common disasm macros nasmlib output stdlib x86"
OBJS=""

for dir in $SRCDIRS; do
    for file in $dir/*.c; do
        echo "CC $file"
        gcc $CFLAGS -c -o ${file%.c}.o $file &
        OBJS="$OBJS ${file%.c}.o"
    done
done

wait

ar cq $OUT_PATH/libnasm.a $OBJS
ranlib $OUT_PATH/libnasm.a

gcc -c $CFLAGS -o mains/ndisasm.o mains/ndisasm.c
gcc -c $CFLAGS -o mains/nasm.o mains/nasm.c

#this will work
echo "==="
ld -m elf_i386 -nostdlib -L $PROFAN_PATH/out/zlibs -T $PROFAN_PATH/tools/link_elf.ld -lc -o $OUT_PATH/nasm.elf $PROFAN_PATH/out/make/entry_elf.o mains/nasm.o $OUT_PATH/libnasm.a
ld -m elf_i386 -nostdlib -L $PROFAN_PATH/out/zlibs -T $PROFAN_PATH/tools/link_elf.ld -lc -o $OUT_PATH/ndisasm.elf $PROFAN_PATH/out/make/entry_elf.o mains/ndisasm.o $OUT_PATH/libnasm.a

rm */*.o
