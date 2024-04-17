#!/bin/sh

# define directories
OBJDIR="build"
SRCDIR="src"

# define cc and linker
CC="gcc"
LD="ld"

# get output name from directory name
OUTPUT=$(basename $(pwd))

# get profan path from argument, or use default
if [ -z "$1" ]; then
    profan_path="../profanOS"
else
    profan_path=$1
fi

if [ ! -d "$profan_path" ]; then
    echo "Error: ProfanOS path not found" > /dev/stderr
    exit 1
fi

# define extra libraries
if [ -z "$2" ]; then
    extra_libs=""
else
    extra_libs="$2"
fi

# define flags
CFLAGS="-ffreestanding -fno-exceptions -m32 -I$profan_path/include/zlibs -O1 -nostdinc"
LDFLAGS="-m elf_i386 -nostdlib -L $profan_path/out/zlibs -T $profan_path/tools/link_elf.ld -lc $extra_libs"

# find all source files
SRC=$(find $SRCDIR -name "*.c")

# function to compile a file
compile_file() {
    if [ -z "$1" ]; then
        echo "Internal error: No file provided"
        exit 1
    fi

    src=$1
    obj=$OBJDIR/$(basename $src .c).o

    echo "CC $src" > /dev/tty

    $CC $CFLAGS -c $src -o $obj
    if [ $? -ne 0 ]; then
        echo "Error: Compilation failed" > /dev/stderr
        exit 1
    fi

    echo $obj
}

# function to link files
link_files() {
    if [ $# -lt 1 ]; then
        echo "Internal error: No output provided"
        exit 1
    fi

    echo "LD $@" > /dev/tty

    $LD $LDFLAGS -o $OUTPUT.elf $@
    if [ $? -ne 0 ]; then
        echo "Error: Linking failed" > /dev/stderr
        exit 1
    fi
}

mkdir -p $OBJDIR

# compile all source files and store the object files
objs=""
for src in $SRC; do
    obj=$(compile_file $src)
    objs="$objs $obj"
done

# sort object files by name (for consistency)
objs=$(echo $objs | tr " " "\n" | sort -n)

# compile zentry and link all object files
link_files $(compile_file $profan_path/tools/entry_elf.c $OBJDIR/zentry.o) $objs

echo "> $OUTPUT.elf created successfully" > /dev/tty
